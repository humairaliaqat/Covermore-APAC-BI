USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penQuoteAddOn]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penQuoteAddOn](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[QuoteCountryKey] [varchar](41) NULL,
	[CustomerKey] [varchar](41) NULL,
	[QuoteID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[QuoteAddOnID] [int] NOT NULL,
	[AddOnName] [nvarchar](50) NULL,
	[AddOnGroup] [nvarchar](50) NULL,
	[AddOnItem] [nvarchar](500) NULL,
	[PremiumIncrease] [numeric](10, 4) NULL,
	[CoverIncrease] [numeric](10, 4) NULL,
	[CoverIsPercentage] [bit] NULL,
	[IsRateCardBased] [bit] NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penQuoteAddOn_QuoteCountryKey]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penQuoteAddOn_QuoteCountryKey] ON [dbo].[penQuoteAddOn]
(
	[QuoteCountryKey] ASC,
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
