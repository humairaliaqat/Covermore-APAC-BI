USE [db-au-stage]
GO
/****** Object:  Table [dbo].[tmp_penPayment]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_penPayment](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[PaymentKey] [varchar](41) NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[PaymentID] [int] NOT NULL,
	[PolicyTransactionID] [int] NULL,
	[PaymentRefID] [varchar](50) NULL,
	[OrderID] [varchar](50) NULL,
	[Status] [varchar](100) NULL,
	[Total] [money] NULL,
	[ClientID] [int] NULL,
	[TransTime] [datetime] NULL,
	[MerchantID] [varchar](16) NULL,
	[ReceiptNo] [varchar](50) NULL,
	[ResponseDescription] [varchar](34) NULL,
	[ACQResponseCode] [varchar](50) NULL,
	[TransactionNo] [varchar](50) NULL,
	[AuthoriseID] [varchar](50) NULL,
	[CardType] [varchar](50) NULL,
	[BatchNo] [varchar](20) NULL,
	[TxnResponseCode] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[DomainID] [int] NOT NULL,
	[TransTimeUTC] [datetime] NULL,
	[PaymentGatewayID] [int] NULL,
	[PaymentMerchantID] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_tmp_penPayment_PaymentKey]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_tmp_penPayment_PaymentKey] ON [dbo].[tmp_penPayment]
(
	[PaymentKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_tmp_penPayment_PolicyTransactionKey]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_tmp_penPayment_PolicyTransactionKey] ON [dbo].[tmp_penPayment]
(
	[PolicyTransactionKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
