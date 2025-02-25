USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_EMC_tblMedicalConditionsGroup_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_EMC_tblMedicalConditionsGroup_AU](
	[Counter] [int] NOT NULL,
	[ClientID] [int] NULL,
	[Score] [numeric](18, 2) NULL,
	[DeniedAccepted] [varchar](1) NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[Status] [varchar](50) NULL
) ON [PRIMARY]
GO
