USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_dimAirport_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_dimAirport_AU](
	[DimAirportID] [int] NOT NULL,
	[IATACode] [char](3) NULL,
	[ISO3CountryCode] [nvarchar](10) NULL,
	[AirportName] [nvarchar](50) NULL,
	[ISO3RegionCode] [nvarchar](10) NULL,
	[City] [nvarchar](255) NULL
) ON [PRIMARY]
GO
