USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_ssdocdataquerykey_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_ssdocdataquerykey_audtc](
	[kdocdataquerykeyid] [int] NOT NULL,
	[docdataquerytablekeyname] [ntext] NULL,
	[docdataquerykeyentitydesc] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
