USE [db-au-stage]
GO
/****** Object:  Table [dbo].[refAirportCountry]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[refAirportCountry](
	[Airport_Code] [varchar](50) NULL,
	[Airport_City_Name] [varchar](50) NULL,
	[Airport_Country_Name] [varchar](50) NULL,
	[Airport_Area_Continent] [varchar](50) NULL,
	[PrimaryCountry] [varchar](50) NULL
) ON [PRIMARY]
GO
