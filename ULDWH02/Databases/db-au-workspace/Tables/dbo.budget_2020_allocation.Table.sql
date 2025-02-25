USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[budget_2020_allocation]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[budget_2020_allocation](
	[Country] [nvarchar](10) NOT NULL,
	[JV] [nvarchar](20) NULL,
	[Channel] [nvarchar](100) NULL,
	[OutletAlphaKey] [nvarchar](50) NOT NULL,
	[FinanceProductCode] [nvarchar](50) NULL,
	[Month] [date] NULL,
	[LYSales] [float] NULL,
	[LYPremium] [float] NULL,
	[LYPolicyCount] [int] NULL,
	[RatioSales] [float] NULL,
	[RatioCount] [numeric](31, 19) NULL
) ON [PRIMARY]
GO
