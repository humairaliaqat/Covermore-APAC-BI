USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0267b]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0267b]  
    @Country Varchar(10)

as

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0267b
--  Author:         Saurabh Date
--  Date Created:   20160624
--  Description:    This stored procedure returns Corporate sales YTD Details
--  Parameters:     @Country: Value is valid Country key
--  Change History: 20160624 - SD - Created
--
/****************************************************************************************************/


--uncomment to debug
/*
declare @Country varchar(10)
select @Country = 'AU'
*/


--Get Current year corporate sales YTD details

if object_id('tempdb..#CURRENT') is not null drop table #CURRENT

SELECT
  po.AlphaCode,
  Case
  	When po.StateSalesArea = 'Australian Capital Territory' then 'ACT'
  	when po.StateSalesArea = 'New South Wales' then 'NSW'
  	when po.StateSalesArea = 'Northern Territory' then 'NT'
  	when po.StateSalesArea = 'Queensland' then 'QLD'
  	when po.StateSalesArea = 'South Australia' then 'SA'
  	when po.StateSalesArea = 'Tasmania' then 'TAS'
  	when po.StateSalesArea = 'Victoria' then 'VIC'
  	when po.StateSalesArea = 'Western Australia' then 'WA'
  End [Agency Group State],
  count(distinct cq.PolicyNo) [Policy Count],
  sum(( corpTaxes.UWSaleExGST ) + ( corpTaxes.GSTGross )) [Gross Sales Inc GST],
  sum(OnPeriodPolicyCount.NewPolicyCount) [On Period Policy Count]
into #CURRENT
FROM
   corpQuotes cq LEFT OUTER JOIN corpTaxes ON (cq.QuoteKey=corpTaxes.QuoteKey)
   INNER JOIN Calendar  TaxCalendar ON (corpTaxes.AccountingPeriod=TaxCalendar.Date)
   INNER JOIN vDateRange  TaxDateRange ON (TaxCalendar.Date between TaxDateRange.StartDate and TaxDateRange.EndDate)
   LEFT OUTER JOIN corpContact ON (cq.QuoteKey=corpContact.QuoteKey)
   INNER JOIN ( 
  select
  QuoteKey,
  NewPolicyCount
from fn_CorpNewPolicyCount('Fiscal Year-To-Date', '', '')
  )  OnPeriodPolicyCount ON (cq.QuoteKey=OnPeriodPolicyCount.QuoteKey)
outer apply
  (
	SELECT
		Top 1
		p.CountryKey,
		p.AlphaCode,
		p.OutletName,
		p.BDMName,
		p.StateSalesArea,
		p.GroupCode,
		p.SubGroupCode
	FROM
		penOutlet p
	WHERE
		p.OutletStatus = 'Current' and
		(p.CountryKey  + '-' + p.AlphaCode) = cq.AgencyKey
  ) po
WHERE
  (
   po.CountryKey  =  @Country
   AND
   TaxDateRange.DateRange  =  'Fiscal Year-To-Date'
   AND
   corpContact.ContactType  =  'A'
  )
GROUP BY
  po.AlphaCode, 
  Case
   	When po.StateSalesArea = 'Australian Capital Territory' then 'ACT'
   	when po.StateSalesArea = 'New South Wales' then 'NSW'
   	when po.StateSalesArea = 'Northern Territory' then 'NT'
   	when po.StateSalesArea = 'Queensland' then 'QLD'
   	when po.StateSalesArea = 'South Australia' then 'SA'
   	when po.StateSalesArea = 'Tasmania' then 'TAS'
   	when po.StateSalesArea = 'Victoria' then 'VIC'
   	when po.StateSalesArea = 'Western Australia' then 'WA'
  End





--Get Previous year corporate sales YTD details

if object_id('tempdb..#YAGO') is not null drop table #YAGO

SELECT
  po.AlphaCode,
  Case
   	When po.StateSalesArea = 'Australian Capital Territory' then 'ACT'
   	when po.StateSalesArea = 'New South Wales' then 'NSW'
   	when po.StateSalesArea = 'Northern Territory' then 'NT'
   	when po.StateSalesArea = 'Queensland' then 'QLD'
   	when po.StateSalesArea = 'South Australia' then 'SA'
   	when po.StateSalesArea = 'Tasmania' then 'TAS'
   	when po.StateSalesArea = 'Victoria' then 'VIC'
   	when po.StateSalesArea = 'Western Australia' then 'WA'
  End [Agency Group State],
  count(distinct YAGOQuotes.PolicyNo) [YAGO Policy Count],
  sum(YAGOQuotes.UWSaleExGST + YAGOQuotes.GSTGross) [YAGO Gross Sales Inc GST],
  sum(YAGOOnPeriodPolicyCount.NewPolicyCount) [YAGO On Period Policy Count]
Into #YAGO
FROM
  vDateRange  TaxDateRange INNER JOIN Calendar  TaxCalendar ON (TaxCalendar.Date between TaxDateRange.StartDate and TaxDateRange.EndDate)
   INNER JOIN ( 
  select 
  q.QuoteKey,
  q.QuoteID,
  q.AgencyKey,
  q.CompanyKey,
  q.PolicyNo,
  q.QuoteType,
  t.UWSaleExGST,
  t.GSTGross,
  t.AgtCommExGST,
  t.GSTAgtComm,
  t.AccountingPeriod
from 
  corpQuotes q 
  inner join corpTaxes t on t.QuoteKey = q.QuoteKey
  )  YAGOQuotes ON (YAGOQuotes.AccountingPeriod=dateadd(year, -1, TaxCalendar.Date))
   INNER JOIN ( 
  select
  QuoteKey,
  NewPolicyCount
from fn_CorpYAGONewPolicyCount('Fiscal Year-To-Date', '', '')
  )  YAGOOnPeriodPolicyCount ON (YAGOQuotes.QuoteKey=YAGOOnPeriodPolicyCount.QuoteKey)
  outer apply
  (
	SELECT
		Top 1
		p.CountryKey,
		p.AlphaCode,
		p.OutletName,
		p.BDMName,
		p.StateSalesArea,
		p.GroupCode,
		p.SubGroupCode
	FROM
		penOutlet p
	WHERE
		p.OutletStatus = 'Current' and
		(p.CountryKey  + '-' + p.AlphaCode) = YAGOQuotes.AgencyKey
  ) po
WHERE
  (
   po.CountryKey  =  @Country
   AND
   TaxDateRange.DateRange  =  'Fiscal Year-To-Date'
  )
GROUP BY
  po.AlphaCode, 
  Case
   	When po.StateSalesArea = 'Australian Capital Territory' then 'ACT'
   	when po.StateSalesArea = 'New South Wales' then 'NSW'
   	when po.StateSalesArea = 'Northern Territory' then 'NT'
   	when po.StateSalesArea = 'Queensland' then 'QLD'
   	when po.StateSalesArea = 'South Australia' then 'SA'
   	when po.StateSalesArea = 'Tasmania' then 'TAS'
   	when po.StateSalesArea = 'Victoria' then 'VIC'
   	when po.StateSalesArea = 'Western Australia' then 'WA'
  End




select
	isnull(#CURRENT.AlphaCode,#YAGO.AlphaCode) [AlphaCode],
	isnull(#CURRENT.[Agency Group State],#YAGO.[Agency Group State]) [Agency Group State],
	[Policy Count],
	[YAGO Policy Count],
	[Gross Sales Inc GST],
	[YAGO Gross Sales Inc GST],
	[On Period Policy Count],
	[YAGO On Period Policy Count]
From
	#CURRENT FULL OUTER JOIN #YAGO
		On #CURRENT.AlphaCode = #YAGO.AlphaCode and
			#CURRENT.[Agency Group State] = #YAGO.[Agency Group State]
GO
