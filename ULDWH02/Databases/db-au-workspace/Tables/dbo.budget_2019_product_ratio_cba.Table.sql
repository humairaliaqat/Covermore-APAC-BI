USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[budget_2019_product_ratio_cba]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[budget_2019_product_ratio_cba](
	[Domain] [varchar](2) NULL,
	[JV] [nvarchar](3) NULL,
	[Channel] [varchar](19) NULL,
	[Month] [date] NULL,
	[Product] [nvarchar](4000) NULL,
	[PremiumBudget] [float] NULL,
	[ProductBudgetRatio] [float] NULL
) ON [PRIMARY]
GO
