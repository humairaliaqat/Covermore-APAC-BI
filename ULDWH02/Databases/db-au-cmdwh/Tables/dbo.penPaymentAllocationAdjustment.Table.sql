USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penPaymentAllocationAdjustment]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPaymentAllocationAdjustment](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[PaymentAllocationAdjustmentKey] [varchar](41) NULL,
	[PaymentAllocationKey] [varchar](41) NULL,
	[PaymentAllocationAdjustmentID] [int] NOT NULL,
	[PaymentAllocationID] [int] NOT NULL,
	[Amount] [money] NULL,
	[AdjustmentType] [varchar](30) NULL,
	[Comments] [varchar](255) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPaymentAllocationAdjustment_PaymentAllocationKey]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penPaymentAllocationAdjustment_PaymentAllocationKey] ON [dbo].[penPaymentAllocationAdjustment]
(
	[PaymentAllocationAdjustmentKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPaymentAllocationAdjustment_OutletKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPaymentAllocationAdjustment_OutletKey] ON [dbo].[penPaymentAllocationAdjustment]
(
	[PaymentAllocationKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPaymentAllocationAdjustment_PaymentAllocationAdjustmentKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPaymentAllocationAdjustment_PaymentAllocationAdjustmentKey] ON [dbo].[penPaymentAllocationAdjustment]
(
	[PaymentAllocationAdjustmentKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
