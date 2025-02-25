USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_sfTask]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_sfTask](
	[TaskID] [nvarchar](18) NULL,
	[AccountID] [nvarchar](18) NULL,
	[ActivityDate] [date] NULL,
	[CallDisposition] [nvarchar](255) NULL,
	[CallDurationInSeconds] [int] NULL,
	[CallObject] [nvarchar](255) NULL,
	[CallType] [nvarchar](40) NULL,
	[CreatedBy] [nvarchar](121) NULL,
	[CreatedDate] [datetime] NULL,
	[Description] [nvarchar](max) NULL,
	[isArchived] [bit] NULL,
	[isClosed] [bit] NULL,
	[isDeleted] [bit] NULL,
	[isRecurrence] [bit] NULL,
	[isReminderSet] [bit] NULL,
	[LastModifiedBy] [nvarchar](121) NULL,
	[LastModifiedDate] [datetime] NULL,
	[Owner] [nvarchar](121) NULL,
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
	[SystemModStamp] [datetime] NULL,
	[WhatID] [nvarchar](18) NULL,
	[WhoID] [nvarchar](18) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
