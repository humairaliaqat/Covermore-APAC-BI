USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penPaymentAllocation]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPaymentAllocation](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[PaymentAllocationKey] [varchar](41) NULL,
	[OutletKey] [varchar](41) NULL,
	[CRMUserKey] [varchar](41) NULL,
	[PaymentAllocationID] [int] NOT NULL,
	[OutletID] [int] NULL,
	[AlphaCode] [varchar](20) NULL,
	[AccountingPeriod] [datetime] NULL,
	[AccountingPeriodUTC] [date] NULL,
	[PaymentAmount] [money] NULL,
	[AmountType] [varchar](30) NULL,
	[Comments] [varchar](255) NULL,
	[Status] [varchar](15) NULL,
	[Source] [varchar](50) NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[CreateDateTimeUTC] [datetime] NULL,
	[UpdateDateTimeUTC] [datetime] NULL,
	[PolicyAmount] [money] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPaymentAllocation_PaymentAllocationKey]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penPaymentAllocation_PaymentAllocationKey] ON [dbo].[penPaymentAllocation]
(
	[PaymentAllocationKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPaymentAllocation_AllocationKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPaymentAllocation_AllocationKey] ON [dbo].[penPaymentAllocation]
(
	[PaymentAllocationKey] ASC
)
INCLUDE([Status],[CreateDateTime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penPaymentAllocation_CreateDateTime]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPaymentAllocation_CreateDateTime] ON [dbo].[penPaymentAllocation]
(
	[CreateDateTime] ASC
)
INCLUDE([PaymentAllocationKey],[Status]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPaymentAllocation_OutletKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPaymentAllocation_OutletKey] ON [dbo].[penPaymentAllocation]
(
	[OutletKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPaymentAllocation_PaymentAllocationID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPaymentAllocation_PaymentAllocationID] ON [dbo].[penPaymentAllocation]
(
	[PaymentAllocationID] ASC,
	[CountryKey] ASC,
	[CompanyKey] ASC
)
INCLUDE([CreateDateTime],[Status]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
