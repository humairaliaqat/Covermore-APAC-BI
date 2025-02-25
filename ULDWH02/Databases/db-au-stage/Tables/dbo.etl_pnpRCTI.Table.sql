USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_pnpRCTI]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_pnpRCTI](
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
	[HeaderGST] [money] NULL,
	[AmountIncGST] [money] NULL,
	[DateCreated] [datetime] NULL,
	[IsPrinted] [bit] NULL,
	[DatePrinted] [datetime] NULL,
	[SupplierEmailAddress] [varchar](255) NULL,
	[IsRegisteredForGST] [varchar](10) NULL,
	[ContainsAdjustment] [bit] NULL,
	[DocumentTitle] [varchar](200) NULL,
	[HeaderCPFNotCompleted] [bit] NULL,
	[CPFCompletedDate] [datetime] NULL,
	[EpicorVoucherNo] [varchar](16) NULL,
	[TimesheetToDate] [datetime] NULL,
	[IsVoidAndReIssue] [bit] NULL,
	[VoidVoucher] [varchar](16) NULL,
	[ReIssueVoucher] [varchar](16) NULL,
	[BSB] [varchar](10) NULL,
	[BankAccount] [varchar](20) NULL,
	[EpicorVendorBalance] [money] NULL,
	[LineNum] [int] NOT NULL,
	[PeriodDescription] [varchar](10) NULL,
	[LineDescription] [varchar](400) NULL,
	[Unit] [varchar](10) NULL,
	[Qty] [money] NULL,
	[Rate] [money] NULL,
	[AmtExGST] [money] NULL,
	[LineGST] [money] NULL,
	[AmtIncGST] [money] NULL,
	[TimesheetControlID] [varchar](50) NOT NULL,
	[LineCPFNotCompleted] [bit] NULL,
	[AccountCodeSegment1] [varchar](32) NULL,
	[AccountCodeSegment2] [varchar](32) NULL,
	[AccountCodeSegment3] [varchar](32) NULL,
	[AccountReferenceCode] [varchar](32) NULL,
	[TaxCode] [varchar](20) NULL,
	[CompanyCode] [varchar](8) NULL,
	[CompanyID] [smallint] NULL,
	[OverSessionLimitFlag] [int] NULL,
	[OldTimesheetEntryFlag] [int] NULL,
	[VoidDontReissue] [bit] NULL,
	[PayrollCategory] [varchar](50) NULL
) ON [PRIMARY]
GO
