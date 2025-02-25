USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penQuoteSummaryCBA]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penQuoteSummaryCBA](
	[QuoteDate] [varchar](max) NULL,
	[QuoteSource] [varchar](max) NULL,
	[CountryKey] [varchar](max) NULL,
	[CompanyKey] [varchar](max) NULL,
	[OutletAlphaKey] [varchar](max) NULL,
	[StoreCode] [varchar](max) NULL,
	[UserKey] [varchar](max) NULL,
	[CRMUserKey] [varchar](max) NULL,
	[SaveStep] [varchar](max) NULL,
	[CurrencyCode] [varchar](max) NULL,
	[Area] [varchar](max) NULL,
	[Destination] [varchar](max) NULL,
	[PurchasePath] [varchar](max) NULL,
	[ProductKey] [varchar](max) NULL,
	[ProductCode] [varchar](max) NULL,
	[ProductName] [varchar](max) NULL,
	[PlanCode] [varchar](max) NULL,
	[PlanName] [varchar](max) NULL,
	[PlanType] [varchar](max) NULL,
	[MaxDuration] [varchar](max) NULL,
	[Duration] [varchar](max) NULL,
	[LeadTime] [varchar](max) NULL,
	[Excess] [varchar](max) NULL,
	[CompetitorName] [varchar](max) NULL,
	[CompetitorGap] [varchar](max) NULL,
	[PrimaryCustomerAge] [varchar](max) NULL,
	[PrimaryCustomerSuburb] [varchar](max) NULL,
	[PrimaryCustomerState] [varchar](max) NULL,
	[YoungestAge] [varchar](max) NULL,
	[OldestAge] [varchar](max) NULL,
	[NumberOfChildren] [varchar](max) NULL,
	[NumberOfAdults] [varchar](max) NULL,
	[NumberOfPersons] [varchar](max) NULL,
	[QuotedPrice] [varchar](max) NULL,
	[QuoteSessionCount] [varchar](max) NULL,
	[QuoteCount] [varchar](max) NULL,
	[QuoteWithPriceCount] [varchar](max) NULL,
	[SavedQuoteCount] [varchar](max) NULL,
	[ConvertedCount] [varchar](max) NULL,
	[ExpoQuoteCount] [varchar](max) NULL,
	[AgentSpecialQuoteCount] [varchar](max) NULL,
	[PromoQuoteCount] [varchar](max) NULL,
	[UpsellQuoteCount] [varchar](max) NULL,
	[PriceBeatQuoteCount] [varchar](max) NULL,
	[QuoteRenewalCount] [varchar](max) NULL,
	[CancellationQuoteCount] [varchar](max) NULL,
	[LuggageQuoteCount] [varchar](max) NULL,
	[MotorcycleQuoteCount] [varchar](max) NULL,
	[WinterQuoteCount] [varchar](max) NULL,
	[EMCQuoteCount] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
