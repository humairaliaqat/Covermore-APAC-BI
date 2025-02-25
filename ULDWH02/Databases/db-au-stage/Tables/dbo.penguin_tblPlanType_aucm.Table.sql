USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPlanType_aucm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPlanType_aucm](
	[PlanTypeId] [int] NOT NULL,
	[PlanType] [nvarchar](50) NULL,
	[Active] [bit] NULL,
	[PlanTypeName] [nvarchar](50) NULL
) ON [PRIMARY]
GO
