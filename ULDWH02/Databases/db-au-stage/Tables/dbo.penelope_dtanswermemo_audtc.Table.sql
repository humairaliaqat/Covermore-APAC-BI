USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_dtanswermemo_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_dtanswermemo_audtc](
	[kcomanswerid] [int] NOT NULL,
	[answer] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
