USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0832]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[rptsp_rpt0832]	@DateRange varchar(30),
									@StartDate varchar(10),
									@EndDate varchar(10)
as

SET NOCOUNT ON


/****************************************************************************************************/
--	Name:			dbo.rptsp_rpt0832
--	Author:			Linus Tor
--	Date Created:	20161107
--	Description:	This stored procedure returns traveller count by destination
--
--	Parameters:		@DateRange: default date range or '_User Defined'
--					@StartDate: if _User Defined enter date value (Format YYYY-MM-DD eg. 2010-01-01).
--					@EndDate: if _User Defined enter date value (Format YYYY-MM-DD eg. 2010-01-01).
--	
--	Change History:	20161107 - LT - Created
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @DateRange = 'Last Month', @StartDate = null, @EndDate = null
*/

declare @rptStartDate datetime
declare @rptEndDate datetime
declare @SQL nvarchar(max)

/* get reporting dates */
if @DateRange = '_User Defined'
  select @rptStartDate = convert(smalldatetime,@StartDate), @rptEndDate = convert(smalldatetime,@EndDate)
else
  select @rptStartDate = StartDate, @rptEndDate = EndDate
  from [db-au-cmdwh].dbo.vDateRange
  where DateRange = @DateRange


select 
      convert(varchar(8),p.TripStart,120) + '01' DepartureMonth, 
      case 
            when p.PrimaryCountry IN ('England','Ireland','Northern Ireland','Republic of Ireland','Scotland','United Kingdom','Wales') then 'UK'
            when p.PrimaryCountry IN ('All of North America','United States of America') THEN 'USA'
            else p.PrimaryCountry
      end Destination,
	count(distinct p.PolicyKey) as PolicyCount,  
	count(1) as TravellerCount,
	@rptStartDate as StartDate,
	@rptEndDate as EndDate
from 
	[db-au-cmdwh].dbo.penPolicy p 
	inner join [db-au-star].dbo.dimOutlet o on 
		o.OutletAlphaKey = p.OutletAlphaKey and 
		o.isLatest = 'Y' and
		o.SuperGroupName in ('Flight Centre','Cover-More Websales','Cover-More Phonesales','Helloworld','Independents') and
		o.Country = 'AU'
	inner join [db-au-cmdwh].dbo.penPolicyTraveller ptv on 
		p.PolicyKey = ptv.PolicyKey
where 
	p.TripStart between @rptStartDate and @rptEndDate and
	p.StatusDescription = 'Active' and
	p.PrimaryCountry in ('Canada','India','Japan','Switzerland','England','Ireland','Northern Ireland','Republic of Ireland','Scotland',
						 'United Kingdom','Wales','All of North America','United States of America')
group by 
	convert(varchar(8),p.TripStart,120),
	case when p.PrimaryCountry IN ('England','Ireland','Northern Ireland','Republic of Ireland','Scotland','United Kingdom','Wales') then 'UK'
		 when p.PrimaryCountry IN ('All of North America','United States of America') then 'USA'
		 else p.PrimaryCountry
	end
order by 1,2
GO
