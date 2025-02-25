USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penPolicyRenewalBatchUS]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penPolicyRenewalBatchUS](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[PolicyRenewalBatchKey] [varchar](71) NULL,
	[BatchTransactionKey] [varchar](71) NULL,
	[PolicyKey] [varchar](71) NULL,
	[QuoteCountryKey] [varchar](71) NULL,
	[JobID] [int] NOT NULL,
	[BatchID] [int] NOT NULL,
	[BatchTransactionID] [int] NOT NULL,
	[BatchStatus] [varchar](50) NOT NULL,
	[BatchTransactionStatus] [varchar](50) NOT NULL,
	[IsPolicyIssued] [bit] NULL,
	[BatchCreateDate] [datetime] NULL,
	[BatchUpdateDate] [datetime] NULL,
	[BatchTransactionCreateDate] [datetime] NULL,
	[BatchTransactionUpdateDate] [datetime] NULL,
	[QuoteId] [int] NULL,
	[DomainID] [int] NOT NULL
) ON [PRIMARY]
GO
