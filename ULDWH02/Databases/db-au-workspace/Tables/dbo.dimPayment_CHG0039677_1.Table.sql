USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[dimPayment_CHG0039677_1]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dimPayment_CHG0039677_1](
	[PaymentSK] [int] IDENTITY(1,1) NOT NULL,
	[Country] [nvarchar](10) NOT NULL,
	[PaymentKey] [nvarchar](50) NOT NULL,
	[PolicyTransactionKey] [nvarchar](50) NULL,
	[PaymentRefID] [nvarchar](50) NULL,
	[OrderID] [nvarchar](50) NULL,
	[Status] [nvarchar](100) NULL,
	[PaymentAmount] [money] NULL,
	[ClientID] [int] NULL,
	[TransactionDate] [datetime] NULL,
	[TransactionDateUTC] [datetime] NULL,
	[MerchantID] [nvarchar](100) NULL,
	[ReceiptNo] [nvarchar](50) NULL,
	[ResponseDescription] [nvarchar](50) NULL,
	[TransactionNo] [nvarchar](50) NULL,
	[AuthoriseID] [nvarchar](50) NULL,
	[CardType] [nvarchar](50) NULL,
	[BatchNo] [nvarchar](20) NULL,
	[PaymentGatewayID] [nvarchar](50) NULL,
	[PaymentMerchantID] [int] NULL,
	[PaymentMethod] [nvarchar](50) NULL,
	[LoadDate] [datetime] NOT NULL,
	[updateDate] [datetime] NULL,
	[LoadID] [int] NOT NULL,
	[updateID] [int] NULL,
	[HashKey] [varbinary](30) NULL
) ON [PRIMARY]
GO
