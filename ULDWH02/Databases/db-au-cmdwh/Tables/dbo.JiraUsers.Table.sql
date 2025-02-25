USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[JiraUsers]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[JiraUsers](
	[UserKey] [varchar](500) NULL,
	[JiraUserKey] [varchar](500) NULL,
	[JiraAccountId] [varchar](500) NULL,
	[name] [varchar](500) NULL,
	[emailAddress] [varchar](500) NULL,
	[displayName] [varchar](500) NULL,
	[active] [varchar](10) NULL,
	[timeZone] [varchar](255) NULL,
	[locale] [varchar](255) NULL,
	[isLatest] [char](1) NULL,
	[ETLInsertDate] [datetime] NULL,
	[ETLUpdateDate] [datetime] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_DimJiraUsers_UserKey]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_DimJiraUsers_UserKey] ON [dbo].[JiraUsers]
(
	[UserKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[JiraUsers] ADD  DEFAULT ('Y') FOR [isLatest]
GO
ALTER TABLE [dbo].[JiraUsers] ADD  DEFAULT (getdate()) FOR [ETLInsertDate]
GO
