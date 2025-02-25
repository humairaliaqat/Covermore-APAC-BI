USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_tblPayment_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_tblPayment_au](
	[PaymentID] [int] NOT NULL,
	[RegistrationID] [int] NOT NULL,
	[PaymentRef] [varchar](50) NULL,
	[OrderID] [varchar](50) NULL,
	[Status] [varchar](100) NULL,
	[Total] [money] NULL,
	[ReceiptNo] [varchar](50) NULL,
	[PaymentDate] [datetime] NULL,
	[CardType] [varchar](20) NULL,
	[MerchantID] [varchar](16) NULL
) ON [PRIMARY]
GO
