USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[verAdherence]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[verAdherence](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[AdherenceID] [int] NOT NULL,
	[ActivityKey] [int] NOT NULL,
	[EmployeeKey] [int] NOT NULL,
	[SupervisorEmployeeKey] [int] NOT NULL,
	[OrganisationKey] [int] NOT NULL,
	[TimelineID] [int] NOT NULL,
	[ActivityStartTime] [datetime] NOT NULL,
	[ActivityEndTime] [datetime] NOT NULL,
	[ActivityStartTimeGMT] [datetime] NOT NULL,
	[ActivityEndTimeGMT] [datetime] NOT NULL,
	[ExceptionApprover] [nvarchar](255) NOT NULL,
	[ApprovedExceptionDuration] [float] NOT NULL,
	[UnapprovedExceptionDuration] [float] NOT NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_verAdherence_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_verAdherence_BIRowID] ON [dbo].[verAdherence]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_factAdherence_AdherenceID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_factAdherence_AdherenceID] ON [dbo].[verAdherence]
(
	[AdherenceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_factAdherence_Datetime]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_factAdherence_Datetime] ON [dbo].[verAdherence]
(
	[ActivityStartTime] ASC,
	[ActivityEndTime] ASC
)
INCLUDE([ActivityKey],[EmployeeKey],[OrganisationKey],[ActivityStartTimeGMT],[ActivityEndTimeGMT],[ApprovedExceptionDuration],[UnapprovedExceptionDuration]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_factAdherence_SupervisorEmployeeKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_factAdherence_SupervisorEmployeeKey] ON [dbo].[verAdherence]
(
	[SupervisorEmployeeKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
