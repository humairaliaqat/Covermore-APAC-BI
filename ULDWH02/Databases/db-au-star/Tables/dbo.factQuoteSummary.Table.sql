USE [db-au-star]
GO
/****** Object:  Table [dbo].[factQuoteSummary]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factQuoteSummary](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[DateSK] [int] NOT NULL,
	[DomainSK] [int] NOT NULL,
	[OutletSK] [int] NOT NULL,
	[ConsultantSK] [int] NOT NULL,
	[AreaSK] [int] NOT NULL,
	[DestinationSK] [int] NOT NULL,
	[DurationSK] [int] NOT NULL,
	[AgeBandSK] [int] NOT NULL,
	[ProductSK] [int] NOT NULL,
	[QuoteSessionCount] [int] NOT NULL,
	[QuoteCount] [int] NOT NULL,
	[QuoteWithPriceCount] [int] NOT NULL,
	[SavedQuoteCount] [int] NOT NULL,
	[ConvertedCount] [int] NOT NULL,
	[ExpoQuoteCount] [int] NOT NULL,
	[AgentSpecialQuoteCount] [int] NOT NULL,
	[PromoQuoteCount] [int] NOT NULL,
	[UpsellQuoteCount] [int] NOT NULL,
	[PriceBeatQuoteCount] [int] NOT NULL,
	[QuoteRenewalCount] [int] NOT NULL,
	[CancellationQuoteCount] [int] NOT NULL,
	[LuggageQuoteCount] [int] NOT NULL,
	[MotorcycleQuoteCount] [int] NOT NULL,
	[WinterQuoteCount] [int] NOT NULL,
	[EMCQuoteCount] [int] NOT NULL,
	[LoadDate] [datetime] NOT NULL,
	[LoadID] [int] NOT NULL,
	[updateDate] [datetime] NULL,
	[updateID] [int] NULL,
	[LeadTime] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_factQuoteSummary_Update_BIRowID]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE CLUSTERED INDEX [idx_factQuoteSummary_Update_BIRowID] ON [dbo].[factQuoteSummary]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO
/****** Object:  Index [idx_factQuoteSummary_Update_AgeBandSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factQuoteSummary_Update_AgeBandSK] ON [dbo].[factQuoteSummary]
(
	[AgeBandSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO
/****** Object:  Index [idx_factQuoteSummary_Update_AreaSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factQuoteSummary_Update_AreaSK] ON [dbo].[factQuoteSummary]
(
	[AreaSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO
/****** Object:  Index [idx_factQuoteSummary_Update_ConsultantSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factQuoteSummary_Update_ConsultantSK] ON [dbo].[factQuoteSummary]
(
	[ConsultantSK] ASC
)
INCLUDE([DateSK],[OutletSK]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO
/****** Object:  Index [idx_factQuoteSummary_Update_DateSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factQuoteSummary_Update_DateSK] ON [dbo].[factQuoteSummary]
(
	[DateSK] ASC,
	[OutletSK] ASC
)
INCLUDE([DomainSK],[QuoteCount],[ConsultantSK],[AreaSK],[DestinationSK],[DurationSK],[AgeBandSK],[ProductSK],[QuoteSessionCount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO
/****** Object:  Index [idx_factQuoteSummary_Update_DestinationSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factQuoteSummary_Update_DestinationSK] ON [dbo].[factQuoteSummary]
(
	[DestinationSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO
/****** Object:  Index [idx_factQuoteSummary_Update_DomainSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factQuoteSummary_Update_DomainSK] ON [dbo].[factQuoteSummary]
(
	[DomainSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO
/****** Object:  Index [idx_factQuoteSummary_Update_DurationSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factQuoteSummary_Update_DurationSK] ON [dbo].[factQuoteSummary]
(
	[DurationSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO
/****** Object:  Index [idx_factQuoteSummary_Update_OutletSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factQuoteSummary_Update_OutletSK] ON [dbo].[factQuoteSummary]
(
	[OutletSK] ASC,
	[DateSK] ASC
)
INCLUDE([QuoteCount],[ConsultantSK],[AgeBandSK],[QuoteSessionCount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO
/****** Object:  Index [idx_factQuoteSummary_Update_ProductSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factQuoteSummary_Update_ProductSK] ON [dbo].[factQuoteSummary]
(
	[ProductSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO
ALTER TABLE [dbo].[factQuoteSummary] ADD  DEFAULT ((-1)) FOR [LeadTime]
GO
