USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cbBilling_BKP20190122_deleted_records]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cbBilling_BKP20190122_deleted_records](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [nvarchar](2) NOT NULL,
	[CaseKey] [nvarchar](20) NOT NULL,
	[BillingKey] [nvarchar](20) NOT NULL,
	[AddressKey] [nvarchar](20) NULL,
	[CaseNo] [nvarchar](15) NOT NULL,
	[BillingID] [int] NOT NULL,
	[OpenDate] [datetime] NULL,
	[OpenTimeUTC] [datetime] NULL,
	[SentDate] [datetime] NULL,
	[SentTimeUTC] [datetime] NULL,
	[OpenedByID] [nvarchar](30) NULL,
	[OpenedBy] [nvarchar](55) NULL,
	[ProcessedBy] [nvarchar](30) NULL,
	[BillingTypeCode] [nvarchar](10) NULL,
	[BillingType] [nvarchar](100) NULL,
	[InvoiceNo] [nvarchar](50) NULL,
	[InvoiceDate] [datetime] NULL,
	[BillItem] [nvarchar](20) NULL,
	[Provider] [nvarchar](200) NULL,
	[Details] [nvarchar](1500) NULL,
	[PaymentBy] [nvarchar](50) NULL,
	[PaymentDate] [datetime] NULL,
	[LocalCurrencyCode] [nvarchar](3) NULL,
	[LocalCurrency] [nvarchar](20) NULL,
	[LocalInvoice] [money] NULL,
	[ExchangeRate] [money] NULL,
	[AUDInvoice] [money] NULL,
	[AUDGST] [money] NULL,
	[CostContainmentAgent] [nvarchar](25) NULL,
	[BackFrontEnd] [nvarchar](50) NULL,
	[CCInvoiceAmount] [money] NULL,
	[CCSaving] [money] NULL,
	[CCDiscountedInvoice] [money] NULL,
	[CustomerPayment] [money] NULL,
	[ClientPayment] [money] NULL,
	[PPOFee] [money] NULL,
	[TotalDueCCAgent] [money] NULL,
	[CCFee] [money] NULL,
	[isImported] [bit] NULL,
	[isDeleted] [bit] NULL
) ON [PRIMARY]
GO
