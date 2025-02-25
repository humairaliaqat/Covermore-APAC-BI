USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_EMC_tblMedicalTreatmentDetails_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_EMC_tblMedicalTreatmentDetails_AU](
	[RxDetsID] [int] NOT NULL,
	[ClientID] [int] NULL,
	[MedRxID] [int] NULL,
	[RxDate] [datetime] NULL,
	[RxDetails] [varchar](2000) NULL
) ON [PRIMARY]
GO
