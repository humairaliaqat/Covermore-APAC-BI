USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_dtanswersite_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_dtanswersite_audtc](
	[kcomanswerid] [int] NOT NULL,
	[ksiteid] [int] NOT NULL,
	[answer] [varchar](5) NOT NULL
) ON [PRIMARY]
GO
