USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_UKEMC_Medical_UK]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_UKEMC_Medical_UK](
	[Counter] [int] NOT NULL,
	[ClientID] [int] NULL,
	[Condition] [varchar](50) NULL,
	[DeniedAccepted] [varchar](1) NULL,
	[CONDCODE] [varchar](1) NULL,
	[AssessorID] [int] NULL,
	[DiagnosisDate] [datetime] NULL,
	[Meds_Dose_Freq] [varchar](2000) NULL,
	[MedsChanged] [bit] NULL,
	[OnlineCondition] [varchar](2000) NULL,
	[MedicalConditionsGroupID] [int] NULL,
	[IsAMTExclusion] [bit] NULL,
	[IsWSExclusion] [bit] NULL,
	[Score] [numeric](18, 2) NULL
) ON [PRIMARY]
GO
