USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_repeat_customers]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[tmp_repeat_customers]
as

SET NOCOUNT ON


declare @rptLast6MonthsStart datetime
declare @rptLast6MonthsEnd datetime
declare @rptLast5YearsStart datetime
declare @rptLast5YearsEnd datetime

select @rptLast6MonthsStart = convert(datetime,convert(varchar(8),dateadd(month,-6,getdate()),120) + '01')
select @rptLast6MonthsEnd = dateadd(d,-1,convert(datetime,convert(varchar(8),getdate(),120) + '01'))
select @rptLast5YearsStart = dateadd(year,-5,@rptLast6MonthsStart)
select @rptLast5YearsEnd = dateadd(d,-1,@rptLast6MonthsStart)

--select @rptLast6MonthsStart, @rptLast6MonthsEnd, @rptLast5YearsStart, @rptLast5YearsEnd


if Object_id('tempdb..#CustomersLast6Months') is not null drop table #CustomersLast6Months
select *
into #CustomersLast6Months
from
(
select
	replace(Convert(varchar(8),c.DateOfBirth,112) + '-' + c.FirstName + '-' + c.LastName,' ','') as UniqueCustomer,
	convert(varchar(10),c.DateOfBirth,120) as DateOfBirth,
	c.FirstName,
	c.LastName
from
	Customer c
	join Policy p on
		c.CustomerKey = p.CustomerKey
    join Agency a on
		p.AgencyKey = a.AgencyKey		
where
	c.CountryKey = 'AU' and
	a.AgencyGroupCode = 'CM' and
	left(convert(varchar,c.PolicyNo),1) <> '9' and
	p.CreateDate between @rptLast6MonthsStart and @rptLast6MonthsEnd and
	c.PersonIsAdult = 1
group by
	replace(Convert(varchar(8),c.DateOfBirth,112) + '-' + c.FirstName + '-' + c.LastName,' ',''),
	convert(varchar(10),c.DateOfBirth,120),
	c.FirstName,
	c.LastName	
) a
where 
	a.UniqueCustomer not like '%--%' and
	a.UniqueCustomer is not null and
	a.UniqueCustomer not like '%test%'
order by
	a.UniqueCustomer	


if object_id('tempdb..#CustomersLast5Years') is not null drop table #CustomersLast5Years
select
	replace(Convert(varchar(8),c.DateOfBirth,112) + '-' + c.FirstName + '-' + c.LastName,' ','') as UniqueCustomer,
	convert(varchar(10),c.DateOfBirth,120) as DateOfBirth,
	c.FirstName,
	c.LastName,
	case when a.AgencyGroupCode = 'CM' then 1 else 0 end as 'RepeatDirect',
	case when a.AgencyGroupCode <> 'CM' then 1 else 0 end as 'NonDirect'     
into #CustomersLast5Years	
from
	Customer c
	join Policy p on
		c.CustomerKey = p.CustomerKey
    join Agency a on
		p.AgencyKey = a.AgencyKey		
where
	c.CountryKey = 'AU' and
	left(convert(varchar,c.PolicyNo),1) <> '9' and
	p.CreateDate between @rptLast5YearsStart and @rptLast5YearsEnd and
	c.PersonIsAdult = 1 and
	replace(Convert(varchar(8),c.DateOfBirth,112) + '-' + c.FirstName + '-' + c.LastName,' ','') in (select UniqueCustomer from #CustomersLast6Months)	
group by
	replace(Convert(varchar(8),c.DateOfBirth,112) + '-' + c.FirstName + '-' + c.LastName,' ',''),
	convert(varchar(10),c.DateOfBirth,120),
	c.FirstName,
	c.LastName,
	case when a.AgencyGroupCode = 'CM' then 1 else 0 end,
	case when a.AgencyGroupCode <> 'CM' then 1 else 0 end
order by 1	



if object_id('tempdb..#NewDirect') is not null drop table #NewDirect	
select
	a.UniqueCustomer,
	a.DateOfBirth,
	a.FirstName,
	a.LastName,
	case when b.UniqueCustomer is null then 1 else 0 end as NewDirect
into #NewDirect	
from 
	#CustomersLast6Months a
	left join #CustomersLast5Years b on
		a.UniqueCustomer = b.UniqueCustomer



if object_id('tempdb..#Others') is not null drop table #Others
select
	a.UniqueCustomer,
	a.DateOfBirth,
	a.FirstName,
	a.LastName,
	a.RepeatDirect,
	a.NonDirect
into #Others	
from 
	#CustomersLast5Years a
	join #NewDirect b on
		a.UniqueCustomer = b.UniqueCustomer and
		b.NewDirect = 0
		
if object_id('tempdb..#t') is not null drop table #t
select
	a.UniqueCustomer,
	a.DateOfBirth,
	a.FirstName,
	a.LastName,
	sum(isNull(b.NewDirect,0)) as NewDirect,
	sum(isNull(c.RepeatDirect,0)) as RepeatDirect,
	sum(isNull(c.NonDirect,0)) as NonDirect
into #t	
from
	#CustomersLast6Months a
	left join #NewDirect b on
		a.UniqueCustomer = b.UniqueCustomer and
		b.NewDirect = 1
	left join #Others c on
		a.UniqueCustomer = c.UniqueCustomer
group by
	a.UniqueCustomer,
	a.DateOfBirth,
	a.FirstName,
	a.LastName		
order by
	a.UniqueCustomer	
	
	
select
  a.UniqueCustomer,
  a.DateOfBirth,
  a.FirstName,
  a.LastName,
  a.NewDirect,
  a.RepeatDirect,
  a.NonDirect,
  @rptLast6MonthsStart as rptLast6MonthsStart,
  @rptLast6MonthsEnd as rptLast6MonthsEnd,
  @rptLast5YearsStart as rptLast5YearsStart,
  @rptLast5YearsEnd as rptLast5YearsEnd  
from
(  
select
  a.UniqueCustomer,
  replace(a.DateOfBirth,' ','') as DateOfBirth,
  replace(a.FirstName,' ','') as FirstName,
  replace(a.LastName,' ','') as LastName,
  a.NewDirect,
  case when a.RepeatDirect > 0 then 1 else 0 end as RepeatDirect,
  case when a.NonDirect > 0 then 1 else 0 end as NonDirect
from #t a
) a
group by
  a.UniqueCustomer,
  a.DateOfBirth,
  a.FirstName,
  a.LastName,
  a.NewDirect,
  a.RepeatDirect,
  a.NonDirect

drop table #CustomersLast6Months
drop table #CustomersLast5Years
drop table #NewDirect
drop table #Others
GO
