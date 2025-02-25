USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrJabberHistory]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrJabberHistory](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[ToJID] [nvarchar](200) NOT NULL,
	[FromJID] [nvarchar](200) NOT NULL,
	[SentDate] [datetime] NOT NULL,
	[SentDateUTC] [datetime] NOT NULL,
	[Subject] [nvarchar](128) NULL,
	[ThreadID] [nvarchar](128) NULL,
	[MessageType] [nvarchar](1) NOT NULL,
	[Direction] [nvarchar](1) NOT NULL,
	[BodyLength] [int] NOT NULL,
	[MessageLength] [int] NOT NULL,
	[BodyString] [nvarchar](2000) NULL,
	[MessageString] [nvarchar](1000) NULL,
	[BodyText] [nvarchar](2000) NULL,
	[MessageText] [nvarchar](1000) NULL,
	[HistoryFlag] [nvarchar](1) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_usrJabberHistory_BIRowID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE CLUSTERED INDEX [idx_usrJabberHistory_BIRowID] ON [dbo].[usrJabberHistory]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrJabberHistory_JIDPair]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrJabberHistory_JIDPair] ON [dbo].[usrJabberHistory]
(
	[FromJID] ASC,
	[ToJID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrJabberHistory_ThreadID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrJabberHistory_ThreadID] ON [dbo].[usrJabberHistory]
(
	[ThreadID] ASC
)
INCLUDE([SentDate],[ToJID],[FromJID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
