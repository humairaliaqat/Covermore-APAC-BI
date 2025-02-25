USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penOutletBanding]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penOutletBanding](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Country] [nvarchar](10) NULL,
	[SuperGroupName] [nvarchar](255) NULL,
	[GroupName] [nvarchar](50) NULL,
	[OutletAlphaKey] [nvarchar](50) NULL,
	[LatestOutletAlphaKey] [nvarchar](50) NULL,
	[SalesLTM] [money] NULL,
	[InGroupRank] [bigint] NULL,
	[MaxRank] [bigint] NULL,
	[Percentile] [float] NULL,
	[SalesTier] [varchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [cidx] ON [dbo].[penOutletBanding]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_OutletAlphaKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_OutletAlphaKey] ON [dbo].[penOutletBanding]
(
	[OutletAlphaKey] ASC
)
INCLUDE([Percentile],[SalesTier]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
