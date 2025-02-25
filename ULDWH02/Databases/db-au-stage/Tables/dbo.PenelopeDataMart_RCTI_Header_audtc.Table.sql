USE [db-au-stage]
GO
/****** Object:  Table [dbo].[PenelopeDataMart_RCTI_Header_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PenelopeDataMart_RCTI_Header_audtc](
	[BatchID] [int] NOT NULL,
	[InvoiceID] [int] NOT NULL,
	[InvoiceDate] [datetime] NULL,
	[ResourceCode] [varchar](10) NULL,
	[RecipientName] [varchar](40) NULL,
	[RecipientAddressLine1] [varchar](40) NULL,
	[RecipientAddressLine2] [varchar](40) NULL,
	[RecipientAddressLine3] [varchar](40) NULL,
	[RecipientABN] [varchar](20) NULL,
	[EpicorVendorCode] [varchar](12) NULL,
	[SupplierName] [varchar](40) NULL,
	[SupplierAddressLine1] [varchar](40) NULL,
	[SupplierAddressLine2] [varchar](40) NULL,
	[SupplierAddressLine3] [varchar](40) NULL,
	[SupplierABN] [varchar](20) NULL,
	[AmountExGST] [money] NULL,
	[GST] [money] NULL,
	[AmountIncGST] [money] NULL,
	[DateCreated] [datetime] NULL,
	[IsPrinted] [bit] NULL,
	[DatePrinted] [datetime] NULL,
	[SupplierEmailAddress] [varchar](255) NULL,
	[IsRegisteredForGST] [varchar](10) NULL,
	[ContainsAdjustment] [bit] NULL,
	[DocumentTitle] [varchar](200) NULL,
	[CPFNotCompleted] [bit] NULL,
	[CPFCompletedDate] [datetime] NULL,
	[EpicorVoucherNo] [varchar](16) NULL,
	[TimesheetToDate] [datetime] NULL,
	[IsVoidAndReIssue] [bit] NULL,
	[VoidVoucher] [varchar](16) NULL,
	[ReIssueVoucher] [varchar](16) NULL,
	[BSB] [varchar](10) NULL,
	[BankAccount] [varchar](20) NULL,
	[EpicorVendorBalance] [money] NULL,
	[IsVoidInvoice] [bit] NULL,
	[IsReIssueInvoice] [bit] NULL
) ON [PRIMARY]
GO
