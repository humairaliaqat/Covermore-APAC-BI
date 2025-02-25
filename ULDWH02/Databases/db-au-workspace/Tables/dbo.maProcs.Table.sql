USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[maProcs]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[maProcs](
	[CaseKey] [nvarchar](20) NOT NULL,
	[CaseNo] [nvarchar](15) NULL,
	[Procedure] [int] NULL,
	[ProcedureRawDesc] [nvarchar](max) NULL,
	[ProcedureDesc] [nvarchar](max) NULL,
	[ProcGroup] [int] NULL,
	[Sequence] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
