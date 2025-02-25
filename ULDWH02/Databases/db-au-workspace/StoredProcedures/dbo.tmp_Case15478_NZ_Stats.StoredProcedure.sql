USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_Case15478_NZ_Stats]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[tmp_Case15478_NZ_Stats] @ReportingPeriod varchar(30),				--values D, W, MTD, M, Q, YTD, Y, FY, FYTD, S
											@StartDate varchar(10),						--Enter if ReportingPeriod = S. Format YYYY-MM-DD
											@EndDate varchar(10)						--Enter if ReportingPeriod = S. Format YYYY-MM-DD
as

SET NOCOUNT ON



--uncomment to debug
/*
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @ReportingPeriod = 'User Defined', @StartDate = '2010-07-01', @EndDate = '2011-03-31'
*/

declare @rptStartDate smalldatetime
declare @rptEndDate smalldatetime
declare @SQL varchar(8000)

/* get reporting dates */
if @ReportingPeriod = 'User Defined'
  select @rptStartDate = convert(smalldatetime,@StartDate), @rptEndDate = convert(smalldatetime,@EndDate)
else
  select @rptStartDate = StartDate, @rptEndDate = EndDate
  from [db-au-cmdwh].dbo.vDateRange
  where DateRange = @ReportingPeriod


if object_id('tempdb..#New') is not null drop table #New
select
	p.CountryKey as NewCountryKey,
	p.PolicyNo as NewPolicyNo,
	p.PolicyType as NewPolicyType,
	p.PlanCode as NewPlanCode,
	p.ProductCode as NewProductCode
into #New	
from
	Policy p
where
	p.CountryKey = 'NZ' and
	p.PolicyType = 'N' and
	p.CreateDate between @rptStartDate and @rptEndDate		

if object_id('tempdb..#Old') is not null drop table #Old
select	
	pp.CountryKey as PostCountryKey,
	pp.PolicyNo as PostNewPolicyNo,
	pp.PolicyType as PostNewPolicyType,
	pp.PlanCode as PostPlanCode,
	pp.ProductCode as PostProductCode,
	pp.OldPolicyNo as OldPolicyNo
into #Old	
from
	Policy pp
where
	pp.CountryKey = 'NZ' and
	pp.CreateDate between @rptStartDate and @rptEndDate and
    pp.OldPolicyNo in (select NewPolicyNo from #New)


select
	n.NewPolicyNo,
	n.NewProductCode,
	n.NewPlanCode,
	o.PostNewPolicyNo,
	o.PostNewPolicyType,
	o.PostProductCode,
	o.PostPlanCode,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate
from
	#New n
	join #Old o on
		n.NewCountryKey = o.PostCountryKey and
		n.NewPolicyNo = o.OldPolicyNo
order by
	n.NewPolicyNo,
	o.PostNewPolicyNo

drop table #New
drop table #Old
	
/*
select
	p.PolicyNo,
	pp.OldPolicyNo,
	p.ProductCode,
	p.PolicyType,
	pp.OldPolicyType,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate
from
	Policy p
	left join Policy pp on
		p.CountryKey = pp.CountryKey and
		p.PolicyNo = pp.OldPolicyNo
where
	p.CountryKey = 'NZ' and
	p.CreateDate between @rptStartDate and @rptEndDate
order by
	pp.OldPolicyNo,
	p.PolicyNo			
*/
GO
