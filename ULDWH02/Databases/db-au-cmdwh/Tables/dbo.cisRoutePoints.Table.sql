USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cisRoutePoints]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisRoutePoints](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[RoutePoint] [nvarchar](30) NULL,
	[InternalName] [nvarchar](100) NULL,
	[GroupName] [nvarchar](100) NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_cisRoutePoints_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_cisRoutePoints_BIRowID] ON [dbo].[cisRoutePoints]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cisRoutePoints_AgentLogin]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cisRoutePoints_AgentLogin] ON [dbo].[cisRoutePoints]
(
	[RoutePoint] ASC
)
INCLUDE([InternalName],[GroupName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
