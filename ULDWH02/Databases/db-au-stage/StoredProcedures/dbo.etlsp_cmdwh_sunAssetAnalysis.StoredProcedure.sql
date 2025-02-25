USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_sunAssetAnalysis]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_sunAssetAnalysis]
as

SET NOCOUNT ON


if object_id('[db-au-cmdwh].dbo.sunAssetAnalysis') is null
begin
    create table [db-au-cmdwh].[dbo].sunAssetAnalysis
    (
        AnalysisDimensionKey [varchar](6) NOT NULL,
        BusinessUnit [varchar](3) NOT NULL,
        AnalysisDimensionCode [varchar](2) NOT NULL,
        AssetCode [varchar](10) NOT NULL,
        UpdateCount [smallint] NOT NULL,
        LastChangeUserID [varchar](3) NOT NULL,
        LastChangeDateTime [datetime] NOT NULL,
        AnalysisCode [varchar](15) NOT NULL
    )

    if exists(select name from sys.indexes where name = 'idx_sunAssetAnalysis_AnalysisDimensionKey')
    drop index idx_sunAssetAnalysis_AnalysisDimensionKey on sunAssetAnalysis.AnalysisDimensionKey

    if exists(select name from sys.indexes where name = 'idx_sunAssetAnalysis_BusinessUnit')
    drop index idx_sunAssetAnalysis_BusinessUnit on sunAssetAnalysis.BusinessUnit

    if exists(select name from sys.indexes where name = 'idx_sunAssetAnalysis_AssetCode')
    drop index idx_sunAssetAnalysis_AssetCode on sunAssetAnalysis.AssetCode

    create index idx_sunAssetAnalysis_AnalysisDimensionKey on [db-au-cmdwh].dbo.sunAssetAnalysis(AnalysisDimensionKey)
    create index idx_sunAssetAnalysis_BusinessUnit on [db-au-cmdwh].dbo.sunAssetAnalysis(BusinessUnit)
    create index idx_sunAssetAnalysis_AssetCode on [db-au-cmdwh].dbo.sunAssetAnalysis(AssetCode)
end
else
    truncate table [db-au-cmdwh].dbo.sunAssetAnalysis



declare @SQL varchar(max)
declare @TableName varchar(100)
declare @BusinessUnit varchar(3)
declare CUR_Table cursor for select
                                TargetTableName as TableName,
                                substring(TargetTableName,5,3) as BusinessUnit
                             from [db-au-stage].dbo.etl_meta_data
                             where SourceDatabaseName = 'SUNDB' and right(TargetTableName,len(TargetTableName)-8) = 'ASSET_ANL_CAT_au'

open CUR_Table
fetch NEXT from CUR_Table into @TableName, @BusinessUnit

while @@FETCH_STATUS = 0
begin
    select @SQL = 'insert into [db-au-cmdwh].dbo.sunAssetAnalysis with(tablock)
                    (AnalysisDimensionKey,
                    BusinessUnit,
                    AnalysisDimensionCode,
                    AssetCode,
                    UpdateCount,
                    LastChangeUserID,
                    LastChangeDateTime,
                    AnalysisCode)
                    select ''' + @BusinessUnit + '-'' + [ANL_CAT_ID] as AssetKey, ''' + @BusinessUnit + ''' as BusinessUnit,
                    [ANL_CAT_ID],
                    [ASSET_CODE],
                    [UPDATE_COUNT],
                    [LAST_CHANGE_USER_ID],
                    [LAST_CHANGE_DATETIME],
                    [ANL_CODE]
                from [db-au-stage].dbo.' + @TableName
    execute(@SQL)
    fetch NEXT from Cur_Table into @TableName, @BusinessUnit
end

close CUR_Table
deallocate CUR_Table

GO
