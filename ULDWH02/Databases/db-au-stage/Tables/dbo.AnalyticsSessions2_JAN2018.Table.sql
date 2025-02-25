USE [db-au-stage]
GO
/****** Object:  Table [dbo].[AnalyticsSessions2_JAN2018]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AnalyticsSessions2_JAN2018](
	[AnalyticsSessionID] [bigint] NOT NULL,
	[CampaignSessionID] [bigint] NOT NULL,
	[TravellerID] [bigint] NOT NULL,
	[ImpressionID] [bigint] NULL,
	[BusinessUnitID] [smallint] NOT NULL,
	[ChannelID] [smallint] NOT NULL,
	[TransactionType] [char](1) NOT NULL,
	[PathType] [char](1) NOT NULL,
	[TransactionTime] [datetime] NULL,
	[CampaignID] [smallint] NOT NULL,
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
	[NumAdults] [tinyint] NOT NULL,
	[NumChildren] [tinyint] NOT NULL,
	[TravellerAge] [tinyint] NULL,
	[IsAdult] [bit] NOT NULL,
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
