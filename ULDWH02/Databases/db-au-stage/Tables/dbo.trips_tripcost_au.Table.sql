USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_tripcost_au]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_tripcost_au](
	[TripCostId] [int] NOT NULL,
	[TripCostDetails] [varchar](100) NULL,
	[TripCostVal] [money] NULL,
	[Seq] [smallint] NULL,
	[PlanType] [varchar](1) NULL,
	[TripCostSetID] [tinyint] NULL,
	[Enabled] [bit] NULL,
	[FamTripCostVal] [money] NULL
) ON [PRIMARY]
GO
