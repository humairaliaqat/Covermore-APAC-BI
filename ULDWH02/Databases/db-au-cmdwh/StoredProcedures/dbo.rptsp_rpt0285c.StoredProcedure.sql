USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0285c]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0285c]	@ReportingPeriod varchar(30),
										@StartDate varchar(10) = null,
										@EndDate varchar(10) = null                      
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0285c
--  Author:         Linus Tor
--  Date Created:   20121128
--  Description:    This stored procedure returns Flight Centre trial agency AMT policies with return date in specified range
--  Parameters:     @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--   
--  Change History: 20121128 - LT - Created
--
/****************************************************************************************************/
--uncomment to debug
/*
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @ReportingPeriod = '_User Defined', @StartDate = '2012-12-01', @EndDate = '2012-12-31'
*/

declare @rptStartDate smalldatetime
declare @rptEndDate smalldatetime
declare @WhereLetterType varchar(500)
declare @SQL varchar(max)

--store trial alphas in temp table. add new records as required
if object_id('tempdb..#t') is not null drop table #t
create table #t
(
	AgencyCode varchar(7) null,
	AgencyName varchar(100) null
)
insert #t values('FLN0130','Double Bay Flight Centre')
insert #t values('FLN0200','Bondi Junction Flight Centre')
insert #t values('FLN0625','Woollahra Flight Centre')
insert #t values('FLN0658','Rose Bay Flight Centre')
insert #t values('FLN1205','Randwick North Flight Centre')
insert #t values('FLN1315','Eastgardens B Flight Centre')
insert #t values('FLN1316','Eastgardens A Flight Centre')
insert #t values('FLN1322','Bondi Beach Flight Centre')
insert #t values('FLN1331','Coogee Flight Centre')
insert #t values('FLN1421','Bondi Westfield Flight Centre')
insert #t values('FLN1423','Edgecliff Flight Centre')
insert #t values('FLN1431','Maroubra Junct Flight Centre')
insert #t values('FLN1471','Waverley Flight Centre')
insert #t values('FLN1473','Rockdale Flight Centre')
insert #t values('FLN1490','Southpoint Flight Centre')
insert #t values('FLN1519','Vaucluse Flight Centre')
insert #t values('FLN1711','Flight Centre Sydney Intl Airport')
insert #t values('FLN0065','Cronulla Flight Centre')
insert #t values('FLN0256','Engadine Flight Centre')
insert #t values('FLN0260','Shellharbour Flight Centre')
insert #t values('FLN0300','Hurstville Flight Centre')
insert #t values('FLN0550','Miranda Fair Flight Centre')
insert #t values('FLN0660','Roselands Flight Centre')
insert #t values('FLN0840','Corrimal Flight Centre')
insert #t values('FLN0850','Wollongong Flight Centre')
insert #t values('FLN1413','Gymea Flight Centre')
insert #t values('FLN1414','Caringbah Flight Centre')
insert #t values('FLN1437','Kareela Flight Centre')
insert #t values('FLN1438','Figtree Flight Centre')
insert #t values('FLN1499','Warrawong Flight Centre')
insert #t values('FLN1514','Sylvania Southgate Flight Cent')
insert #t values('FLN1515','Nowra Flight Centre')
insert #t values('FLN1588','Flight Centre Sutherland ')
insert #t values('FLN1706','Flight Centre Kiama')
insert #t values('FLN0079','Bankstown Flight Centre')
insert #t values('FLN0085','MacArthur Square Flight Centre')
insert #t values('FLN0460','Liverpool Flight Centre')
insert #t values('FLN0580','Narellan Flight Centre')
insert #t values('FLN1381','Bonnyrigg Flight Centre')
insert #t values('FLN1382','Wetherill Park Flight Centre')
insert #t values('FLN1395','Bowral Flight Centre')
insert #t values('FLN1404','Revesby Flight Centre')
insert #t values('FLN1443','Ingleburn Flight Centre')
insert #t values('FLN1463','Camden Flight Centre')
insert #t values('FLN1482','Campbelltown Mall Flight Ctr')
insert #t values('FLN1484','Picton Flight Centre ')
insert #t values('FLN1488','Fairfield Flight Centre')
insert #t values('FLN1528','Flight Centre Mittagong')
insert #t values('FLN1551','Flight Centre Casula')
insert #t values('FLN1560','Flight Centre Carnes Hill')
insert #t values('FLN0028','Ashfield Flight Centre')
insert #t values('FLN0036','Balmain Flight Centre')
insert #t values('FLN0080','Burwood Flight Centre')
insert #t values('FLN0425','Leichhardt Flight Centre')
insert #t values('FLN0485','Marrickville Flight Centre Met')
insert #t values('FLN0652','Parramatta South Flight Centre')
insert #t values('FLN1330','Church Street Flight Centre')
insert #t values('FLN1346','Norton Plaza Flight Centre')
insert #t values('FLN1390','Rozelle Flight Centre')
insert #t values('FLN1403','Parramatta North Flight Centre')
insert #t values('FLN1415','Concord Flight Centre')
insert #t values('FLN1436','Rhodes Waterside Flight Centre')
insert #t values('FLN1481','Five Dock Flight Centre')
insert #t values('FLN1527','Marrickville Road Flight Centr')
insert #t values('FLN1537','Strathfield Plaza Flight Centr')
insert #t values('FLN1606','Flight Centre Merrylands')
insert #t values('FLN1627','Summer Hill Flight Centre')
insert #t values('FLA0100','Woden Flight Centre')
insert #t values('FLA0150','Belconnen Flight Centre')
insert #t values('FLA0200','Tuggeranong Flight Centre')
insert #t values('FLA0250','Capital Flight Centre')
insert #t values('FLA0300','Manuka Flight Centre')
insert #t values('FLA0400','Dickson Flight Centre')
insert #t values('FLA0450','Kingston Flight Centre')
insert #t values('FLA0453','Weston Flight Centre')
insert #t values('FLA0454','Citywalk Flight Centre')
insert #t values('FLA0455','Fyshwick Flight Centre')
insert #t values('FLA0457','Gungahlin Flight Centre')
insert #t values('FLA0471','Flight Centre Mawson')
insert #t values('FLN1428','Batemans Bay Flight Centre')
insert #t values('FLN1491','Goulburn Flight Centre')
insert #t values('FLN1517','Bunda Street Flight Centre')
insert #t values('FLN1586','Flight Centre Queanbeyan ')
insert #t values('FLN1696','Flight Centre Bega')
insert #t values('FLN1705','Ulladulla Flight Centre')
insert #t values('FLN0046','Sydney Central Flight Centre')
insert #t values('FLN0052','Surry Hills Flight Centre')
insert #t values('FLN0082','Broadway Flight Centre East')
insert #t values('FLN0120','Darlinghurst Flight Centre')
insert #t values('FLN0390','Kings Cross Flight Centre B')
insert #t values('FLN0585','Newtown Flight Centre')
insert #t values('FLN0800','Town Hall Flight Centre')
insert #t values('FLN1175','Wagga Wagga Flight Centre')
insert #t values('FLN1319','Galeries Flight Centre')
insert #t values('FLN1329','Bathurst St Flight Centre')
insert #t values('FLN1345','Taylor Square Flight Centre')
insert #t values('FLN1468','World Square Flight Centre ')
insert #t values('FLN1477','Botany Road Flight Centre')
insert #t values('FLN1530','Potts Point Flight Centre')
insert #t values('FLN1550','Flight Centre Griffith')
insert #t values('FLN1568','Broadway Flight Centre West')
insert #t values('FLN1572','Flight Centre Pyrmont')
insert #t values('FLN1599','Liverpool Street (NSW) Flight')
insert #t values('FLQ0181','Buderim Flight Centre')
insert #t values('FLQ0182','Bundaberg Flight Centre')
insert #t values('FLQ0806','Mooloolaba Flight Centre')
insert #t values('FLQ0820','Nambour Flight Centre')
insert #t values('FLQ0823','Noosa Flight Centre')
insert #t values('FLQ1225','Sunshine Plaza Flight Centre')
insert #t values('FLQ1708','Gympie Flight Centre')
insert #t values('FLQ1752','Plaza Parade Flight Centre')
insert #t values('FLQ1754','Coolum Flight Centre')
insert #t values('FLQ1798','Bundaberg City Flight Centre')
insert #t values('FLQ1808','Noosa Civic Flight Centre')
insert #t values('FLQ1845','Eli Waters Flight Centre')
insert #t values('FLQ1859','Flight Centre Pialba Place')
insert #t values('FLQ1867','Noosaville Flight Centre')
insert #t values('FLQ1940','Maryborough Flight Centre')




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
	p.CompanyKey = 'CM' and
	o.GroupCode = 'FL' and
	o.AlphaCode in (select AgencyCode from #t) and
	pt.isAdult = 1 and
	pt.isPrimary = 1 and
	p.TripType = 'Annual Multi Trip' and
	p.PolicyEnd >= convert(varchar(10),@rptStartDate,120) and 
	p.PolicyEnd <  convert(varchar(10),dateadd(day, 1, @rptEndDate),120) and
	p.StatusCode = 1 
order by 
	p.PolicyNumber

				    
GO
