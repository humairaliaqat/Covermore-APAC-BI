USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[budget_2020_phasing]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[budget_2020_phasing](
	[Country] [nvarchar](10) NOT NULL,
	[JV] [nvarchar](20) NULL,
	[Channel] [nvarchar](100) NULL,
	[FinanceProductCode] [nvarchar](50) NULL,
	[Date] [smalldatetime] NOT NULL,
	[Month] [date] NULL,
	[DayWeightSales] [float] NULL,
	[DayWeightCount] [numeric](38, 6) NULL
) ON [PRIMARY]
GO
