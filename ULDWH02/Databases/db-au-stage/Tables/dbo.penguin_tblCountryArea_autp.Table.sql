USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblCountryArea_autp]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblCountryArea_autp](
	[CountryAreaId] [int] NOT NULL,
	[CountryId] [int] NOT NULL,
	[AreaId] [int] NOT NULL
) ON [PRIMARY]
GO
