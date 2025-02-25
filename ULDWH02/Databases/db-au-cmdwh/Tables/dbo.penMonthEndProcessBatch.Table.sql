USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penMonthEndProcessBatch]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penMonthEndProcessBatch](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[DomainKey] [varchar](41) NOT NULL,
	[BatchKey] [varchar](41) NOT NULL,
	[CRMUserKey] [varchar](41) NULL,
	[DomainID] [int] NULL,
	[BatchID] [int] NULL,
	[CRMUserID] [int] NULL,
	[PaymentTypeID] [int] NULL,
	[AgentID] [int] NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[AccountingPeriod] [date] NULL,
	[BatchStatus] [varchar](15) NULL,
	[PaymentType] [varchar](55) NULL,
	[PaymentProcessAgent] [varchar](55) NULL,
	[JobType] [varchar](15) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penMonthEndProcessBatch_BatchID]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penMonthEndProcessBatch_BatchID] ON [dbo].[penMonthEndProcessBatch]
(
	[BatchID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penMonthEndProcessBatch_CreateDateTime]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penMonthEndProcessBatch_CreateDateTime] ON [dbo].[penMonthEndProcessBatch]
(
	[CreateDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
