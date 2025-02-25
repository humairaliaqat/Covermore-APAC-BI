USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_onlinepayment_refresh]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_onlinepayment_refresh]
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
  b.PayID as PayID,
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

delete [db-au-cmdwh].dbo.OnlinePayment
from [db-au-cmdwh].dbo.OnlinePayment o
    join [db-au-stage].dbo.etl_OnlinePayment t on
        o.CountryKey = t.CountryKey and
        o.PaymentKey = t.PaymentKey



-- Transfer data from [db-au-stage].dbo.etl_onlinepayment to [db-au-cmdwh].dbo.OnlinePayment
insert into [db-au-cmdwh].dbo.OnlinePayment with (tablockx)
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
