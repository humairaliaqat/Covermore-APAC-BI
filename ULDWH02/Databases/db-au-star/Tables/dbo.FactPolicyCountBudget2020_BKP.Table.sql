USE [db-au-star]
GO
/****** Object:  Table [dbo].[FactPolicyCountBudget2020_BKP]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactPolicyCountBudget2020_BKP](
	[DateSK] [int] NOT NULL,
	[DomainSK] [int] NOT NULL,
	[OutletSK] [int] NOT NULL,
	[PolicyCountBudget] [float] NULL,
	[AveragePremiumBudget] [int] NULL,
	[LoadDate] [datetime] NOT NULL,
	[updateDate] [int] NULL,
	[LoadID] [int] NOT NULL,
	[updateID] [int] NULL,
	[ProductSK] [int] NULL
) ON [PRIMARY]
GO
