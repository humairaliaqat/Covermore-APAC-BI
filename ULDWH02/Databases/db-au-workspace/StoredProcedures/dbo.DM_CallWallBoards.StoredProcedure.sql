USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[DM_CallWallBoards]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [DM_CallWallBoards]

CREATE procedure [dbo].[DM_CallWallBoards]
	--@Team varchar(10) = null
AS
BEGIN
	SET NOCOUNT ON
	--Uncomment to Debug
	--declare @team varchar(10) = 'CSR'

	--select @Team = NullIf(@Team, 'NULL')

	if object_id('tempdb..#Intervals') IS NOT NULL
		drop table #Intervals

	DECLARE @CurrentTime datetime = CAST('19000101' as Datetime) + CAST(CAST(GetDate() as Time) as datetime)

	;with NumberSequence( Number ) as
		(
			Select 0 as Number
				union all
			Select Number + 1
				from NumberSequence
				where Number < (24 * 4) -1
		),
	Intervals as (
		select	DateAdd(minute, number * 15, '19000101') as [timeStart], 
				DateAdd(minute, (number + 1) * 15, '19000101') as [timeEnd], 
				C.Date as [CallDate], 
				DateAdd(minute, number * 15, C.Date) as [CallDateTimeStart], 
				DateAdd(minute, (number +1) * 15, C.Date) as [CallDateTimeEnd], 
				datepart(dw, C.Date) as [DayofWeekNum], 
				datename(dw,c.date) [DayofWeek]
		from [db-au-cmdwh].dbo.Calendar c
		cross join NumberSequence s
		where c.Date = CAST(GetDate() as Date)
	)
	select *
	into #Intervals
	from Intervals

	if object_id('tempdb..#LiveData') IS NOT NULL
		drop table #LiveData

	--select * from [db-au-cmdwh].dbo.usrCallMapping

	select 
		IsNull(cm.[Team Type],'Unknown') [Team Type], 
		cm.[Call Classification],
		cm.[Call Type],
		cd.CallStartDateTime,
		CAST('19000101' as Datetime) + CAST(CAST(cd.CallStartDateTime as time) as datetime) as CallTime,
		cd.SessionID,
		cd.CSQName,
		cd.ApplicationName,
		cd.Team,
		cd.QueueTime, 
		cd.CallsHandled,
		cd.CallsPresented,
		cd.CallsAbandoned,
		cd.TalkTime,
		cd.HoldTime,
		cd.WorkTime,
		cd.WrapUpTime,
		cd.RingNoAnswer
	into #LiveData 
	from [db-au-cmdwh].dbo.vTelephonyLiveCallData cd
	cross apply (
		select	top 1 cm.[Team Type], 
				cm.[Call Classification],
				cm.[Call Type]
		from [db-au-cmdwh].dbo.usrCallMapping cm 
		where cd.OrigCalledNumber = cm.[Answer Point]
		and CAST(cd.CallStartDateTime as date) between isNull(cm.[Start Date], CAst(cd.CallStartDateTime as date)) AND isNull(cm.[End Date], CAST(cd.CallStartDateTime as date)) 
	) cm
		--AND isNull(cm.[Team Type],'') = Coalesce(@Team, cm.[Team Type], '')

	if object_id('tempdb..#HistoricData') IS NOT NULL
		drop table #HistoricData

	select 
		IsNull(cm.[Team Type],'Unknown') [Team Type], 
		cm.[Call Classification],
		cm.[Call Type],
		cd.CallStartDateTime,
		cd.SessionID,
		CAST('19000101' as Datetime) + CAST(CAST(cd.CallStartDateTime as time) as datetime) as CallTime,
		cd.GatewayNumber,
		cd.ContactType,
		x.ContactType as FirstContactType,
		cd.ContactDisposition,
		cd.CSQName,
		cd.ApplicationName,
		cd.Team,
		cd.QueueTime, 
		cd.QueueHandled CallsHandled,
		cd.CallsPresented,
		cd.QueueAbandoned CallsAbandoned,
		cd.TalkTime,
		cd.HoldTime,
		cd.WorkTime,
		cd.WrapUpTime,
		cd.RNA,
		cd.Transfer,
		cd.Redirect,
		cd.Conference,
		cd.MetServiceLevel,
		cd.ServiceLevelPercentage
	into #HistoricData
	from [db-au-cmdwh].dbo.vTelephonyData cd
	--left JOIN [db-au-cmdwh].dbo.usrCallMapping cm on cd.OrigCalledNumber = cm.[Answer Point]
	cross apply (
		select	top 1 cm.[Team Type], 
				cm.[Call Classification],
				cm.[Call Type]
		from [db-au-cmdwh].dbo.usrCallMapping cm 
		where cd.GatewayNumber = cm.[Answer Point]
		and CAST(cd.CallStartDateTime as date) between isNull(cm.[Start Date], CAst(cd.CallStartDateTime as date)) AND isNull(cm.[End Date], CAST(cd.CallStartDateTime as date)) 
	) cm
	outer apply(
		select top 1 ContactType
		from [db-au-cmdwh].dbo.vTelephonyData fcd
		where cd.SessionID = fcd.SessionID
		and fcd.SessionSequence = 0
	) x
	where 
		datepart(dw,GetDate()) = datepart(dw,CallStartDateTime)
		and cd.CallDate between CAST(DateAdd(week,-8,GetDate()) as Date) and CAST(DateAdd(day,-1,GetDate()) as Date)
		and x.ContactType <> 'Outgoing'
		--AND isNull(cm.[Team Type],'') = Coalesce(@Team, cm.[Team Type], '')


	if object_id('tempdb..#Teams') IS NOT NULL
		drop table #Teams

	select distinct [Team Type]
	into #Teams
	from #LiveData
	union
	select distinct [Team Type]
	from #HistoricData

	--select * from #HistoricData where callsHandled = 0 and CallsAbandoned = 0 and RNA = 0 and Redirect = 0 and contactType <> 'INternal'

	--select [Call Classification], [Team], ContactType, COUNT(*) from #HistoricData GROUP BY [Call Classification], [Team], ContactType order by 1,2,3

	--select *
	--from [db-au-cmdwh].dbo.cisCallData
	--where SessionID = 230000028319

	--select top 10 * from [db-au-cmdwh].dbo.vTelephonyData where GatewayNumber = '00011959403909948'
	--select * from [db-au-cmdwh].dbo.usrCallMapping

	--select distinct GatewayNumber, ContactType
	--into #temp
	--from [db-au-cmdwh].dbo.vTelephonyData

	
	--select distinct Team
	--from [db-au-cmdwh].dbo.vTelephonyData
	--where SessionSequence = 0

	--select *
	--from #temp
	--where contacttype <> 'Outgoing'

	--delete from #HistoricData where CallTime > @CurrentTime

	CREATE NONCLUSTERED INDEX tmpidx_liveData
	ON #LiveData ([CallTime])
	INCLUDE ([QueueTime],[CallsHandled],[CallsPresented],[CallsAbandoned],[TalkTime],[HoldTime],[WorkTime],[WrapUpTime],[RingNoAnswer])

	CREATE NONCLUSTERED INDEX tmpidx_HistoricData
	ON #HistoricData ([CallTime])
	INCLUDE ([QueueTime],[CallsHandled],[CallsPresented],[CallsAbandoned],[TalkTime],[HoldTime],[WorkTime],[WrapUpTime],RNA)
	
	if object_id('tempdb..#Results') IS NOT NULL
		drop table #Results

	create table #results(
		[timeStart] datetime NULL,
		[timeEnd] datetime NULL,
		[Team Type] varchar(20) NULL,
		[CallDate] date,
		[DayofWeek] nvarchar(10) NULL,
		[DayofWeekNum] int NULL,
		[Live_CallsHandled] float,
		[Live_CallsPresented] int,
		[Live_CallsAbandoned] int,
		[Live_TalkTime] int,
		[Live_HoldTime] int,
		[Live_WorkTime] int,
		[Live_WrapUpTime] int,
		[Live_RingNoAnswer] int,
		[Live_QueueTime] int,
		[Live_CallsInGOS] int,
		[Hist_CallsHandled] float,
		[Hist_CallsPresented] int,
		[Hist_CallsAbandoned] int,
		[Hist_TalkTime] int,
		[Hist_HoldTime] int,
		[Hist_WorkTime] int,
		[Hist_WrapUpTime] int,
		[Hist_RingNoAnswer] int,
		[Hist_QueueTime] int,
		[Hist_CallsInGOS] int,
		[Hist_DayCount] int,
		[Include] int,
		[HistPeriodicGOS] float,
		[DayGOS] float
	)

	select 
		CAST(CallStartDateTime as date) CallDate,
		I.timeStart,
		I.timeEnd,
		H.[Team Type],
		SUM(H.CallsHandled) Hist_CallsHandled,
		CAST(SUM(H.CallsPresented) as float)  Hist_CallsPresented,
		SUM(H.CallsAbandoned) Hist_CallsAbandoned,
		SUM(H.TalkTime)  Hist_TalkTime,
		SUM(H.HoldTime) Hist_HoldTime,
		SUM(H.WorkTime) Hist_WorkTime,
		SUM(H.WrapUpTime) Hist_WrapUpTime,
		SUM(H.RNA) Hist_RingNoAnswer,
		SUM(H.QueueTime) Hist_QueueTime,
		CAST(SUM(CASE WHEN H.QueueTime <= 20 THEN 1 ELSE 0 END) as float) as Hist_CallsInGOS,
		SUM(CASE WHEN H.QueueTime <= 20 THEN 1 ELSE 0 END)/ NULLIF(SUM(H.CallsPresented),0) GOS
		--COUNT(DISTINCT CAST(H.CallStartDateTime as Date)) as Hist_DayCount
	into #cte_hist
	from #HistoricData H
	join #Intervals I on H.CallTime >= I.[timeStart] AND H.CallTime < I.timeEnd 
	GROUP BY 
		CAST(CallStartDateTime as date),
		I.timeStart,
		I.timeEnd,
		H.[Team Type]

	;with cte_hist_gos_days_periods as (
		select 
			X.CallDate,
			T.[Team Type],
			timeStart,
			B.totalCallsInGOS_RT,
			B.totalCallsPresented_RT,
			B.GOS_RT,
			B.CallDayCount
		from #Intervals A
		cross apply #Teams t
		cross apply (
			select distinct CallDate
			from #cte_hist
		) X
		outer apply (
			select 
				SUM(Hist_CallsInGOS) totalCallsInGOS_RT,
				SUM(Hist_CallsPresented) totalCallsPresented_RT,
				SUM(Hist_CallsInGOS)/ NULLIF(SUM(Hist_CallsPresented),0) GOS_RT,
				COUNT(DISTINCT B.CallDate) CallDayCount
			from #cte_hist B
			where B.timeStart <= A.timeStart
			AND X.CallDate = B.CallDate
			and b.[Team Type] = T.[Team Type]
		) B
	),
	cte_hist_gos_days as (
		select 
			CallDate,
			[Team Type],
			SUM(Hist_CallsInGOS) totalCallsInGOS,
			SUM(Hist_CallsPresented) totalCallsHandled,
			SUM(Hist_CallsInGOS)/ NULLIF(SUM(Hist_CallsPresented),0) GOS
		from #cte_hist
		GROUP BY 
			CallDate,
			[Team Type]
	)
	insert into #results
	select	I.timeStart,
			I.timeEnd,
			T.[Team Type],
			I.CallDate,
			I.DayofWeek,
			I.DayofWeekNum,
			IsNull(L.Live_CallsHandled,0) Live_CallsHandled,
			IsNull(L.Live_CallsPresented,0) Live_CallsPresented,
			IsNull(L.Live_CallsAbandoned,0) Live_CallsAbandoned,
			IsNull(L.Live_TalkTime,0) Live_TalkTime,
			IsNull(L.Live_HoldTime,0) Live_HoldTime,
			IsNull(L.Live_WorkTime,0) Live_WorkTime,
			IsNull(L.Live_WrapUpTime,0) Live_WrapUpTime,
			IsNull(L.Live_RingNoAnswer,0) Live_RingNoAnswer,
			IsNull(L.Live_QueueTime,0) Live_QueueTime,
			IsNull(L.Live_CallsInGOS,0) Live_CallsInGOS,
			IsNull(H.Hist_CallsHandled,0) Hist_CallsHandled,
			IsNull(H.Hist_CallsPresented,0) Hist_CallsPresented,
			IsNull(H.Hist_CallsAbandoned,0) Hist_CallsAbandoned,
			IsNull(H.Hist_TalkTime,0) Hist_TalkTime,
			IsNull(H.Hist_HoldTime,0) Hist_HoldTime,
			IsNull(H.Hist_WorkTime,0) Hist_WorkTime,
			IsNull(H.Hist_WrapUpTime,0) Hist_WrapUpTime,
			IsNull(H.Hist_RingNoAnswer,0) Hist_RingNoAnswer,
			IsNull(H.Hist_QueueTime,0) Hist_QueueTime,
			IsNull(H.Hist_CallsInGOS,0) Hist_CallsInGOS,
			IsNull(H.Hist_DayCount,0) Hist_DayCount,
			CASE WHEN I.timeEnd <= @CurrentTime THEN 1 ELSE 0 END as Include,
			ghp.Hist_GOS_RT,
			x.DayGOS
	from #Intervals I
	cross apply #Teams T
	outer apply (
		select 
			SUM(L.CallsHandled) Live_CallsHandled,
			SUM(L.CallsPresented) Live_CallsPresented,
			SUM(L.CallsAbandoned) Live_CallsAbandoned,
			SUM(L.TalkTime) Live_TalkTime,
			SUM(L.HoldTime) Live_HoldTime,
			SUM(L.WorkTime) Live_WorkTime,
			SUM(L.WrapUpTime) Live_WrapUpTime,
			SUM(L.RingNoAnswer) Live_RingNoAnswer,
			SUM(L.QueueTime) Live_QueueTime,
			SUM(CASE WHEN L.QueueTime <= 20 THEN 1 ELSE 0 END) as Live_CallsInGOS
		from #LiveData L
		where L.CallTime >= I.[timeStart] 
		AND L.CallTime < I.timeEnd 
		AND L.[Team Type] = T.[Team Type]
	) L
	outer apply (
		select 
			SUM(H.Hist_CallsHandled) / NullIf(COUNT(DISTINCT H.CallDate),0) Hist_CallsHandled,
			SUM(H.Hist_CallsPresented) / NullIf(COUNT(DISTINCT H.CallDate),0) Hist_CallsPresented,
			SUM(H.Hist_CallsAbandoned) / NullIf(COUNT(DISTINCT H.CallDate),0) Hist_CallsAbandoned,
			SUM(H.Hist_TalkTime) / NullIf(COUNT(DISTINCT H.CallDate),0) Hist_TalkTime,
			SUM(H.Hist_HoldTime) / NullIf(COUNT(DISTINCT H.CallDate),0) Hist_HoldTime,
			SUM(H.Hist_WorkTime) / NullIf(COUNT(DISTINCT H.CallDate),0) Hist_WorkTime,
			SUM(H.Hist_WrapUpTime) / NullIf(COUNT(DISTINCT H.CallDate),0) Hist_WrapUpTime,
			SUM(H.Hist_RingNoAnswer) / NullIf(COUNT(DISTINCT H.CallDate),0) Hist_RingNoAnswer,
			SUM(H.Hist_QueueTime) / NullIf(COUNT(DISTINCT H.CallDate),0) Hist_QueueTime,
			SUM(H.Hist_CallsInGOS) / NullIf(COUNT(DISTINCT H.CallDate),0) Hist_CallsInGOS,
			COUNT(DISTINCT H.CallDate) as Hist_DayCount
		from #cte_hist H
		where H.timeStart = I.[timeStart] 
		AND H.[Team Type] = T.[Team Type]
	) H
	outer apply (
		select SUM(ghp.GOS_RT) / Nullif(SUM(CallDayCount),0) as Hist_GOS_RT
		from cte_hist_gos_days_periods ghp 
		where ghp.timeStart = i.timeStart
		and ghp.[Team Type] = T.[Team Type]
	) ghp 
	cross apply (
		select [Team Type], SUM(GOS) / COUNT(DISTINCT CallDate) as DayGOS
		from cte_hist_gos_days
		GROUP BY [Team Type]
	) x

	;with cte_data as (
		select 
			R.[timeStart] ,
			R.[timeEnd] ,
			R.[CallDate] ,
			R.[Team Type],
			R.[DayofWeek] ,
			R.[DayofWeekNum] ,
			R.[Live_CallsHandled] ,
			R.[Live_CallsPresented] ,
			R.[Live_CallsAbandoned] ,
			R.[Live_TalkTime] ,
			R.[Live_HoldTime] ,
			R.[Live_WorkTime] ,
			R.[Live_WrapUpTime] ,
			R.[Live_RingNoAnswer] ,
			R.[Live_QueueTime] ,
			R.[Live_CallsInGOS] ,
			R.[Hist_CallsHandled] ,
			R.[Hist_CallsPresented] ,
			R.[Hist_CallsAbandoned] ,
			R.[Hist_TalkTime] ,
			R.[Hist_HoldTime] ,
			R.[Hist_WorkTime] ,
			R.[Hist_WrapUpTime] ,
			R.[Hist_RingNoAnswer] ,
			R.[Hist_QueueTime] ,
			R.[Hist_CallsInGOS] ,
			R.[Hist_DayCount] ,
			R.[Include],
			R.[HistPeriodicGOS],
			R.[DayGOS],
			A.Live_CallsHandled_RT,
			A.Hist_CallsHandled_RT
		from #results R
		outer apply (
			select 
				SUM(Live_CallsHandled) Live_CallsHandled_RT,
				SUM(Hist_CallsHandled) Hist_CallsHandled_RT
			from #results R2
			where R2.timeStart <= R.TimeStart
			and R.[Team Type] = R2.[Team Type]
			) A
	)
	select
		R.[timeStart] ,
		R.[timeEnd] ,
		R.[CallDate] ,
		R.[Team Type],
		R.[DayofWeek] ,
		R.[DayofWeekNum] ,
		R.[Live_CallsHandled] ,
		R.[Live_CallsPresented] ,
		R.[Live_CallsAbandoned] ,
		R.[Live_TalkTime] ,
		R.[Live_HoldTime] ,
		R.[Live_WorkTime] ,
		R.[Live_WrapUpTime] ,
		R.[Live_RingNoAnswer] ,
		R.[Live_QueueTime] ,
		R.[Live_CallsInGOS] ,
		R.[Hist_CallsHandled] ,
		R.[Hist_CallsPresented] ,
		R.[Hist_CallsAbandoned] ,
		R.[Hist_TalkTime] ,
		R.[Hist_HoldTime] ,
		R.[Hist_WorkTime] ,
		R.[Hist_WrapUpTime] ,
		R.[Hist_RingNoAnswer] ,
		R.[Hist_QueueTime] ,
		R.[Hist_CallsInGOS] ,
		R.[Hist_DayCount] ,
		R.[Include] ,
		R.[HistPeriodicGOS],
		R.[DayGOS],
		R.Live_CallsHandled_RT,
		R.Hist_CallsHandled_RT,
		Trend,
		case
			when timeStart < @CurrentTime then [Live_CallsHandled_RT]
			when [Live_CallsHandled] > (PreviousCallsHandled + Trend) then [Live_CallsHandled_RT]
			else PreviousCallsHandled + Trend
		end ProjectedClosedCount
	from cte_data R
	outer apply (
		 select top 1
            p.Live_CallsHandled_RT PreviousCallsHandled
        from
            cte_data p
        where
            p.timeStart < R.timeStart and
            p.timeStart < @CurrentTime and
			r.[Team Type] = p.[Team Type]
        order by
            p.timeStart desc
	) p
	outer apply
    (
        select 
            sum(Hist_CallsHandled) Trend
        from
            cte_data p
        where
            p.timeEnd >= @CurrentTime and
            p.timeStart < R.timeStart and
			r.[Team Type] = p.[Team Type]
    ) v
	order by R.[timeStart]


END
GO
