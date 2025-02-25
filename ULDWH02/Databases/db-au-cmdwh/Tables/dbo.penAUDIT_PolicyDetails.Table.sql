USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penAUDIT_PolicyDetails]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penAUDIT_PolicyDetails](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[AuditPolicyDetailsKey] [varchar](41) NULL,
	[AUDIT_USERNAME] [varchar](255) NULL,
	[AUDIT_RECORDTYPE] [varchar](255) NULL,
	[AUDIT_DATETIME] [datetime] NULL,
	[AUDIT_DATETIME_UTC] [datetime] NULL,
	[ID] [int] NOT NULL,
	[AUDIT_tblPolicyDetails_ID] [int] NOT NULL,
	[PolicyID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[UniquePlanID] [int] NOT NULL,
	[Excess] [money] NOT NULL,
	[AreaName] [nvarchar](100) NULL,
	[PolicyStart] [datetime] NOT NULL,
	[PolicyEnd] [datetime] NOT NULL,
	[DaysCovered] [int] NULL,
	[MaxDuration] [int] NULL,
	[PlanName] [nvarchar](50) NULL,
	[PlanType] [nvarchar](50) NULL,
	[PlanID] [int] NULL,
	[TripDuration] [int] NULL,
	[EmailConsent] [bit] NULL,
	[ShowDiscount] [bit] NULL,
	[AreaCode] [nvarchar](3) NULL,
	[IsUnbundled] [bit] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penAudit_PolicyDetails_AuditPolicyDetailsKey]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_penAudit_PolicyDetails_AuditPolicyDetailsKey] ON [dbo].[penAUDIT_PolicyDetails]
(
	[AuditPolicyDetailsKey] ASC,
	[AUDIT_DATETIME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
