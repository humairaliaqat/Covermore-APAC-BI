USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL037_Bank_Migration_penPayment]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_ETL037_Bank_Migration_penPayment] 
 
as

SET NOCOUNT ON


--TRIPS OnlinePayment table data migration to PENGUIN
--Transform and migration OnlinePayment data to penPayment
--PolicyTransactionKey will have a 'T' prefix to denote trips migrated data.
--

/***********************************************/
-- NZ OnlinePayment data
/***********************************************/  
        
if object_id('[db-au-stage].dbo.tmp_penPayment') is not null drop table [db-au-stage].dbo.tmp_penPayment
select
	convert(varchar(2),'NZ') as CountryKey,
	convert(varchar(5),'CM') as CompanyKey,
	convert(varchar(41),left('NZ-CM8-' + convert(varchar,p.PayID),35)) as PaymentKey,
	convert(varchar(41),left('NZ-CM8-T' + convert(varchar,p.PolicyNo),34)) as PolicyTransactionKey,
	p.PayID as PaymentID,
	convert(int,p.PolicyNo) as PolicyTransactionID,
	convert(varchar(50),p.MerchantTxtRef) as PaymentRefID,
	convert(varchar(50),p.OrderInfo) as OrderID,
	convert(varchar(100),p.ResponseDescription) as [Status],
	convert(money,p.AmountPaid / 100) as Total,
	convert(int,null) as ClientID,
	p.RecordDate as TransTime,
	convert(varchar(16),p.MerchantID) as MerchantID,
	convert(varchar(50),p.ReceiptNo) as ReceiptNo,
	convert(varchar(34),p.ResponseDescription) as ResponseDescription,
	convert(varchar(50),p.ACQResponseCode) as ACQResponseCode,
	convert(varchar(50),p.TransactionNo) as TransactionNo,
	convert(varchar(50),p.AuthoriseID) as AuthoriseID,
	convert(varchar(50),p.CardType) as CardType,
	convert(varchar(20),p.BatchNo) as BatchNo,
	convert(varchar(5),null) as TxnResponseCode,
	convert(varchar(41),'NZ-CM-8') as DomainKey,
	8 as DomainID,
	p.RecordDate as TransTimeUTC,
	null as PaymentGatewayID,
	null as PaymentMerchantID	
into [db-au-stage].dbo.tmp_penPayment	
from
	[db-au-cmdwh].dbo.OnlinePayment p
where
	p.CountryKey = 'NZ' 

if not exists(select name from  sys.indexes where  name = 'idx_tmp_penPayment_PaymentKey')
    create index idx_tmp_penPayment_PaymentKey on tmp_penPayment(PaymentKey)

if not exists(select name from  sys.indexes where  name = 'idx_tmp_penPayment_PolicyTransactionKey')
    create index idx_tmp_penPayment_PolicyTransactionKey on tmp_penPayment(PolicyTransactionKey)
	
delete [db-au-cmdwh].dbo.penPayment
from [db-au-cmdwh].dbo.penPayment a
	join [db-au-stage].dbo.tmp_penPayment b on
		a.PaymentKey = b.PaymentKey and
		a.PolicyTransactionKey = b.PolicyTransactionKey
where a.CountryKey = 'NZ'

insert [db-au-cmdwh].dbo.penPayment with(tablockx)
(
	CountryKey,
	CompanyKey,
	PaymentKey,
	PolicyTransactionKey,
	PaymentID,
	PolicyTransactionID,
	PaymentRefID,
	OrderId,
	[Status],
	Total,
	ClientID,
	TransTime,
	MerchantID,
	ReceiptNo,
	ResponseDescription,
	ACQResponseCode,
	TransactionNo,
	AuthoriseID,
	CardType,
	BatchNo,
	TxnResponseCode,
	DomainKey,
	DomainID,
	TransTimeUTC,
	PaymentGatewayID,
	PaymentMerchantID	
)
select
	p.CountryKey,
	p.CompanyKey,
	p.PaymentKey,
	p.PolicyTransactionKey,
	p.PaymentID,
	p.PolicyTransactionID,
	p.PaymentRefID,
	p.OrderId,
	p.[Status],
	p.Total,
	p.ClientID,
	p.TransTime,
	p.MerchantID,
	p.ReceiptNo,
	p.ResponseDescription,
	p.ACQResponseCode,
	p.TransactionNo,
	p.AuthoriseID,
	p.CardType,
	p.BatchNo,
	p.TxnResponseCode,
	p.DomainKey,
	p.DomainID,
	p.TransTimeUTC,
	p.PaymentGatewayID,
	p.PaymentMerchantID
from
	[db-au-stage].dbo.tmp_penPayment p	


/***********************************************/
-- UK OnlinePayment data
/***********************************************/
if object_id('[db-au-stage].dbo.tmp_penPayment') is not null drop table [db-au-stage].dbo.tmp_penPayment
select
	convert(varchar(2),'UK') as CountryKey,
	convert(varchar(5),'CM') as CompanyKey,
	convert(varchar(41),left('UK-CM11-' + convert(varchar,p.PayID),35)) as PaymentKey,
	convert(varchar(41),left('UK-CM11-T' + convert(varchar,p.PolicyNo),34)) as PolicyTransactionKey,
	p.PayID as PaymentID,
	convert(int,p.PolicyNo) as PolicyTransactionID,
	convert(varchar(50),p.MerchantTxtRef) as PaymentRefID,
	convert(varchar(50),p.OrderInfo) as OrderID,
	convert(varchar(100),p.ResponseDescription) as [Status],
	convert(money,p.AmountPaid / 100) as Total,
	convert(int,null) as ClientID,
	p.RecordDate as TransTime,
	convert(varchar(16),p.MerchantID) as MerchantID,
	convert(varchar(50),p.ReceiptNo) as ReceiptNo,
	convert(varchar(34),p.ResponseDescription) as ResponseDescription,
	convert(varchar(50),p.ACQResponseCode) as ACQResponseCode,
	convert(varchar(50),p.TransactionNo) as TransactionNo,
	convert(varchar(50),p.AuthoriseID) as AuthoriseID,
	convert(varchar(50),p.CardType) as CardType,
	convert(varchar(20),p.BatchNo) as BatchNo,
	convert(varchar(5),null) as TxnResponseCode,
	convert(varchar(41),'UK-CM-11') as DomainKey,
	11 as DomainID,
	p.RecordDate as TransTimeUTC,
	null as PaymentGatewayID,
	null as PaymentMerchantID	
into [db-au-stage].dbo.tmp_penPayment	
from
	[db-au-cmdwh].dbo.OnlinePayment p
where
	p.CountryKey = 'UK' 
	

if not exists(select name from  sys.indexes where  name = 'idx_tmp_penPayment_PaymentKey')
    create index idx_tmp_penPayment_PaymentKey on tmp_penPayment(PaymentKey)

if not exists(select name from  sys.indexes where  name = 'idx_tmp_penPayment_PolicyTransactionKey')
    create index idx_tmp_penPayment_PolicyTransactionKey on tmp_penPayment(PolicyTransactionKey)
    
    	
delete [db-au-cmdwh].dbo.penPayment
from [db-au-cmdwh].dbo.penPayment a
	join [db-au-stage].dbo.tmp_penPayment b on
		a.PaymentKey = b.PaymentKey and
		a.PolicyTransactionKey = b.PolicyTransactionKey
where a.CountryKey = 'UK'

insert [db-au-cmdwh].dbo.penPayment with(tablockx)
(
	CountryKey,
	CompanyKey,
	PaymentKey,
	PolicyTransactionKey,
	PaymentID,
	PolicyTransactionID,
	PaymentRefID,
	OrderId,
	[Status],
	Total,
	ClientID,
	TransTime,
	MerchantID,
	ReceiptNo,
	ResponseDescription,
	ACQResponseCode,
	TransactionNo,
	AuthoriseID,
	CardType,
	BatchNo,
	TxnResponseCode,
	DomainKey,
	DomainID,
	TransTimeUTC,
	PaymentGatewayID,
	PaymentMerchantID	
)
select
	p.CountryKey,
	p.CompanyKey,
	p.PaymentKey,
	p.PolicyTransactionKey,
	p.PaymentID,
	p.PolicyTransactionID,
	p.PaymentRefID,
	p.OrderId,
	p.[Status],
	p.Total,
	p.ClientID,
	p.TransTime,
	p.MerchantID,
	p.ReceiptNo,
	p.ResponseDescription,
	p.ACQResponseCode,
	p.TransactionNo,
	p.AuthoriseID,
	p.CardType,
	p.BatchNo,
	p.TxnResponseCode,
	p.DomainKey,
	p.DomainID,
	p.TransTimeUTC,
	p.PaymentGatewayID,
	p.PaymentMerchantID
from
	[db-au-stage].dbo.tmp_penPayment p		
GO
