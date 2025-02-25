USE [db-au-stage]
GO
/****** Object:  Table [dbo].[sforce_task]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sforce_task](
	[AccountId] [nvarchar](18) NULL,
	[ActivityDate] [date] NULL,
	[CallDisposition] [nvarchar](255) NULL,
	[CallDurationInSeconds] [int] NULL,
	[CallObject] [nvarchar](255) NULL,
	[CallType] [nvarchar](40) NULL,
	[CreatedById] [nvarchar](18) NULL,
	[CreatedDate] [datetime] NULL,
	[Description] [nvarchar](max) NULL,
	[Id] [nvarchar](18) NULL,
	[IsArchived] [bit] NULL,
	[IsClosed] [bit] NULL,
	[IsDeleted] [bit] NULL,
	[IsRecurrence] [bit] NULL,
	[IsReminderSet] [bit] NULL,
	[LastModifiedById] [nvarchar](18) NULL,
	[LastModifiedDate] [datetime] NULL,
	[OwnerId] [nvarchar](18) NULL,
	[Priority] [nvarchar](40) NULL,
	[RecurrenceActivityId] [nvarchar](18) NULL,
	[RecurrenceDayOfMonth] [int] NULL,
	[RecurrenceDayOfWeekMask] [int] NULL,
	[RecurrenceEndDateOnly] [date] NULL,
	[RecurrenceInstance] [nvarchar](40) NULL,
	[RecurrenceInterval] [int] NULL,
	[RecurrenceMonthOfYear] [nvarchar](40) NULL,
	[RecurrenceRegeneratedType] [nvarchar](40) NULL,
	[RecurrenceStartDateOnly] [date] NULL,
	[RecurrenceTimeZoneSidKey] [nvarchar](40) NULL,
	[RecurrenceType] [nvarchar](40) NULL,
	[ReminderDateTime] [datetime] NULL,
	[Status] [nvarchar](40) NULL,
	[Subject] [nvarchar](255) NULL,
	[SystemModstamp] [datetime] NULL,
	[WhatId] [nvarchar](18) NULL,
	[WhoId] [nvarchar](18) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
