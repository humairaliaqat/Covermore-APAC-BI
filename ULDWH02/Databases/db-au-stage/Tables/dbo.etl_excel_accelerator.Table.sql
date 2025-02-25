USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_excel_accelerator]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_excel_accelerator](
	[Days] [nvarchar](50) NULL,
	[FiscalYear] [float] NULL,
	[AlphaCode] [nvarchar](50) NULL,
	[Country] [nvarchar](50) NULL,
	[CurrencyCode] [nvarchar](50) NULL,
	[Company] [nvarchar](50) NULL,
	[AcceleratorAmount] [float] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_excel_accelerator]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_excel_accelerator] ON [dbo].[etl_excel_accelerator]
(
	[FiscalYear] ASC,
	[Days] ASC,
	[AlphaCode] ASC
)
INCLUDE([Country],[Company],[AcceleratorAmount],[CurrencyCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
