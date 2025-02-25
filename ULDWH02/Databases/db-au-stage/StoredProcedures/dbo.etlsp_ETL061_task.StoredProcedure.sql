USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL061_task]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_ETL061_task]
as

SET NOCOUNT ON


/************************************************************************************************************************************
Author:         Linus Tor
Date:           20160209
Prerequisite:   N/A
Description:    transform salesforce task dimension
Parameters:		
				
Change History:
                20160209 - LT - Procedure created

*************************************************************************************************************************************/


if object_id('[db-au-stage].dbo.etl_sfTask') is not null drop table [db-au-stage].dbo.etl_sfTask
select
	t.ID as TaskID,
	t.AccountID,
	t.ActivityDate,
	t.CallDisposition,
	t.CallDurationInSeconds,
	t.CallObject,
	t.CallType,
	cr.CreatedBy,
	t.CreatedDate,
	t.[Description],
	t.isArchived,
	t.isClosed,
	t.isDeleted,
	t.isRecurrence,
	t.isReminderSet,
	lm.LastModifiedBy,
	t.LastModifiedDate,
	o.[Owner],
	t.[Priority],
	t.RecurrenceActivityId,
	t.RecurrenceDayOfMonth,
	t.RecurrenceDayOfWeekMask,
	t.RecurrenceEndDateOnly,
	t.RecurrenceInstance,
	t.RecurrenceInterval,
	t.RecurrenceMonthOfYear,
	t.RecurrenceRegeneratedType,
	t.RecurrenceStartDateOnly,
	t.RecurrenceTimeZoneSidKey,
	t.RecurrenceType,
	t.ReminderDateTime,
	t.[Status],
	t.[Subject],
	t.SystemModStamp,
	t.WhatID,
	t.WhoID
into [db-au-stage].dbo.etl_sfTask
from
	sforce_task t
	outer apply
	(
		select top 1 Name as CreatedBy
		from sforce_user
		where ID = t.CreatedByID
	) cr
	outer apply
	(
		select top 1 Name as LastModifiedBy
		from sforce_user
		where ID = t.LastModifiedByID
	) lm
	outer apply
	(
		select top 1 Name as [Owner]
		from sforce_user
		where ID = t.[OwnerID]
	) o



if object_id('[db-au-cmdwh].dbo.sfTask') is null
begin
	create table [db-au-cmdwh].dbo.sfTask
	(
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
	) 
       create clustered index idx_sfTask_TaskID on [db-au-cmdwh].dbo.sfTask(TaskID)
	   create nonclustered index idx_sfTask_AccountID on [db-au-cmdwh].dbo.sfTask(AccountID)
	   create nonclustered index idx_sfTask_ActivityDate on [db-au-cmdwh].dbo.sfTask(ActivityDate)
       create nonclustered index idx_sfTask_Owner on [db-au-cmdwh].dbo.sfTask([Owner])
end
else
	delete a
	from [db-au-cmdwh].dbo.sfTask a
		inner join [db-au-stage].dbo.etl_sfTask b on
			a.TaskID = b.TaskID


insert [db-au-cmdwh].dbo.sfTask with (tablockx)
(
	[TaskID],
	[AccountID],
	[ActivityDate],
	[CallDisposition],
	[CallDurationInSeconds],
	[CallObject],
	[CallType],
	[CreatedBy],
	[CreatedDate],
	[Description],
	[isArchived],
	[isClosed],
	[isDeleted],
	[isRecurrence],
	[isReminderSet],
	[LastModifiedBy],
	[LastModifiedDate],
	[Owner],
	[Priority],
	[RecurrenceActivityId],
	[RecurrenceDayOfMonth],
	[RecurrenceDayOfWeekMask],
	[RecurrenceEndDateOnly],
	[RecurrenceInstance],
	[RecurrenceInterval],
	[RecurrenceMonthOfYear],
	[RecurrenceRegeneratedType],
	[RecurrenceStartDateOnly],
	[RecurrenceTimeZoneSidKey],
	[RecurrenceType],
	[ReminderDateTime],
	[Status],
	[Subject],
	[SystemModStamp],
	[WhatID],
	[WhoID]
)
select
	[TaskID],
	[AccountID],
	[ActivityDate],
	[CallDisposition],
	[CallDurationInSeconds],
	[CallObject],
	[CallType],
	[CreatedBy],
	[CreatedDate],
	[Description],
	[isArchived],
	[isClosed],
	[isDeleted],
	[isRecurrence],
	[isReminderSet],
	[LastModifiedBy],
	[LastModifiedDate],
	[Owner],
	[Priority],
	[RecurrenceActivityId],
	[RecurrenceDayOfMonth],
	[RecurrenceDayOfWeekMask],
	[RecurrenceEndDateOnly],
	[RecurrenceInstance],
	[RecurrenceInterval],
	[RecurrenceMonthOfYear],
	[RecurrenceRegeneratedType],
	[RecurrenceStartDateOnly],
	[RecurrenceTimeZoneSidKey],
	[RecurrenceType],
	[ReminderDateTime],
	[Status],
	[Subject],
	[SystemModStamp],
	[WhatID],
	[WhoID]
from
	[db-au-stage].dbo.etl_sfTask
GO
