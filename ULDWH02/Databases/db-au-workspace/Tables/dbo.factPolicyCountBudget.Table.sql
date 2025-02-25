USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[factPolicyCountBudget]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factPolicyCountBudget](
	[DateSK] [int] NOT NULL,
	[DomainSK] [int] NOT NULL,
	[OutletSK] [int] NOT NULL,
	[PolicyCountBudget] [float] NULL,
	[AvgPremiumBudget] [numeric](38, 6) NULL,
	[LoadDate] [datetime] NOT NULL,
	[updateDate] [int] NULL,
	[LoadID] [int] NOT NULL,
	[updateID] [int] NULL,
	[ProductSK] [bigint] NULL
) ON [PRIMARY]
GO
