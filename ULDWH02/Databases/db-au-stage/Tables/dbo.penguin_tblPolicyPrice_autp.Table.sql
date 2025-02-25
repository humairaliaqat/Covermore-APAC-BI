USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPolicyPrice_autp]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPolicyPrice_autp](
	[ID] [int] NOT NULL,
	[GroupID] [int] NOT NULL,
	[ComponentID] [int] NOT NULL,
	[GrossPremium] [money] NULL,
	[BasePremium] [money] NOT NULL,
	[AdjustedNet] [money] NOT NULL,
	[Commission] [money] NOT NULL,
	[CommissionRate] [numeric](10, 9) NULL,
	[Discount] [money] NOT NULL,
	[DiscountRate] [numeric](12, 9) NULL,
	[BaseAdminFee] [money] NULL,
	[GrossAdminFee] [money] NULL,
	[IsPOSDiscount] [bit] NULL
) ON [PRIMARY]
GO
