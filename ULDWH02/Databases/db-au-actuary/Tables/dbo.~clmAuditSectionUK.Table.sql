USE [db-au-actuary]
GO
/****** Object:  Table [dbo].[~clmAuditSectionUK]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[~clmAuditSectionUK](
	[CountryKey] [varchar](2) NOT NULL,
	[AuditKey] [varchar](50) NOT NULL,
	[ClaimKey] [varchar](40) NOT NULL,
	[SectionKey] [varchar](40) NOT NULL,
	[EventKey] [varchar](40) NOT NULL,
	[AuditUserName] [nvarchar](150) NULL,
	[AuditDateTime] [datetime] NOT NULL,
	[AuditAction] [char](1) NOT NULL,
	[SectionID] [int] NOT NULL,
	[ClaimNo] [int] NULL,
	[EventID] [int] NULL,
	[SectionCode] [varchar](25) NULL,
	[EstimateValue] [money] NULL,
	[Redundant] [bit] NOT NULL,
	[BenefitSectionKey] [varchar](40) NULL,
	[BenefitSectionID] [int] NULL,
	[BenefitSubSectionID] [int] NULL,
	[SectionDescription] [nvarchar](200) NULL,
	[BenefitLimit] [nvarchar](200) NULL,
	[RecoveryEstimateValue] [money] NULL,
	[BIRowID] [int] NOT NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
	[AuditDateTimeUTC] [datetime] NULL
) ON [PRIMARY]
GO
