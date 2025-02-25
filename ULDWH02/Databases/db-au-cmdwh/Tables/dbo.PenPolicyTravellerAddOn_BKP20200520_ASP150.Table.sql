USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[PenPolicyTravellerAddOn_BKP20200520_ASP150]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PenPolicyTravellerAddOn_BKP20200520_ASP150](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[PolicyTravellerAddOnKey] [varchar](41) NULL,
	[PolicyTravellerTransactionKey] [varchar](41) NULL,
	[AddOnKey] [varchar](33) NULL,
	[PolicyTravellerAddOnID] [int] NOT NULL,
	[PolicyTravellerTransactionID] [int] NOT NULL,
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
	[isRateCardBased] [bit] NOT NULL
) ON [PRIMARY]
GO
