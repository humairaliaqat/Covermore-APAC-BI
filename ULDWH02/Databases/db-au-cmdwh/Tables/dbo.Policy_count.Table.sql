USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[Policy_count]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Policy_count](
	[Date] [date] NULL,
	[CountryCode] [varchar](10) NULL,
	[Identifier] [varchar](50) NULL,
	[Source] [money] NULL,
	[ODS] [money] NULL,
	[Star] [money] NULL,
	[Subject] [varchar](20) NULL
) ON [PRIMARY]
GO
