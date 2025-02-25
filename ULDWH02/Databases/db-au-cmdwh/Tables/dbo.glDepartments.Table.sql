USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[glDepartments]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[glDepartments](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[ParentDepartmentCode] [varchar](50) NOT NULL,
	[ParentDepartmentDescription] [nvarchar](255) NULL,
	[DepartmentCode] [varchar](50) NOT NULL,
	[DepartmentDescription] [nvarchar](255) NULL,
	[DepartmentTypeCode] [varchar](50) NOT NULL,
	[DepartmentTypeDescription] [nvarchar](200) NULL,
	[DepartmentEntityCode] [varchar](50) NOT NULL,
	[DepartmentEntityDescription] [nvarchar](200) NULL,
	[CreateBatchID] [int] NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateBatchID] [int] NULL,
	[UpdateDateTime] [datetime] NULL,
	[DeleteDateTime] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [cidx] ON [dbo].[glDepartments]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[glDepartments]
(
	[DepartmentCode] ASC
)
INCLUDE([ParentDepartmentCode],[ParentDepartmentDescription],[DepartmentDescription],[DepartmentTypeCode],[DepartmentTypeDescription],[DepartmentEntityCode],[DepartmentEntityDescription]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_parent]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_parent] ON [dbo].[glDepartments]
(
	[ParentDepartmentCode] ASC
)
INCLUDE([DepartmentCode],[DepartmentDescription],[ParentDepartmentDescription]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
