USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_AnalyticsSessions2]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_AnalyticsSessions2](
	[AnalyticsSessionID] [bigint] NULL,
	[CampaignSessionID] [bigint] NULL,
	[TravellerID] [bigint] NULL,
	[ImpressionID] [bigint] NULL,
	[BusinessUnitID] [smallint] NULL,
	[ChannelID] [smallint] NULL,
	[TransactionType] [char](1) NULL,
	[PathType] [char](1) NULL,
	[TransactionTime] [datetime] NULL,
	[CampaignID] [smallint] NULL,
	[ConstructID] [smallint] NULL,
	[OfferID] [smallint] NULL,
	[ProductID] [smallint] NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[RegionID] [smallint] NULL,
	[DestinationType] [char](1) NULL,
	[DestinationCountryID] [int] NULL,
	[TripType] [char](1) NULL,
	[IsSessionClosed] [bit] NULL,
	[IsOfferPurchased] [bit] NULL,
	[PoliciesPerTrip] [tinyint] NULL,
	[PolicyCurrency] [char](3) NULL,
	[GrossIncludingTax] [numeric](19, 5) NULL,
	[GrossExcludingTax] [numeric](19, 5) NULL,
	[NumAdults] [tinyint] NULL,
	[NumChildren] [tinyint] NULL,
	[TravellerAge] [tinyint] NULL,
	[IsAdult] [bit] NULL,
	[TravellerGender] [char](1) NULL,
	[IsPrimaryTraveller] [bit] NULL,
	[AlphaCode] [varchar](10) NULL,
	[PolicyNumber] [int] NULL,
	[PolicyID] [int] NULL,
	[TripCost] [numeric](8, 2) NULL,
	[MemberId] [varchar](255) NULL,
	[TravelClass] [varchar](255) NULL,
	[PartnerTravelProduct] [varchar](255) NULL,
	[PaymentTypeID] [tinyint] NULL
) ON [PRIMARY]
GO
