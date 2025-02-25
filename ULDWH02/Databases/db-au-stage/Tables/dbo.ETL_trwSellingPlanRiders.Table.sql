USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_trwSellingPlanRiders]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_trwSellingPlanRiders](
	[SellingPlanRiderID] [numeric](18, 0) NULL,
	[SellingPlanID] [numeric](18, 0) NULL,
	[CostPlanRiderID] [numeric](18, 0) NULL,
	[PremiumPercent] [numeric](18, 2) NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [varchar](256) NULL,
	[ModifiedDateTime] [datetime] NULL,
	[ModifiedBy] [varchar](256) NULL,
	[IP] [varchar](50) NULL,
	[Session] [varchar](500) NULL,
	[RowID] [uniqueidentifier] NULL,
	[Preexistingridercoverage] [bit] NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY]
GO
