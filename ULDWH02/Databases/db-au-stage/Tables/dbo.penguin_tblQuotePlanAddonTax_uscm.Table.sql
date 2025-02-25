USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblQuotePlanAddonTax_uscm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblQuotePlanAddonTax_uscm](
	[QuotePlanID] [int] NOT NULL,
	[AddOnID] [int] NOT NULL,
	[TaxType] [nvarchar](50) NOT NULL,
	[TaxName] [nvarchar](50) NOT NULL,
	[TaxRate] [numeric](5, 4) NOT NULL,
	[TaxAmount] [numeric](18, 5) NOT NULL,
	[Active] [bit] NOT NULL,
	[TaxOnAgentCommission] [money] NULL,
	[IsPOSDiscount] [bit] NOT NULL
) ON [PRIMARY]
GO
