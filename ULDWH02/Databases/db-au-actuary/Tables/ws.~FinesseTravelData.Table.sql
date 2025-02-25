USE [db-au-actuary]
GO
/****** Object:  Table [ws].[~FinesseTravelData]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ws].[~FinesseTravelData](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Period] [varchar](30) NULL,
	[PeriodEndDate] [datetime] NULL,
	[SampleNumber] [varchar](50) NULL,
	[Factor] [varchar](50) NULL,
	[State] [varchar](100) NULL,
	[Destination] [varchar](200) NULL,
	[InternationalDomestic] [varchar](50) NULL,
	[TravelGroup] [varchar](50) NULL,
	[NumberOfAdults] [int] NULL,
	[NumberOfChildren] [int] NULL,
	[AgeOfOldestAdult] [int] NULL,
	[AgeOfSecondOldestAdult] [int] NULL,
	[AgeOfOldestDependent] [int] NULL,
	[AgeOfSecondOldestDependent] [int] NULL,
	[AgeOfThirdOldestDependent] [int] NULL,
	[TravelDuration] [int] NULL,
	[TravelDurationBands] [varchar](50) NULL,
	[DestinationRegion] [varchar](50) NULL,
	[LeadTime] [int] NULL,
	[Profile] [varchar](50) NULL,
	[AgeOfOldestAdultBand] [varchar](50) NULL,
	[AgeOfSecondOldestAdultBand] [varchar](50) NULL,
	[AgeOfOldestDependentBand] [varchar](50) NULL,
	[AgeOfSecondOldestDependentBand] [varchar](50) NULL,
	[AgeOfThirdOldestDependentBand] [varchar](50) NULL,
	[TravelDurationBand] [varchar](50) NULL,
	[LeadTimeBand] [varchar](50) NULL,
	[SingleMultiTripBand] [varchar](50) NULL,
	[Competitor] [varchar](23) NOT NULL,
	[CompetitorProduct] [varchar](32) NOT NULL,
	[CompetitorPremium] [money] NULL,
	[CompetitorTimeStamp] [datetime] NULL,
	[CompetitorNotes] [varchar](200) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_FinesseTravelData_BIRowID]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE CLUSTERED INDEX [idx_FinesseTravelData_BIRowID] ON [ws].[~FinesseTravelData]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_PeriodEndDate]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_PeriodEndDate] ON [ws].[~FinesseTravelData]
(
	[PeriodEndDate] ASC,
	[Period] ASC
)
INCLUDE([Destination],[TravelGroup],[Competitor]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
