USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[npsSentiment]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[npsSentiment](
	[BIRowID] [bigint] NULL,
	[ScoreTag] [varchar](max) NULL,
	[Agreement] [varchar](max) NULL,
	[Subjectivity] [varchar](max) NULL,
	[Confidence] [int] NULL,
	[Irony] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [ncidx]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [ncidx] ON [dbo].[npsSentiment]
(
	[BIRowID] ASC
)
INCLUDE([ScoreTag],[Agreement],[Subjectivity],[Confidence],[Irony]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
