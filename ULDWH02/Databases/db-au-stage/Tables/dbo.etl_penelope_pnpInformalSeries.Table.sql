USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penelope_pnpInformalSeries]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penelope_pnpInformalSeries](
	[InformalSeriesID] [int] NOT NULL,
	[CaseSeriesID] [int] NOT NULL,
	[UserSK] [int] NULL,
	[KUserID] [int] NOT NULL,
	[InformalSeriesName] [nvarchar](50) NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[Status] [nvarchar](30) NULL
) ON [PRIMARY]
GO
