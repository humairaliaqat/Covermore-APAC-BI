USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[Tmp_rptsp_rpt0114]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Tmp_rptsp_rpt0114]	@ReportingPeriod varchar(30),
										@StartDate varchar(10),
										@EndDate varchar(10)

as

SET NOCOUNT ON


--uncomment to debug
/*
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @ReportingPeriod = 'Last Month To Yesterday'
select @StartDate = null
select @EndDate = null
*/

declare @rptStartDate smalldatetime
declare @rptEndDate smalldatetime


/* get reporting dates */
if @ReportingPeriod = 'User Defined'
  select @rptStartDate = convert(smalldatetime,@StartDate), @rptEndDate = convert(smalldatetime,@EndDate)
  else if  @ReportingPeriod = 'Last Month To Yesterday'
  begin 
   select @rptStartDate = startdate from dbo.vDateRange where DateRange ='Last Month'
 select @rptEndDate = Enddate from dbo.vDateRange where DateRange ='Yesterday'
 end
else
  select @rptStartDate = StartDate, @rptEndDate = EndDate
  from [db-au-cmdwh].dbo.vDateRange
  where DateRange = @ReportingPeriod

--variables to store cursor fields	 
declare @IDStart int, @IDEnd int, @ID int, @Work_Id uniqueidentifier, @Event_Id bigint, @Reference int, @ClaimNumber nvarchar(100), @WorkType nvarchar(100), @GroupType nvarchar(100)
declare @EventName nvarchar(100), @ReceivedDate datetime, @EventUser nvarchar(100), @EventStatus nvarchar(100),	@Detail nvarchar(200)
declare @TempResponseDate datetime, @ActualResponseDate datetime, @TempTurnAroundTime int, @TempReceivedDate datetime


if object_id('tempdb..#WorkEvents1') is not null drop table #WorkEvents1
select
  w.Id as Work_Id,
  w.Reference,
  wcp.ClaimNumber,
  c2.Name as WorkType,
  c3.Name as GroupType,
  we.Id as Event_Id,
  e.Name as EventName,  
  case when we.Detail = 'Launched' then convert(datetime,convert(varchar(10),w.CreationDate,120))
       else convert(datetime,convert(varchar(10),we.EventDate,120))
  end as ReceivedDate,
  we.EventUser,
  es.Name as EventStatus,
  we.Detail
into #WorkEvents1  
from
  ulsql02.e5_content.dbo.Work w
  join ulsql02.e5_content.dbo.WorkCustomProperty wcp on			--WorkCustomProperty
	w.Id = wcp.Work_Id
  join ulsql02.e5_content.dbo.Category2 c2 on						--Category2
	w.Category2_Id = c2.Id
  join ulsql02.e5_content.dbo.Category3 c3 on						--Category3
	w.Category3_Id = c3.Id
  join ulsql02.e5_content.dbo.[Status] ws on						--Status
	w.Status_Id = ws.Id
  join ulsql02.e5_content.dbo.WorkEvent we on
    w.Id = we.Work_Id
  join ulsql02.e5_content.dbo.[Event] e on
	we.Event_Id = e.Id    
  join ulsql02.e5_content.dbo.[Status] es on
	we.Status_Id = es.Id
where
  convert(varchar(10),we.EventDate,120) between @rptStartDate and @rptEndDate and
  w.Status_Id <> 5 and																-- rejected
  w.Category2_Id not in (1,2) and													--enrolment forms, claims / unclassified  
  we.Event_Id in (100,800)															-- 100 = Changed Work Status, 800 = Merged Work
order by
  w.Reference,
  wcp.ClaimNumber,
  we.Id,
  we.EventDate

--update 'Merged Work' events to find the ReceivedDate of the Originator Work
update #WorkEvents1
set ReceivedDate = convert(varchar(10),b.CreationDate,120)
from #WorkEvents1 a join ulsql02.e5_content.dbo.Work b on 
	replace(replace(Detail,'<a href=javascript:openWork(''GetWork'',''',''),''')>Open Originator Work</a>','') = b.Id
where
	a.EventName = 'Merged Work'


--create table to store final work events
if object_id('tempdb..#Main1') is null 
create table #Main1
(
	Id int identity(1,1) not null,
	Work_Id uniqueidentifier null,
	Reference int null,
	ClaimNumber nvarchar(100) null,
	WorkType nvarchar(100) null,
	GroupType nvarchar(100) null,
	Event_Id bigint null,
	EventName nvarchar(100) null,
	ReceivedDate datetime null,
	EventUser nvarchar(100) null,
	EventStatus nvarchar(100) null,
	Detail nvarchar(200) null,	
	SLAResponseDate datetime null,
	ActualResponseDate datetime null,
	TurnAroundTime int null
)
else truncate table #Main1	


--declare cursor
declare CUR_WorkEvents cursor for select * from #WorkEvents1
open CUR_WorkEvents
fetch NEXT from CUR_WorkEvents into	@Work_Id, @Reference, @ClaimNumber, @WorkType, @GroupType, @Event_Id, @EventName,
									@ReceivedDate, @EventUser, @EventStatus, @Detail
--initialise work events batch.
select @IDStart = 1, @IDEnd = 1

--step through each row in #WorkEvents1 and insert them to #Main1 table or update ActualResponseDate to the date status changed to Diarised or Complete
while @@FETCH_STATUS = 0
begin

  if (@EventName = 'Changed Work Status' and @EventStatus in ('Diarised','Complete'))
  begin
	update #Main1
	set ActualResponseDate = @ReceivedDate
	where ClaimNumber = @ClaimNumber and ID between @IDStart and @IDEnd
	
	select @IDStart = @IDEnd
  end
  else
  begin
    insert #Main1
  	select @Work_Id, @Reference, @ClaimNumber, @WorkType, @GroupType, @Event_Id, @EventName,
		   @ReceivedDate, @EventUser, @EventStatus, @Detail, null, null, null
		   
    select @IDEnd = @IDEnd + 1		   
  end


fetch NEXT from CUR_WorkEvents into	@Work_Id, @Reference, @ClaimNumber, @WorkType, @GroupType, @Event_Id, @EventName,
									@ReceivedDate, @EventUser, @EventStatus, @Detail
end

close CUR_WorkEvents
deallocate CUR_WorkEvents



--declare cursor for updating ActualResponseDate where value is null
declare CUR_Main1 cursor for select Id, Work_Id, Reference, ClaimNumber, WorkType, GroupType, Event_Id, EventName, ReceivedDate, EventUser, EventStatus, Detail, ActualResponseDate 
							 from #Main1
							 where ActualResponseDate is null

open CUR_Main1
fetch NEXT from CUR_Main1 into	@ID, @Work_Id, @Reference, @ClaimNumber, @WorkType, @GroupType, @Event_Id, @EventName,
								@ReceivedDate, @EventUser, @EventStatus, @Detail, @ActualResponseDate
--initialise work events batch.
select @IDStart = @ID, @IDEnd = @ID

--step through each row in #WorkEvents1 and insert them to #Main1 table or update ActualResponseDate to the date status changed to Active/Activated
while @@FETCH_STATUS = 0
begin

  if (@EventName = 'Changed Work Status' and @EventStatus = 'Active' and @Detail = 'Activated')
  begin
	update #Main1
	set ActualResponseDate = @ReceivedDate
	where ClaimNumber = @ClaimNumber and ID between @IDStart and @IDEnd

     fetch NEXT from CUR_Main1 into	@ID, @Work_Id, @Reference, @ClaimNumber, @WorkType, @GroupType, @Event_Id, @EventName,
								@ReceivedDate, @EventUser, @EventStatus, @Detail, @ActualResponseDate
  	 
  	 select @IDStart = @ID, @IDEnd = @ID
  end
  else if (@EventName = 'Changed Work Status' and @EventStatus = 'Diarised' and @Detail like '%ClaimDenied%')
  begin
	update #Main1
	set ActualResponseDate = @ReceivedDate
	where ClaimNumber = @ClaimNumber and ID between @IDStart and @IDEnd

     fetch NEXT from CUR_Main1 into	@ID, @Work_Id, @Reference, @ClaimNumber, @WorkType, @GroupType, @Event_Id, @EventName,
								@ReceivedDate, @EventUser, @EventStatus, @Detail, @ActualResponseDate
  	 
  	 select @IDStart = @ID, @IDEnd = @ID  
  end
  else
  begin     
     select @IDEnd = @IDEnd + 1		   
    
     fetch NEXT from CUR_Main1 into	@ID, @Work_Id, @Reference, @ClaimNumber, @WorkType, @GroupType, @Event_Id, @EventName,
								@ReceivedDate, @EventUser, @EventStatus, @Detail, @ActualResponseDate    
  end
								
end

close CUR_Main1
deallocate CUR_Main1



--delete Activated events because they are not required in SLA calculation
delete #Main1
where Detail = 'Activated'


--get the next completed/diarised work event after the reporting period
--store in temp table. it will be used to find the ActualResponseDate 
if object_id('tempdb..#LastWorkEvents') is not null drop table #LastWorkEvents
select
  w.Id as Work_Id,
  wcp.ClaimNumber,
  min(we.Id) as Event_Id,
  convert(datetime,null) as EventDate
into #LastWorkEvents
from
  ulsql02.e5_content.dbo.Work w
  join ulsql02.e5_content.dbo.WorkCustomProperty wcp on			--WorkCustomProperty
	w.Id = wcp.Work_Id
  join ulsql02.e5_content.dbo.Category2 c2 on						--Category2
	w.Category2_Id = c2.Id
  join ulsql02.e5_content.dbo.Category3 c3 on						--Category3
	w.Category3_Id = c3.Id
  join ulsql02.e5_content.dbo.[Status] ws on						--Status
	w.Status_Id = ws.Id
  join ulsql02.e5_content.dbo.WorkEvent we on
    w.Id = we.Work_Id
  join ulsql02.e5_content.dbo.[Event] e on
	we.Event_Id = e.Id    
  join ulsql02.e5_content.dbo.[Status] es on
	we.Status_Id = es.Id
where
  we.Work_Id in (select Work_Id from #Main1 where ActualResponseDate is null group by Work_Id) and
  we.EventDate > @rptEndDate and
  we.Event_Id = 100 and						--Change Work Status
  (we.Detail like 'Diarised%' or we.Detail like 'Completed%' or we.Detail like '%ClaimDenied%' or we.Detail like '%Claim Denied%')
group by
  w.Id,
  wcp.ClaimNumber
order by  
  wcp.ClaimNumber


--update the #LastWorkEvents with EventDate from WorkEvent
update #LastWorkEvents
set EventDate = we.EventDate
from
	#LastWorkEvents a	
	join ulsql02.e5_content.dbo.WorkEvent we on
		a.Work_Id = we.Work_Id and
		a.Event_Id = we.Id

--update #Main1 table where ActualResponseDate is null
update #Main1
set ActualResponseDate = convert(varchar(10),le.EventDate,120)
from #Main1 m join #LastWorkEvents le on
	m.Work_Id = le.Work_Id and
	m.ClaimNumber = le.ClaimNumber collate Latin1_General_CI_AS
where
	m.ActualResponseDate is null


--declare cursor for calculating SLAResponseDate and TurnAroundTime
declare CUR_Main1 cursor for select Id, ReceivedDate, ActualResponseDate from #Main1

open CUR_Main1
fetch NEXT from CUR_Main1 into	@ID, @ReceivedDate, @ActualResponseDate

while @@FETCH_STATUS = 0
begin

  --if @ReceivedDate falls on Sunday, Saturday, or Holiday, move to the next work day
  if (select case when isHoliday = 1 or isWeekEnd = 1 then 1 else 0 end from [db-au-cmdwh].dbo.Calendar where [Date] = @ReceivedDate) = 1
    select @TempReceivedDate = (select min([Date]) from [db-au-cmdwh].dbo.Calendar where [Date] > @ReceivedDate and (isHoliday <> 1 and isWeekDay = 1))
  else
    select @TempReceivedDate = @ReceivedDate
  
  --add 10 work days to @TempResponseDate
  select @TempResponseDate = [db-au-cmdwh].dbo.fn_AddWorkDays(@TempReceivedDate,10)
  --add any public holidays to @TempResponseDate
  select @TempResponseDate = dateadd(d,(select sum(isHoliday) from [db-au-cmdwh].dbo.Calendar where [Date] between @TempReceivedDate and @TempResponseDate),@TempResponseDate)
  
  --if @TempResponseDate falls on Sunday, Saturday or Holiday, move to the next work day
  if (select case when isHoliday = 1 or isWeekEnd = 1 then 1 else 0 end from [db-au-cmdwh].dbo.Calendar where [Date] = @TempResponseDate) = 1
    select @TempResponseDate = (select min([Date]) from [db-au-cmdwh].dbo.Calendar where [Date] > @TempResponseDate and (isHoliday <> 1 and isWeekDay = 1))   
 
  --calculate TurnAroundTime in days
  select @TempTurnAroundTime = datediff(d,@TempReceivedDate,@ActualResponseDate) - (select sum(case when isHoliday = 1 or isWeekend = 1 then 1 else 0 end) from [db-au-cmdwh].dbo.Calendar where [Date] between @TempReceivedDate and @ActualResponseDate)
    
  update #Main1
  set SLAResponseDate = @TempResponseDate, TurnAroundTime = @TempTurnAroundTime
  where ID = @ID
  
  fetch NEXT from CUR_Main1 into @ID, @ReceivedDate, @ActualResponseDate

end

close CUR_Main1
deallocate CUR_Main1

--select main data for report
select
  w.ID,
  w.Reference,
  w.ClaimNumber,
  w.WorkType,
  w.GroupType,
  w.EventName,
  w.ReceivedDate,
  w.EventUser,
  w.EventStatus,
  w.Detail,
  w.SLAResponseDate,
  w.ActualResponseDate,
  w.TurnAroundTime as TurnaroundTime_old,
  (case when ((w.ActualResponseDate = w.ReceivedDate) and (w.TurnAroundTime is null)) then (case when w.TurnAroundTime is null then 0 end)else  w.TurnAroundTime end)as TurnaroundTime,
  case when w.TurnAroundTime <= 10 then 'PASS'
       when w.TurnAroundTime > 10 then 'FAILED'
       when w.ActualResponseDate is null and w.SLAResponseDate < convert(varchar(10),getdate(),120) then 'FAILED'
       else 'PENDING'
  end as Result,
  (case when  w.TurnAroundTime <= 10  then '<= 10 days'
		when  w.TurnAroundTime = 11 then '11'
		when  W.TurnAroundTime =12 then '12'
		when  w.TurnAroundTime =13 then '13'
		when  w.TurnAroundTime =14 then '14'
		when w.TurnAroundTime =15 then '15'
		when w.TurnAroundTime between 16 and 20 then '6-10 Overdue'
		when w.TurnAroundTime between 21 and 30 then '11-20 Overdue'
		when w.TurnAroundTime between 31 and 50 then '21-40 Overdue'
		when w.TurnAroundTime > 50 then '> 40 Overdue'
		when w.TurnAroundTime is null then 'Not Responded' end)as TurnaroundTime2 ,
  @rptStartDate as StartDate,
  @rptEndDate as EndDate
from 
  #Main1 w 
where
  w.Detail not like '%Claim Denied%' and
  w.Detail not like '%ClaimDenied%'and
  w.WorkType not like 'Correspondence'




drop table #WorkEvents1
drop table #Main1
drop table #LastWorkEvents
GO
