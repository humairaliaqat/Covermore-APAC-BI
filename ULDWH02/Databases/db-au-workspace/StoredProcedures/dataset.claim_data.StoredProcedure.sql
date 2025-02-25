USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dataset].[claim_data]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dataset].[claim_data]
as
begin

    set nocount on

    if object_id('tempdb..#dates') is not null
        drop table #dates

    select 
        d.[Date]
    into #dates
    from
        [db-au-cmdwh].[dbo].[Calendar] d
    where
        year(d.[Date]) >= year(dateadd(day, -1, getdate())) - 3 and
        year(d.[Date]) <= year(dateadd(day, -1, getdate()))
    
    if object_id('tempdb..#incurred') is not null
        drop table #incurred

    select 
        ci.IncurredDate,
        b.Bucket,
        cg.ClaimGroup,
        cb.OperationalBenefitGroup Benefit,
        sum(ci.IncurredDelta) ClaimCost,
        sum(ci.EstimateDelta) ClaimEstimate,
        sum(ci.PaymentDelta) ClaimPayment
    into #incurred
    from
        [db-au-cmdwh].[dbo].[clmClaim] cl with(nolock)
        inner join [db-au-cmdwh].[dbo].[penOutlet] o with(nolock) on
            o.OutletKey = cl.OutletKey and
            o.OutletStatus = 'Current'
        cross apply
        (
            select
                case
                    when o.SuperGroupName = 'CBA Group' then 'CBA'
                    else 'Non CBA'
                end ClaimGroup
        ) cg
        inner join [db-au-cmdwh].[dbo].[vclmClaimSectionIncurred] ci with(nolock) on
            ci.Claimkey = cl.ClaimKey
        left join [db-au-cmdwh].[dbo].[clmSection] cs with(nolock) on
            cs.SectionKey = ci.SectionKey 
        left join [db-au-cmdwh].[dbo].[vclmBenefitCategory] cb with(nolock) on
            cb.BenefitSectionKey = cs.BenefitSectionKey
        outer apply
        (
            select top 1
                1 isCAT
            from
                [db-au-cmdwh].[dbo].clmEvent ce with(nolock)
                inner join [db-au-cmdwh].[dbo].clmCatastrophe cc with(nolock) on
                    cc.CountryKey = ce.CountryKey and
                    cc.CatastropheCode = ce.CatastropheCode
            where
                ce.ClaimKey = cl.ClaimKey and
                isnull(ce.CatastropheCode, '') not in ('', 'CC', 'REC')
        ) ce
        cross apply
        (
            select
                case
                    when ce.isCAT = 1 then 'CAT'
                    when
                        exists
                        (
                            select 
                                null
                            from
                                [db-au-cmdwh].[dbo].[vclmClaimIncurred] icd with(nolock)
                            where
                                icd.ClaimKey = cl.ClaimKey and
                                icd.IncurredValue > 25000
                        ) then 'Large'
                        else 'Underlying'
                end Bucket
        ) b
    where
        o.CountryKey = 'AU' and
        ci.IncurredDate in
        (
            select 
                [Date]
            from
                #dates
        )
    group by
        ci.IncurredDate,
        cg.ClaimGroup,
        cb.OperationalBenefitGroup,
        b.Bucket

    if object_id('tempdb..#volume') is not null
        drop table #volume

    select 
        convert(date, cl.CreateDate) RegisterDate,
        b.Bucket,
        cg.ClaimGroup,
        count(cl.ClaimKey) ClaimCount
    into #volume
    from
        [db-au-cmdwh].[dbo].[clmClaim] cl with(nolock)
        outer apply
        (
            select top 1
                1 isCAT
            from
                [db-au-cmdwh].[dbo].clmEvent ce with(nolock)
                inner join [db-au-cmdwh].[dbo].clmCatastrophe cc with(nolock) on
                    cc.CountryKey = ce.CountryKey and
                    cc.CatastropheCode = ce.CatastropheCode
            where
                ce.ClaimKey = cl.ClaimKey and
                isnull(ce.CatastropheCode, '') not in ('', 'CC', 'REC')
        ) ce
        cross apply
        (
            select
                case
                    when ce.isCAT = 1 then 'CAT'
                    when
                        exists
                        (
                            select 
                                null
                            from
                                [db-au-cmdwh].[dbo].[vclmClaimIncurred] icd with(nolock)
                            where
                                icd.ClaimKey = cl.ClaimKey and
                                icd.IncurredValue > 25000
                        ) then 'Large'
                        else 'Underlying'
                end Bucket
        ) b
        inner join [db-au-cmdwh].[dbo].[penOutlet] o with(nolock) on
            o.OutletKey = cl.OutletKey and
            o.OutletStatus = 'Current'
        cross apply
        (
            select
                case
                    when o.SuperGroupName = 'CBA Group' then 'CBA'
                    else 'Non CBA'
                end ClaimGroup
        ) cg
    where
        o.CountryKey = 'AU' and
        convert(date, cl.CreateDate) in
        (
            select 
                [Date]
            from
                #dates
        )
    group by
        convert(date, cl.CreateDate),
        b.Bucket,
        cg.ClaimGroup

    if object_id('[db-au-workspace].[dataset].[claim_au_incurred]') is not null
        drop table [db-au-workspace].[dataset].[claim_au_incurred]

    select 
        case
            when convert(varchar(7), d.[Date], 120) = convert(varchar(7), dateadd(day, -1, getdate()), 120) then 'Yes'
            else 'No'
        end CurrentMonthFlag,
        convert(date, convert(varchar(8), d.[Date], 120) + '01') MonthPeriod,
        d.[Date],
        g.[ClaimGroup],
        b.Bucket,
        cb.benefit,
        cyi.*,
        pyi.*,
        cyv.*,
        pyv.*
    into [db-au-workspace].[dataset].[claim_au_incurred]
    from
        #dates d
        cross apply
        (
            select 'CBA' ClaimGroup
            union 
            select 'Non CBA' ClaimGroup
        ) g
        cross apply
        (
            select 'Underlying' Bucket
            union
            select 'Large' Bucket
            union
            select 'CAT' Bucket
        ) b
        cross apply
        (
            select 'Luggage' Benefit
            union
            select 'Cancellation' Benefit
            union
            select 'Medical' Benefit
            union
            select 'Other' Benefit
        ) cb
        cross apply
        (
            select 
                sum(i.ClaimCost) ClaimCostCY,
                sum(i.ClaimEstimate) ClaimEstimateCY,
                sum(i.ClaimPayment) ClaimPaymentCY
            from
                #incurred i
            where
                i.IncurredDate = d.Date and
                i.ClaimGroup = g.ClaimGroup and
                i.Bucket = b.Bucket and
                i.Benefit = cb.Benefit
            group by
                Bucket
        ) cyi
        cross apply
        (
            select 
                sum(i.ClaimCost) ClaimCostPY,
                sum(i.ClaimEstimate) ClaimEstimatePY,
                sum(i.ClaimPayment) ClaimPaymentPY
            from
                #incurred i
            where
                dateadd(year, 1, i.IncurredDate) = d.Date and
                i.ClaimGroup = g.ClaimGroup and
                i.Bucket = b.Bucket and
                i.Benefit = cb.Benefit
        ) pyi
        cross apply
        (
            select 
                sum(v.ClaimCount) ClaimVolumeCY
            from
                #volume v
            where
                v.RegisterDate = d.Date and
                v.ClaimGroup = g.ClaimGroup and
                v.Bucket = b.Bucket and
                cb.Benefit = 'Other'
        ) cyv
        cross apply
        (
            select 
                sum(v.ClaimCount) ClaimVolumePY
            from
                #volume v
            where
                dateadd(year, 1, v.RegisterDate) = d.Date and
                v.ClaimGroup = g.ClaimGroup and
                v.Bucket = b.Bucket and
                cb.Benefit = 'Other'
        ) pyv

    if object_id('[db-au-workspace].[dataset].[claim_au_tat]') is not null
        drop table [db-au-workspace].[dataset].[claim_au_tat]

    select 
        ClaimKey,
        Status,
        case
            when [Absolute Age] < 60 then '0 - 59'
            when [Absolute Age] < 90 then '> 60 days'
            when [Absolute Age] < 180 then '> 90 days'
            when [Absolute Age] < 360 then '> 180 days'
            when [Absolute Age] < 500 then '> 360 days'
            else '> 500 days'
        end [Age Bracket],
        case
            when [Absolute Age] < 60 then 0
            when [Absolute Age] < 90 then 60
            when [Absolute Age] < 180 then 90
            when [Absolute Age] < 360 then 180
            when [Absolute Age] < 500 then 360
            else 500
        end [Age Sorter],
        case
            when [Time in current status] >= 10 then 10
            else [Time in current status]
        end TAT
    into [db-au-workspace].[dataset].[claim_au_tat]
    from
        [db-au-cmdwh].[dbo].[vClaimPortfolio] with(nolock)
    where
        Country = 'AU' and
        Status <> 'Complete' and
        [Work Type] = 'Claim'

    alter table [db-au-workspace].[dataset].[claim_au_tat] add LastStatusName varchar(max)

    update t
    set
        t.LastStatusName = r.StatusName
    from
        [db-au-workspace].[dataset].[claim_au_tat] t
        outer apply
        (
            select top 1 
                we.StatusName
            from
                [db-au-cmdwh].[dbo].e5Work w with(nolock)
                cross apply
                (
                    select top 1
                        we.StatusName
                    from
                        [db-au-cmdwh].[dbo].e5WorkEvent we with(nolock)
                    where
                        we.Work_ID = w.Work_ID and
                        we.EventName in ('Changed Work Status', 'Merged Work', 'Saved Work')
                    order by
                        we.EventDate desc
                ) we
            where
                w.ClaimKey = t.ClaimKey and
                w.WorkType = 'Claim'
        ) r

	if object_id('[db-au-workspace].[dataset].[claim_au_poldet]') is not null
		drop table [db-au-workspace].[dataset].[claim_au_poldet]

    select 
        d.[Date]
    into #month
    from
        [db-au-cmdwh].[dbo].[Calendar] d
		inner join [db-au-cmdwh].[dbo].[vDateRange] r on d.[date] between r.StartDate and r.EndDate
    where r.DateRange = 'Month-to-date'

	select m.date, cl.CreateDate, cl.ClaimNo, icd.ClaimValue, o.SuperGroupName as AgencySuperGroupName, X.GrossPremium, row_number() over(order by icd.ClaimValue desc) as rnk
	into #claim_au_poldet
	from 
        [db-au-cmdwh].[dbo].[clmClaim] cl with(nolock)
	inner join [db-au-cmdwh].[dbo].[penOutlet] o with(nolock) on
            o.OutletKey = cl.OutletKey and
            o.OutletStatus = 'Current'
	outer apply (
		select sum(IncurredValue) ClaimValue
		from [db-au-cmdwh].[dbo].[vclmClaimIncurred] icd with(nolock) 
		where icd.ClaimKey = cl.ClaimKey
	) icd
	join #month m on CAST(cl.CreateDate as date) = m.Date
	outer apply (
		select SUM(pts2.GrossPremium) as GrossPremium
		from [db-au-cmdwh].dbo.penPolicyTransSummary pts
		join [db-au-cmdwh].dbo.penPolicyTransSummary pts2 on pts.PolicyKey = pts2.Policykey
		where pts.PolicyTransactionKey = cl.PolicyTransactionKey
		) X
	where o.CountryKey = 'AU'

	select *
	into [db-au-workspace].[dataset].[claim_au_poldet]
	from #claim_au_poldet
	where rnk <= 50
end
GO
