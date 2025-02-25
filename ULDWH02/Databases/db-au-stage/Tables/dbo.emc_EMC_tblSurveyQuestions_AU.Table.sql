USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_EMC_tblSurveyQuestions_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_EMC_tblSurveyQuestions_AU](
	[SQ_ID] [int] NOT NULL,
	[SurveyID] [int] NOT NULL,
	[QuesID] [int] NOT NULL,
	[Question] [varchar](200) NULL
) ON [PRIMARY]
GO
