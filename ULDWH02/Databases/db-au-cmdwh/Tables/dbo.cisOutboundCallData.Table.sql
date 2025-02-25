USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cisOutboundCallData]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisOutboundCallData](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[SessionKey] [nvarchar](50) NOT NULL,
	[SessionID] [bigint] NOT NULL,
	[AgentKey] [nvarchar](50) NOT NULL,
	[CallStartDateTime] [datetime] NOT NULL,
	[CallEndDateTime] [datetime] NOT NULL,
	[CallDuration] [int] NOT NULL,
	[TalkTime] [int] NOT NULL,
	[OriginatorNumber] [nvarchar](30) NOT NULL,
	[DestinationNumber] [nvarchar](30) NOT NULL,
	[CalledNumber] [nvarchar](30) NOT NULL,
	[OutboundCallType] [varchar](10) NOT NULL,
	[EmployeeKey] [int] NULL,
	[OrganisationKey] [int] NULL,
	[Team] [varchar](50) NULL,
	[Agent] [varchar](50) NULL,
	[LoginID] [varchar](50) NULL,
	[SupervisorFlag] [bit] NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_cisOutboundCallData_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_cisOutboundCallData_BIRowID] ON [dbo].[cisOutboundCallData]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cisOutboundCallData_CallTimes]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cisOutboundCallData_CallTimes] ON [dbo].[cisOutboundCallData]
(
	[CallStartDateTime] ASC,
	[CallEndDateTime] ASC
)
INCLUDE([AgentKey],[CallDuration],[OutboundCallType],[TalkTime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cisOutboundCallData_SessionKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cisOutboundCallData_SessionKey] ON [dbo].[cisOutboundCallData]
(
	[SessionKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
