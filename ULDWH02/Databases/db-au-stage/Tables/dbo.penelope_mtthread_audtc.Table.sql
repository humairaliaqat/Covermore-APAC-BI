USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_mtthread_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_mtthread_audtc](
	[kthreadid] [int] NOT NULL,
	[kthreadtypeid] [int] NOT NULL,
	[threadsubject] [nvarchar](140) NOT NULL,
	[kbookitemidauthor] [int] NOT NULL,
	[lutaskpriid] [int] NOT NULL,
	[threadlocked] [varchar](5) NOT NULL,
	[kiocrossid] [int] NULL
) ON [PRIMARY]
GO
