USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0631]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0631]
    @Country varchar(2),
    @ReportingPeriod varchar(30),
    @StartDate date = null,
    @EndDate date = null
as
begin
--20150424, LS, create F24210

--debug
--declare
--    @Country varchar(2),
--    @ReportingPeriod varchar(30),
--    @StartDate date,
--    @EndDate date

--select
--    @Country = 'AU',
--    @ReportingPeriod = 'Last March'

    set nocount on

    declare 
        @start date,
        @end date
    
    if @ReportingPeriod = '_User Defined' 
        select 
            @start = @StartDate,
            @end = @EndDate
    else
        select 
            @start = StartDate,
            @end = EndDate
        from
            vDateRange
        where
            DateRange = @ReportingPeriod

    if object_id('tempdb..#outletsk') is not null
        drop table #outletsk

    select 
        OutletSK
    into #outletsk
    from
        [db-au-star]..factPolicyTransaction pt
        inner join [db-au-star]..Dim_Date d on
            d.Date_SK = pt.DateSK
    where
        (
            d.[Date] >= @start and
            d.[Date] <  dateadd(day, 1, @end)
        ) or
        (
            d.[Date] >= dateadd(year, -1, @start) and
            d.[Date] <  dateadd(year, -1, dateadd(day, 1, @end))
        )        
        
    union
    
    select 
        OutletSK
    from
        [db-au-star]..factPolicyPremiumBudget b
        inner join [db-au-star]..Dim_Date d on
            d.Date_SK = b.DateSK
    where
        d.[Date] >= @start and
        d.[Date] <  dateadd(day, 1, @end)

    union
    
    select 
        sum(b.PolicyCountBudget) PolicyCountBudget
    from
        [db-au-star]..factPolicyCountBudget b
        inner join [db-au-star]..Dim_Date d on
            d.Date_SK = b.DateSK
    where
        d.[Date] >= @start and
        d.[Date] <  dateadd(day, 1, @end)

    union

    select 
        OutletSK
    from
        [db-au-star]..factCorporate c
        inner join [db-au-star]..Dim_Date d on
            d.Date_SK = c.DateSK
    where
        (
            d.[Date] >= @start and
            d.[Date] <  dateadd(day, 1, @end)
        ) or
        (
            d.[Date] >= dateadd(year, -1, @start) and
            d.[Date] <  dateadd(year, -1, dateadd(day, 1, @end))
        )
        
    union
    
    select 
        OutletSK
    from
        [db-au-star]..factQuoteSummary q
        inner join [db-au-star]..Dim_Date d on
            d.Date_SK = q.DateSK
    where
        (
            d.[Date] >= @start and
            d.[Date] <  dateadd(day, 1, @end)
        ) or
        (
            d.[Date] >= dateadd(year, -1, @start) and
            d.[Date] <  dateadd(year, -1, dateadd(day, 1, @end))
        ) 

    if object_id('tempdb..#outlet') is not null
        drop table #outlet

    select 
        OutletSK,
        AlphaCode,
        JVDesc PITJV,
        GroupName PITGroup,
        LAJV,
        LAGroup,
        Lineage
    into #outlet
    from
        [db-au-star]..dimOutlet o
        outer apply
        (
            select top 1 
                JVDesc LAJV,
                GroupName LAGroup
            from
                [db-au-star]..dimOutlet lo
            where
                lo.OutletSK = o.LatestOutletSK
        ) lo
        outer apply
        (
            select top 1 
                Lineage
            from
                penOutletLineage ol
            where
                ol.OutletKey = o.OutletKey
        ) ol
    where
        o.Country = @Country and
        o.OutletSK in
        (
            select 
                OutletSK
            from
                #outletsk
        )
    group by
        OutletSK,
        AlphaCode,
        JVDesc,
        GroupName,
        LAJV,
        LAGroup,
        Lineage

    select 
        AlphaCode,
        PITJV [Point In Time JV],
        PITGroup [Point In Time Group],
        LAJV [Latest Alpha JV],
        LAGroup [Latest Alpha Group],
        Lineage,
        sum(isnull(CYPremium, 0) + isnull(CYCorpPremium, 0)) [Premium (CY)],
        sum(isnull(CYPolicy, 0) + isnull(CYCorpPolicy, 0)) [Policy Count (CY)],
        sum(isnull(CYCommission, 0) + isnull(CYCorpCommission, 0)) [Commission (CY)],
        sum(isnull(PYPremium, 0) + isnull(PYCorpPremium, 0)) [Premium (PY)],
        sum(isnull(PYPolicy, 0) + isnull(PYCorpPolicy, 0)) [Policy Count (PY)],
        sum(isnull(PYCommission, 0) + isnull(PYCorpCommission, 0)) [Commission (PY)],
        sum(isnull(PremiumBudget, 0)) [Premium (Budget)],
        sum(isnull(PolicyCountBudget, 0)) [Policy Count (Budget)],
        sum(isnull(CYCorpQuote, 0) + isnull(CYQuoteCount, 0)) [Quote Count (CY)],
        sum(isnull(PYCorpQuote, 0) + isnull(PYQuoteCount, 0)) [Quote Count (PY)],
        convert(datetime,@start) StartDate,
        convert(datetime,dateadd(day, 1, @end)) EndDate
    from
        #outlet o
        outer apply
        (
            select 
                sum(Premium) CYPremium,
                sum(PolicyCount) CYPolicy,
                sum(Commission) CYCommission
            from
                [db-au-star]..factPolicyTransaction pt
                inner join [db-au-star]..Dim_Date d on
                    d.Date_SK = pt.DateSK
            where
                pt.OutletSK = o.OutletSK and
                d.[Date] >= @start and
                d.[Date] <  dateadd(day, 1, @end)
        ) cyp
        outer apply
        (
            select 
                sum(Premium) PYPremium,
                sum(PolicyCount) PYPolicy,
                sum(Commission) PYCommission
            from
                [db-au-star]..factPolicyTransaction pt
                inner join [db-au-star]..Dim_Date d on
                    d.Date_SK = pt.DateSK
            where
                pt.OutletSK = o.OutletSK and
                d.[Date] >= dateadd(year, -1, @start) and
                d.[Date] <  dateadd(year, -1, dateadd(day, 1, @end))
        ) pyp
        outer apply
        (
            select 
                sum(BudgetAmount) PremiumBudget
            from
                [db-au-star]..factPolicyPremiumBudget b
                inner join [db-au-star]..Dim_Date d on
                    d.Date_SK = b.DateSK
            where
                b.OutletSK = o.OutletSK and
                d.[Date] >= @start and
                d.[Date] <  dateadd(day, 1, @end)
        ) bpr
        outer apply
        (
            select 
                sum(b.PolicyCountBudget) PolicyCountBudget
            from
                [db-au-star]..factPolicyCountBudget b
                inner join [db-au-star]..Dim_Date d on
                    d.Date_SK = b.DateSK
            where
                b.OutletSK = o.OutletSK and
                d.[Date] >= @start and
                d.[Date] <  dateadd(day, 1, @end)
        ) bpc
        outer apply
        (
            select 
                sum(c.Premium) CYCorpPremium,
                sum(c.PolicyCount) CYCorpPolicy,
                sum(c.Commission) CYCorpCommission,
                sum(c.QuoteCount) CYCorpQuote
            from
                [db-au-star]..factCorporate c
                inner join [db-au-star]..Dim_Date d on
                    d.Date_SK = c.DateSK
            where
                c.OutletSK = o.OutletSK and
                d.[Date] >= @start and
                d.[Date] <  dateadd(day, 1, @end)
        ) cyc
        outer apply
        (
            select 
                sum(c.Premium) PYCorpPremium,
                sum(c.PolicyCount) PYCorpPolicy,
                sum(c.Commission) PYCorpCommission,
                sum(c.QuoteCount) PYCorpQuote
            from
                [db-au-star]..factCorporate c
                inner join [db-au-star]..Dim_Date d on
                    d.Date_SK = c.DateSK
            where
                c.OutletSK = o.OutletSK and
                d.[Date] >= dateadd(year, -1, @start) and
                d.[Date] <  dateadd(year, -1, dateadd(day, 1, @end))
        ) pyc
        outer apply
        (
            select 
                sum(q.QuoteCount) CYQuoteCount
            from
                [db-au-star]..factQuoteSummary q
                inner join [db-au-star]..Dim_Date d on
                    d.Date_SK = q.DateSK
            where
                q.OutletSK = o.OutletSK and
                d.[Date] >= @start and
                d.[Date] <  dateadd(day, 1, @end)
        ) cyq
        outer apply
        (
            select 
                sum(q.QuoteCount) PYQuoteCount
            from
                [db-au-star]..factQuoteSummary q
                inner join [db-au-star]..Dim_Date d on
                    d.Date_SK = q.DateSK
            where
                q.OutletSK = o.OutletSK and
                d.[Date] >= dateadd(year, -1, @start) and
                d.[Date] <  dateadd(year, -1, dateadd(day, 1, @end))
        ) pyq
    group by
        AlphaCode,
        PITJV ,
        PITGroup,
        LAJV,
        LAGroup,
        Lineage

end
GO
