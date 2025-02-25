USE [db-au-actuary]
GO
/****** Object:  StoredProcedure [dbo].[sp_EarningPatternDataSetClaimCost]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_EarningPatternDataSetClaimCost]	@DateRange varchar(30),
															@StartDate varchar(10),
															@EndDate varchar(10)
as

SET NOCOUNT ON

										
/****************************************************************************************************/
--  Name:           sp_EarningPatternDataClaimCost
--  Author:         Saurabh Date
--  Date Created:   20170421
--  Description:    This stored procedure inserts data into [db-au-actuary].[dbo].[EarningPatternsDataSetClaimCost] using [db-au-actuary].dbo.DWHDataSet  policies as data source.
--
--  Parameters:     @ReportingPeriod: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--					@EndDate: if_User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--   
--  Change History: 20170421 - SD - Created
--		    20170427 - SD - Changing policy selection criteria, and apply distinct while selction of policies
--                  
/****************************************************************************************************/

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @DateRange = '_User Defined', @StartDate = '2012-06-01', @EndDate = '2012-06-05'
*/

declare @rptStartDate date
declare @rptEndDate date

--get reporting dates
if @DateRange = '_User Defined'
	select @rptStartDate = @StartDate,
		   @rptEndDate = @EndDate
else
	select @rptStartDate = StartDate, 
		   @rptEndDate = EndDate
	from [db-au-cmdwh].dbo.vDateRange
	where DateRange = @DateRange


IF OBJECT_ID('[db-au-workspace].dbo.tmp1') IS NOT NULL DROP TABLE [db-au-workspace].dbo.tmp1
--Creating temp table to store all the user required data along with pre and post departure percentile and claim cost values
select
	p.PolicyKey,
	p.[Issue Date],
	p.[Departure Date] [TripStart],
	p.[Return Date] [TripEnd],
	p.[Lead Time],
	p.[Trip Length],
	(datediff(day,p.[Issue Date],p.[Return Date])+1) [Trip Duration],
	'Pre Departure' [DepartureState],
	prepost.P01 [Departure State Percentage],
	prepost.ClaimCost [TotalClaimCost],
	(prepost.ClaimCost * prepost.P01) [DepartureStateClaimCost],
	Round(100.00/(Case When p.[Lead Time] <> 0 Then p.[Lead Time] else 1 End),2) [Departure per Day Percentage],
	(p.[Lead Time] / 10.00) [Departure days per pattern],
	pre.P01 [P01],
	pre.P02 [P02],
	pre.P03 [P03],
	pre.P04 [P04],
	pre.P05 [P05],
	pre.P06 [P06],
	pre.P07 [P07],
	pre.P08 [P08],
	pre.P09 [P09],
	pre.P10 [P10],
	(prepost.ClaimCost * prepost.P01 * pre.P01) [P01ClaimCost],
	(prepost.ClaimCost * prepost.P01 * pre.P02) [P02ClaimCost],
	(prepost.ClaimCost * prepost.P01 * pre.P03) [P03ClaimCost],
	(prepost.ClaimCost * prepost.P01 * pre.P04) [P04ClaimCost],
	(prepost.ClaimCost * prepost.P01 * pre.P05) [P05ClaimCost],
	(prepost.ClaimCost * prepost.P01 * pre.P06) [P06ClaimCost],
	(prepost.ClaimCost * prepost.P01 * pre.P07) [P07ClaimCost],
	(prepost.ClaimCost * prepost.P01 * pre.P08) [P08ClaimCost],
	(prepost.ClaimCost * prepost.P01 * pre.P09) [P09ClaimCost],
	(prepost.ClaimCost * prepost.P01 * pre.P10) [P10ClaimCost]
Into
	[db-au-workspace].dbo.tmp1
from
	[db-au-actuary].dbo.DWHDataSet p 
	inner join [db-au-actuary].dbo.EarningPatternDataMappingPP prepost
		on p.PolicyKey = prepost.PolicyKey
	inner join [db-au-actuary].dbo.EarningPatternDataMappingPre pre
		on p.PolicyKey = pre.PolicyKey
where
	p.[Issue Date] >= @rptStartDate and
	p.[Issue Date] < dateadd(d,1,@rptEndDate) and
	p.isParent = 1


union

select
	p.PolicyKey,
	p.[Issue Date],
	p.[Departure Date] [TripStart],
	p.[Return Date] [TripEnd],
	p.[Lead Time],
	p.[Trip Length],
	(datediff(day,p.[Issue Date],p.[Return Date])+1) [Trip Duration],
	'Post Departure' [DepartureState],
	prepost.P00 [Departure State Percentage],
	prepost.ClaimCost [TotalClaimCost],
	(prepost.ClaimCost * prepost.P00) [DepartureStateClaimCost],
	Round(100.00/((Case When p.[Trip Length] = 0 then 1
					    when p.[Trip Length] = -1 then 1
						else p.[Trip Length] 
					End) + 1), 2) [Departure per Day Percentage],
	p.[Trip Length] / 10.00 [Departure days per pattern],
	post.P01 [P01],
	post.P02 [P02],
	post.P03 [P03],
	post.P04 [P04],
	post.P05 [P05],
	post.P06 [P06],
	post.P07 [P07],
	post.P08 [P08],
	post.P09 [P09],
	post.P10 [P10],
	(prepost.ClaimCost * prepost.P00 * post.P01) [P01ClaimCost],
	(prepost.ClaimCost * prepost.P00 * post.P02) [P02ClaimCost],
	(prepost.ClaimCost * prepost.P00 * post.P03) [P03ClaimCost],
	(prepost.ClaimCost * prepost.P00 * post.P04) [P04ClaimCost],
	(prepost.ClaimCost * prepost.P00 * post.P05) [P05ClaimCost],
	(prepost.ClaimCost * prepost.P00 * post.P06) [P06ClaimCost],
	(prepost.ClaimCost * prepost.P00 * post.P07) [P07ClaimCost],
	(prepost.ClaimCost * prepost.P00 * post.P08) [P08ClaimCost],
	(prepost.ClaimCost * prepost.P00 * post.P09) [P09ClaimCost],
	(prepost.ClaimCost * prepost.P00 * post.P10) [P10ClaimCost]
from
	[db-au-actuary].dbo.DWHDataSet p 
	inner join [db-au-actuary].dbo.EarningPatternDataMappingPP prepost
		on p.PolicyKey = prepost.PolicyKey
	inner join [db-au-actuary].dbo.EarningPatternDataMappingPost post
		on p.PolicyKey = post.PolicyKey
where
	p.[Issue Date] >= @rptStartDate and
	p.[Issue Date] < dateadd(d,1,@rptEndDate) and
	p.isParent = 1


IF OBJECT_ID('[db-au-workspace].dbo.tmp_PreDepartureDates') IS NOT NULL DROP TABLE [db-au-workspace].dbo.tmp_PreDepartureDates

--Calculating Pre Departure dates
select
	t.policyKey,
	DateName(mm, c.date) [PreDepartureMonth],
	Month(c.Date) [PreDepartureMonthNumber],
	Year(c.Date) [PreDepartureYear],
	Round(Sum(t.[Departure per Day Percentage]),0) [Pct Value]
Into
	[db-au-workspace].dbo.tmp_PreDepartureDates
from
	[db-au-cmdwh].dbo.Calendar c
	inner join [db-au-workspace].dbo.tmp1 t
		on c.date >= Convert(date,t.[Issue Date]) and 
			c.date <= (Case When t.[Lead Time] = 0 Then Convert(date,t.[Issue Date]) Else DateAdd(Day, t.[Lead Time], Convert(date,t.[Issue Date])) End)
where
	t.DepartureState = 'Pre Departure'
Group BY
	t.policyKey,
	DateName(mm, c.date),
	Month(c.Date),
	Year(c.Date)
Order By
	Year(c.Date),
	Month(c.Date)


IF OBJECT_ID('[db-au-workspace].dbo.tmp_PostDepartureDates') IS NOT NULL DROP TABLE [db-au-workspace].dbo.tmp_PostDepartureDates

--Calculating Post Departure dates
select
	t.policyKey,
	DateName(mm, c.date) [PostDepartureMonth],
	Month(c.Date) [PostDepartureMonthNumber],
	Year(c.Date) [PostDepartureYear],
	Round(Sum(t.[Departure per Day Percentage]),0) [Pct Value]
Into
	[db-au-workspace].dbo.tmp_PostDepartureDates
from
	[db-au-cmdwh].dbo.Calendar c
	inner join [db-au-workspace].dbo.tmp1 t
		on c.date >= convert(date,t.TripStart) and c.date <= Convert(date,t.TripEnd)
where
	t.DepartureState = 'Post Departure'
Group BY
	t.policyKey,
	DateName(mm, c.date),
	Month(c.Date),
	Year(c.Date)
Order By
	Year(c.Date),
	Month(c.Date)


IF OBJECT_ID('[db-au-workspace].dbo.tmp_TempPreDepartureDates') IS NOT NULL DROP TABLE [db-au-workspace].dbo.tmp_TempPreDepartureDates

--Intermediate Pre Departure temp data to calculate Pattern End index
select
	predep1.PolicyKey,
	predep1.PreDepartureMonth, 
	predep1.PreDepartureMonthNumber, 
	predep1.PreDepartureYear, 
	predep1.[Pct Value],
	Sum(predep2.[Pct Value]) [PatternEndIndex]
Into
	[db-au-workspace].dbo.tmp_TempPreDepartureDates
from
	[db-au-workspace].dbo.tmp_PreDepartureDates predep1
	inner join [db-au-workspace].dbo.tmp_PreDepartureDates predep2 
		on convert(datetime, (predep1.PreDepartureMonth + ' ' + Convert(varchar, predep1.PreDepartureYear)), 120) >= convert(datetime, (predep2.PreDepartureMonth + ' ' + Convert(varchar, predep2.PreDepartureYear)), 120) and
		predep1.PolicyKey = predep2.PolicyKey
Group By 
	predep1.PolicyKey,
	predep1.PreDepartureMonth, 
	predep1.PreDepartureMonthNumber,
	predep1.PreDepartureYear, 
	predep1.[Pct Value]
order By 
	predep1.PreDepartureMonthNumber


IF OBJECT_ID('[db-au-workspace].dbo.tmp_TempPostDepartureDates') IS NOT NULL DROP TABLE [db-au-workspace].dbo.tmp_TempPostDepartureDates

--Intermediate Post Departure temp data to calculate Pattern End index
select
	postdep1.PolicyKey,
	postdep1.postDepartureMonth, 
	postdep1.postDepartureMonthNumber, 
	postdep1.postDepartureYear, 
	postdep1.[Pct Value],
	Sum(postdep2.[Pct Value]) [PatternEndIndex]
Into
	[db-au-workspace].dbo.tmp_TemppostDepartureDates
from
	[db-au-workspace].dbo.tmp_postDepartureDates postdep1
	inner join [db-au-workspace].dbo.tmp_postDepartureDates postdep2 
		on convert(datetime, (postdep1.postDepartureMonth + ' ' + Convert(varchar, postdep1.postDepartureYear)), 120) >= convert(datetime, (postdep2.postDepartureMonth + ' ' + Convert(varchar, postdep2.postDepartureYear)), 120) and
		postdep1.PolicyKey = postdep2.PolicyKey
Group By 
	postdep1.PolicyKey,
	postdep1.postDepartureMonth, 
	postdep1.postDepartureMonthNumber,
	postdep1.postDepartureYear, 
	postdep1.[Pct Value]
order By 
	postdep1.postDepartureMonthNumber


IF OBJECT_ID('[db-au-workspace].dbo.tmp_PreDeparturePatternRange') IS NOT NULL DROP TABLE [db-au-workspace].dbo.tmp_PreDeparturePatternRange

--Finding Pre Departure pattern index range for each record
select 
	tpred.PolicyKey,
	tpred.PreDepartureMonth,
	tpred.PreDepartureMonthNumber,
	tpred.PreDepartureYear,
	Case
		When (tpred.PatternEndIndex - tpred.[Pct Value]) = 0 Then  0
		Else (tpred.PatternEndIndex - tpred.[Pct Value]) + 1
	End [PatternStartIndex],
	Case
		When tpred.PreDepartureMonthNUmber = Month(tt.TripStart)
			and tpred.PreDepartureYear = Year(tt.TripStart)
		Then 100
		Else PatternEndIndex
	End [PatternEndIndex]
Into
	[db-au-workspace].dbo.tmp_PreDeparturePatternRange
from 
	[db-au-workspace].dbo.tmp_TempPreDepartureDates tpred
	inner join [db-au-workspace].dbo.tmp1 tt
		on tpred.PolicyKey = tt.PolicyKey
where 
	tt.[DepartureState] = 'Pre Departure'
order by 
	tpred.PolicyKey,
	tpred.PreDepartureMonthNumber,
	tpred.PreDepartureYear


IF OBJECT_ID('[db-au-workspace].dbo.tmp_postDeparturePatternRange') IS NOT NULL DROP TABLE [db-au-workspace].dbo.tmp_postDeparturePatternRange

--Finding post Departure pattern index range for each record
select 
	tpostd.PolicyKey,
	tpostd.postDepartureMonth,
	tpostd.postDepartureMonthNumber,
	tpostd.postDepartureYear,
	Case
		When (tpostd.PatternEndIndex - tpostd.[Pct Value]) = 0 Then  0
		Else (tpostd.PatternEndIndex - tpostd.[Pct Value]) + 1
	End [PatternStartIndex],
	Case
		When tpostd.postDepartureMonthNUmber = Month(tt.TripEnd)
			and tpostd.postDepartureYear = Year(tt.TripEnd)
		Then 100
		Else PatternEndIndex
	End [PatternEndIndex]
Into
	[db-au-workspace].dbo.tmp_postDeparturePatternRange
from 
	[db-au-workspace].dbo.tmp_TemppostDepartureDates tpostd
	inner join [db-au-workspace].dbo.tmp1 tt
		on tpostd.PolicyKey = tt.PolicyKey
where 
	tt.[DepartureState] = 'post Departure'
order by 
	tpostd.PolicyKey,
	tpostd.postDepartureMonthNumber,
	tpostd.postDepartureYear


--create final table and indices
if object_id('[db-au-actuary].dbo.EarningPatternDataClaimCost') is null
begin
	create table [db-au-actuary].dbo.EarningPatternDataClaimCost
	(
		PolicyKey varchar(41) null,
		DepartureState varchar(20) null,
		[Month] datetime null,
		ClaimCost float null
	)
	create clustered index idx_EarningPatternDataClaimCost_PolicyKey on [db-au-actuary].dbo.EarningPatternDataClaimCost(PolicyKey)	
	create nonclustered index idx_EarningPatternDataClaimCost_Month on [db-au-actuary].dbo.EarningPatternDataClaimCost([Month])
end
--else
--	delete [db-au-actuary].dbo.EarningPatternDataClaimCost
--	where [Month] >= @rptStartDate and [Month] < dateadd(d,1,@rptEndDate)


--Final results combining pre and post departure data
insert [db-au-actuary].[dbo].[EarningPatternDataClaimCost] with(tablockx)
(
	[PolicyKey],
	[DepartureState],
	[Month],
	[ClaimCost]
)
select
	preclaim.PolicyKey [PolicyKey],
	'Pre Departure' [DepartureState],
	convert(datetime, (preclaim.PreDepartureMonth + ' ' + convert(varchar,preclaim.PreDepartureYear)), 120) [Month],
	(
		Case when 1 >= PatternStartIndex and 1 <= PatternEndIndex Then (p01ClaimCost/10) Else 0 End +
		Case when 2 >= PatternStartIndex and 2 <= PatternEndIndex Then (p01ClaimCost/10) Else 0 End +
		Case when 3 >= PatternStartIndex and 3 <= PatternEndIndex Then (p01ClaimCost/10) Else 0 End +
		Case when 4 >= PatternStartIndex and 4 <= PatternEndIndex Then (p01ClaimCost/10) Else 0 End +
		Case when 5 >= PatternStartIndex and 5 <= PatternEndIndex Then (p01ClaimCost/10) Else 0 End +
		Case when 6 >= PatternStartIndex and 6 <= PatternEndIndex Then (p01ClaimCost/10) Else 0 End +
		Case when 7 >= PatternStartIndex and 7 <= PatternEndIndex Then (p01ClaimCost/10) Else 0 End +
		Case when 8 >= PatternStartIndex and 8 <= PatternEndIndex Then (p01ClaimCost/10) Else 0 End +
		Case when 9 >= PatternStartIndex and 9 <= PatternEndIndex Then (p01ClaimCost/10) Else 0 End +
		Case when 10 >= PatternStartIndex and 10 <= PatternEndIndex Then (p01ClaimCost/10) Else 0 End +
		Case when 11 >= PatternStartIndex and 11 <= PatternEndIndex Then (p02ClaimCost/10) Else 0 End +
		Case when 12 >= PatternStartIndex and 12 <= PatternEndIndex Then (p02ClaimCost/10) Else 0 End +
		Case when 13 >= PatternStartIndex and 13 <= PatternEndIndex Then (p02ClaimCost/10) Else 0 End +
		Case when 14 >= PatternStartIndex and 14 <= PatternEndIndex Then (p02ClaimCost/10) Else 0 End +
		Case when 15 >= PatternStartIndex and 15 <= PatternEndIndex Then (p02ClaimCost/10) Else 0 End +
		Case when 16 >= PatternStartIndex and 16 <= PatternEndIndex Then (p02ClaimCost/10) Else 0 End +
		Case when 17 >= PatternStartIndex and 17 <= PatternEndIndex Then (p02ClaimCost/10) Else 0 End +
		Case when 18 >= PatternStartIndex and 18 <= PatternEndIndex Then (p02ClaimCost/10) Else 0 End +
		Case when 19 >= PatternStartIndex and 19 <= PatternEndIndex Then (p02ClaimCost/10) Else 0 End +
		Case when 20 >= PatternStartIndex and 20 <= PatternEndIndex Then (p02ClaimCost/10) Else 0 End +
		Case when 21 >= PatternStartIndex and 21 <= PatternEndIndex Then (p03ClaimCost/10) Else 0 End +
		Case when 22 >= PatternStartIndex and 22 <= PatternEndIndex Then (p03ClaimCost/10) Else 0 End +
		Case when 23 >= PatternStartIndex and 23 <= PatternEndIndex Then (p03ClaimCost/10) Else 0 End +
		Case when 24 >= PatternStartIndex and 24 <= PatternEndIndex Then (p03ClaimCost/10) Else 0 End +
		Case when 25 >= PatternStartIndex and 25 <= PatternEndIndex Then (p03ClaimCost/10) Else 0 End +
		Case when 26 >= PatternStartIndex and 26 <= PatternEndIndex Then (p03ClaimCost/10) Else 0 End +
		Case when 27 >= PatternStartIndex and 27 <= PatternEndIndex Then (p03ClaimCost/10) Else 0 End +
		Case when 28 >= PatternStartIndex and 28 <= PatternEndIndex Then (p03ClaimCost/10) Else 0 End +
		Case when 29 >= PatternStartIndex and 29 <= PatternEndIndex Then (p03ClaimCost/10) Else 0 End +
		Case when 30 >= PatternStartIndex and 30 <= PatternEndIndex Then (p03ClaimCost/10) Else 0 End +
		Case when 31 >= PatternStartIndex and 31 <= PatternEndIndex Then (p04ClaimCost/10) Else 0 End +
		Case when 32 >= PatternStartIndex and 32 <= PatternEndIndex Then (p04ClaimCost/10) Else 0 End +
		Case when 33 >= PatternStartIndex and 33 <= PatternEndIndex Then (p04ClaimCost/10) Else 0 End +
		Case when 34 >= PatternStartIndex and 34 <= PatternEndIndex Then (p04ClaimCost/10) Else 0 End +
		Case when 35 >= PatternStartIndex and 35 <= PatternEndIndex Then (p04ClaimCost/10) Else 0 End +
		Case when 36 >= PatternStartIndex and 36 <= PatternEndIndex Then (p04ClaimCost/10) Else 0 End +
		Case when 37 >= PatternStartIndex and 37 <= PatternEndIndex Then (p04ClaimCost/10) Else 0 End +
		Case when 38 >= PatternStartIndex and 38 <= PatternEndIndex Then (p04ClaimCost/10) Else 0 End +
		Case when 39 >= PatternStartIndex and 39 <= PatternEndIndex Then (p04ClaimCost/10) Else 0 End +
		Case when 40 >= PatternStartIndex and 40 <= PatternEndIndex Then (p04ClaimCost/10) Else 0 End +
		Case when 41 >= PatternStartIndex and 41 <= PatternEndIndex Then (p05ClaimCost/10) Else 0 End +
		Case when 42 >= PatternStartIndex and 42 <= PatternEndIndex Then (p05ClaimCost/10) Else 0 End +
		Case when 43 >= PatternStartIndex and 43 <= PatternEndIndex Then (p05ClaimCost/10) Else 0 End +
		Case when 44 >= PatternStartIndex and 44 <= PatternEndIndex Then (p05ClaimCost/10) Else 0 End +
		Case when 45 >= PatternStartIndex and 45 <= PatternEndIndex Then (p05ClaimCost/10) Else 0 End +
		Case when 46 >= PatternStartIndex and 46 <= PatternEndIndex Then (p05ClaimCost/10) Else 0 End +
		Case when 47 >= PatternStartIndex and 47 <= PatternEndIndex Then (p05ClaimCost/10) Else 0 End +
		Case when 48 >= PatternStartIndex and 48 <= PatternEndIndex Then (p05ClaimCost/10) Else 0 End +
		Case when 49 >= PatternStartIndex and 49 <= PatternEndIndex Then (p05ClaimCost/10) Else 0 End +
		Case when 50 >= PatternStartIndex and 50 <= PatternEndIndex Then (p05ClaimCost/10) Else 0 End +
		Case when 51 >= PatternStartIndex and 51 <= PatternEndIndex Then (p06ClaimCost/10) Else 0 End +
		Case when 52 >= PatternStartIndex and 52 <= PatternEndIndex Then (p06ClaimCost/10) Else 0 End +
		Case when 53 >= PatternStartIndex and 53 <= PatternEndIndex Then (p06ClaimCost/10) Else 0 End +
		Case when 54 >= PatternStartIndex and 54 <= PatternEndIndex Then (p06ClaimCost/10) Else 0 End +
		Case when 55 >= PatternStartIndex and 55 <= PatternEndIndex Then (p06ClaimCost/10) Else 0 End +
		Case when 56 >= PatternStartIndex and 56 <= PatternEndIndex Then (p06ClaimCost/10) Else 0 End +
		Case when 57 >= PatternStartIndex and 57 <= PatternEndIndex Then (p06ClaimCost/10) Else 0 End +
		Case when 58 >= PatternStartIndex and 58 <= PatternEndIndex Then (p06ClaimCost/10) Else 0 End +
		Case when 59 >= PatternStartIndex and 59 <= PatternEndIndex Then (p06ClaimCost/10) Else 0 End +
		Case when 60 >= PatternStartIndex and 60 <= PatternEndIndex Then (p06ClaimCost/10) Else 0 End +
		Case when 61 >= PatternStartIndex and 61 <= PatternEndIndex Then (p07ClaimCost/10) Else 0 End +
		Case when 62 >= PatternStartIndex and 62 <= PatternEndIndex Then (p07ClaimCost/10) Else 0 End +
		Case when 63 >= PatternStartIndex and 63 <= PatternEndIndex Then (p07ClaimCost/10) Else 0 End +
		Case when 64 >= PatternStartIndex and 64 <= PatternEndIndex Then (p07ClaimCost/10) Else 0 End +
		Case when 65 >= PatternStartIndex and 65 <= PatternEndIndex Then (p07ClaimCost/10) Else 0 End +
		Case when 66 >= PatternStartIndex and 66 <= PatternEndIndex Then (p07ClaimCost/10) Else 0 End +
		Case when 67 >= PatternStartIndex and 67 <= PatternEndIndex Then (p07ClaimCost/10) Else 0 End +
		Case when 68 >= PatternStartIndex and 68 <= PatternEndIndex Then (p07ClaimCost/10) Else 0 End +
		Case when 69 >= PatternStartIndex and 69 <= PatternEndIndex Then (p07ClaimCost/10) Else 0 End +
		Case when 70 >= PatternStartIndex and 70 <= PatternEndIndex Then (p07ClaimCost/10) Else 0 End +
		Case when 71 >= PatternStartIndex and 71 <= PatternEndIndex Then (p08ClaimCost/10) Else 0 End +
		Case when 72 >= PatternStartIndex and 72 <= PatternEndIndex Then (p08ClaimCost/10) Else 0 End +
		Case when 73 >= PatternStartIndex and 73 <= PatternEndIndex Then (p08ClaimCost/10) Else 0 End +
		Case when 74 >= PatternStartIndex and 74 <= PatternEndIndex Then (p08ClaimCost/10) Else 0 End +
		Case when 75 >= PatternStartIndex and 75 <= PatternEndIndex Then (p08ClaimCost/10) Else 0 End +
		Case when 76 >= PatternStartIndex and 76 <= PatternEndIndex Then (p08ClaimCost/10) Else 0 End +
		Case when 77 >= PatternStartIndex and 77 <= PatternEndIndex Then (p08ClaimCost/10) Else 0 End +
		Case when 78 >= PatternStartIndex and 78 <= PatternEndIndex Then (p08ClaimCost/10) Else 0 End +
		Case when 79 >= PatternStartIndex and 79 <= PatternEndIndex Then (p08ClaimCost/10) Else 0 End +
		Case when 80 >= PatternStartIndex and 80 <= PatternEndIndex Then (p08ClaimCost/10) Else 0 End +
		Case when 81 >= PatternStartIndex and 81 <= PatternEndIndex Then (p09ClaimCost/10) Else 0 End +
		Case when 82 >= PatternStartIndex and 82 <= PatternEndIndex Then (p09ClaimCost/10) Else 0 End +
		Case when 83 >= PatternStartIndex and 83 <= PatternEndIndex Then (p09ClaimCost/10) Else 0 End +
		Case when 84 >= PatternStartIndex and 84 <= PatternEndIndex Then (p09ClaimCost/10) Else 0 End +
		Case when 85 >= PatternStartIndex and 85 <= PatternEndIndex Then (p09ClaimCost/10) Else 0 End +
		Case when 86 >= PatternStartIndex and 86 <= PatternEndIndex Then (p09ClaimCost/10) Else 0 End +
		Case when 87 >= PatternStartIndex and 87 <= PatternEndIndex Then (p09ClaimCost/10) Else 0 End +
		Case when 88 >= PatternStartIndex and 88 <= PatternEndIndex Then (p09ClaimCost/10) Else 0 End +
		Case when 89 >= PatternStartIndex and 89 <= PatternEndIndex Then (p09ClaimCost/10) Else 0 End +
		Case when 90 >= PatternStartIndex and 90 <= PatternEndIndex Then (p09ClaimCost/10) Else 0 End +
		Case when 91 >= PatternStartIndex and 91 <= PatternEndIndex Then (p10ClaimCost/10) Else 0 End +
		Case when 92 >= PatternStartIndex and 92 <= PatternEndIndex Then (p10ClaimCost/10) Else 0 End +
		Case when 93 >= PatternStartIndex and 93 <= PatternEndIndex Then (p10ClaimCost/10) Else 0 End +
		Case when 94 >= PatternStartIndex and 94 <= PatternEndIndex Then (p10ClaimCost/10) Else 0 End +
		Case when 95 >= PatternStartIndex and 95 <= PatternEndIndex Then (p10ClaimCost/10) Else 0 End +
		Case when 96 >= PatternStartIndex and 96 <= PatternEndIndex Then (p10ClaimCost/10) Else 0 End +
		Case when 97 >= PatternStartIndex and 97 <= PatternEndIndex Then (p10ClaimCost/10) Else 0 End +
		Case when 98 >= PatternStartIndex and 98 <= PatternEndIndex Then (p10ClaimCost/10) Else 0 End +
		Case when 99 >= PatternStartIndex and 99 <= PatternEndIndex Then (p10ClaimCost/10) Else 0 End +
		Case when 100 >= PatternStartIndex and 100 <= PatternEndIndex Then (p10ClaimCost/10) Else 0 End
		)
	[ClaimCost]
From
	[db-au-workspace].dbo.tmp_PreDeparturePatternRange preclaim
	inner join [db-au-workspace].dbo.tmp1 tpre
		on preclaim.Policykey = tpre.PolicyKey and tpre.DepartureState = 'Pre Departure'
		
Union

select
	postclaim.PolicyKey [PolicyKey],
	'Post Departure' [DepartureState],
	convert(datetime, (postclaim.PostDepartureMonth + ' ' + convert(varchar,postclaim.PostDepartureYear)), 120) [Month],
	(
		Case when 1 >= PatternStartIndex and 1 <= PatternEndIndex Then (p01ClaimCost/10) Else 0 End +
		Case when 2 >= PatternStartIndex and 2 <= PatternEndIndex Then (p01ClaimCost/10) Else 0 End +
		Case when 3 >= PatternStartIndex and 3 <= PatternEndIndex Then (p01ClaimCost/10) Else 0 End +
		Case when 4 >= PatternStartIndex and 4 <= PatternEndIndex Then (p01ClaimCost/10) Else 0 End +
		Case when 5 >= PatternStartIndex and 5 <= PatternEndIndex Then (p01ClaimCost/10) Else 0 End +
		Case when 6 >= PatternStartIndex and 6 <= PatternEndIndex Then (p01ClaimCost/10) Else 0 End +
		Case when 7 >= PatternStartIndex and 7 <= PatternEndIndex Then (p01ClaimCost/10) Else 0 End +
		Case when 8 >= PatternStartIndex and 8 <= PatternEndIndex Then (p01ClaimCost/10) Else 0 End +
		Case when 9 >= PatternStartIndex and 9 <= PatternEndIndex Then (p01ClaimCost/10) Else 0 End +
		Case when 10 >= PatternStartIndex and 10 <= PatternEndIndex Then (p01ClaimCost/10) Else 0 End +
		Case when 11 >= PatternStartIndex and 11 <= PatternEndIndex Then (p02ClaimCost/10) Else 0 End +
		Case when 12 >= PatternStartIndex and 12 <= PatternEndIndex Then (p02ClaimCost/10) Else 0 End +
		Case when 13 >= PatternStartIndex and 13 <= PatternEndIndex Then (p02ClaimCost/10) Else 0 End +
		Case when 14 >= PatternStartIndex and 14 <= PatternEndIndex Then (p02ClaimCost/10) Else 0 End +
		Case when 15 >= PatternStartIndex and 15 <= PatternEndIndex Then (p02ClaimCost/10) Else 0 End +
		Case when 16 >= PatternStartIndex and 16 <= PatternEndIndex Then (p02ClaimCost/10) Else 0 End +
		Case when 17 >= PatternStartIndex and 17 <= PatternEndIndex Then (p02ClaimCost/10) Else 0 End +
		Case when 18 >= PatternStartIndex and 18 <= PatternEndIndex Then (p02ClaimCost/10) Else 0 End +
		Case when 19 >= PatternStartIndex and 19 <= PatternEndIndex Then (p02ClaimCost/10) Else 0 End +
		Case when 20 >= PatternStartIndex and 20 <= PatternEndIndex Then (p02ClaimCost/10) Else 0 End +
		Case when 21 >= PatternStartIndex and 21 <= PatternEndIndex Then (p03ClaimCost/10) Else 0 End +
		Case when 22 >= PatternStartIndex and 22 <= PatternEndIndex Then (p03ClaimCost/10) Else 0 End +
		Case when 23 >= PatternStartIndex and 23 <= PatternEndIndex Then (p03ClaimCost/10) Else 0 End +
		Case when 24 >= PatternStartIndex and 24 <= PatternEndIndex Then (p03ClaimCost/10) Else 0 End +
		Case when 25 >= PatternStartIndex and 25 <= PatternEndIndex Then (p03ClaimCost/10) Else 0 End +
		Case when 26 >= PatternStartIndex and 26 <= PatternEndIndex Then (p03ClaimCost/10) Else 0 End +
		Case when 27 >= PatternStartIndex and 27 <= PatternEndIndex Then (p03ClaimCost/10) Else 0 End +
		Case when 28 >= PatternStartIndex and 28 <= PatternEndIndex Then (p03ClaimCost/10) Else 0 End +
		Case when 29 >= PatternStartIndex and 29 <= PatternEndIndex Then (p03ClaimCost/10) Else 0 End +
		Case when 30 >= PatternStartIndex and 30 <= PatternEndIndex Then (p03ClaimCost/10) Else 0 End +
		Case when 31 >= PatternStartIndex and 31 <= PatternEndIndex Then (p04ClaimCost/10) Else 0 End +
		Case when 32 >= PatternStartIndex and 32 <= PatternEndIndex Then (p04ClaimCost/10) Else 0 End +
		Case when 33 >= PatternStartIndex and 33 <= PatternEndIndex Then (p04ClaimCost/10) Else 0 End +
		Case when 34 >= PatternStartIndex and 34 <= PatternEndIndex Then (p04ClaimCost/10) Else 0 End +
		Case when 35 >= PatternStartIndex and 35 <= PatternEndIndex Then (p04ClaimCost/10) Else 0 End +
		Case when 36 >= PatternStartIndex and 36 <= PatternEndIndex Then (p04ClaimCost/10) Else 0 End +
		Case when 37 >= PatternStartIndex and 37 <= PatternEndIndex Then (p04ClaimCost/10) Else 0 End +
		Case when 38 >= PatternStartIndex and 38 <= PatternEndIndex Then (p04ClaimCost/10) Else 0 End +
		Case when 39 >= PatternStartIndex and 39 <= PatternEndIndex Then (p04ClaimCost/10) Else 0 End +
		Case when 40 >= PatternStartIndex and 40 <= PatternEndIndex Then (p04ClaimCost/10) Else 0 End +
		Case when 41 >= PatternStartIndex and 41 <= PatternEndIndex Then (p05ClaimCost/10) Else 0 End +
		Case when 42 >= PatternStartIndex and 42 <= PatternEndIndex Then (p05ClaimCost/10) Else 0 End +
		Case when 43 >= PatternStartIndex and 43 <= PatternEndIndex Then (p05ClaimCost/10) Else 0 End +
		Case when 44 >= PatternStartIndex and 44 <= PatternEndIndex Then (p05ClaimCost/10) Else 0 End +
		Case when 45 >= PatternStartIndex and 45 <= PatternEndIndex Then (p05ClaimCost/10) Else 0 End +
		Case when 46 >= PatternStartIndex and 46 <= PatternEndIndex Then (p05ClaimCost/10) Else 0 End +
		Case when 47 >= PatternStartIndex and 47 <= PatternEndIndex Then (p05ClaimCost/10) Else 0 End +
		Case when 48 >= PatternStartIndex and 48 <= PatternEndIndex Then (p05ClaimCost/10) Else 0 End +
		Case when 49 >= PatternStartIndex and 49 <= PatternEndIndex Then (p05ClaimCost/10) Else 0 End +
		Case when 50 >= PatternStartIndex and 50 <= PatternEndIndex Then (p05ClaimCost/10) Else 0 End +
		Case when 51 >= PatternStartIndex and 51 <= PatternEndIndex Then (p06ClaimCost/10) Else 0 End +
		Case when 52 >= PatternStartIndex and 52 <= PatternEndIndex Then (p06ClaimCost/10) Else 0 End +
		Case when 53 >= PatternStartIndex and 53 <= PatternEndIndex Then (p06ClaimCost/10) Else 0 End +
		Case when 54 >= PatternStartIndex and 54 <= PatternEndIndex Then (p06ClaimCost/10) Else 0 End +
		Case when 55 >= PatternStartIndex and 55 <= PatternEndIndex Then (p06ClaimCost/10) Else 0 End +
		Case when 56 >= PatternStartIndex and 56 <= PatternEndIndex Then (p06ClaimCost/10) Else 0 End +
		Case when 57 >= PatternStartIndex and 57 <= PatternEndIndex Then (p06ClaimCost/10) Else 0 End +
		Case when 58 >= PatternStartIndex and 58 <= PatternEndIndex Then (p06ClaimCost/10) Else 0 End +
		Case when 59 >= PatternStartIndex and 59 <= PatternEndIndex Then (p06ClaimCost/10) Else 0 End +
		Case when 60 >= PatternStartIndex and 60 <= PatternEndIndex Then (p06ClaimCost/10) Else 0 End +
		Case when 61 >= PatternStartIndex and 61 <= PatternEndIndex Then (p07ClaimCost/10) Else 0 End +
		Case when 62 >= PatternStartIndex and 62 <= PatternEndIndex Then (p07ClaimCost/10) Else 0 End +
		Case when 63 >= PatternStartIndex and 63 <= PatternEndIndex Then (p07ClaimCost/10) Else 0 End +
		Case when 64 >= PatternStartIndex and 64 <= PatternEndIndex Then (p07ClaimCost/10) Else 0 End +
		Case when 65 >= PatternStartIndex and 65 <= PatternEndIndex Then (p07ClaimCost/10) Else 0 End +
		Case when 66 >= PatternStartIndex and 66 <= PatternEndIndex Then (p07ClaimCost/10) Else 0 End +
		Case when 67 >= PatternStartIndex and 67 <= PatternEndIndex Then (p07ClaimCost/10) Else 0 End +
		Case when 68 >= PatternStartIndex and 68 <= PatternEndIndex Then (p07ClaimCost/10) Else 0 End +
		Case when 69 >= PatternStartIndex and 69 <= PatternEndIndex Then (p07ClaimCost/10) Else 0 End +
		Case when 70 >= PatternStartIndex and 70 <= PatternEndIndex Then (p07ClaimCost/10) Else 0 End +
		Case when 71 >= PatternStartIndex and 71 <= PatternEndIndex Then (p08ClaimCost/10) Else 0 End +
		Case when 72 >= PatternStartIndex and 72 <= PatternEndIndex Then (p08ClaimCost/10) Else 0 End +
		Case when 73 >= PatternStartIndex and 73 <= PatternEndIndex Then (p08ClaimCost/10) Else 0 End +
		Case when 74 >= PatternStartIndex and 74 <= PatternEndIndex Then (p08ClaimCost/10) Else 0 End +
		Case when 75 >= PatternStartIndex and 75 <= PatternEndIndex Then (p08ClaimCost/10) Else 0 End +
		Case when 76 >= PatternStartIndex and 76 <= PatternEndIndex Then (p08ClaimCost/10) Else 0 End +
		Case when 77 >= PatternStartIndex and 77 <= PatternEndIndex Then (p08ClaimCost/10) Else 0 End +
		Case when 78 >= PatternStartIndex and 78 <= PatternEndIndex Then (p08ClaimCost/10) Else 0 End +
		Case when 79 >= PatternStartIndex and 79 <= PatternEndIndex Then (p08ClaimCost/10) Else 0 End +
		Case when 80 >= PatternStartIndex and 80 <= PatternEndIndex Then (p08ClaimCost/10) Else 0 End +
		Case when 81 >= PatternStartIndex and 81 <= PatternEndIndex Then (p09ClaimCost/10) Else 0 End +
		Case when 82 >= PatternStartIndex and 82 <= PatternEndIndex Then (p09ClaimCost/10) Else 0 End +
		Case when 83 >= PatternStartIndex and 83 <= PatternEndIndex Then (p09ClaimCost/10) Else 0 End +
		Case when 84 >= PatternStartIndex and 84 <= PatternEndIndex Then (p09ClaimCost/10) Else 0 End +
		Case when 85 >= PatternStartIndex and 85 <= PatternEndIndex Then (p09ClaimCost/10) Else 0 End +
		Case when 86 >= PatternStartIndex and 86 <= PatternEndIndex Then (p09ClaimCost/10) Else 0 End +
		Case when 87 >= PatternStartIndex and 87 <= PatternEndIndex Then (p09ClaimCost/10) Else 0 End +
		Case when 88 >= PatternStartIndex and 88 <= PatternEndIndex Then (p09ClaimCost/10) Else 0 End +
		Case when 89 >= PatternStartIndex and 89 <= PatternEndIndex Then (p09ClaimCost/10) Else 0 End +
		Case when 90 >= PatternStartIndex and 90 <= PatternEndIndex Then (p09ClaimCost/10) Else 0 End +
		Case when 91 >= PatternStartIndex and 91 <= PatternEndIndex Then (p10ClaimCost/10) Else 0 End +
		Case when 92 >= PatternStartIndex and 92 <= PatternEndIndex Then (p10ClaimCost/10) Else 0 End +
		Case when 93 >= PatternStartIndex and 93 <= PatternEndIndex Then (p10ClaimCost/10) Else 0 End +
		Case when 94 >= PatternStartIndex and 94 <= PatternEndIndex Then (p10ClaimCost/10) Else 0 End +
		Case when 95 >= PatternStartIndex and 95 <= PatternEndIndex Then (p10ClaimCost/10) Else 0 End +
		Case when 96 >= PatternStartIndex and 96 <= PatternEndIndex Then (p10ClaimCost/10) Else 0 End +
		Case when 97 >= PatternStartIndex and 97 <= PatternEndIndex Then (p10ClaimCost/10) Else 0 End +
		Case when 98 >= PatternStartIndex and 98 <= PatternEndIndex Then (p10ClaimCost/10) Else 0 End +
		Case when 99 >= PatternStartIndex and 99 <= PatternEndIndex Then (p10ClaimCost/10) Else 0 End +
		Case when 100 >= PatternStartIndex and 100 <= PatternEndIndex Then (p10ClaimCost/10) Else 0 End
		)
	[ClaimCost]
From
	[db-au-workspace].dbo.tmp_PostDeparturePatternRange postclaim
	inner join [db-au-workspace].dbo.tmp1 tpost
		on postclaim.Policykey = tpost.PolicyKey and tpost.DepartureState = 'Post Departure'


--drop temp tables
drop table [db-au-workspace].dbo.tmp1
drop table [db-au-workspace].dbo.tmp_PreDepartureDates
drop table [db-au-workspace].dbo.tmp_PostDepartureDates
drop table [db-au-workspace].dbo.tmp_TempPreDepartureDates
drop table [db-au-workspace].dbo.tmp_TempPostDepartureDates
drop table [db-au-workspace].dbo.tmp_PreDeparturePatternRange
drop table [db-au-workspace].dbo.tmp_postDeparturePatternRange
GO
