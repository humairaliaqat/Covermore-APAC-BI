USE [db-au-stage]
GO
/****** Object:  Table [dbo].[StgJiraUsers]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StgJiraUsers](
	[JiraUserKey] [varchar](500) NULL,
	[JiraAccountId] [varchar](500) NULL,
	[name] [varchar](500) NULL,
	[emailAddress] [varchar](500) NULL,
	[displayName] [varchar](500) NULL,
	[active] [varchar](10) NULL,
	[timeZone] [varchar](255) NULL,
	[locale] [varchar](255) NULL
) ON [PRIMARY]
GO
