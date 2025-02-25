USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[telActivity]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[telActivity](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[AgentName] [nvarchar](100) NULL,
	[TeamName] [nvarchar](255) NULL,
	[ActivityDate] [datetime] NULL,
	[ActivityStartTime] [datetime] NULL,
	[ActivityEndTime] [datetime] NULL,
	[Activity] [nvarchar](255) NULL,
	[ActualActivityTime] [float] NULL,
	[ScheduledActivityTime] [float] NULL,
	[ApprovedExceptionDuration] [float] NULL,
	[UnapprovedExceptionDuration] [float] NULL,
	[QualityScore] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_telActivity_BIRowID]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_telActivity_BIRowID] ON [dbo].[telActivity]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_telActivity_Activity]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_telActivity_Activity] ON [dbo].[telActivity]
(
	[ActivityDate] ASC,
	[AgentName] ASC
)
INCLUDE([TeamName],[Activity],[ActivityStartTime],[ActualActivityTime],[ScheduledActivityTime],[ApprovedExceptionDuration],[UnapprovedExceptionDuration],[QualityScore]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_telActivity_ActivityTime]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_telActivity_ActivityTime] ON [dbo].[telActivity]
(
	[ActivityStartTime] ASC,
	[AgentName] ASC
)
INCLUDE([TeamName],[Activity],[ActivityDate],[ActualActivityTime],[ScheduledActivityTime],[ApprovedExceptionDuration],[UnapprovedExceptionDuration],[QualityScore]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
