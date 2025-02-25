USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL038_bobjSchedule]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_ETL038_bobjSchedule]
as

SET NOCOUNT ON


if object_id('[db-au-cmdwh].dbo.bobjSchedule') is null
begin
	create table [db-au-cmdwh].dbo.bobjSchedule
	(
		[No] [float] NULL,
		[Path] [nvarchar](255) NULL,
		[InstanceTitle] [nvarchar](255) NULL,
		[InstanceType] [nvarchar](255) NULL,
		[Reoccurrence] [nvarchar](255) NULL,
		[StartDate] [datetime] NULL,
		[EndDate] [datetime] NULL,
		[DaysN] [float] NULL,
		[DaysNth] [float] NULL,
		[CalendarDays] [datetime] NULL,
		[ScheduledBy] [nvarchar](255) NULL,
		[EventName] [nvarchar](255) NULL,
		[SuccessfulRun] [nvarchar](255) NULL,
		[FailedRun] [nvarchar](255) NULL,
		[FailedNotification] [nvarchar](255) NULL,
		[DestinationType] [nvarchar](255) NULL,
		[Destination] [nvarchar](255) NULL,
		[CCEmailAddress] [nvarchar](255) NULL,
		[UserId] [nvarchar](255) NULL,
		[Name0] [nvarchar](255) NULL,
		[Default0] [float] NULL,
		[Value0] [nvarchar](255) NULL,
		[Name1] [nvarchar](255) NULL,
		[Default1] [float] NULL,
		[Value1] [nvarchar](255) NULL,
		[Name2] [nvarchar](255) NULL,
		[Default2] [float] NULL,
		[Value2] [nvarchar](255) NULL,
		[Name3] [nvarchar](255) NULL,
		[Default3] [float] NULL,
		[Value3] [nvarchar](255) NULL,
		[Name4] [nvarchar](255) NULL,
		[Default4] [float] NULL,
		[Value4] [nvarchar](255) NULL,
		[Name5] [nvarchar](255) NULL,
		[Default5] [nvarchar](255) NULL,
		[Value5] [nvarchar](255) NULL,
		[Name6] [nvarchar](255) NULL,
		[Default6] [nvarchar](255) NULL,
		[Value6] [nvarchar](255) NULL,
		[Name7] [float] NULL,
		[Default7] [float] NULL,
		[Value7] [nvarchar](255) NULL,
		[Name8] [nvarchar](255) NULL,
		[Default8] [nvarchar](255) NULL,
		[Value8] [nvarchar](255) NULL,
		[Name9] [nvarchar](255) NULL,
		[Default9] [nvarchar](255) NULL,
		[Value9] [nvarchar](255) NULL,
		[InstanceID] [float] NULL
	)
end	
else
	truncate table [db-au-cmdwh].dbo.bobjSchedule


insert [db-au-cmdwh].dbo.bobjSchedule with(tablock)
(
	[No],
	[Path],
	[InstanceTitle],
	[InstanceType],
	[Reoccurrence],
	[StartDate],
	[EndDate],
	[DaysN],
	[DaysNth],
	[CalendarDays],
	[ScheduledBy],
	[EventName],
	[SuccessfulRun],
	[FailedRun],
	[FailedNotification],
	[DestinationType],
	[Destination],
	[CCEmailAddress],
	[UserId],
	[Name0],
	[Default0],
	[Value0],
	[Name1],
	[Default1],
	[Value1],
	[Name2],
	[Default2],
	[Value2],
	[Name3],
	[Default3],
	[Value3],
	[Name4],
	[Default4],
	[Value4],
	[Name5],
	[Default5],
	[Value5],
	[Name6],
	[Default6],
	[Value6],
	[Name7],
	[Default7],
	[Value7],
	[Name8],
	[Default8],
	[Value8],
	[Name9],
	[Default9],
	[Value9],
	[InstanceID]
)
select
	[No],
	[Path],
	[InstanceTitle],
	[InstanceType],
	[Reoccurrence],
	[StartDate],
	[EndDate],
	[DaysN],
	[DaysNth],
	[CalendarDays],
	[ScheduledBy],
	[EventName],
	[SuccessfulRun],
	[FailedRun],
	[FailedNotification],
	[DestinationType],
	[Destination],
	[CCEmailAddress],
	[UserId],
	[Name0],
	[Default0],
	[Value0],
	[Name1],
	[Default1],
	[Value1],
	[Name2],
	[Default2],
	[Value2],
	[Name3],
	[Default3],
	[Value3],
	[Name4],
	[Default4],
	[Value4],
	[Name5],
	[Default5],
	[Value5],
	[Name6],
	[Default6],
	[Value6],
	[Name7],
	[Default7],
	[Value7],
	[Name8],
	[Default8],
	[Value8],
	[Name9],
	[Default9],
	[Value9],
	[InstanceID]
from
	[db-au-stage].dbo.etl_usrBIReportSchedules
where
	[No] is not null	
GO
