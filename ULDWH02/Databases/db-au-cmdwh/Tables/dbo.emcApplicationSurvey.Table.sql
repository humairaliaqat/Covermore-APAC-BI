USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[emcApplicationSurvey]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emcApplicationSurvey](
	[CountryKey] [varchar](2) NOT NULL,
	[ApplicationKey] [varchar](15) NULL,
	[ApplicationSurveyKey] [varchar](15) NULL,
	[ApplicationID] [int] NULL,
	[ApplicationSurveyID] [int] NOT NULL,
	[CreateDate] [datetime] NULL,
	[SurveyCategory] [varchar](40) NULL,
	[Question] [varchar](255) NULL,
	[Answer] [varchar](255) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_emcApplicationSurvey_ApplicationSurveyKey]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_emcApplicationSurvey_ApplicationSurveyKey] ON [dbo].[emcApplicationSurvey]
(
	[ApplicationSurveyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
