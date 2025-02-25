USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_UKEMC_AUDIT_PAYMENT_UK]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_UKEMC_AUDIT_PAYMENT_UK](
	[AUDIT_USERNAME] [varchar](255) NULL,
	[AUDIT_DATETIME] [datetime] NULL,
	[AUDIT_ACTION] [varchar](10) NULL,
	[Counter] [int] NOT NULL,
	[ClientID] [int] NULL,
	[Excess] [float] NULL,
	[Premium] [float] NULL,
	[Limit] [float] NULL,
	[ResricCond] [varchar](255) NULL,
	[OtherRestrictions] [varchar](255) NULL,
	[Over70] [float] NULL,
	[Comments] [varchar](1000) NULL,
	[Duration] [varchar](10) NULL,
	[Surname] [varchar](22) NULL,
	[CardType] [varchar](6) NULL,
	[PDate] [datetime] NULL,
	[GST] [money] NULL,
	[Merchantid] [varchar](16) NULL,
	[ReceiptNo] [varchar](50) NULL,
	[TxnResponseCode] [varchar](5) NULL,
	[ACQResponseCode] [varchar](50) NULL,
	[Status] [varchar](100) NULL,
	[OrderId] [varchar](50) NULL,
	[MerchantxRef] [varchar](50) NULL
) ON [PRIMARY]
GO
