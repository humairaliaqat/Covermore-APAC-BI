USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_excel_budget]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_excel_budget](
	[Days] [nvarchar](50) NULL,
	[FiscalYear] [float] NULL,
	[AlphaCode] [nvarchar](50) NULL,
	[Country] [nvarchar](50) NULL,
	[CurrencyCode] [nvarchar](50) NULL,
	[Company] [nvarchar](50) NULL,
	[BudgetAmount] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_excel_budget]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_excel_budget] ON [dbo].[etl_excel_budget]
(
	[FiscalYear] ASC
)
INCLUDE([Country],[Company],[AlphaCode],[BudgetAmount],[Days],[CurrencyCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
