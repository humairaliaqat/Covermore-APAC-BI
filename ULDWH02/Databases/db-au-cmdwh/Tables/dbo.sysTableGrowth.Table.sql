USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[sysTableGrowth]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sysTableGrowth](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[TimeStamp] [datetime] NOT NULL,
	[DatabaseName] [varchar](255) NOT NULL,
	[TableName] [varchar](255) NOT NULL,
	[RowCounts] [bigint] NOT NULL,
	[TotalSpaceMB] [numeric](38, 6) NULL,
	[UsedSpaceMB] [numeric](38, 6) NULL,
	[DataSpaceMB] [numeric](38, 6) NULL,
	[IndexSpaceMB] [numeric](38, 6) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx] ON [dbo].[sysTableGrowth]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_database]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_database] ON [dbo].[sysTableGrowth]
(
	[DatabaseName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_date]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_date] ON [dbo].[sysTableGrowth]
(
	[TimeStamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
