USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0788]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0788] 
@DashboardMonth varchar(30),
@StartDate date,
@EndDate date
as 

Begin
/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0788
--  Author:         Peter Zhuo
--  Date Created:   20160706
--  Description:    This stored procedure produces key claims metrics on a monthly basis
--					for current and previous fiscal year
--  Parameters:     @ReportingPeriod (@StartDate, @EndDate): Standard BI reporting period
--                  
	
--	Query 
--	Structure:		Part 1 - Preparation. Store month master, views and reports into temp tables
--					Part 2 - Store reporting sections into temp table
--					Part 3 - Main query, putting sections together

--  Change History: 
--                  20160706	-	PZ	-	Created
--					20160727	-	PZ	-	Used the logic from RPT0700 for Teleclaims count
--
/****************************************************************************************************/

set nocount on

--Uncomment to debug
--Declare
--    @DashboardMonth varchar(30),
--    @StartDate date,
--    @EndDate date
--Select 
--    @DashboardMonth = 'Last Month',
--    @StartDate = '2015-02-01',
--    @EndDate = '2015-02-04'



--'Current Fiscal Year','Last Fiscal Year'
declare @sd date = (select min(d.StartDate) as [Period Start] from vDateRange d where d.DateRange in ('Current Fiscal Year','Last Fiscal Year','Last 2 Fiscal Year'))
declare @ed date = (select max(d.EndDate) as [Period End] from vDateRange d where d.DateRange in ('Current Fiscal Year','Last Fiscal Year','Last 2 Fiscal Year'))

declare
    @rptStartDate datetime,
    @rptEndDate datetime

    if @dashboardmonth = '_User Defined'
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
            DateRange = @dashboardmonth


IF OBJECT_ID('tempdb..#temp_m') IS NOT NULL DROP TABLE #temp_m
select distinct
	c.CurMonthStart,
	c.CurMonthEnd,
	c.NextMonthStart
into #temp_m
from 
	Calendar c
where
	--c.[date] >= '2016-04-01' and c.[date] < '2016-07-01'
	c.[date] >= @sd and c.[date] < dateadd(day,1,@rptEndDate)  -- Ends at selected dashboard month
create nonclustered index idx on #temp_m (CurMonthStart,CurMonthEnd,NextMonthStart)

declare @sql nvarchar(max)
set @sql = -- Run SP rptsp_rpt0663 and store the result in a temp table, used for turnaround time
'
select
	aa.[Company],
	aa.[CreationDate],
	aa.[CYTurnAroundTime],
	aa.[CYCaseCount]
from openrowset
(--aa
    ''SQLNCLI'', 
    ''server=localhost;Trusted_Connection=yes'',
    ''
    set fmtonly off 
    exec [db-au-cmdwh].[dbo].[rptsp_rpt0663]
		@Country = ''''AU'''',
        @ReportingPeriod = ''''_User Defined'''',
        @StartDate = ''''' + cast(@sd as nvarchar) +''''',
        @EndDate = ''''' + cast(@ed as nvarchar) +'''''
    ''
) as aa
where
	aa.[WorkType] = ''Claim''	
'

IF OBJECT_ID('tempdb..#temp_ta') IS NOT NULL DROP TABLE #temp_ta
Create table #temp_ta ([Company] nvarchar(100), [CreationDate] date, [CYTurnAroundTime] float, [CYCaseCount] float)
insert into #temp_ta
exec (@sql)


IF OBJECT_ID('tempdb..#temp_cii') IS NOT NULL DROP TABLE #temp_cii
select 
	cii.ClaimKey,
	cii.IncurredDate,
	cii.NewCount,
	cii.ReopenedCount,
	cii.ClosedCount
into #temp_cii
from 
	vclmClaimIncurredIntraDay cii
where
	cii.Claimkey like 'AU%'

create nonclustered index idx on #temp_cii (IncurredDate,ClaimKey) include(NewCount,ReopenedCount,ClosedCount)


/* End preparation */
----------------------------------------------------------------------------


/* Begin Insert Sections into temp tables */

--BEGIN zz1--------------------------------------------------------
IF OBJECT_ID('tempdb..#zz1') IS NOT NULL DROP TABLE #zz1
select
	m.CurMonthStart as [Incurred Month],
	zz1.*
into #zz1
from 
	#temp_m m
outer apply
	(--zz1
	select
	sum(bb.Opening) as [Opening]
	from
		(--bb
			select
				aa.ClaimKey,
				case
					when Opening > 0 then 1
					else 0
				end as [Opening]
			from
				(--aa
				select 
					cii.ClaimKey,
					sum(cii.NewCount + cii.ReopenedCount - cii.ClosedCount) as Opening
				from
					#temp_cii cii --with(index(idx))
				where
					cii.IncurredDate >= dateadd(year,-4,getdate()) and -- Add a start date filter here significantly reduces the query run time, 
																		--however need to be careful with the date range settings as a very old claim can still be re-opened, in theory.
					cii.IncurredDate < m.CurMonthStart  
					--cii.IncurredDate < '2016-06-01'
				group by
					cii.ClaimKey
				)as aa				
		)as bb
	) as zz1
--END zz1--------------------------------------------------------

--BEGIN zz2--------------------------------------------------------
IF OBJECT_ID('tempdb..#zz2') IS NOT NULL DROP TABLE #zz2
select
	DATEADD(month, DATEDIFF(month, 0, cii.IncurredDate), 0) as [Incurred Month],
    sum(cii.NewCount) as NewCount, 
    sum(cii.ReopenedCount) as ReopenedCount,
    sum(cii.ClosedCount) as ClosedCount,
	sum(case when ind.ClaimKey is not null and cii.ClosedCount > 0 then 1 end) as [Fast Track Claim Closed by India],
	sum(case when deni.ClaimKey is not null and cii.ClosedCount > 0 then 1 end) as [Claims Denied] -- Denied claims among the closed ones
into #zz2
from #temp_cii cii 
outer apply	
	(
	select top 1
		w.ClaimKey
	from e5Work w
	outer apply
		(
		select top 1
			u.Company
		from
			usrLDAP u
		where
			u.DisplayName = w.AssignedUser
			and u.Company like '%Trawel%'
		order by
			u.UpdateDateTime desc 
		) Comp
	where
		w.Country = 'AU' and
		w.WorkType like 'Claim%' and
		w.GroupType = 'fast track' and
		comp.Company like '%Trawel%' and
		w.ClaimKey = cii.ClaimKey 
	) as ind
outer apply
	(
	select 
		distinct a_w.ClaimKey
	from 
		e5work a_w
	inner join e5WorkActivity a_wa on a_wa.Work_ID = a_w.Work_ID
	where
		isnull(a_w.Country, 'AU') = 'AU' and
		a_w.WorkType like 'Claim%' and
		a_wa.CategoryActivityName = 'Assessment Outcome' and
		a_wa.AssessmentOutcomeDescription = 'Deny' and
		a_w.ClaimKey = cii.ClaimKey
	) as deni
where
   cii.IncurredDate >= @sd and cii.IncurredDate < dateadd(day,1,@rptEndDate)
    --and cii.IncurredDate >= m.CurMonthStart and cii.IncurredDate < m.NextMonthStart
group by
	DATEADD(month, DATEDIFF(month, 0, cii.IncurredDate), 0)
----END zz2--------------------------------------------------------

----BEGIN zz3--------------------------------------------------------
IF OBJECT_ID('tempdb..#zz3') IS NOT NULL DROP TABLE #zz3
select
	m.CurMonthStart as [Event Month],
	zz3.*
into #zz3
from 
	#temp_m m
outer apply
	(--zz3
	select
		count(distinct case when ls.[Last Status In The Chosen Period] = 'Active' then w.ClaimKey else null end) as [Closing Active Claims],
		count(distinct case when ls.[Last Status In The Chosen Period] = 'Diarised' then w.ClaimKey else null end) as [Closing Diarised Claims]
	from 
		e5work w
	cross apply
		(
		select top 1
			we.StatusName as [Last Status In The Chosen Period]
			--we.EventDate
		from 
			e5WorkEvent we 
		where
			we.Work_ID = w.Work_ID
			and we.EventDate < m.NextMonthStart
			and 
			(
			we.EventName = 'Changed Work Status' 
			or
			(
				we.EventName = 'Saved Work' and
				we.EventUser in ('e5 Launch Service', 'svc-e5-prd-services')
			)
			)
		order by we.EventDate desc
		) as ls
	where
		w.Country = 'AU'
		and w.CreationDate >= @sd
		and (w.WorkType like 'claim%' and w.WorkType <> 'Claims Audit')
		and ls.[Last Status In The Chosen Period] in ('Active','Diarised')
		and w.ClaimKey is not null
	) as zz3
----END zz3--------------------------------------------------------

----BEGIN zz4--------------------------------------------------------
IF OBJECT_ID('tempdb..#zz4') IS NOT NULL DROP TABLE #zz4
select
	DATEADD(month, DATEDIFF(month, 0, c.IncurredDate), 0) as [Incurred Month],
	sum(case when isnull(vb.OperationalBenefitGroup,'') = 'Medical' then c.PaymentDelta else 0 end) as [Paid - Medical],
	sum(case when isnull(vb.OperationalBenefitGroup,'') = 'Cancellation' then c.PaymentDelta else 0 end) as [Paid - Cancellation],
	sum(case when isnull(vb.OperationalBenefitGroup,'') = 'Luggage' then c.PaymentDelta else 0 end) as [Paid - Luggage],
	sum(case when isnull(vb.OperationalBenefitGroup,'') = 'Other' then c.PaymentDelta else 0 end) as [Paid - Other]
into #zz4
from 
	vclmClaimSectionIncurred c
left join clmSection s on s.SectionKey = c.SectionKey
left join vclmBenefitCategory vb on vb.BenefitSectionKey = s.BenefitSectionKey
where
	s.CountryKey = 'AU' and
	c.IncurredDate >= @sd and c.IncurredDate < dateadd(day,1,@rptEndDate)
group by
	DATEADD(month, DATEDIFF(month, 0, c.IncurredDate), 0)
----END zz4--------------------------------------------------------

----BEGIN zz5--------------------------------------------------------
IF OBJECT_ID('tempdb..#zz5') IS NOT NULL DROP TABLE #zz5
select
	m.CurMonthStart as [Estimate Month],
	zz5.*
into #zz5
from 
	#temp_m m
outer apply
	(-- zz5
	select
		sum(case when isnull(vb.OperationalBenefitGroup,'') = 'Medical' then c.EstimateMovement else 0 end) as [Estimates Balance - Medical],
		sum(case when isnull(vb.OperationalBenefitGroup,'') = 'Cancellation' then c.EstimateMovement else 0 end) as [Estimates Balance - Cancellation],
		sum(case when isnull(vb.OperationalBenefitGroup,'') = 'Luggage' then c.EstimateMovement else 0 end) as [Estimates Balance - Luggage],
		sum(case when isnull(vb.OperationalBenefitGroup,'') = 'Other' then c.EstimateMovement else 0 end) as [Estimates Balance - Other]
	from 
		clmClaimEstimateMovement c
		--#temp_em c
	left join clmSection s on s.SectionKey = c.SectionKey
	left join vclmBenefitCategory vb on vb.BenefitSectionKey = s.BenefitSectionKey
	where
		c.ClaimKey like 'AU%' and
		c.[EstimateDate] < m.NextMonthStart
	) as zz5
----END zz5--------------------------------------------------------

----BEGIN zz6--------------------------------------------------------
IF OBJECT_ID('tempdb..#zz6') IS NOT NULL DROP TABLE #zz6
select 
	DATEADD(month, DATEDIFF(month, 0, ta.CreationDate), 0) as [Month],
	sum(ta.CYTurnAroundTime) as [Total TA Time],
	sum(case when ta.[company] like '%Trawelltag%' then ta.CYTurnAroundTime else 0 end) as [Total TA Time - India],
	sum(case when ta.[company] like '%Trawelltag%' then 0 else ta.CYTurnAroundTime end) as [Total TA Time - AU],

	sum(ta.CYCaseCount) as [Total Case Count],
	sum(case when ta.[company] like '%Trawelltag%' then ta.CYCaseCount else 0 end) as [Total Case Count - India],
	sum(case when ta.[company] like '%Trawelltag%' then 0 else ta.CYCaseCount end) as [Total Case Count - AU]
into #zz6
from 
	#temp_ta ta
where
	ta.CreationDate > @sd -->= m.CurMonthStart and ta.CreationDate < m.NextMonthStart
group by
	DATEADD(month, DATEDIFF(month, 0, ta.CreationDate), 0)
----END zz6--------------------------------------------------------

----BEGIN zz7--------------------------------------------------------
IF OBJECT_ID('tempdb..#zz7') IS NOT NULL DROP TABLE #zz7
select
	aa.[Received Month],
	sum(case when aa.OnlineClaim = 1 then 1 else 0 end) as [OnlineClaim Count],
	Count(distinct aa.ClaimKey) as [Total Claim Count],
	cast(sum(case when aa.OnlineClaim = '1' then 1 else 0 end) as money) / nullif(cast(Count(aa.ClaimKey) as money),0) as [OnlineClaim %],
	sum(aa.TeleclaimCount) as [TeleClaims],
	sum(aa.TeleclaimCount) / nullif(cast(Count(distinct aa.ClaimKey) as money),0) as [% of TeleClaims]
into #zz7
from
	(--aa
	select 
		cl.ClaimKey,
		cast((cast(year(cl.ReceivedDate) as nvarchar) + '-' + cast(month(cl.ReceivedDate) as nvarchar) + '-01') as date) as [Received Month],
		cl.CreatedBy,
		cl.OnlineClaim,
		case
			when cl.OnlineClaim = 0 then 'Offline'
			when isnull(cl.OnlineAlpha, '') = '' then 'Customer'			
			else isnull(crm.CRMUser, 'Agent')
		end OnlineBy,
		claimType.claimType,
		case when claimType.ClaimType = 'Teleclaim' then 1						 
				when isnull(cl.OnlineAlpha, '') = '' then 0			--customer
				when isnull(cl.OnlineAlpha, '') <> '' then 0			--agent
				when isnull(crm.CRMUser, '') <> '' then 1			   --CM internal staff
				else 0
		end as TeleclaimCount
	from
		clmClaim cl	
		outer apply
		(
			select top 1
				OnlineConsultant,
				CountryKey,
				OnlineAlpha,
				CreatedBy
			from
				clmClaim
			where
				ClaimKey = cl.ClaimKey
		) cl2
		outer apply
		(
			select top 1 
				cu.FirstName + ' ' + cu.LastName CRMUser
			from
				penCRMUser cu
			where
				cu.CountryKey = cl2.CountryKey and
				cu.UserName = cl2.OnlineConsultant
		) crm	
		outer apply
		(
			select top 1 
				w.CreationUser as CreatedBy,
				w.CreationDate,
				w.AssignedUser,
				w.AssignedDate,
				w.CompletionUser,
				w.CompletionDate,
				teleclaim.ClaimType
			from
				e5Work w
				outer apply
				(
					select top 1 
						witem.ClaimType
					from
						e5Work_v3 e5w
						inner join e5WorkProperties_v3 e5wp on e5w.Work_ID = e5wp.Work_ID
						outer apply
						(
							select top 1 Name as ClaimType
							from 
								e5WorkItems_v3
							where
								ID = e5wp.PropertyValue
						) witem
					where 
						e5wp.Property_ID = 'ClaimType' and
						e5w.Work_ID = w.Work_ID
				) teleclaim
			where
				w.ClaimKey = cl.ClaimKey and
				(
					w.WorkType like '%claim%'
				)
		) claimType
  
	where
		cl.CountryKey = 'AU' and
		cl.ReceivedDate >= @sd and cl.ReceivedDate < dateadd(day,1,@rptEndDate)
	)as aa
group by
	aa.[Received Month]


--select
--	aa.[Received Month],
--	sum(case when aa.OnlineClaim = '1' then 1 else 0 end) as [OnlineClaim Count],
--	Count(aa.ClaimKey) as [Total Claim Count],
--	cast(sum(case when aa.OnlineClaim = '1' then 1 else 0 end) as money) / nullif(cast(Count(aa.ClaimKey) as money),0) as [OnlineClaim %],
--	count(tele.ClaimKey) as [TeleClaims],
--	cast(count(tele.ClaimKey) as money) / nullif(cast(Count(aa.ClaimKey) as money),0) as [% of TeleClaims]
--into #zz7
--from
--	(--aa
--	select
--		cast((cast(year(cl.ReceivedDate) as nvarchar) + '-' + cast(month(cl.ReceivedDate) as nvarchar) + '-01') as date) as [Received Month],
--		cl.ClaimKey,
--		cl.OnlineClaim
--	from 
--		clmClaim cl
--	where
--		cl.CountryKey = 'AU'
--	)as aa
--outer apply
--	(-- tele
--	select distinct 
--		cc.ClaimKey
--	from
--		(--cc
--		select
--			aa.ClaimKey,
--			aa.CaseOfficer,
--			aa.[Claim Created Date]
--		from
--			(--aa
--			select -- New online claims from Claims.Net
--				c.ClaimKey,
--				case
--					when c.CreatedBy = 'Online Submitted' then isnull(u.[User DisplayName], '')
--					else c.CreatedBy collate database_default
--				end as [CaseOfficer],
--				cast(c.CreateDate as date) as [Claim Created Date]
--			from clmClaim c
--			outer apply
--				(
--				select top 1
--					a_u.DisplayName as [User DisplayName]
--				from 
--					usrLDAP a_u
--				where
--						a_u.UserName = c.OnlineConsultant
--				) as u
--			where
--				c.CountryKey = 'AU' and
--				c.OnlineClaim = 1
--				--and c.CreateDate >= '2016-06-19'
--			)as aa
--		inner join
--			(
--			select distinct
--				d.AgentName as [CaseOfficer],
--				cast(d.CallDate as date) as [TeleClaim Date]
--			from 
--				[dbo].[vTelephonyCallData] d
--			where
--				(d.Team like '%claim%' or d.CSQName like '%claim%')
--				and d.CSQName like '%tele%claim%'
--			) as bb on aa.CaseOfficer = bb.CaseOfficer and aa.[Claim Created Date] = bb.[TeleClaim Date] -- Join telephony call history. A claim is considered 'Teleclaim' only when both the case officer and claim date have a match in telephony call history.
				
--		union all

--		select -- TeleClaims from e5
--			w.ClaimKey,
--			w.AssignedUser as [CaseOfficer],
--			cast(w.CreationDate as date) as [Claim Created Date]
--		from 
--			e5work w
--		left join e5WorkProperties wp on wp.Work_ID = w.Work_ID 
--		where
--			w.Country = 'AU'
--			and (w.WorkType like 'claim%' or w.WorkType in ('Phone Call', 'Complaints', 'Recovery', 'Investigation'))
--			and wp.PropertyValue in (272,273) --Teleclaims, AssistanceTeleclaims
--			and w.ClaimKey is not null
--		)as cc
--	where
--		cc.ClaimKey = aa.ClaimKey
--	) as tele
--where
--	aa.[Received Month] >= @sd and aa.[Received Month] < dateadd(day,1,@rptEndDate)
--group by
--	aa.[Received Month]
----END zz7--------------------------------------------------------

----BEGIN zz9--------------------------------------------------------
IF OBJECT_ID('tempdb..#zz9') IS NOT NULL DROP TABLE #zz9
select
	m.CurMonthStart as [Month],
	zz9.*
into #zz9
from 
	#temp_m m
outer apply
	(-- zz9
	select
		count(distinct aa.ClaimKey) as [New Claims with End-of-Month <=$1000]
	from
		(--aa
		select
		cii.ClaimKey,
		cast((cast(year(cii.IncurredDate) as nvarchar) + '-' + cast(month(cii.IncurredDate) as nvarchar) + '-01') as date) as [Incurred Month]
		from 
			#temp_cii cii with(nolock) --on cii.ClaimKey = cl.ClaimKey
		where
			cii.NewCount > 0 and
			cii.IncurredDate >= m.CurMonthStart and cii.IncurredDate < m.NextMonthStart
		)as aa
	outer apply
			(
			select
				sum(a_c.IncurredDelta) as [End-of-Month IncurredValue]
			from 
				vclmClaimIncurred a_c
			where
				a_c.ClaimKey = aa.ClaimKey and
				a_c.IncurredDate < dateadd(month,1,aa.[Incurred Month])	
			) as EoM
	where
		eom.[End-of-Month IncurredValue] <= 1000
		and aa.[Incurred Month] >= @sd
	) as zz9
----END zz9--------------------------------------------------------

----BEGIN zz9a--------------------------------------------------------
IF OBJECT_ID('tempdb..#zz9a') IS NOT NULL DROP TABLE #zz9a
select
	m.CurMonthStart as [Month],
	zz9a.*
into #zz9a
from 
	#temp_m m
outer apply
	(-- zz9a
	select
		count(distinct aa.ClaimKey) as [Existing Claims (Opening Balance) with End-of-Month <=$1000]
	from
		(--aa
		select 
			cii.ClaimKey, -- Opening Balance
			m.CurMonthStart as [Month Start]
		from
			#temp_cii cii with(nolock)
		where
			cii.ClaimKey like 'AU%' and
			cii.IncurredDate < m.CurMonthStart
		group by
			cii.ClaimKey
		having 
			sum(cii.NewCount + cii.ReopenedCount - cii.ClosedCount) > 0
		)as aa	
	outer apply
		(
		select
			sum(a_c.IncurredDelta) as [End-of-Month IncurredValue]
		from 
			vclmClaimIncurred a_c
		where
			a_c.ClaimKey = aa.ClaimKey and
			a_c.IncurredDate < dateadd(month,1,aa.[Month Start]) -- First day of next month
		) as EoM
	where
		eom.[End-of-Month IncurredValue] <= 1000
		and aa.[Month Start] >= @sd
	) as zz9a
----END zz9a--------------------------------------------------------

----BEGIN zz10--------------------------------------------------------
IF OBJECT_ID('tempdb..#zz10') IS NOT NULL DROP TABLE #zz10
select
	bb.[First Settlement Month],
	sum(bb.LeadTime) / nullif(count(bb.SectionKey),0) as [Settlement Days (avg)],
	sum(case when isnull(bb.OperationalBenefitGroup,'') = 'Medical' then bb.LeadTime else 0 end) / nullif(sum(case when isnull(bb.OperationalBenefitGroup,'') = 'Medical' then 1 else 0 end),0) as [Settlement Days (avg) - Medical],
	sum(case when isnull(bb.OperationalBenefitGroup,'') = 'Cancellation' then bb.LeadTime else 0 end) / nullif(sum(case when isnull(bb.OperationalBenefitGroup,'') = 'Cancellation' then 1 else 0 end),0) as [Settlement Days (avg) - Cancellation],
	sum(case when isnull(bb.OperationalBenefitGroup,'') = 'Luggage' then bb.LeadTime else 0 end) / nullif(sum(case when isnull(bb.OperationalBenefitGroup,'') = 'Luggage' then 1 else 0 end),0) as [Settlement Days (avg) - Luggage],
	sum(case when isnull(bb.OperationalBenefitGroup,'') = 'Other' then bb.LeadTime else 0 end) / nullif(sum(case when isnull(bb.OperationalBenefitGroup,'') = 'Other' then 1 else 0 end),0) as [Settlement Days (avg) - Other]
into #zz10
from
	(--bb
	select
		aa.SectionKey,
		aa.OperationalBenefitGroup,
		case 
			when aa.[LeadTime - First Nil Estimate] is null then aa.[LeadTime - First Payment]
			else 
				case
					when aa.[LeadTime - First Nil Estimate] >= aa.[LeadTime - First Payment] then aa.[LeadTime - First Payment]
					else aa.[LeadTime - First Nil Estimate]
				end			 
		end as [LeadTime],
		aa.[First Payment Month],
		aa.[First Nil Month],
		case 
			when aa.[LeadTime - First Nil Estimate] is null then aa.[First Payment Month]
			else 
				case
					when aa.[LeadTime - First Nil Estimate] >= aa.[LeadTime - First Payment] then aa.[First Payment Month]
					else aa.[First Nil Month]
				end			 
		end as [First Settlement Month],
		aa.[LeadTime - First Nil Estimate],
		aa.[LeadTime - First Payment]
	from
		(--aa
		select 
			cpm.SectionKey,
			vb.OperationalBenefitGroup,
			datediff(d, convert(date, cl.ReceivedDate), cpm.PaymentDate) + 1.00 as [LeadTime - First Payment],
			datediff(d, convert(date, cl.ReceivedDate), cl.FirstNilDate) + 1.00 as [LeadTime - First Nil Estimate],
			--case when isnull((datediff(d, convert(date, cl.ReceivedDate), cpm.PaymentDate)),0) < isnull((datediff(d, convert(date, cl.ReceivedDate), cl.FirstNilDate)),0) then (isnull(datediff(d, convert(date, cl.ReceivedDate), cpm.PaymentDate),0) + 1.00) else (isnull(datediff(d, convert(date, cl.ReceivedDate), cl.FirstNilDate),0) + 1.00) end as [LeadTime],
			cast((cast(year(cpm.PaymentDate) as nvarchar) + '-' + cast(month(cpm.PaymentDate) as nvarchar) + '-01') as date) as [First Payment Month],
			cast((cast(year(cl.FirstNilDate) as nvarchar) + '-' + cast(month(cl.FirstNilDate) as nvarchar) + '-01') as date) as [First Nil Month]
		from
			clmClaimPaymentMovement cpm
		inner join clmClaim cl on cl.ClaimKey = cpm.ClaimKey
		left join clmSection s on s.SectionKey = cpm.SectionKey
		left join vclmBenefitCategory vb on vb.BenefitSectionKey = s.BenefitSectionKey
		where
			cl.CountryKey = 'AU'
			and cpm.FirstPayment = 1
			--and cl.ReceivedDate >= @sd
		)as aa
	)as bb
where
	bb.[First Settlement Month] >= @sd
group by
	bb.[First Settlement Month]
----END zz10--------------------------------------------------------

----BEGIN zz11--------------------------------------------------------
IF OBJECT_ID('tempdb..#zz11') IS NOT NULL DROP TABLE #zz11
select
	DATEADD(month, DATEDIFF(month, 0, c.AccountingDate), 0) as [Accounting Month],
	sum(c.PreFirstNilPayment) as [PreFirstNilPayment],
	sum(c.PostFirstNilPayment) as [PostFirstNilPayment],
	count(distinct c.PreFirstNilCount) as [PreFirstNilCount],
	count(distinct c.PostFirstNilCount) as [PostFirstNilCount],

	sum(case when b.BenefitCategory = 'Medical and Dental' then c.PreFirstNilPayment else 0 end) as [PreFirstNilPayment - Medical],
	sum(case when b.BenefitCategory = 'Cancellation' then c.PreFirstNilPayment else 0 end) as [PreFirstNilPayment - Cancellation],
	sum(case when b.BenefitCategory = 'Luggage and Travel Documents' then c.PreFirstNilPayment else 0 end) as [PreFirstNilPayment - Luggage],
	sum(case when b.BenefitCategory not in ('Medical and Dental','Cancellation','Luggage and Travel Documents') then c.PreFirstNilPayment else 0 end) as [PreFirstNilPayment - Other],

	count(distinct case when b.BenefitCategory = 'Medical and Dental' then c.PreFirstNilCount else null end) as [PreFirstNilCount - Medical],
	count(distinct case when b.BenefitCategory = 'Cancellation' then c.PreFirstNilCount else null end) as [PreFirstNilCount - Cancellation],
	count(distinct case when b.BenefitCategory = 'Luggage and Travel Documents' then c.PreFirstNilCount else null end) as [PreFirstNilCount - Luggage],
	count(distinct case when b.BenefitCategory not in ('Medical and Dental','Cancellation','Luggage and Travel Documents') then c.PreFirstNilCount else null end) as [PreFirstNilCount - Other]
into #zz11
from 
	[db-au-star].[dbo].[vfactClaimPaymentMovement] c
	inner join [db-au-star].[dbo].[dimBenefit] b on b.BenefitSK = c.BenefitSK
where
	c.ClaimKey like 'AU%'
	and c.AccountingDate >= @sd
group by
	DATEADD(month, DATEDIFF(month, 0, c.AccountingDate), 0)
----END zz11--------------------------------------------------------

----BEGIN zz13--------------------------------------------------------
IF OBJECT_ID('tempdb..#zz13') IS NOT NULL DROP TABLE #zz13
select
	DATEADD(month, DATEDIFF(month, 0, bb.[Subsequent Status DateTime]), 0) as [Breaching Month],
	count(bb.ClaimNo) as [No of claims outside of 10 days]
into #zz13
from
	(--bb
	select
		aa.*,
		ROW_NUMBER() over(partition by aa.ClaimNo, aa.[Active Event DateONLY] order by [Active Event DateTime] asc) as [X]
	from
		(--aa
		select
			cl.ClaimNo,
			w.StatusName as [Claim Status],
			cl.CreateDate,
			w.AssignedUser,
			we.EventDate as [Active Event DateTime],
			cast(we.EventDate as date) as [Active Event DateONLY],
			ss.StatusName as [Subsequent Status],
			ss.EventDate as [Subsequent Status DateTime],
			ss.EventUser as [Event User],
			ss.Detail,
			--floor(cast(datediff(minute,we.EventDate, ss.EventDate) as money) / 1440) as [Days in Between],
			datediff(day,we.EventDate, ss.EventDate) as [Days in Between],
			nwd.[Non-Workings Days in Between],
			datediff(day,we.EventDate, ss.EventDate) - nwd.[Non-Workings Days in Between] as [Workings Days in Between]
		from 
			e5Work w
		inner join clmClaim cl on cl.ClaimKey = w.ClaimKey
		inner join e5WorkEvent we on we.Work_ID = w.Work_ID
		outer apply
			( -- ss
			select top 1
				a_we.EventDate,
				a_we.StatusName,
				a_we.EventUser,
				a_we.Detail
			from 
				e5Work a_w
			inner join e5WorkEvent a_we on a_we.Work_ID = a_w.Work_ID
			where
				a_w.WorkType = 'Claim'
				and ((a_we.EventName = 'Changed Work Status' and a_we.StatusName <> 'Active') or (we.EventName = 'Completed Task' and we.StatusName = 'Rejected'))
				and a_we.EventName = 'Changed Work Status'
				and a_w.ClaimKey = w.ClaimKey
				and a_we.EventDate > we.EventDate
			order by
				a_we.EventDate asc
			) as ss
		outer apply
			( -- nwd
			select
				count(c.[Date]) as [Non-Workings Days in Between]
			from Calendar c
			where
				c.[Date] >= we.EventDate and
				c.[Date] <  dateadd(day, 1, cast(ss.EventDate as date)) and
				(
					c.isHoliday = 1 or
					c.isWeekEnd = 1
				)
			) as nwd
		where
			w.Country = 'AU'
			and w.WorkType = 'Claim'
			and (we.EventName = 'Changed Work Status')
			and we.StatusName = 'active'
			--and ss.EventDate >= '2016-08-01' and ss.EventDate < '2016-09-01'
			and ss.EventDate >= @sd and ss.EventDate < dateadd(day,1,@rptEndDate)
		)as aa
	where
		aa.[Workings Days in Between] > 10 -- A breach if no action has been taken in 11 days since a claim becomes active
	)as bb
where
	bb.[X] = 1
group by
	DATEADD(month, DATEDIFF(month, 0, bb.[Subsequent Status DateTime]), 0)
----END zz13--------------------------------------------------------

----BEGIN zz14--------------------------------------------------------
IF OBJECT_ID('tempdb..#zz14') IS NOT NULL DROP TABLE #zz14
select
	DATEADD(month, DATEDIFF(month, 0, w.CreationDate), 0) as [IDR Creation Month],
	count(case when w.GroupType = 'IDR' then w.Reference else null end) as [Internal Dispute Resolution - New Cases],
	count(case when w.GroupType = 'New' then w.Reference else null end) as [Complaint - New Cases]
into #zz14
from
	e5Work w
where
	isnull(w.Country, 'AU') = 'AU' and
	w.WorkType = 'Complaints' and    
	w.GroupType in ('NEW', 'IDR') and
	--w.ClaimKey is not null and
	w.CreationDate >= @sd
group by
	DATEADD(month, DATEDIFF(month, 0, w.CreationDate), 0)
----END zz14--------------------------------------------------------

----BEGIN zz15--------------------------------------------------------
IF OBJECT_ID('tempdb..#zz15') IS NOT NULL DROP TABLE #zz15
select 
	DATEADD(month, DATEDIFF(month, 0, w.CreationDate), 0) as [EDR Creation Month],
	count(distinct w.ClaimKey) as [External Dispute Resolution - New Cases]
into #zz15
from 
	e5work w
inner join e5WorkProperties wp on wp.Work_ID = w.Work_ID
where
	isnull(w.Country, 'AU') = 'AU' and
	wp.Property_ID = 'EDRReferral' and
	w.ClaimKey is not null and
	isnull(convert(varchar, PropertyValue),0) <> 0 and
	w.CreationDate >= @sd
group by
	DATEADD(month, DATEDIFF(month, 0, w.CreationDate), 0)
--END zz15--------------------------------------------------------

/* End Insert Sections into temp tables */







select
	m.CurMonthStart as [Month],	
	case 
		when m.CurMonthStart = @rptStartDate then 'Current Year'
		when m.CurMonthStart = dateadd(year,-1,@rptStartDate) then 'Previous Year'
	end as [Period Type],
	case 
		when m.CurMonthStart between 
										(select d.StartDate from vDateRange d where d.DateRange in ('Current Fiscal Year','Last Fiscal Year','Last 2 Fiscal Year') and d.StartDate <= @rptStartDate and d.EndDate > @rptStartDate) 
										and 
										--(select d.EndDate from vDateRange d where d.DateRange in ('Current Fiscal Year','Last Fiscal Year','Last 2 Fiscal Year') and d.StartDate <= @rptStartDate and d.EndDate > @rptStartDate) 
										@rptStartDate
		then 1
	end as [Is CYTD],
	case 
		when m.CurMonthStart between 
										(select d.StartDate from vDateRange d where d.DateRange in ('Current Fiscal Year','Last Fiscal Year','Last 2 Fiscal Year') and d.StartDate <= (select dateadd(year,-1,@rptStartDate)) and d.EndDate > (select dateadd(year,-1,@rptStartDate))) 
										and 
										--(select d.EndDate from vDateRange d where d.DateRange in ('Current Fiscal Year','Last Fiscal Year','Last 2 Fiscal Year') and d.StartDate <= (select dateadd(year,-1,@rptStartDate)) and d.EndDate > (select dateadd(year,-1,@rptStartDate))) 
										(select dateadd(year,-1,@rptStartDate))
		then 1
	end as [Is PYTD],
	zz4.[Paid - Medical] + zz4.[Paid - Cancellation] + zz4.[Paid - Luggage] + zz4.[Paid - Other] as [Claims Cost (PAID)],		-- #1		
	zz4.[Paid - Medical],				-- #2
	zz4.[Paid - Cancellation],			-- #3
	zz4.[Paid - Luggage],				-- #4
	zz4.[Paid - Other],					-- #5	
	(zz4.[Paid - Medical] + zz4.[Paid - Cancellation] + zz4.[Paid - Luggage] + zz4.[Paid - Other]) + (zz5.[Estimates Balance - Medical] + zz5.[Estimates Balance - Cancellation] + zz5.[Estimates Balance - Luggage] + zz5.[Estimates Balance - Other]) as [Claims Total Incurred Balance],		-- #6
	zz5.[Estimates Balance - Medical] + zz5.[Estimates Balance - Cancellation] + zz5.[Estimates Balance - Luggage] + zz5.[Estimates Balance - Other] as [Current Estimates Balance $],		-- #7
	zz5.[Estimates Balance - Medical],			-- #8
	zz5.[Estimates Balance - Cancellation],		-- #9
	zz5.[Estimates Balance - Luggage],			-- #10
	zz5.[Estimates Balance - Other],			-- #11
	zz1.Opening as [Opening Balance],						-- #12
	cast(zz3.[Closing Active Claims] as money) / nullif(cast((zz3.[Closing Active Claims] + zz3.[Closing Diarised Claims]) as money),0) as [% of Active Claims],			-- #13
	cast(zz3.[Closing Diarised Claims] as money) / nullif(cast((zz3.[Closing Active Claims] + zz3.[Closing Diarised Claims]) as money),0) as [% of Diarised Claims],		-- #14
	zz2.NewCount as [New Claims],							-- #15
	zz2.ReopenedCount as [Number of Claims Re-opened],		-- #16
	zz2.ClosedCount as [Claims Closed],		 				-- #17
	(zz1.Opening + zz2.NewCount + zz2.ReopenedCount - zz2.ClosedCount) as [Closing Balance (Outstanding Claims)],		-- #18	
	(zz6.[Total TA Time] / nullif(zz6.[Total Case Count],0)) as [Average Turnaround Time],	
	(zz6.[Total TA Time - AU] / nullif(zz6.[Total Case Count - AU],0)) as [Average Turnaround Time - AU],					-- #21
	(zz6.[Total TA Time - India] / nullif(zz6.[Total Case Count - India],0)) as [Average Turnaround Time - India],		-- #22
	(cast(zz2.[Fast Track Claim Closed by India] as money) / nullif(cast(zz2.NewCount as money),0)) as [Fast Tracks Completed by India - % of Total New Claims],		-- #23
	zz9.[New Claims with End-of-Month <=$1000],								-- #24
	zz9a.[Existing Claims (Opening Balance) with End-of-Month <=$1000],		-- #24
	zz9.[New Claims with End-of-Month <=$1000] + zz9a.[Existing Claims (Opening Balance) with End-of-Month <=$1000] as [Claims <=$1000],
	cast(zz2.[Fast Track Claim Closed by India] as money)  / nullif(cast((zz9.[New Claims with End-of-Month <=$1000] + zz9a.[Existing Claims (Opening Balance) with End-of-Month <=$1000]) as money),0) as [Fast Tracks Completed by India - % of total <=$1000 Claims],		-- #25
	zz2.[Fast Track Claim Closed by India],		-- #26
	zz7.[OnlineClaim Count],			
	zz7.[Total Claim Count],
	zz7.[OnlineClaim %],						-- #27
	zz7.TeleClaims,		
	zz7.[OnlineClaim %] - zz7.[% of TeleClaims] as [% of OnlineClaim by Customer/Agent],		-- #28
	zz7.[% of TeleClaims],	-- #29
	zz10.[Settlement Days (avg)],						
	zz10.[Settlement Days (avg) - Medical],			-- #30
	zz10.[Settlement Days (avg) - Luggage],			-- #31
	zz10.[Settlement Days (avg) - Cancellation],		-- #32
	zz10.[Settlement Days (avg) - Other],				-- #33
	zz11.[PreFirstNilPayment],
	zz11.PreFirstNilCount,
	zz11.PreFirstNilPayment / nullif(zz11.PreFirstNilCount,0) as [Average Claim Size at first closure - All Claims], -- [Pre First Nil Avg Payment]			-- #34
	zz11.PostFirstNilPayment,
	zz11.PostFirstNilCount,
	zz11.PostFirstNilPayment / nullif(zz11.PostFirstNilCount,0) as [Average re-open payment value - All Claims], --[Post First Nil Avg Payment]		-- #35
	(zz11.PreFirstNilPayment / nullif(zz11.PreFirstNilCount,0)) + (zz11.PostFirstNilPayment / nullif(zz11.PostFirstNilCount,0)) as [Sum of first closure claim value and average re-opens],		-- #36
	zz11.[PreFirstNilPayment - Medical] / nullif(zz11.[PreFirstNilCount - Medical],0) as [Average Claim Size at first closure - Medical],			-- #37
	zz11.[PreFirstNilPayment - Luggage] / nullif(zz11.[PreFirstNilCount - Luggage],0) as [Average Claim Size at first closure - Luggage],			-- #38
	zz11.[PreFirstNilPayment - Cancellation] / nullif(zz11.[PreFirstNilCount - Cancellation],0) as [Average Claim Size at first closure - Cancellation],			-- #39
	zz11.[PreFirstNilPayment - Other] / nullif(zz11.[PreFirstNilCount - Other],0) as [Average Claim Size at first closure - Other],			-- #40
	zz2.[Claims Denied],											-- #48
	cast(zz2.[Claims Denied] as money) / nullif(cast(zz2.ClosedCount as money),0) as [Denial Rate],		-- #47
	zz13.[No of claims outside of 10 days],							-- #49 -- Active status to subsequent status greater than 9 working days
	zz14.[Internal Dispute Resolution - New Cases],					-- #50
	zz14.[Complaint - New Cases],
	zz15.[External Dispute Resolution - New Cases],					-- #51	
	@DashboardMonth as [Dashboard Month],
	@rptStartDate as [StartDate],
	@rptEndDate as [EndDate]
from 
	#temp_m m
left join #zz1 zz1 on m.CurMonthStart = zz1.[Incurred Month]
left join #zz2 zz2 on m.CurMonthStart = zz2.[Incurred Month]
left join #zz3 zz3 on m.CurMonthStart = zz3.[Event Month]
left join #zz4 zz4 on m.CurMonthStart = zz4.[Incurred Month]
left join #zz5 zz5 on m.CurMonthStart = zz5.[Estimate Month]
left join #zz6 zz6 on m.CurMonthStart = zz6.[Month]
left join #zz7 zz7 on m.CurMonthStart = zz7.[Received Month]
left join #zz9 zz9 on m.CurMonthStart = zz9.[Month]
left join #zz9a zz9a on m.CurMonthStart = zz9a.[Month]
left join #zz10 zz10 on m.CurMonthStart = zz10.[First Settlement Month]
left join #zz11 zz11 on m.CurMonthStart = zz11.[Accounting Month]
left join #zz13 zz13 on m.CurMonthStart = zz13.[Breaching Month]
left join #zz14 zz14 on m.CurMonthStart = zz14.[IDR Creation Month]
left join #zz15 zz15 on m.CurMonthStart = zz15.[EDR Creation Month]

end
GO
