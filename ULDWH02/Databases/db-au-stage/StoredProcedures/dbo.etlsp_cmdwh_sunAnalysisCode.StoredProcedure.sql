USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_sunAnalysisCode]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_sunAnalysisCode]
as

SET NOCOUNT ON


if object_id('[db-au-cmdwh].dbo.sunAnalysisCode') is null
begin
    create table [db-au-cmdwh].[dbo].sunAnalysisCode
    (
        AnalysisDimensionKey varchar(6) NOT NULL,
        BusinessUnit varchar(3) NOT NULL,
        AnalysisDimensionCode [varchar](2) NOT NULL,
        AnalysisCode [varchar](15) NOT NULL,
        UpdateCount [smallint] NOT NULL,
        LastChangeUserID [varchar](3) NOT NULL,
        LastChangeDateTime [datetime] NOT NULL,
        [Status] [smallint] NOT NULL,
        [Lookup] [varchar](15) NOT NULL,
        [Name] [varchar](50) NULL,
        DataAccessGroupCode [varchar](5) NULL,
        BudgetCheck [smallint] NOT NULL,
        BudgetStop [smallint] NOT NULL,
        ProhibitPost [smallint] NOT NULL,
        BudgetNavigationOption [smallint] NOT NULL,
        CombinedBudgetCheck [smallint] NOT NULL
    )

    if exists(select name from sys.indexes where name = 'idx_sunAnalysisCode_AnalysisDimensionKey')
    drop index idx_sunAnalysisCode_AnalysisDimensionKey on sunAnalysisCode.AnalysisDimensionKey

    if exists(select name from sys.indexes where name = 'idx_sunAnalysisCode_BusinessUnit')
    drop index idx_sunAnalysisCode_BusinessUnit on sunAnalysisCode.BusinessUnit

    if exists(select name from sys.indexes where name = 'idx_sunAnalysisCode_AnalysisDimensionCode')
    drop index idx_sunAnalysisCode_AnalysisDimensionCode on sunAnalysisCode.AnalysisDimensionCode

    if exists(select name from sys.indexes where name = 'idx_sunAccountAnalysis_AnalysisCode')
    drop index idx_sunAccountAnalysis_AnalysisCode on sunAccountAnalysis.AnalysisCode

    create index idx_sunAccountAnalysis_AnalysisDimensionKey on [db-au-cmdwh].dbo.sunAnalysisCode(AnalysisDimensionKey)
    create index idx_sunAccountAnalysis_BusinessUnit on [db-au-cmdwh].dbo.sunAnalysisCode(BusinessUnit)
    create index idx_sunAccountAnalysis_AnalysisDimensionCode on [db-au-cmdwh].dbo.sunAnalysisCode(AnalysisDimensionCode)
    create index idx_sunAccountAnalysis_AnalysisCode on [db-au-cmdwh].dbo.sunAnalysisCode(AnalysisCode)
end
else
    truncate table [db-au-cmdwh].dbo.sunAnalysisCode



declare @SQL varchar(max)
declare @TableName varchar(100)
declare @BusinessUnit varchar(3)
declare CUR_Table cursor for select
                                TargetTableName as TableName,
                                substring(TargetTableName,5,3) as BusinessUnit
                             from [db-au-stage].dbo.etl_meta_data
                             where SourceDatabaseName = 'SUNDB' and right(TargetTableName,len(TargetTableName)-8) = 'ANL_CODE_au'

open CUR_Table
fetch NEXT from CUR_Table into @TableName, @BusinessUnit

while @@FETCH_STATUS = 0
begin
    select @SQL = 'insert into [db-au-cmdwh].dbo.sunAnalysisCode with(tablock)
                (AnalysisDimensionKey,BusinessUnit,AnalysisDimensionCode,AnalysisCode,
                UpdateCount,LastChangeUserID,LastChangeDateTime,[Status],[Lookup],[Name],
                DataAccessGroupCode,BudgetCheck,BudgetStop,ProhibitPost,BudgetNavigationOption,
                CombinedBudgetCheck)
                select ''' + @BusinessUnit + '-'' + ANL_CAT_ID as AnalysisDimensionKey, ''' + @BusinessUnit + ''' as BusinessUnit,ANL_CAT_ID,ANL_CODE,
                    UPDATE_COUNT,LAST_CHANGE_USER_ID,LAST_CHANGE_DATETIME,[STATUS],[LOOKUP],[NAME],[DAG_CODE],[BDGT_CHECK],[BDGT_STOP],PROHIBIT_POSTING,
                    NAVIGATION_OPTION,COMBINED_BDGT_CHCK
                from [db-au-stage].dbo.' + @TableName
    execute(@SQL)
    fetch NEXT from Cur_Table into @TableName, @BusinessUnit
end

close CUR_Table
deallocate CUR_Table

GO
