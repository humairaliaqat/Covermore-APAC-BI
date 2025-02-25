USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penPolicyTransTax]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPolicyTransTax](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[PolicyTransactionID] [int] NULL,
	[PolicyNumber] [varchar](50) NULL,
	[TaxType] [varchar](50) NULL,
	[TaxAmount] [money] NULL,
	[TaxOnAgentCommission] [money] NULL,
	[UnAdjTaxAmount] [money] NULL,
	[UnAdjTaxOnAgentCommission] [money] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyTransTax_PolicyTransactionKey]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penPolicyTransTax_PolicyTransactionKey] ON [dbo].[penPolicyTransTax]
(
	[PolicyTransactionKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
