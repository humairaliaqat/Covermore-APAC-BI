USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0668]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[rptsp_rpt0668]	@ReportingPeriod varchar(30),
					@StartDate varchar(10) = null,
					@EndDate varchar(10) = null
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0668
--  Author:         Saurabh Date
--  Date Created:   20150824
--  Description:    This stored procedure returns policies with policy expiry date in specified range(AMT Renewal report for Air NZ)
--  Parameters:     @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--   
--  Change History: 20150824 - SD - Created
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @ReportingPeriod = 'Next Month', @StartDate = null, @EndDate = null
*/

declare @rptStartDate datetime
declare @rptEndDate datetime

/* get reporting dates */
if @ReportingPeriod = '_User Defined'
	select @rptStartDate = @StartDate,
		@rptEndDate = @EndDate
else
	select	@rptStartDate = StartDate, 
		@rptEndDate = EndDate
	from	[db-au-cmdwh].dbo.vDateRange
	where	DateRange = @ReportingPeriod;	   


select	
	p.PolicyNumber as PolicyNo,	
	p.PolicyEnd as ExpiryDate,	
	p.ProductCode,	
	p.PlanName as PlanCode,	
	a.OutletName as AgencyName, 
	a.ContactTitle as AgencyTitle,
	a.ContactFirstName as AgencyFirstName, 
	a.ContactLastName as AgencyLastName,	
	a.ContactStreet as AgencyStreet, 
	a.ContactSuburb as AgencySuburb,
	a.ContactState as AgencyState, 
	a.ContactPostCode as AgencyPostCode, 
	c.Title as CustTitle, 
	c.FirstName as CustFirstName,
	c.LastName as CustLastName,	
	(c.AddressLine1 + ' ' + c.AddressLine2) as CustStreet, 
	c.Suburb as CustSuburb, 
	c.State as CustState,
	c.PostCode as CustPostcode, 
	c.Country as CustCountry
from 
	[db-au-cmdwh].dbo.penPolicy p
	join [db-au-cmdwh].dbo.penOutlet a on 
		p.OutletAlphaKey = a.OutletAlphaKey and 
		a.OutletStatus = 'Current'
	join [db-au-cmdwh].dbo.penPolicyTraveller c on 
		p.PolicyKey = c.PolicyKey and 
		isnull(c.IsPrimary,0) = 1
where 
	p.CountryKey = 'NZ' and
	a.SuperGroupName='Air NZ' and 
	p.ProductCode in ('ANF','ANB','ANK','ANI') and
	p.StatusDescription = 'Active' and
	p.TripType = 'Annual Multi Trip' and
	p.PolicyEnd between @rptStartDate and @rptEndDate
order by 
	p.PolicyNumber
								
				
			
GO
