USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_btinvoice_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_btinvoice_audtc](
	[kinvoicenoid] [int] NOT NULL,
	[kindid] [int] NULL,
	[kfunagreid] [int] NULL,
	[sinvdate] [datetime2](7) NOT NULL,
	[invbillto] [nvarchar](50) NULL,
	[invname] [nvarchar](50) NULL,
	[invaddress1] [nvarchar](60) NULL,
	[invaddress2] [nvarchar](60) NULL,
	[invcity] [nvarchar](20) NULL,
	[invprovstate] [nvarchar](20) NULL,
	[invcountry] [nvarchar](30) NULL,
	[invpczip] [nvarchar](12) NULL,
	[slogin] [datetime2](7) NULL,
	[slogmod] [datetime2](7) NULL,
	[sloginby] [nvarchar](10) NOT NULL,
	[slogmodby] [nvarchar](10) NOT NULL,
	[kfunderid] [int] NULL,
	[invposted] [varchar](5) NOT NULL,
	[batchno] [int] NULL,
	[paymenttermsdue] [date] NULL,
	[invfullapplied] [varchar](5) NULL,
	[invpartapplied] [varchar](5) NULL,
	[invfullapplieddate] [date] NULL,
	[payabletositeid] [int] NULL,
	[kinvoicecurrencysignid] [int] NULL,
	[properties] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
