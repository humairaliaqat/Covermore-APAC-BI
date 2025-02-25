USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[Task]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[Task](
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
	[SysStartTime] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTime] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	[SystemModstamp] [datetime] NULL,
 CONSTRAINT [PK_STG_Task] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [atlas].[Task_Hist])
)
GO
ALTER TABLE [atlas].[Task]  WITH NOCHECK ADD  CONSTRAINT [FK_STG_Task] FOREIGN KEY([WhatId])
REFERENCES [atlas].[Case] ([Id])
GO
ALTER TABLE [atlas].[Task] NOCHECK CONSTRAINT [FK_STG_Task]
GO
