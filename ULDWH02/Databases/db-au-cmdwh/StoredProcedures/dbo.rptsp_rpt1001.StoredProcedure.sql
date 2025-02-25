USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1001]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************/
--  Name			:	rptsp_rpt1001
--  Description		:	CallCenterData  
--  Author			:	Yi Yang
--  Date Created	:	20180424
--  Description		:	Call Center Channels Reports
--  Parameters		:	@ReportingPeriod, @StartDate, @EndDate
--  Change History	:	20180810
--						Add column of daily total Login Time for each CSO 
--						20190829 
--						Add Server Name ULDWH02 for all Call data tables
--						2019-09-23: DM - MOved from BHDWH03 to ULDWH02 to solve double hop issue with this report.
/****************************************************************************************************/

CREATE PROCEDURE [dbo].[rptsp_rpt1001]
  @ReportingPeriod VARCHAR(30)
, @StartDate DATETIME
, @EndDate DATETIME
AS

begin
    set nocount on

	IF OBJECT_ID('tempdb..#temp_Intv', 'U') IS NOT NULL 
	  DROP TABLE #temp_Intv;
	IF OBJECT_ID('tempdb..#temp_call1', 'U') IS NOT NULL 
	  DROP TABLE #temp_call1;
	IF OBJECT_ID('tempdb..#temp_login', 'U') IS NOT NULL 
	  DROP TABLE #temp_login;


	---- uncomments to debug
	--DECLARE @ReportingPeriod VARCHAR(30)
	--, @StartDate DATETIME
	--, @EndDate DATETIME
	--SELECT @ReportingPeriod =  '_User Defined'
	--, @StartDate = '2018-07-25'
	--, @EndDate = '2018-07-25'
	-- uncomments to debug
 
	 --get reporting dates
	DECLARE @rptStartDate DATETIME, @rptEndDate DATETIME
	IF @ReportingPeriod = '_User Defined'
		SELECT @rptStartDate = @StartDate, @rptEndDate = @EndDate
	ELSE
		SELECT @rptStartDate = StartDate, @rptEndDate = EndDate
		FROM vDateRange
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
		,tc.[IncludeInCSDashboard]
		,it.time
		,it.CallDate as CallDate1
		,it.DayofWeekNum 
		,it.DayOfWeek
		,cast(it.time as time(0)) as Interval
		,DENSE_RANK() over(PARTITION BY tc.SessionId ORDER BY tc.callenddatetime DESC) AS DenseRank  
		,@rptStartDate AS ReportStartDate
		,@rptEndDate AS ReportEndDate
	into 
		#temp_call1
	from 
		[ULDWH02].[db-au-cmdwh].[dbo].[vTelephonyCallData] as tc
		left JOIN #temp_Intv as it ON  
				dateadd(minute, floor(datediff(minute, 0, tc.CallStartDateTime) / 15.0) * 15, 0) = it.time
	where  
		tc.ApplicationName like '%DTC%'
		and 
		(
		(tc.CallDate>=@rptStartDate and tc.CallDate <= @rptEndDate)
		--or 
		--(tc.CallDate>= dateadd(month, -1, @rptStartDate) and tc.CallDate <= dateadd(month, -1, @rptEndDate))
		)
	order by tc.CallDate 

	delete from #temp_call1 where DenseRank <> 1

	--- Get Total Login Time for each CSO
	;with cte_in 
	as
		(
		select   ag.agentkey, ag.agentname, ast.eventdatetime, ast.eventtype --* 
		from 
			[ULDWH02].[db-au-cmdwh].[dbo].cisAgentState as ast
			join [ULDWH02].[db-au-cmdwh].[dbo].cisAgent as ag on (ast.AgentKey = ag.AgentKey)
		where 
			ag.company = 'Davidson Trahaire Corpsych'
			and convert(date, ast.EventDateTime) >= @rptStartDate
			and convert(date, ast.EventDateTime) <= @rptEndDate
			and ast.Eventtype = '1'
		),
	cte_out as 
		(
		select ag.agentkey, ag.agentname, ast.eventdatetime, ast.eventtype --* 
		from 
			[ULDWH02].[db-au-cmdwh].[dbo].cisAgentState as ast
			join [ULDWH02].[db-au-cmdwh].[dbo].cisAgent as ag on (ast.AgentKey = ag.AgentKey)
		where 
			ag.company = 'Davidson Trahaire Corpsych'
			and convert(date, ast.EventDateTime) >= @rptStartDate
			and convert(date, ast.EventDateTime) <= @rptEndDate
		and Eventtype = '7'
		),
	cte_notready as 
		(
		select 
		ag.Agentname, 
		convert(date, ast.eventdatetime) as CallDate, 
		sum(ast.eventduration)/60 as NotReadyTime  --* 
		from 
			[ULDWH02].[db-au-cmdwh].[dbo].cisAgentState as ast
			join [ULDWH02].[db-au-cmdwh].[dbo].cisAgent as ag on (ast.AgentKey = ag.AgentKey)
		where 
			ag.company = 'Davidson Trahaire Corpsych'
			and convert(date, ast.EventDateTime) >= @rptStartDate
			and convert(date, ast.EventDateTime) <= @rptEndDate
			and ast.Eventtype = '2'
		group by 
		ag.Agentname, convert(date, ast.eventdatetime)
		)

	select 
		tin.AgentName, 
		tin.AgentKey, 
		tin.eventdatetime as LoginTime, 
		tout.EventDateTime as LogoutTime, 
		nr.NotReadyTime,
		ROW_NUMBER() OVER(PARTITION BY tin.agentname, tin.EventDateTime order by tout.eventdatetime ASC) AS Row#
	into 
		#temp_login
	from 
		cte_in as tin
		join cte_out as tout on (tin.AgentKey = tout.AgentKey) and 
							(convert(date, tin.EventDateTime) = convert(date, tout.EventDateTime)) 
							and (tin.EventDateTime < tout.EventDateTime)
		join cte_notready as nr on (tin.agentname = nr.agentname) and ((convert(date, tin.EventDateTime) = nr.calldate))


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
		,lgt.TotalLogin
		,tc1.ReportStartDate
		,tc1.ReportEndDate
	from 
		#temp_call1 as tc1 
		outer apply 
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

end
GO
