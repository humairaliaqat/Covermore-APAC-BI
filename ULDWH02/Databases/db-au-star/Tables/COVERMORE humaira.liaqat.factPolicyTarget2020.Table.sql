USE [db-au-star]
GO
/****** Object:  Table [COVERMORE\humaira.liaqat].[factPolicyTarget2020]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [COVERMORE\humaira.liaqat].[factPolicyTarget2020](
	[DateSK] [int] NOT NULL,
	[DomainSK] [nvarchar](10) NOT NULL,
	[OutletSK] [int] NOT NULL,
	[BudgetAmount] [float] NULL,
	[AcceleratorAmount] [int] NULL,
	[LoadDate] [datetime] NOT NULL,
	[updateDate] [int] NULL,
	[LoadID] [int] NOT NULL,
	[updateID] [int] NULL,
	[ProductSK] [int] NULL
) ON [PRIMARY]
GO
