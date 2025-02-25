USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_frfunder_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_frfunder_audtc](
	[kfunderid] [int] NOT NULL,
	[funorg] [nvarchar](50) NOT NULL,
	[funbillto] [nvarchar](50) NOT NULL,
	[lustatementcycleid] [int] NOT NULL,
	[funaddress1] [nvarchar](60) NULL,
	[funaddress2] [nvarchar](60) NULL,
	[funcity] [nvarchar](20) NULL,
	[lufunprovsateid] [int] NULL,
	[lufuncountryid] [int] NULL,
	[funpczip] [nvarchar](12) NULL,
	[funphone1] [nvarchar](13) NOT NULL,
	[funphone2] [nvarchar](13) NULL,
	[funfax] [nvarchar](13) NULL,
	[funurl] [nvarchar](70) NULL,
	[funnotes] [nvarchar](1000) NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[sloginby] [nvarchar](10) NOT NULL,
	[slogmodby] [nvarchar](10) NOT NULL,
	[funnoteslong] [ntext] NULL,
	[lufundertypeid] [int] NULL,
	[lufundertype2id] [int] NULL,
	[ktaxschedid] [int] NULL,
	[kfunderclassid] [int] NOT NULL,
	[issubmiticd10codes] [varchar](5) NOT NULL,
	[lustateid] [int] NOT NULL,
	[kbilltypeid] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
