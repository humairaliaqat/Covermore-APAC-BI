USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblOutlet_ProductPlanTier_aucm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblOutlet_ProductPlanTier_aucm](
	[ID] [int] NOT NULL,
	[OutletProductPlanID] [int] NOT NULL,
	[PlanProductPricinTierID] [int] NOT NULL
) ON [PRIMARY]
GO
