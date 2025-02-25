USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_UKEMC_tblSurveyAnswers_UK]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_UKEMC_tblSurveyAnswers_UK](
	[AnswerID] [int] NOT NULL,
	[SurveyID] [int] NULL,
	[QuesID] [int] NULL,
	[Answer] [varchar](255) NULL
) ON [PRIMARY]
GO
