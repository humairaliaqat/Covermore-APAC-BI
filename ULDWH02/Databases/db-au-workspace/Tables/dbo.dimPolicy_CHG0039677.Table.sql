USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[dimPolicy_CHG0039677]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dimPolicy_CHG0039677](
	[PolicySK] [int] IDENTITY(1,1) NOT NULL,
	[Country] [nvarchar](10) NOT NULL,
	[PolicyKey] [nvarchar](50) NOT NULL,
	[PolicyNumber] [varchar](50) NOT NULL,
	[PolicyStatus] [nvarchar](50) NULL,
	[IssueDate] [datetime] NULL,
	[CancelledDate] [datetime] NULL,
	[TripStart] [datetime] NULL,
	[TripEnd] [datetime] NULL,
	[GroupName] [nvarchar](100) NULL,
	[CompanyName] [nvarchar](100) NULL,
	[PolicyStart] [datetime] NULL,
	[PolicyEnd] [datetime] NULL,
	[Excess] [decimal](18, 2) NOT NULL,
	[TripType] [nvarchar](50) NULL,
	[TripCost] [nvarchar](50) NULL,
	[isCancellation] [nvarchar](1) NULL,
	[CancellationCover] [nvarchar](50) NULL,
	[LoadDate] [datetime] NOT NULL,
	[updateDate] [datetime] NULL,
	[LoadID] [int] NOT NULL,
	[updateID] [int] NULL,
	[HashKey] [varbinary](30) NULL,
	[PurchasePath] [nvarchar](50) NULL,
	[MaxDuration] [int] NULL,
	[TravellerCount] [int] NULL,
	[AdultCount] [int] NULL,
	[ChargedAdultCount] [int] NULL,
	[TotalPremium] [float] NULL,
	[EMCFlag] [varchar](10) NULL,
	[MaxEMCScore] [decimal](18, 2) NULL,
	[TotalEMCScore] [decimal](18, 2) NULL,
	[CancellationFlag] [varchar](25) NULL,
	[CruiseFlag] [varchar](25) NULL,
	[ElectronicsFlag] [varchar](25) NULL,
	[LuggageFlag] [varchar](25) NULL,
	[MotorcycleFlag] [varchar](25) NULL,
	[RentalCarFlag] [varchar](25) NULL,
	[WinterSportFlag] [varchar](25) NULL,
	[Underwriter] [varchar](100) NULL,
	[CancellationPlusFlag] [varchar](100) NULL
) ON [PRIMARY]
GO
