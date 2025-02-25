USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_sunAnalysisStructure]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_sunAnalysisStructure]
as

SET NOCOUNT ON


if object_id('[db-au-cmdwh].dbo.sunAnalysisStructure') is null
begin
    create table [db-au-cmdwh].[dbo].sunAnalysisStructure
    (
        AnalysisEntityKey [varchar](10) NOT NULL,
        AnalysisDimensionKey [varchar](6) NOT NULL,
        BusinessUnit [varchar](3) NOT NULL,
        AnalysisEntityCode [smallint] NOT NULL,
        AnalysisDimensionCode [varchar](2) NOT NULL,
        UpdateCount [smallint] NOT NULL,
        LastChangeUserID [varchar](3) NOT NULL,
        LastChangeDateTime [datetime] NOT NULL,
        EntryNumber [smallint] NOT NULL,
        Validated [smallint] NOT NULL,
        ShortHeading [varchar](15) NOT NULL
    )

    if exists(select name from sys.indexes where name = 'idx_sunAnalysisStructure_AnalysisEntityKey')
    drop index idx_sunAnalysisStructure_AnalysisEntityKey on sunAnalysisStructure.AnalysisEntityKey

    if exists(select name from sys.indexes where name = 'idx_sunAnalysisStructure_AnalysisDimensionKey')
    drop index idx_sunAnalysisStructure_AnalysisDimensionKey on sunAnalysisStructure.AnalysisDimensionKey

    if exists(select name from sys.indexes where name = 'idx_sunAnalysisStructure_BusinessUnit')
    drop index idx_sunAnalysisStructure_BusinessUnit on sunAnalysisStructure.BusinessUnit

    if exists(select name from sys.indexes where name = 'idx_sunAnalysisStructure_AnalysisEntityCode')
    drop index idx_sunAnalysisStructure_AnalysisEntityCode on sunAnalysisStructure.AnalysisEntityCode

    if exists(select name from sys.indexes where name = 'idx_sunAnalysisStructure_AnalysisDimensionCode')
    drop index idx_sunAnalysisStructure_AnalysisDimensionCode on sunAnalysisStructure.AnalysisDimensionCode

    create index idx_sunAnalysisStructure_AnalysisEntityKey on [db-au-cmdwh].dbo.sunAnalysisStructure(AnalysisEntityKey)
    create index idx_sunAnalysisStructure_AnalysisDimensionKey on [db-au-cmdwh].dbo.sunAnalysisStructure(AnalysisDimensionKey)
    create index idx_sunAnalysisStructure_BusinessUnit on [db-au-cmdwh].dbo.sunAnalysisStructure(BusinessUnit)
    create index idx_sunAnalysisStructure_AnalysisEntityCode on [db-au-cmdwh].dbo.sunAnalysisStructure(AnalysisEntityCode)
    create index idx_sunAnalysisStructure_AnalysisDimensionCode on [db-au-cmdwh].dbo.sunAnalysisStructure(AnalysisDimensionCode)
end
else
    truncate table [db-au-cmdwh].dbo.sunAnalysisStructure



declare @SQL varchar(max)
declare @TableName varchar(100)
declare @BusinessUnit varchar(3)
declare CUR_Table cursor for select
                                TargetTableName as TableName,
                                substring(TargetTableName,5,3) as BusinessUnit
                             from [db-au-stage].dbo.etl_meta_data
                             where SourceDatabaseName = 'SUNDB' and right(TargetTableName,len(TargetTableName)-8) = 'ANL_ENT_DEFN_au'

open CUR_Table
fetch NEXT from CUR_Table into @TableName, @BusinessUnit

while @@FETCH_STATUS = 0
begin
    select @SQL = 'insert into [db-au-cmdwh].dbo.sunAnalysisStructure with(tablock)
                    (AnalysisEntityKey,
                    AnalysisDimensionKey,
                    BusinessUnit,
                    AnalysisEntityCode,
                    AnalysisDimensionCode,
                    UpdateCount,
                    LastChangeUserID,
                    LastChangeDateTime,
                    EntryNumber,
                    Validated,
                    ShortHeading)
                    select ''' + @BusinessUnit + '-'' + convert(varchar,[ANL_ENT_ID]) as AnalysisEntityKey, ''' + @BusinessUnit + '-'' + ANL_CAT_ID as AnalysisDimensionKey,
                        ''' + @BusinessUnit + ''' as BusinessUnit,
                        [ANL_ENT_ID],
                        [ANL_CAT_ID],
                        [UPDATE_COUNT],
                        [LAST_CHANGE_USER_ID],
                        [LAST_CHANGE_DATETIME],
                        [ENTRY_NUM],
                        [VALIDATE_IND],
                        [S_HEAD]
                from [db-au-stage].dbo.' + @TableName

    execute(@SQL)
    fetch NEXT from Cur_Table into @TableName, @BusinessUnit
end

close CUR_Table
deallocate CUR_Table

GO
