USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblMonthEndProcessBatchTransaction_autp]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblMonthEndProcessBatchTransaction_autp](
	[MonthEndProcessBatchTransactionId] [int] NOT NULL,
	[MonthEndProcessBatchId] [int] NOT NULL,
	[PaymentAllocationId] [int] NULL,
	[Amount] [money] NOT NULL,
	[AllocationAmount] [money] NOT NULL,
	[AmountType] [varchar](15) NOT NULL,
	[OutletId] [int] NOT NULL,
	[AlphaCode] [varchar](20) NOT NULL,
	[Email] [varchar](255) NULL,
	[IsProcessed] [bit] NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
