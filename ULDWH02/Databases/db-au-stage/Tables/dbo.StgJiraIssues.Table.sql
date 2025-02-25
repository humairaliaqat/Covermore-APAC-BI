USE [db-au-stage]
GO
/****** Object:  Table [dbo].[StgJiraIssues]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StgJiraIssues](
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
	[Urgency] [varchar](50) NULL,
	[Effort] [float] NULL,
	[StoryPoints] [float] NULL,
	[Effort_Done] [float] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
