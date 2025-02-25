USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_ETL083_pnpEpicorInvoice]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_ETL083_pnpEpicorInvoice](
	[Company] [varchar](8) NULL,
	[JournalCtrlNum] [varchar](16) NULL,
	[DateApplied] [int] NULL,
	[ApplyDate] [datetime] NULL,
	[InvoiceNumber] [varchar](16) NULL,
	[RCTINumber] [varchar](50) NULL,
	[VoucherNumber] [varchar](50) NULL,
	[PreTax] [float] NULL,
	[AmtTaxInc] [float] NULL,
	[Currency] [varchar](8) NULL,
	[TrxTypeDesc] [varchar](100) NULL,
	[InvoiceSK] [int] NULL
) ON [PRIMARY]
GO
