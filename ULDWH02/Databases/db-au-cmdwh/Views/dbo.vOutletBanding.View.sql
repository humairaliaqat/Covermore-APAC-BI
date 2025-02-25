USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vOutletBanding]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vOutletBanding] as
with 
cte_ltm as
(
    select 
        lo.OutletAlphaKey LatestOutletAlphaKey,
        do.Country,
        do.SuperGroupName,
        do.GroupName,
        o.OutletAlphaKey,
        pt.SalesLTM
    from
        [db-au-cmdwh]..penOutlet lo
        inner join [db-au-cmdwh]..penOutlet o on
            o.LatestOutletKey = lo.OutletKey and
            o.OutletStatus = 'Current'
        inner join [db-au-star]..dimOutlet do on
            do.OutletAlphaKey = lo.OutletAlphaKey and
            do.isLatest = 'Y'
        cross apply
        (
            select 
                sum(GrossPremium) SalesLTM
            from
                [db-au-cmdwh]..penPolicyTransSummary pt
            where
                pt.OutletAlphaKey = o.OutletAlphaKey and
                pt.PostingDate >= dateadd(month, -12, convert(date, convert(varchar(8), getdate(), 120) + '01')) and
                pt.PostingDate <  convert(date, convert(varchar(8), getdate(), 120) + '01')
            group by
                pt.OutletAlphaKey
        ) pt
    where
        lo.OutletStatus = 'Current' and
        do.SuperGroupName <> ''
),
cte_rank as
(
    select 
        LatestOutletAlphaKey,
        Country,
        SuperGroupName,
        GroupName,
        OutletAlphaKey,
        SalesLTM,
        dense_rank() over (partition by Country, SuperGroupName, GroupName order by SalesLTM desc) InGroupRank
    from
        cte_ltm
),
cte_maxrank as
(
    select 
        LatestOutletAlphaKey,
        Country,
        SuperGroupName,
        GroupName,
        OutletAlphaKey,
        SalesLTM,
        InGroupRank,
        max(InGroupRank) over (partition by Country, SuperGroupName, GroupName) MaxRank
    from
        cte_rank
)
select 
    Country,
    SuperGroupName,
    GroupName,
    OutletAlphaKey,
    LatestOutletAlphaKey,
    SalesLTM,
    InGroupRank,
    MaxRank,
    --case
    --    when MaxRank = 0 then 0
    --    else InGroupRank * 1.00 / MaxRank * 100.0
    --end Percentile,
    Percentile,
    case
        when Percentile <= 25 then 'PLATINUM'
        when Percentile <= 50 then 'GOLD'
        when Percentile <= 75 then 'SILVER'
        else 'BRONZE'
    end SalesTier
from
    cte_maxrank t
    cross apply
    (
        select
            ceiling(
                ceiling(
                    case
                        when MaxRank = 0 then 0
                        else InGroupRank * 1.00 / MaxRank * 100.0
                    end
                ) / 5
            )  * 5 Percentile
    ) r
GO
