USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_AUDIT_tblPolicyTax_aucm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_AUDIT_tblPolicyTax_aucm](
	[AUDIT_USERNAME] [varchar](255) NULL,
	[AUDIT_RECORDTYPE] [varchar](255) NULL,
	[AUDIT_DATETIME] [datetime] NULL,
	[AUDIT_tblPolicyTax_ID] [int] NOT NULL,
	[ID] [int] NULL,
	[PolicyTravellerTransactionID] [int] NOT NULL,
	[TaxID] [int] NOT NULL,
	[TaxAmount] [money] NOT NULL,
	[TaxOnAgentComm] [money] NOT NULL,
	[IsPOSDiscount] [bit] NOT NULL
) ON [PRIMARY]
GO
