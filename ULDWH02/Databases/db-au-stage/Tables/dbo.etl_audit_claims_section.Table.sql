USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_audit_claims_section]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_audit_claims_section](
	[CountryKey] [varchar](2) NULL,
	[AuditKey] [varchar](8000) NULL,
	[ClaimKey] [varchar](33) NULL,
	[SectionKey] [varchar](95) NULL,
	[EventKey] [varchar](64) NULL,
	[AuditUserName] [varchar](255) NULL,
	[AuditDateTime] [datetime] NULL,
	[AuditDateTimeUTC] [datetime] NULL,
	[AuditAction] [varchar](10) NULL,
	[SectionID] [int] NULL,
	[ClaimNo] [int] NULL,
	[EventID] [int] NULL,
	[SectionCode] [varchar](25) NULL,
	[EstimateValue] [money] NULL,
	[Redundant] [bit] NOT NULL,
	[BenefitSectionKey] [varchar](33) NULL,
	[BenefitSectionID] [int] NULL,
	[BenefitSubSectionID] [int] NULL,
	[BenefitLimit] [nvarchar](200) NULL,
	[SectionDescription] [nvarchar](200) NULL,
	[RecoveryEstimateValue] [money] NULL
) ON [PRIMARY]
GO
