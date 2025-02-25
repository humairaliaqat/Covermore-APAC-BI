USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[FinesseLogger]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FinesseLogger](
	[RunId] [int] NULL,
	[StepNum] [int] NULL,
	[SqlQryStmt] [varchar](4000) NULL,
	[LogDt] [datetime] NULL
) ON [PRIMARY]
GO
