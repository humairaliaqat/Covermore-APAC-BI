USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_bankpayment_refresh]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_bankpayment_refresh]
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

delete [db-au-cmdwh].dbo.BankPayment
from [db-au-cmdwh].dbo.BankPayment bp
    join [db-au-stage].dbo.etl_bankpayment t on
        bp.CountryKey = t.CountryKey and
        bp.PaymentID = t.PaymentID


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
