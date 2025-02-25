USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_audit_claims_event]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_audit_claims_event](
	[CountryKey] [varchar](2) NULL,
	[AuditKey] [varchar](8000) NULL,
	[ClaimKey] [varchar](33) NULL,
	[EventKey] [varchar](64) NULL,
	[AuditUserName] [varchar](255) NULL,
	[AuditDateTime] [datetime] NULL,
	[EventDate] [datetime] NULL,
	[CreateDate] [datetime] NULL,
	[AuditDateTimeUTC] [datetime] NULL,
	[EventDateTimeUTC] [datetime] NULL,
	[CreateDateTimeUTC] [datetime] NULL,
	[AuditAction] [varchar](10) NULL,
	[EventID] [int] NULL,
	[ClaimNo] [int] NULL,
	[EMCID] [int] NULL,
	[PerilCode] [varchar](3) NULL,
	[PerilDesc] [varchar](65) NULL,
	[EventCountryCode] [varchar](3) NULL,
	[EventCountryName] [varchar](200) NULL,
	[EventDesc] [nvarchar](100) NULL,
	[CreatedBy] [varchar](30) NULL,
	[CaseID] [varchar](15) NULL,
	[CatastropheCode] [varchar](3) NULL,
	[CatastropheShortDesc] [varchar](20) NULL,
	[CatastropheLongDesc] [nvarchar](60) NULL
) ON [PRIMARY]
GO
