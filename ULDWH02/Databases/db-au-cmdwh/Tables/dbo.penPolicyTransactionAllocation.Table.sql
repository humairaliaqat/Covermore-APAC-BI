USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penPolicyTransactionAllocation]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPolicyTransactionAllocation](
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
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyTransactionAllocation_PolicyAllocationKey]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penPolicyTransactionAllocation_PolicyAllocationKey] ON [dbo].[penPolicyTransactionAllocation]
(
	[PolicyAllocationKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyTransactionAllocation_PolicyTransactionKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyTransactionAllocation_PolicyTransactionKey] ON [dbo].[penPolicyTransactionAllocation]
(
	[PolicyTransactionKey] ASC
)
INCLUDE([PaymentAllocationKey],[AllocationAmount],[Status]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
