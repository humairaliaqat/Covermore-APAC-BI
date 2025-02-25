USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_productplan]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_productplan]
as

SET NOCOUNT ON


--only for AU for now
if object_id('[db-au-stage].dbo.etl_productplan') is not null drop table [db-au-stage].dbo.etl_productplan
select
  'AU' as CountryKey,
  'AU-' + a.PlanCode as PlanKey,
  'AU-' + a.ProductCodeDisplay as ProductKey,
  a.PlanID,
  a.ProductID,
  a.PlanCode,
  a.PlanDesc,
  a.PlanDescDisplay,
  a.TripType,
  a.ProductType,
  a.Area,
  a.PlanType,
  a.LinkedPlanID,
  a.ProductCode,
  a.ProductCodeDisplay,
  a.ProductYear,
  a.PeriodStart,
  a.PeriodEnd
into dbo.etl_productplan
from
(
  select
  pl.PlanID,
  pl.ProductID,
  pl.PlanCode,
  pl.PlanDesc,
  case when pl.PlanCode = 'A2' then 'BUSINESS AGENCY RATE AREA 2'
       when pl.PlanDesc like 'CM %' then right(pl.PlanDesc,len(pl.PlanDesc) - 3)
       when pl.PlanDesc like '% CM %' then replace(pl.PlanDesc,' CM ','')
       else pl.PlanDesc
  end as PlanDescDisplay,
  case when right(pr.ProductCode,1) = 'B' then 'Business'
       when right(pr.ProductCode,1) = 'S' then 'Single'
       when right(pr.ProductCode,1) = 'M' then 'Multi'
       else ''
  end as TripType,
  case when left(pr.ProductCode,2) = 'CT' then 'Travelsure'
       when left(pr.ProductCode,2) = 'CM' then 'Cover-More'
       when left(pr.ProductCode,2) = 'ST' then 'STA'
       when left(pr.ProductCode,2) = 'CO' then 'Options'
       when left(pr.ProductCode,2) = 'CE' then 'Essentials'
       else pr.ProductCode
  end as ProductType,
  case when right(pl.PlanCode,1) = '1' and pl.PlanCode not like '%D%' then 'Area 1'
       when right(pl.PlanCode,1) = '2' and pl.PlanCode not like '%D%'  then 'Area 2'
       when right(pl.PlanCode,1) = '3' and pl.PlanCode not like '%D%'  then 'Area 3'
       when right(pl.PlanCode,1) = '4' and pl.PlanCode not like '%D%'  then 'Area 4'
       when right(pl.PlanCode,1) not in ('1','2','3','4') and pl.PlanCode not like '%D%' then 'Domestic'
       when pl.PlanCode like '%D%' then 'Domestic'
       else pl.PlanCode
  end as Area,
  pl.PlanType,
  pl.LinkedPlanID,
  pr.ProductCode,
  case when pr.ProductCode in ('COS','COM') then 'CMO'
       when pr.ProductCode in ('CES','CEM') then 'CME'
       when pr.ProductCode in ('CTS','CTM') then 'CMT'
       when pr.ProductCode in ('STS','STM') then 'STA'
       when pr.ProductCode = 'CMB' then 'CMB'
       when pr.ProductCode = 'CMS' then 'CMS'
       else pr.ProductCode
  end as ProductCodeDisplay,
  pr.ProductYear,
  pr.PeriodStart,
  pr.PeriodEnd
from
  [db-au-stage].dbo.trips_plan_au pl
  join [db-au-stage].dbo.trips_product_au pr on
    pl.ProductID = pr.ProductID
) a


if object_id('[db-au-cmdwh].dbo.ProductPlan') is null
begin
  create table [db-au-cmdwh].[dbo].[ProductPlan]
  (
    [CountryKey] [varchar](2) NOT NULL,
    [PlanKey] [varchar](13) NULL,
    [ProductKey] [varchar](13) NULL,
    [PlanID] [int] NOT NULL,
    [ProductID] [int] NULL,
    [PlanCode] [varchar](10) NULL,
    [PlanDesc] [varchar](50) NULL,
    [PlanDescDisplay] [varchar](8000) NULL,
    [TripType] [varchar](8) NOT NULL,
    [ProductType] [varchar](10) NULL,
    [Area] [varchar](10) NULL,
    [PlanType] [char](1) NOT NULL,
    [LinkedPlanID] [int] NULL,
    [ProductCode] [varchar](10) NULL,
    [ProductCodeDisplay] [varchar](10) NULL,
    [ProductYear] [varchar](6) NULL,
    [PeriodStart] [datetime] NULL,
    [PeriodEnd] [datetime] NULL
  )
end
else truncate table [db-au-cmdwh].dbo.ProductPlan




insert into [db-au-cmdwh].dbo.ProductPlan with (tablock)
(
    [CountryKey],
    [PlanKey],
    [ProductKey],
    [PlanID],
    [ProductID],
    [PlanCode],
    [PlanDesc],
    [PlanDescDisplay],
    [TripType],
    [ProductType],
    [Area],
    [PlanType],
    [LinkedPlanID],
    [ProductCode],
    [ProductCodeDisplay],
    [ProductYear],
    [PeriodStart],
    [PeriodEnd]
)
select * from [db-au-stage].dbo.etl_productplan




GO
