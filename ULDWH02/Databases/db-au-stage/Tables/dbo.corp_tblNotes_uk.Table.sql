USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_tblNotes_uk]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_tblNotes_uk](
	[NoteId] [int] NOT NULL,
	[Qtid] [int] NULL,
	[NoteAc] [varchar](50) NULL,
	[Notedate] [datetime] NULL,
	[Notes] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
