USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0285a]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0285a]	@Country varchar(2),
										@LetterType varchar(50),
										@ReportingPeriod varchar(30),
										@StartDate varchar(10) = null,
										@EndDate varchar(10) = null                      
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0285
--  Author:         Leonardus Setyabudi
--  Date Created:   20120131
--  Description:    This stored procedure returns policies with return date in specified range
--  Parameters:     @Country: Enter Country Code; e.g. AU
--					@LetterType: Closed Agents & STA, JTG & Indies, Flight Centre Directs, AHM, Brokers
--                  @AgencyGroup: agency group code
--                  @ProductCode: policy product code
--                  @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--   
--  Change History: 20120131 - LS - Created
--                  20120307 - LS - Add Agency Code & Agency Group Name for grouping
--                                  Make ProductCode optional
--                  20120528 - LS - exclude CMB, see rpt0286
--                                  add Product Code description
--                                  exclude agent specials
--                  20120530 - LS - limit to covermore products excluding corporate & mobile
--                  20120614 - LS - add custom common date range for business renewals
--					20120703 - LT - exclude STA agency group (AgencyGroup = ST)
--					20120709 - LT - based on rptsp_rpt0285. This stored procedure is used by RPT0285a report
--									to be run until end of FY2013. It includes some logic to format AMT Client letters
--									based on Agency Group, and Agency Status.
--					20130131 - LT - Removed FL AMT policies from this report. FL will be covered in RPT0285d report.
--					20130725 - LT - Removed AHM from report. AHM is covered in RPT0285f report
--					20150209 - LT - F22842 - Amended query to restrict travellers age equal or greater than 75 years old
--											 on policy expiry date.
--					20161010 - PZ - INC0018099 - Update AMT letter in AU to include only AMT policies where ALL travellers 
--												 age is less than or equal to 74 at time of policy expiry date.
--					20170201 - LT - Exclude CM phone, web, and mobile policies
--
/****************************************************************************************************/
--uncomment to debug
/*
declare @Country varchar(2)
declare @LetterType varchar(50)
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @Country = 'AU', @LetterType = 'Flight Centre, Directs, & Brokers', @ReportingPeriod = 'Current Month', @StartDate = '2012-02-01', @EndDate = '2012-02-29'
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

if @LetterType = 'Closed Agents & STA'
	select @WhereLetterType = 'o.TradingStatus in (''Closed'',''Stocks Withdrawn'')'
else if @LetterType = 'JTG & Indies'
	select @WhereLetterType = 'o.GroupCode in (''TI'',''TT'',''HW'',''TW'',''AA'',''CT'',''AR'') and o.TradingStatus not in (''Closed'',''Stocks Withdrawn'')'
else if @LetterType = 'Flight Centre, Directs, & Brokers'
	select @WhereLetterType = '(o.GroupCode in (''XA'',''ZA'',''IU'',''XF'',''RC'',''ZU'') or (o.GroupCode = ''CM'' and o.SubGroupCode not in (''PH'', ''MS'', ''WE''))) and o.TradingStatus not in (''Closed'',''Stocks Withdrawn'')'

select @SQL = 'select distinct
					p.PolicyNumber,
					p.ProductCode,
					p.ProductDisplayName as ProductType,
					p.PolicyEnd as RenewalDate,
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
					case when o.CountryKey = ''AU'' then ''Australia''
						 when o.CountryKey = ''NZ'' then ''New Zealand''
						 when o.CountryKey = ''UK'' then ''United Kingdom''
					end as AgencyCountry,
					pt.Title as CustTitle,
					pt.FirstName as CustFirstName,
					pt.LastName as CustLastName,
					ltrim(rtrim(pt.AddressLine1)) + '' '' + ltrim(rtrim(pt.AddressLine2)) as CustStreet,
					pt.Suburb as CustSuburb,
					pt.[State] as CustState,
					pt.PostCode as CustPostCode,
					pt.Country as CustCountry,
					convert(datetime,''' + convert(varchar(10),@rptStartDate,120) + ''') as rptStartDate,
					convert(datetime,''' + convert(varchar(10),@rptEndDate,120) + ''') as rptEndDate
				from 
					[db-au-cmdwh].dbo.penPolicy p 
					join [db-au-cmdwh].dbo.penOutlet o on 
						p.OutletAlphaKey = o.OutletAlphaKey and
						o.OutletStatus = ''Current''
					join [db-au-cmdwh].dbo.penPolicyTraveller pt on 
						p.PolicyKey = pt.PolicyKey and pt.isAdult = 1 and pt.isPrimary = 1 
					outer apply
						( -- TOFR
							select 
								count(ptv.PolicyTravellerKey) as [TOFR Count]
							from 
								penPolicyTraveller ptv 
							where
								ptv.PolicyKey = p.PolicyKey
								and datediff(year,ptv.DOB,p.PolicyEnd) >= 75
						) as TOFR --Too old for renewal
				where
					p.ProductCode <> ''CMB'' and 
					p.CompanyKey = ''CM'' and 
					datediff(year,pt.DOB,p.PolicyEnd) < 75 and
					(case when p.CountryKey = ''AU'' and TOFR.[TOFR Count] > 0 then 1 else 0 end) = 0 and -- TOFR Flag 
					o.CountryKey = ''' + @Country + ''' and
					((p.PlanName like ''%M%'' and p.TripType is null) or p.TripType = ''Annual Multi Trip'') and
					p.PolicyEnd >= ''' + convert(varchar(10),@rptStartDate,120) + ''' and 
					p.PolicyEnd <  ''' + convert(varchar(10),dateadd(day, 1, @rptEndDate),120) + ''' and
					p.StatusCode = 1 and ' + @WhereLetterType + ' order by p.PolicyNumber'

execute(@SQL)
				    
GO
