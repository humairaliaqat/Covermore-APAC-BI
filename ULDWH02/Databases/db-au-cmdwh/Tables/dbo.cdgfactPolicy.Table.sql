USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cdgfactPolicy]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdgfactPolicy](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[factPolicyID] [int] NOT NULL,
	[PolicyNumber] [nvarchar](40) NOT NULL,
	[SessionID] [int] NOT NULL,
	[RegionID] [int] NOT NULL,
	[CampaignID] [int] NOT NULL,
	[ImpulseOfferID] [int] NULL,
	[PolicyIssueDate] [datetime] NULL,
	[PolicyIssueTime] [char](8) NULL,
	[PolicyIssueDateTime] [datetime] NULL,
	[AreaCode] [nvarchar](20) NULL,
	[AreaType] [varchar](16) NULL,
	[RiskRank] [int] NULL,
	[RegionName] [nvarchar](100) NULL,
	[ProductCode] [nvarchar](10) NULL,
	[PlanCode] [nvarchar](10) NULL,
	[ProductName] [nvarchar](100) NULL,
	[TripType] [varchar](17) NULL,
	[SingleFamilyDuo] [varchar](7) NULL,
	[PromoCode] [varchar](8000) NULL,
	[PromoType] [varchar](100) NULL,
	[CampaignName] [varchar](255) NULL,
	[BusinessUnitID] [int] NOT NULL,
	[Domain] [char](2) NULL,
	[BusinessUnitName] [varchar](100) NULL,
	[Partner] [varchar](50) NULL,
	[AffiliateCode] [varchar](50) NULL,
	[CurrencyCode] [char](3) NULL,
	[Destination] [varchar](50) NULL,
	[MultiDestination] [varchar](8000) NULL,
	[TripStart] [datetime] NULL,
	[TripEnd] [datetime] NULL,
	[Excess] [int] NOT NULL,
	[MemberPointsAwarded] [int] NOT NULL,
	[hasCANX] [int] NOT NULL,
	[HasWNTS] [int] NOT NULL,
	[HasCRS] [int] NOT NULL,
	[HasLUGG] [int] NOT NULL,
	[HasRTCR] [int] NOT NULL,
	[HasEMC] [int] NOT NULL,
	[isDiscounted] [int] NOT NULL,
	[TotalGrossPremium] [numeric](18, 2) NULL,
	[TotalDiscountedGrossPremium] [numeric](18, 2) NULL,
	[CANXCoverageAmount] [numeric](18, 2) NULL,
	[RTCRCoverageAmount] [numeric](18, 2) NULL,
	[ActualPaymentType] [nvarchar](10) NULL,
	[PaymentReferenceNumber] [nvarchar](50) NULL,
	[TripDuration] [int] NOT NULL,
	[HasMTCL] [int] NOT NULL,
	[DepartureCountry] [varchar](50) NULL,
	[AirportName] [nvarchar](50) NULL,
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
/****** Object:  Index [idx_cdgfactPolicy_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_cdgfactPolicy_BIRowID] ON [dbo].[cdgfactPolicy]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgfactPolicy_factPolicyID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgfactPolicy_factPolicyID] ON [dbo].[cdgfactPolicy]
(
	[factPolicyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgfactPolicy_PolicyIssueDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgfactPolicy_PolicyIssueDate] ON [dbo].[cdgfactPolicy]
(
	[PolicyIssueDate] ASC
)
INCLUDE([factPolicyID],[SessionID],[RegionID],[CampaignID],[PolicyIssueDateTime],[BusinessUnitID],[BusinessUnitName],[Destination],[TripStart],[TripEnd],[TotalGrossPremium],[ProductID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
