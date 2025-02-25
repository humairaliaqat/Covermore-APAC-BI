USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0768a]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0768a] 
@Country varchar(10),
@Benefit varchar(50),
@DateRange varchar(30),
@StartDate varchar(20),
@EndDate varchar(20)
as

begin

/****************************************************************************************************/
--  Name:           rptsp_RPT0768a
--  Author:         Peter Zhuo
--  Date Created:   20160428
--  Description:    This report shows major loss bands (Claim incurred values of $0 - $15K, $15K - $25K, $25K - $75K, $75K - $200K, $200K - $500K, $500K +)
--					by the 4 common benefit categories (Medical, Cancellation, Luggage and Other).
--					This is a summary version of RPT0768, it also shows the how much the estimates and paid amounts change (variance $ and %) between day 0 
--					and day 14 and so on.
--
--  Parameters:     @Country
--					@Benefit: 4 common benefit categories (Medical, Cancellation, Luggage and Other)
--					@ReportingPeriod: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--					@EndDate: if_User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--   
--  Change History: 20160428 - PZ - Created
--                  
/****************************************************************************************************/

--uncomment to debug
--declare @Country varchar(10)
--declare @Benefit varchar(10)
--declare @DateRange varchar(30)
--declare @StartDate varchar(10)
--declare @EndDate varchar(10)
--select @DateRange = 'Current Fiscal Year', @StartDate = null, @EndDate = null
--select @Country = 'AU'
--select @Benefit = 'All'



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



IF OBJECT_ID('tempdb..#temp_a') IS NOT NULL DROP TABLE #temp_a
IF OBJECT_ID('tempdb..#temp_b') IS NOT NULL DROP TABLE #temp_b

-------------------------------------------------------------------------


select -- Must have this complate dimension master to calculate the variance % correctly. 
*
into #temp_b
from
	(--aa
	select 'Medical' as [Benefit Band] union all
	select 'Cancellation' as [Benefit Band] union all
	select 'Luggage' as [Benefit Band] union all
	select 'Other' as [Benefit Band]
	) as aa
cross apply
	(
	select '$0 - $15K' as [Major Loss Band], 1 as [Major Loss Band #] union all
	select '$15K - $25K' as [Major Loss Band], 2 as [Major Loss Band #] union all
	select '$25K - $75K' as [Major Loss Band], 3 as [Major Loss Band #] union all
	select '$75K - $200K' as [Major Loss Band], 4 as [Major Loss Band #] union all
	select '$200K - $500K' as [Major Loss Band], 5 as [Major Loss Band #] union all
	select '$500K +' as [Major Loss Band], 6 as [Major Loss Band #]
	) as bb
cross apply
	(
	select 'Open' as [Claim Status Group] union all
	select 'Closed' as [Claim Status Group]
	) as cc
cross apply
	(
	select 'Day 0' as [Age Band], 1 as [Age Band #] union all
	select 'Day 14' as [Age Band], 2 as [Age Band #] union all
	select 'Day 30' as [Age Band], 3 as [Age Band #] union all
	select 'Day 45' as [Age Band], 4 as [Age Band #] union all
	select 'Day 60' as [Age Band], 5 as [Age Band #] union all
	select 'Day 60 +' as [Age Band], 6 as [Age Band #]
	) as dd

-------------------------------------------------------------------------

SELECT
	cl.ClaimNo,
	isnull(cp.[Absolute Age],0) as [Claim Age],
	cp.[Claim Status],
	case when cp.[Claim Status] = 'Complete' then 'Closed' else 'Open' end as [Claim Status Group],
	b.BenefitCode,
	case 
		when vb.BenefitCategory = 'Medical and Dental' then 'Medical'
		when vb.BenefitCategory = 'Cancellation' then 'Cancellation'
		when vb.BenefitCategory = 'Luggage and Travel Documents' then 'Luggage'
		else 'Other'
	end
	as [Benefit Band],
	isnull(s.EstimateValue,0) as [Estimate],
	isnull(pm.PaymentAmount,0) as [Paid]
into #temp_a
FROM clmSection s
left join clmBenefit b on b.BenefitSectionKey = s.BenefitSectionKey
left join vclmBenefitCategory vb on vb.BenefitSectionKey = b.BenefitSectionKey
left JOIN clmEvent e ON (e.EventKey=s.EventKey and s.isDeleted = 0)
inner JOIN clmClaim cl ON cl.ClaimKey = s.ClaimKey
cross apply
    (
    select
        case
            when cl.ReceivedDate is null then cl.CreateDate
            when cl.ReceivedDate > dateadd(day, 1, convert(date, cl.CreateDate)) then cl.CreateDate
            else cl.ReceivedDate
        end as [ReceiptDate]
    ) as crd
outer apply
	(
	select
		sum(a_p.PaymentAmount) as [PaymentAmount]
	from clmPayment a_p
	where
		a_p.SectionKey = s.SectionKey
        --and a_p.PaymentStatus in ('PAID')
		and a_p.PaymentStatus in ('PAID','APPR')
        and a_p.isDeleted = 0
	)as pm
outer apply
	(
	select top 1
		a_cp.[Absolute Age],
		a_cp.[Status] as [Claim Status]
	from vClaimPortfolio a_cp
	where
		a_cp.ClaimKey = cl.ClaimKey
	) as cp
WHERE
	cl.CountryKey  = @Country
	and s.isDeleted = 0
	and crd.ReceiptDate >= @rptStartDate and crd.ReceiptDate < dateadd(d,1,@rptEndDate)
	

-------------------------------------------------------------------------------------

;with cte_a as
(
select
	a.[Benefit Band],
	bb.[Major Loss Band],
	bb.[Major Loss Band #],
	a.[Claim Status Group],
	bb.[Age Band],
	bb.[Age Band #],
	sum(a.Estimate) as [Estimate],
	sum(a.Paid) as [Paid]
from #temp_a a
cross apply
	(-- bb
	select
	--aa.ClaimNo,
	case
		when aa.[Claim Value] <= 15000 then '$0 - $15K'
		when aa.[Claim Value] > 15000 and aa.[Claim Value] <= 25000 then '$15K - $25K'
		when aa.[Claim Value] > 25000 and aa.[Claim Value] <= 75000 then '$25K - $75K'
		when aa.[Claim Value] > 75000 and aa.[Claim Value] <= 200000 then '$75K - $200K'
		when aa.[Claim Value] > 200000 and aa.[Claim Value] <= 500000 then '$200K - $500K'
		when aa.[Claim Value] > 500000 then '$500K +'
	end as [Major Loss Band],
	case
		when aa.[Claim Value] <= 15000 then 1
		when aa.[Claim Value] > 15000 and aa.[Claim Value] <= 25000 then 2
		when aa.[Claim Value] > 25000 and aa.[Claim Value] <= 75000 then 3
		when aa.[Claim Value] > 75000 and aa.[Claim Value] <= 200000 then 4
		when aa.[Claim Value] > 200000 and aa.[Claim Value] <= 500000 then 5
		when aa.[Claim Value] > 500000 then 6
	end as [Major Loss Band #],
	case
		when aa.[Claim Age] <= 0 then 'Day 0'
		when aa.[Claim Age] > 0 and aa.[Claim Age] <= 14 then 'Day 14'
		when aa.[Claim Age] > 14 and aa.[Claim Age] <= 30 then 'Day 30'
		when aa.[Claim Age] > 30 and aa.[Claim Age] <= 45 then 'Day 45'
		when aa.[Claim Age] > 45  and aa.[Claim Age] <= 60 then 'Day 60'
		when aa.[Claim Age] > 60 then 'Day 60 +'
	end as [Age Band],
	case
		when aa.[Claim Age] <= 0 then 1
		when aa.[Claim Age] > 0 and aa.[Claim Age] <= 14 then 2
		when aa.[Claim Age] > 14 and aa.[Claim Age] <= 30 then 3
		when aa.[Claim Age] > 30 and aa.[Claim Age] <= 45 then 4
		when aa.[Claim Age] > 45  and aa.[Claim Age] <= 60 then 5
		when aa.[Claim Age] > 60 then 6
	end as [Age Band #]
	from
		(--aa
		select
			a.ClaimNo,
			a.[Claim Age],
			sum(a.Estimate + a.Paid) as [Claim Value]
		from #temp_a a
		group by
			a.ClaimNo,
			a.[Claim Age]
		)as aa
	where
		aa.ClaimNo = a.ClaimNo
	) as bb
Where
	(a.[Benefit Band] = @Benefit or @Benefit = 'All')
group by
	a.[Benefit Band],
	bb.[Major Loss Band],
	bb.[Major Loss Band #],
	a.[Claim Status Group],
	bb.[Age Band],
	bb.[Age Band #]
)


,cte_b as
(
select
	b.*,
	isnull(a.Estimate,0) as [Estimate],
	isnull(a.Paid,0) as [Paid]
from #temp_b b
left join cte_a a on a.[Benefit Band] = b.[Benefit Band] and a.[Major Loss Band #] = b.[Major Loss Band #] and a.[Claim Status Group] = b.[Claim Status Group] and a.[Age Band #] = b.[Age Band #]
)



select
	@Country as [Country],
	@rptStartDate as [Start Date],
	@rptEndDate as [End Date],
	a.[Benefit Band],
	a.[Major Loss Band],
	a.[Major Loss Band #],
	a.[Claim Status Group],
	a.[Age Band],
	a.[Age Band #],
	cast(a.[Estimate] as money) as [Estimate],
	cast(a.[Paid] as money) as [Paid],
	cast(isnull(b.[Previous Estimate],0) as money) as [Previous Eatimate],
	cast(isnull(b.[Previous Paid],0) as money) as [Previous Paid]
	--(a.Estimate - isnull(b.[Previous Estimate],0)) as [Variance Estimate],
	--(a.Paid - isnull(b.[Previous Paid],0)) as [Variance Paid]
from cte_b a
outer apply
	(
	select top 1
		a_a.Estimate as [Previous Estimate],
		a_a.Paid as [Previous Paid]
	from cte_a a_a
	where
		a.[Major Loss Band] = a_a.[Major Loss Band] and a.[Claim Status Group] = a_a.[Claim Status Group] and a.[Benefit Band] = a_a.[Benefit Band]
		and a_a.[Age Band #] < a.[Age Band #]
	order by 
		a_a.[Age Band #] desc
	)as b

--order by
--	a.[Benefit Band],
--	a.[Major Loss Band],
--	a.[Claim Status Group],
--	a.[Age Band #]



end
GO
