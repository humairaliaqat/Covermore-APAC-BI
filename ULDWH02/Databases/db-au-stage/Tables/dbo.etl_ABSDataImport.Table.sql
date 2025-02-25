USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_ABSDataImport]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_ABSDataImport](
	[Month] [varchar](500) NULL,
	[DurationGroup] [varchar](50) NULL,
	[AgeGroup] [varchar](50) NULL,
	[Country] [varchar](200) NULL,
	[Reason] [varchar](100) NULL,
	[TravellerCount] [varchar](10) NULL
) ON [PRIMARY]
GO
