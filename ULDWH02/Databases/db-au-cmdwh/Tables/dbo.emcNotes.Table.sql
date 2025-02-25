USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[emcNotes]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emcNotes](
	[CountryKey] [varchar](2) NOT NULL,
	[ApplicationKey] [varchar](15) NULL,
	[UserKey] [varchar](10) NULL,
	[NoteKey] [varchar](15) NOT NULL,
	[ApplicationID] [int] NULL,
	[NoteID] [int] NOT NULL,
	[CreateDate] [datetime] NULL,
	[NoteType] [varchar](20) NULL,
	[Author] [varchar](50) NULL,
	[NoteLogin] [varchar](20) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_emcNotes_ApplicationKey]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_emcNotes_ApplicationKey] ON [dbo].[emcNotes]
(
	[ApplicationKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_emcNotes_NoteID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_emcNotes_NoteID] ON [dbo].[emcNotes]
(
	[NoteID] ASC,
	[CountryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
