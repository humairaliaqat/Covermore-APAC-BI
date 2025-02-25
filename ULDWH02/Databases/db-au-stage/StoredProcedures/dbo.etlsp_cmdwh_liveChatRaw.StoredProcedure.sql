USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_liveChatRaw]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_liveChatRaw]
as
begin
--20190319, LL, new API key, change page request to 1000 (new API restriction), set proxy manually (unsupported https proxy)

    set nocount on

    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    declare @mergeoutput table (MergeAction varchar(20))

	begin try
	
		exec syssp_getrunningbatch
			@SubjectArea = 'Live Chat',
			@BatchID = @batchid out,
			@StartDate = @start out,
			@EndDate = @end out
			
	end try
	
	begin catch
		
		set @batchid = -1
	
	end catch

    select
        @name = object_name(@@procid)
	
    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'


    if object_id('[db-au-cmdwh]..lcLiveChatRaw') is null
    begin

        create table [db-au-cmdwh]..lcLiveChatRaw
        (
            BIRowID bigint not null identity(1,1),
            ChatID varchar(50),
            DataType varchar(10),
            ChatJSON nvarchar(max),
            BatchID int
        )

        create unique clustered index cidx on [db-au-cmdwh]..lcLiveChatRaw(BIRowID)
        create nonclustered index idx_chat on [db-au-cmdwh]..lcLiveChatRaw(ChatID) include (ChatJSON)
        create nonclustered index idx_batch on [db-au-cmdwh]..lcLiveChatRaw(BatchID,DataType) include (ChatID,ChatJSON)

    end

    --check page count for the period
    declare 
        @page int = 1,
        @maxpage int,
        @id varchar(50),
        @string nvarchar(max),
        @missed nvarchar(max),
        @cut nvarchar(max),
        @sql varchar(max),
        @output varchar(max),
        @i int,
        @j int,
        @k int,
        @pos int

    --begin transaction

    --begin try


        ------------------------------------------------------------------------------------------chat------------------------------------------------------------------------------------------------

        set @sql = 'exec xp_cmdshell ''e:\etl\tool\curl\curl.exe --proxy http://sydpxy01:8080  -s -u ryan.power@covermore.com.au:07bb362a0caabf0dc7a2cd556c1ab0dd -H X-API-Version:2 "https://api.livechatinc.com/chats?page=1000&date_from=' + convert(varchar(10), @start, 120) + '&date_to=' + convert(varchar(10), @end, 120) + '"'''
        --print @sql


        if object_id('tempdb..#temptable') is not null
            drop table #temptable

        create table #temptable (string varchar(max))

        insert into #temptable (string)
        exec (@sql)

        select
            @maxpage =
                case
                    when charindex('"pages"', string) = 0 then 0
                    else try_convert(int, replace(right(string, len(string) - charindex('"pages"', string) + 1 - 8), '}', ''))
                end
        from
            #temptable

        select
            @maxpage = isnull(@maxpage, 0)

        print @maxpage


        delete from #temptable

        set @page = 1

        while @page <= @maxpage
        begin

            print @page

            set @output = 'e:\etl\data\' + convert(varchar(128), newid()) + '.json'

            --get json output
            set @sql = 'exec xp_cmdshell ''e:\etl\tool\curl\curl.exe --proxy http://sydpxy01:8080 -s -o ' + @output + ' -u ryan.power@covermore.com.au:07bb362a0caabf0dc7a2cd556c1ab0dd -H X-API-Version:2 "https://api.livechatinc.com/chats?date_from=' + convert(varchar(10), @start, 120) + '&date_to=' + convert(varchar(10), @end, 120) + '&page=' + convert(varchar, @page) + '"'''
            --print @sql
            exec (@sql)


            --store in temp table
            set @sql =
                '
                select
                    BulkColumn
                from 
                    openrowset
                    (
                        bulk ''' + @output + ''', 
                        single_clob
                    ) t
                '

            --print @sql

            insert into #temptable (string)
            exec (@sql)


            set @page = @page + 1


            set @sql = 'exec xp_cmdshell ''del ' + @output + ''''
            exec (@sql)

        end


        ----prepare json table on postgresql server
        --execute
        --(
        --'
        --drop table public.livechatdump
        --'
        --) at [POSTGRESTAGE]

        --execute
        --(
        --'
        --create table public.livechatdump
        --(
        --    chatstring varchar(10000000)
        --)
        --'
        --) at [POSTGRESTAGE]

        --insert into [POSTGRESTAGE].[db-au-stage].[public].[livechatdump]
        --(
        --    chatstring
        --)
        --select
        --    string
        --from
        --    #temptable


        --if object_id('tempdb..#parsedchat') is not null
        --    drop table #parsedchat

        --select
        --    replace(t.id , '"', '') ChatID,
        --    JSON
        --into #parsedchat
        --from
        --    openquery
        --    (
        --        POSTGRESTAGE,
        --        '
        --        select 
        --            r->''id'' "id",
        --            cast(r as varchar(100000)) "json"
        --        from
        --            livechatdump t
        --            cross join json_array_elements((chatstring::json)->''chats'') r
        --        '
        --    ) t

        if object_id('tempdb..#parsedchat') is not null
            drop table #parsedchat

        select
            json_value(c.value, '$.id') ChatID,
            c.value JSON
        into #parsedchat
        from
            #temptable t
            cross apply openjson(t.string, '$.chats') c


        delete 
        from
            [db-au-cmdwh]..lcLiveChatRaw
        where
            ChatID in
            (
                select 
                    ChatID
                from
                    #parsedchat
            )

        insert into [db-au-cmdwh]..lcLiveChatRaw
        (
            DataType,
            ChatID,
            ChatJSON,
            BatchID
        )
        select 
            'Chat',
            ChatID,
            JSON,
            @batchid
        from
            #parsedchat



        ------------------------------------------------------------------------------------------ticket------------------------------------------------------------------------------------------------
        delete from #temptable

        set @sql = 'exec xp_cmdshell ''e:\etl\tool\curl\curl.exe --proxy http://sydpxy01:8080 -s -u ryan.power@covermore.com.au:07bb362a0caabf0dc7a2cd556c1ab0dd -H X-API-Version:2 "https://api.livechatinc.com/tickets?page=1000&date_from=' + convert(varchar(10), @start, 120) + '&date_to=' + convert(varchar(10), @end, 120) + '"'''
        --print @sql


        insert into #temptable (string)
        exec (@sql)

        select
                --string,
                --substring(string, charindex('"pages"', string) + 8, charindex(',', string, charindex('"pages"', string) + 1) - charindex('"pages"', string) - 8)

            @maxpage =
                case
                    when charindex('"pages"', string) = 0 then 0
                    else try_convert(int, substring(string, charindex('"pages"', string) + 8, charindex(',', string, charindex('"pages"', string) + 1) - charindex('"pages"', string) - 8))
                end
        from
            #temptable

        select
            @maxpage = isnull(@maxpage, 0)

        print @maxpage


        delete from #temptable
        set @page = 1

        while @page <= @maxpage
        begin

            print @page

            set @output = 'e:\etl\data\' + convert(varchar(128), newid()) + '.json'

            --get json output
            set @sql = 'exec xp_cmdshell ''e:\etl\tool\curl\curl.exe --proxy http://sydpxy01:8080 -s -o ' + @output + ' -u ryan.power@covermore.com.au:1fcc401d32e20087eaca94f8dc010f3a -H X-API-Version:2 "https://api.livechatinc.com/tickets?date_from=' + convert(varchar(10), @start, 120) + '&date_to=' + convert(varchar(10), @end, 120) + '&page=' + convert(varchar, @page) + '"'''
            --print @sql
            exec (@sql)


            --store in temp table
            set @sql =
                '
                select
                    BulkColumn
                from 
                    openrowset
                    (
                        bulk ''' + @output + ''', 
                        single_clob
                    ) t
                '

            --print @sql

            insert into #temptable (string)
            exec (@sql)


            set @page = @page + 1


            set @sql = 'exec xp_cmdshell ''del ' + @output + ''''
            exec (@sql)

        end


        --prepare json table on postgresql server
        --execute
        --(
        --'
        --drop table public.livechatdump
        --'
        --) at [POSTGRESTAGE]

        --execute
        --(
        --'
        --create table public.livechatdump
        --(
        --    chatstring varchar(10000000)
        --)
        --'
        --) at [POSTGRESTAGE]

        --insert into [POSTGRESTAGE].[db-au-stage].[public].[livechatdump]
        --(
        --    chatstring
        --)
        --select
        --    string
        --from
        --    #temptable


        --if object_id('tempdb..#parsedticket') is not null
        --    drop table #parsedticket

        --select
        --    replace(t.id , '"', '') ChatID,
        --    JSON
        --into #parsedticket
        --from
        --    openquery
        --    (
        --        POSTGRESTAGE,
        --        '
        --        select 
        --            r->''id'' "id",
        --            cast(r as varchar(100000)) "json"
        --        from
        --            livechatdump t
        --            cross join json_array_elements((chatstring::json)->''tickets'') r
        --        '
        --    ) t

        if object_id('tempdb..#parsedticket') is not null
            drop table #parsedticket

        select
            json_value(c.value, '$.id') ChatID,
            c.value JSON
        into #parsedticket
        from
            #temptable t
            cross apply openjson(t.string, '$.tickets') c

        delete 
        from
            [db-au-cmdwh]..lcLiveChatRaw
        where
            ChatID in
            (
                select 
                    ChatID
                from
                    #parsedticket
            )

        insert into [db-au-cmdwh]..lcLiveChatRaw
        (
            DataType,
            ChatID,
            ChatJSON,
            BatchID
        )
        select 
            'Ticket',
            ChatID,
            JSON,
            @batchid
        from
            #parsedticket



        exec syssp_genericerrorhandler
            @LogToTable = 1,
            @ErrorCode = '0',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Finished',
            @LogSourceCount = @sourcecount,
            @LogInsertCount = @insertcount,
            @LogUpdateCount = @updatecount

    --end try

    --begin catch

    --    if @@trancount > 0
    --        rollback transaction

    --    exec syssp_genericerrorhandler
    --        @SourceInfo = 'live chat data refresh failed',
    --        @LogToTable = 1,
    --        @ErrorCode = '-100',
    --        @BatchID = @batchid,
    --        @PackageID = @name

    --end catch

    --if @@trancount > 0
    --    commit transaction

end
GO
