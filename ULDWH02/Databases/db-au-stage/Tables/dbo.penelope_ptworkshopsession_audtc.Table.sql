USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_ptworkshopsession_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_ptworkshopsession_audtc](
	[kworkshopsessionid] [int] NOT NULL,
	[kcworkshopid] [int] NOT NULL,
	[wssessionstart] [datetime2](7) NOT NULL,
	[wssessionend] [datetime2](7) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[slogmodby] [nvarchar](10) NULL,
	[sessallresolved] [varchar](5) NULL,
	[sessallbooked] [varchar](5) NULL,
	[sessnotes] [ntext] NULL,
	[sessattendlimit] [int] NULL,
	[ksiteid] [int] NOT NULL,
	[bookprimary] [varchar](5) NULL,
	[wsnonsched] [varchar](5) NOT NULL,
	[kcworkeridprimsess] [int] NOT NULL,
	[kbookitemidlogin] [int] NOT NULL,
	[kbookitemidlogmod] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
