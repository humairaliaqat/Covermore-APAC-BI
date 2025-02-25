USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[k8_cluster_sample_tsne]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[k8_cluster_sample_tsne](
	[PolicyTravellerKey] [nvarchar](255) NULL,
	[cluster] [float] NULL,
	[tsneV1] [float] NULL,
	[tsneV2] [float] NULL,
	[PostCode] [float] NULL,
	[CustomerID] [float] NULL,
	[PolicyKey] [nvarchar](255) NULL,
	[IssueDate] [datetime] NULL,
	[Channel] [nvarchar](255) NULL,
	[SuperGroupName] [nvarchar](255) NULL,
	[FinanceProductName] [nvarchar](255) NULL,
	[PrimaryCountry] [nvarchar](255) NULL,
	[TripStart] [datetime] NULL,
	[DayofYearTripStart] [float] NULL,
	[isPrimary] [float] NULL,
	[DOB] [datetime] NULL,
	[isAdult] [float] NULL,
	[State] [nvarchar](255) NULL,
	[BirthYear] [float] NULL,
	[Age] [float] NULL,
	[PolicyCount] [float] NULL,
	[isAMT] [float] NULL,
	[isCallCentre] [float] NULL,
	[isIntegrated] [float] NULL,
	[isMobile] [float] NULL,
	[isRetail] [float] NULL,
	[isWebsiteWhiteLabel] [float] NULL,
	[isPointofSale] [float] NULL,
	[isBusiness] [float] NULL,
	[isComprehensive] [float] NULL,
	[isStandard] [float] NULL,
	[isValue] [float] NULL,
	[isExpo] [float] NULL,
	[isPriceBeat] [float] NULL,
	[AdultCompanionsCount] [float] NULL,
	[ChildCompanionsCount] [float] NULL,
	[CompanionsCount] [float] NULL,
	[isAustralia] [float] NULL,
	[isCruise] [float] NULL,
	[isAntarctica] [float] NULL,
	[isAfrica] [float] NULL,
	[isAsia] [float] NULL,
	[isEurope] [float] NULL,
	[isNorthAmerica] [float] NULL,
	[isSouthAmerica] [float] NULL,
	[isOceania] [float] NULL,
	[PolicyValue] [float] NULL,
	[Paid] [float] NULL,
	[HasEMC] [float] NULL,
	[hasAddon] [float] NULL,
	[hasLuggage] [float] NULL,
	[hasMedical] [float] NULL,
	[hasMotorcycle] [float] NULL,
	[hasRentalCar] [float] NULL,
	[hasWintersport] [float] NULL,
	[LeadTime] [float] NULL,
	[TripDuration] [float] NULL,
	[ABSAgeBand] [nvarchar](255) NULL,
	[AgeGroup] [nvarchar](255) NULL,
	[DurationBand] [nvarchar](255) NULL,
	[LeadTimeBand] [nvarchar](255) NULL,
	[Season] [nvarchar](255) NULL,
	[RemotenessArea_ASGS] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [IX_CustomerID]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_CustomerID] ON [dbo].[k8_cluster_sample_tsne]
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
