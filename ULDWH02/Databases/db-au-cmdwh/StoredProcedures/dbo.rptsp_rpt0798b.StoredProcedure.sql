USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0798b]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0798b]	@DateRange varchar(30),
					@StartDate datetime,
					@EndDate datetime
as

SET NOCOUNT ON


/****************************************************************************************************/
--	Name:			dbo.rptsp_rpt0798b
--	Author:			Linus Tor
--	Date Created:	20160804
--	Description:	This stored procedure returns salesforce call summary by State & JV split
--					
--	Parameters:		@DateRange: standard date range or _User Defined
--					@StartDate: valid date value. Format: YYYY-MM-DD (eg. 2016-06-01)
--					@EndDate: valid date value. Format: YYYY-MM-DD (eg. 2016-06-01)
--	
--	Change History:	20160804 - LT - Created
--					20160927 - SD - Included additional calculated columns for YTD and PYYTD Actula Calls and Actual Hours
--					20160928 - SD - Include BDM Level metrics
--					20161028 - LT - Changed AccountID linkage to AgencyID linkage. AgencyID is the correct linkage to use.
--									Amended Sales Call (visit) category definition
--	
/****************************************************************************************************/

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate datetime
declare @EndDate datetime
select @DateRange = 'Last Month', @StartDate = null, @EndDate = null
*/

declare @rptStartDateCY datetime
declare @rptEndDateCY datetime
declare @rptStartDatePY datetime
declare @rptEndDatePY datetime

declare @StartDateCY datetime, @EndDateCY datetime
declare @StartDatePY datetime, @EndDatePY datetime
declare @StartDatePY2 datetime, @EndDatePY2 datetime
declare @StartDateCQ datetime, @EndDateCQ datetime
declare @StartDatePQ datetime, @EndDatePQ datetime
declare @FiscalYear int

/* get reporting dates */
if @DateRange = '_User Defined'
begin
    select 
        @rptStartDateCY = convert(smalldatetime,@StartDate),
        @rptEndDateCY = convert(smalldatetime,@EndDate)
end            
else
    select 
        @rptStartDateCY = StartDate, 
        @rptEndDateCY = EndDate
    from 
        vDateRange
    where 
        DateRange = @DateRange

select
	@rptStartDatePY = dateadd(year,-1,@rptStartDateCY),
	@rptEndDatePY = dateadd(year,-1,@rptEndDateCY)

select @FiscalYear = max(CurFiscalYearNum)
from Calendar
where Date between @rptStartDateCY and @rptEndDateCY

/* get YTD dates */
select @StartDateCY = max(CurFiscalYearStart), @EndDateCY = @rptEndDateCY
from Calendar
where [Date] between @rptStartDateCY and @rptEndDateCY

select @StartDatePY = dateadd(year,-1,@StartDateCY), @EndDatePY = dateadd(year,-1,@EndDateCY)
select @StartDatePY2 = dateadd(year,-2,@StartDateCY), @EndDatePY2 = dateadd(year,-2,@EndDateCY)

/* get Quarter dates */
select @StartDateCQ = max(LastQuarterStart), @EndDateCQ = max(LastQuarterEnd)
from Calendar
where [Date] between @rptStartDateCY and @rptEndDateCY

select @StartDatePQ = dateadd(year,-1,@StartDateCQ), @EndDatePQ = dateadd(year,-1,@EndDateCQ)

--report dates check
--select @rptStartDateCY, @rptEndDateCY, @rptStartDatePY, @rptEndDatePY, @FiscalYear
--select @StartDateCY, @EndDateCY, @StartDatePY, @EndDatePY, @StartDatePY2, @EndDatePY2
--select @StartDateCQ, @EndDateCQ, @StartDatePQ, @EndDatePQ



if object_id('tempdb..#outlet') is not null drop table #outlet
select
	left(a.AgencyID,2) as Country,
	a.AgencyID,
	a.AccountID,
	isnull(o.BDMName,a.BDMName) as BDMName,
	o.JV,
	o.SuperGroupName,
	a.GroupName,
	o.[State],
	case when o.State in ('NSW','ACT') then 'NSW/ACT'
		 when o.State in ('SA','NT') then 'SA/NT'
		 when o.State in ('VIC','TAS') then 'VIC/TAS'
		 else o.State
	end as StateCombined,
	isnull(a.Quadrant,'UNKNOWN') as Quadrant
into #outlet
from
	sfAccount a
	outer apply							--get additional agency details
	(
		select top 1
			lo.OutletAlphaKey,
			lo.CommencementDate,
			lo.Branch,
			lo.ContactSuburb as Suburb,
			lo.ContactPostCode as Postcode,
			case lo.StateSalesArea when 'New South Wales' then 'NSW' 
									when 'Victoria' then 'VIC'
									when 'Western Australia' then 'WA'
									when 'Queensland' then 'QLD'
									when 'South Australia' then 'SA'
									when 'Northern Territory' then 'NT'
									when 'Tasmania' then 'TAS'
									when 'Australian Capital Territory' then 'ACT'
									else lo.StateSalesArea
			end as [State],
			lo.ContactPhone as Phone,
			lo.ContactEmail as Email,			
			lo.LatestBDMName as BDMName,
			lo.SuperGroupName,
			lo.JVDesc as JV
		from 
			[db-au-star].dbo.dimOutlet co
			inner join [db-au-star].dbo.dimOutlet lo on co.LatestOutletSK = lo.LatestOutletSK
		where 
			lo.AlphaCode = a.AlphaCode and
			lo.Country = left(a.AgencyID,2) and
			lo.TradingStatus = 'Stocked'
	) o
where
	left(a.AgencyID,2) = 'AU' and
	a.TradingStatus in ('Stocked') and
	a.OutletType = 'B2B' and
	o.SuperGroupName in ('Independents','Flight Centre','Helloworld')



;with cte_salescall									--get all sales calls (physical visits only) in date range
as
(
	select *	
	from sfAgencyCall
	where
		CallStartTime >= @StartDatePY2 and
		CallStartTime < dateadd(day,1,@rptEndDateCY) and
		(
			CallCategory in ('Activity - AL Meetings','Activity - AM Call','Activity - In-store visit','Activity - Meetings','Activity - One on One','Activity - TL/ATL','Training - AM/PM Session','Activity - AM/PM Training','Training - Cluster Session (F2F)') or
				(
				CallCategory = 'Core' and CallSubCategory = 'Agency Visit' or
				CallCategory = 'Focus' and CallSubCategory in ('Agency Visit','One on One') or
				CallCategory = 'Sales Call' and CallSubCategory = 'Agency Visit' or
				CallCategory = 'Sales Call' and CallSubCategory = 'One on One' or
				CallCategory = 'X - Head Office Hours (Do Not Use)' and CallSubCategory = 'Group Training' or
				CallCategory = 'X - Head Office Hours (Do Not Use)' and CallSubCategory = 'SWOT Meeting' or
				CallCategory = 'X - Sales Call (Do Not Use)' and CallSubCategory = 'Agency Visit' or
				CallCategory = 'X - Sales Call (Do Not Use)' and CallSubCategory = 'One on One' or
				CallCategory = 'X - Sales Call (Do Not Use)' and CallSubCategory = 'Training'
				) 
		) and
		left(AgencyID,2) = 'AU'	
) 
select
	o.StateCombined,
	o.BDMName,
	rptdayCY.rptWorkDaysCY,
	rptDayPY.rptWorkDaysPY,
	count(distinct BDMName) as FTE,
	max(torcy.TORCY) as TORCY,
	max(torpy.TORPY) as TORPY,
	max(torcy.TORCY) * count(distinct BDMName) * 6 as CallsAvailable,
	sum(VisitCount.ActualCalls) as ActualCalls,
	count(distinct BDMName) * max(torcy.TORCY) * 4.5 as HoursAvailable,
	count(distinct BDMName) * max(torpy.TORPY) * 4.5 as HoursAvailablePY,
	sum(VisitCount.ActualHours) / 60 as ActualHours,
	sum(VisitCountPY.ActualHoursPY) / 60 as ActualHoursPY,
	max(torpy.TORPY) * count(distinct BDMName) * 6 as CallsAvailablePY,
	sum(VisitCountPY.ActualCallsPY) as ActualCallsPY,
	sum(VisitCountYTD.ActualCalls) as ActualCallsYTD,
	sum(VisitCountPYYTD.ActualCallsPY) as ActualCallsPYYTD,
	sum(VisitCountYTD.ActualHours) / 60 as ActualHoursYTD,
	sum(VisitCountPYYTD.ActualHoursPY) / 60 as ActualHoursPYYTD
from
	#Outlet o	
	outer apply
	(
		select sum(case when datepart(dw,[Date]) in (2,3,4,5) then 1 else 0 end) as rptWorkDaysCY
		from Calendar
		where [Date] between @rptStartDateCY and @rptEndDateCY
	) rptdayCY
	outer apply
	(
		select sum(case when datepart(dw,[Date]) in (2,3,4,5) then 1 else 0 end) as rptWorkDaysPY
		from Calendar
		where [Date] between @rptStartDatePY and @rptEndDatePY
	) rptdayPY
	outer apply
	(
		select round(sum(convert(float,CallDuration) / 60 / 8),2) as TORCY
		from sfAgencyCall
		where 
			CreatedBy = o.BDMName and
			CallStartTime >= @rptStartDateCY and
			CallStartTime < dateadd(day,1,@rptEndDateCY) and
			CallCategory in ('Time Off Road - Office Time','Time Off Road - Sick Leave')
	) torcy
	outer apply
	(
		select round(sum(convert(float,CallDuration) / 60 / 8),2) as TORPY
		from sfAgencyCall
		where 
			CreatedBy = o.BDMName and
			CallStartTime >= @rptStartDatePY and
			CallStartTime < dateadd(day,1,@rptEndDatePY) and
			CallCategory in ('Time Off Road - Office Time','Time Off Road - Sick Leave')
	) torpy
	outer apply								--get number of visits in quarter
	(
		select count(distinct CallNumber) as ActualCalls,
			   sum(CallDuration) as ActualHours
		from
			cte_salescall
		where
			AgencyID = o.AgencyID and
			CallStartTime >= @rptStartDateCY and
			CallStartTime < dateadd(day,1,@rptEndDateCY) 
	) VisitCount
	outer apply								--get number of visits in quarter
	(
		select count(distinct CallNumber) as ActualCallsPY,
			   sum(CallDuration) as ActualHoursPY
		from
			cte_salescall
		where
			AgencyID = o.AgencyID and
			CallStartTime >= @rptStartDatePY and
			CallStartTime < dateadd(day,1,@rptEndDatePY) 
	) VisitCountPY
	outer apply								--get number of visits in YTD
	(
		select count(distinct CallNumber) as ActualCalls,
			   sum(CallDuration) as ActualHours
		from
			cte_salescall
		where
			AgencyID = o.AgencyID and
			CallStartTime >= @StartDateCY and
			CallStartTime < dateadd(day,1,@EndDateCY) 
	) VisitCountYTD
	outer apply								--get number of visits in Previous year YTD
	(
		select count(distinct CallNumber) as ActualCallsPY,
			   sum(CallDuration) as ActualHoursPY
		from
			cte_salescall
		where
			AgencyID = o.AgencyID and
			CallStartTime >= @StartDatePY and
			CallStartTime < dateadd(day,1,@EndDatePY) 
	) VisitCountPYYTD
group by
	o.StateCombined,
	o.BDMName,
	rptdayCY.rptWorkDaysCY,
	rptDayPY.rptWorkDaysPY
order by 1,2
GO
