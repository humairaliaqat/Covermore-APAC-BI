USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_drdocstagename_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_drdocstagename_audtc](
	[kdocstagenameid] [int] NOT NULL,
	[kdocstageid] [int] NOT NULL,
	[kdocmastid] [int] NOT NULL,
	[docstagename] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
