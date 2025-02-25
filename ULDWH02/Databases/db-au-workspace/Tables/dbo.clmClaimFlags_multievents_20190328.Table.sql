USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[clmClaimFlags_multievents_20190328]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clmClaimFlags_multievents_20190328](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[ClaimKey] [varchar](40) NOT NULL,
	[EventDescription] [nvarchar](max) NULL,
	[EventLocation] [nvarchar](max) NULL,
	[EventCountryName] [nvarchar](45) NULL,
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
	[LocationRedFlag] [bit] NULL,
	[LuggageRedFlag] [bit] NULL,
	[SectionRedFlag] [bit] NULL,
	[MultipleClaimRedFlag] [bit] NULL,
	[CustomerID] [bigint] NULL,
	[HighValueLuggageRedFlag] [bit] NULL,
	[MultipleElectronicRedFlag] [bit] NULL,
	[OnlyElectronicRedFlag] [bit] NULL,
	[NoProofRedFlag] [bit] NULL,
	[NoReportRedFlag] [bit] NULL,
	[CrimeVictimRedFlag] [bit] NULL,
	[MedicalCostFlag] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
