USE [db-au-star]
GO
/****** Object:  View [dbo].[v_ic_factPolicyTransaction]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE view [dbo].[v_ic_factPolicyTransaction]
as
--leisure
select --top 100 
    pt.BIRowID,

    pt.AgeBandSK,
    pt.AreaSK,
    pt.ConsultantSK,
    
    pt.DateSK,
    pt.DestinationSK,
    pt.DomainSK,
    pt.DurationSK,
    pt.LeadTime LeadTimeSK,
    pt.OutletSK,

    pt.PolicySK,

    pt.ProductSK,
    pt.PromotionSK,
    ref.OutletReference,
    pt.TransactionTypeStatusSK,


    --20190415, LL
    --ETL/business rule issue, when trip dates changed, will the transactions be atributed to current trip dates or recorded trip dates
    --this is pointing to current trip dates
    --pt.DepartureDateSK,
    --pt.ReturnDateSK,
    case
        when p.DepartureDateSK < '2001-01-01' then '2001-01-01'
        when p.DepartureDateSK > convert(varchar(10), convert(varchar(4), year(getdate()) + 4) + '-12-31') then convert(varchar(10), convert(varchar(4), year(getdate()) + 4) + '-12-31')
        else p.DepartureDateSK
    end DepartureDateSK,
    case
        when p.ReturnDateSK < '2001-01-01' then '2001-01-01'
        when p.ReturnDateSK > convert(varchar(10), convert(varchar(4), year(getdate()) + 4) + '-12-31') then convert(varchar(10), convert(varchar(4), year(getdate()) + 4) + '-12-31')
        else p.ReturnDateSK
    end ReturnDateSK,
    
    --20190415, LL
    --ETL issue, IssueDateSK can be null
    --not all data have been fixed, this is a workaround
    --pt.IssueDateSK,
    p.IssueDateSK,

    pt.UnderwriterCode,

    pt.isExpo,
    pt.isPriceBeat,
    pt.isAgentSpecial,

    pt.RiskNet,
    pt.Premium,
    pt.BookPremium,
    pt.SellPrice,
    pt.NetPrice,
    pt.PremiumSD,
    pt.PremiumGST,
    pt.Commission,
    pt.CommissionSD,
    pt.CommissionGST,
    pt.PremiumDiscount,
    pt.AdminFee,
    pt.AgentPremium,
    pt.UnadjustedSellPrice,
    pt.UnadjustedNetPrice,
    pt.UnadjustedCommission,
    pt.UnadjustedAdminFee,

    pt.Premium * isnull(fx.FXRate, 0) AUD_Premium,
    pt.SellPrice * isnull(fx.FXRate, 0) AUD_SellPrice,
    (pt.Commission + pt.AdminFee) * isnull(fx.FXRate, 0) AUD_Commission,

    pt.PolicyCount,
    pt.ExtensionPolicyCount,
    pt.CancelledPolicyCount,
    pt.CANXPolicyCount,
    pt.DomesticPolicyCount,
    pt.InternationalPolicyCount,
    pt.InboundPolicyCount,
    
    pt.TravellersCount,
    pt.AdultsCount,
    pt.ChildrenCount,
    pt.ChargedAdultsCount,
    pt.DomesticTravellersCount,
    pt.DomesticAdultsCount,
    pt.DomesticChildrenCount,
    pt.DomesticChargedAdultsCount,
    pt.InboundTravellersCount,
    pt.InboundAdultsCount,
    pt.InboundChildrenCount,
    pt.InboundChargedAdultsCount,
    pt.InternationalTravellersCount,
    pt.InternationalAdultsCount,
    pt.InternationalChildrenCount,
    pt.InternationalChargedAdultsCount,

    pt.LeadTime,
    pt.Duration,
    pt.CancellationCover

from
    dbo.factPolicyTransaction pt
    cross apply
    (
        select 
            convert(date, p.TripStart) DepartureDateSK,
            convert(date, p.TripEnd) ReturnDateSK,
            convert(date, p.IssueDate) IssueDateSK
        from
            dbo.dimPolicy dp
            inner join [db-au-cmdwh].dbo.penPolicy p on
                p.PolicyKey = dp.PolicyKey
        where
            dp.PolicySK = pt.PolicySK 
    ) p
    cross apply
    (
        select
            min(t.DateSK) DateSK
        from
            (
                select pt.DateSK

                union

                select
                    dd.Date_SK
                from
                    Dim_Date dd
                where
                    dd.[Date] = dateadd(day, -1, convert(date, getdate()))
            ) t
    ) d
    outer apply
    (
        select top 1 
            fx.FXRate
        from
            dimDomainFX fx
        where
            fx.DomainSK = pt.DomainSK and
            fx.DateSK = d.DateSK and
            fx.FXCurrency = 'AUD'
    ) fx
    cross apply
    (
        select 'Point in time' OutletReference
        union all
        select 'Latest alpha' OutletReference
    ) ref
where
    pt.DateSK >= 20150101
--        PolicySK in 
--        (

-- select policysk
--        from
--            dimPolicy
--        where
--            PolicyNumber in(
--'716000084032',
--'716000479416',
--'716000580122',
--'716000585792',
--'716000594891'


--            ) union

--            select top 20 
--    t.PolicySK
--    --,
--    --count(distinct AddonGroup)
--from
--    factPolicyTransactionAddons t
--    inner join dimPolicy p on
--        p.PolicySK = t.PolicySK
--where
--    p.PolicyStatus = 'Active'
--group by
--    t.PolicySK
--order by count(distinct AddonGroup) desc
--        )

--    DateSK >= 20180101 and
--    DateSK <  20180201


union all

--corporate
select --top 100 
    pt.BIRowID,

    -1 AgeBandSK,
    -1 AreaSK,
    -1 ConsultantSK,
    
    pt.DateSK,
    -1 DestinationSK,
    pt.DomainSK,
    pt.DurationSK,
    r.LeadTime LeadTimeSK,
    pt.OutletSK,

    pt.BIRowID * -10 PolicySK,

    (
        select top 1 
            r.ProductSK--, *
        from
            dimProduct r
            inner join dimDomain rd on
                rd.CountryCode = r.Country
        where
            r.ProductCode = 'CMC' and
            rd.DomainSK = pt.DomainSK
        --20190503, LL, corporate product tiers
        order by
            case
                when r.ProductKey like '%' + replace(pt.Tier, ' ', '') then 0
                else 1
            end
    ) ProductSK,
    -1 PromotionSK,
    ref.OutletReference,
    -1 TransactionTypeStatusSK,

    pt.DepartureDateSK,
    pt.ReturnDateSK,
    pt.IssueDateSK,
    pt.UnderwriterCode,

    'N' isExpo,
    'N' isPriceBeat,
    'N' isAgentSpecial,

    pt.Premium RiskNet,
    pt.Premium,
    pt.Premium BookPremium,
    pt.SellPrice,
    pt.SellPrice - pt.Commission NetPrice,
    pt.PremiumSD,
    pt.PremiumGST,
    pt.Commission,
    case
        when pt.Premium = 0 then 0
        else pt.PremiumSD / pt.Premium * pt.Commission
    end CommissionSD,
    pt.CommissionGST,
    0 PremiumDiscount,
    0 AdminFee,
    0 AgentPremium,
    pt.SellPrice UnadjustedSellPrice,
    pt.SellPrice - pt.Commission UnadjustedNetPrice,
    pt.Commission UnadjustedCommission,
    0 UnadjustedAdminFee,

    pt.Premium * isnull(fx.FXRate, 0) AUD_Premium,
    pt.SellPrice * isnull(fx.FXRate, 0) AUD_SellPrice,
    pt.Commission * isnull(fx.FXRate, 0) AUD_Commission,

    pt.PolicyCount,
    0 ExtensionPolicyCount,
    0 CancelledPolicyCount,
    0 CANXPolicyCount,
    0 DomesticPolicyCount,
    pt.PolicyCount InternationalPolicyCount,
    0 InboundPolicyCount,
    
    0 TravellersCount,
    0 AdultsCount,
    0 ChildrenCount,
    0 ChargedAdultsCount,
    0 DomesticTravellersCount,
    0 DomesticAdultsCount,
    0 DomesticChildrenCount,
    0 DomesticChargedAdultsCount,
    0 InboundTravellersCount,
    0 InboundAdultsCount,
    0 InboundChildrenCount,
    0 InboundChargedAdultsCount,
    0 InternationalTravellersCount,
    0 InternationalAdultsCount,
    0 InternationalChildrenCount,
    0 InternationalChargedAdultsCount,

    r.LeadTime,
    r.Duration,
    0 CancellationCover

from
    dbo.v_ic_Corporate pt
    cross apply
    (
        select
            min(t.DateSK) DateSK
        from
            (
                select pt.DateSK

                union

                select
                    dd.Date_SK
                from
                    Dim_Date dd
                where
                    dd.[Date] = dateadd(day, -1, convert(date, getdate()))
            ) t
    ) d
    outer apply
    (
        select top 1 
            fx.FXRate
        from
            dimDomainFX fx
        where
            fx.DomainSK = pt.DomainSK and
            fx.DateSK = d.DateSK and
            fx.FXCurrency = 'AUD'
    ) fx
    cross apply
    (
        select 
            datediff(day, pt.PolicyStartDate, pt.PolicyExpiryDate) + 1 Duration,
            case
                when datediff([day], pt.IssueDate, pt.PolicyStartDate) < -1 then -1
                when datediff([day], pt.IssueDate, pt.PolicyStartDate) > 2000 then -1
                else isnull(datediff(day, pt.IssueDate, pt.PolicyStartDate), -1)
            end LeadTime

    ) r
    cross apply
    (
        select 'Point in time' OutletReference
        union all
        select 'Latest alpha' OutletReference
    ) ref
where
    pt.DateSK >= 20150101
--    DateSK <  20180201

















GO
