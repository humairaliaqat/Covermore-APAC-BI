USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_drqueslistgroup_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_drqueslistgroup_audtc](
	[kqueslistgroupid] [int] NOT NULL,
	[queslistgroup] [ntext] NULL,
	[sharelist] [varchar](5) NOT NULL,
	[defaultsort] [varchar](5) NOT NULL,
	[cbcol] [int] NOT NULL,
	[isassesslist] [varchar](5) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[kuseridlogin] [int] NOT NULL,
	[kuseridlogmod] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
