USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[verActivityTimeline]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[verActivityTimeline](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[ActivityTimelineKey] [nvarchar](50) NOT NULL,
	[ActivityKey] [int] NOT NULL,
	[EmployeeKey] [int] NOT NULL,
	[SupervisorEmployeeKey] [int] NOT NULL,
	[OrganisationKey] [int] NOT NULL,
	[TimelineID] [int] NOT NULL,
	[TimeLineType] [nvarchar](50) NOT NULL,
	[ActivityStartTime] [datetime] NOT NULL,
	[ActivityEndTime] [datetime] NOT NULL,
	[ActivityStartTimeGMT] [datetime] NOT NULL,
	[ActivityEndTimeGMT] [datetime] NOT NULL,
	[ActivityTime] [float] NOT NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
	[ISUNPUBLISHED] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_verActivityTimeline_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_verActivityTimeline_BIRowID] ON [dbo].[verActivityTimeline]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_verActivityTimeline_ActivityTimelineKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_verActivityTimeline_ActivityTimelineKey] ON [dbo].[verActivityTimeline]
(
	[ActivityTimelineKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_verActivityTimeline_Datetime]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_verActivityTimeline_Datetime] ON [dbo].[verActivityTimeline]
(
	[ActivityStartTime] ASC,
	[ActivityEndTime] ASC,
	[ActivityStartTimeGMT] ASC,
	[ActivityEndTimeGMT] ASC
)
INCLUDE([ActivityKey],[EmployeeKey],[OrganisationKey],[TimeLineType],[ActivityTime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_verActivityTimeline_EmployeeKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_verActivityTimeline_EmployeeKey] ON [dbo].[verActivityTimeline]
(
	[EmployeeKey] ASC,
	[ActivityStartTime] ASC
)
INCLUDE([SupervisorEmployeeKey],[OrganisationKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_verActivityTimeline_SupervisorEmployeeKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_verActivityTimeline_SupervisorEmployeeKey] ON [dbo].[verActivityTimeline]
(
	[SupervisorEmployeeKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
