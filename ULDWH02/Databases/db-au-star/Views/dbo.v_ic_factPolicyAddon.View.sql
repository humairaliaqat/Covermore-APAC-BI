USE [db-au-star]
GO
/****** Object:  View [dbo].[v_ic_factPolicyAddon]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[v_ic_factPolicyAddon]
as
with cte_addon as
(
    select 
        DateSK,
        DomainSK,
        OutletSK,
        PolicySK,
        ConsultantSK,
        AreaSK,
        DestinationSK,
        DurationSK,
        ProductSK,
        AgeBandSK,
        PromotionSK ,
        LeadTime,
        UnderwriterCode,

        --20190415, LL
        --ETL/business rule issue, when trip dates changed, will the transactions be atributed to current trip dates or recorded trip dates
        --this is pointing to current trip dates
        --DepartureDateSK,
        --ReturnDateSK,
        p.DepartureDateSK,
        p.ReturnDateSK,
    
        --20190415, LL
        --ETL issue, IssueDateSK can be null
        --not all data have been fixed, this is a workaround
        --IssueDateSK,
        p.IssueDateSK,

        AddonGroup,
        sum(AddonCount) AddonCount,
        sum(SellPrice) SellPrice,
        sum(UnadjustedSellPrice) UnadjustedSellPrice
    from
        [db-au-star]..factPolicyTransactionAddons t with(nolock)
        cross apply
        (
            select 
                (
                    select
                        r.DateSK
                    from
                        [db-au-star]..v_ic_dimGeneralDate r
                    where
                        r.DateSK = convert(date, p.TripStart)
                ) DepartureDateSK,
                (
                    select
                        r.DateSK
                    from
                        [db-au-star]..v_ic_dimGeneralDate r
                    where
                        r.DateSK = convert(date, p.TripEnd)
                ) ReturnDateSK,
                (
                    select
                        r.DateSK
                    from
                        [db-au-star]..v_ic_dimGeneralDate r
                    where
                        r.DateSK = convert(date, p.IssueDate)
                ) IssueDateSK
            from
                dbo.dimPolicy dp
                inner join [db-au-cmdwh].dbo.penPolicy p on
                    p.PolicyKey = dp.PolicyKey
            where
                dp.PolicySK = t.PolicySK
        ) p
    where
        t.DateSK >= 20150101

--    where
--        PolicySK in 
--        (

--        select policysk
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
    group by
        DateSK,
        DomainSK,
        OutletSK,
        PolicySK,
        ConsultantSK,
        AreaSK,
        DestinationSK,
        DurationSK,
        ProductSK,
        AgeBandSK,
        PromotionSK ,
        LeadTime,
        UnderwriterCode,
        p.DepartureDateSK,
        p.ReturnDateSK,
        p.IssueDateSK,
        AddonGroup
),
cte_union as
(
select
    f.DateSK,
    f.DomainSK,
    f.OutletSK,
    f.PolicySK,
    f.ConsultantSK,
    f.AreaSK,
    f.DestinationSK,
    f.DurationSK,
    isnull(f.ProductSK, -1) ProductSK,
    f.AgeBandSK,
    f.PromotionSK,
    f.LeadTime,
    f.UnderwriterCode,
    f.DepartureDateSK,
    f.ReturnDateSK,
    f.IssueDateSK,
    f.AddonGroup,
    case
        when f.AddonGroup = 'No Addon' then 0
        when f.AddonCount >= 1 then 1
        when f.AddonCount <= -1 then -1
        else 0
    end AddonCount,
    f.SellPrice,
    f.UnadjustedSellPrice,
    f.SellPrice * isnull(fx.FXRate, 0) AUD_SellPrice,
    ref.OutletReference
from
    cte_addon f
    cross apply
    (
        select
            min(t.DateSK) DateSK
        from
            (
                select f.DateSK

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
            fx.DomainSK = f.DomainSK and
            fx.DateSK = d.DateSK and
            fx.FXCurrency = 'AUD'
    ) fx
    cross apply
    (
        select 'Point in time' OutletReference
        union all
        select 'Latest alpha' OutletReference
    ) ref

--union all

--select --top 100 
--    pt.DateSK,
--    pt.DomainSK,
--    pt.OutletSK,
--    pt.BIRowID * -10 PolicySK,
--    -1 ConsultantSK,
--    -1 AreaSK,
--    -1 DestinationSK,
--    pt.DurationSK,
--    isnull(pt.ProductSK, -1) ProductSK,
--    -1 AgeBandSK,
--    -1 PromotionSK,
--    r.LeadTime LeadTimeSK,
--    pt.UnderwriterCode,
--    pt.DepartureDateSK,
--    pt.ReturnDateSK,
--    pt.IssueDateSK,
--    'No Addon' AddonGroup,
--    0 AddonCount,
--    0 SellPrice,
--    0 UnadjustedSellPrice,
--    0 AUD_SellPrice,
--    ref.OutletReference
--from
--    dbo.v_ic_Corporate pt
--    cross apply
--    (
--        select 
--            datediff(day, pt.PolicyStartDate, pt.PolicyExpiryDate) + 1 Duration,
--            case
--                when datediff([day], pt.IssueDate, pt.PolicyStartDate) < -1 then -1
--                when datediff([day], pt.IssueDate, pt.PolicyStartDate) > 2000 then -1
--                else isnull(datediff(day, pt.IssueDate, pt.PolicyStartDate), -1)
--            end LeadTime

--    ) r
--    cross apply
--    (
--        select 'Point in time' OutletReference
--        union all
--        select 'Latest alpha' OutletReference
--    ) ref
--where
--    DateSK >= 20180101 and
--    DateSK <  20180201


)
select *
from
    cte_union t
where
    exists
    (
        select 
            null
        from
            v_ic_dimPolicy r
        where
            r.PolicySK = t.PolicySK
    )






GO
