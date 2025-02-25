USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[claim_section_recon]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claim_section_recon](
	[Domain Country] [varchar](2) NULL,
	[Group Code] [varchar](2) NULL,
	[Incurred Month] [date] NULL,
	[Loss Month] [date] NULL,
	[UW Month] [date] NULL,
	[Old_EstimateMovement] [decimal](38, 6) NOT NULL,
	[Old_PaymentMovement] [decimal](38, 6) NOT NULL,
	[Old_RecoveryMovement] [decimal](38, 6) NOT NULL,
	[Old_NetPaymentMovement] [decimal](38, 6) NOT NULL,
	[Old_NetRecoveryMovement] [decimal](38, 6) NOT NULL,
	[Old_NetRealRecoveryMovement] [decimal](38, 6) NOT NULL,
	[Old_NetApprovedPaymentMovement] [decimal](38, 6) NOT NULL,
	[Old_SectionCount] [int] NOT NULL,
	[New_EstimateMovement] [decimal](38, 6) NOT NULL,
	[New_PaymentMovement] [decimal](38, 6) NOT NULL,
	[New_RecoveryMovement] [decimal](38, 6) NOT NULL,
	[New_NetPaymentMovement] [decimal](38, 6) NOT NULL,
	[New_NetRecoveryMovement] [decimal](38, 6) NOT NULL,
	[New_NetRealRecoveryMovement] [decimal](38, 6) NOT NULL,
	[New_NetApprovedPaymentMovement] [decimal](38, 6) NOT NULL,
	[New_SectionCount] [int] NOT NULL,
	[Var_EstimateMovement] [decimal](38, 6) NULL,
	[Var_PaymentMovement] [decimal](38, 6) NULL,
	[Var_RecoveryMovement] [decimal](38, 6) NULL,
	[Var_NetPaymentMovement] [decimal](38, 6) NULL,
	[Var_NetRecoveryMovement] [decimal](38, 6) NULL,
	[Var_NetRealRecoveryMovement] [decimal](38, 6) NULL,
	[Var_NetApprovedPaymentMovement] [decimal](38, 6) NULL,
	[Var_SectionCount] [int] NULL
) ON [PRIMARY]
GO
