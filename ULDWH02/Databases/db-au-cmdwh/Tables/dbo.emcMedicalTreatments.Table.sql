USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[emcMedicalTreatments]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emcMedicalTreatments](
	[CountryKey] [varchar](2) NOT NULL,
	[ApplicationKey] [varchar](15) NOT NULL,
	[ApplicationID] [int] NOT NULL,
	[MedicalTreatmentID] [int] NOT NULL,
	[Category] [varchar](35) NULL,
	[TreatmentDate] [datetime] NULL,
	[TreatmentDetails] [varchar](2000) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_emcMedicalTreatments_ApplicationKey]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_emcMedicalTreatments_ApplicationKey] ON [dbo].[emcMedicalTreatments]
(
	[ApplicationKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
