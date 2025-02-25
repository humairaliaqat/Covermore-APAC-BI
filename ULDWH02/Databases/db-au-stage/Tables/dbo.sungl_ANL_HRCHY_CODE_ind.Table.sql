USE [db-au-stage]
GO
/****** Object:  Table [dbo].[sungl_ANL_HRCHY_CODE_ind]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sungl_ANL_HRCHY_CODE_ind](
	[BusinessUnit] [varchar](50) NULL,
	[ANL_CAT_ID] [varchar](50) NULL,
	[ANL_HRCHY_LAB] [varchar](50) NULL,
	[ANL_HRCHY_CODE] [varchar](50) NULL,
	[UPDATE_COUNT] [int] NULL,
	[LAST_CHANGE_USER_ID] [varchar](50) NULL,
	[LAST_CHANGE_DATETIME] [datetime] NULL,
	[STATUS] [int] NULL,
	[LOOKUP] [varchar](50) NULL,
	[S_HEAD] [varchar](50) NULL,
	[DESCR] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [cidx_ind]    Script Date: 24/02/2025 5:08:06 PM ******/
CREATE CLUSTERED INDEX [cidx_ind] ON [dbo].[sungl_ANL_HRCHY_CODE_ind]
(
	[BusinessUnit] ASC,
	[ANL_HRCHY_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
