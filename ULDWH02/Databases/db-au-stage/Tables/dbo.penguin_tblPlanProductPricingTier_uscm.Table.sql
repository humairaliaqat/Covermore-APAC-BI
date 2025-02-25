USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPlanProductPricingTier_uscm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPlanProductPricingTier_uscm](
	[ID] [int] NOT NULL,
	[ProductPricingTierID] [int] NOT NULL,
	[UniquePlanID] [int] NOT NULL,
	[PlanID] [int] NOT NULL,
	[PlanAdjustmentID] [int] NOT NULL,
	[AddionalAdjSetID] [int] NULL
) ON [PRIMARY]
GO
