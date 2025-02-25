USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_dimISOCountry_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_dimISOCountry_AU](
	[DimISOCountryID] [int] NOT NULL,
	[ISOCountryName] [nvarchar](70) NULL,
	[ISO3Code] [char](3) NOT NULL
) ON [PRIMARY]
GO
