USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_MonthEndBatchProcessData]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_MonthEndBatchProcessData](
	[SuperGroupName] [nvarchar](255) NULL,
	[GroupName] [nvarchar](50) NULL,
	[SubGroupName] [nvarchar](50) NULL,
	[AlphaCode] [nvarchar](20) NULL,
	[OutletName] [nvarchar](50) NULL,
	[AccountName] [nvarchar](100) NULL,
	[BSB] [nvarchar](50) NULL,
	[OutletBankAccountNumber] [varchar](255) NULL,
	[OutletPaymentType] [nvarchar](50) NULL,
	[BatchProcessID] [int] NULL,
	[AccountingPeriod] [date] NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[BatchStatus] [varchar](15) NULL,
	[JobType] [varchar](15) NULL,
	[PaymentProcessAgent] [varchar](55) NULL,
	[BatchProcessedBy] [nvarchar](101) NULL,
	[BatchProcessTransactionID] [int] NULL,
	[PaymentAllocationID] [int] NULL,
	[Amount] [money] NULL,
	[AllocationAmount] [money] NULL,
	[AmountType] [varchar](15) NULL,
	[Email] [varchar](255) NULL,
	[IsProcessed] [bit] NULL
) ON [PRIMARY]
GO
