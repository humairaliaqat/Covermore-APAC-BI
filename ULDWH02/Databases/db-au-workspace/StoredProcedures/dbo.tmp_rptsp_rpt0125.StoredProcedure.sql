USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_rptsp_rpt0125]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[tmp_rptsp_rpt0125]	@ReportingPeriod varchar(30),	
										@StartDate varchar(10),
										@EndDate varchar(10)
as

SET NOCOUNT ON 


/****************************************************************************************************/
--	Name:			rptsp_rpt0125
--	Author:			Sharmila Inbaseelan
--	Date Created:	20110124
--	Description:	This stored procedure includes the AU agents who sells a policy, where 
--					the policy number ends in '000' or '0000' 
--	Parameters:		@ReportingPeriod	--If value "User Dafined" enter Start Date and End Date
--					@StartDate			--Enter Start Date (Format:YYYY-MM-DD Eg 2010-01-01)
--					@EndDate			--Enter End Date   (Format:YYYY-MM-DD Eg 2010-01-01)
--	Parameters:
--	Change History:	20110124 - sharmilai - Created (Fogbugs Case_14767)
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @ReportingPeriod varchar(30)
declare @StartDate varchar (10)
declare @EndDate varchar (10)
select @ReportingPeriod = 'User Defined',@StartDate = '2011-02-01', @EndDate = '2011-05-31'
*/

declare @rptStartDate datetime
declare @rptEndDate datetime

--get reporting dates
if @ReportingPeriod = 'User Defined'
	select @rptStartDate = convert(smalldatetime,@StartDate), @rptEndDate = convert(smalldatetime,@EndDate)
else
	select @rptStartDate = StartDate, @rptEndDate = EndDate
	from [db-au-cmdwh].dbo.vDateRange
	where DateRange = @ReportingPeriod

--get plans
if object_id('tempdb..#rpt0125_plans') is not null drop table #rpt0125_plans
select
	pp.PlanCode,
	pp.PlanDesc,
	pp.ProductCode,
	pp.ProductCodeDisplay
into #rpt0125_plans
from [db-au-cmdwh].dbo.ProductPlan pp


--Get all the test/training agencies and Web Sales agencies
if OBJECT_ID('tempdb..#rpt0125_agency')is not null drop table #rpt0125_agency
select
	a.agencycode,
	a.AgencyName
into #rpt0125_agency 
from
	[db-au-cmdwh].dbo.Agency a 
where 
	a.CountryKey = 'AU' and 
	((a.AgencyName like '%websales%') or (a.AgencyName like '%web sales%') or
	(a.AgencyName like '%test%') or (a.AgencyName like '%test/training%') or (a.AgencyName like '%train%')) and 
	a.Agencycode not in ('ZAAV132','TTQ1102')
order by 
	a.AgencyName

--get win policies
if object_id('tempdb..#rpt0125_WinPolicies') is not null drop table #rpt0125_WinPolicies
select 
	c.ConsultantName,
	a.AgencyName,
	isNull(a.AddressStreet,'') + ' ' + isNull(a.AddressSuburb,'') + ' ' + isNull(a.AddressState,'') + ' ' + isNull(a.AddressPostCode,'') as AgencyAdress,
	a.Phone,
	p.AgencyCode,
	p.PolicyNo,
	p.IssuedDate,
	case when p.ProductCode= 'CMB' then 'Business'
		  when p.ProductCode= 'CMC' then 'Corporate'
		  when p.ProductCode= 'CME'	then 'Essentials'
		  when p.ProductCode= 'CMO' then 'Options'
		  when p.ProductCode= 'CMS' then 'Save-More'
		  when p.ProductCode= 'CMT' then 'Travelsure'
		  when p.ProductCode= 'STA' then 'STA Options'
		  else 'Other'
	end as ProductCode,
	p.PlanCode, 
	p.NumberOfDays,
	p.GrossPremiumExGSTBeforeDiscount as SellPriceExcGST,
	case when P.PolicyType ='N' then 'New Policy'
		  when p.PolicyType ='A' then 'Addon'
		  when p.PolicyType ='E' then 'Extension'
		  when p.PolicyType ='R' then 'Refund/Cancel'
	end	as PolicyType,
	p.ProductCode as LinkedProductCode,
	case when p.ProductCode = 'CMO'  and p.PlanCode like 'X' then 'D'
		 when p.ProductCode = 'CMO'  and p.PlanCode like 'X%' AND p.PlanCode NOT LIKE 'xc%' then replace(p.PlanCode, 'X', 'P') 
		 when p.ProductCode = 'CMO'  and p.PlanCode LIKE 'XC%' then replace(p.PlanCode, 'XC', 'CP') 
		 when p.ProductCode = 'CMO'  and p.PlanCode like 'XD%' then 'D'
		 when p.ProductCode = 'CMO'  and p.PlanCode like 'XM%' then replace(p.PlanCode, 'X', 'D') 
		 when p.ProductCode = 'CME'  and p.PlanCode like 'X' then 'D'
		 when p.ProductCode = 'CME' and  p.PlanCode like 'X%' AND p.PlanCode NOT LIKE 'xc%' then replace(p.PlanCode, 'X', 'P') 
		 when p.ProductCode = 'CME' and  p.PlanCode LIKE 'C%' then replace(p.PlanCode, 'XC','CP') 
		 when p.ProductCode = 'CME' and  p.PlanCode like 'XD%' then 'D'
		 when p.ProductCode = 'CME'  and p.PlanCode like 'XM%' then replace(p.PlanCode, 'X', 'D')
		 when p.ProductCode = 'CMT'  and p.PlanCode like 'X' then 'D'
		 when p.ProductCode = 'CMT'  and p.PlanCode like 'X%' AND p.PlanCode NOT LIKE 'xc%'then replace(p.PlanCode, 'X', 'T') 
		 when p.ProductCode = 'CMT'  and p.PlanCode LIKE 'XC%'then replace(p.PlanCode, 'XC', 'CT') 
		 when p.ProductCode = 'CMT'  and p.PlanCode like 'D%' then 'D'
		 when p.ProductCode = 'CMT'  and p.PlanCode like 'XM%' then replace(p.PlanCode, 'X', 'D')  
		 else p.PlanCode 
	end	as LinkedPlanCode
into #rpt0125_WinPolicies	
from 
	[db-au-cmdwh].dbo.Policy p 
	join [db-au-cmdwh].dbo.Consultant c on 
		p.ConsultantKey = c.ConsultantKey
	join [db-au-cmdwh].dbo.Agency a on 
		p.AgencyKey = a.AgencyKey
where 
	p.CountryKey = 'AU'	and 
	(right(p.PolicyNo,3) = '000' or right(p.PolicyNo,4) = '0000') and
	p.IssuedDate >= '2011-02-01' and
	p.PolicyType in ('N','R') and
	p.CreateDate between @rptStartDate and @rptEndDate and
	right(p.BatchNo,2) <> 'BC' and
	a.AgencyCode not in (select AgencyCode from #rpt0125_agency) and
	a.AgencyCode <> 'CMFL000'			--exclude CM Direct Phone Sales


if object_id('tempdb..#rpt0125_CancelledPolicies') is not null drop table #rpt0125_CancelledPolicies
select 
	p.OldPolicyNo
into #rpt0125_CancelledPolicies	
from
	[db-au-cmdwh].dbo.Policy p
	join [db-au-cmdwh].dbo.Agency a on 
		p.AgencyKey = a.AgencyKey
where
	p.CountryKey = 'AU'	and 
	(right(p.PolicyNo,3) = '000' or right(p.PolicyNo,4) = '0000') and
	p.IssuedDate >= '2011-02-01' and
	p.PolicyType = 'R' and
	p.CreateDate between @rptStartDate and @rptEndDate and
	right(p.BatchNo,2) <> 'BC' and
	a.AgencyCode not in (select AgencyCode from #rpt0125_agency)
							
select distinct
	p.ConsultantName,
	p.AgencyName,
	p.AgencyAdress,
	p.Phone,
	p.AgencyCode,
	p.PolicyNo,
	p.IssuedDate,
	p.ProductCode,
	p.PlanCode, 
	pl.PlanDesc,												
	p.NumberOfDays,
	p.SellPriceExcGST,
	p.PolicyType,
	@rptStartDate as StartDate,
	@rptEndDate as EndDate	
from
	#rpt0125_WinPolicies p
	join #rpt0125_Plans pl on
		p.LinkedProductCode = pl.ProductCodeDisplay and
		p.LinkedPlanCode = pl.PlanCode
where
	p.PolicyNo not in (select OldPolicyNo from #rpt0125_CancelledPolicies)
order by
	p.PolicyNo			

drop table #rpt0125_WinPolicies
drop table #rpt0125_CancelledPolicies
drop table #rpt0125_Agency
drop table #rpt0125_Plans
 
/*	
	and p.PolicyNo not in (select pp.OldPolicyNo --exclude new policies that were subsequently cancelled
							from [db-au-cmdwh].dbo.Policy pp
							inner join [db-au-cmdwh].dbo.Agency aa on aa.AgencyKey =pp.AgencyKey
							where pp.CountryKey ='AU'
							and pp.PolicyType ='R'
							and pp.IssuedDate >= '2011-02-01'
							and pp.CreateDate between @rptStartDate and @rptEndDate
							and ((RIGHT(pp.PolicyNo,3)='000')or(RIGHT(pp.PolicyNo,4)= '0000'))
							and ((right (pp.BatchNo,2))<> 'BC')
							and aa.AgencyCode not in (select #agency.AgencyCode from #agency)
							and aa.AgencyCode <> 'CMFL000'
							and pp.OldPolicyNo <> 0)
	and a.AgencyCode not in (select #agency.AgencyCode from #agency)
    and a.AgencyCode <> 'CMFL000' --exclude phone sales

Group by
	c.ConsultantName,
	a.AgencyName,
	(a.AddressStreet+' '+a.AddressSuburb+' '+a.AddressState+' '+a.AddressPostCode),
	a.Phone,
	p.AgencyCode,
	p.PolicyNo,
	p.IssuedDate,
	(case when p.ProductCode= 'CMB' then 'Business'
		  when p.ProductCode= 'CMC' then 'Corporate'
		  when p.ProductCode= 'CME'	then 'Essentials'
		  when p.ProductCode= 'CMO' then 'Options'
		  when p.ProductCode= 'CMS' then 'Save-More'
		  when p.ProductCode= 'CMT' then 'Travelsure'
		  when p.ProductCode= 'STA' then 'STA Options' else 'Other'
	end),
	p.PlanCode,
	p.NumberOfDays,
	(case when P.PolicyType ='N' then 'New Policy'
		  when p.PolicyType ='A' then 'Addon'
		  when p.PolicyType ='E' then 'Extension'
		  when p.PolicyType ='R' then 'Refund/Cancel'end),
	pl.plandesc,
	p.GrossPremiumExGSTBeforeDiscount
						
order by 
	p.PolicyNo 

*/
GO
