USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_factQuoteSummaryBotTemp]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_factQuoteSummaryBotTemp](
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
) ON [PRIMARY]
GO
