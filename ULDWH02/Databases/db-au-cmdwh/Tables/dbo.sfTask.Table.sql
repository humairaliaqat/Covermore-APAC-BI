USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[sfTask]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sfTask](
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
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfTask_TaskID]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_sfTask_TaskID] ON [dbo].[sfTask]
(
	[TaskID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfTask_AccountID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfTask_AccountID] ON [dbo].[sfTask]
(
	[AccountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_sfTask_ActivityDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfTask_ActivityDate] ON [dbo].[sfTask]
(
	[ActivityDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfTask_Owner]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfTask_Owner] ON [dbo].[sfTask]
(
	[Owner] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
