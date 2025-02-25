USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_dimDestination]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_dimDestination](
	[DestinationID] [nvarchar](30) NULL,
	[Destination] [nvarchar](50) NULL,
	[ISO3Code] [varchar](3) NOT NULL,
	[ISO2Code] [varchar](2) NULL,
	[Continent] [nvarchar](255) NOT NULL,
	[SubContinent] [nvarchar](255) NOT NULL,
	[ABSCountry] [nvarchar](255) NOT NULL,
	[ABSArea] [nvarchar](255) NOT NULL,
	[LoadDate] [datetime] NULL,
	[updateDate] [datetime] NULL,
	[LoadID] [int] NULL,
	[updateID] [int] NULL,
	[HashKey] [varbinary](30) NULL,
	[X] [bigint] NULL
) ON [PRIMARY]
GO
