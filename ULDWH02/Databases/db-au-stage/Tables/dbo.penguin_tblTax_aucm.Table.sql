USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblTax_aucm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblTax_aucm](
	[TaxId] [int] NOT NULL,
	[DomainId] [int] NOT NULL,
	[TaxName] [nvarchar](50) NULL,
	[TaxRate] [numeric](18, 5) NULL,
	[TaxTypeId] [int] NULL
) ON [PRIMARY]
GO
