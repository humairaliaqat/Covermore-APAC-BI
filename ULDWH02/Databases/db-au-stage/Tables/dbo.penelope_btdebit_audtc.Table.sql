USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_btdebit_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_btdebit_audtc](
	[kdebitid] [int] NOT NULL,
	[kindid] [int] NULL,
	[kfunderid] [int] NULL,
	[debitdesc] [nvarchar](75) NOT NULL,
	[debitrefno] [nvarchar](15) NOT NULL,
	[debitamount] [numeric](10, 2) NOT NULL,
	[ludebitreasonid] [int] NULL,
	[debitpaid] [varchar](5) NOT NULL,
	[debitpartpaid] [varchar](5) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[sloginby] [nvarchar](10) NULL,
	[slogmodby] [nvarchar](10) NULL,
	[ksiteid] [int] NULL,
	[fullyapplieddate] [date] NULL,
	[kagserid] [int] NULL,
	[lusiteregionid] [int] NULL,
	[debittaxamt] [numeric](10, 2) NOT NULL,
	[debitsubamt] [numeric](10, 2) NOT NULL,
	[ccrefundtransid] [ntext] NULL,
	[applicablefrom] [date] NULL,
	[applicableto] [date] NULL,
	[kinvoicecurrencysignid] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
