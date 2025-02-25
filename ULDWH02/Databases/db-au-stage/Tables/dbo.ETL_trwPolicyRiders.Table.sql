USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_trwPolicyRiders]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_trwPolicyRiders](
	[SellingPlanRiderID] [numeric](18, 0) NULL,
	[PremiumPercent] [numeric](18, 2) NULL,
	[PolicyRiderID] [numeric](18, 0) NULL,
	[PolicyDetailID] [numeric](18, 0) NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY]
GO
