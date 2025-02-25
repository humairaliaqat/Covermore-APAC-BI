USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0818a]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0818a] 
@ReportingPeriod varchar(30),
@StartDate date,
@EndDate date
as 

Begin

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0818a
--  Author:         Peter Zhuo
--  Date Created:   20160927
--  Description:    This stored procedure produces several policy and EMC key metrics so user can monitor 
--					the impact on the policy sales from the EMC denial threshold change which was implemented
--					at the end of August 2016.
--					TFS 27481
--  Parameters:     @ReportingPeriod (@StartDate, @EndDate): Standard BI reporting period
--                  
--  Change History: 
--                  20160927	-	PZ	-	Created
--
/****************************************************************************************************/

set nocount on

--Uncomment to debug
--Declare
--    @ReportingPeriod varchar(30),
--    @StartDate date,
--    @EndDate date
--Select 
--    @ReportingPeriod = 'Current Month',
--    @StartDate = '2015-02-01',
--    @EndDate = '2015-02-04'


declare
    @rptStartDate datetime,
    @rptEndDate datetime

    if @ReportingPeriod = '_User Defined'
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
            DateRange = @ReportingPeriod

Declare @sd date
Set @sd = dateadd(month,-12,DATEADD(month, DATEDIFF(month, 0, @rptStartDate), 0))

--select @sd
------------------------------------------------------

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

	
IF OBJECT_ID('tempdb..#temp_zz1') IS NOT NULL DROP TABLE #temp_zz1
select
	DATEADD(month, DATEDIFF(month, 0, pts.PostingDate), 0) as [Policy Posting Month],
	sum(pts.NewPolicyCount) as [Policy Count],
	sum(case when pts.PurchasePath like 'Age%' then pts.NewPolicyCount else 0 end) as [Aged Policy Count],
	sum(case when pts.PurchasePath not like 'Age%' and pts.PurchasePath not like 'Business%' then pts.NewPolicyCount else 0 end) as [Leisure Policy Count]
into #temp_zz1
from 
	penPolicyTransSummary pts
where
	pts.CountryKey in ('AU','NZ')
	and pts.PostingDate >= @sd and pts.PostingDate < dateadd(day,1,@rptEndDate)
group by
	DATEADD(month, DATEDIFF(month, 0, pts.PostingDate), 0)


IF OBJECT_ID('tempdb..#temp_zz2') IS NOT NULL DROP TABLE #temp_zz2
select
	DATEADD(month, DATEDIFF(month, 0, a.AssessedDateOnly), 0) as [EMC Assessment Month],
	count(a.ApplicationKey) as [EMC Assessment Count],
	count(case when a.ApprovalStatus <> 'Covered' then a.ApplicationKey else null end) as [Declined EMC Assessment Count]
into #temp_zz2
from 
	emcApplications a
inner join emcApplicants ea on ea.ApplicationKey = a.ApplicationKey
where
	a.CountryKey in ('AU','NZ')
	and a.AssessedDateOnly >= @sd and a.AssessedDateOnly < dateadd(day,1,@rptEndDate)
	and ea.FirstName not like '%test%'
	and ea.Surname not like '%test%'
group by
	DATEADD(month, DATEDIFF(month, 0, a.AssessedDateOnly), 0)


IF OBJECT_ID('tempdb..#temp_zz3') IS NOT NULL DROP TABLE #temp_zz3
select
	DATEADD(month, DATEDIFF(month, 0, ea.AssessedDateOnly), 0) as [AssessMonth],
	count(ea.ApplicationID) as [New Declined Group]
into #temp_zz3
from 
	emcApplications ea
left join [db-au-star].[dbo].[dimOutlet] o ON o.OutletAlphaKey=ea.OutletAlphaKey and o.isLatest = 'Y'
LEFT OUTER JOIN penPolicyEMC ppe ON (ea.ApplicationKey=ppe.EMCApplicationKey)
LEFT OUTER JOIN penPolicyTravellerTransaction ptt ON (ppe.PolicyTravellerTransactionKey=ptt.PolicyTravellerTransactionKey)
LEFT OUTER JOIN penPolicyTransSummary pts ON (ptt.PolicyTransactionKey=pts.PolicyTransactionKey)
left join penpolicy p on p.PolicyKey = pts.PolicyKey
inner join emcApplicants eat on eat.ApplicationKey = ea.ApplicationKey
outer apply
	(
	select distinct
		a_ea.ApplicationID
	from 
		emcApplications a_ea
	where
		a_ea.CountryKey  in ('AU','NZ')
		and a_ea.MedicalRisk > 7 and a_ea.MedicalRisk <= 8
		and isnull(a_ea.AgeApprovalStatus,'') = ''
		and a_ea.AssessedDateOnly > @sd and a_ea.AssessedDateOnly < dateadd(day,1,@rptEndDate)
		and a_ea.ApplicationKey = ea.ApplicationKey
	) as c2
outer apply
	(
	select distinct
		a_ea.ApplicationID
	from 
		emcApplications a_ea
	where
		a_ea.CountryKey  in ('AU','NZ')
		and a_ea.MedicalRisk > 5 and a_ea.MedicalRisk <= 5.5
		and isnull(a_ea.AgeApprovalStatus,'') <> ''
		and a_ea.AssessedDateOnly > @sd and a_ea.AssessedDateOnly < dateadd(day,1,@rptEndDate)
		and a_ea.ApplicationKey = ea.ApplicationKey
	) as c3
where
	ea.CountryKey in ('AU','NZ')
	and ea.AssessedDateOnly > @sd and ea.AssessedDateOnly < dateadd(day,1,@rptEndDate)
	and 
		(
		c2.ApplicationID is not null
		or
		c3.ApplicationID is not null
		)
	and isnull(o.Channel,'') not in ('Website White-Label','Mobile')
	and ea.ApprovalStatus <> 'Covered'
	and eat.FirstName not like '%test%' and eat.Surname not like '%test%'
group by
	DATEADD(month, DATEDIFF(month, 0, ea.AssessedDateOnly), 0)


select
	m.CurMonthStart,
	case when month(m.CurMonthStart) = month(@rptStartDate) then 1 else null end as [CYLY],
	zz1.[Policy Count],
	zz1.[Leisure Policy Count],
	zz1.[Aged Policy Count],
	zz2.[EMC Assessment Count],
	zz2.[Declined EMC Assessment Count],
	zz3.[New Declined Group]
from #temp_m m
left join #temp_zz1 zz1 on zz1.[Policy Posting Month] = m.CurMonthStart
left join #temp_zz2 zz2 on zz2.[EMC Assessment Month] = m.CurMonthStart
left join #temp_zz3 zz3 on zz3.AssessMonth = m.CurMonthStart

End
GO
