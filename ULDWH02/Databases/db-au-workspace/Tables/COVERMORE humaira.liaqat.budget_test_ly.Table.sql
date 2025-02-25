USE [db-au-workspace]
GO
/****** Object:  Table [COVERMORE\humaira.liaqat].[budget_test_ly]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [COVERMORE\humaira.liaqat].[budget_test_ly](
	[Country] [nvarchar](10) NOT NULL,
	[JV] [nvarchar](20) NULL,
	[Channel] [nvarchar](100) NULL,
	[OutletAlphaKey] [nvarchar](50) NOT NULL,
	[Date] [datetime] NOT NULL,
	[ProductSK] [int] NULL,
	[DW] [nvarchar](30) NULL,
	[Month] [date] NULL,
	[LYPolicyCount] [int] NULL,
	[LYSales] [float] NULL,
	[LYPremium] [float] NULL
) ON [PRIMARY]
GO
