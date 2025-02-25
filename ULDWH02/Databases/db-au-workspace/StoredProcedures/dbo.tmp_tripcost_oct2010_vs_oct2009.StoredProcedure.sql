USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_tripcost_oct2010_vs_oct2009]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[tmp_tripcost_oct2010_vs_oct2009]
as

SET NOCOUNT ON

/*
Need for the month of Oct this year, what by single (and also by family) by age, by area, what number and % of each trip cost is taken.
Need this also for Oct last year based on old trip cost data.
Please advise soonest who will do, and how fast.
*/

if object_id('tempdb..#TestAgency') is not null drop table #TestAgency
select AgencyCode
into #TestAgency
from [db-au-cmdwh].dbo.Agency
where CountryKey = 'AU' and (AgencyName like 'ZZZ%' or AgencyName like '%test%' or AgencyName like '%training%')
group by AgencyCode

select
  p.DepartureDate,
  case when p.SingleFamily = 'F' then 'Family'
       when p.SingleFamily = 'S' then 'Single'
       else '_Unknown'
  end as SingleFamily,
  case when p.PlanCode like '%1' and p.PlanCode not like '%D%' then 'Area 1 - Worldwide'
       when p.PlanCode like '%2' and p.PlanCode not like '%D%' then 'Area 2 - Worldwide excluding the Americas and Africa'
       when p.PlanCode like '%3' and p.PlanCode not like '%D%' then 'Area 3 - UK and South East Asia'
       when (p.PlanCode like '%4' or p.PlanCode not like '%5') and p.PlanCode not like '%D%' then 'Area 4 - Indonesia and South West Pacific'
       when p.PlanCode like '%D%' then 'Area 5 - Australia'
       else 'Unknown'
  end as Area,
  case when c.AgeAtDateOfIssue between 0 and 20 then '< 21'
       when c.AgeAtDateOfIssue between 21 and 30 then '21 - 30'
       when c.AgeAtDateOfIssue between 31 and 40 then '31 - 40'
       when c.AgeAtDateOfIssue between 41 and 50 then '41 - 50'
       when c.AgeAtDateOfIssue between 51 and 60 then '51 - 60'
       else '> 60'
  end as Age,
  isNull(replace(p.TripCost,'.00',''),'_Unknown') as TripCost,
  sum(case when p.DepartureDate between '2010-10-01' and '2010-10-31' then 1 else 0 end) as PolicyCount2010,
  sum(case when p.DepartureDate between '2009-10-01' and '2009-10-31' then 1 else 0 end) as PolicyCount2009
from
  [db-au-cmdwh].dbo.Policy p
  join [db-au-cmdwh].dbo.Customer c on
	p.CountryKey = c.CountryKey and
	p.CustomerKey = c.CustomerKey
where
  p.CountryKey = 'AU' and
  p.PolicyType = 'N' and
  (p.DepartureDate between '2010-10-01' and '2010-10-31' or
   p.DepartureDate between '2009-10-01' and '2009-10-31') and
  p.AgencyCode not in (select AgencyCode from #TestAgency)
group by
  p.DepartureDate,
  case when p.SingleFamily = 'F' then 'Family'
       when p.SingleFamily = 'S' then 'Single'
       else '_Unknown'
  end,
  case when p.PlanCode like '%1' and p.PlanCode not like '%D%' then 'Area 1 - Worldwide'
       when p.PlanCode like '%2' and p.PlanCode not like '%D%' then 'Area 2 - Worldwide excluding the Americas and Africa'
       when p.PlanCode like '%3' and p.PlanCode not like '%D%' then 'Area 3 - UK and South East Asia'
       when (p.PlanCode like '%4' or p.PlanCode not like '%5') and p.PlanCode not like '%D%' then 'Area 4 - Indonesia and South West Pacific'
       when p.PlanCode like '%D%' then 'Area 5 - Australia'
       else 'Unknown'
  end,
  case when c.AgeAtDateOfIssue between 0 and 20 then '< 21'
       when c.AgeAtDateOfIssue between 21 and 30 then '21 - 30'
       when c.AgeAtDateOfIssue between 31 and 40 then '31 - 40'
       when c.AgeAtDateOfIssue between 41 and 50 then '41 - 50'
       when c.AgeAtDateOfIssue between 51 and 60 then '51 - 60'
       else '> 60'
  end,
  isNull(replace(p.TripCost,'.00',''),'_Unknown')

drop table #TestAgency
GO
