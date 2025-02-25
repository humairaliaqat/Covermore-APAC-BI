USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_dtcomanswer_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_dtcomanswer_audtc](
	[kcomanswerid] [int] NOT NULL,
	[kpartidques] [int] NOT NULL,
	[kcomdocrevbodyid] [int] NOT NULL,
	[comother] [ntext] NULL,
	[comtext] [ntext] NULL,
	[isanswered] [varchar](5) NOT NULL,
	[kcomansweridkey] [int] NULL,
	[kcompositepartid] [int] NULL,
	[isvalidated] [varchar](5) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
