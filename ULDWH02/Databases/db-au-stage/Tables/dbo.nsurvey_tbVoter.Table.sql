USE [db-au-stage]
GO
/****** Object:  Table [dbo].[nsurvey_tbVoter]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[nsurvey_tbVoter](
	[VoterID] [int] NOT NULL,
	[UID] [nvarchar](80) NULL,
	[SurveyID] [int] NULL,
	[ContextUserName] [nvarchar](510) NULL,
	[VoteDate] [datetime] NULL,
	[StartDate] [datetime] NULL,
	[IPSource] [nvarchar](100) NULL,
	[Validated] [bit] NULL,
	[ResumeUID] [nvarchar](80) NULL,
	[ResumeAtPageNumber] [int] NULL,
	[ProgressSaveDate] [datetime] NULL,
	[ResumeQuestionNumber] [int] NULL,
	[ResumeHighestPageNumber] [int] NULL,
	[LanguageCode] [nvarchar](100) NULL,
	[AlphaCode] [nvarchar](50) NULL,
	[Score] [int] NULL,
	[Passed] [bit] NULL
) ON [PRIMARY]
GO
