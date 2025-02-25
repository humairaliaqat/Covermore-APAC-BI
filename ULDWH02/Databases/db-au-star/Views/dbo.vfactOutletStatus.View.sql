USE [db-au-star]
GO
/****** Object:  View [dbo].[vfactOutletStatus]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vfactOutletStatus] as
with cte_tradingmovement as
(
    select 
        do.Country,
        OutletSK,
        oth.StatusChangeDate,
        case
            when isnull(OldTradingStatus, '') = 'Prospect' and isnull(NewTradingStatus, '') <> 'Prospect' then -1
            when isnull(NewTradingStatus, '') = 'Prospect' and isnull(OldTradingStatus, '') <> 'Prospect' then 1
            else 0
        end ProspectMovement,
        case
            when isnull(OldTradingStatus, '') = 'Stocked' and isnull(NewTradingStatus, '') <> 'Stocked' then -1
            when isnull(NewTradingStatus, '') = 'Stocked' and isnull(OldTradingStatus, '') <> 'Stocked' then 1
            else 0
        end StockedMovement,
        case
            when isnull(OldTradingStatus, '') = 'Stocks Withdrawn' and isnull(NewTradingStatus, '') <> 'Stocks Withdrawn' then -1
            when isnull(NewTradingStatus, '') = 'Stocks Withdrawn' and isnull(OldTradingStatus, '') <> 'Stocks Withdrawn' then 1
            else 0
        end WithdrawnedMovement,
        case
            when isnull(OldTradingStatus, '') = 'Closed' and isnull(NewTradingStatus, '') <> 'Closed' then -1
            when isnull(NewTradingStatus, '') = 'Closed' and isnull(OldTradingStatus, '') <> 'Closed' then 1
            else 0
        end ClosedMovement
    from
        dimOutlet do
        inner join [db-au-cmdwh]..penOutletTradingHistory oth on
            oth.OutletKey = do.OutletKey and
            (
                isnull(oth.OldTradingStatus, '') in ('', 'Closed', 'Prospect', 'Stocked', 'Stocks Withdrawn') or
                isnull(oth.NewTradingStatus, '') in ('', 'Closed', 'Prospect', 'Stocked', 'Stocks Withdrawn')
            )
    where
        do.isLatest = 'Y'

    union 

    select 
        do.Country,
        OutletSK,
        do.CommencementDate StatusChangeDate,
        1 ProspectMovement,
        0 StockedMovement,
        0 WithdrawnedMovement,
        0 ClosedMovement
    from
        dimOutlet do
    where
        do.isLatest = 'Y' and
        not exists
        (
            select null
            from
                [db-au-cmdwh]..penOutletTradingHistory oth
            where
                oth.OutletKey = do.OutletKey and
                oth.OldTradingStatus is null and
                oth.NewTradingStatus = 'Prospect'
        )
)
select --top 1000 
    Date_SK,
    OutletSK,
    DomainSK,
    r.OutletReference,
    ProspectMovement,
    StockedMovement,
    WithdrawnedMovement,
    ClosedMovement
from
    cte_tradingmovement t
    cross apply
    (
        select top 1 
            Date_SK
        from
            Dim_Date d
        where
            d.[Date] = convert(date, t.StatusChangeDate)
    ) d
    cross apply
    (
        select top 1 
            DomainSK
        from
            dimDomain dd
        where
            dd.CountryCode = t.Country
    ) dd
    cross apply
    (
        select 'Point in time' OutletReference
        union all
        select 'Latest alpha' OutletReference
    ) r
where
    StatusChangeDate >= '2011-07-01'

union all

select --top 1000 
    20110701 Date_SK,
    OutletSK,
    DomainSK,
    r.OutletReference,
    sum(ProspectMovement),
    sum(StockedMovement),
    sum(WithdrawnedMovement),
    sum(ClosedMovement)
from
    cte_tradingmovement t
    cross apply
    (
        select top 1 
            DomainSK
        from
            dimDomain dd
        where
            dd.CountryCode = t.Country
    ) dd
    cross apply
    (
        select 'Point in time' OutletReference
        union all
        select 'Latest alpha' OutletReference
    ) r
where
    StatusChangeDate < '2011-07-01'
group by
    OutletSK,
    DomainSK,
    r.OutletReference
GO
