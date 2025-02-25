USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_bank_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_bank_rollup]
as

SET NOCOUNT ON


if object_id('[db-au-stage].dbo.etl_bank') is not null drop table [db-au-stage].dbo.etl_bank

select
  'AU' as CountryKey,
  'AU-' + b.Alpha as AgencyKey,
  'AU-' + cast(b.RecordNo as varchar(10)) as BankRecordKey,
  b.RecordNo,
  b.BankDate,
  b.ACT as AccountingDate,
  b.Account,
  b.Product,
  b.Alpha as AgencyCode,
  b.Gross,
  b.Commission,
  b.Adjustment,
  b.Refund,
  b.RefundChq,
  b.Op,
  b.Comments,
  b.MMBonus,
  b.AdjTypeID
into [db-au-stage].dbo.etl_bank
from
  [db-au-stage].dbo.trips_bank_au b

union all

select
  'NZ' as CountryKey,
  'NZ-' + b.Alpha as AgencyKey,
  'NZ-' + cast(b.RecordNo as varchar(10)) as BankRecordKey,
  b.RecordNo,
  b.BankDate,
  b.ACT as AccountingDate,
  b.Account,
  b.Product,
  b.Alpha as AgencyCode,
  b.Gross,
  b.Commission,
  b.Adjustment,
  b.Refund,
  b.RefundChq,
  b.Op,
  b.Comments,
  b.MMBonus,
  b.AdjTypeID
from
  [db-au-stage].dbo.trips_bank_nz b

union all

select
  'UK' as CountryKey,
  'UK-' + b.Alpha as AgencyKey,
  'UK-' + cast(b.RecordNo as varchar(10)) as BankRecordKey,
  b.RecordNo,
  b.BankDate,
  b.ACT as AccountingDate,
  b.Account,
  b.Product,
  b.Alpha as AgencyCode,
  b.Gross,
  b.Commission,
  b.Adjustment,
  b.Refund,
  b.RefundChq,
  b.Op,
  b.Comments,
  b.MMBonus,
  b.AdjTypeID
from
  [db-au-stage].dbo.trips_bank_uk b

union all

select
  'MY' as CountryKey,
  'MY-' + b.Alpha as AgencyKey,
  'MY-' + cast(b.RecordNo as varchar(10)) as BankRecordKey,
  b.RecordNo,
  b.BankDate,
  b.ACT as AccountingDate,
  b.Account,
  b.Product,
  b.Alpha as AgencyCode,
  b.Gross,
  b.Commission,
  b.Adjustment,
  b.Refund,
  b.RefundChq,
  b.Op,
  b.Comments,
  b.MMBonus,
  b.AdjTypeID
from
  [db-au-stage].dbo.trips_bank_my b

union all

select
  'SG' as CountryKey,
  'SG-' + b.Alpha as AgencyKey,
  'SG-' + cast(b.RecordNo as varchar(10)) as BankRecordKey,
  b.RecordNo,
  b.BankDate,
  b.ACT as AccountingDate,
  b.Account,
  b.Product,
  b.Alpha as AgencyCode,
  b.Gross,
  b.Commission,
  b.Adjustment,
  b.Refund,
  b.RefundChq,
  b.Op,
  b.Comments,
  b.MMBonus,
  b.AdjTypeID
from
  [db-au-stage].dbo.trips_bank_sg b


if object_id('[db-au-cmdwh].dbo.Bank') is null
begin
  create table [db-au-cmdwh].dbo.Bank
  (
    CountryKey varchar(2) not null,
    AgencyKey varchar(10) null,
    BankRecordKey varchar(13) null,
    RecordNo int NOT NULL,
    BankDate datetime NULL,
    AccountingDate datetime NULL,
    Account varchar(4) NULL,
    Product varchar(3) NULL,
    AgencyCode varchar(7) NULL,
    Gross money NULL,
    Commission money NULL,
    Adjustment money NULL,
    Refund money NULL,
    RefundChq int NULL,
    Op varchar(2) NULL,
    Comments varchar(100) NULL,
    MMBonus money NULL,
    AdjTypeID smallint NULL
  )

  if exists(select name from sys.indexes where name = 'idx_Bank_CountryKey')
    drop index idx_Bank_CountryKey on Bank.CountryKey

  if exists(select name from sys.indexes where name = 'idx_Bank_AgencyKey')
    drop index idx_Bank_AgencyKey on Bank.AgencyKey

  if exists(select name from sys.indexes where name = 'idx_Bank_BankRecordKey')
    drop index idx_Bank_BankRecordKey on Bank.BankRecordKey

  if exists(select name from sys.indexes where name = 'idx_Bank_RecordNo')
    drop index idx_Bank_RecordNo on Bank.RecordNo

  if exists(select name from sys.indexes where name = 'idx_Bank_BankDate')
    drop index idx_Bank_BankDate on Bank.BankDate

  if exists(select name from sys.indexes where name = 'idx_Bank_Account')
    drop index idx_Bank_Account on Bank.Account

  create index idx_Bank_CountryKey on [db-au-cmdwh].dbo.Bank(CountryKey)
  create index idx_Bank_AgencyKey on [db-au-cmdwh].dbo.Bank(AgencyKey)
  create index idx_Bank_BankRecordKey on [db-au-cmdwh].dbo.Bank(BankRecordKey)
  create index idx_Bank_RecordNo on [db-au-cmdwh].dbo.Bank(RecordNo)
  create index idx_Bank_BankDate on [db-au-cmdwh].dbo.Bank(BankDate)
  create index idx_Bank_Account on [db-au-cmdwh].dbo.Bank(Account)
end
else
begin
  truncate table [db-au-cmdwh].dbo.Bank
end



-- Transfer data from [db-au-stage].dbo.etl_bank to [db-au-cmdwh].dbo.Bank
insert into [db-au-cmdwh].dbo.Bank with (tablock)
(
    CountryKey,
    AgencyKey,
    BankRecordKey,
    RecordNo,
    BankDate,
    AccountingDate,
    Account,
    Product,
    AgencyCode,
    Gross,
    Commission,
    Adjustment,
    Refund,
    RefundChq,
    Op,
    Comments,
    MMBonus,
    AdjTypeID
)
select * from [db-au-stage].dbo.etl_bank

GO
