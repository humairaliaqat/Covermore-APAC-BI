USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_corpExcessDiscRate_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_corpExcessDiscRate_rollup]
as

SET NOCOUNT ON


/*************************************************************/
--combine EMC from AU, NZ into one table
/*************************************************************/
if object_id('[db-au-stage].dbo.etl_corpExcessDiscRate') is not null drop table [db-au-stage].dbo.etl_corpExcessDiscRate

select
  'AU' as CountryKey,
  left('AU-' + cast(e.ID as varchar),10) as ExcessDiscRateKey,
  e.ID as ExcessDiscRateID,
  e.XSAmt as ExcessAmount,
  e.DiscRate as DiscountRate,
  e.ValidFrom as ValidFrom,
  e.ValidTo as ValidTo
into [db-au-stage].dbo.etl_corpExcessDiscRate
from
  [db-au-stage].dbo.corp_tblExcessDiscRates_au e

union all

select
  'NZ' as CountryKey,
  left('NZ-' + cast(e.ID as varchar),10) as ExcessDiscRateKey,
  e.ID as ExcessDiscRateID,
  e.XSAmt as ExcessAmount,
  e.DiscRate as DiscountRate,
  e.ValidFrom as ValidFrom,
  e.ValidTo as ValidTo
from
  [db-au-stage].dbo.corp_tblExcessDiscRates_nz e

union all

select
  'UK' as CountryKey,
  left('UK-' + cast(e.ID as varchar),10) as ExcessDiscRateKey,
  e.ID as ExcessDiscRateID,
  e.XSAmt as ExcessAmount,
  e.DiscRate as DiscountRate,
  e.ValidFrom as ValidFrom,
  e.ValidTo as ValidTo
from
  [db-au-stage].dbo.corp_tblExcessDiscRates_uk e


if object_id('[db-au-cmdwh].dbo.corpExcessDiscRate') is null
begin
    create table [db-au-cmdwh].dbo.corpExcessDiscRate
    (
        [CountryKey] [varchar](2) NOT NULL,
        [ExcessDiscRateKey] [varchar](10) NULL,
        [ExcessDiscRateID] [int] NOT NULL,
        [ExcessAmount] [money] NULL,
        [DiscountRate] [real] NULL,
        [ValidFrom] [datetime] NULL,
        [ValidTo] [datetime] NULL
    )

    if exists(select name from sys.indexes where name = 'idx_corpExcessDiscRate_CountryKey')
    drop index idx_corpExcessDiscRate_CountryKey on corpExcessDiscRate.CountryKey

    if exists(select name from sys.indexes where name = 'idx_corpExcessDiscRate_ExcessDiscRateKey')
    drop index idx_corpExcessDiscRate_ExcessDiscRateKey on corpExcessDiscRate.ExcessDiscRateKey

    create index idx_corpExcessDiscRate_CountryKey on [db-au-cmdwh].dbo.corpExcessDiscRate(CountryKey)
    create index idx_corpExcessDiscRate_EMCKey on [db-au-cmdwh].dbo.corpExcessDiscRate(ExcessDiscRateKey )

end
else
    truncate table [db-au-cmdwh].dbo.corpExcessDiscRate



/*************************************************************/
-- Transfer data from [db-au-stage].dbo.etl_corpExcessDiscRate to [db-au-cmdwh].dbo.corpExcessDiscRate
/*************************************************************/

insert into [db-au-cmdwh].dbo.corpExcessDiscRate with (tablock)
(
    CountryKey,
    ExcessDiscRateKey,
    ExcessDiscRateID,
    ExcessAmount,
    DiscountRate,
    ValidFrom,
    ValidTo
)
select
    CountryKey,
    ExcessDiscRateKey,
    ExcessDiscRateID,
    ExcessAmount,
    DiscountRate,
    ValidFrom,
    ValidTo
from [db-au-stage].dbo.etl_corpExcessDiscRate



GO
