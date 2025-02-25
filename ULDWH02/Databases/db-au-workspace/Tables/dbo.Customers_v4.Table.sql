USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Customers_v4]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customers_v4](
	[CustomerID] [bigint] NOT NULL,
	[ABSAgeBand] [nvarchar](50) NOT NULL,
	[Gender] [nvarchar](7) NULL,
	[State] [nvarchar](10) NULL,
	[LocationProfile] [varchar](50) NULL,
	[TravelPattern] [varchar](50) NULL,
	[ChannelPreference] [varchar](50) NULL,
	[ProductPreference] [varchar](50) NULL,
	[BrandAffiliation] [varchar](50) NULL,
	[TravelGroup] [varchar](50) NULL,
	[DestinationGroup] [varchar](50) NULL,
	[AvgPolicyValue] [money] NULL,
	[isPrimaryRatio] [numeric](24, 2) NULL,
	[AvgPaid] [money] NULL,
	[AddonRatio] [numeric](24, 2) NULL,
	[EMCRatio] [numeric](24, 2) NULL,
	[AvgLeadTime] [int] NULL,
	[AvgTripDuration] [int] NULL,
	[BrandCount] [int] NULL,
	[PoliciesHeld] [int] NULL,
	[isPrimaryCount] [int] NULL,
	[PoliciesPurachsed] [int] NULL,
	[AMTCount] [int] NULL,
	[CallCentreCount] [int] NULL,
	[IntegratedCount] [int] NULL,
	[MobileCount] [int] NULL,
	[RetailCount] [int] NULL,
	[WebsiteWhiteLabelCount] [int] NULL,
	[PointofSaleCount] [int] NULL,
	[BusinessCount] [int] NULL,
	[ComprehensiveCount] [int] NULL,
	[StandardCount] [int] NULL,
	[ValueCount] [int] NULL,
	[ExpoCount] [int] NULL,
	[PriceBeatCount] [int] NULL,
	[AdultCompanionsCount] [int] NULL,
	[ChildCompanionsCount] [int] NULL,
	[CompanionsCount] [int] NULL,
	[AustraliaCount] [int] NULL,
	[CruiseCount] [int] NULL,
	[AntarcticaCount] [int] NULL,
	[AfricaCount] [int] NULL,
	[AsiaCount] [int] NULL,
	[EuropeCount] [int] NULL,
	[NorthAmericaCount] [int] NULL,
	[SouthAmericaCount] [int] NULL,
	[OceaniaCount] [int] NULL,
	[TotalPolicyValue] [money] NULL,
	[TotalPaid] [money] NULL,
	[TotalEMC] [int] NULL,
	[TotalPolicyWithAddon] [int] NULL,
	[LuggageCount] [int] NULL,
	[MedicalCount] [int] NULL,
	[MotorcycleCount] [int] NULL,
	[RentalCarCount] [int] NULL,
	[WintersportCount] [int] NULL,
	[TotalLeadTime] [int] NULL,
	[TotalTripDuration] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [IX_CustomerID]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_CustomerID] ON [dbo].[Customers_v4]
(
	[CustomerID] ASC
)
INCLUDE([ABSAgeBand],[Gender],[ProductPreference],[ChannelPreference],[BrandAffiliation],[TravelPattern],[TravelGroup],[DestinationGroup],[LocationProfile]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
