USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[factPolicyTarget]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factPolicyTarget](
	[DateSK] [int] NULL,
	[DomainSK] [int] NOT NULL,
	[OutletSK] [int] NOT NULL,
	[BudgetAmount] [float] NULL,
	[AcceleratorAmount] [float] NULL,
	[LoadDate] [datetime] NOT NULL,
	[updateDate] [int] NULL,
	[LoadID] [int] NULL,
	[updateID] [int] NULL,
	[ProductSK] [bigint] NULL
) ON [PRIMARY]
GO
