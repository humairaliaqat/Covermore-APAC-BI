USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[factPolicyPremiumBudget]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factPolicyPremiumBudget](
	[DateSK] [int] NOT NULL,
	[DomainSK] [int] NOT NULL,
	[OutletSK] [int] NOT NULL,
	[BudgetAmount] [float] NULL,
	[LoadDate] [datetime] NOT NULL,
	[updateDate] [int] NULL,
	[LoadID] [int] NOT NULL,
	[updateID] [int] NULL,
	[ProductSK] [bigint] NULL
) ON [PRIMARY]
GO
