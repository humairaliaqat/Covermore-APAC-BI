USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[penQuoteSelectedPlan_10172023]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penQuoteSelectedPlan_10172023](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[QuoteCountryKey] [varchar](41) NULL,
	[QuotePlanKey] [varchar](41) NULL,
	[DomainID] [int] NOT NULL,
	[QuoteID] [int] NULL,
	[ProductCode] [nvarchar](50) NULL,
	[ProductName] [nvarchar](50) NOT NULL,
	[PlanID] [int] NULL,
	[PlanName] [nvarchar](50) NOT NULL,
	[PlanCode] [nvarchar](50) NULL,
	[PlanType] [nvarchar](50) NOT NULL,
	[IsUpSell] [bit] NOT NULL,
	[Excess] [money] NOT NULL,
	[IsDefaultExcess] [bit] NOT NULL,
	[PolicyStart] [datetime] NOT NULL,
	[PolicyEnd] [datetime] NOT NULL,
	[DaysCovered] [int] NULL,
	[MaxDuration] [int] NULL,
	[GrossPremium] [money] NOT NULL,
	[PDSUrl] [varchar](100) NULL,
	[SortOrder] [int] NULL,
	[PlanDisplayName] [nvarchar](100) NULL,
	[RiskNet] [money] NULL,
	[PlanProductPricingTierID] [int] NULL,
	[VolumeCommission] [decimal](18, 9) NOT NULL,
	[Discount] [decimal](18, 9) NOT NULL,
	[CommissionTier] [varchar](50) NULL,
	[Area] [nvarchar](100) NULL,
	[COI] [varchar](100) NULL,
	[UniquePlanID] [int] NULL,
	[TripCost] [nvarchar](100) NULL,
	[PolicyID] [int] NULL,
	[IsPriceBeat] [bit] NOT NULL,
	[CancellationValueText] [nvarchar](50) NULL,
	[ProductDisplayName] [nvarchar](50) NULL,
	[AreaID] [int] NULL,
	[AgeBandID] [int] NULL,
	[DurationID] [int] NULL,
	[ExcessID] [int] NULL,
	[LeadTimeID] [int] NULL,
	[RateCardID] [int] NULL,
	[IsSelected] [bit] NULL,
	[AreaCode] [nvarchar](3) NULL
) ON [PRIMARY]
GO
