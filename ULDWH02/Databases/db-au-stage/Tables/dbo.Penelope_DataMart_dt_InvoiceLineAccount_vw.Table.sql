USE [db-au-stage]
GO
/****** Object:  Table [dbo].[Penelope_DataMart_dt_InvoiceLineAccount_vw]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Penelope_DataMart_dt_InvoiceLineAccount_vw](
	[InvoiceLineID] [int] NULL,
	[InvoiceNo] [varchar](20) NULL,
	[PenelopeInvoiceID] [int] NULL,
	[AccountCode] [varchar](26) NULL,
	[TransactionType] [smallint] NULL,
	[CustomerCode] [varchar](10) NULL
) ON [PRIMARY]
GO
