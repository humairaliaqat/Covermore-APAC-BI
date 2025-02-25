USE [db-au-workspace]
GO
/****** Object:  Table [COVERMORE\mercedee].[segCluster]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [COVERMORE\mercedee].[segCluster](
	[SegmentID] [int] NULL,
	[cluster] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [IX_SegmentID]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_SegmentID] ON [COVERMORE\mercedee].[segCluster]
(
	[SegmentID] ASC
)
INCLUDE([cluster]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
