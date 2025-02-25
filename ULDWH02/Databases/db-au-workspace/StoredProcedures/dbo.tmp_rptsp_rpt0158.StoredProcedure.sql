USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_rptsp_rpt0158]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[tmp_rptsp_rpt0158]	@Country varchar(3),	
											@EarnedDate varchar(10),										
											@StartDate varchar(10),
											@EndDate varchar(10)
as

SET NOCOUNT ON


--uncomment to debug
/*
declare @Country varchar(3)
declare @EarnedDate varchar(10)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @Country = 'AU', @EarnedDate = '2011-03-31', @StartDate = '2010-04-01', @EndDate = '2011-03-31'
*/



declare @rptEarnedDate datetime
declare @rptStartDate datetime
declare @rptEndDate datetime
select	@rptEarnedDate = convert(datetime,@EarnedDate),
		@rptStartDate = convert(datetime,@StartDate),
		@rptEndDate = convert(datetime,@EndDate)
		
if object_id('tempdb..#testagencies') is not null drop table #testagencies
select AgencyCode
into #testagencies
from [db-au-cmdwh].dbo.Agency 
where
	CountryKey = @Country and 
	(Agencyname like '%test%' or agencyname like '%train%') and
	AgencyCode not in ('ZAAV132','TTQ1102')
	
if object_id('tempdb..#baseline') is not null drop table #baseline
select
	a.AgencyGroupCode as AgencyGroup,
	(select top 1 AgeAtDateOfIssue from [db-au-cmdwh].dbo.Customer where CountryKey = p.CountryKey and PolicyNo = p.PolicyNo) as Age,
	case when p.PlanCode like 'DA%' then 'DA'
		 when p.PlanCode like 'D%' then 'D'
		 when p.PlanCode like '%1' then '1'
		 when p.PlanCode like '%2' then '2'
		 when p.PlanCode like '%3' then '3'
		 when p.PlanCode like '%4' then '4'
		 when p.PlanCode like '%5' then '5'
		 else 'Unknown'
    end as Area,
	p.TripCost,
	case when datediff(day,p.IssuedDate,p.DepartureDate) <= 10 then '<= 10 days'
		 when datediff(day,p.IssuedDate,p.DepartureDate) between 11 and 15 then '11-15 days'
		 when datediff(day,p.IssuedDate,p.DepartureDate) between 16 and 20 then '16-20 days'
		 when datediff(day,p.IssuedDate,p.DepartureDate) between 21 and 30 then '21-30 days'
		 when datediff(day,p.IssuedDate,p.DepartureDate) between 31 and 60 then '31-60 days'
		 when datediff(day,p.IssuedDate,p.DepartureDate) between 61 and 90 then '61-90 days'
		 when datediff(day,p.IssuedDate,p.DepartureDate) between 91 and 120 then '91-120 days'
		 when datediff(day,p.IssuedDate,p.DepartureDate) between 121 and 150 then 'From 121 To 150 days'
		 when datediff(day,p.IssuedDate,p.DepartureDate) between 151 and 180 then 'From 151 To 180 days'
		 when datediff(day,p.IssuedDate,p.DepartureDate) > 180 then 'More than 180 days'
	end as LagDuration,
	p.Excess,
	case when p.NumberOfDays between 0 and 2 then '2 D'
		 when p.NumberOfDays between 3 and 5 then '5 D'
		 when p.NumberOfDays between 6 and 8 then '8 D'
		 when p.NumberOfDays between 9 and 11 then '11 D'
		 when p.NumberOfDays between 12 and 14 then '14 D'
		 when p.NumberOfDays between 15 and 17 then '17 D'
		 when p.NumberOfDays between 18 and 20 then '20 D'
		 when p.NumberOfDays between 21 and 23 then '23 D'
		 when p.NumberOfDays between 24 and 26 then '26 D'
		 when p.NumberOfDays between 27 and 29 then '29 D'
		 when p.NumberOfDays between 30 and 32 then '32 D'
		 when p.NumberOfDays between 33 and 35 then '5 W'
		 when p.NumberOfDays between 36 and 42 then '6 W'
		 when p.NumberOfDays between 43 and 49 then '7 W'
		 when p.NumberOfDays between 50 and 56 then '8 W'
		 when p.NumberOfDays between 57 and 63 then '9 W'		 
		 when p.NumberOfDays between 64 and 70 then '10 W'
		 when p.NumberOfDays between 71 and 92 then '3 M'
		 when p.NumberOfDays between 93 and 123 then '4 M'
		 when p.NumberOfDays between 124 and 153 then '5 M'
		 when p.NumberOfDays between 154 and 183 then '6 M'
		 when p.NumberOfDays between 184 and 213 then '7 M'
		 when p.NumberOfDays between 214 and 243 then '8 M'
		 when p.NumberOfDays between 244 and 274 then '9 M'
		 when p.NumberOfDays between 275 and 304 then '10 M'
		 when p.NumberOfDays between 305 and 335 then '11 M'
		 when p.NumberOfDays between 336 and 366 then '12 M'
		 else '> 12 M'
	end as DurationLong,	    		 
	p.PolicyNo,
	p.PolicyType,
	p.PlanCode,
	p.IssuedDate,
	@rptEarnedDate as EarnedDate,
	p.DepartureDate,
	p.ReturnDate,
	datediff(day,@rptEarnedDate,p.DepartureDate) as DaysDiffEarnedDepart,
	case when p.DepartureDate = p.ReturnDate then 1
	     else datediff(day,p.DepartureDate,p.ReturnDate)
	end as DaysDiffDepartReturn,	
	case when (p.PlanCode like 'C%' or p.PlanCode like 'XC%') AND (p.CancellationPremium <> 0) then 'CANX'
		 else 'NON-CANX'
    end as PremiumType,    
	case 	when p.ProductCode = 'CMB' then isNull(p.CancellationPremium,0) * (1 - (isNull(p.CommissionRate,0)/100)) * 1
			when p.ProductCode = 'CMS' then isNull(p.CancellationPremium,0) * (1 - (isNull(p.CommissionRate,0)/100)) * 1
			when p.ProductCode = 'CMT' then isNull(p.CancellationPremium,0) * (1 - (isNull(p.CommissionRate,0)/100)) * 1.9394
			when p.ProductCode = 'CME' then isNull(p.CancellationPremium,0) * (1 - (isNull(p.CommissionRate,0)/100)) * 1.9454
			when p.ProductCode = 'STA' then isNull(p.CancellationPremium,0) * (1 - (isNull(p.CommissionRate,0)/100)) * 1.808
			when p.ProductCode = 'CMO' then 
				case when p.CommissionTierID = 'CO-0' then isNull(p.CancellationPremium,0) * (1 - (isNull(p.CommissionRate,0)/100)) * 1
					 else case when p.VolumePercentage is null then isNull(p.CancellationPremium,0) * (1 - (isNull(p.CommissionRate,0)/100)) * 1
							   else isNull(p.CancellationPremium,0) * (1 - (isNull(p.CommissionRate,0)/100)) * p.VolumePercentage
						  end
				end
			else isNull(p.CancellationPremium,0) * (1 - (isNull(p.CommissionRate,0)/100)) * 1
	end as GrossCANX,
	case 	when P.ProductCode = 'CMB' then p.GrossPremiumExGSTBeforeDiscount
			when P.ProductCode = 'CMS' then p.GrossPremiumExGSTBeforeDiscount
			when P.ProductCode = 'CMT' then
				case when P.GSTOnGrossPremium = 0 then
						(((P.GrossPremiumExGSTBeforeDiscount-((P.GrossPremiumExGSTBeforeDiscount-P.ActualAdminFee)*0.1))-P.ActualAdminFee)*1.9394)
					 else ((P.GrossPremiumExGSTBeforeDiscount-((((P.GrossPremiumExGSTBeforeDiscount+P.GSTonGrossPremium-P.ActualAdminFee)*0.1)+P.ActualAdminFee)/1.1))*1.9394)
	   			end
			when P.ProductCode = 'CME' then 
				case when P.GSTOnGrossPremium = 0 then 			
						(((P.GrossPremiumExGSTBeforeDiscount-((P.GrossPremiumExGSTBeforeDiscount-P.ActualAdminFee)*0.1))-P.ActualAdminFee)*1.9454)
             	     else ((P.GrossPremiumExGSTBeforeDiscount-((((P.GrossPremiumExGSTBeforeDiscount+P.GSTonGrossPremium-P.ActualAdminFee)*0.1)+P.ActualAdminFee)/1.1))*1.9454)
				end
			when P.ProductCode = 'STA' then (P.GrossPremiumExGSTBeforeDiscount + P.GSTonGrossPremium - P.CommissionAmount - P.GSTOnCommission) * 1.808
			when P.ProductCode = 'CMO' then 
				case when P.CommissionTierID = 'CO-0' then P.GrossPremiumExGSTBeforeDiscount
					 else case when P.VolumePercentage is null then P.GrossPremiumExGSTBeforeDiscount
							   else (P.GrossPremiumExGSTBeforeDiscount - P.CommissionAmount) * P.VolumePercentage
						  end
				end
			else p.GrossPremiumExGSTBeforeDiscount
	end	as FinanceGrossedUp,
	p.GrossPremiumExGSTBeforeDiscount as PPRGT,
	p.CancellationPremium as PPCANX,
	case when p.PolicyType in ('N','E') then 1 
		 when p.PolicyType = 'R' and p.OldPolicyType in ('N','E') then -1 
		 else 0 
	end as NewPolicyCount,
	p.ActualCommissionAfterDiscount
into #baseline    	
from
	[db-au-cmdwh].dbo.Policy p
	join [db-au-cmdwh].dbo.Agency a on
		p.AgencyKey = a.AgencyKey and
		a.AgencyStatus = 'Current'
where
	p.CountryKey = @Country and
	p.IssuedDate between convert(varchar(10),@rptStartDate,120) and convert(varchar(10),@rptEndDate,120) and
	a.AgencyCode not in (select AgencyCode from #TestAgencies) and
	p.ProductCode = 'STA'  and
	a.AgencyGroupCode = 'ST'


select
	b.AgencyGroup,
	case when b.Age is null then '-'
		 when b.Age between 0 and 49 then '0 - 34'
		 when b.Age between 50 and 59 then '35 - 59'
		 when b.Age between 60 and 69 then '60 - 69'
		 when b.Age between 70 and 74 then '70 - 74'
		 when b.Age between 75 and 79 then '75 - 79'
		 when b.Age between 80 and 84 then '80 - 84'
		 else '> 84'
	end as Age,
	b.Area,
	b.TripCost,
	b.LagDuration,
	b.Excess,
	b.DurationLong,
	b.PremiumType,
	b.PolicyNo,
	b.IssuedDate,
	b.EarnedDate,
	b.DepartureDate,
	b.ReturnDate,
	case when b.PremiumType = 'CANX' then	
			case when b.EarnedDate < b.DepartureDate then
					case	when b.DaysDiffEarnedDepart > 88 then 0
							when b.DaysDiffEarnedDepart between 45 and 88 then b.GrossCANX * 0.065
							when b.DaysDiffEarnedDepart between 28 and 44 then b.GrossCANX * 0.169
							when b.DaysDiffEarnedDepart between 16 and 27 then b.GrossCANX * 0.26
							when b.DaysDiffEarnedDepart between 9 and 15 then b.GrossCANX * 0.351
							when b.DaysDiffEarnedDepart between 4 and 8	then b.GrossCANX * 0.449
							when b.DaysDiffEarnedDepart between 1 and 3	then b.GrossCANX * 0.559
							when b.DaysDiffEarnedDepart >= 0 then b.GrossCANX * 0.65
					end
				 else 0
			end
		 else 0
	end as PremiumEarnedPreDepart,
	case when b.PremiumType = 'CANX' then
			case when b.EarnedDate >= b.DepartureDate and b.EarnedDate < b.ReturnDate then 
					(b.GrossCANX * 0.65) + 
					(((convert(numeric(18,6),abs(b.DaysDiffEarnedDepart)) / convert(numeric(18,6),b.DaysDiffDepartReturn)) * 0.35) * b.GrossCANX) +
					(convert(numeric(18,6),abs(b.DaysDiffEarnedDepart)) / convert(numeric(18,6),b.DaysDiffDepartReturn)) * (b.FinanceGrossedUp - b.GrossCANX)
				 else 0
		    end
		 else
			case when b.EarnedDate > b.DepartureDate and b.EarnedDate < b.ReturnDate then (convert(numeric(18,6),abs(b.DaysDiffEarnedDepart)) / convert(numeric(18,6),b.DaysDiffDepartReturn)) * (b.FinanceGrossedUp - b.GrossCANX)
				 else 0
		    end
	end as PremiumEarnedPreReturn,
	case when b.PremiumType = 'CANX' then
			case when b.EarnedDate >= b.ReturnDate then b.GrossCANX + (b.FinanceGrossedUp - b.GrossCANX)
				 else 0
		    end
		 else
			case when b.EarnedDate >= b.ReturnDate then (b.FinanceGrossedUp - b.GrossCANX)
				 else 0
		    end
   end as PremiumEarnedPostReturn,
   b.DaysDiffEarnedDepart,
   b.DaysDiffDepartReturn,
   b.GrossCANX,
   (b.FinanceGrossedUp - b.GrossCANX) as GrossNONCANX,
   b.FinanceGrossedUp,
   b.PPRGT,
   b.PPCANX,
   b.NewPolicyCount,
   b.ActualCommissionAfterDiscount,
   @rptStartDate as rptStartDate,
   @rptEndDate as rptEndDate
from 
	#baseline b


drop table #baseline
drop table #testagencies
GO
