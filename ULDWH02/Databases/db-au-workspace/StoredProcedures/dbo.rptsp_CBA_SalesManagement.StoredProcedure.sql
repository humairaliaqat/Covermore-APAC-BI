USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_CBA_SalesManagement]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[rptsp_CBA_SalesManagement]

AS
begin
	set nocount on

	IF OBJECT_ID('tempdb..#temp_Intv', 'U') IS NOT NULL 
	  DROP TABLE #temp_Intv;
	IF OBJECT_ID('tempdb..#temp_call1', 'U') IS NOT NULL 
	  DROP TABLE #temp_call1;


	---- uncomments to debug
	DECLARE 
	 @StartDate DATETIME,
	 @EndDate DATETIME
	SELECT 
	 @StartDate = DATEADD(day,-30, getdate()),            -- get last 30 days data
	 @EndDate = getdate()
	-- uncomments to debug



	 --get reporting dates
	DECLARE @rptStartDate DATETIME, @rptEndDate DATETIME
		SELECT @rptStartDate = @StartDate, @rptEndDate = @EndDate


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
	,tc.[IncludeInCSDashboard]
	,it.time
	,it.CallDate as CallDate1
	,it.DayofWeekNum 
	,it.DayOfWeek
	,cast(it.time as time(0)) as Interval
	,DENSE_RANK() over(PARTITION BY tc.SessionId ORDER BY tc.callenddatetime DESC) AS DenseRank  
	,@rptStartDate AS ReportStartDate
	,@rptEndDate AS ReportEndDate
	into #temp_call1

	from [db-au-cba].[dbo].[vTelephonyCallData] as tc
	left JOIN #temp_Intv as it ON  
				dateadd(minute, floor(datediff(minute, 0, tc.CallStartDateTime) / 15.0) * 15, 0) = it.time
	where  
	tc.Company like '%Medibank%'
	and convert(date, tc.CallDate) >= convert(date, @rptStartDate) and convert(date, tc.CallDate) < convert(date,@rptEndDate)
	order by tc.CallDate 

	delete from #temp_call1 where DenseRank <> 1

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
	,tc1.ReportStartDate
	,tc1.ReportEndDate

	from #temp_call1 as tc1
end
GO
