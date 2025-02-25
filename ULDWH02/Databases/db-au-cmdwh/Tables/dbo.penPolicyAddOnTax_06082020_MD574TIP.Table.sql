USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penPolicyAddOnTax_06082020_MD574TIP]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPolicyAddOnTax_06082020_MD574TIP](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[PolicyAddOnTaxKey] [varchar](41) NULL,
	[PolicyAddOnKey] [varchar](41) NULL,
	[TaxKey] [varchar](41) NULL,
	[PolicyAddOnTaxID] [int] NOT NULL,
	[PolicyAddOnID] [int] NOT NULL,
	[TaxID] [int] NOT NULL,
	[TaxName] [nvarchar](50) NULL,
	[TaxRate] [numeric](18, 5) NULL,
	[TaxType] [nvarchar](50) NULL,
	[TaxAmount] [money] NULL,
	[TaxOnAgentComm] [money] NULL,
	[TaxAmountPOSDisc] [money] NULL,
	[TaxOnAgentCommPOSDisc] [money] NULL,
	[DomainID] [int] NULL
) ON [PRIMARY]
GO
