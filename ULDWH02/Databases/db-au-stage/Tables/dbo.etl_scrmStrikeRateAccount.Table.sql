USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_scrmStrikeRateAccount]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_scrmStrikeRateAccount](
	[CountryKey] [varchar](2) NOT NULL,
	[AlphaCode] [nvarchar](20) NOT NULL,
	[CurrencyCode] [char](3) NULL,
	[CompanyName] [varchar](255) NOT NULL
) ON [PRIMARY]
GO
