USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_corpCommRate_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_corpCommRate_rollup]
as

SET NOCOUNT ON


/*************************************************************/
--combine Commission Rates from AU, NZ into one table
/*************************************************************/
if object_id('[db-au-stage].dbo.etl_corpCommRate') is not null drop table [db-au-stage].dbo.etl_corpCommRate

select
  'AU' as CountryKey,
  left('AU-' + cast(c.ID as varchar),10) as CommRateKey,
  c.ID as CommRateID,
  c.AgtGroup as AgencyGroupCode,
  c.GrpDesc as AgencyGroupName,
  c.CMCommRate as CMCommissionRate,
  c.AgtCommRate as AgentCommissionRate,
  c.ValidFrom,
  c.ValidTo,
  c.OverrideCommRate as OverrideCommissionRate
into [db-au-stage].dbo.etl_corpCommRate
from
  [db-au-stage].dbo.corp_tblCommRates_au c

union all

select
  'NZ' as CountryKey,
  left('NZ-' + cast(c.ID as varchar),10) as CommRateKey,
  c.ID as CommRateID,
  c.AgtGroup as AgencyGroupCode,
  c.GrpDesc as AgencyGroupName,
  c.CMCommRate as CMCommissionRate,
  c.AgtCommRate as AgentCommissionRate,
  c.ValidFrom,
  c.ValidTo,
  c.OverrideCommRate as OverrideCommissionRate
from
  [db-au-stage].dbo.corp_tblCommRates_nz c


if object_id('[db-au-cmdwh].dbo.corpCommRate') is null
begin
    create table [db-au-cmdwh].dbo.corpCommRate
    (
        [CountryKey] [varchar](2) NOT NULL,
        [CommRateKey] [varchar](10) NULL,
        [CommRateID] [smallint] NOT NULL,
        [AgencyGroupCode] [varchar](2) NULL,
        [AgencyGroupName] [varchar](10) NULL,
        [CMCommissionRate] [float] NULL,
        [AgentCommissionRate] [float] NULL,
        [ValidFrom] [datetime] NULL,
        [ValidTo] [datetime] NULL,
        [OverrideCommissionRate] [float] NULL
    )
    if exists(select name from sys.indexes where name = 'idx_corpCommRate_CountryKey')
    drop index idx_corpCommRate_CountryKey on corpCommRate.CountryKey

    if exists(select name from sys.indexes where name = 'idx_corpCommRate_CommRateKey')
    drop index idx_corpCommRate_CommRateKey on corpCommRate.CommRateKey

    create index idx_corpCommRate_CountryKey on [db-au-cmdwh].dbo.corpCommRate(CountryKey)
    create index idx_corpCommRate_CommRateKey on [db-au-cmdwh].dbo.corpCommRate(CommRateKey)
end
else
    truncate table [db-au-cmdwh].dbo.corpCommRate



/*************************************************************/
-- Transfer data from [db-au-stage].dbo.etl_corpCommRate to [db-au-cmdwh].dbo.corpCommRate
/*************************************************************/

insert into [db-au-cmdwh].dbo.corpCommRate with (tablock)
(
    CountryKey,
    CommRateKey,
    CommRateID,
    AgencyGroupCode,
    AgencyGroupName,
    CMCommissionRate,
    AgentCommissionRate,
    ValidFrom,
    ValidTo,
    OverrideCommissionRate
)
select
    CountryKey,
    CommRateKey,
    CommRateID,
    AgencyGroupCode,
    AgencyGroupName,
    CMCommissionRate,
    AgentCommissionRate,
    ValidFrom,
    ValidTo,
    OverrideCommissionRate
from [db-au-stage].dbo.etl_corpCommRate



GO
