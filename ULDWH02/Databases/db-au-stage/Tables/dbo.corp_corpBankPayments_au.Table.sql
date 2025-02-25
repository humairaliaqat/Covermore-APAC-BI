USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_corpBankPayments_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_corpBankPayments_au](
	[Payment_ID] [int] NOT NULL,
	[BankRec] [int] NULL,
	[PendRec] [int] NULL,
	[PayType] [varchar](5) NULL,
	[Payer] [varchar](50) NULL,
	[BSB] [int] NULL,
	[ChequeNo] [float] NULL,
	[CCardType] [varchar](15) NULL,
	[CCardNo] [varchar](50) NULL,
	[CCardExpiry] [datetime] NULL,
	[Amount] [money] NULL,
	[Comment] [varchar](100) NULL,
	[PartPay] [bit] NULL,
	[IncComm] [bit] NULL
) ON [PRIMARY]
GO
