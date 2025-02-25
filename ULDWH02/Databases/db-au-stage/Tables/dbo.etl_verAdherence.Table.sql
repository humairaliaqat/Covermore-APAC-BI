USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_verAdherence]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_verAdherence](
	[ActivityKey] [int] NOT NULL,
	[EmployeeKey] [int] NOT NULL,
	[SupervisorEmployeeKey] [int] NOT NULL,
	[OrganisationKey] [int] NOT NULL,
	[TimelineID] [int] NOT NULL,
	[AdherenceID] [int] NOT NULL,
	[ActivityStartTime] [datetime] NULL,
	[ActivityEndTime] [datetime] NULL,
	[ActivityStartTimeGMT] [datetime] NOT NULL,
	[ActivityEndTimeGMT] [datetime] NOT NULL,
	[ExceptionApprover] [varchar](260) NOT NULL,
	[ApprovedExceptionDuration] [float] NULL,
	[UnapprovedExceptionDuration] [float] NULL
) ON [PRIMARY]
GO
