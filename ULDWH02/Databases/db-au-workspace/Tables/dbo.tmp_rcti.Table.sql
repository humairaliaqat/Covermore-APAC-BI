USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_rcti]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_rcti](
	[TimesheetControlID] [varchar](30) NULL,
	[ResourceCode] [varchar](10) NULL,
	[TimesheetPeriod] [varchar](20) NULL,
	[RateDescription] [varchar](100) NULL,
	[TranDate] [datetime] NULL,
	[NormalHours] [numeric](17, 6) NULL,
	[AfterHours] [numeric](17, 6) NULL,
	[Qty] [numeric](19, 6) NULL,
	[CustomerCode] [int] NULL,
	[ContractNo] [int] NULL,
	[JobNo] [varchar](20) NULL,
	[ServiceType] [nvarchar](160) NULL,
	[ActivityCode] [nvarchar](51) NULL,
	[ApprovedBy] [varchar](8) NOT NULL,
	[ApprovedDate] [int] NULL,
	[RateType] [varchar](20) NULL,
	[NormalRate] [money] NULL,
	[AfterHoursRate] [money] NULL,
	[AmountExGST] [numeric](38, 10) NULL,
	[InvoiceID] [int] NULL,
	[IsPriorPeriodAdjustment] [int] NOT NULL,
	[LineDesc] [nvarchar](125) NULL,
	[AdjustmentToInvoiceID] [int] NULL,
	[CPFNotCompleted] [int] NOT NULL,
	[AccountCodeSegment1] [varchar](10) NULL,
	[AccountCodeSegment2] [varchar](10) NULL,
	[AccountCodeSegment3] [varchar](16) NULL,
	[AccountReferenceCode] [varchar](68) NULL,
	[DocCtrlNum] [int] NULL,
	[ProjectID] [int] NULL,
	[DoNotAttendRebooked] [bit] NOT NULL,
	[OnholdReason] [varchar](100) NULL,
	[CompanyCode] [varchar](6) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[ReplacedJobNo] [int] NULL,
	[IsDailyRate] [int] NOT NULL,
	[RateZeroedByDailyRate] [int] NOT NULL,
	[IsCPFApproved] [int] NOT NULL,
	[OverSessionLimitFlag] [int] NOT NULL,
	[OldTimesheetEntryFlag] [int] NOT NULL,
	[NoAssociatedBooking] [int] NOT NULL,
	[CPFPaidOnFutureInvoice] [int] NULL,
	[RateID] [int] NULL,
	[PayOnDailyRate] [bit] NULL,
	[PayrollCategory] [varchar](50) NULL,
	[ServiceID] [int] NULL,
	[ServiceFileID] [int] NULL,
	[PolicyID] [int] NULL,
	[ServiceEventID] [int] NULL,
	[ServiceEventActivityID] [int] NULL,
	[SiteID] [int] NULL,
	[Paid] [bit] NOT NULL,
	[UserId] [int] NULL,
	[Removed] [bit] NOT NULL,
	[DuplicatedCartItem] [bit] NOT NULL,
	[ReversedPayment] [bit] NOT NULL,
	[OverAllowedHours] [bit] NOT NULL,
	[Payable] [bit] NOT NULL,
	[PenelopeCompositeKey] [varchar](30) NULL,
	[Category] [nvarchar](50) NULL,
	[ActivityDesc] [nvarchar](80) NULL,
	[Onhold] [bit] NOT NULL,
	[TimesheetControlID_Star] [varchar](40) NULL,
	[SourceSystem] [varchar](8) NOT NULL,
	[NewUserId] [varchar](6) NULL,
	[Status] [varchar](30) NULL,
	[department_code] [varchar](10) NULL,
	[WorkerToPay] [int] NULL,
	[WorkerPaid] [int] NULL,
	[ServiceName] [nvarchar](160) NULL,
	[ServiceEventActivityIDStr] [varchar](150) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE CLUSTERED INDEX [cidx] ON [dbo].[tmp_rcti]
(
	[ServiceEventActivityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[tmp_rcti]
(
	[ServiceEventActivityIDStr] ASC
)
INCLUDE([Paid],[Removed],[NormalHours],[NormalRate],[AfterHours],[AfterHoursRate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
