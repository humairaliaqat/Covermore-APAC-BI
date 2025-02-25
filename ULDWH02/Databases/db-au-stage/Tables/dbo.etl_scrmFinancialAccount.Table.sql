USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_scrmFinancialAccount]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_scrmFinancialAccount](
	[CountryKey] [varchar](2) NOT NULL,
	[AlphaCode] [nvarchar](20) NOT NULL,
	[CurrencyCode] [char](3) NULL
) ON [PRIMARY]
GO
