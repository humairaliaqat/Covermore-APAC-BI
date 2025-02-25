USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[pnpServiceEventActivity_Duplicated]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[pnpServiceEventActivity_Duplicated](
	[ServiceEventActivitySK] [int] NOT NULL,
	[ServiceEventSK] [int] NULL,
	[ServiceFileSK] [int] NULL,
	[CaseSK] [int] NULL,
	[ItemSK] [int] NULL,
	[FunderSK] [int] NULL,
	[FunderDepartmentSK] [int] NULL,
	[ServiceEventActivityID] [varchar](50) NULL,
	[ServiceEventID] [varchar](50) NULL,
	[ServiceFileID] [varchar](50) NULL,
	[CaseID] [varchar](50) NULL,
	[ItemID] [varchar](50) NULL,
	[FunderID] [varchar](50) NULL,
	[FunderDepartmentID] [varchar](50) NULL,
	[Name] [nvarchar](100) NULL,
	[Quantity] [numeric](10, 2) NULL,
	[UnitOfMeasurementClass] [nvarchar](max) NULL,
	[UnitOfMeasurementIsTime] [varchar](5) NULL,
	[UnitOfMeasurementIsSchedule] [nvarchar](30) NULL,
	[UnitOfMeasurementIsName] [nvarchar](10) NULL,
	[UnitOfMeasurementIsEquivalent] [numeric](10, 2) NULL,
	[Fee] [numeric](10, 2) NULL,
	[Total] [numeric](10, 2) NULL,
	[CreatedDatetime] [datetime2](7) NULL,
	[UpdatedDatetime] [datetime2](7) NULL,
	[CreatedBy] [nvarchar](20) NULL,
	[UpdatedBy] [nvarchar](20) NULL,
	[UseSeqOvr] [varchar](5) NULL,
	[WorkshopRegItemID] [int] NULL,
	[WorkshopSessionLineID] [int] NULL,
	[ServiceEventActivityIDRet] [int] NULL,
	[DeletedDatetime] [datetime2](7) NULL,
	[Invoiced] [tinyint] NULL,
	[Note] [nvarchar](max) NULL,
	[ScheduleStartDate] [date] NULL,
	[ScheduleEndDate] [date] NULL,
	[DebtorCode] [varchar](16) NULL,
	[CompanyCode] [varchar](10) NULL,
	[PostingCode] [varchar](8) NULL,
	[RCTIDate] [datetime] NULL,
	[FinanceDate] [datetime] NULL,
	[FinMonthAC] [varchar](8000) NULL,
	[FinYearAC] [varchar](4) NULL,
	[FinMonthACDate] [datetime] NULL,
	[ScheduleDate] [date] NULL,
	[CostDate] [datetime] NULL,
	[RevenueDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
