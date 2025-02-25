USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penPolicyAddOn]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPolicyAddOn](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[PolicyAddOnKey] [varchar](41) NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[AddOnKey] [varchar](33) NULL,
	[PolicyAddOnID] [int] NOT NULL,
	[PolicyTransactionID] [int] NOT NULL,
	[AddOnID] [int] NOT NULL,
	[AddonCode] [nvarchar](50) NULL,
	[AddonName] [nvarchar](50) NULL,
	[DisplayName] [nvarchar](100) NULL,
	[AddOnValueID] [int] NOT NULL,
	[AddonValueCode] [nvarchar](10) NULL,
	[AddonValueDesc] [nvarchar](50) NULL,
	[AddonValuePremiumIncrease] [numeric](18, 5) NULL,
	[CoverIncrease] [money] NOT NULL,
	[AddOnGroup] [nvarchar](50) NULL,
	[AddOnText] [nvarchar](500) NULL,
	[isRateCardBased] [bit] NOT NULL,
	[DomainID] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyAddOn_PolicyTransactionKey]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_penPolicyAddOn_PolicyTransactionKey] ON [dbo].[penPolicyAddOn]
(
	[PolicyTransactionKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyAddOn_Pricing]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyAddOn_Pricing] ON [dbo].[penPolicyAddOn]
(
	[PolicyTransactionKey] ASC
)
INCLUDE([AddOnGroup],[CountryKey],[CompanyKey],[PolicyAddOnKey],[PolicyAddOnID],[CoverIncrease],[AddOnText]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
