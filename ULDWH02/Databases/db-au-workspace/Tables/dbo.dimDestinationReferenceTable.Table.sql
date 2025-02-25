USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[dimDestinationReferenceTable]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dimDestinationReferenceTable](
	[DestinationSK] [int] NOT NULL,
	[Destination] [nvarchar](50) NULL,
	[Continent] [nvarchar](100) NULL,
	[SubContinent] [nvarchar](100) NULL,
	[ABSCountry] [nvarchar](200) NULL,
	[ABSArea] [nvarchar](200) NULL
) ON [PRIMARY]
GO
