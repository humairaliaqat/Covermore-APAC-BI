USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0342]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0342]	@AgencyGroup varchar(3),										
										@ReportingPeriod varchar(30),
										@StartDate varchar(10) = null,
										@EndDate varchar(10) = null
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0342
--  Author:         Linus Tor
--  Date Created:   20120803
--  Description:    This stored procedure returns policies with return date in specified range
--  Parameters:     @AgencyGroup: agency group code
--                  @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--   
--  Change History: 20120803 - LT - Created
--					20140129 - LT - Migrated to Penguin
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @AgencyGroup varchar(3)
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @AgencyGroup = 'ALL', @ReportingPeriod = 'Next Month', @StartDate = null, @EndDate = null
*/

declare @rptStartDate datetime
declare @rptEndDate datetime
declare @SQL varchar(max)
declare @WhereAgencyGroup varchar(100)
declare @WhereProductCode varchar(100)

/* get reporting dates */
if @ReportingPeriod = '_User Defined'
	select @rptStartDate = @StartDate, @rptEndDate = @EndDate
else
	select	@rptStartDate = StartDate, 
			@rptEndDate = EndDate
	from	[db-au-cmdwh].dbo.vDateRange
	where	DateRange = @ReportingPeriod	   


if @AgencyGroup is null or @AgencyGroup = '' or @AgencyGroup = 'ALL'	select @WhereAgencyGroup = 'like ''%'''
else select @WhereAgencyGroup = '= ''' + @AgencyGroup + ''''


select @SQL = 'select	p.PolicyNumber as PolicyNo,
						p.PolicyEnd as ExpiryDate,	
						p.ProductCode,	
						p.PlanDisplayName as PlanCode,	
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
						(c.AddressLine1 + '' '' + c.AddressLine2) as CustStreet, 
						c.Suburb as CustSuburb, 
						c.State as CustState,
						c.PostCode as CustPostcode, 
						c.Country as CustCountry
			   from [db-au-cmdwh].dbo.penPolicy p
					join [db-au-cmdwh].dbo.penOutlet a on 
						p.OutletAlphaKey = a.OutletAlphaKey and 
						a.OutletStatus = ''Current''
					join [db-au-cmdwh].dbo.penPolicyTraveller c on 
						p.PolicyKey = c.PolicyKey and 
						isnull(c.IsPrimary,0) = 1 and 
						isnull(c.IsAdult,0) = 1
			   where 
					p.CountryKey = ''NZ'' and 
					p.StatusDescription = ''Active'' and	
					(p.TripType = ''Annual Multi Trip'' or
					p.PlanName in (''A'',''A1'',''A2'')) and
					a.GroupCode ' + @WhereAgencyGroup + ' and p.ProductCode = ''CMB'' and
					a.AlphaCode <> ''TSZ0000'' and
					p.PolicyEnd between ''' + convert(varchar(10),@rptStartDate,120) + ''' and ''' + convert(varchar(10),@rptEndDate,120) + '''
				order by p.PolicyNumber'
execute(@SQL)
							
			
GO
