USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cisCalls]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisCalls](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[SessionKey] [varchar](50) NOT NULL,
	[SessionID] [bigint] NULL,
	[SessionSequence] [int] NULL,
	[NodeID] [int] NULL,
	[ProfileID] [int] NULL,
	[ContactType] [varchar](50) NULL,
	[ContactDisposition] [varchar](50) NULL,
	[DispositionReason] [varchar](100) NULL,
	[OriginatorTypeID] [int] NULL,
	[OriginatorType] [varchar](50) NULL,
	[OriginatorID] [int] NULL,
	[OriginatorAgent] [varchar](50) NULL,
	[OriginatorExt] [varchar](50) NULL,
	[OriginatorNumber] [varchar](50) NULL,
	[DestinationTypeID] [int] NULL,
	[DestinationType] [varchar](50) NULL,
	[DestinationID] [int] NULL,
	[DestinationAgent] [varchar](50) NULL,
	[DestinationExt] [varchar](50) NULL,
	[DestinationNumber] [varchar](50) NULL,
	[CallResult] [varchar](50) NULL,
	[CallStartDateTime] [datetime] NULL,
	[CallEndDateTime] [datetime] NULL,
	[CallStartDateTimeUTC] [datetime] NULL,
	[CallEndDateTimeUTC] [datetime] NULL,
	[GatewayNumber] [varchar](50) NULL,
	[DialedNumber] [varchar](50) NULL,
	[Transfer] [int] NULL,
	[Redirect] [int] NULL,
	[Conference] [int] NULL,
	[ConnectTime] [int] NULL,
	[RingTime] [int] NULL,
	[TalkTime] [int] NULL,
	[HoldTime] [int] NULL,
	[WorkTime] [int] NULL,
	[WrapUpTime] [int] NULL,
	[TargetType] [varchar](50) NULL,
	[TargetID] [int] NULL,
	[CSQName] [varchar](50) NULL,
	[QueueDisposition] [varchar](50) NULL,
	[QueueHandled] [int] NULL,
	[QueueAbandoned] [int] NULL,
	[QueueTime] [int] NULL,
	[ServiceLevelPercentage] [int] NULL,
	[MetServiceLevel] [int] NULL,
	[Agent] [varchar](50) NULL,
	[Team] [varchar](50) NULL,
	[LoginID] [varchar](50) NULL,
	[SupervisorFlag] [int] NULL,
	[VarCSQName] [varchar](40) NULL,
	[VarEXT] [varchar](40) NULL,
	[VarClassification] [varchar](40) NULL,
	[VarIVROption] [varchar](40) NULL,
	[VarIVRReference] [varchar](40) NULL,
	[VarWrapUp] [varchar](40) NULL,
	[WrapUpData] [varchar](40) NULL,
	[AccountNumber] [varchar](40) NULL,
	[CallerEnteredDigits] [varchar](40) NULL,
	[BadCallTag] [char](1) NULL,
	[ApplicationID] [int] NULL,
	[ApplicationName] [varchar](30) NULL,
	[CampaignID] [int] NULL,
	[DialinglistID] [int] NULL,
	[OriginProtocol] [varchar](50) NULL,
	[DestinationProtocol] [varchar](50) NULL,
	[UpdateDateTime] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_cisCalls_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_cisCalls_BIRowID] ON [dbo].[cisCalls]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cisCalls_SessionID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cisCalls_SessionID] ON [dbo].[cisCalls]
(
	[SessionID] ASC
)
INCLUDE([CallStartDateTime],[CallEndDateTime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cisCalls_SessionKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cisCalls_SessionKey] ON [dbo].[cisCalls]
(
	[SessionKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cisCalls_Time]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cisCalls_Time] ON [dbo].[cisCalls]
(
	[CallStartDateTime] ASC,
	[CallEndDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cisCalls] ADD  DEFAULT (getdate()) FOR [UpdateDateTime]
GO
