USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_banktransfer_refresh]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_banktransfer_refresh]
as

SET NOCOUNT ON


if object_id('[db-au-stage].dbo.etl_banktransfer') is not null drop table [db-au-stage].dbo.etl_banktransfer

select
  'AU' as CountryKey,
  'AU-' + cast(b.BankRec as varchar(10)) as BankRecordKey,
  'AU-' + cast(b.TransferID as varchar(10)) as TransferKey,
  b.TransferID,
  b.BankRec,
  b.Account,
  b.Amount
into [db-au-stage].dbo.etl_banktransfer
from
  [db-au-stage].dbo.trips_banktransfers_au b

union all

select
  'NZ' as CountryKey,
  'NZ-' + cast(b.BankRec as varchar(10)) as BankRecordKey,
  'NZ-' + cast(b.TransferID as varchar(10)) as TransferKey,
  b.TransferID,
  b.BankRec,
  b.Account,
  b.Amount
from
  [db-au-stage].dbo.trips_banktransfers_nz b

union all

select
  'MY' as CountryKey,
  'MY-' + cast(b.BankRec as varchar(10)) as BankRecordKey,
  'MY-' + cast(b.TransferID as varchar(10)) as TransferKey,
  b.TransferID,
  b.BankRec,
  b.Account,
  b.Amount
from
  [db-au-stage].dbo.trips_banktransfers_my b

union all

select
  'SG' as CountryKey,
  'SG-' + cast(b.BankRec as varchar(10)) as BankRecordKey,
  'SG-' + cast(b.TransferID as varchar(10)) as TransferKey,
  b.TransferID,
  b.BankRec,
  b.Account,
  b.Amount
from
  [db-au-stage].dbo.trips_banktransfers_sg b

delete [db-au-cmdwh].dbo.BankTransfer
from [db-au-cmdwh].dbo.BankTransfer bt
    join [db-au-stage].dbo.etl_banktransfer t on
        bt.CountryKey = t.CountryKey and
        bt.TransferKey = t.TransferKey



-- Transfer data from [db-au-stage].dbo.etl_banktransfer to [db-au-cmdwh].dbo.BankTransfer
insert into [db-au-cmdwh].dbo.BankTransfer with (tablock)
(
    CountryKey,
    BankRecordKey,
    TransferKey,
    TransferID,
    BankRec,
    Account,
    Amount
)
select * from [db-au-stage].dbo.etl_banktransfer

GO
