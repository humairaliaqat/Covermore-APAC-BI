USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblAddOnCxRCPricingTier_uscm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblAddOnCxRCPricingTier_uscm](
	[ID] [int] NOT NULL,
	[AddOnID] [int] NOT NULL,
	[PlanProductPricingTierID] [int] NOT NULL,
	[CxAdjustmentSetID] [int] NOT NULL,
	[CxAdditionalAdjustmentSetID] [int] NULL
) ON [PRIMARY]
GO
