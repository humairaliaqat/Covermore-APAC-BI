USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_AMT_Analysis_ZacBrookes]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[tmp_AMT_Analysis_ZacBrookes]
as

declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @StartDate = '2010-01-01', @EndDate = '2012-12-31'


--AMT renewal

--1. get all AMT policies between 2009-12-01 and 2012-11-30
if object_id('tempdb..#raw') is not null drop table #raw
select
	convert(varchar(8),t.DOB,112) + '-' + t.LastName as TravellerHashKey,
	t.FirstName,
	t.LastName,
	t.DOB,
	t.isPrimary,
	o.GroupCode,
	o.GroupName,
	o.SubGroupCode,
	o.SubGroupName,
	p.PolicyNumber,
	p.IssueDate,
	p.StatusDescription,
	p.PolicyStart,
	p.PolicyEnd,
	p.DaysCovered,
	p.TripType,
	p.PlanName,
	pt.TransactionType,
	pt.TransactionStatus,
	pt.GrossPremium as SellPrice,
	pt.AdjustedNet as NetPrice,
	pt.AdultsCount as AdultsCount,
	pt.BasePolicyCount as PolicyCount
into #raw	
from
	[db-au-cmdwh].dbo.penPolicy p
	join [db-au-cmdwh].dbo.penPolicyTransSummary pt on p.PolicyKey = pt.PolicyKey
	join [db-au-cmdwh].dbo.penPolicyTraveller t on p.PolicyKey = t.PolicyKey
	join [db-au-cmdwh].dbo.penOutlet o on p.OutletSKey = o.OutletSKey
where
	p.CountryKey = 'AU' and
	p.IssueDate between @StartDate and @EndDate and
	((p.PlanName like '%M%' and p.TripType is null) or p.TripType = 'Annual Multi Trip') and
	p.StatusCode = 1 and
	pt.TransactionType = 'Base'
	

/*
if object_id('tempdb..#base') is not null drop table #base
select
	row_number() over(partition by a.TravellerHashKey order by a.PolicyNumber asc) as Row,
	a.TravellerHashKey,
	a.PolicyNumber,
	a.IssueDate,
	a.PolicyStart,
	a.PolicyEnd
into #base	
from #PrimaryTravellers a	
where a.TravellerHashKey <> '19000101-'
order by 2,3,1

select
	a.TravellerHashKey,
	max(case when a.[Row] = 1 then a.PolicyNumber else null end) as OriginalPolicy,
	max(case when a.[Row] = 1 then a.IssueDate else null end) as OriginalIssueDate,
	max(case when a.[Row] = 1 then a.PolicyStart else null end) as OriginalPolicyStart,
	max(case when a.[Row] = 1 then a.PolicyEnd else null end) as OriginalPolicyEnd,
	
	max(case when a.[Row] = 2 then a.PolicyNumber else null end) as FirstRenewalPolicy,
	max(case when a.[Row] = 2 then a.IssueDate else null end) as FirstRenewalIssueDate,
	max(case when a.[Row] = 2 then a.PolicyStart else null end) as FirstRenewalPolicyStart,
	max(case when a.[Row] = 2 then a.PolicyEnd else null end) as FirstRenewalPolicyEnd,
	
	max(case when a.[Row] = 3 then a.PolicyNumber else null end) as SecondRenewalPolicy,
	max(case when a.[Row] = 3 then a.IssueDate else null end) as SecondRenewalIssueDate,
	max(case when a.[Row] = 3 then a.PolicyStart else null end) as SecondRenewalPolicyStart,
	max(case when a.[Row] = 3 then a.PolicyEnd else null end) as SecondRenewalPolicyEnd,
	
	max(case when a.[Row] = 4 then a.PolicyNumber else null end) as ThirdRenewalPolicy,
	max(case when a.[Row] = 4 then a.IssueDate else null end) as ThirdRenewalIssueDate,
	max(case when a.[Row] = 4 then a.PolicyStart else null end) as ThirdRenewalPolicyStart,
	max(case when a.[Row] = 4 then a.PolicyEnd else null end) as ThirdRenewalPolicyEnd
from
	#base a	
group by a.TravellerHashKey
order by 1	
*/

select distinct
	t.TravellerHashKey,
	t.GroupCode,
	t.SubGroupCode,
	t.PolicyNumber,
	t.IssueDate,
	t.PolicyStart,
	t.PolicyEnd,
	t.SellPrice,
	t.NetPrice,
	t.AdultsCount,
	t.PolicyCount,
	o.PolicyNumber as RPolicyNumber,
	o.IssueDate as RIssueDate,
	o.PolicyStart as RPolicyStart,
	o.PolicyEnd as RPolicyEnd,
	o.SellPrice RSellPrice,
	o.NetPrice RNetPrice,
	o.AdultsCount RAdultsCount,
	o.PolicyCount RPolicyCount
from #raw t
outer apply (select r.PolicyNumber, r.IssueDate, r.PolicyStart, r.PolicyEnd, 
					r.SellPrice,r.NetPrice, r.AdultsCount, r.PolicyCount
			 from #raw r
			 where r.TravellerHashKey = t.TravellerHashKey and
				t.IssueDate between dateadd(d,-30,r.PolicyEnd) and dateadd(d,30,r.PolicyEnd)) o
order by
	t.TravellerHashKey,
	t.PolicyNumber
	



drop table #raw
--drop table #base
GO
