USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_btreceipts_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_btreceipts_audtc](
	[kreceiptid] [int] NOT NULL,
	[kreceipttypeid] [int] NOT NULL,
	[kindid] [int] NULL,
	[kfunderid] [int] NULL,
	[recname] [nvarchar](75) NULL,
	[recchequeno] [nvarchar](15) NULL,
	[recamount] [numeric](10, 2) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[sloginby] [nvarchar](10) NOT NULL,
	[slogmodby] [nvarchar](10) NOT NULL,
	[lurecpid] [int] NULL,
	[fullyapplied] [varchar](5) NULL,
	[fullyapplieddate] [date] NULL,
	[reclock] [varchar](5) NOT NULL,
	[ksiteid] [int] NULL,
	[kdepositid] [int] NULL,
	[kagserid] [int] NULL,
	[lusiteregionid] [int] NULL,
	[cctransid] [ntext] NULL,
	[ccpenrefno] [ntext] NULL,
	[applicablefrom] [date] NULL,
	[applicableto] [date] NULL,
	[kinvoicecurrencysignid] [int] NULL,
	[kccconfigid] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
