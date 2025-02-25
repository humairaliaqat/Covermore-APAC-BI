USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[glProjects_ind]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[glProjects_ind](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[ParentProjectCode] [varchar](50) NOT NULL,
	[ParentProjectDescription] [nvarchar](255) NULL,
	[ProjectCode] [varchar](50) NOT NULL,
	[ProjectDescription] [nvarchar](255) NULL,
	[ProjectOwnerCode] [varchar](50) NOT NULL,
	[ProjectOwnerDescription] [nvarchar](255) NULL,
	[CreateBatchID] [int] NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateBatchID] [int] NULL,
	[UpdateDateTime] [datetime] NULL,
	[DeleteDateTime] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx_ind]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [cidx_ind] ON [dbo].[glProjects_ind]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_ind]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_ind] ON [dbo].[glProjects_ind]
(
	[ProjectCode] ASC
)
INCLUDE([ParentProjectCode],[ParentProjectDescription],[ProjectDescription],[ProjectOwnerCode],[ProjectOwnerDescription]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_parent_ind]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_parent_ind] ON [dbo].[glProjects_ind]
(
	[ParentProjectCode] ASC
)
INCLUDE([ProjectCode],[ProjectDescription],[ParentProjectDescription]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
