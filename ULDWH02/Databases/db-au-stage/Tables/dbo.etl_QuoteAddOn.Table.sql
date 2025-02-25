USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_QuoteAddOn]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_QuoteAddOn](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[QuoteCountryKey] [varchar](41) NULL,
	[QuoteID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[QuoteAddOnID] [int] NOT NULL,
	[AddOnName] [varchar](50) NULL,
	[AddOnGroup] [varchar](50) NULL,
	[AddOnItem] [varchar](500) NULL,
	[PremiumIncrease] [numeric](10, 4) NULL,
	[CoverIncrease] [numeric](10, 4) NULL,
	[CoverIsPercentage] [bit] NULL,
	[IsRateCardBased] [bit] NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]
GO
