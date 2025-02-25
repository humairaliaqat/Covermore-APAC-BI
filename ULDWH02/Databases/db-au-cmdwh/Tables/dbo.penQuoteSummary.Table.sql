USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penQuoteSummary]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penQuoteSummary](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[QuoteDate] [datetime] NOT NULL,
	[QuoteSource] [int] NOT NULL,
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[OutletAlphaKey] [nvarchar](50) NULL,
	[StoreCode] [varchar](10) NULL,
	[UserKey] [varchar](41) NULL,
	[CRMUserKey] [varchar](41) NULL,
	[SaveStep] [int] NULL,
	[CurrencyCode] [varchar](3) NULL,
	[Area] [nvarchar](200) NULL,
	[Destination] [nvarchar](200) NULL,
	[PurchasePath] [nvarchar](100) NULL,
	[ProductKey] [nvarchar](200) NULL,
	[ProductCode] [nvarchar](50) NULL,
	[ProductName] [nvarchar](100) NULL,
	[PlanCode] [nvarchar](50) NULL,
	[PlanName] [nvarchar](100) NULL,
	[PlanType] [nvarchar](100) NULL,
	[MaxDuration] [int] NULL,
	[Duration] [int] NULL,
	[Excess] [money] NULL,
	[CompetitorName] [nvarchar](200) NULL,
	[CompetitorGap] [int] NULL,
	[PrimaryCustomerAge] [int] NULL,
	[PrimaryCustomerSuburb] [nvarchar](200) NULL,
	[PrimaryCustomerState] [nvarchar](200) NULL,
	[YoungestAge] [int] NULL,
	[OldestAge] [int] NULL,
	[NumberOfChildren] [int] NULL,
	[NumberOfAdults] [int] NULL,
	[NumberOfPersons] [int] NULL,
	[QuotedPrice] [money] NULL,
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
	[EMCQuoteCount] [int] NULL,
	[CreateBatchID] [int] NULL,
	[LeadTime] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penQuoteSummary_Update_BIRowID]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penQuoteSummary_Update_BIRowID] ON [dbo].[penQuoteSummary]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO
/****** Object:  Index [idx_penQuoteSummary_QuoteDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penQuoteSummary_QuoteDate] ON [dbo].[penQuoteSummary]
(
	[QuoteDate] ASC
)
INCLUDE([QuoteSessionCount],[QuoteCount],[QuoteWithPriceCount],[SavedQuoteCount],[ConvertedCount],[ExpoQuoteCount],[AgentSpecialQuoteCount],[PromoQuoteCount],[UpsellQuoteCount],[PriceBeatQuoteCount],[QuoteRenewalCount],[CancellationQuoteCount],[LuggageQuoteCount],[MotorcycleQuoteCount],[WinterQuoteCount],[EMCQuoteCount],[CountryKey],[OutletAlphaKey],[UserKey],[CRMUserKey],[Area],[Destination],[Duration],[LeadTime],[PrimaryCustomerAge],[ProductKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penQuoteSummary_Update_QuoteDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penQuoteSummary_Update_QuoteDate] ON [dbo].[penQuoteSummary]
(
	[QuoteDate] ASC
)
INCLUDE([QuoteSessionCount],[QuoteCount],[QuoteWithPriceCount],[SavedQuoteCount],[ConvertedCount],[ExpoQuoteCount],[AgentSpecialQuoteCount],[PromoQuoteCount],[UpsellQuoteCount],[PriceBeatQuoteCount],[QuoteRenewalCount],[CancellationQuoteCount],[LuggageQuoteCount],[MotorcycleQuoteCount],[WinterQuoteCount],[EMCQuoteCount],[CountryKey],[OutletAlphaKey],[UserKey],[CRMUserKey],[Area],[Destination],[Duration],[PrimaryCustomerAge],[ProductKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO
