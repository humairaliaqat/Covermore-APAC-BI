USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_bankreturn_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_bankreturn_rollup]
as

SET NOCOUNT ON


if object_id('[db-au-stage].dbo.etl_bankreturn') is not null drop table [db-au-stage].dbo.etl_bankreturn

select
  'AU' as CountryKey,
  'AU-' + cast(b.RtnID as varchar(10)) as ReturnKey,
  'AU-' + b.Alpha as AgencyKey,
  b.RtnID as ReturnID,
  b.Alpha as AgencyCode,
  b.Op,
  b.Account,
  b.BankDate,
  b.BankTime
into [db-au-stage].dbo.etl_bankreturn
from
  [db-au-stage].dbo.trips_bankreturns_au b

union all

select
  'NZ' as CountryKey,
  'NZ-' + cast(b.RtnID as varchar(10)) as ReturnKey,
  'NZ-' + b.Alpha as AgencyKey,
  b.RtnID as ReturnID,
  b.Alpha as AgencyCode,
  b.Op,
  b.Account,
  b.BankDate,
  b.BankTime
from
  [db-au-stage].dbo.trips_bankreturns_nz b

union all

select
  'UK' as CountryKey,
  'UK-' + cast(b.RtnID as varchar(10)) as ReturnKey,
  'UK-' + b.Alpha as AgencyKey,
  b.RtnID as ReturnID,
  b.Alpha as AgencyCode,
  b.Op,
  b.Account,
  b.BankDate,
  b.BankTime
from
  [db-au-stage].dbo.trips_bankreturns_uk b

union all

select
  'MY' as CountryKey,
  'MY-' + cast(b.RtnID as varchar(10)) as ReturnKey,
  'MY-' + b.Alpha as AgencyKey,
  b.RtnID as ReturnID,
  b.Alpha as AgencyCode,
  b.Op,
  b.Account,
  b.BankDate,
  b.BankTime
from
  [db-au-stage].dbo.trips_bankreturns_my b

union all

select
  'SG' as CountryKey,
  'SG-' + cast(b.RtnID as varchar(10)) as ReturnKey,
  'SG-' + b.Alpha as AgencyKey,
  b.RtnID as ReturnID,
  b.Alpha as AgencyCode,
  b.Op,
  b.Account,
  b.BankDate,
  b.BankTime
from
  [db-au-stage].dbo.trips_bankreturns_sg b


if object_id('[db-au-cmdwh].dbo.BankReturn') is null
begin
  create table [db-au-cmdwh].dbo.BankReturn
  (
    CountryKey varchar(2) NOT NULL,
    ReturnKey varchar(13) NOT NULL,
    AgencyKey varchar(10)  NULL,
    ReturnID int not null,
    AgencyCode varchar(7) null,
    Op varchar(10) null,
    Account varchar(4) null,
    BankDate datetime null,
    BankTime datetime null
  )

  if exists(select name from sys.indexes where name = 'idx_BankReturn_CountryKey')
    drop index idx_BankReturn_CountryKey on BankReturn.CountryKey

  if exists(select name from sys.indexes where name = 'idx_BankReturn_ReturnKey')
    drop index idx_BankReturn_ReturnKey on BankReturn.ReturnKey

  if exists(select name from sys.indexes where name = 'idx_BankReturn_AgencyKey')
    drop index idx_BankReturn_AgencyKey on BankReturn.AgencyKey

  if exists(select name from sys.indexes where name = 'idx_BankReturn_ReturnID')
    drop index idx_BankReturn_ReturnID on BankReturn.ReturnID

  if exists(select name from sys.indexes where name = 'idx_BankReturn_BankDate')
    drop index idx_BankReturn on BankReturn.BankDate

  create index idx_BankReturn_CountryKey on [db-au-cmdwh].dbo.BankReturn(CountryKey)
  create index idx_BankReturn_ReturnKey on [db-au-cmdwh].dbo.BankReturn(ReturnKey)
  create index idx_BankReturn_AgencyKey on [db-au-cmdwh].dbo.BankReturn(AgencyKey)
  create index idx_BankReturn_ReturnID on [db-au-cmdwh].dbo.BankReturn(ReturnID)
  create index idx_BankReturn_BankDate on [db-au-cmdwh].dbo.BankReturn(BankDate)
end
else
begin
  truncate table [db-au-cmdwh].dbo.BankReturn
end



-- Transfer data from [db-au-stage].dbo.etl_bankpayment to [db-au-cmdwh].dbo.BankPayment
insert into [db-au-cmdwh].dbo.BankReturn with (tablock)
(
    CountryKey,
    ReturnKey,
    AgencyKey,
    ReturnID,
    AgencyCode,
    Op,
    Account,
    BankDate,
    BankTime
)
select * from [db-au-stage].dbo.etl_bankreturn

GO
