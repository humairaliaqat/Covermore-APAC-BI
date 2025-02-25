USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cbPlan_BKP20190122_deleted_records]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cbPlan_BKP20190122_deleted_records](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [nvarchar](2) NOT NULL,
	[CaseKey] [nvarchar](20) NOT NULL,
	[PlanKey] [nvarchar](20) NOT NULL,
	[OriginalPlanKey] [nvarchar](20) NULL,
	[CaseNo] [nvarchar](15) NOT NULL,
	[PlanID] [int] NOT NULL,
	[PlanVersion] [int] NULL,
	[OriginalPlanID] [nvarchar](20) NULL,
	[OpenedByID] [nvarchar](30) NULL,
	[OpenedBy] [nvarchar](55) NULL,
	[CompletedByID] [nvarchar](30) NULL,
	[CompletedBy] [nvarchar](55) NULL,
	[ActionLevel] [nvarchar](30) NULL,
	[CancelledByID] [nvarchar](30) NULL,
	[CancelledBy] [nvarchar](55) NULL,
	[AllocatedToID] [nvarchar](30) NULL,
	[AllocatedTo] [nvarchar](55) NULL,
	[CreateDate] [datetime] NULL,
	[CreateTimeUTC] [datetime] NULL,
	[TodoDate] [datetime] NULL,
	[TodoTime] [datetime] NULL,
	[TodoTimeUTC] [datetime] NULL,
	[AllocatedDate] [datetime] NULL,
	[AllocatedTimeUTC] [datetime] NULL,
	[CompletionDate] [datetime] NULL,
	[CompletionTime] [datetime] NULL,
	[CompletionTimeUTC] [datetime] NULL,
	[PlanDetail] [nvarchar](255) NULL,
	[AdditionalDetail] [nvarchar](255) NULL,
	[IsPriority] [bit] NULL,
	[RescheduleReason] [nvarchar](120) NULL,
	[IsRescheduled] [bit] NULL,
	[IsCompleted] [bit] NULL,
	[IsCancelled] [bit] NULL
) ON [PRIMARY]
GO
