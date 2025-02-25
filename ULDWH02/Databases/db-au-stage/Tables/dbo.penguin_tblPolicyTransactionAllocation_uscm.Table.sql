USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPolicyTransactionAllocation_uscm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPolicyTransactionAllocation_uscm](
	[PolicyAllocationId] [int] NOT NULL,
	[PaymentAllocationId] [int] NOT NULL,
	[PolicyTransactionId] [int] NOT NULL,
	[TripsPolicyNumber] [varchar](25) NULL,
	[Amount] [money] NOT NULL,
	[AllocationAmount] [money] NOT NULL,
	[AmountType] [varchar](15) NOT NULL,
	[Transferred] [bit] NOT NULL,
	[Comments] [varchar](255) NULL,
	[Status] [varchar](15) NOT NULL
) ON [PRIMARY]
GO
