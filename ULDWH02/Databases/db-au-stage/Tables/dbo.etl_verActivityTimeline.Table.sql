USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_verActivityTimeline]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_verActivityTimeline](
	[ActivityTimelineKey] [varchar](91) NULL,
	[ActivityKey] [int] NOT NULL,
	[EmployeeKey] [int] NOT NULL,
	[SupervisorEmployeeKey] [int] NOT NULL,
	[OrganisationKey] [int] NOT NULL,
	[TimelineID] [int] NOT NULL,
	[TimeLineType] [varchar](7) NOT NULL,
	[ActivityStartTime] [datetime] NULL,
	[ActivityEndTime] [datetime] NULL,
	[ActivityStartTimeGMT] [datetime] NOT NULL,
	[ActivityEndTimeGMT] [datetime] NOT NULL,
	[ActivityTime] [float] NULL,
	[ISUNPUBLISHED] [int] NOT NULL
) ON [PRIMARY]
GO
