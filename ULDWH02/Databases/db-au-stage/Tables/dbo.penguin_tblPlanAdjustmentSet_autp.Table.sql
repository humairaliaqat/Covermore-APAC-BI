USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPlanAdjustmentSet_autp]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPlanAdjustmentSet_autp](
	[AdjustmentSetID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[PlanRateCardSetID] [int] NOT NULL
) ON [PRIMARY]
GO
