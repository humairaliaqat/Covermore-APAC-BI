USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0285d]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0285d]	@ReportingPeriod varchar(30),
										@StartDate varchar(10) = null,
										@EndDate varchar(10) = null                      
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0285d
--  Author:         Linus Tor
--  Date Created:   20121128
--  Description:    This stored procedure returns Flight Centre AMT policies with return date in specified range
--  Parameters:     @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--   
--  Change History: 20130117 - LT - Created
--					20150209 - LT - F22842 - Amended query to restrict travellers age equal or greater than 75 years old
--											 on policy expiry date.
--					20161005 - SD - INC0017054 - Amended query to include SubGroupCode
--					20161010 - PZ - INC0018099 - Update AMT letter in AU to include only AMT policies where ALL travellers 
--												 age is less than or equal to 74 at time of policy expiry date.
--
/****************************************************************************************************/
--uncomment to debug
/*
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @ReportingPeriod = 'Next Year', @StartDate = '2012-12-01', @EndDate = '2012-12-31'
*/

declare @rptStartDate smalldatetime
declare @rptEndDate smalldatetime
declare @WhereLetterType varchar(500)
declare @SQL varchar(max)


/* get reporting dates */
if @ReportingPeriod = '_User Defined'
select 
  @rptStartDate = @StartDate, 
  @rptEndDate = @EndDate

else if @ReportingPeriod = 'Date +4 weeks'
	select	@rptStartDate = dateadd(week, 4, convert(date, getdate())), 
			@rptEndDate = dateadd(week, 4, convert(date, getdate()))
else if @ReportingPeriod = 'Date +6 weeks'
	select	@rptStartDate = dateadd(week, 6, convert(date, getdate())), 
			@rptEndDate = dateadd(week, 6, convert(date, getdate()))
else
	select	@rptStartDate = StartDate, 
			@rptEndDate = EndDate
	from	[db-au-cmdwh].dbo.vDateRange
	where	DateRange = @ReportingPeriod

select distinct
	p.PolicyNumber,
	p.ProductCode,
	p.ProductDisplayName as ProductType,	
	p.PolicyStart,
	p.PolicyEnd as RenewalDate,
	p.TripType, 
	o.AlphaCode as AgencyCode,
	o.Outletname as AgencyName,
	o.GroupName as AgencyGroupName,
    o.SubGroupName,
    o.SuperGroupName,
	o.SubGroupCode,	
	o.ContactTitle as AgencyTitle,
	o.ContactFirstName as AgencyFirstName,
	o.ContactLastName as AgencyLastName,
	o.ContactStreet as AgencyStreet,
	o.ContactSuburb as AgencySuburb,
	o.ContactState as AgencyState,
	o.ContactPostCode as AgencyPostCode,
	o.ContactPhone as AgencyPhone,
	case when o.CountryKey = 'AU' then 'Australia'
		 when o.CountryKey = 'NZ' then 'New Zealand'
		 when o.CountryKey = 'UK' then 'United Kingdom'
	end as AgencyCountry,
	pt.Title as CustTitle,
	pt.FirstName as CustFirstName,
	pt.LastName as CustLastName,
	ltrim(rtrim(pt.AddressLine1)) + ' ' + ltrim(rtrim(pt.AddressLine2)) as CustStreet,
	pt.Suburb as CustSuburb,
	pt.[State] as CustState,
	pt.PostCode as CustPostCode,
	pt.Country as CustCountry,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate
from 
	[db-au-cmdwh].dbo.penPolicy p 
	join [db-au-cmdwh].dbo.penOutlet o on 
		p.OutletAlphaKey = o.OutletAlphaKey and
		o.OutletStatus = 'Current'
	join [db-au-cmdwh].dbo.penPolicyTraveller pt on 
		p.PolicyKey = pt.PolicyKey	and pt.isAdult = 1 and pt.isPrimary = 1
	outer apply
		( -- TOFR
			select 
                count(ptv.PolicyTravellerKey) as [TOFR Count]
            from 
                penPolicyTraveller ptv 
            where
                ptv.PolicyKey = p.PolicyKey
				and datediff(year,ptv.DOB,p.TripEnd) >= 75
		) as TOFR --Too old for renewal
where
	p.CountryKey = 'AU' and
	p.CompanyKey = 'CM' and
	o.GroupCode = 'FL' and
	p.TripType = 'Annual Multi Trip' and
	p.PolicyEnd >= convert(varchar(10),@rptStartDate,120) and 
	p.PolicyEnd <  convert(varchar(10),dateadd(day, 1, @rptEndDate),120) and
	p.StatusCode = 1 and
	datediff(year,pt.DOB,p.PolicyEnd) < 75 and 
	(case when p.CountryKey = 'AU' and TOFR.[TOFR Count] > 0 then 1 else 0 end) = 0 -- TOFR Flag            	
order by 
	p.PolicyNumber
GO
