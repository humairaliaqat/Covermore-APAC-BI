USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_corpBankPayment_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_corpBankPayment_rollup]
as

SET NOCOUNT ON


/*************************************************************/
--combine bank payment from AU, NZ, AU into one table
/*************************************************************/
if object_id('[db-au-stage].dbo.etl_corpBankPayment') is not null drop table [db-au-stage].dbo.etl_corpBankPayment

select
  'AU' as CountryKey,
  left('AU-' + cast(b.Payment_ID as varchar),10) as PaymentKey,
  left('AU-' + cast(b.BankRec as varchar),10) as BankRecordKey,
  left('AU-' + cast(b.PendRec as varchar),10) as PendingRecordKey,
  b.Payment_ID as PaymentID,
  b.BankRec as BankRecord,
  b.PendRec as PendingRecord,
  b.PayType,
  b.Payer,
  b.BSB,
  b.ChequeNo,
  b.CCardType as CreditCardType,
  b.CCardNo as CreditCardNo,
  b.CCardExpiry as CreditCardExpiryDate,
  b.Amount,
  b.Comment,
  b.PartPay as isPartPayment,
  b.IncComm as IncludeCommission
into [db-au-stage].dbo.etl_corpBankPayment
from
  [db-au-stage].dbo.corp_corpBankPayments_au b

union all

select
  'NZ' as CountryKey,
  left('NZ-' + cast(b.Payment_ID as varchar),10) as PaymentKey,
  left('NZ-' + cast(b.BankRec as varchar),10) as BankRecordKey,
  left('NZ-' + cast(b.PendRec as varchar),10) as PendingRecordKey,
  b.Payment_ID as PaymentID,
  b.BankRec as BankRecord,
  b.PendRec as PendingRecord,
  b.PayType,
  b.Payer,
  b.BSB,
  b.ChequeNo,
  b.CCardType as CreditCardType,
  b.CCardNo as CreditCardNo,
  b.CCardExpiry as CreditCardExpiryDate,
  b.Amount,
  b.Comment,
  b.PartPay as isPartPayment,
  b.IncComm as IncludeCommission
from
  [db-au-stage].dbo.corp_corpBankPayments_nz b

union all

select
  'UK' as CountryKey,
  left('UK-' + cast(b.Payment_ID as varchar),10) as PaymentKey,
  left('UK-' + cast(b.BankRec as varchar),10) as BankRecordKey,
  left('UK-' + cast(b.PendRec as varchar),10) as PendingRecordKey,
  b.Payment_ID as PaymentID,
  b.BankRec as BankRecord,
  b.PendRec as PendingRecord,
  b.PayType,
  b.Payer,
  b.BSB,
  b.ChequeNo,
  b.CCardType as CreditCardType,
  b.CCardNo as CreditCardNo,
  b.CCardExpiry as CreditCardExpiryDate,
  b.Amount,
  b.Comment,
  b.PartPay as isPartPayment,
  b.IncComm as IncludeCommission
from
  [db-au-stage].dbo.corp_corpBankPayments_uk b


if object_id('[db-au-cmdwh].dbo.corpBankPayment') is null
begin
    create table [db-au-cmdwh].dbo.corpBankPayment
    (
        [CountryKey] [varchar](2) NOT NULL,
        [PaymentKey] [varchar](10) NULL,
        [BankRecordKey] [varchar](10) NULL,
        [PendingRecordKey] [varchar](10) NULL,
        [PaymentID] [int] NOT NULL,
        [BankRecord] [int] NULL,
        [PendingRecord] [int] NULL,
        [PayType] [varchar](5) NULL,
        [Payer] [varchar](50) NULL,
        [BSB] [int] NULL,
        [ChequeNo] [float] NULL,
        [CreditCardType] [varchar](15) NULL,
        [CreditCardNo] [varchar](50) NULL,
        [CreditCardExpiryDate] [datetime] NULL,
        [Amount] [money] NULL,
        [Comment] [varchar](100) NULL,
        [isPartPayment] [bit] NULL,
        [IncludeCommission] [bit] NULL
    )

    if exists(select name from sys.indexes where name = 'idx_corpBankPayment_CountryKey')
    drop index idx_corpBankPayment_CountryKey on corpBankPayment.CountryKey

    if exists(select name from sys.indexes where name = 'idx_corpBankPayment_PaymentKey')
    drop index idx_corpBankPayment_PaymentKey on corpBankPayment.PaymentKey

    if exists(select name from sys.indexes where name = 'idx_corpBankPayment_BankRecordKey')
    drop index idx_corpBankPayment_BankRecordKey on corpBankPayment.BankRecordKey

    if exists(select name from sys.indexes where name = 'idx_corpBankPayment_PendingRecordKey')
    drop index idx_corpBankPayment_PendingRecordKey on corpBankPayment.PendingRecordKey

end
else
    truncate table [db-au-cmdwh].dbo.corpBankPayment



/*************************************************************/
-- Transfer data from [db-au-stage].dbo.etl_corpBankPayment to [db-au-cmdwh].dbo.corpBankPayment
/*************************************************************/

insert into [db-au-cmdwh].dbo.corpBankPayment with (tablock)
(
    CountryKey,
    PaymentKey,
    BankRecordKey,
    PendingRecordKey,
    PaymentID,
    BankRecord,
    PendingRecord,
    PayType,
    Payer,
    BSB,
    ChequeNo,
    CreditCardType,
    CreditCardNo,
    CreditCardExpiryDate,
    Amount,
    Comment,
    isPartPayment,
    IncludeCommission
)
select
    CountryKey,
    PaymentKey,
    BankRecordKey,
    PendingRecordKey,
    PaymentID,
    BankRecord,
    PendingRecord,
    PayType,
    Payer,
    BSB,
    ChequeNo,
    CreditCardType,
    CreditCardNo,
    CreditCardExpiryDate,
    Amount,
    Comment,
    isPartPayment,
    IncludeCommission
from [db-au-stage].dbo.etl_corpBankPayment



GO
