USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_dtcomdocrevbody_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_dtcomdocrevbody_audtc](
	[kcomdocrevbodyid] [int] NOT NULL,
	[kcomdocrevid] [int] NOT NULL,
	[kpartidbody] [int] NOT NULL,
	[kbookitemid] [int] NULL
) ON [PRIMARY]
GO
