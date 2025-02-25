USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Benestar_SessionsPayment]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Benestar_SessionsPayment](
	[BatchID] [smallint] NULL,
	[InvoiceID] [int] NULL,
	[LineNum] [smallint] NULL,
	[PeriodDescription] [datetime] NULL,
	[LineDescription] [varchar](244) NULL,
	[Unit] [varchar](8) NULL,
	[Qty] [real] NULL,
	[Rate] [real] NULL,
	[AmtExGST] [real] NULL,
	[GST] [real] NULL,
	[AmtIncGST] [real] NULL,
	[ResourceCode] [varchar](50) NULL,
	[TimesheetControlID] [varchar](25) NULL,
	[IsPriorPeriodAdjustment] [smallint] NULL,
	[CPFNotCompleted] [smallint] NULL,
	[AccountCodeSegment1] [varchar](50) NULL,
	[AccountCodeSegment2] [varchar](50) NULL,
	[AccountCodeSegment3] [varchar](50) NULL,
	[AccountReferenceCode] [varchar](18) NULL,
	[TaxCode] [varchar](8) NULL,
	[CompanyCode] [varchar](5) NULL,
	[CompanyID] [smallint] NULL,
	[OverSessionLimitFlag] [smallint] NULL,
	[OldTimesheetEntryFlag] [smallint] NULL,
	[VoidDontReissue] [smallint] NULL,
	[PayrollCategory] [varchar](4) NULL
) ON [PRIMARY]
GO
