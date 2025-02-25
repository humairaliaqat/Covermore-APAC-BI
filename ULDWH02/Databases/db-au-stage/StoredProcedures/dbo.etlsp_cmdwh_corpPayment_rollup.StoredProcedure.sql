USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_corpPayment_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_corpPayment_rollup]
as

SET NOCOUNT ON


/*************************************************************/
--combine registration from AU, NZ, AU into one table
/*************************************************************/
if object_id('[db-au-stage].dbo.etl_corpPayment') is not null drop table [db-au-stage].dbo.etl_corpPayment

select
  'AU' as CountryKey,
  left('AU-' + cast(b.PaymentID as varchar),41) as PaymentKey,
  left('AU-' + cast(b.RegistrationID as varchar),41) as RegistrationKey,
  b.PaymentID,
  b.RegistrationID,
  b.OrderID,
  b.[Status],
  b.Total,
  b.ReceiptNo,
  b.PaymentDate,
  b.CardType,
  b.MerchantID
into [db-au-stage].dbo.etl_corpPayment
from
  [db-au-stage].dbo.corp_tblPayment_au b



if object_id('[db-au-cmdwh].dbo.corpPayment') is null
begin
    create table [db-au-cmdwh].dbo.corpPayment
    (    
		CountryKey varchar(2) not null,
		PaymentKey varchar(41) null,
		RegistrationKey varchar(41) null,
		PaymentID int null,
		RegistrationID int null,
		OrderID [varchar](50) NULL,
		[Status] [varchar](100) NULL,
		Total [money] NULL,
		ReceiptNo [varchar](50) NULL,
		PaymentDate datetime NULL,
		CardType varchar(20) NULL,
		MerchantID varchar(16) NULL
    )
    if exists(select name from sys.indexes where name = 'idx_corpPayment_CountryKey')
    drop index idx_corpPayment_CountryKey on corpPayment.CountryKey

    if exists(select name from sys.indexes where name = 'idx_corpPayment_PaymentKey')
    drop index idx_corpPayment_PaymentKey on corpPayment.PaymentKey
    
    if exists(select name from sys.indexes where name = 'idx_corpPayment_RegistrationKey')
    drop index idx_corpPayment_RegistrationKey on corpPayment.RegistrationKey
  
    create index idx_corpPayment_CountryKey on [db-au-cmdwh].dbo.corpPayment(CountryKey)
    create index idx_corpPayment_PaymentKey on [db-au-cmdwh].dbo.corpPayment(PaymentKey)
    create index idx_corpPayment_RegistrationKey on [db-au-cmdwh].dbo.corpPayment(RegistrationKey)
end
else
    truncate table [db-au-cmdwh].dbo.corpPayment



/*************************************************************/
-- Transfer data from [db-au-stage].dbo.etl_corpPayment to [db-au-cmdwh].dbo.corpPayment
/*************************************************************/

insert into [db-au-cmdwh].dbo.corpPayment with (tablock)
(
	CountryKey,
	PaymentKey,
	RegistrationKey,
	PaymentID,
	RegistrationID,
	OrderID,
	[Status],
	Total,
	ReceiptNo,
	PaymentDate,
	CardType,
	MerchantID
)
select
	CountryKey,
	PaymentKey,
	RegistrationKey,
	PaymentID,
	RegistrationID,
	OrderID,
	[Status],
	Total,
	ReceiptNo,
	PaymentDate,
	CardType,
	MerchantID
from [db-au-stage].dbo.etl_corpPayment
GO
