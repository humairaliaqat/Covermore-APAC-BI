USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_sadocdataquery_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_sadocdataquery_audtc](
	[kdocdataqueryid] [int] NOT NULL,
	[kdocdataquerykeyid] [int] NOT NULL,
	[dataquerycat] [ntext] NULL,
	[dataqueryname] [ntext] NULL,
	[dataqueryview] [ntext] NULL,
	[kdocdataquerydatecompopid] [int] NOT NULL,
	[isdatalist] [varchar](5) NOT NULL,
	[textforpreview] [ntext] NULL,
	[snamtable] [ntext] NULL,
	[snamefield] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
