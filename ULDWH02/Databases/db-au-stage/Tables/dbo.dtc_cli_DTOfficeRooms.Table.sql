USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_DTOfficeRooms]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_DTOfficeRooms](
	[DTOffice_ID] [varchar](32) NULL,
	[OfficeName] [varchar](255) NULL,
	[TotalRooms] [int] NULL,
	[DaysPerWeek] [int] NULL,
	[CostPerDay] [float] NULL
) ON [PRIMARY]
GO
