USE [db-au-actuary]
GO
/****** Object:  Table [ws].[EMCGroupScore]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ws].[EMCGroupScore](
	[BIRowID] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[SourceSystem] [varchar](15) NULL,
	[SourceKey] [varchar](100) NULL,
	[Max EMC Score] [numeric](6, 2) NULL,
	[Total EMC Score] [numeric](6, 2) NULL,
	[Max EMC Score No Filter] [numeric](6, 2) NULL,
	[Total EMC Score No Filter] [numeric](6, 2) NULL,
 CONSTRAINT [PK_EMCGroupScore] PRIMARY KEY NONCLUSTERED 
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [cidx]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE CLUSTERED INDEX [cidx] ON [ws].[EMCGroupScore]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx] ON [ws].[EMCGroupScore]
(
	[SourceKey] ASC,
	[SourceSystem] ASC
)
INCLUDE([Max EMC Score],[Total EMC Score],[Max EMC Score No Filter],[Total EMC Score No Filter]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
