USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_Country_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_Country_AU](
	[CountryId] [int] NOT NULL,
	[Country] [nvarchar](50) NULL,
	[Code] [char](3) NULL,
	[CountryIsoCode] [nvarchar](255) NULL
) ON [PRIMARY]
GO
