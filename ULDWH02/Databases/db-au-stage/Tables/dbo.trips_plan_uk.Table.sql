USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_plan_uk]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_plan_uk](
	[PlanID] [int] NOT NULL,
	[ProductID] [int] NULL,
	[PlanCode] [nvarchar](10) NULL,
	[PlanDesc] [nvarchar](50) NULL
) ON [PRIMARY]
GO
