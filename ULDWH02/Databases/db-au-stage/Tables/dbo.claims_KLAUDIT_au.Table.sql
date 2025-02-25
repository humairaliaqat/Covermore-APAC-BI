USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLAUDIT_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLAUDIT_au](
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
	[CHSECTION] [varchar](25) NULL,
	[CHSECTDESC] [nvarchar](200) NULL,
	[CHLOSSDATE] [datetime] NULL,
	[CHPSEUDO] [int] NULL,
	[CHCHQNO] [bigint] NULL,
	[CHPOLACT] [date] NULL,
	[CHPAYEE] [nvarchar](250) NULL,
	[CHINSURED] [nvarchar](250) NULL,
	[CHLETNAME] [nvarchar](100) NULL,
	[CHLETTITLE] [nvarchar](100) NULL,
	[CHLETINIT] [nvarchar](100) NULL,
	[CHSTREET] [nvarchar](100) NULL,
	[CHSUBURB] [nvarchar](50) NULL,
	[CHSTATE] [nvarchar](100) NULL,
	[CHPCODE] [nvarchar](50) NULL,
	[CHWORDING_ID] [int] NULL,
	[CHWORDVAR1] [nvarchar](25) NULL,
	[CHWORDVAR2] [nvarchar](25) NULL,
	[CHWORDVAR3] [nvarchar](25) NULL,
	[CHWORDING] [nvarchar](255) NULL,
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
	[CHPAYMETHOD] [varchar](4) NULL,
	[CHADDRESSEE_ID] [int] NULL,
	[CHDFTPAYEE_ID] [int] NULL,
	[CHDFTPAYEE] [nvarchar](250) NULL,
	[CHSTARTCLAIMNO] [int] NULL,
	[CHENDCLAIMNO] [int] NULL,
	[CHSTARTACTPER] [date] NULL,
	[CHENDACTPER] [date] NULL,
	[CHCHQTEMPID] [int] NULL,
	[CHDISS] [datetime] NULL,
	[CHPAYDATE] [date] NULL,
	[CHACCT] [varchar](20) NULL,
	[CHACCTNAME] [nvarchar](100) NULL,
	[CHBSB] [varchar](15) NULL,
	[CHEMAILOK] [bit] NULL,
	[CHEMAIL] [nvarchar](255) NULL,
	[CHTHIRDPARTY] [bit] NULL,
	[CHRANDCHK] [bit] NOT NULL,
	[CHRANDCHKVAL] [varchar](20) NULL,
	[CHRANDCHKVAL2] [varchar](20) NULL,
	[CHSTATUS] [varchar](4) NULL,
	[CHINVOICE] [nvarchar](100) NULL,
	[CHPAYSTATUS] [varchar](4) NULL,
	[CHFileCreated] [bit] NULL,
	[CHEncryptACCT] [varbinary](256) NULL,
	[CHEncryptBSB] [varbinary](2560) NULL,
	[CHISPROVIDER] [bit] NULL,
	[CHSELECT] [bit] NULL,
	[CHITCADJ] [money] NULL,
	[CHRANDCHKDDT] [datetime] NULL,
	[CHRANDCHKDDT2] [datetime] NULL,
	[CHRANDCHKUSER] [int] NULL,
	[CHRANDCHKUSER2] [int] NULL,
	[CHRANDCHKUSERLVL] [varchar](1) NULL,
	[CHRANDCHKUSERLVL2] [varchar](1) NULL,
	[KLDOMAINID] [int] NOT NULL,
	[KPBANKNAME] [nvarchar](50) NULL
) ON [PRIMARY]
GO
