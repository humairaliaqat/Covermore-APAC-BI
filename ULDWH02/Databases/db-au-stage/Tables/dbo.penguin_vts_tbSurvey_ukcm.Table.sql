USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_vts_tbSurvey_ukcm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_vts_tbSurvey_ukcm](
	[SurveyID] [int] NOT NULL,
	[ProgressDisplayModeId] [int] NULL,
	[NotificationModeID] [int] NULL,
	[ResumeModeID] [tinyint] NULL,
	[CreationDate] [datetime] NOT NULL,
	[LastEntryDate] [datetime] NULL,
	[OpenDate] [datetime] NULL,
	[CloseDate] [datetime] NULL,
	[Title] [nvarchar](255) NULL,
	[RedirectionURL] [varchar](1024) NULL,
	[ThankYouMessage] [nvarchar](4000) NULL,
	[AccessPassword] [nvarchar](255) NULL,
	[SurveyDisplayTimes] [int] NOT NULL,
	[ResultsDisplayTimes] [int] NOT NULL,
	[NavigationEnabled] [bit] NULL,
	[Archive] [bit] NOT NULL,
	[Activated] [bit] NOT NULL,
	[Scored] [bit] NULL,
	[IPExpires] [int] NULL,
	[CookieExpires] [int] NULL,
	[OnlyInvited] [bit] NULL,
	[UnAuthentifiedUserActionID] [int] NULL,
	[AllowMultipleUserNameSubmissions] [bit] NULL,
	[QuestionNumberingDisabled] [bit] NULL,
	[AllowMultipleNSurveySubmissions] [bit] NULL,
	[MultiLanguageModeId] [int] NULL,
	[MultiLanguageVariable] [nvarchar](50) NULL,
	[DisplayOrder] [int] NULL
) ON [PRIMARY]
GO
