USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_corpPolicyDiscRate_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_corpPolicyDiscRate_rollup]
as

SET NOCOUNT ON


if object_id('[db-au-cmdwh].dbo.corpPolicyDiscRate') is null
begin
    create table [db-au-cmdwh].dbo.corpPolicyDiscRate
    (
        [CountryKey] [varchar](2) NOT NULL,
        [PolicyDiscRateKey] [varchar](10) NULL,
        [PolicyDiscRateID] [int] NULL,
        [DiscountRate] [real] NULL,
        [ValidFrom] [datetime] NULL,
        [ValidTo] [datetime] NULL
    )

    if exists(select name from sys.indexes where name = 'idx_corpPolicyDiscRate_CountryKey')
    drop index idx_corpPolicyDiscRate_CountryKey on corpPolicyDiscRate.CountryKey

    if exists(select name from sys.indexes where name = 'idx_corpPolicyDiscRate_PolicyDiscRateKey')
    drop index idx_corpPolicyDiscRate_MiscCodeKey on corpPolicyDiscRate.PolicyDiscRateKey

    create index idx_corpPolicyDiscRate_CountryKey on [db-au-cmdwh].dbo.corpPolicyDiscRate(CountryKey)
    create index idx_corpPolicyDiscRate_EMCKey on [db-au-cmdwh].dbo.corpPolicyDiscRate(PolicyDiscRateKey)

end
else
    truncate table [db-au-cmdwh].dbo.corpPolicyDiscRate



insert into [db-au-cmdwh].dbo.corpPolicyDiscRate with (tablock)
(
    [CountryKey],
    [PolicyDiscRateKey],
    [PolicyDiscRateID],
    [DiscountRate],
    [ValidFrom],
    [ValidTo]
)
select
  'AU' as CountryKey,
  left('AU-' + cast(d.ID as varchar),10) as PolicyDiscRateKey,
  d.ID as PolicyDiscRateID,
  d.DiscRate as DiscountRate,
  d.ValidFrom,
  d.ValidTo
from
  [db-au-stage].dbo.corp_tblNewPolDiscRates_au d

union all

select
  'NZ' as CountryKey,
  left('NZ-' + cast(d.ID as varchar),10) as PolicyDiscRateKey,
  d.ID as PolicyDiscRateID,
  d.DiscRate as DiscountRate,
  d.ValidFrom,
  d.ValidTo
from
  [db-au-stage].dbo.corp_tblNewPolDiscRates_nz d


GO
