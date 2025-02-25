USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_sunAccountAnalysis]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_sunAccountAnalysis]
as

SET NOCOUNT ON


if object_id('[db-au-cmdwh].dbo.sunAccountAnalysis') is null
begin
    create table [db-au-cmdwh].[dbo].sunAccountAnalysis
    (
        AccountKey varchar(19) NOT NULL,
        AnalysisDimensionKey [varchar](6) NOT NULL,
        BusinessUnit varchar(3) NOT NULL,
        AnalysisDimensionCode char(2) NOT NULL,
        AccountCode varchar(15) NOT NULL,
        UpdateCount smallint NOT NULL,
        LastChangeUserID varchar(3) NOT NULL,
        LastChangeDateTime datetime NOT NULL,
        AnalysisCode varchar(15) NOT NULL
    )

    if exists(select name from sys.indexes where name = 'idx_sunAccountAnalysis_AccountKey')
    drop index idx_sunAccountAnalysis_AccountKey on sunAccountAnalysis.AccountKey

    if exists(select name from sys.indexes where name = 'idx_sunAccountAnalysis_AnalysisDimensionKey')
    drop index idx_sunAccountAnalysis_AnalysisDimensionKey on sunAccountAnalysis.AnalysisDimensionKey

    if exists(select name from sys.indexes where name = 'idx_sunAccountAnalysis_BusinessUnit')
    drop index idx_sunAccountAnalysis_BusinessUnit on sunAccountAnalysis.BusinessUnit

    if exists(select name from sys.indexes where name = 'idx_sunAccountAnalysis_AccountCode')
    drop index idx_sunAccountAnalysis_AccountCode on sunAccountAnalysis.AccountCode

    if exists(select name from sys.indexes where name = 'idx_sunAccountAnalysis_AnalysisDimensionCode')
    drop index idx_sunAccountAnalysis_AnalysisDimensionCode on sunAccountAnalysis.AnalysisDimensionCode

    create index idx_sunAccountAnalysis_AccountKey on [db-au-cmdwh].dbo.sunAccountAnalysis(AccountKey)
    create index idx_sunAccountAnalysis_AnalysisDimensionKey on [db-au-cmdwh].dbo.sunAccountAnalysis(AnalysisDimensionKey)
    create index idx_sunAccountAnalysis_BusinessUnit on [db-au-cmdwh].dbo.sunAccountAnalysis(BusinessUnit)
    create index idx_sunAccountAnalysis_AccountCode on [db-au-cmdwh].dbo.sunAccountAnalysis(AccountCode)
    create index idx_sunAccountAnalysis_AnalysisDimensionCode on [db-au-cmdwh].dbo.sunAccountAnalysis(AnalysisDimensionCode)
end
else
    truncate table [db-au-cmdwh].dbo.sunAccountAnalysis



declare @SQL varchar(max)
declare @TableName varchar(100)
declare @BusinessUnit varchar(3)
declare CUR_Table cursor for select
                                TargetTableName as TableName,
                                substring(TargetTableName,5,3) as BusinessUnit
                             from [db-au-stage].dbo.etl_meta_data
                             where SourceDatabaseName = 'SUNDB' and right(TargetTableName,len(TargetTableName)-8) = 'ACNT_ANL_CAT_au'

open CUR_Table
fetch NEXT from CUR_Table into @TableName, @BusinessUnit

while @@FETCH_STATUS = 0
begin
    select @SQL = 'insert into [db-au-cmdwh].dbo.sunAccountAnalysis with(tablock)
                (AccountKey,AnalysisDimensionKey,BusinessUnit,AnalysisDimensionCode,AccountCode,UpdateCount,
                LastChangeUserID,LastChangeDateTime,AnalysisCode)
                select ''' + @BusinessUnit + '-'' + ACNT_CODE as AccountKey, ''' + @BusinessUnit + '-'' + ANL_CAT_ID as AnalysisDimensionKey, ''' + @BusinessUnit + ''' as BusinessUnit, ANL_CAT_ID,ACNT_CODE,UPDATE_COUNT,LAST_CHANGE_USER_ID,
                LAST_CHANGE_DATETIME,ANL_CODE
                from [db-au-stage].dbo.' + @TableName
    execute(@SQL)
    fetch NEXT from Cur_Table into @TableName, @BusinessUnit
end

close CUR_Table
deallocate CUR_Table

GO
