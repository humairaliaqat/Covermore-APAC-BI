USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_corpLuggage_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_corpLuggage_rollup]
as

SET NOCOUNT ON


/*************************************************************/
--combine EMC from AU, NZ into one table
/*************************************************************/
if object_id('[db-au-stage].dbo.etl_corpLuggage') is not null drop table [db-au-stage].dbo.etl_corpLuggage

select
  'AU' as CountryKey,
  left('AU-' + cast(l.LuggID as varchar),10) as LuggageKey,
  left('AU-' + cast(l.QtID as varchar),10) as QuoteKey,
  left('AU-' + cast(l.BankRec as varchar),10) as BankRecordKey,
  l.LuggID as LuggageID,
  l.QtID as QuoteID,
  l.LuggTypID as LuggageTypeID,
  (select top 1 LuggTypDesc from [db-au-stage].dbo.corp_tblLuggateTypes_au where LuggTypID = l.LuggTypID) as LuggageTypeDesc,
  (select top 1 Coverage from [db-au-stage].dbo.corp_tblLuggateTypes_au where LuggTypID = l.LuggTypID) as LuggageTypeCoverage,
  l.CreatedDT as CreatedDate,
  l.IssuedDt as IssuedDate,
  l.LuggDesc as LuggageDesc,
  l.LuggVal as LuggageValue,
  l.LuggLoad as LuggageLoading,
  l.LuggAccept as isLuggageAccepted,
  l.AgtComm as AgentCommission,
  l.CMComm as CMCommission,
  l.BankRec as BankRecord,
  l.Comments
into [db-au-stage].dbo.etl_corpLuggage
from
  [db-au-stage].dbo.corp_tblLuggage_au l

union all

select
  'NZ' as CountryKey,
  left('NZ-' + cast(l.LuggID as varchar),10) as LuggageKey,
  left('NZ-' + cast(l.QtID as varchar),10) as QuoteKey,
  left('NZ-' + cast(l.BankRec as varchar),10) as BankRecordKey,
  l.LuggID as LuggageID,
  l.QtID as QuoteID,
  l.LuggTypID as LuggageTypeID,
  (select top 1 LuggTypDesc from [db-au-stage].dbo.corp_tblLuggateTypes_nz where LuggTypID = l.LuggTypID) as LuggageTypeDesc,
  (select top 1 Coverage from [db-au-stage].dbo.corp_tblLuggateTypes_nz where LuggTypID = l.LuggTypID) as LuggageTypeCoverage,
  l.CreatedDT as CreatedDate,
  l.IssuedDt as IssuedDate,
  l.LuggDesc as LuggageDesc,
  l.LuggVal as LuggageValue,
  l.LuggLoad as LuggageLoading,
  l.LuggAccept as isLuggageAccepted,
  l.AgtComm as AgentCommission,
  l.CMComm as CMCommission,
  l.BankRec as BankRecord,
  l.Comments
from
  [db-au-stage].dbo.corp_tblLuggage_nz l


if object_id('[db-au-cmdwh].dbo.corpLuggage') is null
begin
    create table [db-au-cmdwh].dbo.corpLuggage
    (
        [CountryKey] [varchar](2) NOT NULL,
        [LuggageKey] [varchar](10) NULL,
        [QuoteKey] [varchar](10) NULL,
        [BankRecordKey] [varchar](10) NULL,
        [LuggageID] [int] NOT NULL,
        [QuoteID] [int] NULL,
        [LuggageTypeID] [int] NULL,
        [LuggageTypeDesc] [varchar](50) NULL,
        [LuggageTypeCoverage] [money] NULL,
        [CreatedDate] [datetime] NULL,
        [IssuedDate] [datetime] NULL,
        [LuggageDesc] [varchar](50) NULL,
        [LuggageValue] [money] NULL,
        [LuggageLoading] [money] NULL,
        [isLuggageAccepted] [bit] NULL,
        [AgentCommission] [money] NULL,
        [CMCommission] [money] NULL,
        [BankRecord] [int] NULL,
        [Comments] [varchar](255) NULL
    )

    if exists(select name from sys.indexes where name = 'idx_corpLuggage_CountryKey')
    drop index idx_corpLuggage_CountryKey on corpLuggage.CountryKey

    if exists(select name from sys.indexes where name = 'idx_corpLuggage_LuggageKey')
    drop index idx_corpLuggage_LuggageKey on corpLuggage.LuggageKey

    if exists(select name from sys.indexes where name = 'idx_corpLuggage_QuoteKey')
    drop index idx_corpLuggage_QuoteKey on corpLuggage.QuoteKey

    if exists(select name from sys.indexes where name = 'idx_corpLuggage_BankRecordKey')
    drop index idx_corpLuggage_BankRecordKey on corpLuggage.BankRecordKey

    create index idx_corpLuggage_CountryKey on [db-au-cmdwh].dbo.corpLuggage(CountryKey)
    create index idx_corpLuggage_EMCKey on [db-au-cmdwh].dbo.corpLuggage(LuggageKey)
    create index idx_corpLuggage_QuoteKey on [db-au-cmdwh].dbo.corpLuggage(QuoteKey)
    create index idx_corpLuggage_BankRecordKey on [db-au-cmdwh].dbo.corpLuggage(BankRecordKey)
end
else
    truncate table [db-au-cmdwh].dbo.corpLuggage



/*************************************************************/
-- Transfer data from [db-au-stage].dbo.etl_corpLuggage to [db-au-cmdwh].dbo.corpLuggage
/*************************************************************/

insert into [db-au-cmdwh].dbo.corpLuggage with (tablock)
(
    CountryKey,
    LuggageKey,
    QuoteKey,
    BankRecordKey,
    LuggageID,
    QuoteID,
    LuggageTypeID,
    LuggageTypeDesc,
    LuggageTypeCoverage,
    CreatedDate,
    IssuedDate,
    LuggageDesc,
    LuggageValue,
    LuggageLoading,
    isLuggageAccepted,
    AgentCommission,
    CMCommission,
    BankRecord,
    Comments
)
select
    CountryKey,
    LuggageKey,
    QuoteKey,
    BankRecordKey,
    LuggageID,
    QuoteID,
    LuggageTypeID,
    LuggageTypeDesc,
    LuggageTypeCoverage,
    CreatedDate,
    IssuedDate,
    LuggageDesc,
    LuggageValue,
    LuggageLoading,
    isLuggageAccepted,
    AgentCommission,
    CMCommission,
    BankRecord,
    Comments
from [db-au-stage].dbo.etl_corpLuggage



GO
