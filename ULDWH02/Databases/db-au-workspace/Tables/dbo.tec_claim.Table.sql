USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tec_claim]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tec_claim](
	[Category] [varchar](27) NOT NULL,
	[PolicyKey] [varchar](41) NULL,
	[PolicyNumber] [varchar](50) NULL,
	[IssueDate] [datetime] NOT NULL,
	[TripStart] [datetime] NULL,
	[TripEnd] [datetime] NULL,
	[PrimaryCountry] [nvarchar](max) NULL,
	[MultiDestination] [nvarchar](max) NULL,
	[CustomerID] [bigint] NULL,
	[ClaimNo] [int] NOT NULL,
	[CreateDate] [datetime] NULL,
	[PerilDesc] [nvarchar](65) NULL,
	[CatastropheShortDesc] [nvarchar](20) NULL,
	[EventCountryName] [nvarchar](45) NULL,
	[EventDescription] [nvarchar](max) NULL,
	[EventLocation] [nvarchar](max) NULL,
	[MentalHealthFlag] [bit] NULL,
	[LuggageFlag] [bit] NULL,
	[ElectronicsFlag] [bit] NULL,
	[CruiseFlag] [bit] NULL,
	[MopedFlag] [bit] NULL,
	[RentalCarFlag] [bit] NULL,
	[WinterSportFlag] [bit] NULL,
	[CrimeVictimFlag] [bit] NULL,
	[FoodPoisoningFlag] [bit] NULL,
	[AnimalFlag] [bit] NULL,
	[MedicalCostFlag] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
