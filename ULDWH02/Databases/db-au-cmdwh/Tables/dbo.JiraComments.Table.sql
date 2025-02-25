USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[JiraComments]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[JiraComments](
	[IssueKey] [varchar](255) NULL,
	[CommentKey] [int] NULL,
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
	[isLatest] [char](1) NULL,
	[ETLInsertDate] [datetime] NULL,
	[ETLUpdateDate] [datetime] NULL,
	[PublicComment] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_JiraComments_IssueKeyCommentKey]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_JiraComments_IssueKeyCommentKey] ON [dbo].[JiraComments]
(
	[IssueKey] ASC,
	[CommentKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[JiraComments] ADD  DEFAULT ('Y') FOR [isLatest]
GO
ALTER TABLE [dbo].[JiraComments] ADD  DEFAULT (getdate()) FOR [ETLInsertDate]
GO
