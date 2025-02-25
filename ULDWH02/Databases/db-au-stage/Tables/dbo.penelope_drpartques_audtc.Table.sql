USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_drpartques_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_drpartques_audtc](
	[kpartid] [int] NOT NULL,
	[kpartquestypeid] [int] NOT NULL,
	[kpartquesformatid] [int] NOT NULL,
	[quesinline] [varchar](5) NOT NULL,
	[kqueslistgroupid] [int] NULL,
	[quesuseother] [varchar](5) NOT NULL,
	[kpartquescommtypeid] [int] NOT NULL,
	[quescommtext] [ntext] NULL,
	[kpartquesansid] [int] NOT NULL,
	[abbrev] [ntext] NULL,
	[queshelptext] [ntext] NULL,
	[quesdefault] [ntext] NULL,
	[decplaces] [int] NULL,
	[limitlower] [numeric](10, 2) NULL,
	[limitupper] [numeric](10, 2) NULL,
	[showcb] [varchar](5) NOT NULL,
	[shareques] [varchar](5) NOT NULL,
	[isassess] [varchar](5) NOT NULL,
	[kdocdataqueryspeckeyid] [int] NULL,
	[kdocdataqueryid] [int] NULL,
	[lowerendpointtext] [ntext] NULL,
	[upperendpointtext] [ntext] NULL,
	[hidena] [varchar](5) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
