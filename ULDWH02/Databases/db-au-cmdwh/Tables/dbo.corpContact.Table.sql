USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[corpContact]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corpContact](
	[CountryKey] [varchar](2) NOT NULL,
	[ContactKey] [varchar](10) NULL,
	[QuoteKey] [varchar](10) NULL,
	[ContactID] [int] NOT NULL,
	[QuoteID] [int] NULL,
	[ContactType] [char](1) NULL,
	[Title] [varchar](5) NULL,
	[FirstName] [varchar](15) NULL,
	[Surname] [varchar](25) NULL,
	[DirectPhone] [varchar](15) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_corpContact_ContactKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_corpContact_ContactKey] ON [dbo].[corpContact]
(
	[ContactKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_corpContact_QuoteKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_corpContact_QuoteKey] ON [dbo].[corpContact]
(
	[QuoteKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
