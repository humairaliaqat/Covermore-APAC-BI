USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_trwPolicyEndorsementRequestRiders]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_trwPolicyEndorsementRequestRiders](
	[PolicyEndorsementRequestRiderID] [numeric](18, 0) NULL,
	[PolicyEndorsementRequestID] [numeric](18, 0) NULL,
	[SellingPlanRiderID] [numeric](18, 0) NULL,
	[Preexistingrider] [bit] NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY]
GO
