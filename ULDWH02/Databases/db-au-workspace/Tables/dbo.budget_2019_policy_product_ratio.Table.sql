USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[budget_2019_policy_product_ratio]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[budget_2019_policy_product_ratio](
	[Domain] [varchar](2) NULL,
	[JV] [nvarchar](3) NULL,
	[Channel] [varchar](19) NULL,
	[Month] [date] NULL,
	[Product] [nvarchar](4000) NULL,
	[PremiumBudget] [float] NULL,
	[ProductBudgetRatio] [float] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[budget_2019_policy_product_ratio]
(
	[Domain] ASC,
	[JV] ASC,
	[Channel] ASC,
	[Month] ASC
)
INCLUDE([ProductBudgetRatio]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
