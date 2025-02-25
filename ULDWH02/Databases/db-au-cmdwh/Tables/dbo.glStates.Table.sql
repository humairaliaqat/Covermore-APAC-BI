USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[glStates]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[glStates](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[ParentStateCode] [varchar](50) NOT NULL,
	[ParentStateDescription] [nvarchar](255) NULL,
	[StateCode] [varchar](50) NOT NULL,
	[StateDescription] [nvarchar](255) NULL,
	[CreateBatchID] [int] NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateBatchID] [int] NULL,
	[UpdateDateTime] [datetime] NULL,
	[DeleteDateTime] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [cidx] ON [dbo].[glStates]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[glStates]
(
	[StateCode] ASC
)
INCLUDE([StateDescription],[ParentStateCode],[ParentStateDescription]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_parent]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_parent] ON [dbo].[glStates]
(
	[ParentStateCode] ASC
)
INCLUDE([StateCode],[StateDescription],[ParentStateDescription]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
