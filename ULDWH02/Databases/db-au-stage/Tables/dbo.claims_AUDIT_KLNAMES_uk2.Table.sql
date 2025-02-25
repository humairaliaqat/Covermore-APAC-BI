USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_AUDIT_KLNAMES_uk2]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_AUDIT_KLNAMES_uk2](
	[AUDIT_USERNAME] [varchar](255) NULL,
	[AUDIT_DATETIME] [datetime] NULL,
	[AUDIT_ACTION] [varchar](10) NULL,
	[KN_ID] [int] NOT NULL,
	[KNCLAIM_ID] [int] NULL,
	[KNNUM] [smallint] NULL,
	[KNSURNAME] [nvarchar](100) NULL,
	[KNFIRST] [nvarchar](100) NULL,
	[KNTITLE] [nvarchar](50) NULL,
	[KNDOB] [date] NULL,
	[KNSTREET] [nvarchar](100) NULL,
	[KNSUBURB] [nvarchar](50) NULL,
	[KNSTATE] [nvarchar](100) NULL,
	[KNCOUNTRY] [nvarchar](100) NULL,
	[KNPCODE] [nvarchar](50) NULL,
	[KNHPHONE] [nvarchar](50) NULL,
	[KNWPHONE] [nvarchar](50) NULL,
	[KNFAX] [varchar](20) NULL,
	[KNEMAIL] [nvarchar](255) NULL,
	[KNDIRECTCRED] [bit] NOT NULL,
	[KNACCT] [varchar](20) NULL,
	[KNACCTNAME] [nvarchar](100) NULL,
	[KNBSB] [varchar](6) NULL,
	[KNPRIMARY] [bit] NOT NULL,
	[KNTHIRDPARTY] [bit] NOT NULL,
	[KNFOREIGN] [bit] NOT NULL,
	[KNPROV_ID] [int] NULL,
	[KNBUSINESSNAME] [varchar](30) NULL,
	[KNEMAILOK] [bit] NULL,
	[KNPAYMENTMETHODID] [int] NULL,
	[KNEMC] [nvarchar](100) NULL,
	[KNITC] [bit] NULL,
	[KNITCPCT] [float] NULL,
	[KPGST] [bit] NULL,
	[KPGSTPERC] [float] NULL,
	[KPGOODSSUPPLIER] [bit] NULL,
	[KPSERVPROV] [bit] NULL,
	[KPSUPPLYBY] [int] NULL,
	[KNEncryptACCT] [varbinary](256) NULL,
	[KNEncryptBSB] [varbinary](256) NULL,
	[KNPAYER] [bit] NULL,
	[KPBANKNAME] [nvarchar](50) NULL,
	[KNFISCALECODE] [nvarchar](20) NULL
) ON [PRIMARY]
GO
