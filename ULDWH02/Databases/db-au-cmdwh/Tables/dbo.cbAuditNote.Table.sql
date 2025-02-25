USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cbAuditNote]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cbAuditNote](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [nvarchar](2) NOT NULL,
	[CaseKey] [nvarchar](17) NULL,
	[UserKey] [nvarchar](33) NULL,
	[NoteKey] [nvarchar](20) NULL,
	[AuditUserName] [nvarchar](255) NULL,
	[AuditDateTime] [datetime] NULL,
	[AuditDateTimeUTC] [datetime] NULL,
	[AuditDate] [datetime] NULL,
	[AuditAction] [nvarchar](10) NULL,
	[CaseNo] [nvarchar](14) NULL,
	[UserID] [nvarchar](30) NULL,
	[isIncluded] [nvarchar](1) NULL,
	[NoteDate] [datetime] NULL,
	[NoteType] [nvarchar](2) NULL,
	[MBFSent] [nvarchar](1) NULL,
	[Note] [nvarchar](max) NULL,
	[CreateDate] [datetime] NULL,
	[NoteTime] [datetime] NULL,
	[NoteTimeUTC] [datetime] NULL,
	[NoteID] [int] NOT NULL,
	[DeleteDate] [datetime] NULL,
	[AuditCount] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_cbAuditNote_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_cbAuditNote_BIRowID] ON [dbo].[cbAuditNote]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cbAuditNote_AuditDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cbAuditNote_AuditDate] ON [dbo].[cbAuditNote]
(
	[AuditDate] ASC,
	[CountryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cbAuditNote_CaseKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cbAuditNote_CaseKey] ON [dbo].[cbAuditNote]
(
	[CaseKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
