USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[budget_product_ratio]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[budget_product_ratio](
	[DomainSK] [int] NOT NULL,
	[JV] [nvarchar](3) NULL,
	[Channel] [varchar](19) NOT NULL,
	[ProductSK] [int] NOT NULL,
	[Month] [date] NULL,
	[ProductBudgetRatio] [float] NULL
) ON [PRIMARY]
GO
