USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_UKEMC_tblMeasurementUnits_UK]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_UKEMC_tblMeasurementUnits_UK](
	[UnitID] [tinyint] NOT NULL,
	[MeasurementTypeCode] [char](1) NULL,
	[Unit] [varchar](20) NULL
) ON [PRIMARY]
GO
