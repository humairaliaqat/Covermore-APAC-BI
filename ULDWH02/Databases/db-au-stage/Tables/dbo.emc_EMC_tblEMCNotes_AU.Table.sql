USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_EMC_tblEMCNotes_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_EMC_tblEMCNotes_AU](
	[NoteID] [int] NOT NULL,
	[ClientID] [int] NULL,
	[NoteTypeID] [tinyint] NULL,
	[NoteDt] [datetime] NULL,
	[NoteAuthor] [varchar](20) NULL,
	[Note] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
