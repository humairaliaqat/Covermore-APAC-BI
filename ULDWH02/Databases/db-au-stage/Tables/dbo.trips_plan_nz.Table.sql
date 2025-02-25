USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_plan_nz]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_plan_nz](
	[PlanID] [int] NOT NULL,
	[ProductID] [int] NULL,
	[PlanCode] [varchar](10) NULL,
	[PlanDesc] [varchar](50) NULL,
	[PlanDest] [varchar](100) NULL
) ON [PRIMARY]
GO
