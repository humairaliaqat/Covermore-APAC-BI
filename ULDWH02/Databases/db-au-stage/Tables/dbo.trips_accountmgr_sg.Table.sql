USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_accountmgr_sg]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_accountmgr_sg](
	[AccountMgrId] [int] NOT NULL,
	[Username] [varchar](50) NULL,
	[Fullname] [varchar](100) NULL,
	[Inuse] [bit] NULL
) ON [PRIMARY]
GO
