USE [db-au-star]
GO
/****** Object:  Table [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[DateSK] [int] NOT NULL,
	[DomainSK] [int] NOT NULL,
	[OutletSK] [int] NOT NULL,
	[ConsultantSK] [int] NOT NULL,
	[AreaSK] [int] NOT NULL,
	[DestinationSK] [int] NOT NULL,
	[DurationSK] [int] NOT NULL,
	[LeadTime] [int] NOT NULL,
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
	[updateID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_factQuoteSummaryBotCBA_BIRowID]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE CLUSTERED INDEX [idx_factQuoteSummaryBotCBA_BIRowID] ON [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_factQuoteSummaryBotCBA_AgeBandSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factQuoteSummaryBotCBA_AgeBandSK] ON [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119]
(
	[AgeBandSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_factQuoteSummaryBotCBA_AreaSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factQuoteSummaryBotCBA_AreaSK] ON [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119]
(
	[AreaSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_factQuoteSummaryBotCBA_ConsultantSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factQuoteSummaryBotCBA_ConsultantSK] ON [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119]
(
	[ConsultantSK] ASC
)
INCLUDE([OutletSK],[DateSK]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_factQuoteSummaryBotCBA_DateSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factQuoteSummaryBotCBA_DateSK] ON [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119]
(
	[DateSK] ASC
)
INCLUDE([DomainSK]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_factQuoteSummaryBotCBA_DestinationSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factQuoteSummaryBotCBA_DestinationSK] ON [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119]
(
	[DestinationSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_factQuoteSummaryBotCBA_DomainSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factQuoteSummaryBotCBA_DomainSK] ON [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119]
(
	[DomainSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_factQuoteSummaryBotCBA_DurationSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factQuoteSummaryBotCBA_DurationSK] ON [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119]
(
	[DurationSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_factQuoteSummaryBotCBA_LeadTime]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factQuoteSummaryBotCBA_LeadTime] ON [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119]
(
	[LeadTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_factQuoteSummaryBotCBA_OutletSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factQuoteSummaryBotCBA_OutletSK] ON [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119]
(
	[OutletSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_factQuoteSummaryBotCBA_ProductSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factQuoteSummaryBotCBA_ProductSK] ON [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119]
(
	[ProductSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119] ADD  DEFAULT ((-1)) FOR [LeadTime]
GO
ALTER TABLE [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119] ADD  DEFAULT ((0)) FOR [QuoteSessionCount]
GO
ALTER TABLE [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119] ADD  DEFAULT ((0)) FOR [QuoteCount]
GO
ALTER TABLE [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119] ADD  DEFAULT ((0)) FOR [QuoteWithPriceCount]
GO
ALTER TABLE [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119] ADD  DEFAULT ((0)) FOR [SavedQuoteCount]
GO
ALTER TABLE [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119] ADD  DEFAULT ((0)) FOR [ConvertedCount]
GO
ALTER TABLE [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119] ADD  DEFAULT ((0)) FOR [ExpoQuoteCount]
GO
ALTER TABLE [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119] ADD  DEFAULT ((0)) FOR [AgentSpecialQuoteCount]
GO
ALTER TABLE [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119] ADD  DEFAULT ((0)) FOR [PromoQuoteCount]
GO
ALTER TABLE [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119] ADD  DEFAULT ((0)) FOR [UpsellQuoteCount]
GO
ALTER TABLE [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119] ADD  DEFAULT ((0)) FOR [PriceBeatQuoteCount]
GO
ALTER TABLE [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119] ADD  DEFAULT ((0)) FOR [QuoteRenewalCount]
GO
ALTER TABLE [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119] ADD  DEFAULT ((0)) FOR [CancellationQuoteCount]
GO
ALTER TABLE [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119] ADD  DEFAULT ((0)) FOR [LuggageQuoteCount]
GO
ALTER TABLE [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119] ADD  DEFAULT ((0)) FOR [MotorcycleQuoteCount]
GO
ALTER TABLE [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119] ADD  DEFAULT ((0)) FOR [WinterQuoteCount]
GO
ALTER TABLE [dbo].[factQuoteSummaryBotCBA_RENAMED_ON_20191119] ADD  DEFAULT ((0)) FOR [EMCQuoteCount]
GO
