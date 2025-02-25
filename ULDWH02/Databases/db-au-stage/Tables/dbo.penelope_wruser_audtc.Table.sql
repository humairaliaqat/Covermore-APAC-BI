USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_wruser_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_wruser_audtc](
	[kbookitemid] [int] NOT NULL,
	[kuserid] [int] NOT NULL,
	[usfirstname] [nvarchar](25) NOT NULL,
	[uslastname] [nvarchar](25) NOT NULL,
	[ustitle] [nvarchar](50) NOT NULL,
	[krepuserid] [int] NULL,
	[uswext] [nvarchar](6) NULL,
	[usphone1] [nvarchar](13) NULL,
	[usphone2] [nvarchar](13) NULL,
	[usemail] [nvarchar](70) NULL,
	[kusergroupid] [int] NOT NULL,
	[usloginid] [nchar](10) NOT NULL,
	[usloginpass] [nchar](10) NULL,
	[usaddress1] [nvarchar](60) NULL,
	[usaddress2] [nvarchar](60) NULL,
	[uscity] [nvarchar](20) NULL,
	[luusprovstateid] [int] NULL,
	[luuscountryid] [int] NULL,
	[luuslanguage1] [int] NULL,
	[luuslanguage2] [int] NULL,
	[luuslanguage3] [int] NULL,
	[uspczip] [nvarchar](12) NULL,
	[usstatus] [varchar](5) NOT NULL,
	[usnotes] [ntext] NULL,
	[usregno] [nvarchar](50) NULL,
	[usfulltimeeq] [numeric](10, 2) NULL,
	[usmaxcaseload] [int] NULL,
	[usmaxindload] [int] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[sloginby] [nvarchar](10) NOT NULL,
	[slogmodby] [nvarchar](10) NOT NULL,
	[ksecurityclassid] [int] NULL,
	[passwordlogmod] [datetime2](7) NOT NULL,
	[kreportsecclassid] [int] NOT NULL,
	[userfahcsiano] [ntext] NULL,
	[passwordexpiryperiodindays] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
