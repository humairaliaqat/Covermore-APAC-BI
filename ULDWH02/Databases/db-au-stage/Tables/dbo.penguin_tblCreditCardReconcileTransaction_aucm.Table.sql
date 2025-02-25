USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblCreditCardReconcileTransaction_aucm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblCreditCardReconcileTransaction_aucm](
	[CreditCardReconcileTransactionId] [int] NOT NULL,
	[CreditCardReconcileId] [int] NOT NULL,
	[PolicyTransactionId] [int] NULL,
	[Net] [money] NOT NULL,
	[Commission] [money] NOT NULL,
	[Gross] [money] NOT NULL,
	[AmountType] [varchar](15) NOT NULL,
	[PaymentTypeId] [int] NOT NULL,
	[Status] [varchar](15) NOT NULL,
	[OutletId] [int] NOT NULL,
	[AlphaCode] [varchar](20) NOT NULL,
	[PaymentRegisterId] [int] NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
