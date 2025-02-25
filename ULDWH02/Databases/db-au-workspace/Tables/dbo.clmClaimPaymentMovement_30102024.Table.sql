USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[clmClaimPaymentMovement_30102024]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clmClaimPaymentMovement_30102024](
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[ClaimKey] [varchar](40) NOT NULL,
	[SectionKey] [varchar](40) NOT NULL,
	[PaymentKey] [varchar](40) NOT NULL,
	[BenefitCategory] [varchar](35) NOT NULL,
	[SectionCode] [varchar](25) NULL,
	[FirstPayment] [bit] NOT NULL,
	[FirstMonthPayment] [bit] NOT NULL,
	[PaymentStatus] [varchar](4) NULL,
	[PaymentDate] [date] NULL,
	[PaymentDateUTC] [date] NULL,
	[AllMovement] [money] NULL,
	[PaymentMovement] [money] NULL,
	[RecoveryPaymentMovement] [money] NULL,
	[BatchID] [int] NULL,
	[PaymentDateTime] [datetime] NULL
) ON [PRIMARY]
GO
