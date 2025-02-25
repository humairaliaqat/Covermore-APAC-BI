USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[PolicyTransSummary_Premium_Discrepanncies]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PolicyTransSummary_Premium_Discrepanncies](
	[countrykey] [varchar](2) NULL,
	[BI_PolicyTransactionKey] [varchar](41) NULL,
	[Src_PolicyNumber] [varchar](25) NULL,
	[BI_policyNumber] [varchar](50) NULL,
	[Src_PolicyTransactionKey] [varchar](41) NULL,
	[BI_PolicyTransactionID] [int] NULL,
	[Src_Premium] [money] NOT NULL,
	[BI_Premium_Roundoff] [money] NULL,
	[BI_Premium] [money] NULL,
	[Src_CNStatusID] [int] NULL,
	[BI_CNStatusID] [int] NULL,
	[Src_TransactionStatus] [int] NOT NULL,
	[BI_TransactionStatus] [int] NULL
) ON [PRIMARY]
GO
