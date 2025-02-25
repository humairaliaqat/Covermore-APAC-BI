USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_corpEMC_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_corpEMC_rollup]
as

SET NOCOUNT ON


/*************************************************************/
--combine EMC from AU, NZ into one table
/*************************************************************/
if object_id('[db-au-stage].dbo.etl_corpEMC') is not null drop table [db-au-stage].dbo.etl_corpEMC

select
  'AU' as CountryKey,
  left('AU-' + cast(e.EMCID as varchar),10) as EMCKey,
  left('AU-' + cast(e.QtID as varchar),10) as QuoteKey,
  left('AU-' + cast(e.BankRec as varchar),10) as BankRecordKey,
  left('AU-' + cast(e.TravellerID as varchar),41) as TravellerKey,
  e.EmcID as EMCID,
  e.QtID as QuoteID,
  e.CreatedDt as CreatedDate,
  e.IssuedDt as IssuedDate,
  e.EmcAppNo as EMCApplicatioNo,
  e.EMCInsName as EMCInsuredName,
  e.EMCLoad as EMCLoading,
  e.EMCAccept as isEMCAccepted,
  e.AgtComm as AgentCommission,
  e.CMComm as CMCommission,
  e.BankRec as BankRecord,
  e.Comments,
  e.TravellerID
into [db-au-stage].dbo.etl_corpEMC
from
  [db-au-stage].dbo.corp_tblEMC_au e


union all

select
  'NZ' as CountryKey,
  left('NZ-' + cast(e.EMCID as varchar),10) as EMCKey,
  left('NZ-' + cast(e.QtID as varchar),10) as QuoteKey,
  left('NZ-' + cast(e.BankRec as varchar),10) as BankRecordKey,
  null as TravellerKey,
  e.EmcID as EMCID,
  e.QtID as QuoteID,
  e.CreatedDt as CreatedDate,
  e.IssuedDt as IssuedDate,
  e.EmcAppNo as EMCApplicatioNo,
  e.EMCInsName as EMCInsuredName,
  e.EMCLoad as EMCLoading,
  e.EMCAccept as isEMCAccepted,
  e.AgtComm as AgentCommission,
  e.CMComm as CMCommission,
  e.BankRec as BankRecord,
  e.Comments,
  null as TravellerID
from
  [db-au-stage].dbo.corp_tblEMC_nz e


if object_id('[db-au-cmdwh].dbo.corpEMC') is null
begin
    create table [db-au-cmdwh].dbo.corpEMC
    (
        [CountryKey] [varchar](2) NOT NULL,
        [EMCKey] [varchar](10) NULL,
        [QuoteKey] [varchar](10) NULL,
        [BankRecordKey] [varchar](10) NULL,
        [EMCID] [int] NOT NULL,
        [QuoteID] [int] NULL,
        [CreatedDate] [datetime] NULL,
        [IssuedDate] [datetime] NULL,
        [EMCApplicatioNo] [varchar](50) NULL,
        [EMCInsuredName] [varchar](50) NULL,
        [EMCLoading] [money] NULL,
        [isEMCAccepted] [bit] NULL,
        [AgentCommission] [money] NULL,
        [CMCommission] [money] NULL,
        [BankRecord] [int] NULL,
        [Comments] [varchar](255) NULL,
        [TravellerKey] [varchar](41) NULL,
        [TravellerID] [int] NULL
    )

    if exists(select name from sys.indexes where name = 'idx_corpEMC_CountryKey')
    drop index idx_corpEMC_CountryKey on corpEMC.CountryKey

    if exists(select name from sys.indexes where name = 'idx_corpEMC_EMCKey')
    drop index idx_corpEMC_EMCKey on corpEMC.EMCKey

    if exists(select name from sys.indexes where name = 'idx_corpEMC_QuoteKey')
    drop index idx_corpEMC_QuoteKey on corpEMC.QuoteKey

    if exists(select name from sys.indexes where name = 'idx_corpEMC_BankRecordKey')
    drop index idx_corpEMC_BankRecordKey on corpEMC.BankRecordKey

    if exists(select name from sys.indexes where name = 'idx_corpEMC_TravellerKey')
    drop index idx_corpEMC_TravellerKey on corpEMC.TravellerKey
    
    create index idx_corpEMC_CountryKey on [db-au-cmdwh].dbo.corpEMC(CountryKey)
    create index idx_corpEMC_EMCKey on [db-au-cmdwh].dbo.corpEMC(EMCKey)
    create index idx_corpEMC_QuoteKey on [db-au-cmdwh].dbo.corpEMC(QuoteKey)
    create index idx_corpEMC_BankRecordKey on [db-au-cmdwh].dbo.corpEMC(BankRecordKey)
    create index idx_corpEMC_TravellerKey on [db-au-cmdwh].dbo.corpEMC(TravellerKey)
end
else
    truncate table [db-au-cmdwh].dbo.corpEMC



/*************************************************************/
-- Transfer data from [db-au-stage].dbo.etl_corpBankPayment to [db-au-cmdwh].dbo.corpBankPayment
/*************************************************************/

insert into [db-au-cmdwh].dbo.corpEMC with (tablock)
(
    CountryKey,
    EMCKey,
    QuoteKey,
    BankRecordKey,
    EMCID,
    QuoteID,
    CreatedDate,
    IssuedDate,
    EMCApplicatioNo,
    EMCInsuredName,
    EMCLoading,
    isEMCAccepted,
    AgentCommission,
    CMCommission,
    BankRecord,
    Comments,
    TravellerKey,
    TravellerID
)
select
    CountryKey,
    EMCKey,
    QuoteKey,
    BankRecordKey,
    EMCID,
    QuoteID,
    CreatedDate,
    IssuedDate,
    EMCApplicatioNo,
    EMCInsuredName,
    EMCLoading,
    isEMCAccepted,
    AgentCommission,
    CMCommission,
    BankRecord,
    Comments,
    TravellerKey,
    TravellerID
from [db-au-stage].dbo.etl_corpEMC
GO
