USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[clmAuditEvent]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clmAuditEvent](
	[CountryKey] [varchar](2) NOT NULL,
	[AuditKey] [varchar](50) NOT NULL,
	[AuditUserName] [nvarchar](150) NULL,
	[AuditDateTime] [datetime] NOT NULL,
	[AuditAction] [char](1) NOT NULL,
	[ClaimKey] [varchar](40) NOT NULL,
	[EventKey] [varchar](40) NOT NULL,
	[EventID] [int] NOT NULL,
	[ClaimNo] [int] NULL,
	[EMCID] [int] NULL,
	[PerilCode] [varchar](3) NULL,
	[PerilDesc] [nvarchar](65) NULL,
	[EventCountryCode] [varchar](3) NULL,
	[EventCountryName] [nvarchar](45) NULL,
	[EventDate] [datetime] NULL,
	[EventDesc] [nvarchar](100) NULL,
	[CreateDate] [datetime] NULL,
	[CreatedBy] [nvarchar](150) NULL,
	[CaseID] [varchar](15) NULL,
	[CatastropheCode] [varchar](3) NULL,
	[CatastropheShortDesc] [nvarchar](20) NULL,
	[CatastropheLongDesc] [nvarchar](60) NULL,
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
	[AuditDateTimeUTC] [datetime] NULL,
	[EventDateTimeUTC] [datetime] NULL,
	[CreateDateTimeUTC] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_clmAuditEvent_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_clmAuditEvent_BIRowID] ON [dbo].[clmAuditEvent]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmAuditEvent_AuditKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmAuditEvent_AuditKey] ON [dbo].[clmAuditEvent]
(
	[AuditKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmAuditEvent_ClaimKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmAuditEvent_ClaimKey] ON [dbo].[clmAuditEvent]
(
	[ClaimKey] ASC
)
INCLUDE([EventKey],[EventCountryCode],[EventDate],[EventDesc],[CaseID],[CatastropheCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmAuditEvent_EventKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmAuditEvent_EventKey] ON [dbo].[clmAuditEvent]
(
	[EventKey] ASC
)
INCLUDE([ClaimKey],[EventCountryCode],[EventCountryName],[EventDate],[EventDesc],[CaseID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
