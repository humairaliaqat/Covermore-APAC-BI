USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[lcLiveChatRaw]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[lcLiveChatRaw](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[ChatID] [varchar](50) NULL,
	[DataType] [varchar](10) NULL,
	[ChatJSON] [nvarchar](max) NULL,
	[BatchID] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [cidx]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE UNIQUE CLUSTERED INDEX [cidx] ON [dbo].[lcLiveChatRaw]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_batch]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_batch] ON [dbo].[lcLiveChatRaw]
(
	[BatchID] ASC,
	[DataType] ASC
)
INCLUDE([ChatID],[ChatJSON]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_chat]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_chat] ON [dbo].[lcLiveChatRaw]
(
	[ChatID] ASC
)
INCLUDE([ChatJSON]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
