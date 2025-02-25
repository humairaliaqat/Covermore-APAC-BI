USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_corpPayment]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_corpPayment](
	[CountryKey] [varchar](2) NOT NULL,
	[PaymentKey] [varchar](33) NULL,
	[RegistrationKey] [varchar](33) NULL,
	[PaymentID] [int] NOT NULL,
	[RegistrationID] [int] NOT NULL,
	[OrderID] [varchar](50) NULL,
	[Status] [varchar](100) NULL,
	[Total] [money] NULL,
	[ReceiptNo] [varchar](50) NULL,
	[PaymentDate] [datetime] NULL,
	[CardType] [varchar](20) NULL,
	[MerchantID] [varchar](16) NULL
) ON [PRIMARY]
GO
