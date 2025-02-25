USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_corpCompany_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_corpCompany_rollup]
as

SET NOCOUNT ON


/*************************************************************/
--combine companies from AU, NZ, AU into one table
/*************************************************************/

if object_id('[db-au-stage].dbo.etl_corpCompany') is not null drop table [db-au-stage].dbo.etl_corpCompany

select
  'AU' as CountryKey,
  left('AU-' + cast(c.CompID as varchar),10) as CompanyKey,
  c.CompID as CompanyID,
  c.CompName as CompanyName,
  c.Nature,
  c.ACN,
  c.ABN,
  c.Street,
  c.Suburb,
  c.State,
  c.PostCode,
  c.ITC,
  c.NotRenew,
  c.Phone,
  c.Fax,
  c.Email
into [db-au-stage].dbo.etl_corpCompany
from
  [db-au-stage].dbo.corp_tblCompanies_au c

union all

select
  'NZ' as CountryKey,
  left('NZ-' + cast(c.CompID as varchar),10) as CompanyKey,
  c.CompID as CompanyID,
  c.CompName as CompanyName,
  c.Nature,
  c.ACN,
  c.ABN,
  c.Street,
  c.Suburb,
  c.State,
  c.PostCode,
  c.ITC,
  c.NotRenew,
  c.Phone,
  c.Fax,
  c.Email
from
  [db-au-stage].dbo.corp_tblCompanies_nz c

union all

select
  'UK' as CountryKey,
  left('UK-' + cast(c.CompID as varchar),10) as CompanyKey,
  c.CompID as CompanyID,
  c.CompName as CompanyName,
  c.Nature,
  c.ACN,
  c.ABN,
  c.Street,
  c.Suburb,
  c.State,
  c.PostCode,
  c.ITC,
  c.NotRenew,
  c.Phone,
  c.Fax,
  c.Email
from
  [db-au-stage].dbo.corp_tblCompanies_uk c


if object_id('[db-au-cmdwh].dbo.corpCompany') is null
begin
    create table [db-au-cmdwh].dbo.corpCompany
    (
        CountryKey varchar(2) NOT NULL,
        CompanyKey varchar(10) NULL,
        CompanyID int NOT NULL,
        CompanyName varchar(50) NULL,
        Nature varchar(50) NULL,
        ACN varchar(15) NULL,
        ABN varchar(15) NULL,
        Street varchar(100) NULL,
        Suburb varchar(25) NULL,
        State varchar(20) NULL,
        PostCode varchar(10) NULL,
        ITC float NULL,
        NotRenew bit NULL,
        Phone varchar(15) NULL,
        Fax varchar(15) NULL,
        Email varchar(50) NULL
    )
    if exists(select name from sys.indexes where name = 'idx_corpCompany_CountryKey')
    drop index idx_corpCompany_CountryKey on corpCompany.CountryKey

    if exists(select name from sys.indexes where name = 'idx_corpCompany_CompanyKey')
    drop index idx_corpCompany_CompanyKey on corpCompany.CompanyKey

    create index idx_corpCompany_CountryKey on [db-au-cmdwh].dbo.corpCompany(CountryKey)
    create index idx_corpCompany_CompanyKey on [db-au-cmdwh].dbo.corpCompany(CompanyKey)
end
else
  truncate table [db-au-cmdwh].dbo.corpCompany





/*************************************************************/
-- Transfer data from [db-au-stage].dbo.etl_corpCompany to [db-au-cmdwh].dbo.corpCompany
/*************************************************************/

insert into [db-au-cmdwh].dbo.corpCompany with (tablock)
(
        CountryKey,
        CompanyKey,
        CompanyID,
        CompanyName,
        Nature,
        ACN,
        ABN,
        Street,
        Suburb,
        State,
        PostCode,
        ITC,
        NotRenew,
        Phone,
        Fax,
        Email
)
select
        CountryKey,
        CompanyKey,
        CompanyID,
        CompanyName,
        Nature,
        ACN,
        ABN,
        Street,
        Suburb,
        State,
        PostCode,
        ITC,
        NotRenew,
        Phone,
        Fax,
        Email
from [db-au-stage].dbo.etl_corpCompany



GO
