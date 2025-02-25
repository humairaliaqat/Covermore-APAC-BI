USE [db-au-star]
GO
/****** Object:  View [dbo].[v_ic_factTarget]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[v_ic_factTarget]
as
with cte_targets
as
(
    select 
        pt.DateSK,
        pt.DomainSK,
        pt.OutletSK,
        pt.ProductSK,
        pt.BudgetAmount SellPriceTarget,
        pt.BudgetAmount * 0 PremiumBudget,
        pt.BudgetAmount * 0 PolicyCountBudget,
        pt.BudgetAmount * isnull(fx.FXRate, 0) AUD_SellPriceTarget,
        pt.BudgetAmount * 0 AUD_PremiumBudget
    from
        factPolicyTarget pt with(nolock)
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
    where
        pt.DateSK >= 20180101

    union all

    select 
        pt.DateSK,
        pt.DomainSK,
        pt.OutletSK,
        pt.ProductSK,
        0 SellPriceTarget,
        pt.BudgetAmount PremiumBudget,
        0 PolicyCountBudget,
        0 AUD_SellPriceTarget,
        pt.BudgetAmount * isnull(fx.FXRate, 0) AUD_PremiumBudget
    from
        factPolicyPremiumBudget pt with(nolock)
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
    where
        pt.DateSK >= 20180101

    union all

    select 
        DateSK,
        DomainSK,
        OutletSK,
        ProductSK,
        0 SellPriceTarget,
        0 PremiumBudget,
        PolicyCountBudget,
        0 AUD_SellPriceTarget,
        0 AUD_PremiumBudget
    from
        factPolicyCountBudget pt with(nolock)
    where
        pt.DateSK >= 20180101
)
--,
--cte_agg as
--(
--    select
--        DateSK,
--        DomainSK,
--        OutletSK,
--        convert(int, ProductSK) ProductSK,
--        sum(isnull(SellPriceTarget, 0)) SellPriceTarget,
--        sum(isnull(PremiumBudget, 0)) PremiumBudget,
--        sum(isnull(PolicyCountBudget, 0)) PolicyCountBudget
--    from
--        cte_targets
--    group by
--        DateSK,
--        DomainSK,
--        OutletSK,
--        ProductSK
--)
select
    DateSK,
    DomainSK,
    OutletSK,
    isnull(nullif(ProductSK, 0), -1) ProductSK,
    SellPriceTarget,
    PremiumBudget,
    PolicyCountBudget,
    AUD_SellPriceTarget,
    AUD_PremiumBudget,
    OutletReference
from
    cte_targets
    --cte_agg
    cross apply
    (
        select 'Point in time' OutletReference
        union all
        select 'Latest alpha' OutletReference
    ) r





GO
