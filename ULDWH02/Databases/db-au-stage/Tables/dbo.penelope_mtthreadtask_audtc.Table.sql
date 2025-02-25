USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_mtthreadtask_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_mtthreadtask_audtc](
	[kthreadid] [int] NOT NULL,
	[ktaskstatusid] [int] NOT NULL,
	[kbookitemidassigned] [int] NULL,
	[ktaskcancelid] [int] NULL,
	[taskdatefrom] [date] NOT NULL,
	[taskdateto] [date] NOT NULL,
	[taskdatecomp] [date] NULL,
	[kdocmastid] [int] NULL,
	[kcomdocid] [int] NULL,
	[kthreadidparent] [int] NULL,
	[kthreadidprev] [int] NULL,
	[approved] [varchar](5) NOT NULL,
	[kdocstagenameid] [int] NULL
) ON [PRIMARY]
GO
