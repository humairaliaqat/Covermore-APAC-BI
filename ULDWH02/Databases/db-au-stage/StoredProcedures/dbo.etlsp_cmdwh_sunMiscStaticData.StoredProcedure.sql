USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_sunMiscStaticData]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_sunMiscStaticData]
as

SET NOCOUNT ON


if object_id('[db-au-cmdwh].dbo.sunMiscStaticData') is null
begin
    create table [db-au-cmdwh].[dbo].sunMiscStaticData
    (
        SunTableKey [varchar](7) NOT NULL,
        BusinessUnit [varchar](3) NOT NULL,
        SunTable [varchar](3) NOT NULL,
        KeyFields [varchar](61) NOT NULL,
        [Lookup] [varchar](10) NOT NULL,
        LastChangeDateTime [datetime] NOT NULL,
        DataAccessGroupCode [char](5) NULL,
        UpdateCount [smallint] NOT NULL,
        LastChangeUserID [varchar](3) NOT NULL,
        RecordStatus [numeric](1, 0) NOT NULL,
        SunData [varchar](927) NOT NULL
    )

    if exists(select name from sys.indexes where name = 'idx_sunMiscStaticData_SunTableKey')
    drop index idx_sunMiscStaticData_SunTableKey on sunMiscStaticData.SunTableKey

    if exists(select name from sys.indexes where name = 'idx_sunMiscStaticData_BusinessUnit')
    drop index idx_sunMiscStaticData_BusinessUnit on sunMiscStaticData.BusinessUnit

    if exists(select name from sys.indexes where name = 'idx_sunMiscStaticData_SunTable')
    drop index idx_sunMiscStaticData_SunTable on sunMiscStaticData.SunTable

    create index idx_sunMiscStaticData_AnalysisEntityKey on [db-au-cmdwh].dbo.sunMiscStaticData(SunTableKey)
    create index idx_sunMiscStaticData_BusinessUnit on [db-au-cmdwh].dbo.sunMiscStaticData(BusinessUnit)
    create index idx_sunMiscStaticData_SunTable on [db-au-cmdwh].dbo.sunMiscStaticData(SunTable)
end
else
    truncate table [db-au-cmdwh].dbo.sunMiscStaticData



declare @SQL varchar(max)
declare @TableName varchar(100)
declare @BusinessUnit varchar(3)
declare CUR_Table cursor for select
                                TargetTableName as TableName,
                                substring(TargetTableName,5,3) as BusinessUnit
                             from [db-au-stage].dbo.etl_meta_data
                             where SourceDatabaseName = 'SUNDB' and right(TargetTableName,len(TargetTableName)-8) = 'SSRFMSC_au'

open CUR_Table
fetch NEXT from CUR_Table into @TableName, @BusinessUnit

while @@FETCH_STATUS = 0
begin
    select @SQL = 'insert into [db-au-cmdwh].dbo.sunMiscStaticData with(tablock)
                    (SunTableKey,
                    BusinessUnit,
                    SunTable,
                    KeyFields,
                    [Lookup],
                    LastChangeDateTime,
                    DataAccessGroupCode,
                    UpdateCount,
                    LastChangeUserID,
                    RecordStatus,
                    SunData)
                    select ''' + @BusinessUnit + '-'' + SUN_TB as SunTableKey, ''' + @BusinessUnit + ''' as BusinessUnit,
                        [SUN_TB],
                        [KEY_FIELDS],
                        [LOOKUP],
                        [LAST_CHANGE_DATETIME],
                        [DAG],
                        [UPDATE_COUNT],
                        [LAST_CHANGE_USER_ID],
                        [RECORD_STATUS],
                        [SUN_DATA]
                from [db-au-stage].dbo.' + @TableName
    execute(@SQL)
    fetch NEXT from Cur_Table into @TableName, @BusinessUnit
end

close CUR_Table
deallocate CUR_Table

GO
