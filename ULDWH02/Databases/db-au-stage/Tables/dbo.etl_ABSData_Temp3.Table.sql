USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_ABSData_Temp3]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_ABSData_Temp3](
	[Month] [datetime] NULL,
	[FYear] [varchar](33) NULL,
	[CYear] [int] NULL,
	[AgeGroup] [varchar](7) NULL,
	[DurationGroup] [varchar](10) NOT NULL,
	[Country] [varchar](200) NULL,
	[CountryGroup] [varchar](32) NOT NULL,
	[Reason] [varchar](100) NULL,
	[TravellersCount] [int] NULL,
	[TravellersCountRLTM] [int] NULL,
	[FirstMonth] [datetime] NULL,
	[LastMonth] [datetime] NULL
) ON [PRIMARY]
GO
