USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[Task_Hist]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[Task_Hist](
	[Id] [varchar](25) NOT NULL,
	[IsDeleted] [bit] NULL,
	[Currency_ISOCode] [varchar](10) NULL,
	[CreatedById] [varchar](20) NULL,
	[CreatedDate] [datetime] NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastModifiedById] [varchar](20) NULL,
	[LastReferencedDate] [datetime] NULL,
	[LastViewedDate] [datetime] NULL,
	[AccountId] [varchar](50) NULL,
	[WhatId] [varchar](25) NULL,
	[WhoId] [varchar](50) NULL,
	[OwnerId] [varchar](50) NULL,
	[DueDateTime_c] [datetime] NULL,
	[CompletedDateTime_c] [datetime] NULL,
	[DaysOpen_c] [numeric](18, 0) NULL,
	[DaystoService_c] [numeric](18, 0) NULL,
	[Description] [varchar](8000) NULL,
	[Subject] [nvarchar](255) NULL,
	[Type] [nvarchar](255) NULL,
	[Status] [nvarchar](255) NULL,
	[TaskSubtype] [nvarchar](255) NULL,
	[IsClosed] [bit] NULL,
	[HandoverReason_c] [varchar](255) NULL,
	[NordicShortName_c] [varchar](255) NULL,
	[NordicTaskId_c] [varchar](20) NULL,
	[NumberofDaysOverdue_c] [numeric](18, 0) NULL,
	[Outcome_c] [nvarchar](50) NULL,
	[OverdueTask_c] [varchar](255) NULL,
	[Priority] [nvarchar](50) NULL,
	[QAReview_c] [bit] NULL,
	[TaskAge_c] [numeric](18, 0) NULL,
	[TimeDue_c] [varchar](90) NULL,
	[CallType] [nvarchar](50) NULL,
	[SysStartTime] [datetime2](7) NOT NULL,
	[SysEndTime] [datetime2](7) NOT NULL,
	[SystemModstamp] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_Task_Hist]    Script Date: 21/02/2025 11:28:24 AM ******/
CREATE CLUSTERED INDEX [ix_Task_Hist] ON [atlas].[Task_Hist]
(
	[SysEndTime] ASC,
	[SysStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
