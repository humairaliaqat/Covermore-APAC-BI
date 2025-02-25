USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vFCUS]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vFCUS] 
as
with cte_cy
as
(
    select --top 1000
        dd.[Date],
        do.SubGroupName Brand,
        do.FCNation,
        do.FCArea,
        do.LatestBDMName BDMName,
        do.OutletName StoreName,
        dc.ConsultantName,
        dpo.ProductCode,
        dpo.ProductClassification,
        dab.ABSAgeBand AgeBand,
        ddr.ABSDurationBand,
        dp.CancellationCoverBand,
        dlt.LeadTimeBand,
        sum(isnull(pt.PolicyCount, 0)) PolicyCount,
        sum(isnull(pt.SellPrice, 0)) SellPrice,
        sum(isnull(pt.Commission, 0) + isnull(pt.AdminFee, 0)) Commission,
        sum(convert(money, isnull(dp.CancellationCover, 0)) * isnull(pt.PolicyCount, 0)) TripCost,
        sum(lt.LeadTime * isnull(pt.PolicyCount, 0)) LeadTime,
        0 QuoteCount,
        0 TargetPolicyCount,
        0 TargetSellPrice
    from
        [db-au-star]..factPolicyTransaction pt with(nolock)
        inner join [db-au-star]..dim_date dd with(nolock) on
            dd.Date_SK = pt.DateSK
        inner join [db-au-star]..dimOutlet do with(nolock) on
            do.OutletSK = pt.OutletSK
        inner join [db-au-star]..dimProduct dpo with(nolock) on
            dpo.ProductSK = pt.ProductSK
        inner join [db-au-star]..dimAgeBand dab with(nolock) on
            dab.AgeBandSK = pt.AgeBandSK
        inner join [db-au-star]..dimDuration ddr with(nolock) on
            ddr.DurationSK = pt.DurationSK
        inner join [db-au-star]..vdimPolicy dp with(nolock) on
            dp.PolicySK = pt.PolicySK
        cross apply
        (
            select
                case
                    when datediff([day], dp.issuedate, dp.tripstart) < -1 then -1
                    when datediff([day], dp.issuedate, dp.tripstart) > 2000 then -1
                    else datediff([day], dp.issuedate, dp.tripstart)
                end LeadTime
        ) lt
        inner join [db-au-star]..dimLeadTime dlt with(nolock) on
            dlt.LeadTimeSK = lt.LeadTime
        inner join [db-au-star]..dimConsultant dc with(nolock) on
            dc.ConsultantSK = pt.ConsultantSK
    where
        dd.[Date] >= '2015-07-01' and
        do.Country = 'US' and
        do.GroupCode = 'FL' and
        do.LatestBDMName not in ('Paul Yang')
    group by
        dd.[Date],
        do.SubGroupName,
        do.FCNation,
        do.FCArea,
        do.LatestBDMName,
        do.OutletName,
        dc.ConsultantName,
        dpo.ProductCode,
        dpo.ProductClassification,
        dab.ABSAgeBand,
        ddr.ABSDurationBand,
        dp.CancellationCoverBand,
        dlt.LeadTimeBand

    union all

    select --top 1000
        dd.[Date],
        do.SubGroupName Brand,
        do.FCNation,
        do.FCArea,
        do.LatestBDMName BDMName,
        do.OutletName StoreName,
        dc.ConsultantName,
        dpo.ProductCode,
        dpo.ProductClassification,
        dab.ABSAgeBand AgeBand,
        ddr.ABSDurationBand,
        'Unknown' CancellationCoverBand,
        dlt.LeadTimeBand,
        0 PolicyCount,
        0 SellPrice,
        0 Commission,
        0 TripCost,
        0 LeadTime,
        sum(isnull(q.QuoteCount, 0)) QuoteCount,
        0 TargetPolicyCount,
        0 TargetSellPrice
    from
        [db-au-star]..vfactQuoteSummary q with(nolock)
        inner join [db-au-star]..dim_date dd with(nolock) on
            dd.Date_SK = q.DateSK
        inner join [db-au-star]..dimOutlet do with(nolock) on
            do.OutletSK = q.OutletSK
        inner join [db-au-star]..dimProduct dpo with(nolock) on
            dpo.ProductSK = q.ProductSK
        inner join [db-au-star]..dimAgeBand dab with(nolock) on
            dab.AgeBandSK = q.AgeBandSK
        inner join [db-au-star]..dimDuration ddr with(nolock) on
            ddr.DurationSK = q.DurationSK
        inner join [db-au-star]..dimLeadTime dlt with(nolock) on
            dlt.LeadTimeSK = q.LeadTime
        inner join [db-au-star]..dimConsultant dc with(nolock) on
            dc.ConsultantSK = q.ConsultantSK
    where
        dd.[Date] >= '2015-07-01' and
        do.Country = 'US' and
        do.GroupCode = 'FL' and
        do.LatestBDMName not in ('Paul Yang') and
        q.OutletReference = 'Point in time'
    group by
        dd.[Date],
        do.SubGroupName,
        do.FCNation,
        do.FCArea,
        do.LatestBDMName,
        do.OutletName,
        dc.ConsultantName,
        dpo.ProductCode,
        dpo.ProductClassification,
        dab.ABSAgeBand,
        ddr.ABSDurationBand,
        dlt.LeadTimeBand

    union all

    select --top 1000
        dd.[Date],
        do.SubGroupName Brand,
        do.FCNation,
        do.FCArea,
        do.LatestBDMName BDMName,
        do.OutletName StoreName,
        'Unknown' ConsultantName,
        'Unknown' ProductCode,
        'Unknown' ProductClassification,
        'Unknown' AgeBand,
        'Unknown' ABSDurationBand,
        'Unknown' CancellationCoverBand,
        'Unknown' LeadTimeBand,
        0 PolicyCount,
        0 SellPrice,
        0 Commission,
        0 TripCost,
        0 LeadTime,
        0 QuoteCount,
        0 TargetPolicyCount,
        sum(isnull(pt.BudgetAmount, 0)) TargetSellPrice
    from
        [db-au-star]..factPolicyTarget pt with(nolock)
        inner join [db-au-star]..dim_date dd with(nolock) on
            dd.Date_SK = pt.DateSK
        inner join [db-au-star]..dimOutlet do with(nolock) on
            do.OutletSK = pt.OutletSK
    where
        dd.[Date] >= '2015-07-01' and
        do.Country = 'US' and
        do.GroupCode = 'FL' and
        do.LatestBDMName not in ('Paul Yang')
    group by
        dd.[Date],
        do.SubGroupName,
        do.FCNation,
        do.FCArea,
        do.LatestBDMName,
        do.OutletName

    union all

    select --top 1000
        dd.[Date],
        do.SubGroupName Brand,
        do.FCNation,
        do.FCArea,
        do.LatestBDMName BDMName,
        do.OutletName StoreName,
        'Unknown' ConsultantName,
        'Unknown' ProductCode,
        'Unknown' ProductClassification,
        'Unknown' AgeBand,
        'Unknown' ABSDurationBand,
        'Unknown' CancellationCoverBand,
        'Unknown' LeadTimeBand,
        0 PolicyCount,
        0 SellPrice,
        0 Commission,
        0 LeadTime,
        0 TripCost,
        0 QuoteCount,
        sum(isnull(pt.PolicyCountBudget, 0)) TargetPolicyCount,
        0 TargetSellPrice
    from
        [db-au-star]..factPolicyCountBudget pt with(nolock)
        inner join [db-au-star]..dim_date dd with(nolock) on
            dd.Date_SK = pt.DateSK
        inner join [db-au-star]..dimOutlet do with(nolock) on
            do.OutletSK = pt.OutletSK
    where
        dd.[Date] >= '2015-07-01' and
        do.Country = 'US' and
        do.GroupCode = 'FL' and
        do.LatestBDMName not in ('Paul Yang')
    group by
        dd.[Date],
        do.SubGroupName,
        do.FCNation,
        do.FCArea,
        do.LatestBDMName,
        do.OutletName
)
select
    [Date],
    Brand,
    FCNation,
    FCArea,
    BDMName,
    StoreName,
    ConsultantName,
    ProductCode,
    ProductClassification,
    AgeBand,
    ABSDurationBand,
    CancellationCoverBand,
    LeadTimeBand,
    PolicyCount,
    SellPrice,
    Commission,
    TripCost,
    LeadTime,
    QuoteCount,
    TargetPolicyCount,
    TargetSellPrice,
    0 PolicyCountPY,
    0 SellPricePY,
    0 CommissionPY,
    0 QuoteCountPY,
    0 TargetPolicyCountPY,
    0 TargetSellPricePY
from
    cte_cy
--where
--    [Date] = '2016-07-01' and
--    StoreName = 'Cherry Hill Groups'

union all

select
    dateadd(year, 1, [Date]),
    Brand,
    FCNation,
    FCArea,
    BDMName,
    StoreName,
    ConsultantName,
    ProductCode,
    ProductClassification,
    AgeBand,
    ABSDurationBand,
    CancellationCoverBand,
    LeadTimeBand,
    0 PolicyCount,
    0 SellPrice,
    0 Commission,
    0 TripCost,
    0 LeadTime,
    0 QuoteCount,
    0 TargetPolicyCount,
    0 TargetSellPrice,
    PolicyCount PolicyCountPY,
    SellPrice SellPricePY,
    Commission CommissionPY,
    QuoteCount QuoteCountPY,
    TargetPolicyCount TargetPolicyCountPY,
    TargetSellPrice TargetSellPricePY
from
    cte_cy
--where
--    [Date] = '2016-07-01' and
--    StoreName = 'Cherry Hill Groups'
GO
