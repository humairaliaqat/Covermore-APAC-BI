USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_EMC_tblAppSurveys_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_EMC_tblAppSurveys_AU](
	[SAH_ID] [int] NOT NULL,
	[SurveyID] [int] NULL,
	[QuesID] [int] NULL,
	[AnsID] [int] NULL,
	[ClientID] [int] NULL,
	[CreatedDt] [datetime] NULL,
	[Login] [varchar](15) NULL
) ON [PRIMARY]
GO
