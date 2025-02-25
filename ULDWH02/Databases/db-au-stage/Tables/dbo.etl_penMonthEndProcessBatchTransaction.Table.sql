USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penMonthEndProcessBatchTransaction]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penMonthEndProcessBatchTransaction](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[BatchKey] [varchar](41) NULL,
	[BatchTransactionKey] [varchar](41) NULL,
	[PaymentAllocationKey] [varchar](41) NULL,
	[OutletKey] [varchar](41) NULL,
	[BatchID] [int] NOT NULL,
	[BatchTransactionID] [int] NOT NULL,
	[PaymentAllocationID] [int] NULL,
	[AlphaCode] [varchar](20) NOT NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[Amount] [money] NOT NULL,
	[AllocationAmount] [money] NOT NULL,
	[AmountType] [varchar](15) NOT NULL,
	[Email] [varchar](255) NULL,
	[IsProcessed] [bit] NOT NULL
) ON [PRIMARY]
GO
