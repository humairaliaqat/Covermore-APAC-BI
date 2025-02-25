USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0788x]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0788x]
as
begin

    set nocount on

    if object_id('tempdb..#claims') is not null
        drop table #claims

    select
        ClaimKey,
        FirstNilMonth,
        Section,
        IncurredMonth,
        PreFirstNilFlag,
        sum(IncurredDelta) Incurred,
        sum(PreFirstNilPayment) PreFirstNilPayment,
        sum(IncurredAtEOM) EOMValue
    into #claims
    from
        (
            select --top 100 
                cl.ClaimKey,
                convert(date, convert(varchar(8), cl.FirstNilDate, 120) + '01') FirstNilMonth,
                cb.OperationalBenefitGroup Section,
                convert(date, convert(varchar(8), csi.IncurredDate, 120) + '01') IncurredMonth,
                case
                    when csi.PaymentDelta = 0 then null
                    when cl.FirstNilDate is null then cl.ClaimKey
                    when cl.FirstNilDate > convert(date, getdate()) then cl.ClaimKey
                    when csi.IncurredDate < dateadd(day, 1, convert(date, cl.FirstNilDate)) then cl.ClaimKey
                    else null
                end PreFirstNilFlag,
                csi.IncurredDelta,
                case
                    when cl.FirstNilDate is null then csi.PaymentDelta
                    when cl.FirstNilDate > convert(date, getdate()) then csi.PaymentDelta
                    when csi.IncurredDate < dateadd(day, 1, convert(date, cl.FirstNilDate)) then csi.PaymentDelta
                    else 0
                end PreFirstNilPayment,
                case
                    when IncurredTime = max(IncurredTime) over (partition by csi.SectionKey, convert(varchar(7), IncurredTime, 120)) then csi.IncurredValue
                    else 0
                end IncurredAtEOM
            from
                [db-au-cmdwh]..clmClaim cl with(nolock)
                inner join [db-au-cmdwh]..vclmClaimSectionIncurredIntraDay csi with(nolock) on
                    csi.ClaimKey = cl.ClaimKey
                left join [db-au-cmdwh]..clmSection cs with(nolock) on
                    cs.SectionKey = csi.SectionKey
                left join [db-au-cmdwh]..vclmBenefitCategory cb with(nolock) on
                    cb.BenefitSectionKey = cs.BenefitSectionKey
            where
                cl.CountryKey = 'AU' and
                csi.IncurredDate between '2014-07-01' and '2017-06-30' 
        ) t
    group by
        ClaimKey,
        FirstNilMonth,
        Section,
        IncurredMonth,
        PreFirstNilFlag

--select 
--    sum(Incurred),
--    sum(PreFirstNilPayment),
--    count(distinct PreFirstNilFlag)
--from
--    #claims
--where
--    IncurredMonth = '2016-07-01'


    if object_id('tempdb..#claimflag') is not null
        drop table #claimflag

    select
        ClaimKey,
        IncurredMonth,
        case
            when PreFirstNilFlag is not null then 1
            else 0
        end FirstClosedFlag,
        case
            when isnull(New, 0) = 0 then 0
            else 1
        end NewFlag,
        case
            when isnull(Reopened, 0) = 0 then 0
            else 1
        end ReopenFlag
    into #claimflag
    from
        (
            select
                ClaimKey,
                IncurredMonth,
                max(PreFirstNilFlag) PreFirstNilFlag
            from
                #claims
            group by
                ClaimKey,
                IncurredMonth
        ) t
        outer apply
        (
            select 
                sum(cii.NewCount) New,
                sum(cii.ReopenedCount) Reopened
            from
                [db-au-cmdwh]..vclmClaimIncurredIntraDay cii
            where
                cii.ClaimKey = t.ClaimKey and
                cii.IncurredTime >= t.IncurredMonth and
                cii.IncurredTime <  dateadd(month, 1, t.IncurredMonth)
        ) cro

    if object_id('tempdb..#claimsummary') is not null
        drop table #claimsummary

    select 
        t.IncurredMonth,
        Section,
        cc.Classification,
        sum(Incurred) ClaimValue,
        sum(PreFirstNilPayment) ValueAtFirstNil,
        count(distinct PreFirstNilFlag) CountAtFirstNil,
        count
        (
            distinct
            case
                when FirstNilMonth = t.IncurredMonth then t.ClaimKey
                else null
            end 
        ) FirstClosedCount,
        count
        (
            distinct
            case
                when cf.ReopenFlag = 0 then null
                else t.ClaimKey
            end 
        ) ReopenedCount,
        count
        (
            distinct
            case
                when cf.NewFlag = 0 then null
                else t.ClaimKey
            end 
        ) NewCount,
        count(distinct t.ClaimKey) SectionCount
    into #claimsummary
    from
        #claims t
        inner join #claimflag cf on
            cf.ClaimKey = t.ClaimKey and
            cf.IncurredMonth = t.IncurredMonth
        outer apply
        (
            select top 1 
                p.AreaType
            from
                [db-au-cmdwh]..clmClaim cl with(nolock)
                inner join [db-au-cmdwh]..penPolicyTransSummary pt with(nolock) on
                    pt.PolicyTransactionKey = cl.PolicyTransactionKey
                inner join [db-au-cmdwh]..penPolicy p on
                    p.PolicyKey = pt.PolicyKey
            where
                cl.ClaimKey = t.ClaimKey
        ) p
        outer apply
        (
            select top 1 
                ce.CatastropheCode
            from
                [db-au-cmdwh]..clmEvent ce with(nolock)
            where
                ce.ClaimKey = t.ClaimKey and
                ce.CatastropheCode not in ('CC', 'REC')
        ) ce
        outer apply
        (
            select
                case
                    when isnull(p.AreaType, '') = 'Domestic' then 'Domestic'
                    when isnull(CatastropheCode, '') <> '' then 'CAT'
                    when EOMValue >= 25000 then 'Major'
                    else 'Minor'
                end Classification
        ) cc
    group by
        t.IncurredMonth,
        Section,
        Classification

    if object_id('tempdb..#opex') is not null
        drop table #opex

    select 
        dd.[Date] [Month],
        sum(-GLAmount) OpEx
    into #opex
    from
        [db-au-cmdwh]..glTransactions gl with(nolock)
        inner join [db-au-cmdwh]..glDepartments d with(nolock) on
            d.DepartmentCode = gl.DepartmentCode
        inner join [db-au-cmdwh]..Calendar dd with(nolock) on
            dd.SUNPeriod = gl.Period and
            datepart(day, dd.[Date]) = 1
    where
        gl.ScenarioCode = 'A' and
        gl.BusinessUnit = 'IAU' and
        gl.Period between 2014001 and 2017013 and
        gl.AccountCode in 
        (
            select 
                Descendant_Code
            from
                [db-au-star]..vAccountAncestors aa
            where
                aa.Account_Code = 'TC'
        ) and
        d.DepartmentDescription = 'Claims'
    group by
        dd.Date

    if object_id('tempdb..#policy') is not null
        drop table #policy

    select 
        d.[Date] [Month],
        isnull(pc.PolicyCount, 0) PolicyCount,
        isnull(pp.Premium, 0) Premium
    into #policy
    from
        [db-au-cmdwh]..Calendar d
        outer apply
        (
            select 
                sum(pt.BasePolicyCount) PolicyCount
            from
                [db-au-cmdwh]..penPolicyTransSummary pt with(nolock)
            where
                pt.OutletAlphaKey like 'AU%' and
                pt.PostingDate >= dateadd(month, -4, d.[Date]) and
                pt.PostingDate <  dateadd(month, -3, d.[Date])
        ) pc
        outer apply
        (
            select 
                sum(pt.GrossPremium - pt.TaxAmountGST - pt.TaxAmountSD) Premium
            from
                [db-au-cmdwh]..penPolicyTransSummary pt with(nolock)
            where
                pt.OutletAlphaKey like 'AU%' and
                pt.PostingDate >= d.[Date] and
                pt.PostingDate <  dateadd(month, 1, d.[Date])
        ) pp
    where
        datepart(day, d.[Date]) = 1 and
        d.[Date] between '2014-07-01' and '2017-06-30'


    --select *
    --from    
    --    #claimsummary

    --select *
    --from    
    --    #opex

    --select *
    --from    
    --    #policy

    --drop table [db-au-workspace]..tmp_cd

    select 
        d.[Date] [Month],
        cc.FirstClosedCount,
        cc.NewCount,
        cc.ReopenCount,
        ox.OpEx,
        p.PolicyCount,
        p.Premium,
        cs.Section,
        cs.Classification,
        cs.ClaimValue SectionValue,
        cs.ValueAtFirstNil SectionValueAtFirstClosed,
        cs.CountAtFirstNil SectionCountAtFirstClosed,
        cs.FirstClosedCount SectionFirstClosedCount,
        cs.ReopenedCount SectionReopenedCount,
        cs.NewCount SectionNewCount,
        cs.SectionCount
    --into [db-au-workspace]..tmp_cd
    from
        [db-au-cmdwh]..Calendar d
        outer apply
        (
            select 
                sum(cf.FirstClosedFlag) FirstClosedCount,
                sum(cf.NewFlag) NewCount,
                sum(cf.ReopenFlag) ReopenCount
            from
                #claimflag cf
            where
                cf.IncurredMonth = d.[Date]
        ) cc
        left join #opex ox on
            ox.[Month] = d.[Date]
        left join #policy p on
            p.[Month] = d.[Date]
        left join #claimsummary cs on
            cs.IncurredMonth = d.[Date]
    where
        datepart(day, d.[Date]) = 1 and
        d.[Date] between '2014-07-01' and '2017-06-30'
    

end
GO
