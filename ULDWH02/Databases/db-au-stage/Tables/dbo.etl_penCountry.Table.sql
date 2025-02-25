USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penCountry]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penCountry](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[DestinationKey] [varchar](71) NULL,
	[CountryID] [int] NOT NULL,
	[Country] [nvarchar](50) NOT NULL,
	[ISO3Code] [char](3) NULL,
	[ISO2Code] [char](2) NULL,
	[Is_Part_Of_ISO_Standard] [bit] NULL
) ON [PRIMARY]
GO
