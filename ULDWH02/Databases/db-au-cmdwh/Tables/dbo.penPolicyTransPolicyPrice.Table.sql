USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penPolicyTransPolicyPrice]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPolicyTransPolicyPrice](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[PolicyAddOnKey] [varchar](41) NULL,
	[BasePremium] [money] NULL,
	[GrossPremium] [money] NULL,
	[Commission] [money] NULL,
	[Discount] [money] NULL,
	[GrossAdminFee] [money] NULL,
	[CommissionRate] [numeric](10, 9) NULL,
	[DiscountRate] [numeric](10, 9) NULL,
	[AdjustedNet] [money] NULL,
	[UnAdjBasePremium] [money] NULL,
	[UnAdjGrossPremium] [money] NULL,
	[UnAdjCommission] [money] NULL,
	[UnAdjDiscount] [money] NULL,
	[UnAdjGrossAdminFee] [money] NULL,
	[UnAdjCommissionRate] [numeric](10, 9) NULL,
	[UnAdjDiscountRate] [numeric](10, 9) NULL,
	[UnAdjAdjustedNet] [money] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyTransPolicyPrice_PolicyTransactionKey]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penPolicyTransPolicyPrice_PolicyTransactionKey] ON [dbo].[penPolicyTransPolicyPrice]
(
	[PolicyTransactionKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyTransPolicyPrice_PolicyAddOnKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyTransPolicyPrice_PolicyAddOnKey] ON [dbo].[penPolicyTransPolicyPrice]
(
	[PolicyAddOnKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
