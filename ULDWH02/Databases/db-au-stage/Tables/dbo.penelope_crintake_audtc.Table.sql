USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_crintake_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_crintake_audtc](
	[kcaseid] [int] NOT NULL,
	[itsummary] [ntext] NULL,
	[luit1presissueid] [int] NULL,
	[luit2presissueid] [int] NULL,
	[luit3presissueid] [int] NULL,
	[luit4presissueid] [int] NULL,
	[itreopen] [varchar](5) NULL,
	[itdatereopen] [datetime2](7) NULL,
	[itformalref] [varchar](5) NULL,
	[itreferraldate] [datetime2](7) NULL,
	[luitreferralid] [int] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[sloginby] [nvarchar](10) NOT NULL,
	[slogmodby] [nvarchar](10) NOT NULL,
	[luit5presissueid] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
