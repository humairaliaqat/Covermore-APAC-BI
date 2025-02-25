USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_bankreturn_refresh]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_bankreturn_refresh]
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

delete [db-au-cmdwh].dbo.BankReturn
from [db-au-cmdwh].dbo.BankReturn br
    join [db-au-stage].dbo.etl_bankreturn t on
        br.CountryKey = t.CountryKey and
        br.ReturnKey = t.ReturnKey


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
