USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_corpContact]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_corpContact](
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
