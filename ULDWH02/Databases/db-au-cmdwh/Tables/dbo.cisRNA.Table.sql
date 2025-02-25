USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cisRNA]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisRNA](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[SessionKey] [nvarchar](50) NOT NULL,
	[SessionID] [numeric](18, 0) NOT NULL,
	[AgentKey] [nvarchar](50) NOT NULL,
	[CSQKey] [nvarchar](50) NOT NULL,
	[Disposition] [char](20) NOT NULL,
	[CallStartDateTime] [datetime2](7) NOT NULL,
	[CallEndDateTime] [datetime2](7) NOT NULL,
	[OriginatorNumber] [nvarchar](30) NOT NULL,
	[DestinationNumber] [nvarchar](30) NOT NULL,
	[CalledNumber] [nvarchar](30) NOT NULL,
	[OrigCalledNumber] [nvarchar](30) NOT NULL,
	[RingNoAnswer] [int] NOT NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
	[EmployeeKey] [int] NULL,
	[OrganisationKey] [int] NULL,
	[Team] [varchar](50) NULL,
	[Agent] [varchar](50) NULL,
	[LoginID] [varchar](50) NULL,
	[SupervisorFlag] [bit] NULL,
	[ApplicationID] [int] NULL,
	[ApplicationName] [varchar](30) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_cisRNA_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_cisRNA_BIRowID] ON [dbo].[cisRNA]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cisRNA_CallTimes]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cisRNA_CallTimes] ON [dbo].[cisRNA]
(
	[CallStartDateTime] ASC,
	[CallEndDateTime] ASC
)
INCLUDE([SessionID],[AgentKey],[CSQKey],[Disposition],[OriginatorNumber],[DestinationNumber],[CalledNumber],[OrigCalledNumber],[RingNoAnswer],[EmployeeKey],[OrganisationKey],[ApplicationName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cisRNA_SessionKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cisRNA_SessionKey] ON [dbo].[cisRNA]
(
	[SessionKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
