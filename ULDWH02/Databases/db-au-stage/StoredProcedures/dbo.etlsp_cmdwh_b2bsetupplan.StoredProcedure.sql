USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_b2bsetupplan]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_b2bsetupplan]
as

SET NOCOUNT ON


if object_id('[db-au-cmdwh].dbo.B2BSetupPlan') is null
begin
    create table [db-au-cmdwh].dbo.B2BSetupPlan
    (
        CountryKey varchar(2) NOT NULL,
        PlanID int NULL,
        ProductID int NULL,
        PlanCode varchar(10) NULL,
        PlanDesc varchar(50) NULL,
        PlanDest varchar(100) NULL,
        Description varchar(50) NULL,
        AFSL varchar(1) NULL,
        TVLINS_ID int NULL,
        PlanType varchar(1) NULL,
        LinkedPlanID int NULL
    )

    if exists(select name from sys.indexes where name = 'idx_B2BSetupPlan_CountryKey')
        drop index idx_B2BSetupPlan_CountryKey on B2BSetupPlan.CountryKey

    if exists(select name from sys.indexes where name = 'idx_B2BSetupPlan_PlanID')
        drop index idx_B2BSetupPlan_AgencyKey on B2BSetupPlan.PlanID

    if exists(select name from sys.indexes where name = 'idx_B2BSetupPlan_ProductID')
        drop index idx_B2BSetupPlan_AgeLoadingID on B2BSetupPlan.ProductID

    create index idx_B2BSetupPlan_CountryKey on [db-au-cmdwh].dbo.B2BSetupPlan(CountryKey)
    create index idx_B2BSetupPlan_PlanID on [db-au-cmdwh].dbo.B2BSetupPlan(PlanID)
    create index idx_B2BSetupPlan_ProductID on [db-au-cmdwh].dbo.B2BSetupPlan(ProductID)
end
else truncate table [db-au-cmdwh].dbo.B2BSetupPlan





insert into [db-au-cmdwh].dbo.B2BSetupPlan with (tablock)
(
        CountryKey,
        PlanID,
        ProductID,
        PlanCode,
        PlanDesc,
        PlanDest,
        Description,
        AFSL,
        TVLINS_ID,
        PlanType,
        LinkedPlanID
)
select
    'AU' as CountryKey,
    convert(int,b.PlanID) as PlanID,
    convert(int,b.ProductID) as ProductID,
    convert(varchar(10),b.PlanCode) as PlanCode,
    convert(varchar(50),b.PlanDesc) as PlanDesc,
    convert(varchar(100),b.PlanDest) as PlanDest,
    convert(varchar(50),b.Description) as [Description],
    convert(varchar(1),b.AFSL) as AFSL,
    convert(int,b.TVLINS_ID) as TVLINS_ID,
    convert(varchar(1),b.PlanType) as PlanType,
    convert(int,b.LinkedPlanID) as LinkedPlanID
from
    [db-au-stage].dbo.trips_b2bsetupplan_au b

union all

select
    'NZ' as CountryKey,
    convert(int,b.PlanID) as PlanID,
    convert(int,b.ProductID) as ProductID,
    convert(varchar(10),b.PlanCode) as PlanCode,
    convert(varchar(50),b.PlanDesc) as PlanDesc,
    convert(varchar(100),b.PlanDest) as PlanDest,
    convert(varchar(50),b.Description) as [Description],
    convert(varchar(1),b.AFSL) as AFSL,
    convert(int,b.TVLINS_ID) as TVLINS_ID,
    convert(varchar(1),null) as PlanType,
    convert(int,null) as LinkedPlanID
from
    [db-au-stage].dbo.trips_b2bsetupplan_nz b

union all

select
    'UK' as CountryKey,
    convert(int,b.PlanID) as PlanID,
    convert(int,b.ProductID) as ProductID,
    convert(varchar(10),b.PlanCode) as PlanCode,
    convert(varchar(50),b.PlanDesc) as PlanDesc,
    convert(varchar(100),null) as PlanDest,
    convert(varchar(50),null) as [Description],
    convert(varchar(1),null) as AFSL,
    convert(int,null) as TVLINS_ID,
    convert(varchar(1),null) as PlanType,
    convert(int,null) as LinkedPlanID
from
    [db-au-stage].dbo.trips_b2bsetupplan_uk b




GO
