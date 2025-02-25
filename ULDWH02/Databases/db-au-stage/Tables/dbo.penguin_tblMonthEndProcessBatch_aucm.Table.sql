USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblMonthEndProcessBatch_aucm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblMonthEndProcessBatch_aucm](
	[MonthEndProcessBatchId] [int] NOT NULL,
	[MonthEndProcessMasterId] [int] NULL,
	[CRMUserId] [int] NOT NULL,
	[Status] [varchar](15) NOT NULL,
	[AccountingPeriod] [date] NOT NULL,
	[PaymentTypeId] [int] NOT NULL,
	[PaymentProcessAgentId] [tinyint] NOT NULL,
	[JobType] [varchar](15) NOT NULL,
	[DomainId] [int] NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
