USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_mtthreadproc_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_mtthreadproc_audtc](
	[kthreadid] [int] NOT NULL,
	[kclientcomconfigid] [int] NULL,
	[kautothreadid] [int] NULL,
	[kprimkeyid] [int] NULL
) ON [PRIMARY]
GO
