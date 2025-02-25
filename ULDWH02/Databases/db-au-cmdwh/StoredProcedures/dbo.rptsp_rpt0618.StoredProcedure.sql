USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0618]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[rptsp_rpt0618] @ReportingPeriod varchar(30)   
as
begin

--20150408, LS, F23930, bug fix on past spin count formula
--                      bug fix, on weeks where there's no sales

--declare
--    @ReportingPeriod varchar(30)
    
--select
--    @ReportingPeriod = 'Last Month'
    
    
    set nocount on

    declare 
        @rptStartDate date,
        @rptEndDate date

    --get reporting dates
    select 
        @rptStartDate = StartDate, 
        @rptEndDate = EndDate
    from 
        vDateRange
    where 
        DateRange = @ReportingPeriod

    --week starts on monday
    set datefirst 1

    if object_id('tempdb..#sales') is not null
        drop table #sales

    select 
        u.[Login],
        datepart(week, pt.PostingDate) - datepart(week, @rptStartDate) + 1 [Week Number],
        sum(BasePolicyCount) [Policy Count]
    into #sales
    from
        penPolicyTransSummary pt
        inner join penPolicy p on
            p.PolicyKey = pt.PolicyKey
        inner join penOutlet o on
            o.OutletAlphaKey = pt.OutletAlphaKey and
            o.OutletStatus = 'Current'
        inner join penUser u on
            u.UserKey = pt.UserKey and
            u.UserStatus = 'Current'
    where
        o.CountryKey = 'AU' and
        o.SuperGroupName = 'Flight Centre' and
        pt.PostingDate >= @rptStartDate and
        pt.PostingDate <  dateadd(day, 1, @rptEndDate) and
        p.AreaType = 'International' and
        u.[Login] not in ('SysUser', 'webuser', 'ozgold', 'training')
    group by
        u.[Login],
        datepart(week, pt.PostingDate)
        
    create nonclustered index idx on #sales ([Login],[Week Number]) include ([Policy Count])

    declare @lastweek int
    select 
        @lastweek = max([Week Number])
    from
        #sales

    ;with cte_filler as
    (
        select 
            1 [Week Number]
        
        union all
        
        select
            [Week Number] + 1
        from
            cte_filler
        where
            [Week Number] < @lastweek
    )
    insert into #sales
    (
        [Login],
        [Week Number],
        [Policy Count]
    )
    select 
        sm.[Login],
        t.[Week Number],
        0 [Policy Count]
    from
        cte_filler t
        cross apply
        (
            select distinct
                [Login]
            from
                #sales sm
        ) sm
        left join #sales s on
            s.[Login] = sm.[Login] and
            s.[Week Number] = t.[Week Number]
    where
        s.[Week Number] is null

    ;with
    cte_cumulative as
    (
        select 
            [Login],
            [Week Number],
            [Policy Count],
            [Cumulative Policy Count],
            case
                when [Cumulative Policy Count] > 9 then [Cumulative Policy Count] - 9
                else 0
            end [Spin Count]
        from
            #sales t
            outer apply
            (
                select 
                    sum(isnull(r.[Policy Count], 0)) [Cumulative Policy Count]
                from
                    #sales r
                where
                    r.[Login] = t.[Login] and
                    r.[Week Number] <= t.[Week Number]
            ) r
    )
    select 
        [T4 Code],
        [Login],
        [First Name],
        [Surname],
        [Agency Address],
        [Suburb],
        [State],
        [Post Code],
        [Email],
        [Week Number],
        case
            when [Week End] > @rptEndDate then @rptEndDate
            else [Week End]
        end [Week End],
        [Policy Count],
        [Cumulative Policy Count],
        case
            when [Spin Count] - isnull([Past Spin Count], 0) < 0 then 0
            else [Spin Count] - isnull([Past Spin Count], 0)
        end [Spin Count],
        [Store Name]
    from
        cte_cumulative t
        outer apply
        (
            select top 1 
                r.[Spin Count] [Past Spin Count]
            from
                cte_cumulative r
            where
                r.[Login] = t.[Login] and
                r.[Week Number] < t.[Week Number]
            order by
                r.[Week Number] desc
        ) r
        cross apply
        (
            select
                dateadd(week, [Week Number] - 1, dateadd(day, 7 - datepart(dw, @rptStartDate), @rptStartDate)) [Week End]
        ) we
        outer apply
        (
            select 
                t4.EMP_T4_CODE [T4 Code],
                t4.EMP_EMAIL [Email]
            from
                usrFLT4Code t4
            where
                t4.EMP_T4_CODE = t.[Login]
        ) t4
        outer apply
        (
            select top 1 
                u.FirstName [First Name],
                u.LastName [Surname],
                o.OutletName [Store Name],
                o.ContactStreet [Agency Address],
                o.ContactSuburb [Suburb],
                o.ContactState [State],
                o.ContactPostCode [Post Code]
            from
                penUser u
                inner join penOutlet o on
                    o.OutletKey = u.OutletKey
            where
                o.CountryKey = 'AU' and
                o.SuperGroupName = 'Flight Centre' and
                u.UserStatus = 'Current' and
                o.OutletStatus = 'Current' and
                u.[Login] = t.[Login]
        ) u


end
GO
