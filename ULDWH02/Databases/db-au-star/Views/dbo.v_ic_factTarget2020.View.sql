USE [db-au-star]
GO
/****** Object:  View [dbo].[v_ic_factTarget2020]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [dbo].[v_ic_factTarget2020]
as
with cte_targets
as
(
    select 
        pt.Date_SK,
        pt.Country,
        pt.OutletSK,
        pt.FinanceProductCode,
        pt.BudgetAmountSales SellPriceTarget,
        pt.BudgetAmountPremium PremiumBudget,
        pt.PolicyCountBudget PolicyCountBudget,
        pt.BudgetAmountSales * isnull(fx.FXRate, 0) AUD_SellPriceTarget,
        pt.BudgetAmountPremium * isnull(fx.FXRate, 0) AUD_PremiumBudget
    from
        factPolicyTarget2020 pt with(nolock)
        cross apply
        (
            select
                min(t.Date_SK) DateSK
            from
                (
                    select pt.Date_SK

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
				join dimDomain dm on pt.Country = dm.CountryCode
            where
                fx.DomainSK = dm.DomainSK and
                fx.DateSK = d.DateSK and
                fx.FXCurrency = 'AUD'
        ) fx
    where
        pt.Date_SK >= 20180101

   
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
    Date_SK,
    Country,
    OutletSK,
    FinanceProductCode,
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
