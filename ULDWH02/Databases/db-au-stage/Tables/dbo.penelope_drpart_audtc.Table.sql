USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_drpart_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_drpart_audtc](
	[kpartid] [int] NOT NULL,
	[partname] [ntext] NULL,
	[kdocpartclassid] [int] NOT NULL,
	[numberpart] [varchar](5) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[kuseridlogin] [int] NOT NULL,
	[kuseridlogmod] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
