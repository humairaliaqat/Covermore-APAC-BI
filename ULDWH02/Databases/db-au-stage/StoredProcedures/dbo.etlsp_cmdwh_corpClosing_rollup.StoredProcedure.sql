USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_corpClosing_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_corpClosing_rollup]
as

SET NOCOUNT ON


/*************************************************************/
--combine benefits from AU, NZ, AU into one table
/*************************************************************/
if object_id('[db-au-stage].dbo.etl_corpClosing') is not null drop table [db-au-stage].dbo.etl_corpClosing

select
  'AU' as CountryKey,
  left('AU-' + cast(c.ClosingID as varchar),10) as ClosingKey,
  left('AU-' + cast(c.QtID as varchar),10) as QuoteKey,
  left('AU-' + cast(c.BankRec as varchar),10) as BankRecordKey,
  left('AU-' + cast(c.TravellerID as varchar),41) as TravellerKey,
  c.ClosingID as ClosingID,
  c.QtID as QuoteID,
  c.CreatedDt as CreatedDate,
  c.IssuedDt as IssuedDate,
  c.ClosingTypID as ClosingTypeID,
  (select top 1 ClosingTypDesc from [db-au-stage].dbo.corp_tblClosingTypes_au where ClosingTypID = c.ClosingTypID) as ClosingTypeDesc,
  c.BenefitID,
  (select top 1 BenCode from [db-au-stage].dbo.corp_tblBenefits_au where BenefitID = c.BenefitID) as BenefitCode,
  (select top 1 BenDesc from [db-au-stage].dbo.corp_tblBenefits_au where BenefitID = c.BenefitID) as BenefitDesc,
  c.UWAcceptDt as UWAcceptDate,
  c.ClosingLoad,
  c.CloseAccept,
  c.AgtComm as AgentCommission,
  c.CMComm as CMCommission,
  c.BankRec as BankRecord,
  c.Comments,
  c.IntlTravelOnly as IntTravelOnly,
  c.TravellerID
into [db-au-stage].dbo.etl_corpClosing
from
  [db-au-stage].dbo.corp_tblClosings_au c

union all

select
  'NZ' as CountryKey,
  left('NZ-' + cast(c.ClosingID as varchar),10) as ClosingKey,
  left('NZ-' + cast(c.QtID as varchar),10) as QuoteKey,
  left('NZ-' + cast(c.BankRec as varchar),10) as BankRecordKey,
  null as TravellerKey,
  c.ClosingID as ClosingID,
  c.QtID as QuoteID,
  c.CreatedDt as CreatedDate,
  c.IssuedDt as IssuedDate,
  c.ClosingTypID as ClosingTypeID,
  (select top 1 ClosingTypDesc from [db-au-stage].dbo.corp_tblClosingTypes_nz where ClosingTypID = c.ClosingTypID) as ClosingTypeDesc,
  c.BenefitID,
  (select top 1 BenCode from [db-au-stage].dbo.corp_tblBenefits_nz where BenefitID = c.BenefitID) as BenefitCode,
  (select top 1 BenDesc from [db-au-stage].dbo.corp_tblBenefits_nz where BenefitID = c.BenefitID) as BenefitDesc,
  c.UWAcceptDt as UWAcceptDate,
  c.ClosingLoad,
  c.CloseAccept,
  c.AgtComm as AgentCommission,
  c.CMComm as CMCommission,
  c.BankRec as BankRecord,
  c.Comments,
  c.IntlTravelOnly as IntTravelOnly,
  null as TravellerID
from
  [db-au-stage].dbo.corp_tblClosings_nz c


if object_id('[db-au-cmdwh].dbo.corpClosing') is null
begin
    create table [db-au-cmdwh].dbo.corpClosing
    (
        [CountryKey] [varchar](2) NOT NULL,
        [ClosingKey] [varchar](10) NULL,
        [QuoteKey] [varchar](10) NULL,
        [BankRecordKey] [varchar](10) NULL,
        [TravellerKey] [varchar](41) NULL,
        [ClosingID] [int] NOT NULL,
        [QuoteID] [int] NULL,
        [CreatedDate] [datetime] NULL,
        [IssuedDate] [datetime] NULL,
        [ClosingTypeID] [int] NULL,
        [ClosingTypeDesc] [varchar](50) NULL,
        [BenefitID] [int] NULL,
        [BenefitCode] [varchar](3) NULL,
        [BenefitDesc] [varchar](50) NULL,
        [UWAcceptDate] [datetime] NULL,
        [ClosingLoad] [money] NULL,
        [CloseAccept] [bit] NULL,
        [AgentCommission] [money] NULL,
        [CMCommission] [money] NULL,
        [BankRecord] [int] NULL,
        [Comments] [varchar](255) NULL,
        [IntTravelOnly] [bit] NULL,
        [TravellerID] [int] NULL
    )
    if exists(select name from sys.indexes where name = 'idx_corpClosing_CountryKey')
    drop index idx_corpClosing_CountryKey on corpClosing.CountryKey

    if exists(select name from sys.indexes where name = 'idx_corpClosing_ClosingKey')
    drop index idx_corpClosing_ClosingKey on corpClosing.ClosingKey

    if exists(select name from sys.indexes where name = 'idx_corpClosing_QuoteKey')
    drop index idx_corpClosing_QuoteKey on corpClosing.QuoteKey

    if exists(select name from sys.indexes where name = 'idx_corpClosing_BankRecordKey')
    drop index idx_corpClosing_BankRecordKey on corpClosing.BankRecordKey

	if exists(select name from sys.indexes where name = 'idx_corpClosing_TravellerKey')
    drop index idx_corpClosing_TravellerKey on corpClosing.TravellerKey
    
    create index idx_corpClosing_CountryKey on [db-au-cmdwh].dbo.corpClosing(CountryKey)
    create index idx_corpClosing_ClosingKey on [db-au-cmdwh].dbo.corpClosing(ClosingKey)
    create index idx_corpClosing_QuoteKey on [db-au-cmdwh].dbo.corpClosing(QuoteKey)
    create index idx_corpClosing_BankRecordKey on [db-au-cmdwh].dbo.corpClosing(BankRecordKey)
    create index idx_corpClosing_TravellerKey on [db-au-cmdwh].dbo.corpClosing(TravellerKey)
end
else
    truncate table [db-au-cmdwh].dbo.corpClosing



/*************************************************************/
-- Transfer data from [db-au-stage].dbo.etl_corpClosing to [db-au-cmdwh].dbo.corpClosing
/*************************************************************/

insert into [db-au-cmdwh].dbo.corpClosing with (tablock)
(
        CountryKey,
        ClosingKey,
        QuoteKey,
        BankRecordKey,
        TravellerKey,
        ClosingID,
        QuoteID,
        CreatedDate,
        IssuedDate,
        ClosingTypeID,
        ClosingTypeDesc,
        BenefitID,
        BenefitCode,
        BenefitDesc,
        UWAcceptDate,
        ClosingLoad,
        CloseAccept,
        AgentCommission,
        CMCommission,
        BankRecord,
        Comments,
        IntTravelOnly,
        TravellerID
)
select
        CountryKey,
        ClosingKey,
        QuoteKey,
        BankRecordKey,
        TravellerKey,
        ClosingID,
        QuoteID,
        CreatedDate,
        IssuedDate,
        ClosingTypeID,
        ClosingTypeDesc,
        BenefitID,
        BenefitCode,
        BenefitDesc,
        UWAcceptDate,
        ClosingLoad,
        CloseAccept,
        AgentCommission,
        CMCommission,
        BankRecord,
        Comments,
        IntTravelOnly,
        TravellerID
from [db-au-stage].dbo.etl_corpClosing
GO
