USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_tripcost_uk]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_tripcost_uk](
	[TripCostId] [int] NOT NULL,
	[TripCostDetails] [varchar](100) NULL
) ON [PRIMARY]
GO
