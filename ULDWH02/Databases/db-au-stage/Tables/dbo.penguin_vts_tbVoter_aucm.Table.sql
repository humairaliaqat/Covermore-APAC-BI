USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_vts_tbVoter_aucm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_vts_tbVoter_aucm](
	[VoterID] [int] NOT NULL,
	[UID] [nvarchar](40) NULL,
	[SurveyID] [int] NULL,
	[ContextUserName] [nvarchar](255) NULL,
	[VoteDate] [datetime] NULL,
	[StartDate] [datetime] NULL,
	[IPSource] [nvarchar](50) NULL,
	[Validated] [bit] NULL,
	[ResumeUID] [nvarchar](40) NULL,
	[ResumeAtPageNumber] [int] NULL,
	[ProgressSaveDate] [datetime] NULL,
	[ResumeQuestionNumber] [int] NULL,
	[ResumeHighestPageNumber] [int] NULL,
	[LanguageCode] [nvarchar](50) NULL,
	[AlphaCode] [nvarchar](25) NULL,
	[Score] [int] NULL,
	[Passed] [bit] NULL,
	[CountryCode] [nvarchar](50) NULL
) ON [PRIMARY]
GO
