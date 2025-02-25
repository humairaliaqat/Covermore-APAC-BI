USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cdgQuote_Impulse2]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdgQuote_Impulse2](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[AnalyticsSessionID] [bigint] NOT NULL,
	[TransactionTime] [datetime] NULL,
	[CampaignID] [varchar](max) NULL,
	[Campaign] [nvarchar](255) NULL,
	[CampaignSessionID] [varchar](255) NULL,
	[BusinessUnitID] [int] NULL,
	[Domain] [nvarchar](255) NULL,
	[BusinessUnit] [nvarchar](255) NULL,
	[ChannelID] [int] NULL,
	[Channel] [nvarchar](255) NULL,
	[Currency] [nvarchar](3) NULL,
	[TravellerID] [varchar](max) NULL,
	[ImpressionID] [varchar](100) NULL,
	[TransactionType] [nvarchar](1) NULL,
	[PathType] [nvarchar](1) NULL,
	[ConstructID] [int] NULL,
	[Construct] [nvarchar](255) NULL,
	[OfferID] [int] NULL,
	[Offer] [nvarchar](255) NULL,
	[ProductID] [int] NULL,
	[Product] [nvarchar](100) NULL,
	[ProductCode] [nvarchar](255) NULL,
	[PlanCode] [nvarchar](255) NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[RegionID] [int] NULL,
	[Region] [nvarchar](4000) NULL,
	[DestinationType] [nvarchar](1) NULL,
	[DestinationCountryID] [int] NULL,
	[DestinationCountryCode] [nvarchar](3) NULL,
	[DestinationCountry] [nvarchar](50) NULL,
	[TripType] [nvarchar](1) NULL,
	[IsSessionClosed] [bit] NULL,
	[IsOfferPurchased] [bit] NULL,
	[PoliciesPerTrip] [int] NULL,
	[PolicyCurrency] [nvarchar](3) NULL,
	[GrossIncludingTax] [numeric](19, 5) NULL,
	[GrossExcludingTax] [numeric](19, 5) NULL,
	[NumAdults] [int] NULL,
	[NumChildren] [int] NULL,
	[TravellerAge] [int] NULL,
	[IsAdult] [bit] NULL,
	[TravellerGender] [nvarchar](1) NULL,
	[IsPrimaryTraveller] [bit] NULL,
	[AlphaCode] [nvarchar](20) NULL,
	[PolicyNumber] [varchar](max) NULL,
	[PolicyID] [varchar](max) NULL,
	[TripCost] [numeric](8, 2) NULL,
	[DepartureAirport] [nvarchar](max) NULL,
	[DestinationAirport] [nvarchar](max) NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
	[isDeleted] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgQuote_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_cdgQuote_BIRowID] ON [dbo].[cdgQuote_Impulse2]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgQuote_AnalyticsSessionID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgQuote_AnalyticsSessionID] ON [dbo].[cdgQuote_Impulse2]
(
	[AnalyticsSessionID] ASC
)
INCLUDE([BIRowID],[IsPrimaryTraveller],[NumChildren],[NumAdults],[GrossIncludingTax]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgQuote_BusinessUnitID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgQuote_BusinessUnitID] ON [dbo].[cdgQuote_Impulse2]
(
	[BusinessUnitID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cdgQuote_CampaignSessionID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgQuote_CampaignSessionID] ON [dbo].[cdgQuote_Impulse2]
(
	[CampaignSessionID] ASC,
	[IsPrimaryTraveller] ASC
)
INCLUDE([TravellerID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgQuote_TransactionTime]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgQuote_TransactionTime] ON [dbo].[cdgQuote_Impulse2]
(
	[TransactionTime] ASC
)
INCLUDE([BIRowID],[Currency],[Region],[DestinationCountry],[PathType],[ProductID],[ProductCode],[Product],[PlanCode],[StartDate],[EndDate],[NumChildren],[IsPrimaryTraveller],[NumAdults],[GrossIncludingTax],[CampaignSessionID],[ImpressionID],[PolicyID],[TravellerAge],[Domain],[BusinessUnit],[Channel]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgQuote_TransactionTime_IsDeleted]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgQuote_TransactionTime_IsDeleted] ON [dbo].[cdgQuote_Impulse2]
(
	[TransactionTime] ASC,
	[isDeleted] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdgQuote_Impulse2] ADD  DEFAULT ((0)) FOR [isDeleted]
GO
