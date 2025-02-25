USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penMonthEndProcessBatch]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penMonthEndProcessBatch](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[BatchKey] [varchar](41) NULL,
	[CRMUserKey] [varchar](41) NULL,
	[DomainID] [int] NOT NULL,
	[BatchID] [int] NOT NULL,
	[CRMUserID] [int] NOT NULL,
	[PaymentTypeID] [int] NOT NULL,
	[AgentID] [tinyint] NOT NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[AccountingPeriod] [date] NOT NULL,
	[BatchStatus] [varchar](15) NOT NULL,
	[PaymentType] [varchar](55) NULL,
	[PaymentProcessAgent] [varchar](55) NULL,
	[JobType] [varchar](15) NOT NULL
) ON [PRIMARY]
GO
