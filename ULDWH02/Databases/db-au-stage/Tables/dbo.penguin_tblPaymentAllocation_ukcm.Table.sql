USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPaymentAllocation_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPaymentAllocation_ukcm](
	[PaymentAllocationId] [int] NOT NULL,
	[OutletId] [int] NOT NULL,
	[AlphaCode] [varchar](20) NOT NULL,
	[CRMUserId] [int] NOT NULL,
	[AccountingPeriod] [date] NOT NULL,
	[PaymentAmount] [money] NOT NULL,
	[PolicyAmount] [money] NOT NULL,
	[AmountType] [varchar](15) NOT NULL,
	[Comments] [varchar](255) NULL,
	[Status] [varchar](15) NOT NULL,
	[Source] [varchar](50) NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
