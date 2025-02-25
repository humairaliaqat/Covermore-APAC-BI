USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_bankpayment_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_bankpayment_rollup]
as

SET NOCOUNT ON


if object_id('[db-au-stage].dbo.etl_bankpayment') is not null drop table [db-au-stage].dbo.etl_bankpayment

select
  'AU' as CountryKey,
  'AU-' + cast(b.Payment_ID as varchar(10)) as PaymentKey,
  'AU-' + cast(b.BankRec as varchar(10)) as BankRecordKey,
  'AU-' + cast(b.RtnID as varchar(10)) as ReturnKey,
  b.Payment_ID as PaymentID,
  b.BankRec,
  b.PendRec,
  b.PayType,
  b.Payer,
  b.BSB,
  b.ChequeNo,
  b.CCardType,
  b.CCardNo,
  b.CCardExpiry,
  b.Amount,
  b.Comment,
  b.PartPay,
  b.RtnID,
  b.Allocated
into [db-au-stage].dbo.etl_bankpayment
from
  [db-au-stage].dbo.trips_bankpayments_au b

union all

select
  'NZ' as CountryKey,
  'NZ-' + cast(b.Payment_ID as varchar(10)) as PaymentKey,
  'NZ-' + cast(b.BankRec as varchar(10)) as BankRecordKey,
  'NZ-' + cast(b.RtnID as varchar(10)) as ReturnKey,
  b.Payment_ID as PaymentID,
  b.BankRec,
  b.PendRec,
  b.PayType,
  b.Payer,
  b.BSB,
  b.ChequeNo,
  b.CCardType,
  b.CCardNo,
  b.CCardExpiry,
  b.Amount,
  b.Comment,
  b.PartPay,
  b.RtnID,
  b.Allocated
from
  [db-au-stage].dbo.trips_bankpayments_nz b

union all

select
  'UK' as CountryKey,
  'UK-' + cast(b.Payment_ID as varchar(10)) as PaymentKey,
  'UK-' + cast(b.BankRec as varchar(10)) as BankRecordKey,
  'UK-' + cast(b.RtnID as varchar(10)) as ReturnKey,
  b.Payment_ID as PaymentID,
  b.BankRec,
  b.PendRec,
  b.PayType,
  b.Payer,
  b.BSB,
  b.ChequeNo,
  b.CCardType,
  b.CCardNo,
  b.CCardExpiry,
  b.Amount,
  b.Comment,
  b.PartPay,
  b.RtnID,
  b.Allocated
from
  [db-au-stage].dbo.trips_bankpayments_uk b

union all

select
  'MY' as CountryKey,
  'MY-' + cast(b.Payment_ID as varchar(10)) as PaymentKey,
  'MY-' + cast(b.BankRec as varchar(10)) as BankRecordKey,
  'MY-' + cast(b.RtnID as varchar(10)) as ReturnKey,
  b.Payment_ID as PaymentID,
  b.BankRec,
  b.PendRec,
  b.PayType,
  b.Payer,
  b.BSB,
  b.ChequeNo,
  b.CCardType,
  b.CCardNo,
  b.CCardExpiry,
  b.Amount,
  b.Comment,
  b.PartPay,
  b.RtnID,
  b.Allocated
from
  [db-au-stage].dbo.trips_bankpayments_my b

union all

select
  'SG' as CountryKey,
  'SG-' + cast(b.Payment_ID as varchar(10)) as PaymentKey,
  'SG-' + cast(b.BankRec as varchar(10)) as BankRecordKey,
  'SG-' + cast(b.RtnID as varchar(10)) as ReturnKey,
  b.Payment_ID as PaymentID,
  b.BankRec,
  b.PendRec,
  b.PayType,
  b.Payer,
  b.BSB,
  b.ChequeNo,
  b.CCardType,
  b.CCardNo,
  b.CCardExpiry,
  b.Amount,
  b.Comment,
  b.PartPay,
  b.RtnID,
  b.Allocated
from
  [db-au-stage].dbo.trips_bankpayments_sg b

if object_id('[db-au-cmdwh].dbo.BankPayment') is null
begin
  create table [db-au-cmdwh].dbo.BankPayment
  (
    CountryKey varchar(2) NOT NULL,
    PaymentKey varchar(13) NOT NULL,
    BankRecordKey varchar(13)  NULL,
    ReturnKey varchar(13) NULL,
    PaymentID int NOT NULL,
    BankRec int NULL,
    PendRec int NULL,
    PayType varchar(3) NULL,
    Payer varchar(50) NULL,
    BSB int NULL,
    ChequeNo float NULL,
    CCardType varchar(10) NULL,
    CCardNo varchar(25) NULL,
    CCardExpiry datetime NULL,
    Amount money NULL,
    Comment varchar(100) NULL,
    PartPay bit NOT NULL,
    RtnID int NULL,
    Allocated bit NULL
  )

  if exists(select name from sys.indexes where name = 'idx_BankPayment_CountryKey')
    drop index idx_BankPayment_CountryKey on BankPayment.CountryKey

  if exists(select name from sys.indexes where name = 'idx_BankPayment_PaymentKey')
    drop index idx_BankPayment_PaymentKey on BankPayment.PaymentKey

  if exists(select name from sys.indexes where name = 'idx_BankPayment_BankRecordKey')
    drop index idx_BankPayment_BankRecordKey on BankPayment.BankRecordKey

  if exists(select name from sys.indexes where name = 'idx_BankPayment_ReturnKey')
    drop index idx_BankPayment_ReturnKey on BankPayment.ReturnKey

  if exists(select name from sys.indexes where name = 'idx_BankPayment_PaymentID')
    drop index idx_BankPayment_PaymentID on BankPayment.PaymentID

  if exists(select name from sys.indexes where name = 'idx_BankPayment_BankRec')
    drop index idx_BankPayment_BankRec on BankPayment.BankRec

  create index idx_BankPayment_CountryKey on [db-au-cmdwh].dbo.BankPayment(CountryKey)
  create index idx_BankPayment_PaymentKey on [db-au-cmdwh].dbo.BankPayment(PaymentKey)
  create index idx_BankPayment_BankRecordKey on [db-au-cmdwh].dbo.BankPayment(BankRecordKey)
  create index idx_BankPayment_ReturnKey on [db-au-cmdwh].dbo.BankPayment(ReturnKey)
  create index idx_BankPayment_PaymentID on [db-au-cmdwh].dbo.BankPayment(PaymentID)
  create index idx_BankPayment_BankRec on [db-au-cmdwh].dbo.BankPayment(BankRec)
end
else
  truncate table [db-au-cmdwh].dbo.BankPayment



-- Transfer data from [db-au-stage].dbo.etl_bankpayment to [db-au-cmdwh].dbo.BankPayment
insert into [db-au-cmdwh].dbo.BankPayment with (tablock)
(
    CountryKey,
    PaymentKey,
    BankRecordKey,
    ReturnKey,
    PaymentID,
    BankRec,
    PendRec,
    PayType,
    Payer,
    BSB,
    ChequeNo,
    CCardType,
    CCardNo,
    CCardExpiry,
    Amount,
    Comment,
    PartPay,
    RtnID,
    Allocated
)
select * from [db-au-stage].dbo.etl_bankpayment

GO
