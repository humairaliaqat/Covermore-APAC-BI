USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_ClaimCountByValue]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[tmp_ClaimCountByValue]
as

SET NOCOUNT ON


if object_id('tempdb..#section') is not null drop table #section
select
	s.ClaimKey,
	s.ClaimNo,
	convert(datetime,convert(varchar(8),c.ReceivedDate,120) + '01 00:00:00') as ReceivedDate,
	sum(s.EstimateValue) as EstimateValue
into #section	
from
	[db-au-cmdwh].dbo.clmClaim c
	join [db-au-cmdwh].dbo.clmSection s	on
		c.CountryKey = s.CountryKey and
		c.ClaimKey = s.ClaimKey
where
	c.CountryKey = 'AU' and
	convert(varchar(10),c.ReceivedDate,120) between '2010-07-01' and '2011-07-31'
group by
	s.ClaimKey,
	s.ClaimNo,
	convert(datetime,convert(varchar(8),c.ReceivedDate,120) + '01 00:00:00')

if object_id('tempdb..#payment') is not null drop table #payment
select
	p.ClaimKey,
	p.ClaimNo,
	sum(p.PaymentAmount) as PaymentAmount
into #payment	
from
	[db-au-cmdwh].dbo.clmPayment p
where
	p.CountryKey = 'AU' and
	p.ClaimKey in (select ClaimKey from #section) and
	p.PaymentStatus = 'PAID'
group by
	p.ClaimKey,
	p.ClaimNo

if object_id('tempdb..#main') is not null drop table #main
select 
	s.ReceivedDate,
	s.ClaimNo,
	sum(isNull(p.PaymentAmount,0)) as PaymentAmount,
	sum(isNull(s.EstimateValue,0)) as EstimateValue,
	sum(isNull(p.PaymentAmount,0) + isNull(s.EstimateValue,0)) as TotalValue
into #main	
from 
	#payment p
	right join #section s on
		p.ClaimKey = s.ClaimKey 
group by
	s.ReceivedDate,
	s.ClaimNo		
having
	sum(isNull(p.PaymentAmount,0) + isNull(s.EstimateValue,0)) >= 25000	
order by 1
    
select 
	a.ReceivedDate, 
	case when a.TotalValue between 25000 and 39999 then '25000-39999'
		 when a.TotalValue between 40000 and 49999 then '40000-49999'
		 when a.TotalValue >= 50000 then '50000+'
		 else '0'
    end as ValueBracket,
	a.ClaimNo, 
	a.TotalValue, 
	count(distinct a.ClaimNo)  as ClaimCount 
from 
	#main a
group by
	a.ReceivedDate, 
	case when a.TotalValue between 25000 and 39999 then '25000-39999'
		 when a.TotalValue between 40000 and 49999 then '40000-49999'
		 when a.TotalValue >= 50000 then '50000+'
		 else '0'
    end,
	a.ClaimNo, 
	a.TotalValue  
order by 1,2,3


drop table #payment
drop table #section    
drop table #main
GO
