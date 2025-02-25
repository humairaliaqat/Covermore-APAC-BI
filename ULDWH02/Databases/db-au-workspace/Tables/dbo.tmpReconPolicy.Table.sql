USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmpReconPolicy]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpReconPolicy](
	[ID] [int] NULL,
	[GroupID] [int] NULL,
	[ComponentID] [int] NULL,
	[GrossPremiumAfterDiscount] [numeric](19, 4) NULL,
	[CommissionAfterDiscount] [numeric](19, 4) NULL,
	[GrossAdminFeeAfterDiscount] [numeric](19, 4) NULL,
	[GrossPremiumBeforeDiscount] [numeric](19, 4) NULL,
	[BasePremium] [money] NULL,
	[AdjustedNet] [money] NULL,
	[Commission] [money] NULL,
	[CommissionRate] [numeric](10, 9) NULL,
	[Discount] [money] NULL,
	[DiscountRate] [numeric](12, 9) NULL,
	[BaseAdminFee] [money] NULL,
	[GrossAdminFee] [money] NULL,
	[IsPOSDiscount] [bit] NULL,
	[PolicyTransactionID] [int] NULL,
	[PolicyID] [int] NULL,
	[PolicyNumber] [varchar](25) NULL,
	[CountryKey] [varchar](50) NULL,
	[CompanyKey] [varchar](50) NULL
) ON [PRIMARY]
GO
