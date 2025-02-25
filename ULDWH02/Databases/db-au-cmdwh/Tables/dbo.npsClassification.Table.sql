USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[npsClassification]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[npsClassification](
	[BIRowID] [bigint] NULL,
	[Classification] [varchar](max) NULL,
	[Relevance] [float] NULL,
	[RelevanceRank] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [ncidx]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [ncidx] ON [dbo].[npsClassification]
(
	[BIRowID] ASC
)
INCLUDE([Classification],[Relevance],[RelevanceRank]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
