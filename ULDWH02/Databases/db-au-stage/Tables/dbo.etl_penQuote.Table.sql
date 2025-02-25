USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penQuote]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penQuote](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[QuoteKey] [nvarchar](132) NULL,
	[QuoteCountryKey] [varchar](71) NULL,
	[PolicyKey] [varchar](71) NULL,
	[OutletSKey] [int] NULL,
	[OutletAlphaKey] [nvarchar](101) NULL,
	[DomainID] [int] NOT NULL,
	[QuoteID] [int] NOT NULL,
	[SessionID] [nvarchar](255) NULL,
	[AgencyCode] [nvarchar](60) NOT NULL,
	[ConsultantName] [nvarchar](101) NULL,
	[UserName] [nvarchar](100) NULL,
	[CreateDate] [date] NULL,
	[CreateTime] [datetime] NULL,
	[CreateDateUTC] [varchar](10) NULL,
	[CreateTimeUTC] [datetime] NOT NULL,
	[Area] [nvarchar](100) NOT NULL,
	[Destination] [nvarchar](max) NULL,
	[DepartureDate] [date] NULL,
	[ReturnDate] [date] NULL,
	[IsExpo] [bit] NOT NULL,
	[IsAgentSpecial] [bit] NOT NULL,
	[PromoCode] [nvarchar](60) NULL,
	[CanxFlag] [bit] NOT NULL,
	[PolicyNo] [varchar](25) NULL,
	[NumberOfChildren] [int] NOT NULL,
	[NumberOfAdults] [int] NOT NULL,
	[NumberOfPersons] [int] NOT NULL,
	[Duration] [int] NULL,
	[IsSaved] [int] NOT NULL,
	[SaveStep] [int] NULL,
	[AgentReference] [nvarchar](100) NULL,
	[QuoteSaveDate] [date] NULL,
	[QuoteSaveDateUTC] [datetime] NULL,
	[UpdateTime] [datetime] NULL,
	[UpdateTimeUTC] [datetime] NULL,
	[StoreCode] [varchar](10) NULL,
	[QuotedPrice] [money] NULL,
	[ProductCode] [nvarchar](50) NULL,
	[PurchasePath] [nvarchar](50) NOT NULL,
	[CRMUserName] [nvarchar](100) NULL,
	[CRMFullName] [nvarchar](101) NULL,
	[PreviousPolicyNumber] [varchar](25) NULL,
	[QuoteImportDateUTC] [datetime] NULL,
	[CurrencyCode] [varchar](3) NOT NULL,
	[CultureCode] [nvarchar](20) NULL,
	[AreaCode] [nvarchar](3) NULL,
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
	[VolumeCommission] [numeric](18, 9) NULL,
	[Discount] [numeric](18, 9) NULL,
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
	[IsNoClaimBonus] [bit] NULL,
	[LeadTimeDate] [date] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
