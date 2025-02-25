USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_dimAirportList_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_dimAirportList_AU](
	[DimAirportListID] [int] NOT NULL,
	[AirportID1] [int] NOT NULL,
	[AirportID2] [int] NULL,
	[AirportID3] [int] NULL,
	[AirportID4] [int] NULL,
	[AirportID5] [int] NULL,
	[AirportID6] [int] NULL,
	[AirportID7] [int] NULL,
	[AirportID8] [int] NULL,
	[AirportID9] [int] NULL,
	[AirportID10] [int] NULL
) ON [PRIMARY]
GO
