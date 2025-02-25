USE [db-au-workspace]
GO
/****** Object:  Table [COVERMORE\humaira.liaqat].[budget_test_product_ratio]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [COVERMORE\humaira.liaqat].[budget_test_product_ratio](
	[Domain] [varchar](2) NULL,
	[JV] [nvarchar](2) NULL,
	[Channel] [varchar](19) NULL,
	[Month] [date] NULL,
	[ProductSK] [int] NOT NULL,
	[PremiumBudget] [float] NULL,
	[ProductBudgetRatio] [float] NULL
) ON [PRIMARY]
GO
