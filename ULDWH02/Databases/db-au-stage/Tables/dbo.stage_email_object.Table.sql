USE [db-au-stage]
GO
/****** Object:  Table [dbo].[stage_email_object]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stage_email_object](
	[mailbox] [nvarchar](450) NULL,
	[id] [nvarchar](450) NULL,
	[emailsubject] [nvarchar](max) NULL,
	[conversationid] [nvarchar](max) NULL,
	[conversationtopic] [nvarchar](max) NULL,
	[categories] [nvarchar](max) NULL,
	[datetimecreated] [datetime] NULL,
	[datetimereceived] [datetime] NULL,
	[datetimesent] [datetime] NULL,
	[sender] [nvarchar](max) NULL,
	[replyto] [nvarchar](max) NULL,
	[displayto] [nvarchar](max) NULL,
	[displaycc] [nvarchar](max) NULL,
	[hasattachment] [bit] NULL,
	[importance] [nvarchar](max) NULL,
	[inreplyto] [nvarchar](max) NULL,
	[isresend] [bit] NULL,
	[lastmodifiedname] [nvarchar](max) NULL,
	[lastmodifiedtime] [datetime] NULL,
	[parentfolderid] [nvarchar](450) NULL,
	[size] [bigint] NULL,
	[isread] [bit] NULL,
	[receivedby] [nvarchar](max) NULL,
	[internetheaders] [nvarchar](max) NULL,
	[internetid] [nvarchar](max) NULL,
	[body] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_email_mailbox]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_email_mailbox] ON [dbo].[stage_email_object]
(
	[mailbox] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
