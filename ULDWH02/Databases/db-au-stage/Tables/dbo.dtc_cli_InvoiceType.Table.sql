USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_InvoiceType]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_InvoiceType](
	[InvoiceTypeID] [int] NOT NULL,
	[InvoiceTypeName] [varchar](50) NULL
) ON [PRIMARY]
GO
