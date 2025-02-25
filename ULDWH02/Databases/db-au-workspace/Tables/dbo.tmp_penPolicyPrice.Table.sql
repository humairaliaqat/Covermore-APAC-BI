USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_penPolicyPrice]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_penPolicyPrice](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[PolicyPriceKey] [varchar](41) NOT NULL,
	[GroupID] [int] NOT NULL,
	[ComponentID] [int] NOT NULL,
	[GrossPremium] [money] NULL,
	[BasePremium] [money] NOT NULL,
	[AdjustedNet] [money] NOT NULL,
	[Commission] [money] NOT NULL,
	[CommissionRate] [numeric](15, 9) NULL,
	[Discount] [money] NOT NULL,
	[DiscountRate] [numeric](15, 9) NULL,
	[BaseAdminFee] [money] NULL,
	[GrossAdminFee] [money] NULL,
	[isPOSDiscount] [bit] NULL,
	[PolicyTransactionID] [int] NULL,
	[ID] [int] NULL
) ON [PRIMARY]
GO
