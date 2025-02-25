USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[glCCATeams]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[glCCATeams](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[ParentCCATeamsCode] [varchar](50) NOT NULL,
	[ParentCCATeamsDescription] [nvarchar](255) NULL,
	[CCATeamsCode] [varchar](50) NOT NULL,
	[CCATeamsDescription] [nvarchar](255) NULL,
	[CCATeamsOwnerCode] [varchar](50) NOT NULL,
	[CCATeamsOwnerDescription] [nvarchar](255) NULL,
	[CreateBatchID] [int] NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateBatchID] [int] NULL,
	[UpdateDateTime] [datetime] NULL,
	[DeleteDateTime] [datetime] NULL
) ON [PRIMARY]
GO
