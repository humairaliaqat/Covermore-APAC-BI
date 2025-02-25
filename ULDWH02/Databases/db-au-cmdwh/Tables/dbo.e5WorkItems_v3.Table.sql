USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[e5WorkItems_v3]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5WorkItems_v3](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Domain] [varchar](5) NULL,
	[ItemKey] [varchar](50) NULL,
	[ID] [int] NOT NULL,
	[Code] [nvarchar](32) NULL,
	[Name] [nvarchar](400) NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
	[DeleteBatchID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_e5WorkItems_v3_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_e5WorkItems_v3_BIRowID] ON [dbo].[e5WorkItems_v3]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_e5WorkItems_v3_ID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_e5WorkItems_v3_ID] ON [dbo].[e5WorkItems_v3]
(
	[ID] ASC,
	[Domain] ASC
)
INCLUDE([Code],[Name]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_e5WorkItems_v3_ItemKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_e5WorkItems_v3_ItemKey] ON [dbo].[e5WorkItems_v3]
(
	[ItemKey] ASC
)
INCLUDE([Code],[Name]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_e5WorkItems_v3_Name]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_e5WorkItems_v3_Name] ON [dbo].[e5WorkItems_v3]
(
	[Name] ASC
)
INCLUDE([Code],[ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
