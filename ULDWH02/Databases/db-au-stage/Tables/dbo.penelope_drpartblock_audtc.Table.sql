USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_drpartblock_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_drpartblock_audtc](
	[kpartid] [int] NOT NULL,
	[blocktitle] [ntext] NULL,
	[blockheadertext] [ntext] NULL,
	[blockfootertext] [ntext] NULL,
	[kdocstyleid] [int] NULL,
	[kpartnumberingid] [int] NOT NULL,
	[includeparentnum] [varchar](5) NOT NULL,
	[contqnum] [varchar](5) NOT NULL,
	[kpartidbelongbody] [int] NULL,
	[componentadvlayoutidentifier] [int] NOT NULL,
	[float] [varchar](5) NOT NULL,
	[sectionwidth] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
