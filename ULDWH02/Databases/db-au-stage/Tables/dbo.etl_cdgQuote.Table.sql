USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_cdgQuote]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_cdgQuote](
	[AnalyticsSessionID] [bigint] NOT NULL,
	[TransactionTime] [datetime] NULL,
	[CampaignID] [smallint] NOT NULL,
	[Campaign] [nvarchar](255) NULL,
	[CampaignSessionID] [bigint] NOT NULL,
	[BusinessUnitID] [smallint] NOT NULL,
	[Domain] [nvarchar](255) NULL,
	[BusinessUnit] [nvarchar](255) NULL,
	[ChannelID] [smallint] NOT NULL,
	[Channel] [nvarchar](255) NULL,
	[Currency] [nvarchar](3) NULL,
	[TravellerID] [bigint] NOT NULL,
	[ImpressionID] [bigint] NULL,
	[TransactionType] [char](1) NOT NULL,
	[PathType] [char](1) NOT NULL,
	[ConstructID] [smallint] NULL,
	[Construct] [nvarchar](255) NULL,
	[OfferID] [smallint] NULL,
	[Offer] [nvarchar](255) NULL,
	[ProductID] [smallint] NULL,
	[Product] [nvarchar](100) NULL,
	[ProductCode] [nvarchar](255) NULL,
	[PlanCode] [nvarchar](255) NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[RegionID] [smallint] NULL,
	[Region] [nvarchar](4000) NULL,
	[DestinationType] [char](1) NULL,
	[DestinationCountryID] [int] NULL,
	[DestinationCountryCode] [nvarchar](3) NULL,
	[DestinationCountry] [nvarchar](50) NULL,
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
	[TripCost] [numeric](8, 2) NULL
) ON [PRIMARY]
GO
