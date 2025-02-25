USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0784]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0784]
    @Country varchar(10) = 'AU',
    @Period date

as
begin
    
    set nocount on

    declare
        --@Country varchar(10) = 'AU',
        --@Period date = '2016-05-01',
        @StartDate date,
        @EndDate date,
        @LYStartDate date,
        @LYEndDate date

    select 
        @StartDate = min(d.[Date]),
        @EndDate = max(d.[Date])
    from
        [db-au-cmdwh]..Calendar d
    where
        d.[Date] <  dateadd(month, 1, convert(varchar(8), @Period, 120) + '01') and
        d.[Date] >= dateadd(month, -12, convert(varchar(8), @Period, 120) + '01')

    select 
        @LYStartDate = dateadd(year, -1, @StartDate),
        @LYEndDate = dateadd(year, -1, @EndDate)

    --claim values at first nil
    if object_id('tempdb..#claimvalues') is not null
        drop table #claimvalues

    select 
        'At First Nil' Reference,
        convert(date, convert(varchar(8), cl.FirstNilDate, 120) + '01') [Month],
        'Current Year' Period,
        count(ClaimNo) ClaimCount,
        sum(Medical) Medical,
        sum(Luggage) Luggage,
        sum(Cancellation) Cancellation,
        sum(Other) Other,
        sum(case when MedicalCount > 0 then 1 else 0 end) MedicalCount,
        sum(case when LuggageCount > 0 then 1 else 0 end) LuggageCount,
        sum(case when CancellationCount > 0 then 1 else 0 end) CancellationCount,
        sum(case when OtherCount > 0 then 1 else 0 end) OtherCount
    into #claimvalues
    from
        [db-au-cmdwh]..clmClaim cl with(nolock)
        cross apply
        (
            select 
                sum(case when BenefitCategory like '%medic%' then 1 else 0 end * csi.PaymentDelta) Medical,
                sum(case when BenefitCategory like '%luggage%' then 1 else 0 end * csi.PaymentDelta) Luggage,
                sum(case when BenefitCategory like '%can%' then 1 else 0 end * csi.PaymentDelta) Cancellation,
                sum(
                    case 
                        when BenefitCategory like '%medic%' then 0 
                        when BenefitCategory like '%luggage%' then 0 
                        when BenefitCategory like '%can%' then 0 
                        else 1 
                    end * csi.PaymentDelta
                ) Other,
                count(case when BenefitCategory like '%medic%' and csi.IncurredDelta <> 0 then IncurredDate else null end) MedicalCount,
                count(case when BenefitCategory like '%luggage%' and csi.IncurredDelta <> 0 then IncurredDate else null end) LuggageCount,
                count(case when BenefitCategory like '%can%' and csi.IncurredDelta <> 0 then IncurredDate else null end) CancellationCount,
                count(
                    case 
                        when BenefitCategory like '%medic%' then null
                        when BenefitCategory like '%luggage%' then null 
                        when BenefitCategory like '%can%' then null 
                        when csi.IncurredDelta <> 0 then IncurredDate
                    end 
                ) OtherCount
            from
                [db-au-cmdwh]..clmSection cs with(nolock)
                inner join [db-au-cmdwh]..vclmBenefitCategory cb with(nolock) on
                    cb.BenefitSectionKey = cs.BenefitSectionKey
                inner join [db-au-cmdwh]..vclmClaimSectionIncurred csi with(nolock) on
                    csi.SectionKey = cs.SectionKey
            where
                cs.ClaimKey = cl.ClaimKey and
                csi.IncurredDate <= cl.FirstNilDate
        ) cb
    where
        cl.CountryKey = @Country and
        cl.FirstNilDate >= @StartDate and
        cl.FirstNilDate <  @EndDate
    group by
        convert(date, convert(varchar(8), cl.FirstNilDate, 120) + '01')

    insert into #claimvalues
    select 
        'At First Nil' Reference,
        dateadd(year, 1, convert(date, convert(varchar(8), cl.FirstNilDate, 120) + '01')) [Month],
        'Prior Year' Period,
        count(ClaimNo) ClaimCount,
        sum(Medical) Medical,
        sum(Luggage) Luggage,
        sum(Cancellation) Cancellation,
        sum(Other) Other,
        sum(case when MedicalCount > 0 then 1 else 0 end) MedicalCount,
        sum(case when LuggageCount > 0 then 1 else 0 end) LuggageCount,
        sum(case when CancellationCount > 0 then 1 else 0 end) CancellationCount,
        sum(case when OtherCount > 0 then 1 else 0 end) OtherCount
    from
        [db-au-cmdwh]..clmClaim cl with(nolock)
        cross apply
        (
            select 
                sum(case when BenefitCategory like '%medic%' then 1 else 0 end * csi.PaymentDelta) Medical,
                sum(case when BenefitCategory like '%luggage%' then 1 else 0 end * csi.PaymentDelta) Luggage,
                sum(case when BenefitCategory like '%can%' then 1 else 0 end * csi.PaymentDelta) Cancellation,
                sum(
                    case 
                        when BenefitCategory like '%medic%' then 0 
                        when BenefitCategory like '%luggage%' then 0 
                        when BenefitCategory like '%can%' then 0 
                        else 1 
                    end * csi.PaymentDelta
                ) Other,
                count(case when BenefitCategory like '%medic%' and csi.IncurredDelta <> 0 then IncurredDate else null end) MedicalCount,
                count(case when BenefitCategory like '%luggage%' and csi.IncurredDelta <> 0 then IncurredDate else null end) LuggageCount,
                count(case when BenefitCategory like '%can%' and csi.IncurredDelta <> 0 then IncurredDate else null end) CancellationCount,
                count(
                    case 
                        when BenefitCategory like '%medic%' then null
                        when BenefitCategory like '%luggage%' then null 
                        when BenefitCategory like '%can%' then null 
                        when csi.IncurredDelta <> 0 then IncurredDate
                    end 
                ) OtherCount
            from
                [db-au-cmdwh]..clmSection cs with(nolock)
                inner join [db-au-cmdwh]..vclmBenefitCategory cb with(nolock) on
                    cb.BenefitSectionKey = cs.BenefitSectionKey
                inner join [db-au-cmdwh]..vclmClaimSectionIncurred csi with(nolock) on
                    csi.SectionKey = cs.SectionKey
            where
                cs.ClaimKey = cl.ClaimKey and
                csi.IncurredDate <= cl.FirstNilDate
        ) cb
    where
        cl.CountryKey = @Country and
        cl.FirstNilDate >= @LYStartDate and
        cl.FirstNilDate <  @LYEndDate
    group by
        dateadd(year, 1, convert(date, convert(varchar(8), cl.FirstNilDate, 120) + '01'))

    insert into #claimvalues
    select 
        'At Closes' Reference,
        IncurredMonth,
        'Current Year' Period,
        count(ClaimNo) ClaimCount,
        sum(Medical) Medical,
        sum(Luggage) Luggage,
        sum(Cancellation) Cancellation,
        sum(Other) Other,
        sum(case when MedicalCount > 0 then 1 else 0 end) MedicalCount,
        sum(case when LuggageCount > 0 then 1 else 0 end) LuggageCount,
        sum(case when CancellationCount > 0 then 1 else 0 end) CancellationCount,
        sum(case when OtherCount > 0 then 1 else 0 end) OtherCount
    from
        [db-au-cmdwh]..clmClaim cl with(nolock)
        cross apply
        (
            select 
                convert(date, convert(varchar(8), ci.IncurredDate, 120) + '01') IncurredMonth,
                max(ci.IncurredDate) LastNilDate
            from
                [db-au-cmdwh]..[vclmClaimIncurred] ci with(nolock)
            where
                ci.ClaimKey = cl.ClaimKey and
                ci.Estimate = 0 and
                ci.IncurredDate >= @StartDate and
                ci.IncurredDate <  @EndDate
            group by
                convert(date, convert(varchar(8), ci.IncurredDate, 120) + '01')
        ) ci
        cross apply
        (
            select 
                sum(case when BenefitCategory like '%medic%' then 1 else 0 end * csi.PaymentDelta) Medical,
                sum(case when BenefitCategory like '%luggage%' then 1 else 0 end * csi.PaymentDelta) Luggage,
                sum(case when BenefitCategory like '%can%' then 1 else 0 end * csi.PaymentDelta) Cancellation,
                sum(
                    case 
                        when BenefitCategory like '%medic%' then 0 
                        when BenefitCategory like '%luggage%' then 0 
                        when BenefitCategory like '%can%' then 0 
                        else 1 
                    end * csi.PaymentDelta
                ) Other,
                count(case when BenefitCategory like '%medic%' and csi.IncurredDelta <> 0 then IncurredDate else null end) MedicalCount,
                count(case when BenefitCategory like '%luggage%' and csi.IncurredDelta <> 0 then IncurredDate else null end) LuggageCount,
                count(case when BenefitCategory like '%can%' and csi.IncurredDelta <> 0 then IncurredDate else null end) CancellationCount,
                count(
                    case 
                        when BenefitCategory like '%medic%' then null
                        when BenefitCategory like '%luggage%' then null 
                        when BenefitCategory like '%can%' then null 
                        when csi.IncurredDelta <> 0 then IncurredDate
                    end 
                ) OtherCount
            from
                [db-au-cmdwh]..clmSection cs with(nolock)
                inner join [db-au-cmdwh]..vclmBenefitCategory cb with(nolock) on
                    cb.BenefitSectionKey = cs.BenefitSectionKey
                inner join [db-au-cmdwh]..vclmClaimSectionIncurred csi with(nolock) on
                    csi.SectionKey = cs.SectionKey
            where
                cs.ClaimKey = cl.ClaimKey and
                csi.IncurredDate <= LastNilDate
        ) cb
    where
        cl.CountryKey = @Country
    group by
        IncurredMonth

    
    insert into #claimvalues
    select 
        'At Closes' Reference,
        dateadd(year, 1, IncurredMonth) IncurredMonth,
        'Prior Year' Period,
        count(ClaimNo) ClaimCount,
        sum(Medical) Medical,
        sum(Luggage) Luggage,
        sum(Cancellation) Cancellation,
        sum(Other) Other,
        sum(case when MedicalCount > 0 then 1 else 0 end) MedicalCount,
        sum(case when LuggageCount > 0 then 1 else 0 end) LuggageCount,
        sum(case when CancellationCount > 0 then 1 else 0 end) CancellationCount,
        sum(case when OtherCount > 0 then 1 else 0 end) OtherCount
    from
        [db-au-cmdwh]..clmClaim cl with(nolock)
        cross apply
        (
            select 
                convert(date, convert(varchar(8), ci.IncurredDate, 120) + '01') IncurredMonth,
                max(ci.IncurredDate) LastNilDate
            from
                [db-au-cmdwh]..[vclmClaimIncurred] ci with(nolock)
            where
                ci.ClaimKey = cl.ClaimKey and
                ci.Estimate = 0 and
                ci.IncurredDate >= @LYStartDate and
                ci.IncurredDate <  @LYEndDate
            group by
                convert(date, convert(varchar(8), ci.IncurredDate, 120) + '01')
        ) ci
        cross apply
        (
            select 
                sum(case when BenefitCategory like '%medic%' then 1 else 0 end * csi.PaymentDelta) Medical,
                sum(case when BenefitCategory like '%luggage%' then 1 else 0 end * csi.PaymentDelta) Luggage,
                sum(case when BenefitCategory like '%can%' then 1 else 0 end * csi.PaymentDelta) Cancellation,
                sum(
                    case 
                        when BenefitCategory like '%medic%' then 0 
                        when BenefitCategory like '%luggage%' then 0 
                        when BenefitCategory like '%can%' then 0 
                        else 1 
                    end * csi.PaymentDelta
                ) Other,
                count(case when BenefitCategory like '%medic%' and csi.IncurredDelta <> 0 then IncurredDate else null end) MedicalCount,
                count(case when BenefitCategory like '%luggage%' and csi.IncurredDelta <> 0 then IncurredDate else null end) LuggageCount,
                count(case when BenefitCategory like '%can%' and csi.IncurredDelta <> 0 then IncurredDate else null end) CancellationCount,
                count(
                    case 
                        when BenefitCategory like '%medic%' then null
                        when BenefitCategory like '%luggage%' then null 
                        when BenefitCategory like '%can%' then null 
                        when csi.IncurredDelta <> 0 then IncurredDate
                    end 
                ) OtherCount
            from
                [db-au-cmdwh]..clmSection cs with(nolock)
                inner join [db-au-cmdwh]..vclmBenefitCategory cb with(nolock) on
                    cb.BenefitSectionKey = cs.BenefitSectionKey
                inner join [db-au-cmdwh]..vclmClaimSectionIncurred csi with(nolock) on
                    csi.SectionKey = cs.SectionKey
            where
                cs.ClaimKey = cl.ClaimKey and
                csi.IncurredDate <= LastNilDate
        ) cb
    where
        cl.CountryKey = @Country
    group by
        IncurredMonth

    select 
        Reference,
        [Month],
        Period,
        ClaimCount,
        Medical,
        Luggage,
        Cancellation,
        Other,
        MedicalCount,
        LuggageCount,
        CancellationCount,
        OtherCount
    from
        #claimvalues

end
GO
