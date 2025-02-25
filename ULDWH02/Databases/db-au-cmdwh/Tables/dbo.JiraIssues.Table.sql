USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[JiraIssues]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[JiraIssues](
	[IssueKey] [varchar](255) NULL,
	[JiraIssueId] [int] NULL,
	[JiraIssueKey] [varchar](255) NULL,
	[IssueSummary] [varchar](500) NULL,
	[IssueDescription] [text] NULL,
	[ReporterName] [varchar](255) NULL,
	[ReporterEmail] [varchar](255) NULL,
	[AssigneeName] [varchar](255) NULL,
	[AssigneeEmail] [varchar](255) NULL,
	[CreatedDate] [datetime] NULL,
	[DueDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[IssueStatus] [varchar](255) NULL,
	[IssueType] [varchar](255) NULL,
	[IssuePriority] [varchar](255) NULL,
	[IssueProjectKey] [varchar](255) NULL,
	[IssueProjectName] [varchar](500) NULL,
	[IssueLabels] [varchar](500) NULL,
	[IssueComponent] [varchar](500) NULL,
	[IssueResolution] [varchar](255) NULL,
	[isLatest] [char](1) NULL,
	[ETLInsertDate] [datetime] NULL,
	[ETLUpdateDate] [datetime] NULL,
	[Urgency] [varchar](50) NULL,
	[Effort] [float] NULL,
	[StoryPoints] [float] NULL,
	[Effort_Done] [float] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_JiraIssues_IssueKey]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_JiraIssues_IssueKey] ON [dbo].[JiraIssues]
(
	[IssueKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[JiraIssues] ADD  DEFAULT ('Y') FOR [isLatest]
GO
ALTER TABLE [dbo].[JiraIssues] ADD  DEFAULT (getdate()) FOR [ETLInsertDate]
GO
