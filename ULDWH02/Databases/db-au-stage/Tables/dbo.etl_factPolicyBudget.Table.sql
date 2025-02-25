USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_factPolicyBudget]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_factPolicyBudget](
	[DateSK] [int] NULL,
	[DomainSK] [int] NOT NULL,
	[OutletSK] [int] NOT NULL,
	[BudgetAmount] [float] NULL,
	[AcceleratorAmount] [float] NULL
) ON [PRIMARY]
GO
