USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_claim_recon]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_claim_recon](
	[Domain Country] [varchar](2) NOT NULL,
	[GroupCode] [varchar](2) NOT NULL,
	[Incurred Month] [date] NULL,
	[Loss Month] [date] NULL,
	[UW Month] [date] NULL,
	[EstimateMovement] [decimal](38, 6) NULL,
	[PaymentMovement] [decimal](38, 6) NULL,
	[RecoveryMovement] [decimal](38, 6) NULL,
	[NetPaymentMovement] [decimal](38, 6) NULL,
	[NetRecoveryMovement] [decimal](38, 6) NULL,
	[NetRealRecoveryMovement] [decimal](38, 6) NULL,
	[NetApprovedPaymentMovement] [decimal](38, 6) NULL,
	[SectionCount] [int] NULL
) ON [PRIMARY]
GO
