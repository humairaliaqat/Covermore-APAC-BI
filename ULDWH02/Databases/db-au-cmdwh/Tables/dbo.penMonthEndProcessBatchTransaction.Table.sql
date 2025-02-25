USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penMonthEndProcessBatchTransaction]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penMonthEndProcessBatchTransaction](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[DomainKey] [varchar](41) NOT NULL,
	[BatchKey] [varchar](41) NOT NULL,
	[BatchTransactionKey] [varchar](41) NOT NULL,
	[PaymentAllocationKey] [varchar](41) NULL,
	[OutletKey] [varchar](41) NOT NULL,
	[BatchID] [int] NULL,
	[BatchTransactionID] [int] NULL,
	[PaymentAllocationID] [int] NULL,
	[AlphaCode] [varchar](20) NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[Amount] [money] NULL,
	[AllocationAmount] [money] NULL,
	[AmountType] [varchar](15) NULL,
	[Email] [varchar](255) NULL,
	[IsProcessed] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penMonthEndProcessBatchTransaction_BatchTransactionID]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penMonthEndProcessBatchTransaction_BatchTransactionID] ON [dbo].[penMonthEndProcessBatchTransaction]
(
	[BatchTransactionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penMonthEndProcessBatchTransaction_CreateDateTime]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penMonthEndProcessBatchTransaction_CreateDateTime] ON [dbo].[penMonthEndProcessBatchTransaction]
(
	[CreateDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
