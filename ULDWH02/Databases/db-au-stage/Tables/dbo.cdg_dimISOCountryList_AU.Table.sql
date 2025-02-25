USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_dimISOCountryList_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_dimISOCountryList_AU](
	[DimISOCountryListID] [int] NOT NULL,
	[ISOCountryID1] [int] NOT NULL,
	[ISOCountryID2] [int] NULL,
	[ISOCountryID3] [int] NULL,
	[ISOCountryID4] [int] NULL,
	[ISOCountryID5] [int] NULL,
	[ISOCountryID6] [int] NULL,
	[ISOCountryID7] [int] NULL,
	[ISOCountryID8] [int] NULL,
	[ISOCountryID9] [int] NULL,
	[ISOCountryID10] [int] NULL
) ON [PRIMARY]
GO
