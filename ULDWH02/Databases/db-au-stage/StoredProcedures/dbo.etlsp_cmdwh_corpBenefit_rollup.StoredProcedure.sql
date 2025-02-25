USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_corpBenefit_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_corpBenefit_rollup]
as

SET NOCOUNT ON


/*************************************************************/
--combine benefits from AU, NZ, AU into one table
/*************************************************************/
if object_id('[db-au-stage].dbo.etl_corpBenefit') is not null drop table [db-au-stage].dbo.etl_corpBenefit

select
  'AU' as CountryKey,
  left('AU-' + cast(b.BenefitID as varchar),10) as BenefitKey,
  b.BenefitID as BenefitID,
  b.BenCode as BenefitCode,
  b.BenDesc as BenefitDesc,
  b.ValidFrom,
  b.ValidTo
into [db-au-stage].dbo.etl_corpBenefit
from
  [db-au-stage].dbo.corp_tblBenefits_au b

union all

select
  'NZ' as CountryKey,
  left('NZ-' + cast(b.BenefitID as varchar),10) as BenefitKey,
  b.BenefitID as BenefitID,
  b.BenCode as BenefitCode,
  b.BenDesc as BenefitDesc,
  b.ValidFrom,
  b.ValidTo
from
  [db-au-stage].dbo.corp_tblBenefits_nz b


if object_id('[db-au-cmdwh].dbo.corpBenefit') is null
begin
    create table [db-au-cmdwh].dbo.corpBenefit
    (
        CountryKey varchar(2) NOT NULL,
        BenefitKey varchar(10) NULL,
        BenefitID int NOT NULL,
        BenefitCode varchar(10) NULL,
        BenefitDesc varchar(250) NULL,
        ValidFrom datetime NULL,
        ValidTo datetime NULL
    )
    if exists(select name from sys.indexes where name = 'idx_corpBenefit_CountryKey')
    drop index idx_corpBenefit_CountryKey on corpBenefit.CountryKey

    if exists(select name from sys.indexes where name = 'idx_corpBenefit_BenefitKey')
    drop index idx_corpBenefit_BenefitKey on corpBenefit.BenefitKey

    create index idx_corpBenefit_CountryKey on [db-au-cmdwh].dbo.corpBenefit(CountryKey)
    create index idx_corpBenefit_BenefitKey on [db-au-cmdwh].dbo.corpBenefit(BenefitKey)
end
else
    truncate table [db-au-cmdwh].dbo.corpBenefit





/*************************************************************/
-- Transfer data from [db-au-stage].dbo.etl_corpBenefit to [db-au-cmdwh].dbo.corpBenefit
/*************************************************************/

insert into [db-au-cmdwh].dbo.corpBenefit with (tablock)
(
        CountryKey,
        BenefitKey,
        BenefitID,
        BenefitCode,
        BenefitDesc,
        ValidFrom,
        ValidTo
)
select
        CountryKey,
        BenefitKey,
        BenefitID,
        BenefitCode,
        BenefitDesc,
        ValidFrom,
        ValidTo
from [db-au-stage].dbo.etl_corpBenefit



GO
