USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_drqueslist_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_drqueslist_audtc](
	[kqueslistid] [int] NOT NULL,
	[queslist] [ntext] NULL,
	[kqueslistgroupid] [int] NOT NULL,
	[isdefault] [varchar](5) NOT NULL,
	[sortorder] [int] NOT NULL,
	[valisactive] [varchar](5) NOT NULL,
	[assessval] [numeric](10, 2) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
