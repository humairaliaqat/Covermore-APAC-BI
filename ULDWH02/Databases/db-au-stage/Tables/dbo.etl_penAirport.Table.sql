USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penAirport]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penAirport](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[AirportKey] [varchar](71) NULL,
	[AirportID] [int] NOT NULL,
	[CountryID] [int] NOT NULL,
	[AirportCode] [nvarchar](50) NOT NULL,
	[AirportName] [nvarchar](255) NOT NULL
) ON [PRIMARY]
GO
