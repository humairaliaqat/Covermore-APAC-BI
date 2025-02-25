USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[glProjects_28112022]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[glProjects_28112022](
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
