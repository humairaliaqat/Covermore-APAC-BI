USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_corpContact_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_corpContact_rollup]
as

SET NOCOUNT ON


/*************************************************************/
--combine Contact from AU, NZ into one table
/*************************************************************/
if object_id('[db-au-stage].dbo.etl_corpContact') is not null drop table [db-au-stage].dbo.etl_corpContact

select
  'AU' as CountryKey,
  left('AU-' + cast(c.ContactID as varchar),10) as ContactKey,
  left('AU-' + cast(c.QtID as varchar),10) as QuoteKey,
  c.ContactID,
  c.QtID as QuoteID,
  c.ContactType,
  c.Title,
  c.FirstName,
  c.Surname,
  c.DirectPh as DirectPhone
into [db-au-stage].dbo.etl_corpContact
from
  [db-au-stage].dbo.corp_tblContacts_au c

union all

select
  'NZ' as CountryKey,
  left('NZ-' + cast(c.ContactID as varchar),10) as ContactKey,
  left('NZ-' + cast(c.QtID as varchar),10) as QuoteKey,
  c.ContactID,
  c.QtID as QuoteID,
  c.ContactType,
  c.Title,
  c.FirstName,
  c.Surname,
  c.DirectPh as DirectPhone
from
  [db-au-stage].dbo.corp_tblContacts_nz c

union all

select
  'UK' as CountryKey,
  left('UK-' + cast(c.ContactID as varchar),10) as ContactKey,
  left('UK-' + cast(c.QtID as varchar),10) as QuoteKey,
  c.ContactID,
  c.QtID as QuoteID,
  c.ContactType,
  c.Title,
  c.FirstName,
  c.Surname,
  c.DirectPh as DirectPhone
from
  [db-au-stage].dbo.corp_tblContacts_uk c


if object_id('[db-au-cmdwh].dbo.corpContact') is null
begin
    create table [db-au-cmdwh].dbo.corpContact
    (
        [CountryKey] [varchar](2) NOT NULL,
        [ContactKey] [varchar](10) NULL,
        [QuoteKey] [varchar](10) NULL,
        [ContactID] [int] NOT NULL,
        [QuoteID] [int] NULL,
        [ContactType] [char](1) NULL,
        [Title] [varchar](5) NULL,
        [FirstName] [varchar](15) NULL,
        [Surname] [varchar](25) NULL,
        [DirectPhone] [varchar](15) NULL
    )
    if exists(select name from sys.indexes where name = 'idx_corpContact_CountryKey')
    drop index idx_corpContact_CountryKey on corpContact.CountryKey

    if exists(select name from sys.indexes where name = 'idx_corpContact_ContactKey')
    drop index idx_corpContact_ContactKey on corpContact.ContactKey

    if exists(select name from sys.indexes where name = 'idx_corpContact_QuoteKey')
    drop index idx_corpContact_QuoteKey on corpContact.QuoteKey

    create index idx_corpContact_CountryKey on [db-au-cmdwh].dbo.corpContact(CountryKey)
    create index idx_corpContact_ContactKey on [db-au-cmdwh].dbo.corpContact(ContactKey)
    create index idx_corpContact_QuoteKey on [db-au-cmdwh].dbo.corpContact(QuoteKey)
end
else
    truncate table [db-au-cmdwh].dbo.corpContact



/*************************************************************/
-- Transfer data from [db-au-stage].dbo.etl_corpContact to [db-au-cmdwh].dbo.corpContact
/*************************************************************/

insert into [db-au-cmdwh].dbo.corpContact with (tablock)
(
    CountryKey,
    ContactKey,
    QuoteKey,
    ContactID,
    QuoteID,
    ContactType,
    Title,
    FirstName,
    Surname,
    DirectPhone
)
select
    CountryKey,
    ContactKey,
    QuoteKey,
    ContactID,
    QuoteID,
    ContactType,
    Title,
    FirstName,
    Surname,
    DirectPhone
from [db-au-stage].dbo.etl_corpContact



GO
