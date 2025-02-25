USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[clmAuditClaim]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clmAuditClaim](
	[CountryKey] [varchar](2) NOT NULL,
	[AuditKey] [varchar](50) NOT NULL,
	[ClaimKey] [varchar](40) NOT NULL,
	[AuditUserName] [nvarchar](150) NULL,
	[AuditDateTime] [datetime] NOT NULL,
	[AuditAction] [char](1) NOT NULL,
	[ClaimNo] [int] NOT NULL,
	[CreatedBy] [varchar](30) NULL,
	[CreateDate] [datetime] NULL,
	[OfficerName] [nvarchar](150) NULL,
	[StatusCode] [varchar](4) NULL,
	[StatusDesc] [varchar](50) NULL,
	[ReceivedDate] [datetime] NULL,
	[Authorisation] [varchar](1) NULL,
	[ActionDate] [datetime] NULL,
	[ActionCode] [int] NULL,
	[FinalisedDate] [datetime] NULL,
	[ArchiveBox] [varchar](20) NULL,
	[PolicyID] [int] NULL,
	[PolicyNo] [varchar](50) NULL,
	[PolicyProduct] [varchar](4) NULL,
	[AgencyCode] [varchar](7) NULL,
	[PolicyPlanCode] [varchar](50) NULL,
	[IntDom] [varchar](3) NULL,
	[Excess] [money] NULL,
	[SingleFamily] [varchar](1) NULL,
	[PolicyIssuedDate] [datetime] NULL,
	[AccountingDate] [datetime] NULL,
	[DepartureDate] [datetime] NULL,
	[ArrivalDate] [datetime] NULL,
	[NumberOfDays] [int] NULL,
	[ITCPremium] [float] NULL,
	[EMCApprovalNo] [varchar](15) NULL,
	[GroupPolicy] [tinyint] NULL,
	[LuggageFlag] [tinyint] NULL,
	[HRisk] [tinyint] NULL,
	[CaseNo] [varchar](14) NULL,
	[Comment] [ntext] NULL,
	[ClaimProduct] [varchar](5) NULL,
	[ClaimPlan] [varchar](50) NULL,
	[RecoveryType] [tinyint] NULL,
	[RecoveryTypeDesc] [varchar](255) NULL,
	[RecoveryOutcome] [tinyint] NULL,
	[RecoveryOutcomeDesc] [varchar](255) NULL,
	[CultureCode] [nvarchar](10) NULL,
	[DomainID] [int] NULL,
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
	[AuditDateTimeUTC] [datetime] NULL,
	[CreateDateTimeUTC] [datetime] NULL,
	[ReceivedDateTimeUTC] [datetime] NULL,
	[ActionDateTimeUTC] [datetime] NULL,
	[FinalisedDateTimeUTC] [datetime] NULL,
	[PolicyOffline] [bit] NULL,
	[MasterPolicyNumber] [varchar](20) NULL,
	[GroupName] [nvarchar](200) NULL,
	[AgencyName] [nvarchar](200) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_clmAuditClaim_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_clmAuditClaim_BIRowID] ON [dbo].[clmAuditClaim]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_clmAuditClaim_AuditDateTime]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmAuditClaim_AuditDateTime] ON [dbo].[clmAuditClaim]
(
	[AuditDateTime] ASC
)
INCLUDE([ClaimKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmAuditClaim_AuditKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmAuditClaim_AuditKey] ON [dbo].[clmAuditClaim]
(
	[AuditKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmAuditClaim_ClaimKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmAuditClaim_ClaimKey] ON [dbo].[clmAuditClaim]
(
	[ClaimKey] ASC
)
INCLUDE([AuditDateTime],[ClaimNo],[StatusDesc]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmAuditClaim_ClaimPointInTime]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmAuditClaim_ClaimPointInTime] ON [dbo].[clmAuditClaim]
(
	[ClaimKey] ASC,
	[AuditDateTime] DESC
)
INCLUDE([StatusCode],[StatusDesc]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
