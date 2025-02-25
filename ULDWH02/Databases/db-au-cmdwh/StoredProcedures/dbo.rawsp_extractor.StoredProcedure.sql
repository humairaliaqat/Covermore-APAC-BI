USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_extractor]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rawsp_extractor]
    @ExtractID int = null,
    @ExtractName varchar(50) = null,
    @SQL varchar(max) = null,
    @ParamCountry varchar(2) = null,
    @ParamAgencyGroup varchar(2) = null,
    @ParamDateRange varchar(30) = null,
    @ParamStartDate date = null,
    @ParamEndDate date = null,
    @EnclosedBy varchar(1) = '',
    @SeparatedBy varchar(1) = '',
    @SelectiveEnclose bit = 1,
    @IncludeHeader bit = 0,
    @Debug bit = 0
  
as
begin  

/****************************************************************************************************/
--  Name:           rawsp_extractor
--  Author:         Leonardus Setyabudi
--  Date Created:   20111020
--  Description:    This stored procedure extract data to csv lines formatted as given parameters
--  Parameters:    
--                  source parameters, priority in this order
--                  @ExtractID: get statement to execute by usrRawExtract.ID
--                  @ExtractName: get statement to execute by usrRawExtract.Name
--                  @SQL: statement to execute
--
--                  format parameters
--                  @EnclosedBy: Enclose the data by this character
--                  @SeparatedBy: Separate the fields by this character
--                  @SelectiveEnclose: Flag, 1: Only enclose string and date values, 0: enclose all
--                  @IncludeHeader: Flag, 1: include header, 0: no header
--
--                  optional parameters
--                  @Param*: parameters to be forwarded
--  
--  Change History: 20111024 - LS - Created
--                  20111025 - LS - Add additional optional parameters
--                                  Add optional sql source (by Extract ID, Extract Name or SQL)
--                                  Add error handling
--                  20121203 - LS - bug fix, when separatedby is set to blank the sp failed, 
--                                  change the tail truncation length when separatedby is blank
--                  20131213 - LS - 1. enable dumping data to alternative output file directly.
--                                  2. enable logging to specified table.
--                                  Due to limitation of openrowset,
--                                  extract that needs to dump data must specify the output file name
--                                  in additional column xOutputFileNamex.
--                                  extract that needs to log data must specify the record id in
--                                  additional column xDataIDx.
--                                  These columns will be stripped from the end result.
--                  20131227 - LS - error handling on data logger
--                  20140205 - LS - logger:
--                                  add xDataValuex, general use
--                                  add DataTimeStamp
--                                  add option to replace
--                  20140206 - LS - add Debug flag
--                  20150210 - LS - bug fix, ignore xDataValuex from output file
--                  20161104 - LS - replace bcp -c with -w (UTF16-LE) hardcode for propello atm
--                  20170816 - LL - fucking out of order insert (IAL data extract)
--
/****************************************************************************************************/
--uncomment to debug
--declare 
--    @ExtractID int,
--    @ExtractName varchar(50),
--    @SQL varchar(max),
--    @EnclosedBy varchar(1),
--    @SeparatedBy varchar(1),
--    @SelectiveEnclose bit,
--    @IncludeHeader bit,
--    @ParamCountry varchar(2),
--    @ParamAgencyGroup varchar(2),
--    @ParamDateRange varchar(30),
--    @ParamStartDate date,
--    @ParamEndDate date,
--    @Debug bit

--select 
--    @ExtractID = 70, 
--    @EnclosedBy = '',
--    @SeparatedBy = '',
--    @SelectiveEnclose = 0,
--    @IncludeHeader = 1,
--    @ParamCountry = 'NZ',
--    @ParamAgencyGroup = 'AZ',
--    @ParamDateRange = 'Yesterday',
--    @Debug = 1

    set nocount on 

    declare 
        @localsql varchar(max),
        @temptable varchar(64),
        @guid varchar(40),
        @dumpdata bit,
        @outputpath varchar(max),
        @outputfilename varchar(max),
        @globalresult varchar(64),
        @logdata bit,
        @logtable varchar(64),
        @replacelog bit
    
    set @guid = newid()

    -- use guid for global temp table, multi user safe
    set @temptable = '##svextract_' + @guid
    set @globalresult = '##output_' + @guid

    begin try

        if object_id('tempdb..' + @temptable) is not null
            exec ('drop table [' + @temptable + ']')

        if object_id('tempdb..' + @globalresult) is not null
            exec ('drop table [' + @globalresult + ']')

        if object_id('tempdb..#outputfile') is not null
            drop table #outputfile
            
        exec('create table [' + @globalresult + '] (Data nvarchar(max), xxx_idx bigint)')
        create table #outputfile (OutputFile varchar(max))

        /* construct @sql statement to execute */
        -- get by ID
        if isnull(@ExtractID, 0) <> 0
            select 
                @SQL = Procs,
                @dumpdata = dumpOutput,
                @outputpath = OutputPath,
                @logdata = logOutput,
                @logtable = LogTable,
                @replacelog = replaceLog
            from 
                usrRawExtract 
            where 
                ID = @ExtractID

        -- get by Name
        else if ltrim(rtrim(isnull(@ExtractName, ''))) <> ''
            select 
                @SQL = Procs,
                @dumpdata = dumpOutput,
                @outputpath = OutputPath,
                @logdata = logOutput,
                @logtable = LogTable,
                @replacelog = replaceLog
            from 
                usrRawExtract 
            where 
                [Name] = @ExtractName
                
        /* create log table if it doesn't exist */
        if 
            @logdata = 1 and 
            not exists 
            (
                select null
                from
                    information_schema.tables
                where
                    table_name = @logtable
            )
        begin
    
            set @localsql =
                '
                create table [' + @logtable + ']
                (
                    BIRowID bigint identity(1,1) not null,
                    xOutputFileNamex varchar(64) null,
                    xDataIDx varchar(41) null,
                    xDataValuex money not null default 0,
                    Data nvarchar(max) null,
                    xFailx bit not null default 0,
                    DataTimeStamp datetime not null default getdate()
                )

                create clustered index [idx_' + @logtable + '_BIRowID] on [' + @logtable + '] (BIRowID)
                create index [idx_' + @logtable + '_xOutputFileNamex] on [' + @logtable + '] (xOutputFileNamex)
                create index [idx_' + @logtable + '_xDataIDx] on [' + @logtable + '] (xDataIDx, xFailx, xDataValuex)
                create index [idx_' + @logtable + '_DataTimeStamp] on [' + @logtable + '] (DataTimeStamp)
                '
                
            exec (@localsql)
                
        end

        -- escape single quote
        set @SQL = replace(@SQL, '''', '''''')

        if ltrim(rtrim(isnull(@SQL, ''))) <> ''
        begin

            set @EnclosedBy = isnull(@EnclosedBy, '')
            set @SeparatedBy = isnull(@SeparatedBy, '')

            -- populate parameters
            if @ParamCountry is not null
                set @SQL = replace(@SQL, '[Country]', @ParamCountry)
                
            if @ParamAgencyGroup is not null
                set @SQL = replace(@SQL, '[AgencyGroup]', @ParamAgencyGroup)
                
            if @ParamDateRange is not null
                set @SQL = replace(@SQL, '[DateRange]', @ParamDateRange)
                
            set @SQL = replace(@SQL, '[StartDate]', isnull('''''' + convert(varchar(10), @ParamStartDate, 120) + '''''', 'null'))
            set @SQL = replace(@SQL, '[EndDate]', isnull('''''' + convert(varchar(10), @ParamEndDate, 120) + '''''', 'null'))

            /* store sql statement result to global temp table */
            set @localsql =
                '    
                select 
                    *,
                    row_number() over (order by (select 1)) xxx_idx
                into [' + @temptable + ']
                from 
                    openrowset(
                        ''SQLNCLI'', 
                        ''Server=(local);Trusted_Connection=yes;'',
                        ''' + @SQL + ''' 
                    )
                '

            if @Debug = 1
                print @localsql
                
            exec (@localsql)

            /* log data */
            if 
                @logdata = 1 and
                exists
                (
                    select null
                    from
                        tempdb.information_schema.columns
                    where
                        table_name = @temptable and
                        column_name = 'xOutputFileNamex'
                ) and
                exists
                (
                    select null
                    from
                        tempdb.information_schema.columns
                    where
                        table_name = @temptable and
                        column_name = 'xDataIDx'
                ) and
                exists
                (
                    select null
                    from
                        tempdb.information_schema.columns
                    where
                        table_name = @temptable and
                        column_name = 'Data'
                ) and
                exists
                (
                    select null
                    from
                        information_schema.columns
                    where
                        table_name = @logtable and
                        column_name = 'xOutputFileNamex'
                ) and
                exists
                (
                    select null
                    from
                        information_schema.columns
                    where
                        table_name = @logtable and
                        column_name = 'xDataIDx'
                ) and
                exists
                (
                    select null
                    from
                        information_schema.columns
                    where
                        table_name = @logtable and
                        column_name = 'Data'
                ) and               
                exists
                (
                    select null
                    from
                        information_schema.columns
                    where
                        table_name = @logtable and
                        column_name = 'DataTimeStamp'
                )                
            begin
            
                if @replacelog = 1
                begin
                
                    set @localsql = 'delete from [' + @logtable + '] where convert(date, DataTimeStamp) = convert(date, getdate())';
                    exec (@localsql)
                    
                end
            
                if 
                    exists
                    (
                        select null
                        from
                            tempdb.information_schema.columns
                        where
                            table_name = @temptable and
                            column_name = 'xDataValuex'
                    ) and
                    exists
                    (
                        select null
                        from
                            information_schema.columns
                        where
                            table_name = @logtable and
                            column_name = 'xDataValuex'
                    )
                    set @localsql =
                        'insert into [' + @logtable + '] (xOutputFileNamex, xDataIDx, xDataValuex, Data) ' +
                        'select xOutputFileNamex, xDataIDx, xDataValuex, Data from [' + @temptable + ']'
                
                else
                    set @localsql =
                        'insert into [' + @logtable + '] (xOutputFileNamex, xDataIDx, Data) ' +
                        'select xOutputFileNamex, xDataIDx, Data from [' + @temptable + ']'
                
                    
                exec (@localsql)
            
            end
                
            /* construct sql statement to get data as one formatted line */
            declare 
                @column varchar(255),
                @type varchar(255),
                @header varchar(max)
            declare cfields cursor local for 
                select
                    column_name,
                    data_type
                from 
                    tempdb.information_schema.columns
                where 
                    table_name like @temptable + '%' and
                    column_name not in ('xOutputFileNamex', 'xDataIDx', 'xDataValuex', 'xxx_idx')

            set @header = ''
            set @localsql = 'select '

            open cfields

            fetch next from cfields into @column, @type
            
            while @@fetch_status = 0 
            begin

                if @IncludeHeader = 1
                    set @header = 
                        @header +
                        case 
                            when @EnclosedBy = '''' then '''''' 
                            else @EnclosedBy 
                        end +
                        @column + 
                        case 
                            when @EnclosedBy = '''' then '''''' 
                            else @EnclosedBy 
                        end +
                        @SeparatedBy

                set @localsql = 
                    @localsql + 

                    --prefix enclosure
                    case
                        when 
                            @SelectiveEnclose = 0 or 
                            @type like '%char%' or 
                            @type like '%text%' or 
                            @type like '%date%' 
                        then 
                            '''' + 
                            case 
                                when @EnclosedBy = '''' then '''''' 
                                else @EnclosedBy 
                            end + 
                            '''+'
                        else
                            '+'
                    end +

                    --column name
                    case
                        when 
                            @type like '%char%' or 
                            @type like '%text%' 
                        then 'isnull(' + '[' + @column + ']' + ','''')'
                        when @type like '%date%' then 'isnull(convert(varchar, ' + '[' + @column + ']' + ', 120),'''')'
                        else 'isnull(convert(varchar, ' + '[' + @column + ']' + '),'''')'
                    end +

                    --suffix enclosure
                    case
                        when 
                            @SelectiveEnclose = 0 or 
                            @type like '%char%' or 
                            @type like '%text%' or 
                            @type like '%date%' 
                        then 
                            '+''' + 
                            case 
                                when @EnclosedBy = '''' then '''''' 
                                else @EnclosedBy 
                            end + ''''
                        else
                            ''
                    end +

                    --separator
                    '+''' + 
                    case 
                        when @SeparatedBy = '''' then '''''''''' 
                        else @SeparatedBy 
                    end + 
                    '''+'

                fetch next from cfields into @column, @type
                
            end

            close cfields
            deallocate cfields

            -- remove last column definition
            if @SeparatedBy = ''
                set @localsql = left(@localsql, len(@localsql) - 4) + ' [Data] from [' + @temptable + ']'
            else
                set @localsql = left(@localsql, len(@localsql) - 5) + ' [Data] from [' + @temptable + ']'

            if @IncludeHeader = 1
            begin
                -- remove last header definition
                set @header = left(@header, len(@header) - 1)

                -- use union all to keep header at the top
                set @localsql = 'select ''' + @header + ''' [Data] union all ' + @localsql

            end


            /*return standard output*/
            if @Debug = 1            
                print @localsql
                
            exec (@localsql)

            /*output to file if applicable*/
            if 
                @dumpdata = 1 and
                exists
                (
                    select null
                    from
                        tempdb.information_schema.columns
                    where
                        table_name = @temptable and
                        column_name = 'xOutputFileNamex'
                )
            begin
                
                insert into #outputfile (OutputFile)
                exec('select top 1 xOutputFileNamex from [' + @temptable + ']')
            
                select
                    @outputfilename = OutputFile
                from
                    #outputfile

                set @localsql = replace(@localsql, '[Data] union all', '[Data], 0 xxx_idx union all')
                set @localsql = replace(@localsql, '[Data] from', '[Data], xxx_idx from')
                
                exec (
                    'insert into [' + @globalresult + '] (data, xxx_idx) ' +
                    @localsql
                )

                if @ExtractID between 90 and 99 
                    set @SQL = 'exec xp_cmdshell ''bcp "select [Data] from tempdb..[' + @globalresult + '] order by xxx_idx" queryout "' + @outputpath + '\' + @outputfilename + '" -S localhost -T -w'''

                else
                    set @SQL = 'exec xp_cmdshell ''bcp "select [Data] from tempdb..[' + @globalresult + '] order by xxx_idx" queryout "' + @outputpath + '\' + @outputfilename + '" -S localhost -T -c'''

                if @Debug = 1            
                    print @SQL
                    
                exec (@SQL)
                
            end

        end

    end try

    /* catch exceptions */
    begin catch

        exec syssp_genericerrorhandler 'Data extraction failed'

    end catch

    /* cleanup */
    if object_id('tempdb..' + @temptable) is not null
        exec ('drop table [' + @temptable + ']')

    if object_id('tempdb..' + @globalresult) is not null
        exec ('drop table [' + @globalresult + ']')

    if object_id('tempdb..#outputfile') is not null
        drop table #outputfile
  
end
GO
