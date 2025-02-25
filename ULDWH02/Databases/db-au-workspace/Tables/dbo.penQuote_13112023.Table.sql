USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[penQuote_13112023]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penQuote_13112023](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[QuoteKey] [varchar](30) NULL,
	[QuoteCountryKey] [varchar](41) NULL,
	[PolicyKey] [varchar](41) NULL,
	[OutletSKey] [bigint] NULL,
	[OutletAlphaKey] [nvarchar](50) NULL,
	[QuoteID] [int] NULL,
	[SessionID] [nvarchar](255) NULL,
	[AgencyCode] [nvarchar](60) NULL,
	[ConsultantName] [nvarchar](101) NULL,
	[UserName] [nvarchar](100) NULL,
	[CreateDate] [datetime] NULL,
	[CreateTime] [datetime] NULL,
	[Area] [nvarchar](100) NULL,
	[Destination] [nvarchar](max) NULL,
	[DepartureDate] [datetime] NULL,
	[ReturnDate] [datetime] NULL,
	[IsExpo] [bit] NULL,
	[IsAgentSpecial] [bit] NULL,
	[PromoCode] [nvarchar](60) NULL,
	[CanxFlag] [bit] NULL,
	[PolicyNo] [varchar](50) NULL,
	[NumberOfChildren] [int] NULL,
	[NumberOfAdults] [int] NULL,
	[NumberOfPersons] [int] NULL,
	[Duration] [int] NULL,
	[IsSaved] [bit] NULL,
	[SaveStep] [int] NULL,
	[AgentReference] [nvarchar](100) NULL,
	[UpdateTime] [datetime] NULL,
	[StoreCode] [varchar](10) NULL,
	[QuotedPrice] [numeric](19, 4) NULL,
	[ProductCode] [nvarchar](50) NULL,
	[DomainKey] [varchar](41) NULL,
	[DomainID] [int] NULL,
	[CreateDateUTC] [datetime] NULL,
	[CreateTimeUTC] [datetime] NULL,
	[UpdateTimeUTC] [datetime] NULL,
	[YAGOCreateDate] [datetime] NULL,
	[PurchasePath] [nvarchar](50) NULL,
	[QuoteSaveDate] [datetime] NULL,
	[QuoteSaveDateUTC] [datetime] NULL,
	[CRMUserName] [nvarchar](100) NULL,
	[CRMFullName] [nvarchar](101) NULL,
	[PreviousPolicyNumber] [varchar](50) NULL,
	[QuoteImportDateUTC] [datetime] NULL,
	[CurrencyCode] [varchar](3) NULL,
	[AreaCode] [nvarchar](3) NULL,
	[CultureCode] [nvarchar](20) NULL,
	[ProductName] [nvarchar](50) NULL,
	[PlanID] [int] NULL,
	[PlanName] [nvarchar](50) NULL,
	[PlanCode] [nvarchar](50) NULL,
	[PlanType] [nvarchar](50) NULL,
	[IsUpSell] [bit] NULL,
	[Excess] [money] NULL,
	[IsDefaultExcess] [bit] NULL,
	[PolicyStart] [datetime] NULL,
	[PolicyEnd] [datetime] NULL,
	[DaysCovered] [int] NULL,
	[MaxDuration] [int] NULL,
	[GrossPremium] [money] NULL,
	[PDSUrl] [varchar](100) NULL,
	[SortOrder] [int] NULL,
	[PlanDisplayName] [nvarchar](100) NULL,
	[RiskNet] [money] NULL,
	[PlanProductPricingTierID] [int] NULL,
	[VolumeCommission] [decimal](18, 9) NULL,
	[Discount] [decimal](18, 9) NULL,
	[CommissionTier] [varchar](50) NULL,
	[COI] [varchar](100) NULL,
	[UniquePlanID] [int] NULL,
	[TripCost] [nvarchar](100) NULL,
	[PolicyID] [int] NULL,
	[IsPriceBeat] [bit] NULL,
	[CancellationValueText] [nvarchar](50) NULL,
	[ProductDisplayName] [nvarchar](50) NULL,
	[AreaID] [int] NULL,
	[AgeBandID] [int] NULL,
	[DurationID] [int] NULL,
	[ExcessID] [int] NULL,
	[LeadTimeID] [int] NULL,
	[RateCardID] [int] NULL,
	[IsSelected] [bit] NULL,
	[ParentQuoteID] [int] NULL,
	[MultiDestination] [nvarchar](max) NULL,
	[LeadTimeDate] [date] NULL,
	[IsNoClaimBonus] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
