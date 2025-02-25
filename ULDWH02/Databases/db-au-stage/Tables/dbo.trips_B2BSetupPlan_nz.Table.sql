USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_B2BSetupPlan_nz]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_B2BSetupPlan_nz](
	[PlanID] [int] NOT NULL,
	[ProductID] [int] NULL,
	[PlanCode] [varchar](10) NULL,
	[PlanDesc] [varchar](50) NULL,
	[PlanDest] [varchar](100) NULL,
	[Description] [varchar](50) NULL,
	[afsl] [varchar](1) NULL,
	[tvlins_id] [int] NULL,
	[PLANTYPE] [char](1) NOT NULL,
	[LinkedPlanId] [int] NULL
) ON [PRIMARY]
GO
