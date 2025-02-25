USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[penpayment_bkp]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penpayment_bkp](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[PaymentKey] [varchar](41) NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[PaymentID] [int] NULL,
	[PolicyTransactionID] [int] NULL,
	[PaymentRefID] [varchar](50) NULL,
	[OrderId] [varchar](50) NULL,
	[Status] [varchar](100) NULL,
	[Total] [money] NULL,
	[ClientID] [int] NULL,
	[TransTime] [datetime] NULL,
	[MerchantID] [varchar](100) NULL,
	[ReceiptNo] [varchar](50) NULL,
	[ResponseDescription] [varchar](34) NULL,
	[ACQResponseCode] [varchar](50) NULL,
	[TransactionNo] [varchar](50) NULL,
	[AuthoriseID] [varchar](50) NULL,
	[CardType] [varchar](50) NULL,
	[BatchNo] [varchar](20) NULL,
	[TxnResponseCode] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[DomainID] [int] NULL,
	[TransTimeUTC] [datetime] NULL,
	[PaymentGatewayID] [varchar](50) NULL,
	[PaymentMerchantID] [int] NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[Source] [varchar](50) NULL
) ON [PRIMARY]
GO
