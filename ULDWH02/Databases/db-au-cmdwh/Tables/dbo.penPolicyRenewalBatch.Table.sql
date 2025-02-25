USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penPolicyRenewalBatch]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPolicyRenewalBatch](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](3) NULL,
	[DomainKey] [varchar](41) NULL,
	[PolicyRenewalBatchKey] [varchar](41) NULL,
	[BatchTransactionKey] [varchar](41) NULL,
	[PolicyKey] [varchar](41) NULL,
	[QuoteCountryKey] [varchar](41) NULL,
	[JobID] [int] NULL,
	[BatchID] [int] NULL,
	[BatchTransactionID] [int] NULL,
	[BatchStatus] [varchar](50) NULL,
	[BatchTransactionStatus] [varchar](50) NULL,
	[IsPolicyIssued] [bit] NULL,
	[BatchCreateDate] [datetime] NULL,
	[BatchUpdateDate] [datetime] NULL,
	[BatchTransactionCreateDate] [datetime] NULL,
	[BatchTransactionUpdateDate] [datetime] NULL,
	[QuoteID] [int] NULL,
	[DomainID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penPolicyRenewalBatch_BIRowID]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penPolicyRenewalBatch_BIRowID] ON [dbo].[penPolicyRenewalBatch]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penPolicyRenewalBatch_BatchCreateDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyRenewalBatch_BatchCreateDate] ON [dbo].[penPolicyRenewalBatch]
(
	[BatchCreateDate] ASC
)
INCLUDE([PolicyKey],[QuoteCountryKey],[CountryKey],[BatchStatus],[BatchTransactionStatus],[IsPolicyIssued]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
