USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vEnterpriseClaimPortfolio]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vEnterpriseClaimPortfolio] as
select --top 100 
    *
from
    [db-au-workspace]..live_dashboard_portfolio




GO
