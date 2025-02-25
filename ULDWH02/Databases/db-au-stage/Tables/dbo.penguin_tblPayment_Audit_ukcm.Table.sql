USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPayment_Audit_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPayment_Audit_ukcm](
	[PAYUNIQUE_ID] [int] NOT NULL,
	[PaymentId] [int] NULL,
	[PolicyTransactionId] [int] NULL,
	[PAYMENTREF_ID] [varchar](50) NULL,
	[ORDERID] [varchar](50) NULL,
	[STATUS] [varchar](100) NULL,
	[TOTAL] [money] NULL,
	[CLIENTID] [int] NULL,
	[TTIME] [datetime] NULL,
	[MerchantID] [varchar](60) NULL,
	[ReceiptNo] [varchar](50) NULL,
	[ResponseDescription] [varchar](34) NULL,
	[ACQResponseCode] [varchar](50) NULL,
	[TransactionNo] [varchar](50) NULL,
	[AuthoriseID] [varchar](50) NULL,
	[CardType] [varchar](50) NULL,
	[BatchNo] [varchar](20) NULL,
	[TxnResponseCode] [varchar](5) NULL,
	[PaymentGatewayID] [varchar](50) NULL,
	[PaymentMerchantID] [int] NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[Source] [nvarchar](50) NULL,
	[AUDIT_DATETIME] [datetime] NULL,
	[AUDIT_ACTION] [nvarchar](100) NULL,
	[AUDIT_USER] [nvarchar](50) NULL,
	[PaymentChannel] [nvarchar](100) NULL
) ON [PRIMARY]
GO
