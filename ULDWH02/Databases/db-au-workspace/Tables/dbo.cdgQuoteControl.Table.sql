USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[cdgQuoteControl]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdgQuoteControl](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[AnalyticsSessionID] [bigint] NOT NULL,
	[TransactionTime] [datetime] NULL,
	[CampaignID] [int] NULL,
	[Campaign] [nvarchar](255) NULL,
	[CampaignSessionID] [bigint] NULL,
	[BusinessUnitID] [int] NULL,
	[Domain] [nvarchar](255) NULL,
	[BusinessUnit] [nvarchar](255) NULL,
	[ChannelID] [int] NULL,
	[Channel] [nvarchar](255) NULL,
	[Currency] [nvarchar](3) NULL,
	[TravellerID] [bigint] NULL,
	[ImpressionID] [bigint] NULL,
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
	[PolicyNumber] [int] NULL,
	[PolicyID] [int] NULL,
	[TripCost] [numeric](8, 2) NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
	[isDeleted] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgQuoteControl_BIRowID]    Script Date: 24/02/2025 5:22:16 PM ******/
CREATE CLUSTERED INDEX [idx_cdgQuoteControl_BIRowID] ON [dbo].[cdgQuoteControl]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgQuoteControl_AnalyticsSessionID]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgQuoteControl_AnalyticsSessionID] ON [dbo].[cdgQuoteControl]
(
	[AnalyticsSessionID] ASC
)
INCLUDE([BIRowID],[IsPrimaryTraveller],[NumChildren],[NumAdults],[GrossIncludingTax],[CampaignSessionID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgQuoteControl_CampaignSessionID]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgQuoteControl_CampaignSessionID] ON [dbo].[cdgQuoteControl]
(
	[CampaignSessionID] ASC
)
INCLUDE([AnalyticsSessionID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgQuoteControl_TransactionTime]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgQuoteControl_TransactionTime] ON [dbo].[cdgQuoteControl]
(
	[TransactionTime] ASC,
	[isDeleted] ASC
)
INCLUDE([BIRowID],[Currency],[Region],[DestinationCountry],[PathType],[ProductID],[ProductCode],[Product],[PlanCode],[StartDate],[EndDate],[NumChildren],[IsPrimaryTraveller],[NumAdults],[GrossIncludingTax],[CampaignSessionID],[ImpressionID],[PolicyID],[TravellerAge],[Domain],[BusinessUnit],[Channel]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cdgQuoteControl_TransactionTime__Domain_IsDeleted]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgQuoteControl_TransactionTime__Domain_IsDeleted] ON [dbo].[cdgQuoteControl]
(
	[TransactionTime] ASC,
	[Domain] ASC,
	[isDeleted] ASC
)
INCLUDE([CampaignSessionID],[BusinessUnitID],[ImpressionID],[ProductID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgQuoteControl_TransactionTime_IsDeleted]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgQuoteControl_TransactionTime_IsDeleted] ON [dbo].[cdgQuoteControl]
(
	[TransactionTime] ASC,
	[isDeleted] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdgQuoteControl] ADD  DEFAULT ((0)) FOR [isDeleted]
GO
