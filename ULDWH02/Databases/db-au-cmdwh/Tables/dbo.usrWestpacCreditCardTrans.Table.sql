USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrWestpacCreditCardTrans]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrWestpacCreditCardTrans](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[CommunityCode] [varchar](50) NULL,
	[BusinessCode] [varchar](50) NULL,
	[BusinessName] [varchar](50) NULL,
	[Source] [varchar](50) NULL,
	[OrderType] [varchar](50) NULL,
	[ReceiptNumber] [varchar](50) NULL,
	[CustomerReferenceNumber] [varchar](50) NULL,
	[CustomerNumber] [varchar](50) NULL,
	[PaymentReference] [varchar](50) NULL,
	[TotalAmount] [money] NULL,
	[PaymentAmount] [money] NULL,
	[SurchargeAmount] [money] NULL,
	[Currency] [varchar](10) NULL,
	[SettlementDate] [datetime] NULL,
	[TransactionDateTime] [datetime] NULL,
	[TransactionStatus] [varchar](10) NULL,
	[SummaryCode] [varchar](10) NULL,
	[TransactionStatusDescription] [varchar](50) NULL,
	[AuthorisationCode] [varchar](50) NULL,
	[SettlementAccountName] [varchar](50) NULL,
	[PaymentInstrument] [varchar](50) NULL,
	[AccountType] [varchar](50) NULL,
	[CustomerAccountBusinessCode] [varchar](50) NULL,
	[CardType] [varchar](50) NULL,
	[CardNumber] [varchar](50) NULL,
	[CardExpiryDate] [varchar](50) NULL,
	[CardHolderName] [varchar](50) NULL,
	[BankAccountName] [varchar](50) NULL,
	[BankAccountBSB] [varchar](50) NULL,
	[BankAccountNumber] [varchar](50) NULL,
	[BankAccountBankCode] [varchar](50) NULL,
	[BankAccountBranchCode] [varchar](50) NULL,
	[BankAccountSuffix] [varchar](50) NULL,
	[LoginName] [varchar](50) NULL,
	[FullName] [varchar](50) NULL,
	[Comment] [varchar](50) NULL,
	[RelatedTransactionReceiptNumber] [varchar](50) NULL,
	[FraudGuardResult] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrWestpacCC_ReceiptNumber]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE CLUSTERED INDEX [idx_usrWestpacCC_ReceiptNumber] ON [dbo].[usrWestpacCreditCardTrans]
(
	[ReceiptNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrWestpacCC_CompanyKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrWestpacCC_CompanyKey] ON [dbo].[usrWestpacCreditCardTrans]
(
	[CompanyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrWestpacCC_CountryKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrWestpacCC_CountryKey] ON [dbo].[usrWestpacCreditCardTrans]
(
	[CountryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_usrWestpacCC_TransactionDateTime]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrWestpacCC_TransactionDateTime] ON [dbo].[usrWestpacCreditCardTrans]
(
	[TransactionDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
