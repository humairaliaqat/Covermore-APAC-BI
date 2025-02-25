USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_case14094_tracypiriz]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[tmp_case14094_tracypiriz]
as

SET NOCOUNT ON

if object_id('tempdb..#TestAgencies') is not null drop table #TestAgencies
select distinct AgencyCode
into #TestAgencies 
from
 agency
where
  CountryKey = 'AU' and
  (AgencyName like '%test%' or
   AgencyName like '%training%')
  
  
select
	a.AgencyGroupName,
	a.AgencyCode,
	a.AgencyName,
	case when a.AgencyCode = 'CMFL000' and right(p.BatchNo,2) <> 'BC' then 'CM Phone Sales'	     
		 when right(p.BatchNo,2) = 'BC' then 'B2C Sales'
		 when right(p.BatchNo,2) = 'BB' then 'B2B Sales'
	     else 'Others'
	end as SalesChannel,
	sum(case when p.PolicyType in ('N','E') then 1 else 0 end) as NewPolicy,
	sum(case when p.PolicyType = 'R' and p.OldPolicyType in ('N','E') then 1 else 0 end) as CancelledPolicy
from
	[db-au-cmdwh].dbo.Policy p
	join [db-au-cmdwh].dbo.Agency a on
		p.CountryKey = a.CountryKey and
		p.AgencyKey = a.AgencyKey
where
	p.CountryKey = 'AU' and
	p.CreateDate between '2009-07-01' and '2010-10-31' and
	a.AgencyStatusCode in ('C','P') and
	a.AgencyCode not in (select AgencyCode from #TestAgencies)			
group by
	a.AgencyGroupName,
	a.AgencyCode,
	a.AgencyName,
	case when a.AgencyCode = 'CMFL000' and right(p.BatchNo,2) <> 'BC' then 'CM Phone Sales'	     
		 when right(p.BatchNo,2) = 'BC' then 'B2C Sales'
		 when right(p.BatchNo,2) = 'BB' then 'B2B Sales'
	     else 'Others'
	end

drop table #TestAgencies
GO
