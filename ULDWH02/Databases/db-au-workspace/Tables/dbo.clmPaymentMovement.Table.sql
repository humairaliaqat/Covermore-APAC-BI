USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[clmPaymentMovement]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clmPaymentMovement](
	[ClaimKey] [varchar](40) NOT NULL,
	[SectionKey] [varchar](40) NULL,
	[SectionCode] [varchar](25) NULL,
	[PaymentKey] [varchar](40) NULL,
	[AuditKey] [varchar](50) NOT NULL,
	[PaymentDate] [datetime] NULL,
	[Currency] [varchar](3) NULL,
	[FXRate] [float] NULL,
	[PaymentStatus] [varchar](4) NULL,
	[PaymentAmount] [money] NOT NULL,
	[ITCDAM] [real] NULL,
	[NetPayment] [real] NULL,
	[PaymentMovement] [money] NULL,
	[ITCDAMMovement] [real] NULL,
	[NetPaymentMovement] [real] NULL,
	[asRecovery] [int] NOT NULL,
	[asEstimate] [int] NOT NULL
) ON [PRIMARY]
GO
