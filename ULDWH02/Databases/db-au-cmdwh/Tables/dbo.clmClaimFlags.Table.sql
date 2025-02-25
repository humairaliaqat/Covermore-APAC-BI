USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[clmClaimFlags]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clmClaimFlags](
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
/****** Object:  Index [idx_clmClaimFlags_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_clmClaimFlags_BIRowID] ON [dbo].[clmClaimFlags]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmClaimFlags_ClaimKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmClaimFlags_ClaimKey] ON [dbo].[clmClaimFlags]
(
	[ClaimKey] ASC
)
INCLUDE([CustomerID],[EventDescription],[EventLocation],[EventCountryName],[MentalHealthFlag],[LuggageFlag],[ElectronicsFlag],[CruiseFlag],[MopedFlag],[RentalCarFlag],[WinterSportFlag],[CrimeVictimFlag],[FoodPoisoningFlag],[AnimalFlag],[MedicalCostFlag],[LocationRedFlag],[LuggageRedFlag],[SectionRedFlag],[MultipleClaimRedFlag],[HighValueLuggageRedFlag],[MultipleElectronicRedFlag],[OnlyElectronicRedFlag],[NoProofRedFlag],[NoReportRedFlag],[CrimeVictimRedFlag]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_clmClaimFlags_CustomerID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmClaimFlags_CustomerID] ON [dbo].[clmClaimFlags]
(
	[CustomerID] ASC
)
INCLUDE([ClaimKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
