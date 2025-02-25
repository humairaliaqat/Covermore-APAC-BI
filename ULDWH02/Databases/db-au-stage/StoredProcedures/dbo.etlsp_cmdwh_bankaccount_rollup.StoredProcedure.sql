USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_bankaccount_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_bankaccount_rollup]
as

SET NOCOUNT ON


if object_id('[db-au-cmdwh].dbo.BankAccount') is null
begin
    create table [db-au-cmdwh].dbo.BankAccount
    (
        CountryKey varchar(2) not null,
        AgencyKey varchar(10) not null,
        AccountKey varchar(10) not null,
        AgencyCode varchar(7) null,
        AccountID int not null,
        AccountName varchar(30) null,
        BSB varchar(10) null,
        AccountNo varchar(10) null,
        AccountEmail varchar(100) null
    )

    if exists(select name from sys.indexes where name = 'idx_BankAccount_CountryKey')
        drop index idx_BankAccount_CountryKey on BankAccount.CountryKey

    if exists(select name from sys.indexes where name = 'idx_BankAccount_AgencyKey')
        drop index idx_BankAccount_AgencyKey on BankAccount.AgencyKey

    if exists(select name from sys.indexes where name = 'idx_BankAccount_AccountKey')
        drop index idx_BankAccount_AccountKey on BankAccount.AccountKey

    if exists(select name from sys.indexes where name = 'idx_BankAccount_AgencyCode')
        drop index idx_BankAccount_AgencyCode on BankAccount.AgencyCode

    if exists(select name from sys.indexes where name = 'idx_BankAccount_AccountID')
        drop index idx_BankAccount_AccountID on BankAccount.AccountID

    create index idx_BankAccount_CountryKey on [db-au-cmdwh].dbo.BankAccount(CountryKey)
    create index idx_BankAccount_AgencyKey on [db-au-cmdwh].dbo.BankAccount(AgencyKey)
    create index idx_BankAccount_AccountKey on [db-au-cmdwh].dbo.BankAccount(AccountKey)
    create index idx_BankAccount_AgencyCode on [db-au-cmdwh].dbo.BankAccount(AgencyCode)
    create index idx_BankAccount_AccountID on [db-au-cmdwh].dbo.BankAccount(AccountID)
end
else
    truncate table [db-au-cmdwh].dbo.BankAccount


insert [db-au-cmdwh].dbo.BankAccount with (TABLOCKX)
select
    'AU' as CountryKey,
    left('AU-' + a.DCALPHA,10) as AgencyKey,
    left('AU-' + convert(varchar,a.DCACCOUNTID),10) as AccountKey,
    left(a.DCALPHA,7) as AgencyCode,
    a.DCACCOUNTID as AccountID,
    left(a.DCACCNAME,30) as AccountName,
    left(a.BSB,10) as BSB,
    left(a.DCACCNO,10) as AccountNo,
    left(a.DCACCEMAIL,100) as AccountEmail
from
    [db-au-stage].dbo.trips_dcaccount_au a

union all

select
    'NZ' as CountryKey,
    left('NZ-' + a.DCALPHA,10) as AgencyKey,
    left('NZ-' + convert(varchar,a.DCACCOUNTID),10) as AccountKey,
    left(a.DCALPHA,7) as AgencyCode,
    a.DCACCOUNTID as AccountID,
    left(a.DCACCNAME,30) as AccountName,
    left(a.BSB,10) as BSB,
    left(a.DCACCNO,10) as AccountNo,
    left(a.DCACCEMAIL,100) as AccountEmail
from
    [db-au-stage].dbo.trips_dcaccount_nz a


union all

select
    'UK' as CountryKey,
    left('UK-' + a.DCALPHA,10) as AgencyKey,
    left('UK-' + convert(varchar,a.DCACCOUNTID),10) as AccountKey,
    left(a.DCALPHA,7) as AgencyCode,
    a.DCACCOUNTID as AccountID,
    left(a.DCACCNAME,30) as AccountName,
    left(a.BSB,10) as BSB,
    left(a.DCACCNO,10) as AccountNo,
    left(a.DCACCEMAIL,100) as AccountEmail
from
    [db-au-stage].dbo.trips_dcaccount_uk a

union all

select
    'MY' as CountryKey,
    left('MY-' + a.DCALPHA,10) as AgencyKey,
    left('MY-' + convert(varchar,a.DCACCOUNTID),10) as AccountKey,
    left(a.DCALPHA,7) as AgencyCode,
    a.DCACCOUNTID as AccountID,
    left(a.DCACCNAME,30) as AccountName,
    left(a.BSB,10) as BSB,
    left(a.DCACCNO,10) as AccountNo,
    left(a.DCACCEMAIL,100) as AccountEmail
from
    [db-au-stage].dbo.trips_dcaccount_my a

union all

select
    'SG' as CountryKey,
    left('SG-' + a.DCALPHA,10) as AgencyKey,
    left('SG-' + convert(varchar,a.DCACCOUNTID),10) as AccountKey,
    left(a.DCALPHA,7) as AgencyCode,
    a.DCACCOUNTID as AccountID,
    left(a.DCACCNAME,30) as AccountName,
    left(a.BSB,10) as BSB,
    left(a.DCACCNO,10) as AccountNo,
    left(a.DCACCEMAIL,100) as AccountEmail
from
    [db-au-stage].dbo.trips_dcaccount_sg a

GO
