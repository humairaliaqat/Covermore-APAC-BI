USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_ABSData_Temp2]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_ABSData_Temp2](
	[Month] [datetime] NULL,
	[FYear] [varchar](33) NULL,
	[CYear] [int] NULL,
	[DurationGroup] [varchar](10) NOT NULL,
	[AgeGroup] [varchar](7) NULL,
	[Country] [varchar](200) NULL,
	[CountryGroup] [varchar](32) NOT NULL,
	[Reason] [varchar](100) NULL,
	[TravellersCount] [int] NULL
) ON [PRIMARY]
GO
