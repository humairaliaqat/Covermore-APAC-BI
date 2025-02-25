USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_dimPolicy]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_dimPolicy](
	[Country] [nvarchar](20) NOT NULL,
	[PolicyKey] [varchar](41) NULL,
	[PolicyNumber] [varchar](50) NULL,
	[PolicyStatus] [nvarchar](50) NULL,
	[IssueDate] [datetime] NOT NULL,
	[CancelledDate] [datetime] NULL,
	[TripStart] [datetime] NULL,
	[TripEnd] [datetime] NULL,
	[GroupName] [nvarchar](100) NOT NULL,
	[CompanyName] [nvarchar](100) NOT NULL,
	[PolicyStart] [datetime] NOT NULL,
	[PolicyEnd] [datetime] NOT NULL,
	[Excess] [bigint] NULL,
	[TripType] [nvarchar](50) NOT NULL,
	[TripCost] [bigint] NULL,
	[isCancellation] [varchar](1) NULL,
	[CancellationCover] [bigint] NULL,
	[LoadDate] [datetime] NULL,
	[updateDate] [datetime] NULL,
	[LoadID] [int] NULL,
	[updateID] [int] NULL,
	[HashKey] [varbinary](30) NULL,
	[PurchasePath] [nvarchar](50) NOT NULL,
	[MaxDuration] [int] NOT NULL,
	[TravellerCount] [int] NOT NULL,
	[AdultCount] [int] NOT NULL,
	[ChargedAdultCount] [int] NOT NULL,
	[TotalPremium] [money] NOT NULL,
	[EMCFlag] [varchar](7) NOT NULL,
	[TotalEMCScore] [decimal](38, 2) NOT NULL,
	[MaxEMCScore] [decimal](18, 2) NOT NULL,
	[CancellationFlag] [varchar](16) NOT NULL,
	[CruiseFlag] [varchar](10) NOT NULL,
	[ElectronicsFlag] [varchar](15) NOT NULL,
	[LuggageFlag] [varchar](11) NOT NULL,
	[MotorcycleFlag] [varchar](14) NOT NULL,
	[RentalCarFlag] [varchar](14) NOT NULL,
	[WinterSportFlag] [varchar](16) NOT NULL,
	[CancellationPlusFlag] [varchar](25) NOT NULL,
	[Underwriter] [varchar](50) NULL
) ON [PRIMARY]
GO
