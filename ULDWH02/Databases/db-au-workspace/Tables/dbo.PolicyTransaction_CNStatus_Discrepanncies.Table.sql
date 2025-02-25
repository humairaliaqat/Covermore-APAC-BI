USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[PolicyTransaction_CNStatus_Discrepanncies]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PolicyTransaction_CNStatus_Discrepanncies](
	[countrykey] [varchar](2) NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[Src_PolicyNumber] [varchar](25) NULL,
	[BI_PolicyNumber] [varchar](50) NULL,
	[Src_Premmium] [money] NOT NULL,
	[BI_Premium] [money] NULL,
	[Src_CNStatusID] [int] NULL,
	[BI_CNStatusID] [int] NULL,
	[Src_TransactionStatus] [int] NOT NULL,
	[BI_TransactionStatus] [int] NULL
) ON [PRIMARY]
GO
