USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penPaymentRegister]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPaymentRegister](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[PaymentRegisterKey] [varchar](41) NULL,
	[OutletKey] [varchar](41) NULL,
	[CRMUserKey] [varchar](41) NULL,
	[BankAccountKey] [varchar](41) NULL,
	[PaymentRegisterID] [int] NULL,
	[OutletID] [int] NULL,
	[CRMUserID] [int] NULL,
	[BankAccountID] [int] NULL,
	[PaymentStatus] [varchar](15) NULL,
	[PaymentTypeID] [int] NULL,
	[PaymentType] [varchar](55) NULL,
	[PaymentCode] [varchar](3) NULL,
	[PaymentSource] [varchar](50) NULL,
	[PaymentCreateDateTime] [datetime] NULL,
	[PaymentUpdateDateTime] [datetime] NULL,
	[PaymentCreateDateTimeUTC] [datetime] NULL,
	[PaymentUpdateDateTimeUTC] [datetime] NULL,
	[DomainID] [int] NULL,
	[TripsAccount] [varchar](4) NULL,
	[Comment] [varchar](500) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPaymentRegister_PaymentRegisterKey]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penPaymentRegister_PaymentRegisterKey] ON [dbo].[penPaymentRegister]
(
	[PaymentRegisterKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPaymentRegister_OutletKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPaymentRegister_OutletKey] ON [dbo].[penPaymentRegister]
(
	[OutletKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
