USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_dashboard_liveclaimclose]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_dashboard_liveclaimclose]
as
begin

    declare @utcdate datetime
    set @utcdate = dbo.xfn_ConvertLocaltoUTC(convert(date, getdate()), 'AUS Eastern Standard Time')

    if object_id('tempdb..#liveestimate') is not null
        drop table #liveestimate

    select 
        c.KLCLAIM ClaimNo,
        s.KS_ID SectionID,
        s.KSESTV CurrentEstimate,
        eh.EHEstimate Estimate,
        EHCREATED EstimateDate,
        EHCreatedBy_id EstimateBy,
        c.KLCREATED RegisterDate
    into #liveestimate 
    from
        [db-au-penguinsharp.aust.covermore.com.au].CLAIMS.dbo.KLREG c
        inner join [db-au-penguinsharp.aust.covermore.com.au].CLAIMS.dbo.KLSECTION s on
            s.KSCLAIM_ID = c.KLCLAIM
        inner join [db-au-penguinsharp.aust.covermore.com.au].CLAIMS.dbo.KLESTHIST eh on
            eh.EHIS_ID = s.KS_ID
    where
        KLDOMAINID = 7 and
        s.KS_ID in
        (
            select 
                EHIS_ID
            from
                [db-au-penguinsharp.aust.covermore.com.au].CLAIMS.dbo.KLESTHIST
            where
                EHCREATED >= @utcdate
        ) 

    union

    select 
        c.KLCLAIM ClaimNo,
        s.KS_ID SectionID,
        s.KSESTV CurrentEstimate,
        eh.EHEstimate Estimate,
        EHCREATED EstimateDate,
        isnull(EHCreatedBy_id, KLCREATEDBY_ID) EstimateBy,
        c.KLCREATED RegisterDate
    from
        [db-au-penguinsharp.aust.covermore.com.au].CLAIMS.dbo.KLREG c
        left join [db-au-penguinsharp.aust.covermore.com.au].CLAIMS.dbo.KLSECTION s on
            s.KSCLAIM_ID = c.KLCLAIM
        left join [db-au-penguinsharp.aust.covermore.com.au].CLAIMS.dbo.KLESTHIST eh on
            eh.EHIS_ID = s.KS_ID
    where
        KLDOMAINID = 7 and
        KLCREATED >= @utcdate

    create nonclustered index idx on #liveestimate (ClaimNo,SectionID) include (CurrentEstimate,Estimate,EstimateDate,EstimateBy,RegisterDate)

    update #liveestimate 
    set
        EstimateDate = dbo.xfn_ConvertUTCtoLocal(EstimateDate, 'AUS Eastern Standard Time'),
        RegisterDate = dbo.xfn_ConvertUTCtoLocal(RegisterDate, 'AUS Eastern Standard Time')


    --select *
    --from
    --    cte_closed
    --where
    --    YesterdayEstimate is null

    --select * 
    --from 
    --    vclmClaimIncurred 
    --where 
    --    ClaimKey = 'AU-878725'

    --select * 
    --from 
    --    clmClaimEstimateMovement
    --where 
    --    ClaimKey = 'AU-878725'


    ;with
    cte_closedtoday as
    (
        select 
            ClaimNo,
            RegisterDate,
            CurrentEstimate,
            YesterdayEstimate,
            TodayFirstEstimate,
            EstimateDate,
            EstimateBy
        from
            (
                select 
                    ClaimNo,
                    max(RegisterDate) RegisterDate,
                    sum(CurrentEstimate) CurrentEstimate
                from
                    #liveestimate
                group by
                    ClaimNo
            ) c
            outer apply
            (
                select top 1
                    EstimateDate,
                    EstimateBy
                from
                    #liveestimate le
                    outer apply
                    (
                        select top 1
                            pe.Estimate PreviousEstimate
                        from
                            #liveestimate pe
                        where
                            pe.ClaimNo = le.ClaimNo and
                            pe.SectionID = le.SectionID and
                            pe.EstimateDate < le.EstimateDate
                        order by
                            pe.EstimateDate desc
                    ) pe
                where
                    le.ClaimNo = c.ClaimNo and
                    (
                        le.Estimate <> pe.PreviousEstimate or
                        pe.PreviousEstimate is null
                    )
                order by
                    EstimateDate desc
            ) le
            outer apply
            (
                select top 1
                    Estimate YesterdayEstimate
                from
                    vclmClaimIncurred
                where
                    ClaimKey = 'AU-' + convert(varchar, c.ClaimNo) and
                    IncurredDate < convert(date, getdate())
                order by
                    IncurredDate desc
            ) ci
            outer apply
            (
                select 
                    sum(isnull(TodayFirstEstimate, 0)) TodayFirstEstimate
                from
                    (
                        select distinct
                            s.SectionID
                        from
                            #liveestimate s
                        where
                            s.ClaimNo = c.ClaimNo
                    ) s
                    outer apply
                    (
                        select top 1 
                            Estimate TodayFirstEstimate
                        from
                            #liveestimate me
                        where
                            me.ClaimNo = c.ClaimNo and
                            me.SectionID = s.SectionID and
                            me.EstimateDate >= convert(date, getdate())
                        order by
                            me.EstimateDate
                    ) me
            ) me
    ),
    cte_ytd as
    (
        select 
            AbsoluteAge,
            DateClosed,
            DateClosedBy,
            ClaimKey,
            case
                when 
                    Estimate = 0 and
                    (
                        PreviousEstimate <> 0 or
                        DateFirstEstimate <> 0
                    )
                then 1
                else 0
            end YTDClosedCount,
            case
                when ci.AbsoluteAge = 0 then 0
                when ci.NewMovements > 0 and ci.NewMovements >= ci.RedundantMovements and ci.IncurredAge > 0 then 1
                when ci.ReopenedMovements > 0 then 1
                when 
                    ci.Estimate <> 0 and
                    ci.PreviousEstimate = 0 and
                    ci.AbsoluteAge > 0 and
                    ci.PreviousAbsoluteAge > 0
                then 1
                else 0
            end YTDReopenedCount,
            case
                when ci.AbsoluteAge = 0 then 1
                else 0
            end YTDNewCount
        from
            vclmClaimIncurred ci
            cross apply
            (
                select 
                    sum(isnull(DateFirstEstimate, 0)) DateFirstEstimate
                from
                    clmSection cs
                    outer apply
                    (
                        select top 1 
                            fe.EHEstimateValue DateFirstEstimate
                        from
                            clmEstimateHistory fe
                        where
                            fe.SectionKey = cs.SectionKey and
                            fe.EHCreateDate >= ci.IncurredDate
                        order by
                            fe.EHCreateDate
                    ) fe
                where
                    cs.ClaimKey = ci.ClaimKey
                group by
                    cs.ClaimKey
            ) e
            cross apply
            (
                select top 1 
                    e.EHCreatedBy DateClosedBy,
                    e.EHCreateDate DateClosed
                from
                    clmEstimateHistory e
                where
                    e.ClaimKey = ci.ClaimKey and
                    e.EHCreateDate >= ci.IncurredDate and
                    e.EHCreateDate <  dateadd(day, 1, ci.IncurredDate)
                order by
                    e.EHCreateDate desc
            ) eby
        where
            ClaimKey like 'AU%' and
            IncurredDate < convert(date, getdate()) and
            IncurredDate >= 
            (
                select top 1
                    CurFiscalYearStart
                from
                    Calendar
                where
                    [Date] = convert(date, getdate())
            ) 
            --and
            --(
            --    Estimate = 0 and
            --    (
            --        PreviousEstimate <> 0 or
            --        DateFirstEstimate <> 0
            --    )
            --)
    ),
    cte_ytdagg as
    (
        select 
            --DateClosedBy CaseOfficer,
            'YTD Average' CaseOfficer,
            datepart(hh, DateClosed) [Hour],
            sum(YTDClosedCount) YTDClosedCount,
            sum(YTDReopenedCount) YTDReopenedCount,
            sum(YTDNewCount) YTDNewCount,
            count(distinct convert(date, DateClosed)) DayCount
        from
            cte_ytd
        group by
            --DateClosedBy,
            datepart(hh, DateClosed)
    )
    select 
        CaseOfficer,
        --ClaimNo,
        --RegisterDate,
        datepart(hh, isnull(EstimateDate, RegisterDate)) [Hour],
        sum(TodayClosedCount) TodayClosedCount,
        sum(TodayReopenedCount) TodayReopenedCount,
        sum(TodayNewCount) TodayNewCount,
        sum(TodayClosedCount - TodayReopenedCount - TodayNewCount) TodayNetClosedCount,
        0.00 YTDAvgClosedCount,
        0.00 YTDAvgReopenedCount,
        0.00 YTDAvgNewCount,
        0.00 YTDAvgNetClosedCount
    from
        cte_closedtoday c
        cross apply
        (
            select
                case
                    when 
                        CurrentEstimate = 0 and
                        (
                            YesterdayEstimate <> 0 or
                            TodayFirstEstimate <> 0
                        )
                    then 1.00
                    else 0
                end TodayClosedCount,
                case
                    when RegisterDate >= convert(date, getdate()) then 0.00
                    when 
                        YesterdayEstimate = 0 and
                        (
                            CurrentEstimate <> 0 or
                            TodayFirstEstimate <> 0
                        )
                    then 1.00
                    else 0
                end TodayReopenedCount,
                case
                    when RegisterDate >= convert(date, getdate()) then 1.00
                    else 0
                end TodayNewCount
        ) cs
        outer apply
        (
            select top 1
                Name CaseOfficer
            from
                clmSecurity cs
            where
                SecurityID = c.EstimateBy
        ) co
    group by
        CaseOfficer,
        --ClaimNo,
        datepart(hh, isnull(EstimateDate, RegisterDate))

    union all

    select 
        'YTD Average', 
        --CaseOfficer,
        [Hour],
        0 TodayClosedCount,
        0 TodayReopenedCount,
        0 TodayNewCount,
        0 TodayNetClosed,
        case
            when DayCount = 0 then 0
            else YTDClosedCount * 1.00 / DayCount
        end YTDAvgClosedCount,
        case
            when DayCount = 0 then 0
            else YTDReopenedCount * 1.00 / DayCount
        end YTDAvgReopenedCount,
        case
            when DayCount = 0 then 0
            else YTDNewCount * 1.00 / DayCount
        end YTDAvgNewCount,
        case
            when DayCount = 0 then 0
            else (YTDClosedCount - YTDReopenedCount - YTDNewCount) * 1.00 / DayCount
        end YTDAvgNetClosedCount
    from
        cte_ytdagg

    --select *
    --from
    --    cte_ytd
    --where
    --    ClaimKey = 'AU-890743'

end
GO
