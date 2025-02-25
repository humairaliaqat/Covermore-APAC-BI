USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penQuoteSummaryBot_20240422]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penQuoteSummaryBot_20240422](
	[QuoteDate] [date] NULL,
	[QuoteSource] [int] NOT NULL,
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[OutletAlphaKey] [nvarchar](50) NULL,
	[StoreCode] [varchar](10) NULL,
	[UserKey] [varchar](41) NULL,
	[CRMUserKey] [varchar](41) NULL,
	[SaveStep] [int] NULL,
	[CurrencyCode] [varchar](3) NULL,
	[Area] [nvarchar](100) NULL,
	[Destination] [nvarchar](max) NULL,
	[PurchasePath] [nvarchar](50) NULL,
	[ProductKey] [nvarchar](243) NULL,
	[ProductCode] [nvarchar](50) NULL,
	[ProductName] [nvarchar](60) NULL,
	[PlanCode] [nvarchar](50) NULL,
	[PlanName] [nvarchar](50) NULL,
	[PlanType] [nvarchar](50) NULL,
	[MaxDuration] [int] NULL,
	[Duration] [int] NULL,
	[LeadTime] [int] NULL,
	[Excess] [money] NULL,
	[CompetitorName] [nvarchar](50) NULL,
	[CompetitorGap] [numeric](28, 8) NULL,
	[PrimaryCustomerAge] [int] NULL,
	[PrimaryCustomerSuburb] [nvarchar](50) NULL,
	[PrimaryCustomerState] [nvarchar](100) NULL,
	[YoungestAge] [int] NULL,
	[OldestAge] [int] NULL,
	[NumberOfChildren] [int] NULL,
	[NumberOfAdults] [int] NULL,
	[NumberOfPersons] [int] NULL,
	[QuotedPrice] [numeric](38, 4) NULL,
	[QuoteSessionCount] [int] NULL,
	[QuoteCount] [int] NULL,
	[QuoteWithPriceCount] [int] NULL,
	[SavedQuoteCount] [int] NULL,
	[ConvertedCount] [int] NULL,
	[ExpoQuoteCount] [int] NULL,
	[AgentSpecialQuoteCount] [int] NULL,
	[PromoQuoteCount] [int] NULL,
	[UpsellQuoteCount] [int] NULL,
	[PriceBeatQuoteCount] [int] NULL,
	[QuoteRenewalCount] [int] NULL,
	[CancellationQuoteCount] [int] NULL,
	[LuggageQuoteCount] [int] NULL,
	[MotorcycleQuoteCount] [int] NULL,
	[WinterQuoteCount] [int] NULL,
	[EMCQuoteCount] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
