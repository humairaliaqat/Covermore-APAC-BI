USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_entClaimScore]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_entClaimScore]
as
begin

    update ec
    set
        ec.ClaimScore = 
            case
                when SanctionScore >= 30 then 2000
                else 0
            end +
            isnull(bl.Score, 0) + 
            (isnull(wl.WatchList, 0) * 100) +
            --(isnull(r.BlackListRelation, 0) * 9000) +
            isnull(cs.ClaimScore, 0)
    from
        [db-au-cmdwh]..entCustomer ec
        outer apply
        (
            select top 1 
                9001 Score
            from
                [db-au-cmdwh]..entBlacklist bl
            where
                bl.CustomerID = ec.CustomerID
        ) bl
        cross apply
        (
            select 
                sum
                (
                    case
                        when Classification = 'Red' then 1000
                        when Classification = 'Amber' then 100
                        when Classification = 'Yellow' then 10
                        else 1
                    end 
                ) ClaimScore
            from
                [db-au-cmdwh]..vEnterpriseClaimClassification
            where
                ClaimKey in
                (
                    select 
                        ClaimKey
                    from
                        [db-au-cmdwh]..entPolicy ep
                    where
                        ep.CustomerID = ec.CustomerID

                    union

                    select 
                        cl.ClaimKey
                    from
                        [db-au-cmdwh]..entPolicy ep
                        inner join [db-au-cmdwh]..penPolicyTransSummary pt on
                            pt.PolicyKey = ep.PolicyKey
                        inner join [db-au-cmdwh]..clmClaim cl on
                            cl.PolicyTransactionKey = pt.PolicyTransactionKey
                        inner join [db-au-cmdwh]..penPolicy p on
                            p.PolicyKey = pt.PolicyKey
                    where
                        ep.CustomerID = ec.CustomerID and
                        p.ProductName not like '%Base'
                )
        ) cs
        outer apply
        (
            select top 1
                1 WatchList
            from
                [db-au-workspace]..live_dashboard_watchlist wl
            where
                wl.CustomerID = ec.CustomerID
        ) wl
        --cross apply
        --(
        --    select top 1
        --        1 BlackListRelation
        --    from
        --        [db-au-cmdwh].[dbo].[fn_EnterpriseRelation] (ec.CustomerID, null) r
        --    where
        --        r.Relation in ('Shared account(s)') and
        --        (
        --            r.PrimaryScore >= 9000 or
        --            exists
        --            (
        --                select 
        --                    null
        --                from
        --                    [db-au-cmdwh]..entBlacklist bl
        --                where
        --                    bl.CustomerID = r.CustomerID
        --            )
        --        )
        --) r
    where
        CustomerID = MergedTo and
        (
            ec.UpdateBatchID in
            (
                select 
                    Batch_ID
                from
                    [db-au-log]..Batch_Run_Status
                where
                    Subject_Area = 'EnterpriseMDM ODS' and
                    Batch_Start_Time >= dateadd(day, -2, convert(date, getdate())) and
                    Batch_Start_Time >= '2017-01-19'
            ) or
            ec.CustomerID in
            (
                select 
                    ep.CustomerID
                from
                    [db-au-cmdwh]..clmClaim cl with(nolock)
                    inner join [db-au-cmdwh]..entPolicy ep with(nolock) on
                        ep.ClaimKey = cl.ClaimKey
                where
                    cl.CreateDate >= dateadd(day, -7, convert(date, getdate()))

                union 

                select 
                    ep.CustomerID
                from
                    [db-au-cmdwh]..clmClaim cl with(nolock)
                    inner join [db-au-cmdwh]..penPolicyTransSummary pt with(nolock) on
                        pt.PolicyTransactionKey = cl.PolicyTransactionKey
                    inner join [db-au-cmdwh]..entPolicy ep with(nolock) on
                        ep.PolicyKey = pt.PolicyKey
                where
                    cl.CreateDate >= dateadd(day, -4, convert(date, getdate()))

                union 

                select 
                    ep.CustomerID
                from
                    [db-au-cmdwh]..clmClaim cl with(nolock)
                    inner join [db-au-cmdwh]..clmClaimIncurredMovement cim with(nolock) on
                        cim.ClaimKey = cl.ClaimKey
                    inner join [db-au-cmdwh]..penPolicyTransSummary pt with(nolock) on
                        pt.PolicyTransactionKey = cl.PolicyTransactionKey
                    inner join [db-au-cmdwh]..entPolicy ep with(nolock) on
                        ep.PolicyKey = pt.PolicyKey
                where
                    cim.IncurredDate >= dateadd(day, -3, convert(date, getdate()))
            )
        )

end
GO
