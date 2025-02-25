USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[glClients_ind]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[glClients_ind](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[ParentClientCode] [varchar](50) NOT NULL,
	[ParentClientDescription] [nvarchar](255) NULL,
	[ClientCode] [varchar](50) NOT NULL,
	[ClientDescription] [nvarchar](255) NULL,
	[CreateBatchID] [int] NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateBatchID] [int] NULL,
	[UpdateDateTime] [datetime] NULL,
	[DeleteDateTime] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx_ind]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [cidx_ind] ON [dbo].[glClients_ind]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_ind]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_ind] ON [dbo].[glClients_ind]
(
	[ClientCode] ASC
)
INCLUDE([ParentClientCode],[ParentClientDescription],[ClientDescription]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_parent_ind]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_parent_ind] ON [dbo].[glClients_ind]
(
	[ParentClientCode] ASC
)
INCLUDE([ClientCode],[ClientDescription],[ParentClientDescription]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
