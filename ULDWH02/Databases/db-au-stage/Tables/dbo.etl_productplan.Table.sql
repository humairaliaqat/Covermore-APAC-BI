USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_productplan]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_productplan](
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
) ON [PRIMARY]
GO
