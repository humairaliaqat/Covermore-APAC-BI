USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_scrmStrikeRate]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_scrmStrikeRate](
	[Month] [datetime] NULL,
	[CountryCode] [nvarchar](10) NOT NULL,
	[AlphaCode] [nvarchar](20) NULL,
	[PolicyCount] [int] NULL,
	[TicketCount] [int] NULL
) ON [PRIMARY]
GO
