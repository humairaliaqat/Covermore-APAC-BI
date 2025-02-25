USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_banktransfer_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_banktransfer_rollup]
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


if object_id('[db-au-cmdwh].dbo.BankTransfer') is null
begin
  create table [db-au-cmdwh].dbo.BankTransfer
  (
    CountryKey varchar(2) NOT NULL,
    BankRecordKey varchar(13) NOT NULL,
    TransferKey varchar(13) NOT NULL,
    TransferID int not null,
    BankRec int not null,
    Account varchar(6) not null,
    Amount money not null
  )

  if exists(select name from sys.indexes where name = 'idx_BankTransfer_CountryKey')
    drop index idx_BankTransfer_CountryKey on BankTransfer.CountryKey

  if exists(select name from sys.indexes where name = 'idx_BankTransfer_BankRecordKey')
    drop index idx_BankTransfer_BankRecordKey on BankTransfer.BankRecordKey

  if exists(select name from sys.indexes where name = 'idx_BankTransfer_TransferKey')
    drop index idx_BankTransfer_TransferKey on BankTransfer.TransferKey

  if exists(select name from sys.indexes where name = 'idx_BankTransfer_TransferID')
    drop index idx_BankTransfer_TransferID on BankTransfer.TransferID


  create index idx_BankTransfer_CountryKey on [db-au-cmdwh].dbo.BankTransfer(CountryKey)
  create index idx_BankTransfer_BankRecordKey on [db-au-cmdwh].dbo.BankTransfer(BankRecordKey)
  create index idx_BankTransfer_TransferKey on [db-au-cmdwh].dbo.BankTransfer(TransferKey)
  create index idx_BankTransfer_TransferID on [db-au-cmdwh].dbo.BankTransfer(TransferID)
end
else
  truncate table [db-au-cmdwh].dbo.BankTransfer




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
