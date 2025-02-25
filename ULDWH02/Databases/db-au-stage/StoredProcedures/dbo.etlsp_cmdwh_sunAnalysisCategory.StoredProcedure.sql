USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_sunAnalysisCategory]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_sunAnalysisCategory]
as

SET NOCOUNT ON


if object_id('[db-au-cmdwh].dbo.sunAnalysisCategory') is null
begin
    create table [db-au-cmdwh].[dbo].sunAnalysisCategory
    (
        AnalysisDimensionKey varchar(6) NOT NULL,
        BusinessUnit varchar(3) NOT NULL,
        AnalysisDimensionCode [varchar](2) NOT NULL,
        UpdateCount [smallint] NOT NULL,
        LastChangeUserID [varchar](3) NOT NULL,
        LastChangeDateTime [datetime] NOT NULL,
        [Status] [smallint] NOT NULL,
        LookupCode [varchar](15) NOT NULL,
        AnalysisTableID [smallint] NULL,
        ShortHeading [varchar](15) NOT NULL,
        [Description] [varchar](40) NOT NULL,
        DataAccessGroupCode [char](5) NULL,
        AmendCode [smallint] NOT NULL,
        Validated [smallint] NOT NULL,
        [Length] [smallint] NOT NULL,
        [Linked] [smallint] NOT NULL
    )

    if exists(select name from sys.indexes where name = 'idx_sunAnalysisCategory_AnalysisDimensionKey')
    drop index idx_sunAnalysisCategory_AnalysisDimensionKey on sunAnalysisCategory.AnalysisDimensionKey

    if exists(select name from sys.indexes where name = 'idx_sunAnalysisCategory_BusinessUnit')
    drop index idx_sunAnalysisCategory_BusinessUnit on sunAnalysisCategory.BusinessUnit

    if exists(select name from sys.indexes where name = 'idx_sunAnalysisCategory_AnalysisDimensionCode')
    drop index idx_sunAnalysisCategory_AnalysisDimensionCode on sunAnalysisCategory.AnalysisDimensionCode

    create index idx_sunAnalysisCategory_AnalysisDimensionKey on [db-au-cmdwh].dbo.sunAnalysisCategory(AnalysisDimensionKey)
    create index idx_sunAnalysisCategory_BusinessUnit on [db-au-cmdwh].dbo.sunAnalysisCategory(BusinessUnit)
    create index idx_sunAnalysisCategory_AnalysisDimensionCode on [db-au-cmdwh].dbo.sunAnalysisCategory(AnalysisDimensionCode)
end
else
    truncate table [db-au-cmdwh].dbo.sunAnalysisCategory



declare @SQL varchar(max)
declare @TableName varchar(100)
declare @BusinessUnit varchar(3)
declare CUR_Table cursor for select
                                TargetTableName as TableName,
                                substring(TargetTableName,5,3) as BusinessUnit
                             from [db-au-stage].dbo.etl_meta_data
                             where SourceDatabaseName = 'SUNDB' and right(TargetTableName,len(TargetTableName)-8) = 'ANL_CAT_au'

open CUR_Table
fetch NEXT from CUR_Table into @TableName, @BusinessUnit

while @@FETCH_STATUS = 0
begin
    select @SQL = 'insert into [db-au-cmdwh].dbo.sunAnalysisCategory with(tablock)
                    (AnalysisDimensionKey,
                    BusinessUnit,
                    AnalysisDimensionCode,
                    UpdateCount,
                    LastChangeUserID,
                    LastChangeDateTime,
                    [Status],
                    LookupCode,
                    AnalysisTableID,
                    ShortHeading,
                    [Description],
                    DataAccessGroupCode,
                    AmendCode,
                    Validated,
                    [Length],
                    [Linked])
                    select ''' + @BusinessUnit + '-'' + ANL_CAT_ID as AnalysisDimensionKey, ''' + @BusinessUnit + ''' as BusinessUnit,
                        [ANL_CAT_ID],
                        [UPDATE_COUNT],
                        [LAST_CHANGE_USER_ID],
                        [LAST_CHANGE_DATETIME],
                        [STATUS],
                        [LOOKUP],
                        [USEABLE_ANL_ENT_ID],
                        [S_HEAD],
                        [DESCR],
                        [DAG_CODE],
                        [AMEND_CODE],
                        [VALIDATE_IND],
                        [LNGTH],
                        [LINKED]
                from [db-au-stage].dbo.' + @TableName
    execute(@SQL)
    fetch NEXT from Cur_Table into @TableName, @BusinessUnit
end

close CUR_Table
deallocate CUR_Table

GO
