USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penPaymentRegisterTransaction]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPaymentRegisterTransaction](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[PaymentRegisterTransactionKey] [varchar](41) NULL,
	[PaymentRegisterKey] [varchar](41) NULL,
	[PaymentAllocationKey] [varchar](41) NULL,
	[PaymentRegisterTransactionID] [int] NULL,
	[PaymentRegisterID] [int] NULL,
	[PaymentAllocationID] [int] NULL,
	[Payer] [varchar](50) NULL,
	[BankDate] [datetime] NULL,
	[BankDateUTC] [datetime] NULL,
	[BSB] [varchar](10) NULL,
	[ChequeNumber] [varchar](30) NULL,
	[Amount] [money] NULL,
	[AmountType] [varchar](15) NULL,
	[Status] [varchar](15) NULL,
	[Comment] [varchar](500) NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[CreateDateTimeUTC] [datetime] NULL,
	[UpdateDateTimeUTC] [datetime] NULL,
	[CreditNoteDepartmentID] [int] NULL,
	[CreditNoteDepartmentName] [varchar](55) NULL,
	[CreditNoteDepartmentCode] [varchar](3) NULL,
	[JointVentureID] [int] NULL,
	[JVCode] [varchar](10) NULL,
	[JVDescription] [varchar](55) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPaymentRegisterTransaction_PaymentRegisterTransactionKey]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penPaymentRegisterTransaction_PaymentRegisterTransactionKey] ON [dbo].[penPaymentRegisterTransaction]
(
	[PaymentRegisterTransactionKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPaymentRegisterTransaction_CountryKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPaymentRegisterTransaction_CountryKey] ON [dbo].[penPaymentRegisterTransaction]
(
	[CountryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPaymentRegisterTransaction_PaymentAllocationKeyKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPaymentRegisterTransaction_PaymentAllocationKeyKey] ON [dbo].[penPaymentRegisterTransaction]
(
	[PaymentAllocationKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPaymentRegisterTransaction_PaymentRegisterKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPaymentRegisterTransaction_PaymentRegisterKey] ON [dbo].[penPaymentRegisterTransaction]
(
	[PaymentRegisterKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
