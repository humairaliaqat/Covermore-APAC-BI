USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrCallMapping]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrCallMapping](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Answer Point] [nvarchar](30) NULL,
	[Call Classification] [varchar](250) NULL,
	[Call Type] [varchar](50) NULL,
	[Agent Group] [varchar](50) NULL,
	[Caller] [varchar](50) NULL,
	[Team Type] [varchar](50) NULL,
	[Start Date] [date] NULL,
	[End Date] [date] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE UNIQUE CLUSTERED INDEX [cidx] ON [dbo].[usrCallMapping]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[usrCallMapping]
(
	[Answer Point] ASC,
	[Start Date] ASC,
	[End Date] ASC
)
INCLUDE([Call Classification],[Call Type],[Agent Group],[Caller],[Team Type]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
