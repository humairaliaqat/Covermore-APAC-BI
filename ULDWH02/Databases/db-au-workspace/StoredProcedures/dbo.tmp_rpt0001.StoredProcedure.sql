USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_rpt0001]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[tmp_rpt0001]  @Country varchar(3),
									@ReportingPeriod varchar(30), 
									@StartDate varchar(10),
									@EndDate varchar(10)
as

SET NOCOUNT ON


/****************************************************************************************************/
--	Name:			dbo.rptsp_rpt0001
--	Author:			Linus Tor
--	Date Created:	20100310
--	Description:	This stored procedure calculates number of travellers by age by duration within
--					reporting period.
--	Parameters:		@Country: AU, NZ, or UK
--					@ReportingPeriod: Value is standard date range or _User Defined
--					@StartDate: Enter if @ReportingPeriod = S. Format YYYY-MM-DD eg. 2010-01-01
--					@EndDate: Enter if @ReportingPeriod = S. Format YYYY-MM-DD eg. 2010-01-01
--	Parameters:
--	Change History:	20100310 - LT - Created
--					20100317 - LT - Changed LEFT JOINs to INNER JOINs since all link key values cannot be NULL.
--									Added filter for PPMULT.PPAGE to exclude non numeric values. This was 
--									causing conversion to integer errors when it encountered non numeric values.
--					20120518 - LT - Migrated from OXLEY.RPTDB.dbo.rpt0001
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @Country varchar(3)
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @Country = 'AU', @ReportingPeriod = 'Last Month', @StartDate = '2011-01-01', @EndDate = '2013-04-30'
*/


declare @rptStartDate smalldatetime
declare @rptEndDate smalldatetime


/* get reporting dates */
if @ReportingPeriod = '_User Defined'
  select @rptStartDate = convert(smalldatetime,@StartDate), @rptEndDate = convert(smalldatetime,@EndDate)
else
  select @rptStartDate = StartDate, @rptEndDate = EndDate
  from [db-au-cmdwh].dbo.vDateRange
  where DateRange = @ReportingPeriod


--get test & training policies
if object_id('tempdb..#rpt0001_testagency') is not null drop table #rpt001_testagency
select
	a.AgencyCode,
	a.AgencyName
into #rpt0001_testagency	
from
	[db-au-cmdwh].dbo.Agency a	
where
	a.CountryKey = @Country and
	a.AgencyStatus = 'Current' and
	(a.AgencyName like '%training%' or a.AgencyName like '%test%') and
	a.AgencyCode <> 'ZAAV132'					--valid agency: Centestage Insurance Brokers
order by
	a.AgencyName
		
--get refunded policies
if object_id('tempdb..#rpt0001_refund') is not null drop table #rpt0001_refund
select
	p.PolicyNo,
	p.OldPolicyNo
into #rpt0001_refund	
from
	[db-au-cmdwh].dbo.Policy p
where
	p.CountryKey = @Country and
	p.PolicyType = 'R' and
	p.DepartureDate between convert(varchar(10),@rptStartDate,120) and convert(varchar(10),@rptEndDate,120) and
	p.AreaType = 'International'
	
		
--select baseline data
select
	p.PolicyNo,
	a.AgencyGroupName,
	a.AgencyGroupCode,
	convert(datetime,convert(varchar(8),p.DepartureDate,120)+'01') as IssueMonth,
    case when c.AgeAtDateOfIssue between 0 and 34 then '0 - 34'
		when c.AgeAtDateOfIssue between 35 and 49 then '35 - 49'
		when c.AgeAtDateOfIssue between 50 and 59 then '50 - 59'
		when c.AgeAtDateOfIssue between 60 and 64 then '60 - 64'
		when c.AgeAtDateOfIssue between 65 and 69 then '65 - 69'
		when c.AgeAtDateOfIssue between 70 and 74 then '70 - 74'
		else '> 75'
    end as AgeGroup,
  case when p.NumberOfDays <= 7 then '< 1 Week'
       when p.NumberOfDays between 8 and 14 then '1 - 2 Weeks'
       when p.NumberOfDays between 15 and 28 then '2 - 4 Weeks'
	   when p.NumberOfDays between 29 and 60 then '1 - 2 Months'
	   when p.NumberOfDays between 61 and 90 then '2 - 3 Months'
       when p.NumberOfDays between 91 and 180 then '3 - 6 Months'
       when p.NumberOfDays between 181 and 365 then '6 - 12 Months'
       else '> 12 Months'
  end as DurationGroup,
	case when p.CountryKey = 'AU' then
			case when p.PlanCode in ('PBA5','CPBA5') then 'Area 6'
				 when p.PlanCode like '%1' and p.PlanCode not like '%D%' then 'Area 1'
				 when p.PlanCode like '%2' and p.PlanCode not like '%D%' then 'Area 2'
				 when p.PlanCode like '%3' and p.PlanCode not like '%D%' then 'Area 3'
				 when (p.PlanCode like '%4' or p.PlanCode like '%5') and p.PlanCode not like '%D%' then 'Area 4'
				 when (p.PlanCode in ('X','XM') or p.PlanCode like '%D%') then 'Area 5'
				 else 'Unknown'
			end
		 when p.CountryKey = 'NZ' then
			case when p.PlanCode like 'C%' or p.PlanCode like 'D%' then 'Area 8'
				 when p.PlanCode like 'A%' and Destination = 'Worldwide' then 'Area 10'
				 when p.PlanCode like 'A%' and Destination = 'Restricted Worldwide' then 'Area 11'
				 when p.PlanCode like 'A%' and Destination = 'South Pacific and Australia' then 'Area 12'
				 when p.PlanCode like 'A%' and Destination = 'New Zealand Only' then 'Area 13'
				 when p.PlanCode like 'A%' then 'Area 0'
				 when p.PlanCode like 'X%' or len(p.PlanCode) > 3 then 
					case when p.PlanCode like '%M%' then 'Area ' + convert(varchar, convert(int, substring(p.PlanCode, patindex('%[0-9]%', p.PlanCode), len(p.PlanCode) - patindex('%[0-9]%', p.PlanCode) + 1)) + 9)
						 else 'Area ' + substring(p.PlanCode, patindex('%[0-9]%', p.PlanCode), len(p.PlanCode) - patindex('%[0-9]%', p.PlanCode) + 1)
					end
				 else 'Unknown'
			end
		 else case 	when p.PlanCode like '%1' then 'Area 1'
					when p.PlanCode like '%2' then 'Area 2'
					when p.PlanCode like '%3' then 'Area 3'
					when p.PlanCode like '%4' then 'Area 4'
					when p.PlanCode like '%5' then 'Area 5'
					when p.PlanCode like '%6' then 'Area 6'
					when p.PlanCode like '%7' then 'Area 7'
					else 'Unknown'
				end
	end as AreaNo,  
  p.AreaType,
  count(p.PolicyNo) as PolicyCount,
  @rptStartDate as rptStartDate,
  @rptEndDate as rptEndDate
from
	[db-au-cmdwh].dbo.Policy p
	join [db-au-cmdwh].dbo.Agency a on
		p.AgencyKey = a.AgencyKey and
		a.AgencyStatus = 'Current'
	join [db-au-cmdwh].dbo.Customer c on
		p.CustomerKey = c.CustomerKey
where
	p.CountryKey = @Country and
	p.DepartureDate between convert(varchar(10),@rptStartDate,120) and convert(varchar(10),@rptEndDate,120) and
	p.PolicyType = 'N' and									--new policies only
	p.AreaType = 'International' and											--include international policies only
	p.PolicyNo not in (select OldPolicyNo from #rpt0001_refund)	and		--exclude refunded policies
	a.AgencyCode not in (select AgencyCode from #rpt0001_testagency)	--exclude test/training agencies
group by
	p.PolicyNo,
	a.AgencyGroupName,
	a.AgencyGroupCode,
	convert(datetime,convert(varchar(8),p.DepartureDate,120)+'01'),
    case when c.AgeAtDateOfIssue between 0 and 34 then '0 - 34'
		when c.AgeAtDateOfIssue between 35 and 49 then '35 - 49'
		when c.AgeAtDateOfIssue between 50 and 59 then '50 - 59'
		when c.AgeAtDateOfIssue between 60 and 64 then '60 - 64'
		when c.AgeAtDateOfIssue between 65 and 69 then '65 - 69'
		when c.AgeAtDateOfIssue between 70 and 74 then '70 - 74'
		else '> 75'
    end,
    case when p.NumberOfDays <= 7 then '< 1 Week'
       when p.NumberOfDays between 8 and 14 then '1 - 2 Weeks'
       when p.NumberOfDays between 15 and 28 then '2 - 4 Weeks'
	   when p.NumberOfDays between 29 and 60 then '1 - 2 Months'
	   when p.NumberOfDays between 61 and 90 then '2 - 3 Months'
       when p.NumberOfDays between 91 and 180 then '3 - 6 Months'
       when p.NumberOfDays between 181 and 365 then '6 - 12 Months'
       else '> 12 Months'
    end,
	case when p.CountryKey = 'AU' then
			case when p.PlanCode in ('PBA5','CPBA5') then 'Area 6'
				 when p.PlanCode like '%1' and p.PlanCode not like '%D%' then 'Area 1'
				 when p.PlanCode like '%2' and p.PlanCode not like '%D%' then 'Area 2'
				 when p.PlanCode like '%3' and p.PlanCode not like '%D%' then 'Area 3'
				 when (p.PlanCode like '%4' or p.PlanCode like '%5') and p.PlanCode not like '%D%' then 'Area 4'
				 when (p.PlanCode in ('X','XM') or p.PlanCode like '%D%') then 'Area 5'
				 else 'Unknown'
			end
		 when p.CountryKey = 'NZ' then
			case when p.PlanCode like 'C%' or p.PlanCode like 'D%' then 'Area 8'
				 when p.PlanCode like 'A%' and Destination = 'Worldwide' then 'Area 10'
				 when p.PlanCode like 'A%' and Destination = 'Restricted Worldwide' then 'Area 11'
				 when p.PlanCode like 'A%' and Destination = 'South Pacific and Australia' then 'Area 12'
				 when p.PlanCode like 'A%' and Destination = 'New Zealand Only' then 'Area 13'
				 when p.PlanCode like 'A%' then 'Area 0'
				 when p.PlanCode like 'X%' or len(p.PlanCode) > 3 then 
					case when p.PlanCode like '%M%' then 'Area ' + convert(varchar, convert(int, substring(p.PlanCode, patindex('%[0-9]%', p.PlanCode), len(p.PlanCode) - patindex('%[0-9]%', p.PlanCode) + 1)) + 9)
						 else 'Area ' + substring(p.PlanCode, patindex('%[0-9]%', p.PlanCode), len(p.PlanCode) - patindex('%[0-9]%', p.PlanCode) + 1)
					end
				 else 'Unknown'
			end
		 else case 	when p.PlanCode like '%1' then 'Area 1'
					when p.PlanCode like '%2' then 'Area 2'
					when p.PlanCode like '%3' then 'Area 3'
					when p.PlanCode like '%4' then 'Area 4'
					when p.PlanCode like '%5' then 'Area 5'
					when p.PlanCode like '%6' then 'Area 6'
					when p.PlanCode like '%7' then 'Area 7'
					else 'Unknown'
				end
	end,
	p.AreaType
order by
	a.AgencyGroupCode



drop table #rpt0001_testagency
drop table #rpt0001_refund



GO
