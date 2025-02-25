USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_dtcomdoc_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_dtcomdoc_audtc](
	[kcomdocid] [int] NOT NULL,
	[kcaseid] [int] NULL,
	[cdoctitle] [ntext] NULL,
	[cdocdesciption] [nvarchar](50) NULL,
	[cdocdate] [datetime2](7) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[sloginby] [nvarchar](10) NULL,
	[slogmodby] [nvarchar](10) NULL,
	[kprogprovid] [int] NULL,
	[doclock] [varchar](5) NULL,
	[korigcomdocid] [int] NULL,
	[kactid] [int] NULL,
	[kdocid] [int] NOT NULL,
	[kdocstagenameid] [int] NULL,
	[kbookitemid] [int] NULL,
	[kcomdocrevid] [int] NULL,
	[kcomdocrevstateid] [int] NOT NULL,
	[kuseridlogin] [int] NOT NULL,
	[kuseridlogmod] [int] NOT NULL,
	[iocompletedby] [int] NULL,
	[kiocrossid] [int] NULL,
	[kbookitemidlogin] [int] NOT NULL,
	[kbookitemidlogmod] [int] NOT NULL,
	[completiontime] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
