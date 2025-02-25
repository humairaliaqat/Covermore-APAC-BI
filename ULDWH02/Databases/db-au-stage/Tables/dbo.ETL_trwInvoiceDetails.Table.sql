USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_trwInvoiceDetails]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_trwInvoiceDetails](
	[InvoiceDetailID] [numeric](18, 0) NULL,
	[InvoiceID] [numeric](18, 0) NULL,
	[PolicyDetailID] [numeric](18, 0) NULL,
	[TotalAmount] [numeric](18, 2) NULL,
	[ServiceTaxRate] [numeric](18, 2) NULL,
	[CESS1Rate] [numeric](18, 2) NULL,
	[CESS2Rate] [numeric](18, 2) NULL,
	[ServiceTax] [numeric](18, 2) NULL,
	[CESS1] [numeric](18, 2) NULL,
	[CESS2] [numeric](18, 2) NULL,
	[GrossAmount] [numeric](18, 2) NULL,
	[DiscountPercent] [numeric](18, 2) NULL,
	[DiscountAmount] [numeric](18, 2) NULL,
	[DiscountServiceTax] [numeric](18, 2) NULL,
	[DiscountCESS1] [numeric](18, 2) NULL,
	[DiscountCESS2] [numeric](18, 2) NULL,
	[NetServiceTax] [numeric](18, 2) NULL,
	[NetCESS1] [numeric](18, 2) NULL,
	[NetCESS2] [numeric](18, 2) NULL,
	[NetAmount] [numeric](18, 2) NULL,
	[CommissionPercent] [numeric](18, 2) NULL,
	[CommissionAmount] [numeric](18, 2) NULL,
	[TDSRate] [numeric](18, 2) NULL,
	[TDSAmount] [numeric](18, 2) NULL,
	[ServiceTaxDetailID] [numeric](18, 0) NULL,
	[TDSDetailID] [numeric](18, 0) NULL,
	[ManualPremiumTotal] [numeric](18, 2) NULL,
	[ManualPremiumBasic] [numeric](18, 2) NULL,
	[ManualPremiumServiceTax] [numeric](18, 2) NULL,
	[pdfreference] [nvarchar](4000) NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY]
GO
