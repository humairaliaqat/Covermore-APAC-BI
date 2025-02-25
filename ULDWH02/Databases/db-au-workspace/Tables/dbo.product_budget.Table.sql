USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[product_budget]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[product_budget](
	[DateSK] [int] NULL,
	[DomainSK] [int] NOT NULL,
	[OutletSK] [int] NOT NULL,
	[JV] [nvarchar](20) NULL,
	[Channel] [nvarchar](100) NULL,
	[BudgetAmount] [float] NULL,
	[ProductSK] [int] NULL,
	[ProductBudgetRatio] [float] NULL,
	[ProductBudget] [float] NULL
) ON [PRIMARY]
GO
