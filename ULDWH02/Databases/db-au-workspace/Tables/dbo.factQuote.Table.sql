USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[factQuote]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factQuote](
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
	[HasMTCL] [int] NOT NULL
) ON [PRIMARY]
GO
