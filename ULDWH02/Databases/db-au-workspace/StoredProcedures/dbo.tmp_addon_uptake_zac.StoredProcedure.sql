USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_addon_uptake_zac]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[tmp_addon_uptake_zac]	@AgencySuperGroup varchar(50),
											@ReportingPeriod varchar(30),
											@StartDate varchar(10),
											@EndDate varchar(10)
as

SET NOCOUNT ON

declare @rptStartDate smalldatetime
declare @rptEndDate smalldatetime

/* get reporting dates */
if @ReportingPeriod = 'User Defined'
  select @rptStartDate = convert(smalldatetime,@StartDate), @rptEndDate = convert(smalldatetime,@EndDate)
else
  select @rptStartDate = StartDate, @rptEndDate = EndDate
  from [db-au-cmdwh].dbo.vDateRange
  where DateRange = @ReportingPeriod

  
if object_id('tempdb..#emc') is not null drop table #emc
select distinct
	replace(ltrim(rtrim((e.PolNo))),' ','') as PolicyNo
into #emc	
from
	oxley.emc.dbo.tblEMCApplications e
where
	e.[EnteredDt] >= '2010-07-01'	

select
	a.AgencySuperGroupName,
	a.AgencyGroupName,
	sum(case when p.PolicyType in ('N','E') then 1
		 when p.PolicyType = 'R' and p.OldPolicyType in ('N','E') then -1
		 else 0
	end) as NewPolicy,
	sum(case when p.PolicyType in ('N','E','A') and isNull(p.WintersportPremium,0) > 0 then 1
	     when p.PolicyType in ('R') and p.OldPolicyType in ('N','A','E') and isNull(p.WintersportPremium,0) > 0 then -1
	     else 0
	end) as Wintersport,
	sum(case when p.PolicyType in ('N','E','A') and isNull(p.MotorcyclePremium,0) > 0 then 1
	     when p.PolicyType in ('R') and p.OldPolicyType in ('N','A','E') and isNull(p.MotorcyclePremium,0) > 0 then -1
	     else 0
	end) as Motorcycle,
	sum(case when p.PolicyType in ('N','E','A') and isNull(p.LuggagePremium,0) > 0 then 1
	     when p.PolicyType in ('R') and p.OldPolicyType in ('N','A','E') and isNull(p.LuggagePremium,0) > 0 then -1
	     else 0
	end) as Luggage,
	sum(case when p.PolicyType in ('N','E','A') and isNull(p.RentalCarPremium,0) > 0 then 1
	     when p.PolicyType in ('R') and p.OldPolicyType in ('N','A','E') and isNull(p.RentalCarPremium,0) > 0 then -1
	     else 0
	end) as RentalCar,
	sum(case when p.PolicyType in ('N','E','A') and isNull(p.MedicalPremium,0) > 0 and e.PolicyNo is null then 1
	     when p.PolicyType in ('R') and p.OldPolicyType in ('N','A','E') and isNull(p.MedicalPremium,0) > 0 then -1
	     else 0
	end) as MedicalNoAssessment,
	sum(case when p.PolicyType in ('N','E','A') and isNull(p.MedicalPremium,0) > 0 and e.PolicyNo is not null then 1
	     when p.PolicyType in ('R') and p.OldPolicyType in ('N','A','E') and isNull(p.MedicalPremium,0) > 0 then -1
	     else 0
	end) as MedicalAssessment,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate
from
	[db-au-cmdwh].dbo.Agency a
	join [db-au-cmdwh].dbo.Policy p on
		a.AgencyKey = p.AgencyKey
	left join #emc e on
		convert(varchar,p.PolicyNo) = e.PolicyNo		
where
	p.CountryKey = 'AU' and
	a.AgencySuperGroupName like @AgencySuperGroup and
	p.CreateDate between convert(varchar(10),@rptStartDate,120) and convert(varchar(10),@rptEndDate,120)
group by
	a.AgencySuperGroupName,
	a.AgencyGroupName
order by
	a.AgencySuperGroupName,
	a.AgencyGroupName					
	
drop table #emc
GO
