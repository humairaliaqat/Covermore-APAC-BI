USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLAUDIT_nz]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLAUDIT_nz](
	[CH_ID] [int] NOT NULL,
	[CHCLAIM] [int] NULL,
	[CHITEM] [int] NULL,
	[CHPAYID] [int] NULL,
	[CHPAYEE_ID] [int] NULL,
	[CHACCOUNT_ID] [int] NULL,
	[CHOFFICER_ID] [int] NULL,
	[CHBATCH] [int] NULL,
	[CHDEL] [bit] NOT NULL,
	[CHSULLIED] [bit] NOT NULL,
	[CHPROD] [varchar](4) NULL,
	[CHSECTION] [varchar](3) NULL,
	[CHSECTDESC] [varchar](40) NULL,
	[CHLOSSDATE] [datetime] NULL,
	[CHPSEUDO] [int] NULL,
	[CHCHQNO] [int] NULL,
	[CHPOLACT] [datetime] NULL,
	[CHPAYEE] [varchar](80) NULL,
	[CHLETNAME] [varchar](80) NULL,
	[CHLETTITLE] [varchar](10) NULL,
	[CHLETINIT] [varchar](1) NULL,
	[CHSTREET] [varchar](100) NULL,
	[CHSUBURB] [varchar](20) NULL,
	[CHSTATE] [varchar](5) NULL,
	[CHPCODE] [varchar](8) NULL,
	[CHBILLAMT] [money] NULL,
	[CHCURR] [varchar](4) NULL,
	[CHRATE] [float] NULL,
	[CHAUD] [money] NULL,
	[CHEXCESS] [money] NULL,
	[CHDEPV] [money] NULL,
	[CHOTHER] [money] NULL,
	[CHGST] [money] NULL,
	[CHVALUE] [money] NULL,
	[CHMODIFY_DT] [datetime] NULL,
	[CHINSURED] [varchar](45) NULL,
	[CHPAYDATE] [datetime] NULL,
	[CHMANUAL] [bit] NOT NULL,
	[CHDFTPAYEE_ID] [int] NULL,
	[CHDFTPAYEE] [varchar](50) NULL,
	[CHPAYMETHOD] [varchar](3) NULL
) ON [PRIMARY]
GO
