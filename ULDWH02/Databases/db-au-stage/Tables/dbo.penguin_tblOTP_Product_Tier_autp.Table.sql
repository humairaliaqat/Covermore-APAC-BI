USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblOTP_Product_Tier_autp]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblOTP_Product_Tier_autp](
	[ID] [int] NOT NULL,
	[OTP_Product_BundleID] [int] NOT NULL,
	[ProductPricingTierID] [int] NOT NULL,
	[VolumeCommission] [numeric](18, 9) NOT NULL,
	[Discount] [numeric](18, 9) NOT NULL,
	[IsDefault] [bit] NOT NULL,
	[Name] [nvarchar](200) NOT NULL
) ON [PRIMARY]
GO
