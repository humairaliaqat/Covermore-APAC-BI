USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_bankpayment]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_bankpayment](
	[CountryKey] [varchar](2) NOT NULL,
	[PaymentKey] [varchar](13) NULL,
	[BankRecordKey] [varchar](13) NULL,
	[ReturnKey] [varchar](13) NULL,
	[PaymentID] [int] NOT NULL,
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
