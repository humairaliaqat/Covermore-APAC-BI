USE [db-au-stage]
GO
/****** Object:  Table [dbo].[Penelope_DataMart_invoiceLine]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Penelope_DataMart_invoiceLine](
	[InvoiceLineID] [int] NULL,
	[InvoiceNo] [varchar](20) NULL,
	[PenelopeInvoiceID] [int] NULL,
	[AccountCode] [varchar](32) NULL,
	[TransactionType] [smallint] NULL,
	[CustomerCode] [varchar](10) NULL
) ON [PRIMARY]
GO
