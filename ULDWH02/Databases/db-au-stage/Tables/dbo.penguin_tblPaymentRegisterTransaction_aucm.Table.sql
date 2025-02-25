USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPaymentRegisterTransaction_aucm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPaymentRegisterTransaction_aucm](
	[PaymentRegisterTransactionId] [int] NOT NULL,
	[PaymentRegisterId] [int] NOT NULL,
	[Payer] [varchar](50) NULL,
	[BankDate] [date] NULL,
	[BSB] [varchar](10) NULL,
	[ChequeNumber] [varchar](30) NULL,
	[CreditNoteDepartmentId] [int] NULL,
	[JointVentureId] [int] NULL,
	[Amount] [money] NOT NULL,
	[AmountType] [varchar](15) NOT NULL,
	[Status] [varchar](15) NOT NULL,
	[PaymentAllocationId] [int] NULL,
	[Comment] [varchar](500) NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
