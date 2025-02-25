USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_onlinepayment]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_onlinepayment](
	[CountryKey] [varchar](2) NOT NULL,
	[PaymentKey] [varchar](13) NULL,
	[PolicyKey] [varchar](13) NULL,
	[PayID] [int] NOT NULL,
	[PolicyNo] [int] NULL,
	[MerchantTxtRef] [varchar](50) NULL,
	[OrderInfo] [varchar](50) NULL,
	[MerchantID] [varchar](50) NULL,
	[AmountPaid] [money] NULL,
	[ReceiptNo] [varchar](50) NULL,
	[QSIResponseCode] [varchar](50) NULL,
	[ResponseDescription] [varchar](255) NULL,
	[ACQResponseCode] [varchar](50) NULL,
	[TransactionNo] [varchar](50) NULL,
	[AuthoriseID] [varchar](50) NULL,
	[BatchNo] [varchar](50) NULL,
	[CardType] [varchar](50) NULL,
	[DateAdd] [datetime] NULL,
	[RecordDate] [datetime] NULL,
	[AccountingDate] [datetime] NULL,
	[PaymentReferenceID] [int] NULL
) ON [PRIMARY]
GO
