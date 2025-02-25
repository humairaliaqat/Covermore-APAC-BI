USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_dashboard_liveclaimcloserate]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_dashboard_liveclaimcloserate]
as
begin

    declare @utcdate datetime
    set @utcdate = dbo.xfn_ConvertLocaltoUTC(convert(date, getdate()), 'AUS Eastern Standard Time')

    if object_id('tempdb..#telebyday') is not null
        drop table #telebyday

    select distinct
        convert(date, CallDate) CallDate,
        AgentName
    into #telebyday
    from
        vTelephonyCallData
    where
        CallDate >= '2015-07-01' and
        CSQName like '%tele%claim%'

    create nonclustered index idx on #telebyday (AgentName, CallDate)

    if object_id('tempdb..#liveestimate') is not null
        drop table #liveestimate

    select 
        c.KLCLAIM ClaimNo,
        s.KS_ID SectionID,
        s.KSESTV CurrentEstimate,
        eh.EHEstimate Estimate,
        EHCREATED EstimateDate,
        EHCreatedBy_id EstimateBy,
        c.KLCREATED RegisterDate,
        oc.AlphaCode,
        oc.ConsultantName,
        CaseOfficer
    into #liveestimate 
    from
        [db-au-penguinsharp.aust.covermore.com.au].CLAIMS.dbo.KLREG c
        inner join [db-au-penguinsharp.aust.covermore.com.au].CLAIMS.dbo.KLSECTION s on
            s.KSCLAIM_ID = c.KLCLAIM
        inner join [db-au-penguinsharp.aust.covermore.com.au].CLAIMS.dbo.KLESTHIST eh on
            eh.EHIS_ID = s.KS_ID
        left join [db-au-penguinsharp.aust.covermore.com.au].CLAIMS.dbo.tblOnlineClaims oc on
            oc.ClaimId = c.KLCLAIM
        outer apply
        (
            select top 1
                KSNAME CaseOfficer
            from
               [db-au-penguinsharp.aust.covermore.com.au].CLAIMS.dbo.KLSECURITY cs
            where
                cs.KS_ID = c.KLCREATEDBY_ID and
                cs.KSDOMAINID = c.KLDOMAINID
        ) co
    where
        c.KLDOMAINID = 7 and
        s.KS_ID in
        (
            select 
                EHIS_ID
            from
                [db-au-penguinsharp.aust.covermore.com.au].CLAIMS.dbo.KLESTHIST
            where
                EHCREATED >= @utcdate
        ) 

    create nonclustered index idx on #liveestimate (ClaimNo,SectionID) include (CurrentEstimate,Estimate,EstimateDate,EstimateBy,RegisterDate,CaseOfficer,ConsultantName)

    update #liveestimate 
    set
        EstimateDate = dbo.xfn_ConvertUTCtoLocal(EstimateDate, 'AUS Eastern Standard Time'),
        RegisterDate = dbo.xfn_ConvertUTCtoLocal(RegisterDate, 'AUS Eastern Standard Time')




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
            EstimateBy,
            case
                when CaseOfficer = 'Online Submitted' then isnull(DisplayName, '')
                else CaseOfficer collate database_default
            end CreatedBy
        from
            (
                select 
                    ClaimNo,
                    max(RegisterDate) RegisterDate,
                    sum(CurrentEstimate) CurrentEstimate,
                    max(CaseOfficer) CaseOfficer,
                    max(ConsultantName) ConsultantName
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
            outer apply
            (
                select top 1 
                    DisplayName
                from
                    usrLDAP
                where
                    UserName = c.ConsultantName collate database_default
            ) u
    ),
    cte_closed_r7d as
    (
        select 
            cl.ClaimNo,
            cl.CreateDate,
            IncurredDate CloseDate,
            case
                when CreatedBy = 'Online Submitted' then isnull(DisplayName, '')
                else CreatedBy
            end CreatedBy
        from
            clmClaim cl
            inner join vclmClaimIncurred ci on
                ci.ClaimKey = cl.ClaimKey
            outer apply
            (
                select top 1 
                    DisplayName
                from
                    usrLDAP
                where
                    UserName = OnlineConsultant
            ) u
        where
            cl.CountryKey = 'AU' and
            IncurredDate >= dateadd(day, -7, convert(date, getdate())) and
            IncurredDate <  convert(date, getdate()) and
            (
                --closed
                (
                    ci.Estimate = 0 and
                    (
                        ci.PreviousEstimate <> 0 or
                        ci.RedundantMovements > 0
                    )
                ) 
            )
    ),
    cte_all as
    (
        select
            ClaimNo,
            CreatedBy,
            convert(date, RegisterDate) CreateDate,
            convert(date, getdate()) CloseDate
        from
            cte_closedtoday c
        where
            CurrentEstimate = 0 and
            (
                YesterdayEstimate <> 0 or
                TodayFirstEstimate <> 0
            )

        union all

        select
            ClaimNo,
            CreatedBy,
            convert(date, CreateDate),
            convert(date, CloseDate)
        from
            cte_closed_r7d
    ),
    cte_closedays as
    (
        select 
            ClaimNo,
            CreatedBy,
            case
                when exists
                (
                    select 
                        null
                    from
                        #telebyday
                    where
                        CallDate = CreateDate and
                        AgentName = CreatedBy
                ) then 1
                else 0
            end TeleFlag,
            CreateDate,
            CloseDate,
            datediff(day, convert(date, CreateDate), CloseDate) ClosedDays,
            datediff(day, convert(date, CreateDate), CloseDate) - isnull(OffDays, 0) ClosedBusinessDays
        from
            cte_all t
            outer apply
            (
                select 
                    count([Date]) OffDays
                from
                    Calendar d
                where
                    d.[Date] >= convert(date, t.CreateDate) and
                    d.[Date] <  dateadd(day, 1, CloseDate) and
                    (
                        d.isHoliday = 1 or
                        d.isWeekEnd = 1
                    )
            ) ph
    )
    select
        d.[Date] CloseDate,
        TeleFlag,
        count(distinct ClaimNo) ClosedClaimCount,
        count(
            distinct
            case
                when ClosedBusinessDays <= 5 then ClaimNo
                else null
            end
        ) Closed1Week,
        count(
            distinct
            case
                when ClosedBusinessDays <= 10 then ClaimNo
                else null
            end
        ) Closed2Week
    from
        Calendar d
        left join cte_closedays t on
            t.CloseDate = d.[Date]
    where
        d.[Date] >= convert(date, dateadd(day, -7, getdate())) and
        d.[Date] <= convert(date, getdate()) and
        datepart(dw, d.[Date]) not in (1, 7) --exclude Sundays & Saturdays
    group by
        d.[Date],
        TeleFlag

end
GO
