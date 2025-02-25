USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1054p]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************/
--  Name			:	rptsp_rpt1054p
--  Description		:	WTP Dashboard for CBA - Calls Management
--  Author			:	Yi Yang
--  Date Created	:	20190225
--  Parameters		:	@ReportingPeriod, @StartDate, @EndDate
--  Change History	:	
/****************************************************************************************************/
CREATE PROCEDURE [dbo].[rptsp_rpt1054p]
--  @ReportingPeriod VARCHAR(30)
--, @StartDate DATETIME
--, @EndDate DATETIME
AS

begin
    set nocount on

IF OBJECT_ID('tempdb..#temp_call', 'U') IS NOT NULL 
  DROP TABLE #temp_call;
IF OBJECT_ID('tempdb..#temp_login', 'U') IS NOT NULL 
  DROP TABLE #temp_login;

---- uncomments to debug
DECLARE @ReportingPeriod VARCHAR(30)
, @StartDate DATETIME
, @EndDate DATETIME
SELECT @ReportingPeriod =  '_User Defined'
, @StartDate = dateadd(day, 1, EOMONTH(DATEADD(day, -1, convert(date, GETDATE())), -4))		--'2018-11-01'
, @EndDate = DATEADD(day, -1, convert(date, GETDATE()))									-- '2019-02-11'
-- uncomments to debug
 
 --get reporting dates
DECLARE @rptStartDate DATETIME, @rptEndDate DATETIME
IF @ReportingPeriod = '_User Defined'
	SELECT @rptStartDate = @StartDate, @rptEndDate = @EndDate
ELSE
    SELECT @rptStartDate = StartDate, @rptEndDate = EndDate
    FROM [db-au-cmdwh].dbo.vDateRange
    where DateRange = @ReportingPeriod

-- get interval time
DECLARE @IntvTime TABLE(
    time datetime NOT NULL,
	CallDate date Not Null,
	DayofWeekNum int not null,
	--Interval varchar(30)  not null,
	DayOfWeek varchar(30) NOT NULL
	)

declare @number int
,@time1 datetime
,@CallDate1 date
,@DayofWeekNum1 int
--,@Interval1  varchar(30)
,@DayOfWeek1 varchar(30)

set @number = 0

while @number <= 24*4*40

BEGIN  

	set @time1 = DateAdd(minute, -15 * (@number + 1), CAST(CAST(@rptEndDate+1 as date) as datetime)) 
	set @CallDate1  = CAST(@time1 as date) 
	set @DayofWeekNum1 = datepart(dw, @CallDate1) 
	--select  @Interval1 = CONVERT(varchar, @CallDate1, 108)
	set @DayOfWeek1 = 
		case @DayofWeekNum1 
			when  1 THEN   'Sunday'
			when  2 THEN   'Monday'
			when  3 THEN   'Tuesday'
			when  4 THEN   'Wednesday'
			WHEN  5 THEN   'Thursday'
			WHEN  6 THEN   'Friday'
			WHEN  7 THEN   'Saturday'
		END  

	INSERT INTO @IntvTime values (@time1, @CallDate1, @DayofWeekNum1, @DayOfWeek1)
	set @number += 1
END  

select * into #temp_Intv
 from @IntvTime

select 
	tc.[SessionID]
	,tc.[AgentName]
	,tc.[Team]
	,tc.[ApplicationName]
	,tc.[Company]
	,tc.[CSQName]
	,tc.[CallDate]
	,tc.[CallStartDateTime]
	,tc.[CallEndDateTime]
	,tc.[Disposition]
	,tc.[OriginatorNumber]
	,tc.[DestinationNumber]
	,tc.[CalledNumber]
	,tc.[OrigCalledNumber]
	,tc.[CallsPresented]
	,tc.[CallsHandled]
	,tc.[CallsAbandoned]
	,tc.[RingTime]
	,tc.[TalkTime]
	,tc.[HoldTime]
	,tc.[WorkTime]
	,tc.[WrapUpTime]
	,tc.[QueueTime]
	,tc.[MetServiceLevel]
	,tc.[Transfer]
	,tc.[Redirect]
	,tc.[Conference]
	,tc.[RNA]
	,tc.[ContactType]
	,tc.[IncludeInCSDashboard]
	,it.time
	,it.CallDate as CallDate1
	,it.DayofWeekNum 
	,it.DayOfWeek
	,cast(it.time as time(0)) as Interval
	,cm.[Call Classification]
	,cm.[Agent Group]
	,cm.[Team Type]
	,cm.[Call Type]
	,@rptStartDate AS ReportStartDate
	,@rptEndDate AS ReportEndDate
into 
	#temp_call
from 
	[db-au-cmdwh].[dbo].[vTelephonyCallData] as tc with (NOLOCK)
	left join #temp_Intv as it ON  
			dateadd(minute, floor(datediff(minute, 0, tc.CallStartDateTime) / 15.0) * 15, 0) = it.time
	outer apply 
	(select top 1 cm.[Call Classification],cm.[Agent Group],cm.[Team Type],cm.[Call Type]
	from 
		usrCallMapping as cm
		where tc.OrigCalledNumber = cm.[Answer Point]
	order by cm.[Call Classification]
	) cm
where  
	--tc.CSQName in ('CC_CBA_Group')
	OrigCalledNumber in ('5615', '5624', '5632', '5633', '5641', '5646', '5679', '5680')
	and
	(convert(date, tc.CallDate) >= @rptStartDate and convert(date, tc.CallDate) <= @rptEndDate) 
	and
	tc.RNA <> '1'

order by tc.CallDate 

-- remove the calls where handled but not talk time

delete from 
	#temp_call
where 
	TalkTime = 0 and 
	Disposition = 'Handled'

-- Generate output columns for reporting
select 
	tc1.[SessionID]
	,tc1.[AgentName]
	,tc1.[Team]
	,tc1.[ApplicationName]
	,tc1.[Company]
	,tc1.[CSQName]
	,tc1.[CallDate]
	,tc1.[CallStartDateTime]
	,tc1.[CallEndDateTime]
	,tc1.[Disposition]
	,tc1.[OriginatorNumber]
	,tc1.[DestinationNumber]
	,tc1.[CalledNumber]
	,tc1.[OrigCalledNumber]
	,tc1.[CallsPresented]
	,tc1.[CallsHandled]
	,tc1.[CallsAbandoned]
	,tc1.[RingTime]
	,tc1.[TalkTime]
	,tc1.[HoldTime]
	,tc1.[WorkTime]
	,tc1.[WrapUpTime]
	,tc1.[QueueTime]
	,tc1.[MetServiceLevel]
	,tc1.[Transfer]
	,tc1.[Redirect]
	,tc1.[Conference]
	,tc1.[RNA]
	,tc1.[IncludeInCSDashboard]
	,tc1.time
	,tc1.CallDate1
	,tc1.DayofWeekNum 
	,tc1.DayOfWeek
	,tc1.Interval
	,tc1.[ContactType]
	,tc1.[Call Classification]
	,tc1.[Agent Group]
	,tc1.[Team Type]
	,tc1.[Call Type]

	,0 as TotalLogin
	--,lgt.TotalLogin

	,tc1.ReportStartDate
	,tc1.ReportEndDate
from 
	#temp_call as tc1 

/*	outer apply 
	(
	select 
		AgentName, 
		Convert(date, lg.LoginTime) as CallDate, 
		(sum(DATEDIFF(MINUTE, LoginTime, LogoutTime)) - AVG(NotReadyTime)) AS TotalLogin
	from 
		#temp_login as lg
	where 
		row# = 1
		and (tc1.AgentName = lg.AgentName) 
		and (tc1.CallDate = Convert(date, lg.LoginTime))
	group by 
		lg.AgentName, Convert(date, lg.LoginTime) 
	) lgt			-- Get (Total Login Time - Not Ready Time) for each CSO
*/
end
GO
