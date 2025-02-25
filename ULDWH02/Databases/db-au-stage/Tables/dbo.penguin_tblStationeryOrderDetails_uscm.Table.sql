USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblStationeryOrderDetails_uscm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblStationeryOrderDetails_uscm](
	[ID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[StationeryType] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[ProductID] [int] NULL
) ON [PRIMARY]
GO
