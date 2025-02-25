USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_factPolicyBudgetTemp]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_factPolicyBudgetTemp](
	[Date] [datetime] NOT NULL,
	[DomainID] [int] NULL,
	[OutletAlphaKey] [nvarchar](58) NULL,
	[BudgetAmount] [float] NULL,
	[AcceleratorAmount] [float] NULL
) ON [PRIMARY]
GO
