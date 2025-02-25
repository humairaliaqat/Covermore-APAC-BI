USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_onlinepayment_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_onlinepayment_rollup]
as

SET NOCOUNT ON


if object_id('[db-au-stage].dbo.etl_onlinepayment') is not null drop table [db-au-stage].dbo.etl_onlinepayment

select
  'AU' as CountryKey,
  left('AU-' + cast(b.PayID as varchar),13) as PaymentKey,
  left('AU-' + cast(b.PPPOLYN as varchar),13) as PolicyKey,
  b.PayID,
  b.PPPOLYN as PolicyNo,
  b.MerchantTxtRef,
  b.OrderInfo,
  b.MerchantID,
  b.AmountPaid,
  b.ReceiptNo,
  b.QSIResponseCode,
  b.ResponseDescription,
  b.ACQResponseCode,
  b.TransactionNo,
  convert(varchar(50),b.AuthorizeID) as AuthoriseID,
  b.BatchNo,
  b.CardType,
  b.[DateAdd],
  b.Record_Date as RecordDate,
  b.ACT as AccountingDate,
  null as PaymentReferenceID
into [db-au-stage].dbo.etl_onlinepayment
from
  [db-au-stage].dbo.trips_onlinepayments_au b

union all

select
  'NZ' as CountryKey,
  left('NZ-' + cast(b.PayID as varchar),13) as PaymentKey,
  left('NZ-' + cast(b.PPPOLYN as varchar),13) as PolicyKey,
  b.PayID,
  b.PPPOLYN as PolicyNo,
  b.MerchantTxtRef,
  b.OrderInfo,
  b.MerchantID,
  b.AmountPaid,
  b.ReceiptNo,
  b.QSIResponseCode,
  b.ResponseDescription,
  b.ACQResponseCode,
  b.TransactionNo,
  convert(varchar(50),b.AuthorizeID) as AuthoriseID,
  b.BatchNo,
  b.CardType,
  b.[DateAdd],
  b.Record_Date as RecordDate,
  b.ACT as AccountingDate,
  null as PaymentReferenceID
from
  [db-au-stage].dbo.trips_onlinepayments_nz b

union all

select
  'UK' as CountryKey,
  left('UK-' + cast(b.PayID as varchar),13) as PaymentKey,
  left('UK-' + cast(b.OrderID as varchar),13) as PolicyKey,
  b.PayID,
  b.OrderID as PolicyNo,
  null as MerchantTxtRef,
  null as OrderInfo,
  null as MerchantID,
  b.Total as AmountPaid,
  null as ReceiptNo,
  null as QSIResponseCode,
  b.ResponseDescription,
  null as ACQResponseCode,
  null as TransactionNo,
  convert(varchar(50),b.ClientID) as AuthoriseID,
  convert(varchar(8),b.TTime,112) as BatchNo,
  null as CardType,
  null as [DateAdd],
  b.TTime as RecordDate,
  b.ACT as AccountingDate,
  b.PaymentRef_ID as PaymentReferenceID
from
  [db-au-stage].dbo.trips_onlinepayments_uk b

union all

select
  'MY' as CountryKey,
  left('MY-' + cast(b.PayID as varchar),13) as PaymentKey,
  left('MY-' + cast(b.PPPOLYN as varchar),13) as PolicyKey,
  b.PayID,
  b.PPPOLYN as PolicyNo,
  b.MerchantTxtRef,
  b.OrderInfo,
  b.MerchantID,
  b.AmountPaid,
  b.ReceiptNo,
  b.QSIResponseCode,
  b.ResponseDescription,
  b.ACQResponseCode,
  b.TransactionNo,
  convert(varchar(50),b.AuthorizeID) as AuthoriseID,
  b.BatchNo,
  b.CardType,
  b.[DateAdd],
  b.Record_Date as RecordDate,
  b.ACT as AccountingDate,
  null as PaymentReferenceID
from
  [db-au-stage].dbo.trips_onlinepayments_my b

union all

select
  'SG' as CountryKey,
  left('SG-' + cast(b.PayID as varchar),13) as PaymentKey,
  left('SG-' + cast(b.PPPOLYN as varchar),13) as PolicyKey,
  b.PayID,
  b.PPPOLYN as PolicyNo,
  b.MerchantTxtRef,
  b.OrderInfo,
  b.MerchantID,
  b.AmountPaid,
  b.ReceiptNo,
  b.QSIResponseCode,
  b.ResponseDescription,
  b.ACQResponseCode,
  b.TransactionNo,
  convert(varchar(50),b.AuthorizeID) as AuthoriseID,
  b.BatchNo,
  b.CardType,
  b.[DateAdd],
  b.Record_Date as RecordDate,
  b.ACT as AccountingDate,
  null as PaymentReferenceID
from
  [db-au-stage].dbo.trips_onlinepayments_sg b


if object_id('[db-au-cmdwh].dbo.OnlinePayment') is null
begin
    create table [db-au-cmdwh].dbo.OnlinePayment
    (
        CountryKey varchar(2) not null,
        PaymentKey varchar(13) not null,
        PolicyKey varchar(13) null,
        PayID int NOT NULL,
        PolicyNo int NULL,
        MerchantTxtRef varchar(50) NULL,
        OrderInfo varchar(50) NULL,
        MerchantID varchar(50) NULL,
        AmountPaid money NULL,
        ReceiptNo varchar(50) NULL,
        QSIResponseCode varchar(50) NULL,
        ResponseDescription varchar(255) NULL,
        ACQResponseCode varchar(50) NULL,
        TransactionNo varchar(50) NULL,
        AuthoriseID varchar(50) NULL,
        BatchNo varchar(50) NULL,
        CardType varchar(50) NULL,
        [DateAdd] datetime NULL,
        RecordDate datetime NULL,
        AccountingDate datetime NULL,
        PaymentReferenceID int NULL
    )

  if exists(select name from sys.indexes where name = 'idx_OnlinePayment_CountryKey')
    drop index idx_OnlinePayment_CountryKey on OnlinePayment.CountryKey

  if exists(select name from sys.indexes where name = 'idx_OnlinePayment_PaymentKey')
    drop index idx_OnlinePayment_PaymentKey on OnlinePayment.PaymentKey

  if exists(select name from sys.indexes where name = 'idx_OnlinePayment_PolicyKey')
    drop index idx_OnlinePayment_PolicyKey on OnlinePayment.PolicyKey

  if exists(select name from sys.indexes where name = 'idx_OnlinePayment_PayID')
    drop index idx_OnlinePayment_PayID on OnlinePayment.PayID

  if exists(select name from sys.indexes where name = 'idx_OnlinePayment_PolicyNo')
    drop index idx_OnlinePayment_PolicyNo on OnlinePayment.PolicyNo

  if exists(select name from sys.indexes where name = 'idx_OnlinePayment_RecordDate')
    drop index idx_OnlinePayment_RecordDate on OnlinePayment.RecordDate

  create index idx_OnlinePayment_CountryKey on [db-au-cmdwh].dbo.OnlinePayment(CountryKey)
  create index idx_OnlinePayment_PaymentKey on [db-au-cmdwh].dbo.OnlinePayment(PaymentKey)
  create index idx_OnlinePayment_PolicyKey on [db-au-cmdwh].dbo.OnlinePayment(PolicyKey)
  create index idx_OnlinePayment_PayID on [db-au-cmdwh].dbo.OnlinePayment(PayID)
  create index idx_OnlinePayment_PolicyNo on [db-au-cmdwh].dbo.OnlinePayment(PolicyNo)
  create index idx_OnlinePayment_RecordDate on [db-au-cmdwh].dbo.OnlinePayment(RecordDate)
end
else
begin
  truncate table [db-au-cmdwh].dbo.OnlinePayment
end



-- Transfer data from [db-au-stage].dbo.etl_onlinepayment to [db-au-cmdwh].dbo.OnlinePayment
insert into [db-au-cmdwh].dbo.OnlinePayment with (tablock)
(
        CountryKey,
        PaymentKey,
        PolicyKey,
        PayID,
        PolicyNo,
        MerchantTxtRef,
        OrderInfo,
        MerchantID,
        AmountPaid,
        ReceiptNo,
        QSIResponseCode,
        ResponseDescription,
        ACQResponseCode,
        TransactionNo,
        AuthoriseID,
        BatchNo,
        CardType,
        [DateAdd],
        RecordDate,
        AccountingDate,
        PaymentReferenceID
)
select * from [db-au-stage].dbo.etl_onlinepayment

GO
