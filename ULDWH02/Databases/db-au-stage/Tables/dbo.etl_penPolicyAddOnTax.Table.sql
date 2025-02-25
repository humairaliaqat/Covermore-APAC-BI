USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penPolicyAddOnTax]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penPolicyAddOnTax](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[PolicyAddOnTaxKey] [varchar](71) NULL,
	[PolicyAddOnKey] [varchar](71) NULL,
	[TaxKey] [varchar](71) NULL,
	[DomainID] [int] NULL,
	[PolicyAddOnTaxID] [int] NOT NULL,
	[PolicyAddOnID] [int] NOT NULL,
	[TaxID] [int] NOT NULL,
	[TaxName] [nvarchar](50) NULL,
	[TaxRate] [numeric](18, 5) NULL,
	[TaxType] [nvarchar](50) NULL,
	[TaxAmount] [money] NULL,
	[TaxOnAgentComm] [money] NULL,
	[TaxAmountPOSDisc] [money] NULL,
	[TaxOnAgentCommPOSDisc] [money] NULL
) ON [PRIMARY]
GO
