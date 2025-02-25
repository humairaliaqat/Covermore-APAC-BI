USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[factOffer]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factOffer](
	[FactOfferID] [int] NOT NULL,
	[SessionID] [int] NOT NULL,
	[RegionID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[ConstructID] [int] NOT NULL,
	[CampaignID] [int] NOT NULL,
	[BusinessUnitID] [int] NOT NULL,
	[DestCovermoreCountryListID] [int] NOT NULL,
	[DestISOCountryListID] [int] NOT NULL,
	[DestAirportsListID] [int] NULL,
	[ChargedCountryID] [int] NOT NULL,
	[ImpulseOfferID] [int] NOT NULL,
	[OfferDateID] [int] NOT NULL,
	[OfferTimeID] [int] NOT NULL,
	[TripStartDateID] [int] NULL,
	[TripStartTimeID] [int] NULL,
	[TripEndDateID] [int] NULL,
	[TripEndTimeID] [int] NULL,
	[TripTypeID] [int] NULL,
	[TotalGrossPremium] [numeric](9, 4) NULL,
	[TripCost] [numeric](13, 4) NULL,
	[Excess] [int] NOT NULL,
	[NumAdults] [int] NULL,
	[NumInfants] [int] NULL,
	[NumChildren] [int] NULL,
	[IsMultiDestination] [int] NOT NULL,
	[IsMostRecent] [int] NOT NULL,
	[ConstructOfferDisplayPercent] [numeric](9, 4) NULL,
	[MaxPolicies] [int] NOT NULL,
	[ActualPoliciesSold] [int] NOT NULL,
	[DepartureCountryID] [int] NULL,
	[DepartureAirportID] [int] NULL,
	[GroupTypeID] [int] NOT NULL,
	[CurrencyID] [int] NOT NULL,
	[CultureID] [int] NULL,
	[SelectedImpulseOfferID] [int] NOT NULL,
	[PromoCodeListID] [int] NULL,
	[TravelClassID] [int] NULL
) ON [PRIMARY]
GO
