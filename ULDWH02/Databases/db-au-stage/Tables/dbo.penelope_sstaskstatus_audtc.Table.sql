USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_sstaskstatus_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_sstaskstatus_audtc](
	[ktaskstatusid] [int] NOT NULL,
	[taskstatus] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
