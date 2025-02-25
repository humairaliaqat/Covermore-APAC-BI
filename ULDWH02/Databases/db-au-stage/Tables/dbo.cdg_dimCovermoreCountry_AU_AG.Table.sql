USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_dimCovermoreCountry_AU_AG]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_dimCovermoreCountry_AU_AG](
	[DimCovermoreCountryID] [int] NOT NULL,
	[CovermoreCountryName] [varchar](50) NULL,
	[ISO3Code] [char](3) NULL
) ON [PRIMARY]
GO
