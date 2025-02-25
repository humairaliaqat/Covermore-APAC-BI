USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_Enterprise_Watchlist]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_Enterprise_Watchlist]
as
begin

    if object_id('[db-au-workspace]..live_dashboard_watchlist') is null
        create table [db-au-workspace]..live_dashboard_watchlist
        (
            CustomerID bigint
        )

    if object_id('[db-au-workspace]..live_dashboard_repeatoffender') is null
        create table [db-au-workspace]..live_dashboard_repeatoffender
        (
            IDType varchar(50),
            IDValue varchar(300),
            ClaimCount int,
            CustomerCount int,
            ClaimCost decimal(16,2),
            MaxClaimCost decimal(16,2),
            MinClaimCost decimal(16,2)
        )

    truncate table [db-au-workspace]..live_dashboard_repeatoffender

    ;with
    cte_repeatoffender
    as
    (
        select top 5000
            IDValue,
            count(distinct ClaimKey) ClaimCount,
            count(distinct ei.CustomerID) CustomerCount
        from
            entIdentity ei
            inner join entPolicy ep on
                ep.CustomerID = ei.CustomerID
        where   
            IDType = 'Account Number'
        group by
            IDValue
        having
            count(distinct ClaimKey) > 4
        order by
            count(distinct ClaimKey) desc
    )
    insert into [db-au-workspace]..live_dashboard_repeatoffender
    (
        IDType,
        IDValue,
        ClaimCount,
        CustomerCount,
        ClaimCost,
        MaxClaimCost,
        MinClaimCost
    )
    select
        'Account Number' IDType,
        IDValue,
        ClaimCount,
        CustomerCount,
        ClaimCost,
        MaxClaimCost,
        MinClaimCost
    from
        cte_repeatoffender ro
        cross apply
        (
            select 
                sum(ClaimCost) ClaimCost,
                max(ClaimCost) MaxClaimCost,
                min(ClaimCost) MinClaimCost
            from
                (
                    select 
                        ClaimKey,
                        sum(IncurredDelta) ClaimCost
                    from
                        vclmClaimIncurred ci
                    where
                        ci.ClaimKey in
                        (
                            select 
                                ep.ClaimKey
                            from
                                entIdentity ei
                                inner join entPolicy ep on
                                    ep.CustomerID = ei.CustomerID
                            where
                                ei.IDType = 'Account Number' and
                                ei.IDValue = ro.IDValue
                        )
                    group by
                        ClaimKey
                ) t
        ) c
    where
        (
            MaxClaimCost <= 5000 and
            ClaimCount >= 4
        ) or
        MinClaimCost >= 20000 or
        ClaimCount >= 10
    order by
        2 desc


    truncate table [db-au-workspace]..live_dashboard_watchlist

    insert into [db-au-workspace]..live_dashboard_watchlist
    select distinct
        ec.CustomerID
    from
        entIdentity i
        inner join entCustomer ec on
            ec.CustomerID = i.CustomerID
    where
        ec.CustomerID = ec.MergedTo and
        IDType = 'Account Number' and
        IDValue in
        (
            select 
                r.IDValue
            from
                [db-au-workspace]..live_dashboard_repeatoffender r
            where
                r.IDType = i.IDType
        )

end
GO
