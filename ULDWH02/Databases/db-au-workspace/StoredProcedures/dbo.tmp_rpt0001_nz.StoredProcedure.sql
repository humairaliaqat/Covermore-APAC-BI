USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_rpt0001_nz]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[tmp_rpt0001_nz] @Year varchar(4)
as

SET NOCOUNT ON


/****************************************************************************************************/
--	Name:			dbo.rptsp_rpt0001
--	Author:			Linus Tor
--	Date Created:	20100310
--	Description:	This stored procedure calculates number of travellers by age by duration within
--					reporting period.
--	Parameters:		@ReportingPeriod: Value is D, W, MTD, M, YTD, Y, S
--					@StartDate: Enter if @ReportingPeriod = S. Format YYYY-MM-DD eg. 2010-01-01
--					@EndDate: Enter if @ReportingPeriod = S. Format YYYY-MM-DD eg. 2010-01-01
--	Parameters:
--	Change History:	20100310 - LT - Created
--					20100317 - LT - Changed LEFT JOINs to INNER JOINs since all link key values cannot be NULL.
--									Added filter for PPMULT.PPAGE to exclude non numeric values. This was 
--									causing conversion to integer errors when it encountered non numeric values.
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @Year varchar(4)
select @Year = '2007'
*/

declare @rptStartDate smalldatetime
declare @rptEndDate smalldatetime

select @rptStartDate = @Year + '-02-01', @rptEndDate = convert(varchar,convert(int,@Year) + 1) + '-01-31'
--select @rptStartDate, @rptEndDate

--select baseline data
select
	p.PolicyNo as PolicyNo,
	a.AgencyCode as AgencyCode,
	a.AgencyName as AgencyName,
	a.AgencyGroupCode as AgencyGroup,
	a.AgencySubGroupCode as AgencySubGroup,
	p.OldPolicyNo as PolicyNoOld,
	p.ProductCode as ProductCode,
	p.PolicyType as PolicyStatus,
	p.NumberOfChildren as NumOfChild,
	p.NumberOfAdults as NumOfAdult,
	p.NumberOfPersons as TotalPersons,
	p.NumberOfDays as CoverDuration,
	p.DepartureDate as DepartureDate,
	p.ReturnDate as ReturnDate,
	p.Destination as Destination,
	m.AddressState as PersonState,
	m.FirstName as FirstName,
	m.LastName as LastName,
	m.DateOfBirth as DOB,
	m.AgeAtDateOfIssue as Age,		
    case when m.AgeAtDateOfIssue between 0 and 34 then '0 - 34'
	   when m.AgeAtDateOfIssue between 35 and 49 then '35 - 44'
	   when m.AgeAtDateOfIssue between 50 and 59 then '45 - 54'
       when m.AgeAtDateOfIssue between 60 and 64 then '55 - 64'
       else '65+'
    end as AgeGroup,
  case when p.NumberOfDays  < 5 then '< 5 Days'
       when p.NumberOfDays  between 5 and 10 then '5 - 10 Days'
       when p.NumberOfDays  between 11 and 16 then '11 - 16 Days'
	   when p.NumberOfDays  between 17 and 29 then '17 - 29 Days'
       else '30 Days +'
  end as DurationGroup,
  @rptStartDate as rptStartDate,
  @rptEndDate as rptEndDate
from
	[db-au-cmdwh].dbo.Policy p
	join [db-au-cmdwh].dbo.Customer m on
		p.CustomerKey = m.CustomerKey and
		isNumeric(m.AgeAtDateOfIssue) = 1							--20100317_LT - exclude age value not numeric
	join [db-au-cmdwh].dbo.Agency a on
		p.AgencyKey = a.AgencyKey
where
	p.CountryKey = 'NZ' and
	p.DepartureDate between @rptStartDate and @rptEndDate and	--departure date
	p.PolicyType = 'N' and									--new policies only
	p.PlanCode not in ('D','DA2', 'DA4', 'DA6', 'DA8', 'DA15', 'DM', 'DS', 'PBA5', 'X', 'XBA5') and
	p.PolicyNo not in (select OldPolicyNo						--exclude new policies that were subsequently cancelled
					  from [db-au-cmdwh].dbo.Policy
					  where CountryKey = 'NZ' and
							DepartureDate between @rptStartDate and @rptEndDate and
							PolicyType = 'R' and
							PlanCode not in ('D','DA2', 'DA4', 'DA6', 'DA8', 'DA15', 'DM', 'DS', 'PBA5', 'X', 'XBA5') and
							OldPolicyNo <> 0
					  group by OldPolicyNo)
order by
	p.PolicyNo
GO
