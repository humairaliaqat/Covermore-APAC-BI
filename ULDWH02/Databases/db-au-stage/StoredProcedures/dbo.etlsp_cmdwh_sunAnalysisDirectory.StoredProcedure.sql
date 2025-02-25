USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_sunAnalysisDirectory]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_sunAnalysisDirectory]
as

SET NOCOUNT ON


if object_id('[db-au-cmdwh].dbo.sunAnalysisDirectory') is null
begin
    create TABLE [db-au-cmdwh].dbo.sunAnalysisDirectory
    (
        AnalysisDirectoryID [smallint] NOT NULL,
        UpdateCount [smallint] NOT NULL,
        LastChangeUserID [varchar](3) NOT NULL,
        LastChangeDateTime [datetime] NOT NULL,
        [Description] [varchar](50) NOT NULL,
        AnalysisEntityFlag [smallint] NOT NULL,
        PriceBookFlag [smallint] NOT NULL,
        ApprovalFlag [smallint] NOT NULL,
        CostingFlag [smallint] NOT NULL,
        BudgetCheckFlag [smallint] NOT NULL,
        AnalysisEntityID [smallint] NULL,
        LandedCostFlag [smallint] NOT NULL,
        TransRefFlag [smallint] NOT NULL,
        FileCode [varchar](2) NOT NULL,
        UseableCurrencyCode [smallint] NOT NULL,
        SystemsUnionReserved [smallint] NOT NULL
    )

    if exists(select name from sys.indexes where name = 'idx_sunAnalysisDirectory_AnalysisDirectoryID')
    drop index idx_sunAnalysisDirectory_AnalysisDirectoryID on sunAnalysisDirectory.AnalysisDirectoryID

    if exists(select name from sys.indexes where name = 'idx_sunAnalysisDirectory_AnalysisEntityID')
    drop index idx_sunAnalysisDirectory_AnalysisEntityID on sunAnalysisDirectory.AnalysisEntityID

    create index idx_sunAnalysisDirectory_AnalysisDirectoryID on [db-au-cmdwh].dbo.sunAnalysisDirectory(AnalysisDirectoryID)
    create index idx_sunAnalysisDirectory_AnalysisEntityID on [db-au-cmdwh].dbo.sunAnalysisDirectory(AnalysisEntityID)
end
else
    truncate table [db-au-cmdwh].dbo.sunAnalysisDirectory



insert into [db-au-cmdwh].dbo.sunAnalysisDirectory with (tablock)
(
        AnalysisDirectoryID,
        UpdateCount,
        LastChangeUserID,
        LastChangeDateTime,
        [Description],
        AnalysisEntityFlag,
        PriceBookFlag,
        ApprovalFlag,
        CostingFlag,
        BudgetCheckFlag,
        AnalysisEntityID,
        LandedCostFlag,
        TransRefFlag,
        FileCode,
        UseableCurrencyCode,
        SystemsUnionReserved
)
select
        a.ANL_DIR_ID,
        a.UPDATE_COUNT,
        a.LAST_CHANGE_USER_ID,
        a.LAST_CHANGE_DATETIME,
        a.DESCR,
        a.ANL_FLAG,
        a.PB_FLAG,
        a.APRVL_FLAG,
        a.COSTING_FLAG,
        a.BDGT_CHECK_FLAG,
        a.ANL_ENT_ID,
        a.LANDED_COSTS_FLAG,
        a.TXN_REF_FLAG,
        a.FILE_CODE,
        a.USEABLE_AS_CURR_CODE,
        a.SU_RESERVED
from
   [db-au-stage].dbo.sun_ANL_DIR_au a

GO
