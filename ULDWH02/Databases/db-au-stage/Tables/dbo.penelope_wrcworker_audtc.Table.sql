USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_wrcworker_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_wrcworker_audtc](
	[kcworkerid] [int] NOT NULL,
	[kuserid] [int] NOT NULL,
	[luqualificationid] [int] NULL,
	[cworkeraccept] [varchar](5) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[cworkerssn] [nvarchar](9) NULL,
	[cworkerein] [nvarchar](9) NULL,
	[cworkernpi] [nvarchar](10) NULL,
	[cworkertax] [nvarchar](30) NULL,
	[dvqual] [varchar](5) NULL,
	[kcworkeridrend] [int] NULL,
	[krenderingproviderid] [int] NULL,
	[kreferringphysicianid] [int] NULL,
	[kbluebookidrefphys] [int] NULL,
	[cworkermedicarepi] [nvarchar](30) NULL
) ON [PRIMARY]
GO
