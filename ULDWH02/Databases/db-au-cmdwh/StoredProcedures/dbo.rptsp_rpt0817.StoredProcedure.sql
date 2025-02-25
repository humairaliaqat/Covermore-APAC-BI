USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0817]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0817]	
	@Country nvarchar(5),
	@Supergroup nvarchar(50),
	@Group nvarchar(50),
	@Subgroup nvarchar(50),
    @DateRange varchar(30),
    @StartDate datetime,
    @EndDate datetime
as

Begin

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0817
--  Author:         Peter Zhuo
--  Date Created:   20160919
--  Description:    Returns key claims metrics by month
--					
--  Parameters:     
--                  @DateRange: required. valid date range or _User Defined
--                  @StartDate: optional. required if date range = _User Defined
--                  @EndDate: optional. required if date range = _User Defined
--					@Country: Required. Valid outlet country
--					@Supergroup: Optional. Valid outlet supergroupname or choose 'All'
--					@Group: Optional. Valid outlet groupname or choose 'All'
--					@Subgroup: Optional. Valid outlet subgroupname or choose 'All'
--                  
--  Change History: 
--                  20160919 - PZ - Created
--					20161110 - SD - Inculsion Claim Count - Additional Expenses metric
--					20170209 - SD - Inculsion of Subgroup selection prompt
--                  20170712 - ME - Changed the calculation of [Is CYTD] and [Is PYTD] at the final select statement
--					20170717 - ME - Modified the column [Period Type] at the final select statement
/****************************************************************************************************/



--Uncomment to debug
--Declare
--    @DateRange varchar(30),
--    @StartDate datetime,
--    @EndDate datetime,
--	@Country nvarchar(5),
--	@Supergroup nvarchar(50),
--	@Group nvarchar(50),
--	@Subgroup nvarchar(50)

--Select 
--    @DateRange = 'Last July',
--    @StartDate = '2015-02-01',
--    @EndDate = '2015-02-04',
--	@Country = 'AU',
--	@Supergroup = 'All',
--	@Group = 'All',
--	@Subgroup = 'All'



declare
    @rptStartDate datetime,
    @rptEndDate datetime

    if @DateRange = '_User Defined'
        select
            @rptStartDate = @StartDate,
            @rptEndDate = @EndDate

    else
        select
            @rptStartDate = StartDate,
            @rptEndDate = EndDate
        from
            vDateRange
        where
            DateRange = @DateRange


declare @sd datetime -- First day of the previous fiscal year of selected period
Set @sd = dateadd(year,-1,DATEADD(dd,0, DATEDIFF(dd,0, DATEADD( mm, -(((12 + DATEPART(m, @rptStartDate)) - 7)%12), @rptStartDate )  - datePart(d,DATEADD( mm, -(((12 + DATEPART(m, @rptStartDate)) - 7)%12),@rptStartDate ))+1 ) ))


IF OBJECT_ID('tempdb..#temp_m') IS NOT NULL DROP TABLE #temp_m
select distinct
	c.CurMonthStart,
	c.CurMonthEnd,
	c.NextMonthStart
into #temp_m
from 
	Calendar c
where
	c.[date] >= @sd and c.[date] < dateadd(day,1,@rptEndDate)  -- Ends at selected dashboard month

--------------------------------------------------------------
IF OBJECT_ID('tempdb..#temp_zz1') IS NOT NULL DROP TABLE #temp_zz1
select
	DATEADD(month, DATEDIFF(month, 0, cim.IncurredDate), 0) as [IncurredMonth],
	sum(cim.NewCount) as [New Claims],
	sum(cim.ReopenedCount) as [Re-Opened Claims],
	sum(cim.ClosedCount) as [Closed Claims]
into #temp_zz1
from
	clmClaimIntradayMovement cim with(nolock)
inner join clmclaim clm on clm.ClaimKey = cim.ClaimKey
inner join penoutlet o on o.OutletKey = clm.OutletKey and o.OutletStatus = 'current'
where
	cim.IncurredDate >= @sd and cim.IncurredDate < dateadd(day,1,@rptEndDate)
	and o.CountryKey = @country
	and (o.SuperGroupName = @Supergroup or isnull(@Supergroup,'All') = 'All')
	and (o.GroupName = @Group or isnull(@Group,'All') = 'All')
	and (o.SubGroupName = @Subgroup or isnull(@Subgroup,'All') = 'All')
group by
	DATEADD(month, DATEDIFF(month, 0, cim.IncurredDate), 0)
--------------------------------------------------------------
IF OBJECT_ID('tempdb..#temp_zz2') IS NOT NULL DROP TABLE #temp_zz2
select
	DATEADD(month, DATEDIFF(month, 0, pts.PostingDate), 0) as [PolicyPostingMonth],
	sum(pts.NewPolicyCount) as [Policy Count],
	sum(pts.GrossPremium) as [Sell Price]
into #temp_zz2
from 
	penPolicyTransSummary pts
inner join penoutlet o on pts.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'current'
where
	pts.CountryKey = @Country
	and (o.SuperGroupName = @Supergroup or isnull(@Supergroup,'All') = 'All')
	and (o.GroupName = @Group or isnull(@Group,'All') = 'All')
	and (o.SubGroupName = @Subgroup or isnull(@Subgroup,'All') = 'All')
	and pts.PostingDate >= @sd
group by
	DATEADD(month, DATEDIFF(month, 0, pts.PostingDate), 0)
--------------------------------------------------------------
IF OBJECT_ID('tempdb..#temp_zz3') IS NOT NULL DROP TABLE #temp_zz3
select
aa.FinalisedMonth,
Count(case when aa.[ApproveDeny Flag] = 'Approved' then aa.ClaimNo else null end) as [Approved Claims],
Count(case when aa.[ApproveDeny Flag] = 'Partial Approved' then aa.ClaimNo else null end) as [Partial Approved Claims],
Count(case when aa.[ApproveDeny Flag] = 'Denied' then aa.ClaimNo else null end) as [Denied Claims]
into #temp_zz3
from 
	(--aa
	select
		DATEADD(month, DATEDIFF(month, 0, cl.FinalisedDate), 0) as [FinalisedMonth],
		cl.ClaimNo,
		isnull(cp.[Approved Count],0) as [Approved Count],
		isnull(cp.[Declined Count],0) as [Declined Count],
		isnull(cp.[Approved Count],0) + isnull(cp.[Declined Count],0) as [Total Assessment Count],
		case
			when isnull(cp.[Approved Count],0) = (isnull(cp.[Approved Count],0) + isnull(cp.[Declined Count],0)) then 'Approved'
			when (isnull(cp.[Approved Count],0) > 0 and isnull(cp.[Declined Count],0) > 0) then 'Partial Approved'
			else 'Denied'
		end as [ApproveDeny Flag]
	from 
		clmclaim cl
	inner join penoutlet o on o.OutletKey = cl.OutletKey and o.OutletStatus = 'current'
	outer apply
		( -- cp
		select
			sum(cp.[Approved Count]) as [Approved Count],
			sum(cp.[Declined Count]) as [Declined Count]
		from vClaimPortfolio cp
		where
			cp.ClaimKey = cl.ClaimKey
		) as cp
	outer apply
		( -- pm
		select
			sum(a_ci.PaymentDelta) as [Paid]
		from vclmClaimIncurred a_ci
		where
			a_ci.ClaimKey = cl.ClaimKey
		) as pm
	where
		o.CountryKey = @Country
		and (o.SuperGroupName = @Supergroup or isnull(@Supergroup,'All') = 'All')
		and (o.GroupName = @Group or isnull(@Group,'All') = 'All')
		and (o.SubGroupName = @Subgroup or isnull(@Subgroup,'All') = 'All')
		and (case when cl.FinalisedDate is null then 0 else 1 end) = 1 -- IsFinalised
		and cl.FinalisedDate >= @sd
	)as aa
group by
	aa.FinalisedMonth
--------------------------------------------------------------
IF OBJECT_ID('tempdb..#temp_zz4') IS NOT NULL DROP TABLE #temp_zz4
select 
	DATEADD(month, DATEDIFF(month, 0, w.CreationDate), 0) as [CreationMonth],
    sum
    (
        case
            when w.GroupType = 'NEW' then 1
            else 0
        end
    ) as Complaint,
    sum
    (
        case
            when w.GroupType = 'IDR' then 1
            else 0
        end
    ) as [Internal Dispute Resolution],
    sum
    (
        case
            when isnull(wp.isEDR, '0') = '0' then 0
            else 1
        end
    ) [External Dispute Resolution]
into #temp_zz4
from
    e5Work w
    outer apply
    (
        select top 1 
            convert(varchar, PropertyValue) as [isEDR]
        from
            e5WorkProperties wp
        where
            wp.Work_ID = w.Work_ID and
            wp.Property_ID = 'EDRReferral'
    ) wp
	inner join clmClaim cl on cl.ClaimKey = w.ClaimKey
	inner join penoutlet o on o.OutletKey = cl.OutletKey and o.OutletStatus = 'current'
where
    w.WorkType = 'Complaints' and
	o.CountryKey = @Country and
	(o.SuperGroupName = @Supergroup or isnull(@Supergroup,'All') = 'All') and
	(o.GroupName = @Group or isnull(@Group,'All') = 'All') and
	(o.SubGroupName = @Subgroup or isnull(@Subgroup,'All') = 'All') and
	w.CreationDate >= @sd
group by
	DATEADD(month, DATEDIFF(month, 0, w.CreationDate), 0)
----------------------------------------------------------------
IF OBJECT_ID('tempdb..#temp_zz5') IS NOT NULL DROP TABLE #temp_zz5
select
	DATEADD(month, DATEDIFF(month, 0, clm.CreateDate), 0) as [CreationMonth],
	count(case when bc.ActuarialBenefitGroup = 'Cancellation' then clm.ClaimKey else null end) as [Claim Count - Cancellation],
	count(case when bc.ActuarialBenefitGroup = 'Medical' then clm.ClaimKey else null end) as [Claim Count - Medical],
	count(case when bc.ActuarialBenefitGroup = 'Luggage' then clm.ClaimKey else null end) as [Claim Count - Luggage],
	count(case when bc.ActuarialBenefitGroup = 'Additional Expenses' then clm.ClaimKey else null end) as [Claim Count - Additional Expenses],
	count(case when bc.ActuarialBenefitGroup = 'Other' then clm.ClaimKey else null end) as [Claim Count - Other]
into #temp_zz5
from 
	clmSection cs
inner join clmClaim clm on cs.ClaimKey = clm.ClaimKey
left join vclmBenefitCategory bc on bc.BenefitSectionKey = cs.BenefitSectionKey
inner join penoutlet o on o.OutletKey = clm.OutletKey and o.OutletStatus = 'current'
where
	o.CountryKey = @Country and
	(o.SuperGroupName = @Supergroup or isnull(@Supergroup,'All') = 'All') and
	(o.GroupName = @Group or isnull(@Group,'All') = 'All') and
	(o.SubGroupName = @Subgroup or isnull(@Subgroup,'All') = 'All') and
	clm.CreateDate >= @sd
group by
	DATEADD(month, DATEDIFF(month, 0, clm.CreateDate), 0)
--------------------------------------------------------------
IF OBJECT_ID('tempdb..#temp_zz6') IS NOT NULL DROP TABLE #temp_zz6
select 
		aa.[FirstActiveMonth],
		case
			when count(Reference) = 0 then 0
			else sum(isnull(TurnAroundTime, 0)) / count(Reference)
		end as [Average Turnaround Time],
		case
			when count(case when Team = 'AU' then Reference else null end) = 0 then 0
			else sum(case when Team = 'AU' then isnull(TurnAroundTime, 0) else 0 end) / count(case when Team = 'AU' then Reference else null end)
		end as [Average Turnaround Time - AU],
		case
			when count(case when Team = 'India' then Reference else null end) = 0 then 0
			else sum(case when Team = 'India' then isnull(TurnAroundTime, 0) else 0 end) / count(case when Team = 'India' then Reference else null end)
		end as [Average Turnaround Time - India]
into #temp_zz6
from
	(--aa
	select 
	DATEADD(month, DATEDIFF(month, 0, isnull(FirstActiveDate, w.CreationDate)), 0) as [FirstActiveMonth],
	isnull(l.Team, 'AU') as Team,
	w.Reference,
	datediff(day, isnull(FirstActiveDate, w.CreationDate), TurnAroundDate) * 1.0 -
	(
		select
			count(d.[Date])
		from
			[db-au-cmdwh]..Calendar d with(nolock)
		where
			d.[Date] >= isnull(FirstActiveDate, w.CreationDate) and
			d.[Date] <  dateadd(day, 1, convert(date, TurnAroundDate)) and
			(
				d.isHoliday = 1 or
				d.isWeekEnd = 1
			)
	) as TurnAroundTime
from
	[db-au-cmdwh]..e5Work w with(nolock)
	inner join clmclaim clm on w.ClaimKey = clm.claimkey
	inner join penoutlet o on o.OutletKey = clm.OutletKey and o.OutletStatus = 'current'
	outer apply
	(
		--check for e5 Launch Service straight to Diarised (onlince claim bug)
		select top 1 
			els.StatusName,
			els.EventDate
		from
			[db-au-cmdwh]..e5WorkEvent els with(nolock)
		where
			els.Work_Id = w.Work_ID
		order by
			els.EventDate
	) els
	outer apply
	(
		--use first active if it's a botch online launch
		select top 1 
			EventDate FirstActiveDate
		from
			[db-au-cmdwh]..e5WorkEvent fa with(nolock)
		where
			fa.Work_Id = w.Work_ID and
			fa.EventName in ('Changed Work Status', 'Merged Work', 'Saved Work') and
			fa.StatusName = 'Active' and
			(
				fa.EventUser <> 'e5 Launch Service' or
				fa.EventDate >= dateadd(day, 1, convert(date, els.EventDate))
			) and
			els.StatusName = 'Diarised'
		order by
			fa.EventDate
	) fa
	outer apply
	(
		select top 1 
			we.EventDate TurnAroundDate
		from
			[db-au-cmdwh]..e5WorkEvent we with(nolock)
		where
			we.Work_Id = w.Work_ID and
			we.EventDate > isnull(FirstActiveDate, w.CreationDate) and
			we.EventUser <> 'e5 Launch Service' and
			we.EventName = 'Changed Work Status' and
			we.StatusName <> 'Active'
		order by
			we.EventDate
	) we
	outer apply
	(
		select top 1
			'India' Team
		from
			[db-au-cmdwh]..usrLDAP l with(nolock)
		where
			l.DisplayName = w.AssignedUser and
			l.Company like 'Trawel%'
	) l
where	
	w.WorkType = 'Claim' and
	we.TurnAroundDate is not null and
	o.CountryKey = @Country and
	(o.SuperGroupName = @Supergroup or isnull(@Supergroup,'All') = 'All') and
	(o.GroupName = @Group or isnull(@Group,'All') = 'All') and
	(o.SubGroupName = @Subgroup or isnull(@Subgroup,'All') = 'All') and
	isnull(FirstActiveDate, w.CreationDate) >= @sd and
	isnull(FirstActiveDate, w.CreationDate) <  dateadd(day, 1, @rptEndDate)
)as aa
group by
	aa.[FirstActiveMonth]


---------------------------------------------------------------
select
	m.CurMonthStart as [Month],	
-- ME FIX BEGINS
	CASE 
		WHEN m.CurMonthStart >= DATEADD(year,1,@sd) AND m.CurMonthStart <= @rptEndDate THEN 'Current Year'
		WHEN m.CurMonthStart >= @sd AND m.CurMonthStart < DATEADD(year,1,@sd) THEN 'Previous Year'
	END AS [Period Type],
	CASE 
		WHEN m.CurMonthStart >= DATEADD(year,1,@sd) AND m.CurMonthStart <= @rptEndDate
		THEN 1
	END AS [Is CYTD],
	CASE 
		WHEN m.CurMonthStart >= @sd AND m.CurMonthStart < DATEADD(year,1,@sd)
		THEN 1
	END AS [Is PYTD],
-- ME FIX ENDS
	zz1.[Closed Claims],
	zz1.[New Claims],
	zz1.[Re-Opened Claims],
	zz2.[Policy Count],
	zz2.[Sell Price],
	zz3.[Approved Claims],
	zz3.[Denied Claims],
	zz3.[Partial Approved Claims],
	zz4.Complaint,
	zz4.[Internal Dispute Resolution],
	zz4.[External Dispute Resolution],
	zz5.[Claim Count - Cancellation],
	zz5.[Claim Count - Luggage],
	zz5.[Claim Count - Medical],
	zz5.[Claim Count - Additional Expenses],
	zz5.[Claim Count - Other],
	zz6.[Average Turnaround Time],
	zz6.[Average Turnaround Time - AU],
	zz6.[Average Turnaround Time - India],
	@DateRange as [DateRange],
	m.CurMonthStart,
	m.CurMonthEnd
from #temp_m m
left join #temp_zz1 zz1 on m.[CurMonthStart] = zz1.IncurredMonth
left join #temp_zz2 zz2 on m.[CurMonthStart] = zz2.PolicyPostingMonth
left join #temp_zz3 zz3 on m.[CurMonthStart] = zz3.FinalisedMonth
left join #temp_zz4 zz4 on m.[CurMonthStart] = zz4.CreationMonth
left join #temp_zz5 zz5 on m.[CurMonthStart] = zz5.CreationMonth
left join #temp_zz6 zz6 on m.[CurMonthStart] = zz6.FirstActiveMonth

end
GO
