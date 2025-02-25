USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_vwTimesheetInvoiceDate]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_vwTimesheetInvoiceDate](
	[trx_ctrl_num] [varchar](16) NULL,
	[invoiceDate] [date] NULL,
	[invoiceDateid] [int] NULL,
	[invoiceDateSource] [varchar](18) NOT NULL,
	[FeeBasisCode] [varchar](10) NULL
) ON [PRIMARY]
GO
