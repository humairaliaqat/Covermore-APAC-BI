USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cdgfactOffer]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdgfactOffer](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[factOfferID] [int] NOT NULL,
	[SessionID] [int] NOT NULL,
	[RegionID] [int] NOT NULL,
	[CampaignID] [int] NOT NULL,
	[ImpulseOfferID] [int] NOT NULL,
	[OfferDate] [datetime] NULL,
	[OfferTime] [char](8) NULL,
	[OfferDateTime] [datetime] NULL,
	[AreaCode] [nvarchar](20) NULL,
	[AreaType] [varchar](16) NULL,
	[RiskRank] [int] NULL,
	[RegionName] [nvarchar](100) NULL,
	[ProductCode] [nvarchar](10) NULL,
	[PlanCode] [nvarchar](10) NULL,
	[ProductName] [nvarchar](100) NULL,
	[TripType] [varchar](17) NULL,
	[TripCost] [numeric](18, 2) NULL,
	[SingleFamilyDuo] [varchar](7) NULL,
	[PromoCode] [varchar](8000) NULL,
	[PromoType] [varchar](100) NULL,
	[CampaignName] [varchar](255) NULL,
	[BusinessUnitID] [int] NOT NULL,
	[Domain] [char](2) NULL,
	[BusinessUnitName] [varchar](100) NULL,
	[Partner] [varchar](50) NULL,
	[CurrencyCode] [char](3) NULL,
	[Destination] [varchar](50) NULL,
	[IsMultiDestination] [int] NOT NULL,
	[MultiDestination] [varchar](8000) NULL,
	[TripStart] [datetime] NULL,
	[TripEnd] [datetime] NULL,
	[TotalGrossPremium] [numeric](9, 4) NULL,
	[Excess] [int] NOT NULL,
	[IsMostRecent] [int] NOT NULL,
	[ConstructOfferDisplayPercent] [numeric](9, 4) NULL,
	[AdultCount] [int] NULL,
	[ChildCount] [int] NULL,
	[InfantCount] [int] NULL,
	[MaxPolicies] [int] NOT NULL,
	[ActualPoliciesSold] [int] NOT NULL,
	[DepartureCountry] [varchar](50) NULL,
	[AirportName] [nvarchar](50) NULL,
	[GroupType] [nvarchar](7) NULL,
	[CultureCode] [nvarchar](20) NULL,
	[CultureName] [nvarchar](50) NULL,
	[SelectedImpulseOfferID] [int] NOT NULL,
	[ConstructName] [varchar](255) NULL,
	[MinAdults] [int] NULL,
	[MaxAdults] [int] NULL,
	[MinChildren] [int] NULL,
	[MaxChildren] [int] NULL,
	[DestinationType] [varchar](2) NULL,
	[Priority] [tinyint] NULL,
	[CarRental] [int] NULL,
	[CheckedBags] [int] NULL,
	[BookedHotel] [int] NULL,
	[AdvancedPurchase] [int] NULL,
	[MemberLevel] [nvarchar](20) NULL,
	[PaidWithPoints] [int] NULL,
	[TravelClass] [nvarchar](20) NULL,
	[ProductID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgfactOffer_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_cdgfactOffer_BIRowID] ON [dbo].[cdgfactOffer]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgfactOffer_factOfferID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgfactOffer_factOfferID] ON [dbo].[cdgfactOffer]
(
	[factOfferID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgfactOffer_OfferDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgfactOffer_OfferDate] ON [dbo].[cdgfactOffer]
(
	[OfferDate] ASC
)
INCLUDE([factOfferID],[SessionID],[RegionID],[CampaignID],[OfferDateTime],[BusinessUnitID],[BusinessUnitName],[Destination],[TripStart],[TripEnd],[TotalGrossPremium],[AdultCount],[ChildCount],[InfantCount],[ProductID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgfactOffer_SessionID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgfactOffer_SessionID] ON [dbo].[cdgfactOffer]
(
	[SessionID] ASC,
	[IsMostRecent] ASC
)
INCLUDE([BIRowID],[OfferDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
