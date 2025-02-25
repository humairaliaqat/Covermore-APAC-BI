USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_excel_Country]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_excel_Country](
	[Continent] [nvarchar](255) NULL,
	[SubContinent] [nvarchar](255) NULL,
	[Country] [nvarchar](255) NULL,
	[ISO2Code] [nvarchar](255) NULL,
	[ABSCountry] [nvarchar](255) NULL,
	[ABSArea] [nvarchar](255) NULL
) ON [PRIMARY]
GO
