USE [db-au-star]
GO
/****** Object:  Table [COVERMORE\chris.herron].[factPolicyTarget2020]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [COVERMORE\chris.herron].[factPolicyTarget2020](
	[Date_SK] [int] NOT NULL,
	[Country] [nvarchar](10) NOT NULL,
	[OutletSK] [int] NOT NULL,
	[BudgetAmountSales] [float] NULL,
	[BudgetAmountPremium] [float] NULL,
	[PolicyCountBudget] [float] NULL,
	[LoadDate] [datetime] NOT NULL,
	[updateDate] [int] NULL,
	[LoadID] [int] NOT NULL,
	[updateID] [int] NULL,
	[FinanceProductCode] [nvarchar](50) NULL
) ON [PRIMARY]
GO
