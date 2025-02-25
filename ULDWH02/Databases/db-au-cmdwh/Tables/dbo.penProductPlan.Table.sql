USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penProductPlan]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penProductPlan](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[OutletKey] [varchar](41) NULL,
	[DomainID] [int] NULL,
	[OutletID] [int] NULL,
	[OutletProductId] [int] NULL,
	[ProductId] [int] NULL,
	[SortOrder] [int] NULL,
	[ProductCode] [nvarchar](50) NULL,
	[PurchasePathId] [int] NULL,
	[PurchasePath] [nvarchar](50) NULL,
	[CommissionTierId] [int] NULL,
	[CommissionTier] [nvarchar](50) NULL,
	[VolumeCommission] [decimal](18, 5) NULL,
	[Discount] [decimal](18, 5) NULL,
	[ProductPricingTierId] [int] NULL,
	[DeclarationSetId] [int] NULL,
	[IsCancellation] [bit] NULL,
	[Stocked] [bit] NULL,
	[PlanName] [nvarchar](50) NULL,
	[PlanDisplayName] [nvarchar](50) NULL,
	[UniquePlanId] [int] NULL,
	[PlanId] [int] NULL,
	[DefaultExcess] [money] NULL,
	[MaxAdminFee] [money] NULL,
	[IsUpsell] [bit] NULL,
	[PlanAreaID] [int] NULL,
	[AreaID] [int] NULL,
	[AMTUpsellDisplayName] [nvarchar](100) NULL,
	[TravellerSetID] [int] NULL,
	[TravellerSetName] [varchar](100) NULL,
	[MinimumAdult] [int] NULL,
	[MaximumAdult] [int] NULL,
	[MinimumChild] [int] NULL,
	[MaximumChild] [int] NULL,
	[PlanCode] [nvarchar](50) NULL,
	[FinanceProductID] [int] NULL,
	[FinanceProductCode] [nvarchar](10) NULL,
	[FinanceProductName] [nvarchar](125) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penProductPlan_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_penProductPlan_BIRowID] ON [dbo].[penProductPlan]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penProductPlan_OutletKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penProductPlan_OutletKey] ON [dbo].[penProductPlan]
(
	[OutletKey] ASC,
	[ProductId] ASC,
	[UniquePlanId] ASC
)
INCLUDE([PlanName],[PlanDisplayName],[PlanCode],[PlanId],[AMTUpsellDisplayName],[TravellerSetName],[Discount],[AreaID],[CountryKey],[CompanyKey],[FinanceProductCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penProductPlan_UniquePlanId]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penProductPlan_UniquePlanId] ON [dbo].[penProductPlan]
(
	[UniquePlanId] ASC,
	[ProductId] ASC,
	[OutletKey] ASC
)
INCLUDE([PlanName],[PlanDisplayName],[PlanCode],[PlanId],[AMTUpsellDisplayName],[TravellerSetName],[Discount],[AreaID],[CountryKey],[CompanyKey],[FinanceProductCode],[ProductPricingTierId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
