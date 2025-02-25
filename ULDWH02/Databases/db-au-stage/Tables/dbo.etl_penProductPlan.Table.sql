USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penProductPlan]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penProductPlan](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[OutletKey] [varchar](71) NULL,
	[DomainID] [int] NOT NULL,
	[OutletID] [int] NOT NULL,
	[OutletProductID] [int] NOT NULL,
	[ProductId] [int] NOT NULL,
	[SortOrder] [int] NULL,
	[ProductCode] [nvarchar](50) NOT NULL,
	[PurchasePathID] [int] NOT NULL,
	[PurchasePath] [nvarchar](50) NULL,
	[CommissionTierID] [int] NOT NULL,
	[CommissionTier] [nvarchar](50) NULL,
	[VolumeCommission] [numeric](18, 9) NOT NULL,
	[Discount] [numeric](18, 9) NOT NULL,
	[ProductPricingTierID] [int] NOT NULL,
	[DeclarationSetID] [int] NOT NULL,
	[IsCancellation] [bit] NOT NULL,
	[Stocked] [bit] NOT NULL,
	[PlanName] [nvarchar](50) NOT NULL,
	[PlanDisplayName] [nvarchar](100) NULL,
	[UniquePlanID] [int] NOT NULL,
	[PlanId] [int] NOT NULL,
	[DefaultExcess] [money] NOT NULL,
	[MaxAdminFee] [money] NOT NULL,
	[IsUpsell] [bit] NOT NULL,
	[PlanAreaID] [int] NOT NULL,
	[AreaID] [int] NOT NULL,
	[AMTUpsellDisplayName] [nvarchar](100) NULL,
	[PlanCode] [nvarchar](50) NULL,
	[TravellerSetID] [int] NOT NULL,
	[TravellerSetName] [varchar](100) NOT NULL,
	[MinimumAdult] [smallint] NULL,
	[MaximumAdult] [smallint] NULL,
	[MinimumChild] [smallint] NULL,
	[MaximumChild] [smallint] NULL,
	[FinanceProductID] [int] NULL,
	[FinanceProductCode] [nvarchar](12) NULL,
	[FinanceProductName] [nvarchar](125) NULL
) ON [PRIMARY]
GO
