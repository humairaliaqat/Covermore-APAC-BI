USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_ptcaseworkshops_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_ptcaseworkshops_audtc](
	[kcworkshopid] [int] NOT NULL,
	[kcaseprogid] [int] NOT NULL,
	[wsname] [nvarchar](50) NOT NULL,
	[kprogcyclestatusid] [int] NOT NULL,
	[kactivitytypeid] [int] NOT NULL,
	[wsnotes] [ntext] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[wscont] [varchar](5) NULL,
	[kcworkeridprim] [int] NULL,
	[kcworkeridsec] [int] NULL,
	[wsattendlimit] [int] NULL,
	[ksiteid] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
