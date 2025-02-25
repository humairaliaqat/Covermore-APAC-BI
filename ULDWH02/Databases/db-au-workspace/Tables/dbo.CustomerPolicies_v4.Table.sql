USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[CustomerPolicies_v4]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerPolicies_v4](
	[CustomerID] [bigint] NOT NULL,
	[PolicyKey] [varchar](41) NULL,
	[PolicyTravellerKey] [varchar](41) NULL,
	[IssueDate] [datetime] NOT NULL,
	[Channel] [nvarchar](100) NULL,
	[SuperGroupName] [nvarchar](25) NULL,
	[FinanceProductName] [nvarchar](125) NULL,
	[PrimaryCountry] [nvarchar](max) NULL,
	[TripStart] [datetime] NULL,
	[DayofYearTripStart] [int] NULL,
	[isPrimary] [smallint] NULL,
	[DOB] [datetime] NULL,
	[Gender] [nvarchar](10) NULL,
	[isAdult] [smallint] NULL,
	[State] [nvarchar](10) NULL,
	[PostCode] [nvarchar](50) NULL,
	[BirthYear] [int] NULL,
	[Age] [int] NULL,
	[PolicyCount] [int] NOT NULL,
	[isAMT] [int] NULL,
	[isCallCentre] [int] NOT NULL,
	[isIntegrated] [int] NOT NULL,
	[isMobile] [int] NOT NULL,
	[isRetail] [int] NOT NULL,
	[isWebsiteWhiteLabel] [int] NOT NULL,
	[isPointofSale] [int] NOT NULL,
	[isBusiness] [int] NOT NULL,
	[isComprehensive] [int] NOT NULL,
	[isStandard] [int] NOT NULL,
	[isValue] [int] NOT NULL,
	[isExpo] [int] NOT NULL,
	[isPriceBeat] [int] NOT NULL,
	[AdultCompanionsCount] [int] NOT NULL,
	[ChildCompanionsCount] [int] NOT NULL,
	[CompanionsCount] [int] NOT NULL,
	[isAustralia] [int] NOT NULL,
	[isCruise] [int] NOT NULL,
	[isAntarctica] [int] NOT NULL,
	[isAfrica] [int] NOT NULL,
	[isAsia] [int] NOT NULL,
	[isEurope] [int] NOT NULL,
	[isNorthAmerica] [int] NOT NULL,
	[isSouthAmerica] [int] NOT NULL,
	[isOceania] [int] NOT NULL,
	[PolicyValue] [money] NULL,
	[Paid] [money] NULL,
	[HasEMC] [int] NULL,
	[hasAddon] [int] NOT NULL,
	[hasLuggage] [int] NOT NULL,
	[hasMedical] [int] NOT NULL,
	[hasMotorcycle] [int] NOT NULL,
	[hasRentalCar] [int] NOT NULL,
	[hasWintersport] [int] NOT NULL,
	[LeadTime] [int] NULL,
	[TripDuration] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_PolicyKey]    Script Date: 24/02/2025 5:22:16 PM ******/
CREATE CLUSTERED INDEX [IX_PolicyKey] ON [dbo].[CustomerPolicies_v4]
(
	[PolicyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CustomerID]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_CustomerID] ON [dbo].[CustomerPolicies_v4]
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_PolicyKeyCustomerID]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_PolicyKeyCustomerID] ON [dbo].[CustomerPolicies_v4]
(
	[PolicyKey] ASC,
	[CustomerID] ASC,
	[isPrimary] ASC
)
INCLUDE([PolicyTravellerKey],[isAdult],[DOB],[PostCode],[IssueDate],[TripStart]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
