USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cisCSQ]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisCSQ](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CSQKey] [nvarchar](50) NOT NULL,
	[ContactServiceQueueID] [int] NOT NULL,
	[ProfileID] [int] NOT NULL,
	[CSQName] [nvarchar](50) NOT NULL,
	[SLAPercentage] [int] NOT NULL,
	[SLA] [int] NOT NULL,
	[SelectionCriteria] [nvarchar](50) NOT NULL,
	[isActive] [bit] NOT NULL,
	[DateInactive] [datetime] NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_cisCSQ_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_cisCSQ_BIRowID] ON [dbo].[cisCSQ]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cisCSQ_CSQKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cisCSQ_CSQKey] ON [dbo].[cisCSQ]
(
	[CSQKey] ASC
)
INCLUDE([CSQName],[SLAPercentage],[SLA],[isActive],[DateInactive]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
