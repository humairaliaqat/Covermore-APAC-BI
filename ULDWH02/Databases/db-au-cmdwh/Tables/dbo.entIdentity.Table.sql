USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[entIdentity]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[entIdentity](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[IdentityID] [bigint] NOT NULL,
	[CustomerID] [bigint] NOT NULL,
	[UpdateDate] [datetime] NULL,
	[Status] [nvarchar](50) NULL,
	[SourceSystem] [nchar](14) NULL,
	[IDType] [nvarchar](20) NULL,
	[IDSubType] [nvarchar](70) NULL,
	[IDValue] [nvarchar](300) NULL,
	[UpdateBatchID] [bigint] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_entIdentity_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_entIdentity_BIRowID] ON [dbo].[entIdentity]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_entIdentity_CustomerID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_entIdentity_CustomerID] ON [dbo].[entIdentity]
(
	[CustomerID] ASC
)
INCLUDE([BIRowID],[IdentityID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_entIdentity_IDValue]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_entIdentity_IDValue] ON [dbo].[entIdentity]
(
	[IDValue] ASC,
	[IDType] ASC
)
INCLUDE([BIRowID],[CustomerID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
