USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblVoucherTransactions_autp]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblVoucherTransactions_autp](
	[VoucherTransactionID] [int] NOT NULL,
	[VoucherID] [int] NOT NULL,
	[PolicyNumber] [varchar](25) NOT NULL,
	[RedeemAmount] [money] NOT NULL,
	[RedemptionDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
