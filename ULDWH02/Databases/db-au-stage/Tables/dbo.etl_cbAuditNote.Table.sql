USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_cbAuditNote]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_cbAuditNote](
	[CountryKey] [varchar](2) NOT NULL,
	[AuditKey] [varchar](50) NULL,
	[CaseKey] [varchar](17) NULL,
	[UserKey] [varchar](33) NULL,
	[NoteKey] [varchar](20) NULL,
	[AuditID] [varchar](50) NULL,
	[AuditUserName] [varchar](255) NULL,
	[AuditDateTime] [datetime] NULL,
	[AuditAction] [varchar](10) NULL,
	[CaseNo] [varchar](14) NULL,
	[UserID] [varchar](30) NULL,
	[isIncluded] [varchar](1) NULL,
	[NoteDate] [datetime] NULL,
	[NoteType] [varchar](2) NULL,
	[MBFSent] [varchar](1) NULL,
	[Note] [varchar](max) NULL,
	[CreateDate] [datetime] NULL,
	[NoteID] [int] NOT NULL,
	[DeleteDate] [datetime] NULL,
	[AuditCount] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
