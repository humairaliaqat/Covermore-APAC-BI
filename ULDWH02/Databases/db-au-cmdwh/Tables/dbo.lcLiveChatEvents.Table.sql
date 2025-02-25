USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[lcLiveChatEvents]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[lcLiveChatEvents](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[ChatID] [nvarchar](50) NULL,
	[EventTime] [datetime] NULL,
	[Author] [nvarchar](max) NULL,
	[AgentID] [nvarchar](max) NULL,
	[EventType] [nvarchar](255) NULL,
	[EventText] [nvarchar](max) NULL,
	[BatchID] [int] NULL,
	[AuthorType] [varchar](30) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [cid]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE UNIQUE CLUSTERED INDEX [cid] ON [dbo].[lcLiveChatEvents]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_chatid]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_chatid] ON [dbo].[lcLiveChatEvents]
(
	[ChatID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
