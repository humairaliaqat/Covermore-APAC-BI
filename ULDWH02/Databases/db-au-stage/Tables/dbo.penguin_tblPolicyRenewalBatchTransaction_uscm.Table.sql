USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPolicyRenewalBatchTransaction_uscm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPolicyRenewalBatchTransaction_uscm](
	[PolicyRenewalBatchTransactionId] [int] NOT NULL,
	[PolicyId] [int] NOT NULL,
	[QuoteId] [int] NULL,
	[Status] [varchar](50) NOT NULL,
	[PolicyRenewalBatchId] [int] NOT NULL,
	[PolicyIssued] [bit] NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
