USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblProductPricingTierBundle_uscm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblProductPricingTierBundle_uscm](
	[ProductPriceBundleID] [int] NOT NULL,
	[CommissionTierID] [int] NULL,
	[ProductVersionID] [int] NOT NULL
) ON [PRIMARY]
GO
