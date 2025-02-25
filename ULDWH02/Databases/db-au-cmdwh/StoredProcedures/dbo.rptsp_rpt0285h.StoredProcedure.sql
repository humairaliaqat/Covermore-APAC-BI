USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0285h]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0285h]	@ReportingPeriod varchar(30),
										@StartDate varchar(10) = null,
										@EndDate varchar(10) = null                      
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0285h
--  Author:         Linus Tor
--  Date Created:   20140819
--  Description:    This stored procedure returns AAA (AANT, RAA, RACQ, NRMA) AMT policies with expiry
--					date in reporting period.
--  Parameters:     @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--   
--  Change History: 20140819 - LT - Created
--					20150209 - LT - F22842 - Amended query to restrict travellers age equal or greater than 75 years old
--											 on policy expiry date.
--
--
/****************************************************************************************************/
--uncomment to debug
/*
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @ReportingPeriod = 'Next Month', @StartDate = null, @EndDate = null
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
		p.PolicyKey = pt.PolicyKey
where
	p.CountryKey = 'AU' and
	o.SuperGroupName = 'AAA' and
	o.GroupName in ('AANT','RAA','RACQ','NRMA') and
	pt.isAdult = 1 and
	pt.isPrimary = 1 and
	p.TripType = 'Annual Multi Trip' and
	p.PolicyEnd >= convert(varchar(10),@rptStartDate,120) and 
	p.PolicyEnd <  convert(varchar(10),dateadd(day, 1, @rptEndDate),120) and
	p.StatusCode = 1 and
	datediff(year,pt.DOB,p.PolicyEnd) < 75    
order by 
	p.PolicyNumber

				    
GO
