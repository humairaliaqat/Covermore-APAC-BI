USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[MicroSegments_Rate_v3_1]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MicroSegments_Rate_v3_1](
	[SegmentID] [int] IDENTITY(1,1) NOT NULL,
	[ABSAgeBand] [nvarchar](50) NOT NULL,
	[Gender] [nvarchar](7) NULL,
	[LocationProfile] [varchar](50) NULL,
	[TravelPattern] [varchar](50) NULL,
	[ChannelPreference] [varchar](50) NULL,
	[ProductPreference] [varchar](50) NULL,
	[BrandAffiliation] [varchar](50) NULL,
	[TravelGroup] [varchar](50) NULL,
	[DestinationGroup] [varchar](50) NULL,
	[SpendingBand] [varchar](10) NULL,
	[AddonHistory] [varchar](19) NULL,
	[LeadTimeBand] [varchar](18) NULL,
	[DurationBand] [varchar](11) NULL,
	[PolicyPerCustomer] [numeric](24, 2) NULL,
	[CallCenterRate] [numeric](24, 2) NULL,
	[IntegratedRate] [numeric](24, 2) NULL,
	[MobileRate] [numeric](24, 2) NULL,
	[PointofSaleRate] [numeric](24, 2) NULL,
	[RetailRate] [numeric](24, 2) NULL,
	[WebsiteWhiteLabelRate] [numeric](24, 2) NULL,
	[BusinessRate] [numeric](24, 2) NULL,
	[ComprehensiveRate] [numeric](24, 2) NULL,
	[StandardRate] [numeric](24, 2) NULL,
	[ValueRate] [numeric](24, 2) NULL,
	[PriceBeatRate] [numeric](24, 2) NULL,
	[ExpoRate] [numeric](24, 2) NULL,
	[AvgBrandCount] [numeric](24, 2) NULL,
	[AvgAdultCompanions] [numeric](24, 2) NULL,
	[AvgChildCompanions] [numeric](24, 2) NULL,
	[AustraliaRate] [numeric](24, 2) NULL,
	[AntarcticaRate] [numeric](24, 2) NULL,
	[OceaniaRate] [numeric](24, 2) NULL,
	[AfricaRate] [numeric](24, 2) NULL,
	[AsiaRate] [numeric](24, 2) NULL,
	[EuropeRate] [numeric](24, 2) NULL,
	[NorthAmericaRate] [numeric](24, 2) NULL,
	[SouthAmericaRate] [numeric](24, 2) NULL,
	[CruiseRate] [numeric](24, 2) NULL,
	[isPrimaryRate] [numeric](24, 2) NULL,
	[AvgPaid] [numeric](24, 2) NULL,
	[AvgCustomer2YearValue] [numeric](24, 2) NULL,
	[EMCRate] [numeric](24, 2) NULL,
	[LuggageRate] [numeric](24, 2) NULL,
	[MedicalRate] [numeric](24, 2) NULL,
	[MotorcycleRate] [numeric](24, 2) NULL,
	[RentalCarRate] [numeric](24, 2) NULL,
	[WintersportRate] [numeric](24, 2) NULL,
	[AvgLeadTime] [numeric](24, 2) NULL,
	[AvgTripDuration] [numeric](24, 2) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [IX_ID]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_ID] ON [dbo].[MicroSegments_Rate_v3_1]
(
	[SegmentID] ASC
)
INCLUDE([ABSAgeBand],[Gender],[ProductPreference],[ChannelPreference],[BrandAffiliation],[TravelPattern],[TravelGroup],[DestinationGroup],[LocationProfile],[SpendingBand],[AddonHistory],[LeadTimeBand],[DurationBand]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
