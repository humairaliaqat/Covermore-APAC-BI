USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cbAuditPolicy]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cbAuditPolicy](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[AuditUser] [nvarchar](255) NULL,
	[AuditDateTime] [datetime] NULL,
	[AuditDateTimeUTC] [datetime] NULL,
	[AuditAction] [nvarchar](10) NULL,
	[CountryKey] [nvarchar](2) NOT NULL,
	[CaseKey] [nvarchar](20) NOT NULL,
	[TRIPSPolicyKey] [nvarchar](41) NULL,
	[PolicyTransactionKey] [nvarchar](41) NULL,
	[CaseNo] [nvarchar](15) NOT NULL,
	[IsMainPolicy] [bit] NOT NULL,
	[PolicyNo] [nvarchar](25) NULL,
	[IssueDate] [datetime] NULL,
	[ExpiryDate] [datetime] NULL,
	[VerifyDate] [datetime] NULL,
	[VerifiedBy] [nvarchar](10) NULL,
	[ConsultantInitial] [nvarchar](30) NULL,
	[PolicyType] [nvarchar](25) NULL,
	[SingleFamily] [nvarchar](15) NULL,
	[PlanCode] [nvarchar](15) NULL,
	[DepartureDate] [datetime] NULL,
	[InsurerName] [nvarchar](20) NULL,
	[Excess] [int] NULL,
	[ProductCode] [nvarchar](3) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_cbAuditPolicy_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_cbAuditPolicy_BIRowID] ON [dbo].[cbAuditPolicy]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cbAuditPolicy_AuditDateTime]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cbAuditPolicy_AuditDateTime] ON [dbo].[cbAuditPolicy]
(
	[AuditDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cbAuditPolicy_CaseKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cbAuditPolicy_CaseKey] ON [dbo].[cbAuditPolicy]
(
	[CaseKey] ASC,
	[AuditDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
