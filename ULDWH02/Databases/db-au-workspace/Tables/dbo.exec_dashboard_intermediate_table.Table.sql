USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[exec_dashboard_intermediate_table]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[exec_dashboard_intermediate_table](
	[Channel] [nvarchar](100) NOT NULL,
	[FiscalYearEnd] [int] NULL,
	[TotalPolicyCount] [int] NULL,
	[TotalPremium] [money] NULL,
	[AvgPremium] [money] NULL,
	[QuoteConversionRate] [numeric](38, 15) NULL,
	[TotalQuoteCount] [bigint] NULL,
	[TotalPolicyCountYoYChange] [int] NULL,
	[TotalPremiumYoYChange] [money] NULL,
	[AvgPremiumYoYChange] [money] NULL,
	[TotalQuoteCountYoYChange] [bigint] NULL,
	[QuoteConversionRateYoYChange] [numeric](38, 15) NULL
) ON [PRIMARY]
GO
