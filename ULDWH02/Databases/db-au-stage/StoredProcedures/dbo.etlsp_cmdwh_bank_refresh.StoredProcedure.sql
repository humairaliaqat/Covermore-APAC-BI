USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_bank_refresh]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_bank_refresh]
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


delete [db-au-cmdwh].dbo.Bank
from [db-au-cmdwh].dbo.Bank b
    join [db-au-stage].dbo.etl_bank t on
        b.CountryKey = t.CountryKey and
        b.BankRecordKey = t.BankRecordKey


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
