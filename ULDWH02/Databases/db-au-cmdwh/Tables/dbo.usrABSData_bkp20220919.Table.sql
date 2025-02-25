USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrABSData_bkp20220919]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrABSData_bkp20220919](
	[Month] [datetime] NULL,
	[FYear] [varchar](7) NULL,
	[CYear] [int] NULL,
	[DurationGroup] [nvarchar](50) NULL,
	[AgeGroup] [nvarchar](50) NULL,
	[Country] [nvarchar](200) NULL,
	[CountryGroup] [nvarchar](200) NULL,
	[Reason] [nvarchar](100) NULL,
	[TravellersCount] [int] NULL,
	[TravellersCountRLTM] [int] NULL
) ON [PRIMARY]
GO
