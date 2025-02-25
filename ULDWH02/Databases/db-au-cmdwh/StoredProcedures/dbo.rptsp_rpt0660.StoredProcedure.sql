USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0660]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0660]
as
begin

    declare 
        @ReportingPeriod varchar(30),
        @StartDate date,
        @EndDate date

    select 
        @ReportingPeriod = '_User Defined',
        @StartDate = '2015-08-01',
        @EndDate = '2015-09-30'


    set nocount on

    declare
        @start datetime,
        @end datetime

    --get reporting dates
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

    --week starts on monday
    set datefirst 1

    --if object_id('tempdb..#raw') is not null
    --    drop table #raw

    ;with cte_sales
    as
    (
        select
            pt.PolicyNumber,
            pt.TransactionStatus,
            --pt.IssueDate,
            pt.PostingDate [Date],
            datename(month, pt.PostingDate) [Month],
            datepart(week, pt.PostingDate) - datepart(week, convert(varchar(7), pt.PostingDate, 120) + '-01') + 1 WeekOfMonth,
            lo.AlphaCode,
            lo.OutletName,
            lo.StateSalesArea,
            lo.ExtBDMID,
            lo.ExternalBDMName,
            lo.BDMName,
            rtrim(ltrim(u.FirstName)) + ' ' + rtrim(ltrim(u.LastName)) Consultant,
            pt.BasePolicyCount PolicyCount,
            pt.InternationalPolicyCount INTPolicyCount,
            pt.GrossPremium SellPrice,
            0 LYPolicyCount,
            0 LYINTPolicyCount,
            0 LYSellPrice
        from
            penPolicyTransSummary pt
            inner join penPolicy p on
                p.PolicyKey = pt.PolicyKey
            inner join penOutlet o on
                o.OutletAlphaKey = pt.OutletAlphaKey and
                o.OutletStatus = 'Current'
            inner join penOutlet lo on
                lo.OutletKey = o.LatestOutletKey and
                lo.OutletStatus = 'Current'
            left join penUser u on
                u.UserKey = pt.UserKey and
                u.UserStatus = 'Current'
        where
            lo.CountryKey = 'AU' and
            lo.SuperGroupName = 'Stella' and /*helloworld excluding TCIS*/
            pt.PostingDate >= @start and
            pt.PostingDate <  dateadd(day,1 , @end)

        union all

        select
            pt.PolicyNumber,
            pt.TransactionStatus,
            pt.YAGOPostingDate [Date],
            datename(month, pt.PostingDate) [Month],
            datepart(week, pt.YAGOPostingDate) - datepart(week, convert(varchar(7), pt.YAGOPostingDate, 120) + '-01') + 1 WeekOfMonth,
            lo.AlphaCode,
            lo.OutletName,
            lo.StateSalesArea,
            lo.ExtBDMID,
            lo.ExternalBDMName,
            lo.BDMName,
            rtrim(ltrim(u.FirstName)) + ' ' + rtrim(ltrim(u.LastName)) Consultant,
            0 PolicyCount,
            0 INTPolicyCount,
            0 SellPrice,
            pt.BasePolicyCount LYPolicyCount,
            pt.InternationalPolicyCount LYINTPolicyCount,
            pt.GrossPremium LYSellPrice
        from
            penPolicyTransSummary pt
            inner join penPolicy p on
                p.PolicyKey = pt.PolicyKey
            inner join penOutlet o on
                o.OutletAlphaKey = pt.OutletAlphaKey and
                o.OutletStatus = 'Current'
            inner join penOutlet lo on
                lo.OutletKey = o.LatestOutletKey and
                lo.OutletStatus = 'Current'
            left join penUser u on
                u.UserKey = pt.UserKey and
                u.UserStatus = 'Current'
        where
            lo.CountryKey = 'AU' and
            lo.SuperGroupName = 'Stella' and
            pt.YAGOPostingDate >= @start and
            pt.YAGOPostingDate <  dateadd(day,1 , @end)
    )
    select 
        AlphaCode,
        OutletName,
        StateArea,
        ExtBDMID,
        ExternalBDMName,
        BDMName,
        Consultant,
        [Month],
        WeekOfMonth,
        PolicyNumber,
        TransactionStatus,
        min([Date]) FirstDateofWeek,
        max([Date]) LastDateofWeek,
        sum(isnull(PolicyCount, 0)) PolicyCount,
        sum(isnull(INTPolicyCount, 0)) INTPolicyCount,
        sum(isnull(SellPrice, 0)) SellPrice,
        sum(isnull(LYPolicyCount, 0)) LYPolicyCount,
        sum(isnull(LYINTPolicyCount, 0)) LYINTPolicyCount,
        sum(isnull(LYSellPrice, 0)) LYSellPrice
    --into #raw
    from
        cte_sales t
        cross apply
        (
            select
                case StateSalesArea
                    when 'Victoria' then 'VIC/TAS'
                    when 'Tasmania' then 'VIC/TAS'
                    when 'South Australia' then 'WA/SA/NT'
                    when 'Western Australia' then 'WA/SA/NT'
                    when 'New South Wales' then 'NSW/ACT'
                    when 'Queensland' then 'QLD'
                    when 'Australian Capital Territory' then 'NSW/ACT'
                    when 'Northern Territory' then 'WA/SA/NT'
                end StateArea
        ) sa
    group by
        AlphaCode,
        OutletName,
        StateArea,
        ExtBDMID,
        ExternalBDMName,
        BDMName,
        Consultant,
        [Month],
        PolicyNumber,
        TransactionStatus,
        WeekOfMonth

    --select *
    --from
    --    #raw

end
GO
