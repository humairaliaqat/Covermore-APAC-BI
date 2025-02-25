USE [db-au-workspace]
GO
/****** Object:  Table [COVERMORE\chris.herron].[cte_sales_weight_by_year_2020]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [COVERMORE\chris.herron].[cte_sales_weight_by_year_2020](
	[Country] [nvarchar](10) NOT NULL,
	[JV] [nvarchar](20) NULL,
	[Channel] [nvarchar](100) NULL,
	[OutletAlphaKey] [nvarchar](50) NOT NULL,
	[Date] [smalldatetime] NULL,
	[DayWeightSales] [float] NULL
) ON [PRIMARY]
GO
