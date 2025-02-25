USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0267a]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0267a]  
    @Country Varchar(10),  
    @DateRange varchar(30),
    @StartDate datetime = null,
    @EndDate datetime = null

as

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0267a
--  Author:         Saurabh Date
--  Date Created:   20160623
--  Description:    This stored procedure returns Corporate sales MTD Details
--  Parameters:     @Country: Value is valid Country key
--		    @DateRange: Value is valid date range
--                  @StartDate: Enter if @DateRange = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--  Change History: 20160623 - SD - Created
--
/****************************************************************************************************/


--uncomment to debug
/*
declare @Country varchar(10)
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @Country = 'AU', @DateRange = 'Last Fiscal Month', @StartDate = NULL, @EndDate = NULL
*/


    declare @rptStartDate datetime
    declare @rptEndDate datetime

    /* get reporting dates */
    if @DateRange = '_User Defined'
        select @rptStartDate = @StartDate,
            @rptEndDate = @EndDate
    else
        select    @rptStartDate = StartDate, 
            @rptEndDate = EndDate
        from    [db-au-cmdwh].dbo.vDateRange
        where    DateRange = @DateRange;



--Get Current year corporate sales MTD details
if object_id('tempdb..#CURRENT') is not null drop table #CURRENT
SELECT
  po.AlphaCode,
  po.OutletName,
  po.BDMName,
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
  po.GroupCode,
  po.SubGroupCode,
  TaxDateRange.StartDate [Start Date],
  TaxDateRange.EndDate [End Date],
  count(distinct cq.PolicyNo) [Policy Count],
  sum(( corpTaxes.UWSaleExGST ) + ( corpTaxes.GSTGross )) [Gross Sales Inc GST],
  corpContact.FirstName,
  corpContact.Surname,
  sum(OnPeriodPolicyCount.NewPolicyCount) [On Period Policy Count]
  Into #CURRENT
FROM
  corpQuotes cq LEFT OUTER JOIN corpTaxes ON (cq.QuoteKey=corpTaxes.QuoteKey)
	INNER JOIN Calendar  TaxCalendar ON (corpTaxes.AccountingPeriod=TaxCalendar.Date)
	INNER JOIN vDateRange  TaxDateRange ON (TaxCalendar.Date between TaxDateRange.StartDate and TaxDateRange.EndDate)
	LEFT OUTER JOIN corpContact ON (cq.QuoteKey=corpContact.QuoteKey)
	INNER JOIN ( 
				  select
					QuoteKey,
					NewPolicyCount
				  from 
					fn_CorpNewPolicyCount(@DateRange,
				  			      @rptStartDate,
				  			      @rptEndDate
				)
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
   TaxDateRange.DateRange = @DateRange
   AND
   TaxDateRange.StartDate  =  @rptStartDate
   AND
   TaxDateRange.EndDate  =  @rptEndDate
   AND
   corpContact.ContactType  =  'A'
  )
GROUP BY
  po.AlphaCode,
  po.OutletName,
  po.BDMName,
  Case
  	When po.StateSalesArea = 'Australian Capital Territory' then 'ACT'
  	when po.StateSalesArea = 'New South Wales' then 'NSW'
  	when po.StateSalesArea = 'Northern Territory' then 'NT'
  	when po.StateSalesArea = 'Queensland' then 'QLD'
  	when po.StateSalesArea = 'South Australia' then 'SA'
  	when po.StateSalesArea = 'Tasmania' then 'TAS'
  	when po.StateSalesArea = 'Victoria' then 'VIC'
  	when po.StateSalesArea = 'Western Australia' then 'WA'
  End,
  po.GroupCode,
  po.SubGroupCode,
  TaxDateRange.StartDate, 
  TaxDateRange.EndDate, 
  corpContact.FirstName, 
  corpContact.Surname



--Get Previous year corporate sales MTD details
if object_id('tempdb..#YAGO') is not null drop table #YAGO
   SELECT
  po.AlphaCode,
  po.OutletName,
  po.BDMName,
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
  po.GroupCode,
  po.SubGroupCode,
  TaxDateRange.StartDate [Start Date],
  TaxDateRange.EndDate [End Date],
  count(distinct YAGOQuotes.PolicyNo) [YAGO Policy Count],
  sum(YAGOQuotes.UWSaleExGST + YAGOQuotes.GSTGross) [YAGO Gross Sales Inc GST],
  sum(YAGOOnPeriodPolicyCount.NewPolicyCount) [YAGO On Period Policy Count]
  into #YAGO
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
from fn_CorpYAGONewPolicyCount(@DateRange,
			       @rptStartDate,
			       @rptEndDate
)
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
   TaxDateRange.DateRange = @DateRange
   AND
   TaxDateRange.StartDate  =  @rptStartDate
   AND
   TaxDateRange.EndDate = @rptEndDate
  )
GROUP BY
  po.AlphaCode, 
  po.OutletName, 
  po.BDMName, 
  Case
  	When po.StateSalesArea = 'Australian Capital Territory' then 'ACT'
  	when po.StateSalesArea = 'New South Wales' then 'NSW'
  	when po.StateSalesArea = 'Northern Territory' then 'NT'
  	when po.StateSalesArea = 'Queensland' then 'QLD'
  	when po.StateSalesArea = 'South Australia' then 'SA'
  	when po.StateSalesArea = 'Tasmania' then 'TAS'
  	when po.StateSalesArea = 'Victoria' then 'VIC'
  	when po.StateSalesArea = 'Western Australia' then 'WA'
  End, 
  po.GroupCode, 
  po.SubGroupCode, 
  TaxDateRange.StartDate, 
  TaxDateRange.EndDate



select 
	isnull(#CURRENT.AlphaCode, #YAGO.AlphaCode) [AlphaCode],
	isnull(#CURRENT.OutletName, #YAGO.OutletName) [OutletName],
	isnull(#CURRENT.BDMName, #YAGO.BDMName) [BDMName], 
	isnull(#CURRENT.[Agency Group State], #YAGO.[Agency Group State]) [Agency Group State],
	isnull(#CURRENT.GroupCode, #YAGO.GroupCode) [GroupCode],
	isnull(#CURRENT.SubGroupCode, #YAGO.SubGroupCode) [SubGroupCOde],
	isnull(#CURRENT.[Start Date], #YAGO.[Start Date]) [Start Date],
	isnull(#CURRENT.[End Date], #YAGO.[End Date]) [End Date],
	[Policy Count],
	[YAGO Policy Count],
	[Gross Sales Inc GST],
	[YAGO Gross Sales Inc GST],
	[On Period Policy Count],
	[YAGO On Period Policy Count]
from 
	#CURRENT FULL OUTER JOIN #YAGO
		on #CURRENT.AlphaCode = #YAGO.AlphaCode and
			#CURRENT.OutletName = #YAGO.OutletName and 
			#CURRENT.BDMName = #YAGO.BDMName and 
			#CURRENT.[Agency Group State] = #YAGO.[Agency Group State] and
			#CURRENT.GroupCode = #YAGO.GroupCode and
			#CURRENT.SubGroupCode = #YAGO.SubGroupCode
GO
