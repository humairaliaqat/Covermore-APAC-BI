USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vProductPlan]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vProductPlan]
as
select distinct
    CountryKey,
    PlanDescDisplay,
    TripType,
    ProductCodeDisplay,
    PlanCode
from ProductPlan
GO
