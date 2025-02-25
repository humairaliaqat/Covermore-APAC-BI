USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_frpublicpolicy_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_frpublicpolicy_audtc](
	[kpublicpolicyid] [int] NOT NULL,
	[kfunderid] [int] NOT NULL,
	[pubpolname] [nvarchar](50) NOT NULL,
	[pubpolno] [nvarchar](25) NULL,
	[lupubpolcatid] [int] NOT NULL,
	[pubpolstatus] [varchar](5) NOT NULL,
	[pubpolnoshow] [numeric](6, 4) NOT NULL,
	[pubpolstart] [datetime2](7) NULL,
	[pubpolend] [datetime2](7) NULL,
	[pubpolnote] [ntext] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[kpolicytypeid] [int] NULL,
	[poldisableffs] [varchar](5) NOT NULL,
	[searchdepttreeforbillto] [varchar](5) NOT NULL,
	[allowoverridebillto] [varchar](5) NOT NULL,
	[payabletositeid] [int] NULL,
	[kinvoicecurrencysignid] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
