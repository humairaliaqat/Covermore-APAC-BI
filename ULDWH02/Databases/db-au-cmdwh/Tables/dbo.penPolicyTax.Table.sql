USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penPolicyTax]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPolicyTax](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[PolicyTaxKey] [varchar](41) NULL,
	[PolicyTravellerTransactionKey] [varchar](41) NULL,
	[TaxKey] [varchar](41) NULL,
	[PolicyTaxID] [int] NOT NULL,
	[PolicyTravellerTransactionID] [int] NOT NULL,
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
/****** Object:  Index [idx_penPolicyTax_PolicyTaxID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_penPolicyTax_PolicyTaxID] ON [dbo].[penPolicyTax]
(
	[PolicyTaxID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyTax_PolicyTravellerTransactionKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyTax_PolicyTravellerTransactionKey] ON [dbo].[penPolicyTax]
(
	[PolicyTravellerTransactionKey] ASC,
	[TaxKey] ASC
)
INCLUDE([TaxName],[TaxType],[TaxAmount],[TaxOnAgentComm],[TaxAmountPOSDisc],[TaxOnAgentCommPOSDisc]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
