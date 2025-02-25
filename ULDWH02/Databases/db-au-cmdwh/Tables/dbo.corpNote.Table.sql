USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[corpNote]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corpNote](
	[CountryKey] [varchar](2) NOT NULL,
	[NoteKey] [varchar](10) NULL,
	[QuoteKey] [varchar](10) NULL,
	[NoteID] [int] NULL,
	[QuoteID] [int] NULL,
	[Username] [varchar](50) NULL,
	[CreateDate] [datetime] NULL,
	[Notes] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_corpNote_NoteKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_corpNote_NoteKey] ON [dbo].[corpNote]
(
	[NoteKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_corpNote_QuoteKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_corpNote_QuoteKey] ON [dbo].[corpNote]
(
	[QuoteKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
