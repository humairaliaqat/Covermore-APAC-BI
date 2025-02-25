USE [db-au-stage]
GO
/****** Object:  Table [dbo].[StgJiraComments]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StgJiraComments](
	[JiraIssueId] [int] NULL,
	[JiraIssueKey] [varchar](255) NULL,
	[JiraCommentId] [int] NULL,
	[AuthorKey] [varchar](500) NULL,
	[AuthorName] [varchar](500) NULL,
	[AuthorEmailAddress] [varchar](500) NULL,
	[UpdateAuthorKey] [varchar](500) NULL,
	[UpdateAuthorName] [varchar](500) NULL,
	[UpdateAuthorEmailAddress] [varchar](500) NULL,
	[Body] [text] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[PublicComment] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
