USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[telCallData]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[telCallData](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[AgentName] [nvarchar](100) NULL,
	[TeamName] [nvarchar](255) NULL,
	[Company] [varchar](50) NULL,
	[CSQName] [nvarchar](50) NULL,
	[CallDate] [datetime] NULL,
	[CallStartDateTime] [datetime] NULL,
	[CallEndDateTime] [datetime] NULL,
	[Disposition] [varchar](50) NULL,
	[OriginatorNumber] [nvarchar](30) NULL,
	[DestinationNumber] [nvarchar](30) NULL,
	[CalledNumber] [nvarchar](30) NULL,
	[OrigCalledNumber] [nvarchar](30) NULL,
	[CallsPresented] [int] NULL,
	[CallsHandled] [int] NULL,
	[CallsAbandoned] [int] NULL,
	[RingTime] [int] NULL,
	[TalkTime] [int] NULL,
	[HoldTime] [int] NULL,
	[WorkTime] [int] NULL,
	[WrapUpTime] [int] NULL,
	[QueueTime] [int] NULL,
	[MetServiceLevel] [int] NULL,
	[Transfer] [int] NULL,
	[Redirect] [int] NULL,
	[Conference] [int] NULL,
	[RNA] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_telCallData_BIRowID]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_telCallData_BIRowID] ON [dbo].[telCallData]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_telCallData_Activity]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_telCallData_Activity] ON [dbo].[telCallData]
(
	[CallDate] ASC,
	[AgentName] ASC
)
INCLUDE([TeamName],[Company],[CSQName],[CallStartDateTime],[CallEndDateTime],[CallsPresented],[CallsHandled],[CallsAbandoned],[RingTime],[TalkTime],[HoldTime],[WorkTime],[WrapUpTime],[QueueTime],[MetServiceLevel],[Transfer],[Redirect],[Conference],[RNA]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_telCallData_ActivityTime]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_telCallData_ActivityTime] ON [dbo].[telCallData]
(
	[CallStartDateTime] ASC,
	[AgentName] ASC
)
INCLUDE([TeamName],[Company],[CSQName],[CallDate],[CallEndDateTime],[CallsPresented],[CallsHandled],[CallsAbandoned],[RingTime],[TalkTime],[HoldTime],[WorkTime],[WrapUpTime],[QueueTime],[MetServiceLevel],[Transfer],[Redirect],[Conference],[RNA]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
