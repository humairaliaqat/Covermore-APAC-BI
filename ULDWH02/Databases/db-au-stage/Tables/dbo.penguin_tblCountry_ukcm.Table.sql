USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblCountry_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblCountry_ukcm](
	[CountryId] [int] NOT NULL,
	[Country] [nvarchar](50) NOT NULL,
	[ISO3Code] [char](3) NULL,
	[ISO2Code] [char](2) NULL,
	[Is_Part_Of_ISO_Standard] [bit] NULL
) ON [PRIMARY]
GO
