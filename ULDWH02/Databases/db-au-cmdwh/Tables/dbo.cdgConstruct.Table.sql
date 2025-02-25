USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cdgConstruct]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdgConstruct](
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[ConstructID] [int] NOT NULL,
	[Construct] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgConstruct_main]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_cdgConstruct_main] ON [dbo].[cdgConstruct]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgConstruct_id]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgConstruct_id] ON [dbo].[cdgConstruct]
(
	[ConstructID] ASC
)
INCLUDE([Construct]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
