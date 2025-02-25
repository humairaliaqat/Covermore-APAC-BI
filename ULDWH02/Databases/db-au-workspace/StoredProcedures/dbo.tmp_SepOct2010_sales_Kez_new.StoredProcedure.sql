USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_SepOct2010_sales_Kez_new]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[tmp_SepOct2010_sales_Kez_new]
as

SET NOCOUNT ON


if object_id('tempdb..#t') is not null drop table #t
select
  a.AgencyGroupName,
  a.AgencySubGroupName,
  a.AgencyGroupState,
  a.BDMName,
  a.AgencyCode,
  a.Agencyname,
  sum(case when p.CreateDate between '2010-09-01' and '2010-09-30' then p.GrossPremiumExGSTBeforeDiscount else 0 end) as SepSellPrice,
  sum(case when p.CreateDate between '2010-09-01' and '2010-09-30' then
			case when p.PolicyType in ('N','E') then 1 
			     when p.PolicyType = 'R' and p.OldPolicyType in ('N','E') then -1
			     else 0 
			end		   
	  end) as SepPolicyCount,
  sum(case when p.CreateDate between '2010-10-01' and '2010-10-31' then p.GrossPremiumExGSTBeforeDiscount else 0 end) as OctSellPrice,
  sum(case when p.CreateDate between '2010-10-01' and '2010-10-31' then
			case when p.PolicyType in ('N','E') then 1 
			     when p.PolicyType = 'R' and p.OldPolicyType in ('N','E') then -1
			     else 0 
			end
	  end) as OctPolicyCount  
into #t	  	  
from
  Agency a
  join Policy p on
	a.CountryKey = p.CountryKey and
	a.AgencyKey = p.AgencyKey
where
  p.CountryKey = 'AU' and
  p.CreateDate between '2010-09-01' and '2010-10-31'	  
group by
  a.AgencyGroupName,
  a.AgencySubGroupName,
  a.AgencyGroupState,
  a.BDMName,
  a.AgencyCode,
  a.Agencyname


select 
  t.AgencyGroupName,
  t.AgencySubGroupName,
  t.AgencyGroupState,
  t.BDMName,
  t.AgencyCode,
  t.AgencyName,
  t.SepSellPrice,
  t.SepPolicyCount,
  t.OctSellPrice,
  t.OctPolicyCount,
  (case when t.SepSellPrice <> 0 then ((t.OctSellPrice - t.SepSellPrice)/t.sepSellPrice)*100 else 0 end) as VarSellPrice,
  (case when t.SepPolicyCount <> 0 then ((t.OctPolicyCount - t.SepPolicyCount)/t.SepPolicyCount)*100 else 0 end) as VarPolicyCount  
from #t t
order by
t.AgencyGroupName,
t.AgencySubGroupName,
t.AgencyGroupState,
(case when t.SepPolicyCount <> 0 then ((t.OctPolicyCount - t.SepPolicyCount)/t.SepPolicyCount)*100 else 0 end) desc
GO
