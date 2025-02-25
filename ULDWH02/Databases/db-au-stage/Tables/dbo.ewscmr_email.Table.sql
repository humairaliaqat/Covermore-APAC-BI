USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ewscmr_email]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ewscmr_email](
	[mailbox] [nvarchar](450) NULL,
	[id] [nvarchar](450) NULL,
	[emailsubject] [nvarchar](max) NULL,
	[conversationid] [nvarchar](max) NULL,
	[conversationtopic] [nvarchar](max) NULL,
	[catgories] [nvarchar](max) NULL,
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
	[isnew] [bit] NULL,
	[isread] [bit] NULL,
	[receivedby] [nvarchar](max) NULL,
	[internetheaders] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
