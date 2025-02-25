USE [db-au-star]
GO
/****** Object:  Table [COVERMORE\humaira.liaqat].[FactPolicyTarget_19022020]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [COVERMORE\humaira.liaqat].[FactPolicyTarget_19022020](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
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
