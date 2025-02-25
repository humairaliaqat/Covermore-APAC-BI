USE [db-au-workspace]
GO
/****** Object:  Table [ws].[ClaimPaymentMovement_06022024]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ws].[ClaimPaymentMovement_06022024](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[ClaimKey] [varchar](40) NOT NULL,
	[SectionKey] [varchar](40) NULL,
	[SectionCode] [varchar](25) NULL,
	[PaymentKey] [varchar](40) NULL,
	[AuditKey] [varchar](50) NOT NULL,
	[PaymentDate] [datetime] NULL,
	[Currency] [varchar](3) NULL,
	[FXRate] [decimal](25, 10) NULL,
	[PaymentStatus] [varchar](4) NULL,
	[PaymentAmount] [decimal](20, 6) NOT NULL,
	[ITCDAM] [decimal](20, 6) NULL,
	[NetPayment] [decimal](20, 6) NULL,
	[PaymentMovement] [decimal](20, 6) NULL,
	[ITCDAMMovement] [decimal](20, 6) NULL,
	[NetPaymentMovement] [decimal](20, 6) NULL,
	[asRecovery] [int] NOT NULL,
	[asEstimate] [int] NOT NULL
) ON [PRIMARY]
GO
