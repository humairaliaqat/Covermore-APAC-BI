USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_emcMedicalTreatments]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_emcMedicalTreatments](
	[CountryKey] [varchar](2) NULL,
	[ApplicationKey] [varchar](15) NULL,
	[ApplicationID] [int] NULL,
	[MedicalTreatmentID] [int] NOT NULL,
	[Category] [varchar](35) NULL,
	[TreatmentDate] [datetime] NULL,
	[TreatmentDetails] [varchar](2000) NULL
) ON [PRIMARY]
GO
