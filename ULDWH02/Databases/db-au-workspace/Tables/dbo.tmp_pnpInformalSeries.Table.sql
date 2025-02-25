USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_pnpInformalSeries]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_pnpInformalSeries](
	[InformalSeriesSK] [int] IDENTITY(1,1) NOT NULL,
	[InformalSeriesID] [int] NOT NULL,
	[UserSK] [int] NOT NULL,
	[KUserID] [int] NOT NULL,
	[InformalSeriesName] [nvarchar](50) NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[Status] [varchar](6) NOT NULL,
	[CreatedDatetime] [datetime2](7) NOT NULL,
	[UpdatedDatetime] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
