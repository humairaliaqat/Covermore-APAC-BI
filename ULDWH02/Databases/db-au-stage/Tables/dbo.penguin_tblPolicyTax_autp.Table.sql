USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPolicyTax_autp]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPolicyTax_autp](
	[ID] [int] NOT NULL,
	[PolicyTravellerTransactionID] [int] NOT NULL,
	[TaxID] [int] NOT NULL,
	[TaxAmount] [money] NOT NULL,
	[TaxOnAgentComm] [money] NOT NULL,
	[IsPOSDiscount] [bit] NOT NULL
) ON [PRIMARY]
GO
