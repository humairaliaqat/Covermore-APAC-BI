USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penPolicyTransactionAllocation_deleted_records_dated20191223]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPolicyTransactionAllocation_deleted_records_dated20191223](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[PolicyAllocationKey] [varchar](41) NULL,
	[PaymentAllocationKey] [varchar](41) NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[PolicyAllocationID] [int] NULL,
	[PaymentAllocationID] [int] NULL,
	[PolicyTransactionID] [int] NULL,
	[PolicyNumber] [varchar](50) NULL,
	[Amount] [money] NULL,
	[AllocationAmount] [money] NULL,
	[AmountType] [varchar](15) NULL,
	[Comments] [varchar](255) NULL,
	[Status] [varchar](15) NULL
) ON [PRIMARY]
GO
