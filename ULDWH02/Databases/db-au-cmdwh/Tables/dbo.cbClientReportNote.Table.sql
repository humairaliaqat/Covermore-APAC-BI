USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cbClientReportNote]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cbClientReportNote](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [nvarchar](2) NOT NULL,
	[ClientReportKey] [nvarchar](20) NOT NULL,
	[NoteKey] [nvarchar](20) NOT NULL,
	[CRNoteKey] [nvarchar](20) NOT NULL,
	[ClientReportID] [int] NOT NULL,
	[NoteID] [int] NOT NULL,
	[CRNoteID] [int] NOT NULL,
	[AttachmentName] [nvarchar](max) NULL,
	[CRNoteIncludeDate] [datetime] NULL,
	[CRAttachIncludeDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_cbClientReportNote_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_cbClientReportNote_BIRowID] ON [dbo].[cbClientReportNote]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cbClientReportNote_ClientReportKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cbClientReportNote_ClientReportKey] ON [dbo].[cbClientReportNote]
(
	[ClientReportKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
