USE [db-au-actuary]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0806]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0806]	@DateRange varchar(30),
									@StartDate datetime,
									@EndDate datetime,
									@ReferenceDate varchar(20),
									@CountryKey varchar(10)
as
begin

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0806
--  Author:         Saurabh Date
--  Date Created:   20170927
--  Description:    Returns Flight Centre Daily KPI Details
--					
--  Parameters:     
--                  @DateRange: required. valid date range or _User Defined
--                  @StartDate: optional. required if date range = _User Defined
--                  @EndDate: optional. required if date range = _User Defined
--				    @ReferenceDate:	Posting Date or Issue Date for Policy
--                  
--  Change History: 
--                  20170927 - SD - Created
--					20180216 - SD - Included Area, Age Group, Lead Time and Lead Time LY - INC0055586, Simon McNally
--					20180220 - SD - Included International Lead Time and Domestic Lead Time
--					20180515 - SD - Made Alpha Lineage changes
/****************************************************************************************************/


--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate datetime
declare @EndDate datetime
declare @ReferenceDate varchar(20)
select @DateRange = 'Month-To-Date', @StartDate = null, @EndDate = null, @ReferenceDate = 'Posting Date'
*/

                                    
DECLARE @rptStartDate datetime
DECLARE	@rptEndDate datetime
DECLARE @rptStartDateLY datetime
DECLARE @rptEndDateLY datetime


--get reporting dates
if @DateRange = '_User Defined'
    select 
        @rptStartDate = @StartDate,
        @rptEndDate = @EndDate

else
    select 
        @rptStartDate = StartDate, 
        @rptEndDate = EndDate
    from 
        vDateRange
    where 
        DateRange = @DateRange

--get last year reporting dates
SELECT @rptStartDateLY = DATEADD(year,-1,@rptStartDate)
, @rptEndDateLY = DATEADD(year,-1,@rptEndDate)


--Calculate business days for current as well as last year
IF OBJECT_ID('tempdb..#BusinessDays') IS NOT NULL DROP TABLE #BusinessDays
SELECT
	sum(Calendar.isWeekDay) [Current Month Business Days],
	0 [Month-To-Date Business Days],
	0 [Last Year Current Month Business Days],
	0 [Last Year Month-To-Date Business Days]
Into
	#BusinessDays
FROM
	Calendar 
WHERE
	CurMonthNum in (select Distinct CurMonthNUm from Calendar where Date >= @rptStartDate and Date < dateadd(day, 1, @rptEndDate) ) 
	and CurYearNum in (select Distinct CUrYearNUm from Calendar where Date >= @rptStartDate and Date < dateadd(day, 1, @rptEndDate) )
	and Calendar.isHoliday = 0

Union

SELECT
	0 [Current Month Business Days],
	sum(Calendar.isWeekDay) [Month-To-Date Business Days],
	0 [Last Year Current Month Business Days],
	0 [Last Year Month-To-Date Business Days]
FROM
	Calendar 
WHERE
	Date >= @rptStartDate and Date < dateadd(day, 1, @rptEndDate) 
	and Calendar.isHoliday = 0

Union

SELECT
	0 [Current Month Business Days],
	0 [Month-To-Date Business Days],
	sum(Calendar.isWeekDay) [Last Year Current Month Business Days],
	0 [Last Year Month-To-Date Business Days]
FROM
	Calendar 
WHERE
	CurMonthNum in (select Distinct LYCurMonthNUm from Calendar where Date >= @rptStartDate and Date < dateadd(day, 1, @rptEndDate) ) 
	and CurYearNum in (select Distinct LYYearNUm from Calendar where Date >= @rptStartDate and Date < dateadd(day, 1, @rptEndDate) )
	and Calendar.isHoliday = 0

Union

SELECT
	0 [Current Month Business Days],
	0 [Month-To-Date Business Days],
	0 [Last Year Current Month Business Days],
	sum(c.isWeekDay) [Last Year Month-To-Date Business Days]
FROM
	Calendar c
WHERE
	Convert(Date, c.Date) >= dateadd(year,-1,(select min (Date) from Calendar where Date >= @rptStartDate and Date < dateadd(day, 1, @rptEndDate) ))
	and Convert(Date, c.Date) <= dateadd(year,-1,(select max (Date) from Calendar where Date >= @rptStartDate and Date < dateadd(day, 1, @rptEndDate) ))
	and c.isHoliday = 0


if object_id('tempdb..#Outlet') is not null drop table #Outlet
select distinct
	lo.OutletKey, 
	o.OutletAlphaKey, 
	o.LatestOutletKey,
	lo.GroupCode,
	lo.CountryKey,
	lo.SuperGroupName,
	lo.GroupName,
	lo.SubGroupCode,
	lo.SubGroupName,
	lo.AlphaCode,
	lo.OutletName,
	lo.OutletType,
	lo.OutletStatus,
	lo.EGMNation,
	lo.FCNation,
	lo.FCArea,
	lo.StateSalesArea,
	lo.ContactState,
	lo.Branch,
	lo.BDMName,
	lo.SalesSegment,
	lo.TradingStatus	
into #Outlet	
from 
	[db-au-cmdwh].[dbo].penOutlet o
	outer apply
	(
		select top 1 
			OutletKey, 
			OutletAlphaKey, 
			LatestOutletKey,
			CountryKey,
			SuperGroupName,		
			GroupName,
			GroupCode,
			SubGroupCode,
			SubGroupName,
			AlphaCode,
			OutletName,
			OutletType,
			OutletStatus,
			ContactState,
			Branch,
			BDMName,
			SalesSegment,
			TradingStatus,
			EGMNation,
			FCNation,
			FCArea,
			StateSalesArea			
		from [db-au-cmdwh].[dbo].penOutlet
		where 
			OutletKey = o.LatestOutletKey and
			OutletStatus = 'Current'
	) lo
where 
	lo.CountryKey = @CountryKey 
    --and lo.SuperGroupName  =  'Flight Centre'
	

IF OBJECT_ID('tempdb..#ActiveConsultantCount') IS NOT NULL DROP TABLE #ActiveConsultantCount
--Calculate active consultant count
SELECT
	Count(distinct q.ConsultantSK) [Consultant Count]
INTO
	#ActiveConsultantCount
FROM
	[db-au-star].dbo.vFactQuoteSummary q
	inner join [db-au-star].dbo.dimOutlet o 
		on q.OutletSK = o.OutletSK
WHERE
	o.Country  =  @CountryKey
	--AND
	--o.SuperGroupName  =  'Flight Centre'
	AND 
	q.OutletReference = 'Latest alpha'
	AND
	q.DateSk between (select Date_SK from [db-au-star].dbo.dim_date where date=@rptStartDate) and (select Date_SK from [db-au-star].dbo.dim_date where date=@rptEndDate)



IF OBJECT_ID('tempdb..#CYQuote') IS NOT NULL DROP TABLE #CYQuote
--Calculate current year quote count for each store
select 
	po.FCNation,
	Sum(q.SelectedQuoteCount) [QuoteCount]
Into
	#CYQuote
from
    (
        select
            q.OutletSK,
            case
                --use quote count for integrated
                when exists
                (
                    select
                        null
                    from
                        [db-au-star]..dimIntegratdOutlet r
                    where
                        r.OutletSK = q.OutletSK
                ) then q.QuoteCount
                when c.ConsultantSK is not null then q.QuoteSessionCount
                else q.QuoteCount
            end SelectedQuoteCount
        from
            [db-au-star].dbo.factQuoteSummary q
            outer apply
            (
                select top 1 
                    ConsultantSK
                from
                    [db-au-star].dbo.dimConsultant c
                where
                    c.ConsultantSK = q.ConsultantSK and
                    c.ConsultantName like '%webuser%'
            ) c
        where
            DateSK between (select Date_SK from [db-au-star].dbo.dim_date where date=@rptStartDate) and (select Date_SK from [db-au-star].dbo.dim_date where date=@rptEndDate)

        union all

        select
            q.OutletSK,
            case
                --no bot for integrated
                when exists
                (
                    select
                        null
                    from
                        [db-au-star]..dimIntegratdOutlet r
                    where
                        r.OutletSK = q.OutletSK
                ) then 0
                when c.ConsultantSK is not null then q.QuoteSessionCount
                else q.QuoteCount
            end SelectedQuoteCount
        from
            [db-au-star].dbo.factQuoteSummaryBot q
            outer apply
            (
                select top 1 
                    ConsultantSK
                from
                    [db-au-star].dbo.dimConsultant c
                where
                    c.ConsultantSK = q.ConsultantSK and
                    c.ConsultantName like '%webuser%'
            ) c
        where
            DateSK between (select Date_SK from [db-au-star].dbo.dim_date where date=@rptStartDate) and (select Date_SK from [db-au-star].dbo.dim_date where date=@rptEndDate)
    ) q
    cross apply
    (
        select 'Latest alpha' OutletReference
    ) ref
	inner join [db-au-star].dbo.dimOutlet o on q.OutletSK = o.OutletSK
	   inner join #Outlet po on po.OutletAlphaKey = o.OutletAlphaKey
where
       o.Country = @CountryKey and
	   --o.SuperGroupName = 'Flight Centre' and
	   po.OutletStatus = 'Current'
Group by
	po.FCNation


IF OBJECT_ID('tempdb..#LYQuote') IS NOT NULL DROP TABLE #LYQuote
--Calculate Last year quote count for each store
select 
	po.FCNation,
	Sum(q.SelectedQuoteCount) [QuoteCount]
Into
	#LYQuote
from
    (
        select
            q.OutletSK,
            case
                --use quote count for integrated
                when exists
                (
                    select
                        null
                    from
                        [db-au-star]..dimIntegratdOutlet r
                    where
                        r.OutletSK = q.OutletSK
                ) then q.QuoteCount
                when c.ConsultantSK is not null then q.QuoteSessionCount
                else q.QuoteCount
            end SelectedQuoteCount
        from
            [db-au-star].dbo.factQuoteSummary q
            outer apply
            (
                select top 1 
                    ConsultantSK
                from
                    [db-au-star].dbo.dimConsultant c
                where
                    c.ConsultantSK = q.ConsultantSK and
                    c.ConsultantName like '%webuser%'
            ) c
        where
            DateSK between (select Date_SK from [db-au-star].dbo.dim_date where date=@rptStartDateLY) and (select Date_SK from [db-au-star].dbo.dim_date where date=@rptEndDateLY)

        union all

        select
            q.OutletSK,
            case
                --no bot for integrated
                when exists
                (
                    select
                        null
                    from
                        [db-au-star]..dimIntegratdOutlet r
                    where
                        r.OutletSK = q.OutletSK
                ) then 0
                when c.ConsultantSK is not null then q.QuoteSessionCount
                else q.QuoteCount
            end SelectedQuoteCount
        from
            [db-au-star].dbo.factQuoteSummaryBot q
            outer apply
            (
                select top 1 
                    ConsultantSK
                from
                    [db-au-star].dbo.dimConsultant c
                where
                    c.ConsultantSK = q.ConsultantSK and
                    c.ConsultantName like '%webuser%'
            ) c
        where
            DateSK between (select Date_SK from [db-au-star].dbo.dim_date where date=@rptStartDateLY) and (select Date_SK from [db-au-star].dbo.dim_date where date=@rptEndDateLY)
    ) q
    cross apply
    (
        select 'Latest alpha' OutletReference
    ) ref
	inner join [db-au-star].dbo.dimOutlet o on q.OutletSK = o.OutletSK
	   inner join #Outlet po on po.OutletAlphaKey = o.OutletAlphaKey
where
       o.Country = @CountryKey and
	   --o.SuperGroupName = 'Flight Centre' and
	   po.OutletStatus = 'Current'
Group by
	po.FCNation



--Main query combining above details with CY and LY flight centre KPI details
IF OBJECT_ID('tempdb..#MainTable') IS NOT NULL DROP TABLE #MainTable
SELECT
	po.CountryKey,
	po.SuperGroupName,
	po.SubGroupName,
	po.FCNation,
	pp.AreaType,
	pp.ProductDisplayName,
	pp.Area,
	Case
		When pt.Age between 0 and 16 then 'Age Group 0 - 16'
		When pt.Age between 17 and 24 then 'Age Group 17 - 24'
		When pt.Age between 25 and 34 then 'Age Group 25 - 34'
		When pt.Age between 35 and 49 then 'Age Group 35 - 49'
		When pt.Age between 50 and 59 then 'Age Group 50 - 59'
		When pt.Age between 60 and 64 then 'Age Group 60 - 64'
		When pt.Age between 65 and 69 then 'Age Group 65 - 69'
		When pt.Age between 70 and 74 then 'Age Group 70 - 74'
		When pt.Age >= 75 then 'Age Group 75+'
	End [AgeGroup],
	Sum(Case
			When pp.AreaType = 'International' and datediff(day,pp.IssueDate,pp.TripStart) = 0 then 1
			when pp.AreaType = 'International' and datediff(day,pp.IssueDate,pp.TripStart) <> 0 then datediff(day,pp.IssueDate,pp.TripStart)
			Else 0
		End
		) InternationalLeadTime,
	Sum(Case
			When pp.AreaType <> 'International' and datediff(day,pp.IssueDate,pp.TripStart) = 0 then 1
			when pp.AreaType <> 'International' and datediff(day,pp.IssueDate,pp.TripStart) <> 0 then datediff(day,pp.IssueDate,pp.TripStart)
			Else 0
		End
		) DomesticLeadTime,
	sum(ppt.InternationalPolicyCount) [InternationalPolicyCount],
	sum(ppt.DomesticPolicyCount) [DomesticPolicyCount],
	sum(vp.Premium) [Premium],
	(select cq.QuoteCount from #CYQuote cq where cq.FCNation = po.FCNation) [QuoteCount],
	0 InternationalLeadTimeLY,
	0 DomesticLeadTimeLY,
	0 [InternationalPolicyCountLY],
	0 [DomesticPolicyCountLY],
	0 [PremiumLY],
	(select lq.QuoteCount from #LYQuote lq where lq.FCNation = po.FCNation) [QuoteCountLY],
	@rptStartDate [Start Date],
	@rptEndDate [End Date],
	@rptStartDateLY [Start Date LY],
	@rptEndDateLY [End Date LY],
	(select sum([Current Month Business Days]) from #BusinessDays) [Current Month Business Days],
	(select sum([Month-To-Date Business Days]) from #BusinessDays) [Month-To-Date Business Days],
	(select sum([Last Year Current Month Business Days]) from #BusinessDays) [Last Year Current Month Business Days],
	(select sum([Last Year Month-To-Date Business Days]) from #BusinessDays) [Last Year Month-To-Date Business Days],
	(select [Consultant Count] from #ActiveConsultantCount) [Active Consultant Count],
	pp.TripCost,  ---convert(bigint,pp.TripCost) as TripCost ,
	pp.Excess 
Into
	#MainTable
FROM
	[db-au-cmdwh].[dbo].penPolicyTransSummary ppt INNER JOIN [db-au-cmdwh].[dbo].penPolicy pp ON (ppt.PolicyKey=pp.PolicyKey)
	INNER JOIN #Outlet po ON (ppt.OutletAlphaKey=po.OutletAlphaKey)
	INNER JOIN [db-au-cmdwh].[dbo].vPenguinPolicyPremiums vp ON (vp.PolicyTransactionKey=ppt.PolicyTransactionKey)
	outer apply
	(
		select
			pt.Age
		From
			[db-au-cmdwh].[dbo].penPolicyTraveller pt
		Where
			pt.PolicyKey = pp.PolicyKey
			and pt.IsPrimary = 1
	) pt
WHERE
	(
	po.CountryKey  =  @CountryKey
	--AND po.SuperGroupName  =  'Flight Centre'
	AND (
        (	
			@ReferenceDate = 'Posting Date' and
            ppt.PostingDate >= @rptStartDate and 
            ppt.PostingDate < dateadd(day, 1, @rptEndDate) 
        )
		or
		(	
			@ReferenceDate = 'Issue Date' and
            ppt.IssueDate >= @rptStartDate and 
            ppt.IssueDate < dateadd(day, 1, @rptEndDate) 
        )
    ) 
	AND
	( po.OutletStatus = 'Current'  )
	)
GROUP BY
	po.CountryKey, 
	po.SuperGroupName, 
	po.SubGroupName, 
	po.FCNation, 
	pp.AreaType, 
	pp.ProductDisplayName,
	pp.Area,
	pp.TripCost,-----convert(bigint,pp.TripCost),
	pp.Excess,
	Case
		When pt.Age between 0 and 16 then 'Age Group 0 - 16'
		When pt.Age between 17 and 24 then 'Age Group 17 - 24'
		When pt.Age between 25 and 34 then 'Age Group 25 - 34'
		When pt.Age between 35 and 49 then 'Age Group 35 - 49'
		When pt.Age between 50 and 59 then 'Age Group 50 - 59'
		When pt.Age between 60 and 64 then 'Age Group 60 - 64'
		When pt.Age between 65 and 69 then 'Age Group 65 - 69'
		When pt.Age between 70 and 74 then 'Age Group 70 - 74'
		When pt.Age >= 75 then 'Age Group 75+'
	End

UNION

SELECT
	po.CountryKey,
	po.SuperGroupName,
	po.SubGroupName,
	po.FCNation,
	pp.AreaType,
	pp.ProductDisplayName,
	pp.Area,
	Case
		When pt.Age between 0 and 16 then 'Age Group 0 - 16'
		When pt.Age between 17 and 24 then 'Age Group 17 - 24'
		When pt.Age between 25 and 34 then 'Age Group 25 - 34'
		When pt.Age between 35 and 49 then 'Age Group 35 - 49'
		When pt.Age between 50 and 59 then 'Age Group 50 - 59'
		When pt.Age between 60 and 64 then 'Age Group 60 - 64'
		When pt.Age between 65 and 69 then 'Age Group 65 - 69'
		When pt.Age between 70 and 74 then 'Age Group 70 - 74'
		When pt.Age >= 75 then 'Age Group 75+'
	End [AgeGroup],
	0 InternationalLeadTime,
	0 DomesticLeadTime,
	0 [InternationalPolicyCount],
	0 [DomesticPolicyCount],
	0 [Premium],
	(select cq.QuoteCount from #CYQuote cq where cq.FCNation = po.FCNation) [QuoteCount],
	Sum(Case
			When pp.AreaType = 'International' and datediff(day,pp.IssueDate,pp.TripStart) = 0 then 1
			when pp.AreaType = 'International' and datediff(day,pp.IssueDate,pp.TripStart) <> 0 then datediff(day,pp.IssueDate,pp.TripStart)
			Else 0
		End
		) InternationalLeadTimeLY,
	Sum(Case
			When pp.AreaType <> 'International' and datediff(day,pp.IssueDate,pp.TripStart) = 0 then 1
			when pp.AreaType <> 'International' and datediff(day,pp.IssueDate,pp.TripStart) <> 0 then datediff(day,pp.IssueDate,pp.TripStart)
			Else 0
		End
		) DomesticLeadTimeLY,
	sum(ppt.InternationalPolicyCount) [InternationalPolicyCountLY],
	sum(ppt.DomesticPolicyCount) [DomesticPolicyCountLY],
	sum(vp.Premium) [PremiumLY],
	(select lq.QuoteCount from #LYQuote lq where lq.FCNation = po.FCNation) [QuoteCountLY],
	@rptStartDate [Start Date],
	@rptEndDate [End Date],
	@rptStartDateLY [Start Date LY],
	@rptEndDateLY [End Date LY],
	(select sum([Current Month Business Days]) from #BusinessDays) [Current Month Business Days],
	(select sum([Month-To-Date Business Days]) from #BusinessDays) [Month-To-Date Business Days],
	(select sum([Last Year Current Month Business Days]) from #BusinessDays) [Last Year Current Month Business Days],
	(select sum([Last Year Month-To-Date Business Days]) from #BusinessDays) [Last Year Month-To-Date Business Days],
	(select [Consultant Count] from #ActiveConsultantCount) [Active Consultant Count],
	pp.TripCost,---convert(bigint,pp.TripCost) as TripCost,
	pp.Excess
FROM
	[db-au-cmdwh].[dbo].penPolicyTransSummary ppt INNER JOIN [db-au-cmdwh].[dbo].penPolicy pp ON (ppt.PolicyKey=pp.PolicyKey)
	INNER JOIN #Outlet po ON (ppt.OutletAlphaKey=po.OutletAlphaKey)
	INNER JOIN [db-au-cmdwh].[dbo].vPenguinPolicyPremiums vp ON (vp.PolicyTransactionKey=ppt.PolicyTransactionKey)
	outer apply
	(
		select
			pt.Age
		From
			[db-au-cmdwh].[dbo].penPolicyTraveller pt
		Where
			pt.PolicyKey = pp.PolicyKey
			and pt.IsPrimary = 1
	) pt
WHERE
	(
	po.CountryKey  =  @CountryKey
	--AND po.SuperGroupName  =  'Flight Centre'
	AND
	po.LatestOutletKey in (select distinct LatestOutletKey from #outlet)
	AND (
        (	
			@ReferenceDate = 'Posting Date' and
            ppt.PostingDate >= @rptStartDateLY and 
            ppt.PostingDate < dateadd(day, 1, @rptEndDateLY) 
        )
		or
		(	
			@ReferenceDate = 'Issue Date' and
            ppt.IssueDate >= @rptStartDateLY and 
            ppt.IssueDate < dateadd(day, 1, @rptEndDateLY) 
        )
    ) 
	AND
	( po.OutletStatus = 'Current'  )
	)
GROUP BY
	po.CountryKey, 
	po.SuperGroupName, 
	po.SubGroupName, 
	po.FCNation, 
	pp.AreaType, 
	pp.ProductDisplayName,
	pp.Area,
	pp.TripCost,---convert(bigint,pp.TripCost),
	pp.Excess,
	Case
		When pt.Age between 0 and 16 then 'Age Group 0 - 16'
		When pt.Age between 17 and 24 then 'Age Group 17 - 24'
		When pt.Age between 25 and 34 then 'Age Group 25 - 34'
		When pt.Age between 35 and 49 then 'Age Group 35 - 49'
		When pt.Age between 50 and 59 then 'Age Group 50 - 59'
		When pt.Age between 60 and 64 then 'Age Group 60 - 64'
		When pt.Age between 65 and 69 then 'Age Group 65 - 69'
		When pt.Age between 70 and 74 then 'Age Group 70 - 74'
		When pt.Age >= 75 then 'Age Group 75+'
	End

Select
	*
From
	#MainTable
Where
	IsNull(InternationalLeadTime, 0) <> 0 or
	IsNull(DomesticLeadTime, 0) <> 0 or
	IsNull(InternationalPolicyCount, 0) <> 0 or
	IsNull(DomesticPolicyCount, 0) <> 0 or
	IsNull(Premium, 0) <> 0 or
	--IsNull(QuoteCount, 0) <> 0 or
	IsNull(InternationalLeadTimeLY, 0) <> 0 or
	IsNull(DomesticLeadTimeLY, 0) <> 0 or
	IsNull(InternationalPolicyCountLY, 0) <> 0 or
	IsNull(DomesticPolicyCountLY, 0) <> 0 or
	IsNull(PremiumLY, 0) <> 0 
	--or
	--IsNull(QuoteCountLY, 0) <> 0


end





GO
