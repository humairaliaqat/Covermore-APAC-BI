USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_bankpayments_sg]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_bankpayments_sg](
	[Payment_ID] [int] NOT NULL,
	[BankRec] [int] NULL,
	[PendRec] [int] NULL,
	[PayType] [varchar](3) NULL,
	[Payer] [varchar](50) NULL,
	[BSB] [int] NULL,
	[ChequeNo] [float] NULL,
	[CCardType] [varchar](10) NULL,
	[CCardNo] [varchar](25) NULL,
	[CCardExpiry] [datetime] NULL,
	[Amount] [money] NULL,
	[Comment] [varchar](100) NULL,
	[PartPay] [bit] NOT NULL,
	[RtnID] [int] NULL,
	[Allocated] [bit] NULL
) ON [PRIMARY]
GO
