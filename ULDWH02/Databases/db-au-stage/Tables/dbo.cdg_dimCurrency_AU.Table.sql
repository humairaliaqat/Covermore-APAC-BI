USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_dimCurrency_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_dimCurrency_AU](
	[DimCurrencyID] [int] NOT NULL,
	[CurrencyName] [nvarchar](50) NULL,
	[CurrencyISOCode] [varchar](50) NULL,
	[Symbol] [nvarchar](50) NULL,
	[CultureCode] [varchar](50) NULL,
	[CountryISOCode] [varchar](50) NULL,
	[CountryISO2Code] [varchar](50) NULL,
	[LocaleID] [int] NULL,
	[CurrencyFormat] [varchar](15) NULL
) ON [PRIMARY]
GO
