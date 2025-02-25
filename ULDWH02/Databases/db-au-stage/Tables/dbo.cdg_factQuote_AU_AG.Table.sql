USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_factQuote_AU_AG]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_factQuote_AU_AG](
	[FactQuoteID] [int] NOT NULL,
	[SessionID] [int] NOT NULL,
	[RegionID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[CampaignID] [int] NOT NULL,
	[BusinessUnitID] [int] NOT NULL,
	[DestCovermoreCountryListID] [int] NOT NULL,
	[DestISOCountryListID] [int] NOT NULL,
	[DestAirportsListID] [int] NULL,
	[PromoCodeListID] [int] NULL,
	[ChargedCountryID] [int] NULL,
	[QuoteTransactionDateID] [int] NULL,
	[QuoteTransactionTimeID] [int] NULL,
	[TripStartDateID] [int] NULL,
	[TripStartTimeID] [int] NULL,
	[TripEndDateID] [int] NULL,
	[TripEndTimeID] [int] NULL,
	[TotalGrossPremium] [numeric](9, 4) NOT NULL,
	[TotalAdjustedGrossPremium] [numeric](9, 4) NOT NULL,
	[TotalTravelers] [int] NOT NULL,
	[Excess] [int] NOT NULL,
	[IsMultiDestination] [int] NULL,
	[IsMostRecent] [int] NOT NULL,
	[NumAdults] [int] NULL,
	[NumChildren] [int] NULL,
	[NumInfants] [int] NULL,
	[HasCANX] [int] NOT NULL,
	[HasWNTS] [int] NOT NULL,
	[HasCRS] [int] NOT NULL,
	[HasLUGG] [int] NOT NULL,
	[HasRTCR] [int] NOT NULL,
	[CANXCoverageAmount] [numeric](18, 2) NOT NULL,
	[RTCRCoverageAmount] [numeric](18, 2) NOT NULL,
	[MaxPolicies] [int] NOT NULL,
	[ActualPoliciesSold] [int] NOT NULL,
	[DepartureCountryID] [int] NULL,
	[DepartureAirportID] [int] NULL,
	[GroupTypeID] [int] NOT NULL,
	[CurrencyID] [int] NULL,
	[QuoteSourceID] [int] NOT NULL,
	[HasMTCL] [int] NOT NULL,
	[HasADVACT] [int] NOT NULL,
	[HasCANXANY] [int] NOT NULL,
	[HasFPCAP] [int] NOT NULL,
	[HasLUGGDOC] [int] NOT NULL,
	[HasMTCLTWO] [int] NOT NULL,
	[HasNEWFOROLD] [int] NOT NULL,
	[HasSNSPRTS] [int] NOT NULL,
	[HasSNSPRTS2] [int] NOT NULL,
	[HasSSB] [int] NOT NULL,
	[HasINDCOMP] [int] NOT NULL,
	[HasINDMUGG] [int] NOT NULL,
	[HasINDTRVINC] [int] NOT NULL,
	[HasINDCRS] [int] NOT NULL,
	[HasINDGOLF] [int] NOT NULL,
	[HasINDPET] [int] NOT NULL,
	[HasINDCCFRD] [int] NOT NULL,
	[HasINDLAPTOP] [int] NOT NULL,
	[HasINDTRVLN] [int] NOT NULL,
	[HasINDMEDSUB] [int] NOT NULL,
	[HasINDCANX] [int] NOT NULL,
	[HasINDADSPRT] [int] NOT NULL,
	[HasDUTY] [int] NOT NULL,
	[PrimaryTravellerAge] [int] NOT NULL,
	[HasADVACT2] [int] NOT NULL,
	[HasADVACT3] [int] NOT NULL,
	[HasSNSPRTS3] [int] NOT NULL,
	[HasCRS2] [int] NOT NULL,
	[HasAGECBA] [int] NOT NULL,
	[HasELEC] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [<IX_cdg_factQuote_AU_AG_CampaignID_business__Product>]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [<IX_cdg_factQuote_AU_AG_CampaignID_business__Product>] ON [dbo].[cdg_factQuote_AU_AG]
(
	[CampaignID] ASC,
	[BusinessUnitID] ASC,
	[ProductID] ASC
)
INCLUDE([SessionID],[QuoteTransactionDateID],[QuoteTransactionTimeID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [NonClusteredIndex-20241119-222258]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20241119-222258] ON [dbo].[cdg_factQuote_AU_AG]
(
	[SessionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
