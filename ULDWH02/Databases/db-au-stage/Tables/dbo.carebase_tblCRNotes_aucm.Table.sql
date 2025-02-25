USE [db-au-stage]
GO
/****** Object:  Table [dbo].[carebase_tblCRNotes_aucm]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[carebase_tblCRNotes_aucm](
	[RowID] [int] NOT NULL,
	[CRID] [int] NULL,
	[NoteID] [int] NOT NULL,
	[AttachmentName] [nvarchar](max) NULL,
	[CRNoteIncludeDate] [datetime] NULL,
	[CRAttachIncludeDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
