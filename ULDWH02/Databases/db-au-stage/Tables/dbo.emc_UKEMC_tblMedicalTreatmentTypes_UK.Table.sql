USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_UKEMC_tblMedicalTreatmentTypes_UK]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_UKEMC_tblMedicalTreatmentTypes_UK](
	[RxTypeCode] [tinyint] NOT NULL,
	[RxType] [varchar](35) NULL
) ON [PRIMARY]
GO
