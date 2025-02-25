USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_onlinepayments_uk]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_onlinepayments_uk](
	[PAYID] [int] NOT NULL,
	[PPPOLYN] [int] NULL,
	[MERCHANTTXTREF] [varchar](50) NULL,
	[ORDERINFO] [varchar](50) NULL,
	[MERCHANTID] [varchar](50) NULL,
	[AMOUNTPAID] [money] NULL,
	[RECEIPTNO] [varchar](50) NULL,
	[QSIRESPONSECODE] [varchar](50) NULL,
	[RESPONSEDESCRIPTION] [varchar](255) NULL,
	[ACQRESPONSECODE] [varchar](50) NULL,
	[TRANSACTIONNO] [varchar](50) NULL,
	[AUTHORIZEID] [varchar](50) NULL,
	[BATCHNO] [varchar](50) NULL,
	[CARDTYPE] [varchar](50) NULL,
	[DATEADD] [datetime] NULL,
	[Record_Date] [datetime] NULL,
	[ACT] [datetime] NULL,
	[PaymentGatewayID] [varchar](50) NULL,
	[CLIENTID] [int] NULL,
	[ORDERID] [int] NULL,
	[PAYMENTREF_ID] [int] NULL,
	[TOTAL] [money] NULL,
	[TTIME] [datetime] NULL,
	[status] [varchar](100) NULL,
	[onlinepaymentid] [int] NULL
) ON [PRIMARY]
GO
