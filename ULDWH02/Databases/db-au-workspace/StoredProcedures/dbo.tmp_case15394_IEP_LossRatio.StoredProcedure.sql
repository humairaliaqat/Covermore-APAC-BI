USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_case15394_IEP_LossRatio]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[tmp_case15394_IEP_LossRatio]
as

SET NOCOUNT ON

declare @EarnedDate datetime
select @EarnedDate = convert(varchar(10),getdate(),120)

select 
	convert(char(20),'Policy') as [Type],
	p.AgencyCode,
	convert(datetime,convert(varchar(8),p.CreateDate,120)+'01 00:00:00') as CreateMonth,
	sum(p.GrossPremiumExGSTBeforeDiscount) as Value,
	sum(case when p.PolicyType in ('N','E') then 1 when p.PolicyType = 'R' and p.OldPolicyType in ('N','E') then -1 else 0 end) as Tally
from
	[db-au-cmdwh].dbo.Policy p
where
	p.CountryKey = 'NZ' and
	p.AgencyKey in ('NZ-STZ0020','NZ-AAZ0004') and
	p.CreateDate between '2009-01-01' and '2011-04-30'
group by
	p.AgencyCode,
	convert(datetime,convert(varchar(8),p.CreateDate,120)+'01 00:00:00')	

union all

select 
	convert(char(20),'PolicyEarned') as [Type],
	p.AgencyCode,
	convert(datetime,convert(varchar(8),p.CreateDate,120)+'01 00:00:00') as CreateMonth,
	sum(case when @EarnedDate between p.DepartureDate and p.ReturnDate then 
				(convert(numeric(18,6),abs(datediff(day,@EarnedDate,p.DepartureDate))) / convert(numeric(18,6),datediff(day,p.DepartureDate,p.ReturnDate))) * p.GrossPremiumExGSTBeforeDiscount
			when @EarnedDate > p.ReturnDate then p.GrossPremiumExGSTBeforeDiscount		
			else 0	 
	end) as Value,
	0 as Tally
from
	[db-au-cmdwh].dbo.Policy p
where
	p.CountryKey = 'NZ' and
	p.AgencyKey in ('NZ-STZ0020','NZ-AAZ0004') and
	p.CreateDate between '2009-01-01' and '2011-04-30'
group by
	p.AgencyCode,
	convert(datetime,convert(varchar(8),p.CreateDate,120)+'01 00:00:00')

union all

select
	convert(char(20),'Claim') as [Type],
	c.AgencyCode,
	convert(datetime,convert(varchar(8),c.ReceivedDate,120)+'01 00:00:00') as CreateMonth,
	sum(p.PaymentAmount) as Value,
	count(distinct c.ClaimNo) as Tally
from
	[db-au-cmdwh].dbo.clmClaim c
	join [db-au-cmdwh].dbo.clmPayment p on
		c.CountryKey = p.CountryKey and
		c.ClaimKey = p.ClaimKey
where
	c.CountryKey = 'NZ' and
	c.AgencyCode in ('STZ0020','AAZ0004') and
	c.ReceivedDate between '2009-01-01' and '2011-04-30' and
	p.PaymentStatus in ('PAID','RECY')
group by
	c.AgencyCode,
	convert(datetime,convert(varchar(8),c.ReceivedDate,120)+'01 00:00:00')

union all

select
	convert(char(20),'ClaimEstimate') as [Type],
	c.AgencyCode,
	convert(datetime,convert(varchar(8),c.ReceivedDate,120)+'01 00:00:00') as CreateMonth,
	sum(s.EstimateValue) as Value,
	0 as Tally
from
	[db-au-cmdwh].dbo.clmClaim c
	join [db-au-cmdwh].dbo.clmSection s on
		c.CountryKey = s.CountryKey and
		c.ClaimKey = s.ClaimKey
where
	c.CountryKey = 'NZ' and
	c.AgencyCode in ('STZ0020','AAZ0004') and
	c.ReceivedDate between '2009-01-01' and '2011-04-30'
group by
	c.AgencyCode,
	convert(datetime,convert(varchar(8),c.ReceivedDate,120)+'01 00:00:00')
GO
