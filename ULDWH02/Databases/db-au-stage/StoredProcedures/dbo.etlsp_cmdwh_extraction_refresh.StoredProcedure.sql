USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_extraction_refresh]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_extraction_refresh]
  @RunMode varchar(10) = 'AUTO',    --values: AUTO or MANUAL
  @ExtractionType varchar(20),      --values: FileFormat, Export, Import
  @Country varchar(2),              --values: AU, NZ, UK
  @Database varchar(20),            --values: %Trips%, %Corporate%, %Claims%
  @ServerName varchar(100),         --values: valid servername for authentication eg WILLS
  @UserName varchar(100),           --values: valid username to log into database server
  @Password varchar(100) = '',      --values: password to log into database server
  @StartDate varchar(10),           --if RunMode = MANUAL and TableType = F, then format YYYY-MM-DD
  @EndDate varchar(10)              --if RunMode = MANUAL and TableType = F, then format YYYY-MM-DD
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.etlsp_cmdwh_extraction_refresh
--  Author:         Linus Tor
--  Date Created:   20100913
--  Description:    This ETL stored procedure extracts data (as specified by the parameter values)
--                  and outputs to a native text file. The native text file format needs to already exists for the extraction
--                  to work. Any errors encountered during the extraction will be output to the error file.
--
--  Parameters:     @RunMode:  AUTO or MANUAL. During normal ETL run, the default value is AUTO and only refers to
--                  factual tables.
--                  @ExtractionType: Specify what extraction type.
--                    FileFormat - create native text file format
--                    CreateTable - create table definitions in [db-au-stage] database (for importing)
--                    Export - export tables to native text output file
--                    Import - import native text data to database server
--                    The sequence of extraction under normal run should be:
--                    1 - FileFormat - create fileformats for export/importing
--                    2 - CreateTable - create target tables for importing data on Target Server
--                    3 - Export - copy data from source to native text file formats
--                    4 - Import - copy data from native text files to database tables
--                  @Country:  AU, NZ, or UK. Determines the source system country where the table to be extracted
--                  @Database: What database source are we extracting? values: %Trips%, %Corporate%, %Claims%
--                  @ServerName: Enter the server that will authenticate the login
--                  @UserName: valid username to log into database server
--                  @Password: valid password to log into database server
--                  @StartDate: if RunMode = MANUAL and TableType = F, then format YYYY-MM-DD
--                  @EndDate: if RunMode = MANUAL and TableType = F, then format YYYY-MM-DD
--
--  Change History: 20110707 - LT - Created
--                  20111206 - LS - Add time offset for UK on AUTO run.
--                                  Set to -13h due to refresh runs on 12PM AU time
--                                  giving a day cut off for UK
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @RunMode varchar(10)
declare @ExtractionType varchar(20)
declare @Country varchar(2)
declare @Database varchar(20)
declare @ServerName varchar(100)
declare @UserName varchar(100)
declare @Password varchar(100)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @RunMode = 'AUTO', @ExtractionType = 'Import', @Country = 'AU', @Database = '%Trips%', @ServerName = 'WILLS', @UserName = 'bobjuser', @Password = '!readonly!', @StartDate = null, @EndDate = null
--select @RunMode = 'AUTO', @ExtractionType = 'Export', @Country = 'NZ', @Database = '%Trips%', @ServerName = 'IC201', @UserName = 'sa', @Password = '', @StartDate = null, @EndDate = null
--select @RunMode = 'AUTO', @ExtractionType = 'Export', @Country = 'UK', @Database = '%Trips%', @ServerName = 'IC201', @UserName = 'sa', @Password = '', @StartDate = null, @EndDate = null
*/

--DECLARE VARIABLES
declare @rptStartDate datetime
declare @rptEndDate datetime
declare @Sql varchar(8000)

--Check run mode and assign reporting start and end dates
if @RunMode = 'AUTO'
begin

  select
    @rptStartDate = convert(varchar(10),getdate(),120),
    @rptEndDate = convert(varchar(10),getdate(),120)

  if @Country = 'UK'
  begin

    select
      @rptStartDate = convert(varchar(10), dateadd(hour, -13, getdate()), 120),
      @rptEndDate = convert(varchar(10), dateadd(hour, -13, getdate()), 120)

  end

end

else
  select
    @rptStartDate = @StartDate,
    @rptEndDate = @EndDate

if object_id('tempdb..#BCPCommand') is not null drop table #BCPCommand
create table #BCPCommand
(
  BCPCommand varchar(max) null,
  TableType varchar(255) null
)

if @ExtractionType = 'FileFormat'                --create file formats
begin

  insert #BCPCommand
  select BCP_FFCommand as BCPCommand, TableType
  from [db-au-stage].dbo.etl_meta_data_refresh
  where Country = @Country and isActive = 1 and SourceDatabaseName like @Database

end
else if @ExtractionType = 'Export'                --insert Export BCP commands into table
begin

  insert #BCPCommand
  select BCP_ExportCommand as BCPCommand, TableType
  from [db-au-stage].dbo.etl_meta_data_refresh
  where Country = @Country and isActive = 1 and SourceDatabaseName like @Database

end
else if @ExtractionType = 'Import'                --insert Import BCP commands into table
begin

  insert #BCPCommand
  select BCP_ImportCommand as BCPCommand, TableType
  from [db-au-stage].dbo.etl_meta_data_refresh
  where Country = @Country and isActive = 1 and SourceDatabaseName like @Database

end
else if @ExtractionType = 'CreateTable'              --create table definitions
begin

  insert #BCPCommand
  select SQL_CreateTableDef as BCPCommand, TableType
  from [db-au-stage].dbo.etl_meta_data_refresh
  where Country = @Country and isActive = 1 and SourceDatabaseName like @Database

end

--For each BCP command records, execute BCP until no more records
declare @BCPCommand varchar(max)
declare @TableType varchar(1)
declare CUR_BCPCommand cursor for select BCPCommand, TableType from #BCPCommand

open CUR_BCPCommand
fetch NEXT from CUR_BCPCommand into @BCPCommand, @TableType

while @@FETCH_STATUS = 0
begin

  select @SQL = @BCPCommand

  if @ExtractionType = 'CreateTable'
  begin

    execute(@SQL)

  end

  else
  begin

    if @ExtractionType = 'Import'              --uses trusted connections to log into target server
    begin

      select @SQL = replace(@SQL,'-U @UserName','-T')
      select @SQL = replace(@SQL,'-P @Password','')
      select @SQL = replace(@SQL,'-S @ServerName','-S localhost')

    end

    else
    begin                          --set username and passwords to log into source servers

      select @SQL = replace(@SQL,'@UserName',@UserName)
      select @SQL = replace(@SQL,'@Password',@Password)
      select @SQL = replace(@SQL,'@ServerName',@ServerName)

    end

    if @TableType = 'F'                    --update sql statements for FACT tables
    begin

      select @SQL = replace(@SQL,'@rptStartDate','''' + convert(varchar(10),@rptStartDate,120) + '''')
      select @SQL = replace(@SQL,'@rptEndDate','''' + convert(varchar(10),@rptEndDate,120) + '''')

    end

    execute master.dbo.xp_cmdshell @SQL

  end

  fetch NEXT from CUR_BCPCommand into @BCPCommand, @TableType

end

close CUR_BCPCommand
deallocate CUR_BCPCommand

drop table #BCPCommand



GO
