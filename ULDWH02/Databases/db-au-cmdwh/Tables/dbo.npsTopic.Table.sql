USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[npsTopic]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[npsTopic](
	[BIRowID] [bigint] NULL,
	[Topic] [varchar](max) NULL,
	[TopicArea] [varchar](max) NULL,
	[Relevance] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [ncidx]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [ncidx] ON [dbo].[npsTopic]
(
	[BIRowID] ASC
)
INCLUDE([Topic],[TopicArea],[Relevance]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
