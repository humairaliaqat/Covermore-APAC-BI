USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblAddOnValuePricingTier_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblAddOnValuePricingTier_ukcm](
	[ID] [int] NOT NULL,
	[AddOnID] [int] NOT NULL,
	[PlanProductPricingTierID] [int] NOT NULL,
	[AddOnValueAdjustmentSetID] [int] NOT NULL,
	[AddOnValueAdditionalAdjustmentSetID] [int] NULL
) ON [PRIMARY]
GO
