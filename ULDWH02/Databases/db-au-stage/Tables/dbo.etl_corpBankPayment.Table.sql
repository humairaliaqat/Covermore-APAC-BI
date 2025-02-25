USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_corpBankPayment]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_corpBankPayment](
	[CountryKey] [varchar](2) NOT NULL,
	[PaymentKey] [varchar](10) NULL,
	[BankRecordKey] [varchar](10) NULL,
	[PendingRecordKey] [varchar](10) NULL,
	[PaymentID] [int] NOT NULL,
	[BankRecord] [int] NULL,
	[PendingRecord] [int] NULL,
	[PayType] [varchar](5) NULL,
	[Payer] [varchar](50) NULL,
	[BSB] [int] NULL,
	[ChequeNo] [float] NULL,
	[CreditCardType] [varchar](15) NULL,
	[CreditCardNo] [varchar](50) NULL,
	[CreditCardExpiryDate] [datetime] NULL,
	[Amount] [money] NULL,
	[Comment] [varchar](100) NULL,
	[isPartPayment] [bit] NULL,
	[IncludeCommission] [bit] NULL
) ON [PRIMARY]
GO
