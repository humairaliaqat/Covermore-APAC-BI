USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cisAgentState]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisAgentState](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[AgentKey] [nvarchar](50) NOT NULL,
	[EventDateTime] [datetime] NOT NULL,
	[EventType] [int] NULL,
	[EventDescription] [varchar](30) NULL,
	[EventDuration] [int] NOT NULL,
	[ReasonCode] [int] NULL,
	[EmployeeKey] [int] NULL,
	[OrganisationKey] [int] NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_cisAgentState_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_cisAgentState_BIRowID] ON [dbo].[cisAgentState]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cisAgentState_EventTimes]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cisAgentState_EventTimes] ON [dbo].[cisAgentState]
(
	[EventDateTime] ASC,
	[AgentKey] ASC,
	[EventType] ASC
)
INCLUDE([EventDescription],[EventDuration]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
