USE [db-au-stage]
GO
/****** Object:  Table [dbo].[carebase_CCN_CASENOTE_aucm]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[carebase_CCN_CASENOTE_aucm](
	[CASE_NO] [varchar](14) NULL,
	[AC] [varchar](30) NULL,
	[INCLUDE] [varchar](1) NULL,
	[NOTE_DATE] [datetime] NULL,
	[TYPE] [varchar](2) NULL,
	[MBFSENT] [varchar](1) NULL,
	[NOTES] [nvarchar](max) NULL,
	[CREATED_DT] [datetime] NULL,
	[ROWID] [int] NOT NULL,
	[DELETE_DATE] [datetime] NULL,
	[AUDIT_COUNT] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
