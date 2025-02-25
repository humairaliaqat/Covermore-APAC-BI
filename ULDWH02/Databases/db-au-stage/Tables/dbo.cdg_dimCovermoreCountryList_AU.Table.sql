USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_dimCovermoreCountryList_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_dimCovermoreCountryList_AU](
	[DimCovermoreCountryListID] [int] NOT NULL,
	[CMCountryID1] [int] NOT NULL,
	[CMCountryID2] [int] NULL,
	[CMCountryID3] [int] NULL,
	[CMCountryID4] [int] NULL,
	[CMCountryID5] [int] NULL,
	[CMCountryID6] [int] NULL,
	[CMCountryID7] [int] NULL,
	[CMCountryID8] [int] NULL,
	[CMCountryID9] [int] NULL,
	[CMCountryID10] [int] NULL
) ON [PRIMARY]
GO
