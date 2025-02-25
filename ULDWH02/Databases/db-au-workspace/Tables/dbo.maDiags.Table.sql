USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[maDiags]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[maDiags](
	[CaseKey] [nvarchar](20) NOT NULL,
	[CaseNo] [nvarchar](15) NULL,
	[Diagnosis] [nvarchar](max) NULL,
	[DiagnosisDesc] [nvarchar](max) NULL,
	[Sequence] [bigint] NULL,
	[CodeType] [varchar](14) NOT NULL,
	[ConditionOnsetFlag] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
