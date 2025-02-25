USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0798a]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0798a]	@DateRange varchar(30),
										@StartDate datetime,
										@EndDate datetime
as

SET NOCOUNT ON


/****************************************************************************************************/
--	Name:			dbo.rptsp_rpt0798a
--	Author:			Linus Tor
--	Date Created:	20160804
--	Description:	This stored procedure returns salesforce account details and sales call (visit) metrics
--					The result of this stored proc should be used for Stored Details and Quadrant activities
--	Parameters:		@DateRange: standard date range or _User Defined
--					@StartDate: valid date value. Format: YYYY-MM-DD (eg. 2016-06-01)
--					@EndDate: valid date value. Format: YYYY-MM-DD (eg. 2016-06-01)
--	
--	Change History:	20160804 - LT - Created
--			20161004 - SD - Addition of Policy Count Metrics
--			20161005 - SD - Addition of FCArea level for RPt0819 report Area and Store Leaderboard
--			20161010 - SD - Optimized the query to run within 2 minutes
--			20161017 - SD - Addition of Call count in last 90 days metric and Last call comment
--			20161028 - LT - Changed AccountID linkage to AgencyID linkage. AgencyID is the correct linkage to use.
--							Amended Sales Call (visit) category definition
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
				(CallCategory = 'Core' and CallSubCategory = 'Agency Visit') or
				(CallCategory = 'Focus' and CallSubCategory in ('Agency Visit','One on One')) or
				(CallCategory = 'Sales Call' and CallSubCategory in ('Agency Visit', 'One on One')) or
				(CallCategory = 'X - Head Office Hours (Do Not Use)' and CallSubCategory in ('Group Training', 'SWOT Meeting')) or
				(CallCategory = 'X - Sales Call (Do Not Use)' and CallSubCategory in ('Agency Visit', 'One on One', 'Training'))
			) 
		) and
		left(AgencyID,2) = 'AU'	
)


select
	left(a.AgencyID,2) as Country,
	a.AgencyID,
	a.AccountID,
	isnull(o.BDMName,a.BDMName) as BDMName,
	o.JV,
	o.SuperGroupName,
	a.GroupName,
	a.SubGroupName,
	a.AlphaCode,
	o.OutletAlphaKey,
	o.CommencementDate,
	a.TradingStatus,
	a.OutletName,
	o.Branch,
	o.Suburb,
	o.Postcode,
	o.[State],
	case when o.State in ('NSW','ACT') then 'NSW/ACT'
		 when o.State in ('SA','NT') then 'SA/NT'
		 when o.State in ('VIC','TAS') then 'VIC/TAS'
		 else o.State
	end as StateCombined,
	o.Phone,
	o.Email,
	isnull(a.Quadrant,'UNKNOWN') as Quadrant,
	lastvisit.DateLastVisit,
	lastcalled.DateLastCall,
	lastcalled.LastCallComment,
	a.LastVisited,	
	cons.ActiveConsultant,
	cons.ActiveConsultant6MthExp,
	SellPriceCY,
	SellPricePY,
	case when SellPricePY <> 0 then (SellPriceCY-SellPricePY)/SellPricePY else 0 end as YTDGrowthPct,
	SellPricePY2,
	SellPriceCQ,
	SellPricePQ,
	case when SellPricePQ <> 0 then (SellPriceCQ-SellPricePQ)/SellPricePQ else 0 end as QtrGrowthPct,
	rptSellPriceCY,
	rptSellPricePY,
	case when rptSellPricePY <> 0 then (rptSellPriceCY-rptSellPricePY)/rptSellPricePY else 0 end as RptGrowthPct,
	--Addition of Policy Count Metrics
	PolicyCountCY,
	PolicyCountPY,
	case when PolicyCountPY <> 0 then (PolicyCountCY-PolicyCountPY)/PolicyCountPY else 0 end as YTDPolicyCountGrowthPct,
	PolicyCountPY2,
	PolicyCountCQ,
	PolicyCountPQ,
	case when PolicyCountPQ <> 0 then (PolicyCountCQ-PolicyCountPQ)/PolicyCountPQ else 0 end as QtrPolicyCountGrowthPct,
	rptPolicyCountCY,
	rptPolicyCountPY,
	case when rptPolicyCountPY <> 0 then (rptPolicyCountCY-rptPolicyCountPY)/rptPolicyCountPY else 0 end as RptPolicyCountGrowthPct,
	--End of Policy Count Metrics
	@StartDateCY as StartDateCY,
	@EndDateCY as EndDateCY,
	@StartDatePY as StartDatePY,
	@EndDatePY as EndDatePY,
	@StartDatePY2 as StartDatePY2,
	@EndDatePY2 as EndDatePY2,
	@StartDateCQ as StartDateCQ,
	@EndDateCQ as EndDateCQ,
	@StartDatePQ as StartDatePQ,
	@EndDatePQ as EndDatePQ,
	@rptStartDateCY as rptStartDateCY,
	@rptEndDateCY as rptEndDateCY,
	@rptStartDatePY as rptStartDatePY,
	@rptEndDatePY as rptEndDatePY,
	right(convert(varchar,@FiscalYear),2) as FiscalYearCY,
	right(convert(varchar,(@FiscalYear - 1)),2) as FiscalYearPY,
	right(convert(varchar,(@FiscalYear - 2)),2) as FiscalYearPY2,
	lastcall.CallCategory,
	lastcall.CallSubCategory,
	lastcall.CallDuration,
	lastcall.CallComment,
	VisitCount.VisitCount,
	isnull(allcall.TotalCall,0) as TotalCall,
	isNull(TotalCall90Days, 0) as TotalCall90days,
	case when allcall.TotalCall = 0 then 1 else 0 end Call0,
	case when allcall.TotalCall = 1 then 1 else 0 end Call1,
	case when allcall.TotalCall = 2 then 1 else 0 end Call2,
	case when allcall.TotalCall = 3 then 1 else 0 end Call3,
	case when allcall.TotalCall >= 4 then 1 else 0 end Call4,
	rptCall.rptTotalCall,
	rptdayCY.rptWorkDaysCY,
	rptdayPY.rptWorkDaysPY,
	dayCY.WorkDaysCY,
	dayPY.WorkDaysPY,
	isnull(timeoff.TimeOffRoadDays,0) as TimeOffRoadDays,
	rptSalesCall.rptSalesCallDuration,
	o.FCArea
from
	sfAccount a
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
		select sum(case when datepart(dw,[Date]) in (2,3,4,5) then 1 else 0 end) as WorkDaysCY
		from Calendar
		where [Date] between @StartDateCY and @EndDateCY
	) dayCY
	outer apply
	(
		select sum(case when datepart(dw,[Date]) in (2,3,4,5) then 1 else 0 end) as WorkDaysPY
		from Calendar
		where [Date] between @StartDatePY and @EndDatePY
	) dayPY
	outer apply								---get the latest call in period
	(
		select top 1
			cal.CallCategory,
			cal.CallSubCategory,
			cal.CallDuration,
			cal.CallComment
		from
			cte_salescall cal
		where
		    cal.AgencyID = a.AgencyID and		
			cal.CallStartTime >= @rptStartDateCY and
			cal.CallStartTime < dateadd(day,1,@rptEndDateCY) and
			cal.CallNumber = (select max(CallNumber)
							  from cte_salescall
							  where AgencyID = cal.AgencyID)
	) lastcall
	outer apply								--get number of sales/phone calls in Quarter
	(
		select count(distinct CallNumber) as TotalCall
		from cte_salescall
		where 
			AgencyID = a.AgencyID and
			CallStartTime >= @StartDateCQ and
			CallStartTime < dateadd(day,1,@EndDateCQ) 
	) allcall
	outer apply								--get number of sales/phone calls in Last 90 days
	(
		select count(distinct CallNumber) as TotalCall90Days
		from cte_salescall
		where 
			AgencyID = a.AgencyID and
			CallStartTime >= dateadd(day, -90, @rptEndDateCY) and
			CallStartTime < dateadd(day,1, @rptEndDateCY) 
	) allcall90days
	outer apply								--get number of calls in period
	(
		select count(distinct CallNumber) as rptTotalCall
		from cte_salescall
		where 
			AgencyID = a.AgencyID and
			CallStartTime >= @rptStartDateCY and
			CallStartTime < dateadd(day,1,@rptEndDateCY) 
	) rptcall
	outer apply								--get number of calls (phone, sales visits etc...) in period
	(
		select count(distinct CallNumber) as rptCallCount
		from sfAgencyCall
		where 
			AgencyID = a.AgencyID and
			CallStartTime >= @rptStartDateCY and
			CallStartTime < dateadd(day,1,@rptEndDateCY) 
	) rptDuration
	outer apply								--get number of calls (phone, sales visits etc...) in period
	(
		select sum(CallDuration) as rptSalesCallDuration
		from cte_salescall
		where 
			AgencyID = a.AgencyID and
			CallStartTime >= @rptStartDateCY and
			CallStartTime < dateadd(day,1,@rptEndDateCY) 
	) rptSalesCall
	outer apply								--get number of visits in quarter
	(
		select count(distinct CallNumber) as VisitCount
		from
			cte_salescall
		where
			AgencyID = a.AgencyID and
			CallStartTime >= @StartDateCQ and
			CallStartTime < dateadd(day,1,@EndDateCQ) 
	) VisitCount
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
			lo.JVDesc as JV,
			lo.FCArea		
		from 
			[db-au-star].dbo.dimOutlet co
			inner join [db-au-star].dbo.dimOutlet lo on co.LatestOutletSK = lo.LatestOutletSK
		where 
			lo.AlphaCode = a.AlphaCode and
			lo.Country = left(a.AgencyID,2) and
			lo.TradingStatus = 'Stocked'
	) o
	left join
	(
		select AgencyID, CreatedBy, sum(convert(float,CallDuration) / 60 / 8) as TimeOffRoadDays
		from sfAgencyCall
		where 
			CallStartTime >= @rptStartDateCY and
			CallStartTime < dateadd(day,1,@rptEndDateCY) and
			CallCategory in ('Time Off Road - Office Time','Time Off Road - Sick Leave')
		group by
			AgencyID,
			CreatedBy
	) timeoff on a.AgencyID = timeoff.AgencyID and
				 isnull(o.BDMName,a.BDMName) = CreatedBy
	outer apply								--calculate active consultant (based on policy cube definition)
	(
		select 			
			count(distinct case when pt.TransactionType = 'Base' and 
									 pt.TransactionStatus = 'Active' and 
									 u.ConsultantType = 'External' then pt.ConsultantSK
								else null 
				  end) as ActiveConsultant,
			count(distinct case when pt.TransactionType = 'Base' and 
									 pt.TransactionStatus = 'Active' and 
									 u.ConsultantType = 'External' and
									 datediff(month,u.AccreditationDate,@rptEndDateCY) < 6 then pt.ConsultantSK
								else null 
				  end) as ActiveConsultant6MthExp			
		from
			[db-au-star].dbo.factPolicyTransaction pt
			inner join [db-au-star].dbo.dimConsultant u on pt.ConsultantSK = u.ConsultantSK
			inner join [db-au-star].dbo.dimOutlet oo on pt.OutletSK = oo.OutletSK
		where
			oo.OutletAlphaKey = o.OutletAlphaKey and
			pt.PostingDate >= @rptStartDateCY and
			pt.PostingDate < dateadd(day,1,@rptEndDateCY)
	) cons
	outer apply														--get the last agency visit date
	(
		select
			max(CallStartTime) as DateLastVisit
		from cte_salescall
		where
			AgencyID = a.AgencyID
	) lastvisit
	outer apply														--get last call date and call comment
	(
		select Top 1
			CallStartTime as DateLastCall,
			CallComment as LastCallComment
		from sfAgencyCall
		where
			AgencyID = a.AgencyID
		Order By
			CallStartTime Desc
	) lastcalled
	Outer apply
	(
	select
		sum(Case When PostingDate between @StartDateCY and @EndDateCY Then GrossPremium End) as SellPriceCY,
		Sum(Case When PostingDate between @StartDateCY and @EndDateCY Then BasePolicyCount End) as PolicyCountCY,
		sum(Case When PostingDate between @StartDatePY and @EndDatePY Then GrossPremium End) as SellPricePY,
		Sum(Case When PostingDate between @StartDatePY and @EndDatePY Then BasePolicyCount End) as PolicyCountPY,
		sum(Case When PostingDate between @StartDatePY2 and @EndDatePY2 Then GrossPremium End) as SellPricePY2,
		Sum(Case When PostingDate between @StartDatePY2 and @EndDatePY2 Then BasePolicyCount End) as PolicyCountPY2,
		sum(Case When PostingDate between @StartDateCQ and @EndDateCQ Then GrossPremium End) as SellPriceCQ,
		Sum(Case When PostingDate between @StartDateCQ and @EndDateCQ Then BasePolicyCount End) as PolicyCountCQ,
		sum(Case When PostingDate between @StartDatePQ and @EndDatePQ Then GrossPremium End) as SellPricePQ,
		Sum(Case When PostingDate between @StartDatePQ and @EndDatePQ Then BasePolicyCount End) as PolicyCountPQ,
		sum(Case When PostingDate between @rptStartDateCY and @rptEndDateCY Then GrossPremium End) as rptSellPriceCY,
		Sum(Case When PostingDate between @rptStartDateCY and @rptEndDateCY Then BasePolicyCount End) as rptPolicyCountCY,
		sum(Case When PostingDate between @rptStartDatePY and @rptEndDatePY Then GrossPremium End) as rptSellPricePY,
		Sum(Case When PostingDate between @rptStartDatePY and @rptEndDatePY Then BasePolicyCount End) as rptPolicyCountPY	
	from
		[db-au-cmdwh].dbo.penPolicyTransSummary
	Where
		OutletAlphaKey = o.OutletAlphaKey and
		PostingDate between @StartDatePY2 and @rptEndDateCY
	) rptsellPolicy
where
	left(a.AgencyID,2) = 'AU' and
	a.TradingStatus in ('Stocked','Prospect') and
	a.OutletType = 'B2B' and
	o.SuperGroupName in ('Independents','Flight Centre','Helloworld')
GO
