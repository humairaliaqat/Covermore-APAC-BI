USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rpt_rpt1011_Dash_SalesByChannel]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec rpt_rpt1011_Dash_SalesByChannel '20180712', '20180712'

--select * from [uldwh02].[db-au-cba].dbo.vDateRange where DateRange like '%June%'

CREATE procedure [dbo].[rpt_rpt1011_Dash_SalesByChannel]
	--@ReportingPeriod varchar(50) = 'Yesterday',
	@StartDate date = null,
	@EndDate date = null
as 
begin
/****************************************************************************************************/
--  Name:           RPT1011 - CBA - Dashboard - Sales by Channel
--  Author:         Dane Murray
--  Date Created:   20180731
--  Description:    Data by day for Quote and Policies  
--
--  Parameters:     @ReportingPeriod: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--					@EndDate: if_User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--   
--  Change History: 20180523 - DM - Created 
--                  
/****************************************************************************************************/
	--DEBUG -- Uncomment to Debug
	--DECLARE 	
	--	@ReportingPeriod varchar(50) = 'Yesterday',
	--	@StartDate date = '20180712',
	--	@EndDate date = '20180712'

	SET NOCOUNT ON; 
	--Declare @Start date,
	--		@End date

	--select  @Start = R.StartDate,
	--		@End   = R.EndDate
	--from [uldwh02].[db-au-cba].dbo.vDateRange R
	--where DateRange = @ReportingPeriod

	--select	@Start = isNull(@Start, @StartDate),
	--		@End = isNull(@End, @EndDate)

	--if object_id('tempdb..#Periods') is not null
	--	drop table #Periods

	--;with DatePeriods as (
	--	select 'Current Period' as PeriodText, C.Date
	--	from [ULDWH02].[db-au-cba].dbo.Calendar C
	--	where C.Date between @Start and @End
	--	union all
	--	select 'Last Year at Current Period' as PeriodText, C.Date
	--	from [ULDWH02].[db-au-cba].dbo.Calendar C
	--	where C.Date between DateAdd(year, -1, @Start) and DateAdd(year, -1, @End)
	--)
	select *
	into #Periods
	from dbo.UDF_ReportingPeriods(@StartDate, @EndDate, DEFAULT)

	--select * from #Periods

	if object_id('tempdb..#Results') is not null
		drop table #Results

	select	
		C.PeriodText,
		C.Date,
		C.PeriodStartDate,
		C.PeriodEndDate,
		C.PeriodDateNum,
		po.SubGroupName, 
		po.OutletName, 
		po.OutletAlphaKey,
		pts.PolicyCount, 
		Q.ImpulseQuotes, 
		PQ.penguinQuotes,
		Q.ImpulseQuotes + PQ.penguinQuotes as QuoteCount
	INTO #Results
	from [db-au-cba].dbo.penOutlet po
	cross join #Periods c
	outer apply (
		select IsNull(SUM(BasePolicyCount),0) as PolicyCount
		from [db-au-cba].dbo.penPolicyTransSummary pts
		where pts.OutletAlphaKey = po.OutletAlphaKey
		and pts.PostingDate = C.Date
		) pts
	outer apply (
		select isNUll(COUNT(*),0) as ImpulseQuotes
		from [db-au-cba].dbo.impulse_Quotes x
		where po.AlphaCode = x.issuerAffiliateCode
		and QuoteDate = C.Date
		) q
	outer apply (
		select isNUll(COUNT(*),0) as penguinQuotes
		from [db-au-cba].[dbo].[penQuote] x
		where po.OutletAlphaKey = x.OutletAlphaKey
		and CAST(x.CreateDate as date) = C.Date
		) pq
	where po.GroupCode = 'MB'
	and po.OutletStatus = 'Current'

	select 
		'Summary' as DataType,
		PeriodText,
		PeriodStartDate,
		PeriodEndDate,
		OutletAlphaKey,
		--PeriodDateNum,
		SubGroupName,
		OutletName,
		SUM(PolicyCount) as PolicyCount,
		SUM(QuoteCount) as QuoteCount
	INTO #SummaryResults
	from #Results
	GROUP BY PeriodText,PeriodStartDate,PeriodEndDate,OutletAlphaKey, SubGroupName, OutletName

	--select * from #SummaryResults

	insert into #SummaryResults
	select 
		'Summary' DataType,
		'Current Period Variance' as PeriodText,
		null,
		null,
		R.OutletAlphaKey,
		--R.PeriodDateNum,
		R.SubGroupName, 
		R.OutletName, 
		SUM(R.PolicyCount) - SUM(R2.PolicyCount) as PolicyCount, 
		SUM(R.QuoteCount)  - SUM(R2.QuoteCount)  as QuoteCount
		--CASE WHEN SUM(R.QuoteCount) <> 0 THEN CAST(SUM(R.PolicyCount) as float) / CAST(SUM(R.QuoteCount) as float) ELSE 0 END - 
		--CASE WHEN SUM(R2.QuoteCount) <> 0 THEN CAST(SUM(R2.PolicyCount) as float) / CAST(SUM(R2.QuoteCount) as float) ELSE 0 END as ConversionRate
	from #Results R
	LEFT JOIN #Results R2 on R.PeriodDateNum = R2.PeriodDateNum AND R.OutletAlphaKey = R2.OutletAlphaKey
	where R.PeriodText = 'Current Period'
	AND R2.PeriodText = 'Last Year at Current Period'
	GROUP BY R.PeriodText, R.OutletAlphaKey, R.SubGroupName, R.OutletName

	select * from #SummaryResults

end
GO
