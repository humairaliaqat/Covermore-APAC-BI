USE [db-au-stage]
GO
/****** Object:  Table [dbo].[PenelopeDataMart_RCTI_Lines_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PenelopeDataMart_RCTI_Lines_audtc](
	[BatchID] [int] NOT NULL,
	[InvoiceID] [int] NOT NULL,
	[LineNum] [int] NOT NULL,
	[PeriodDescription] [varchar](10) NULL,
	[LineDescription] [varchar](400) NULL,
	[Unit] [varchar](10) NULL,
	[Qty] [money] NULL,
	[Rate] [money] NULL,
	[AmtExGST] [money] NULL,
	[GST] [money] NULL,
	[AmtIncGST] [money] NULL,
	[ResourceCode] [varchar](10) NULL,
	[TimesheetControlID] [varchar](50) NOT NULL,
	[IsPriorPeriodAdjustment] [bit] NULL,
	[CPFNotCompleted] [bit] NULL,
	[AccountCodeSegment1] [varchar](32) NULL,
	[AccountCodeSegment2] [varchar](32) NULL,
	[AccountCodeSegment3] [varchar](32) NULL,
	[AccountReferenceCode] [varchar](32) NULL,
	[TaxCode] [varchar](20) NULL,
	[CompanyCode] [varchar](8) NULL,
	[CompanyID] [smallint] NULL,
	[OverSessionLimitFlag] [int] NULL,
	[OldTimesheetEntryFlag] [int] NULL,
	[VoidDontReissue] [bit] NULL,
	[PayrollCategory] [varchar](50) NULL
) ON [PRIMARY]
GO
