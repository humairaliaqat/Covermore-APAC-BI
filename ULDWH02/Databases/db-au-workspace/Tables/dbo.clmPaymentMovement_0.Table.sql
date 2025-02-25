USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[clmPaymentMovement_0]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clmPaymentMovement_0](
	[ClaimKey] [varchar](40) NOT NULL,
	[SectionKey] [varchar](40) NULL,
	[SectionCode] [varchar](25) NULL,
	[PaymentKey] [varchar](40) NULL,
	[AuditKey] [varchar](50) NOT NULL,
	[PaymentDate] [datetime] NULL,
	[Currency] [varchar](3) NULL,
	[FXRate] [float] NULL,
	[PaymentStatus] [varchar](4) NULL,
	[PaymentAmount] [money] NULL,
	[ITCDAM] [money] NULL,
	[NetPayment] [money] NULL,
	[PaymentMovement] [money] NULL,
	[ITCDAMMovement] [money] NULL,
	[NetPaymentMovement] [money] NULL,
	[asRecovery] [int] NOT NULL,
	[asEstimate] [int] NOT NULL
) ON [PRIMARY]
GO
