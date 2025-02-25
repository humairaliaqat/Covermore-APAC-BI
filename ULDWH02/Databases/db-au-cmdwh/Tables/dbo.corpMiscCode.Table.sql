USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[corpMiscCode]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corpMiscCode](
	[CountryKey] [varchar](2) NOT NULL,
	[MiscKey] [varchar](10) NULL,
	[MiscID] [int] NULL,
	[MiscCode] [varchar](50) NULL,
	[MiscDesc] [varchar](50) NULL,
	[MiscComments] [varchar](200) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_corpMiscCode_CountryKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_corpMiscCode_CountryKey] ON [dbo].[corpMiscCode]
(
	[CountryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
