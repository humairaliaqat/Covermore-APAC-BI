USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_corpBank_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_corpBank_rollup]
as

SET NOCOUNT ON


/*************************************************************/
--combine bank from AU, NZ, AU into one table
/*************************************************************/
if object_id('[db-au-stage].dbo.etl_corpBank') is not null drop table [db-au-stage].dbo.etl_corpBank

select
  'AU' as CountryKey,
  left('AU-' + cast(b.RecordNo as varchar),10) as BankRecordKey,
  left('AU-' + cast((select top 1 QtID from [db-au-stage].dbo.corp_tblClosings_au where BankRec is not null and BankRec = b.RecordNo) as varchar),10) as ClosingQuoteID,
  left('AU-' + cast((select top 1 QtID from [db-au-stage].dbo.corp_tblDaysPaid_au where BankRec is not null and BankRec = b.RecordNo) as varchar),10) as DaysPaidQuoteID,
  left('AU-' + cast((select top 1 QtID from [db-au-stage].dbo.corp_tblEMC_au where BankRec is not null and BankRec = b.RecordNo) as varchar),10) as EMCQuoteID,
  left('AU-' + cast((select top 1 QtID from [db-au-stage].dbo.corp_tblLuggage_au where BankRec is not null and BankRec = b.RecordNo) as varchar),10) as LuggageQuoteID,
  b.RecordNo as BankRecord,
  b.BankDate,
  b.ACT as AccountingDate,
  b.Account,
  b.Product as ProductCode,
  b.Alpha as AgencyCode,
  b.CompID as CompanyID,
  b.Gross,
  b.Commission,
  b.Adjustment,
  b.Refund,
  b.RefundChq as RefundCheque,
  b.Op as Operator,
  b.Comments,
  b.MMBonus
into [db-au-stage].dbo.etl_corpBank
from
  [db-au-stage].dbo.corp_corpBank_au b

union all

select
  'NZ' as CountryKey,
  left('NZ-' + cast(b.RecordNo as varchar),10) as BankRecordKey,
  left('NZ-' + cast((select top 1 QtID from [db-au-stage].dbo.corp_tblClosings_nz where BankRec is not null and BankRec = b.RecordNo) as varchar),10) as ClosingQuoteID,
  left('NZ-' + cast((select top 1 QtID from [db-au-stage].dbo.corp_tblDaysPaid_nz where BankRec is not null and BankRec = b.RecordNo) as varchar),10) as DaysPaidQuoteID,
  left('NZ-' + cast((select top 1 QtID from [db-au-stage].dbo.corp_tblEMC_nz where BankRec is not null and BankRec = b.RecordNo) as varchar),10) as EMCQuoteID,
  left('NZ-' + cast((select top 1 QtID from [db-au-stage].dbo.corp_tblLuggage_nz where BankRec is not null and BankRec = b.RecordNo) as varchar),10) as LuggageQuoteID,
  b.RecordNo as BankRecord,
  b.BankDate,
  b.ACT as AccountingDate,
  b.Account,
  b.Product as ProductCode,
  b.Alpha as AgencyCode,
  b.CompID as CompanyID,
  b.Gross,
  b.Commission,
  b.Adjustment,
  b.Refund,
  b.RefundChq as RefundCheque,
  b.Op as Operator,
  b.Comments,
  b.MMBonus
from
  [db-au-stage].dbo.corp_corpBank_nz b

union all

select
  'UK' as CountryKey,
  left('UK-' + cast(b.RecordNo as varchar),10) as BankRecordKey,
  null as ClosingQuoteID,
  left('UK-' + cast((select top 1 QtID from [db-au-stage].dbo.corp_tblDaysPaid_uk where BankRec is not null and BankRec = b.RecordNo) as varchar),10) as DaysPaidQuoteID,
  null as EMCQuoteID,
  null as LuggageQuoteID,
  b.RecordNo as BankRecord,
  b.BankDate,
  b.ACT as AccountingDate,
  b.Account,
  b.Product as ProductCode,
  b.Alpha as AgencyCode,
  b.CompID as CompanyID,
  b.Gross,
  b.Commission,
  b.Adjustment,
  b.Refund,
  b.RefundChq as RefundCheque,
  b.Op as Operator,
  b.Comments,
  b.MMBonus
from
  [db-au-stage].dbo.corp_corpBank_uk b

if object_id('[db-au-cmdwh].dbo.corpBank') is null
begin
    create table [db-au-cmdwh].dbo.corpBank
    (
        [CountryKey] [varchar](2) NOT NULL,
        [BankRecordKey] [varchar](10) NULL,
        [QuoteKey] [varchar](10) NULL,
        [BankRecord] [int] NOT NULL,
        [BankDate] [datetime] NULL,
        [AccountingDate] [datetime] NULL,
        [Account] [varchar](6) NULL,
        [ProductCode] [varchar](3) NULL,
        [AgencyCode] [varchar](7) NULL,
        [CompanyID] [int] NULL,
        [Gross] [money] NULL,
        [Commission] [money] NULL,
        [Adjustment] [money] NULL,
        [Refund] [money] NULL,
        [RefundCheque] [int] NULL,
        [Operator] [varchar](10) NULL,
        [Comments] [varchar](100) NULL,
        [MMBonus] [money] NULL
    )
    if exists(select name from sys.indexes where name = 'idx_corpBank_CountryKey')
    drop index idx_corpBank_CountryKey on corpBank.CountryKey

    if exists(select name from sys.indexes where name = 'idx_corpBank_BankRecordKey')
    drop index idx_corpBank_BankRecordKey on corpBank.BankRecordKey

    if exists(select name from sys.indexes where name = 'idx_corpBank_QuoteKey')
    drop index idx_corpBank_QuoteKey on corpBank.QuoteKey

    create index idx_corpBank_CountryKey on [db-au-cmdwh].dbo.corpBank(CountryKey)
    create index idx_corpBank_BankRecordKey on [db-au-cmdwh].dbo.corpBank(BankRecordKey)
    create index idx_corpBank_QuoteKey on [db-au-cmdwh].dbo.corpBank(QuoteKey)
end
else
    truncate table [db-au-cmdwh].dbo.corpBank



/*************************************************************/
-- Transfer data from [db-au-stage].dbo.etl_corpBank to [db-au-cmdwh].dbo.corpBank
/*************************************************************/

insert into [db-au-cmdwh].dbo.corpBank with (tablock)
(
    CountryKey,
    BankRecordKey,
    QuoteKey,
    BankRecord,
    BankDate,
    AccountingDate,
    Account,
    ProductCode,
    AgencyCode,
    CompanyID,
    Gross,
    Commission,
    Adjustment,
    Refund,
    RefundCheque,
    Operator,
    Comments,
    MMBonus
)
select
    CountryKey,
    BankRecordKey,
    case when DaysPaidQuoteID is not null then DaysPaidQuoteID
         when ClosingQuoteID is not null then ClosingQuoteID
         when LuggageQuoteID is not null then LuggageQuoteID
         when EMCQuoteID is not null then EMCQuoteID
         else null
    end as QuoteKey,
    BankRecord,
    BankDate,
    AccountingDate,
    Account,
    ProductCode,
    AgencyCode,
    CompanyID,
    Gross,
    Commission,
    Adjustment,
    Refund,
    RefundCheque,
    Operator,
    Comments,
    MMBonus
from [db-au-stage].dbo.etl_corpBank



GO
