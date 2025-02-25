USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [opsupport].[rptsp_EnterpriseSearch_Relation]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [opsupport].[rptsp_EnterpriseSearch_Relation]
    @Customer EVSearch readonly

as
begin

    --build and cache relation

    --shared account
    if object_id('tempdb..#account') is not null
        drop table #account

    select distinct
        ec.CustomerID,
        'Shared account' Relation,
        '' DataID,
        --convert(varchar(max), ea.AccountID) DataID,
        rea.CustomerID RelatedCustomerID
    into #account
    from
        [db-au-cmdwh].dbo.entCustomer ec with(nolock)
        inner join [db-au-cmdwh].dbo.entAccounts ea with(nolock) on
            ea.CustomerID = ec.CustomerID
        inner join [db-au-cmdwh].dbo.entAccounts rea with(nolock) on
            rea.AccountID = ea.AccountID and
            rea.CustomerID <> ea.CustomerID
    where
        ec.CustomerID = isnull(ec.MergedTo, ec.CustomerID) and
        ec.CustomerID in 
        (
            select 
                CustomerID 
            from 
                @Customer
        )

    --shared policy
    if object_id('tempdb..#cotravel') is not null
        drop table #cotravel

    select distinct
        ec.CustomerID,
        'Co-traveller' Relation,
        '' DataID,
        --p.PolicyNumber DataID,
        rep.CustomerID RelatedCustomerID
    into #cotravel
    from
        [db-au-cmdwh].dbo.entCustomer ec with(nolock)
        inner join [db-au-cmdwh].dbo.entPolicy ep with(nolock) on
            ep.CustomerID = ec.CustomerID and
            ep.ClaimKey is null
        inner join [db-au-cmdwh].dbo.penPolicy p on
            p.PolicyKey = ep.PolicyKey and
            isnull(p.GroupName, '') = ''
        inner join [db-au-cmdwh].dbo.entPolicy rep with(nolock) on
            rep.PolicyKey = ep.PolicyKey and
            rep.ClaimKey is null and
            rep.CustomerID <> ep.CustomerID
    where
        ec.CustomerID = isnull(ec.MergedTo, ec.CustomerID) and
        ec.CustomerID in 
        (
            select 
                CustomerID 
            from 
                @Customer
        ) and
        not exists
        (
            select
                null
            from
                #account r
            where
                r.CustomerID = ec.CustomerID and
                r.RelatedCustomerID = rep.CustomerID
        )

    --shared address
    if object_id('tempdb..#colocate') is not null
        drop table #colocate

    select distinct
        ec.CustomerID,
        'Co-resident' Relation,
        '' DataID,
        --ec.CurrentAddress DataID,
        rec.CustomerID RelatedCustomerID
    into #colocate
    from
        [db-au-cmdwh].dbo.entCustomer ec with(nolock)
        inner join [db-au-cmdwh].dbo.entCustomer rec with(nolock) on
            rec.CurrentAddress = ec.CurrentAddress and
            rec.CustomerID <> ec.CustomerID
    where
        ec.CustomerID = isnull(ec.MergedTo, ec.CustomerID) and
        ec.CurrentAddress <> '' and
        ec.CustomerID in 
        (
            select 
                CustomerID 
            from 
                @Customer
        ) and
        not exists
        (
            select
                null
            from
                #account r
            where
                r.CustomerID = ec.CustomerID and
                r.RelatedCustomerID = rec.CustomerID
        ) and
        not exists
        (
            select
                null
            from
                #cotravel r
            where
                r.CustomerID = ec.CustomerID and
                r.RelatedCustomerID = rec.CustomerID
        )
        
    --shared email
    if object_id('tempdb..#email') is not null
        drop table #email

    select distinct
        ec.CustomerID,
        'Shared email' Relation,
        '' DataID,
        --ee.EmailAddress DataID,
        ree.CustomerID RelatedCustomerID
    into #email
    from
        [db-au-cmdwh].dbo.entCustomer ec with(nolock)
        inner join [db-au-cmdwh].dbo.entEmail ee with(nolock) on
            ee.CustomerID = ec.CustomerID
        inner join [db-au-cmdwh].dbo.entEmail ree with(nolock) on
            ree.EmailAddress = ee.EmailAddress and
            ree.CustomerID <> ee.CustomerID
    where
        ec.CustomerID = isnull(ec.MergedTo, ec.CustomerID) and
        rtrim(ee.EmailAddress) <> '' and
        ec.CustomerID in 
        (
            select 
                CustomerID 
            from 
                @Customer
        ) and
        not exists
        (
            select
                null
            from
                #account r
            where
                r.CustomerID = ec.CustomerID and
                r.RelatedCustomerID = ree.CustomerID
        ) and
        not exists
        (
            select
                null
            from
                #cotravel r
            where
                r.CustomerID = ec.CustomerID and
                r.RelatedCustomerID = ree.CustomerID
        ) and
        not exists
        (
            select
                null
            from
                #colocate r
            where
                r.CustomerID = ec.CustomerID and
                r.RelatedCustomerID = ree.CustomerID
        )

    --shared mobile phone
    if object_id('tempdb..#mobile') is not null
        drop table #mobile

    select distinct
        ec.CustomerID,
        'Shared mobile' Relation,
        '' DataID,
        --ep.PhoneNumber DataID,
        rep.CustomerID RelatedCustomerID
    into #mobile
    from
        [db-au-cmdwh].dbo.entCustomer ec with(nolock)
        inner join [db-au-cmdwh].dbo.entPhone ep with(nolock) on
            ep.CustomerID = ec.CustomerID
        inner join [db-au-cmdwh].dbo.entPhone rep with(nolock) on
            rep.PhoneNumber = ep.PhoneNumber and
            rep.CustomerID <> ep.CustomerID
    where
        ec.CustomerID = isnull(ec.MergedTo, ec.CustomerID) and
        rtrim(ep.PhoneNumber) <> '' and
        ec.CustomerID in 
        (
            select 
                CustomerID 
            from 
                @Customer
        ) and
        not exists
        (
            select
                null
            from
                #account r
            where
                r.CustomerID = ec.CustomerID and
                r.RelatedCustomerID = rep.CustomerID
        ) and
        not exists
        (
            select
                null
            from
                #cotravel r
            where
                r.CustomerID = ec.CustomerID and
                r.RelatedCustomerID = rep.CustomerID
        ) and
        not exists
        (
            select
                null
            from
                #colocate r
            where
                r.CustomerID = ec.CustomerID and
                r.RelatedCustomerID = rep.CustomerID
        ) and
        not exists
        (
            select
                null
            from
                #email r
            where
                r.CustomerID = ec.CustomerID and
                r.RelatedCustomerID = rep.CustomerID
        )
        
    --build relation
    insert into [db-au-workspace].[opsupport].[ev_relation]
    select 
        t.*,
        isnull(lp.LastRecordedName, ec.CustomerName) CustomerName,
        case
            when isnull(bl.BlockScore, 0) > 0 then 'Blocked'
            when ec.ClaimScore >= 3000 then 'Very high risk'
            when ec.ClaimScore >= 500 then 'High risk'
            when ec.ClaimScore >= 10 then 'Medium risk'
            when ec.PrimaryScore >= 5000 then 'Very high risk'
            when ec.PrimaryScore >= 3000 then 'High risk'
            when ec.PrimaryScore > 1500 then 'Medium risk'
            else 'Low Risk'
        end RelatedScore,
        case
            when isnull(bl.BlockScore, 0) > 0 then 2000
            when ec.ClaimScore >= 3000 then 1000
            when ec.ClaimScore >= 500 then 500
            when ec.ClaimScore >= 10 then 300
            when ec.PrimaryScore >= 5000 then 1000
            when ec.PrimaryScore >= 3000 then 500
            when ec.PrimaryScore > 1500 then 300
            else 100
        end RelatedSize
    from
        (
            select
                CustomerID,
                Relation,
                DataID,
                RelatedCustomerID
            
            from
                #account

            union

            select
                CustomerID,
                Relation,
                DataID,
                RelatedCustomerID
            from
                #cotravel

            union 

            select
                CustomerID,
                Relation,
                DataID,
                RelatedCustomerID
            from
                #colocate

            union

            select
                CustomerID,
                Relation,
                DataID,
                RelatedCustomerID
            from
                #email

            union

            select
                CustomerID,
                Relation,
                DataID,
                RelatedCustomerID
            from
                #mobile
        ) t
        inner join [db-au-cmdwh].dbo.entCustomer ec with(nolock) on
            ec.CustomerID = t.RelatedCustomerID
        outer apply
        (
            select top 1 
                isnull(ltrim(rtrim(ptv.FirstName)) + ' ', '') + isnull(ltrim(rtrim(ptv.LastName)), '') LastRecordedName
            from
                [db-au-cmdwh].[dbo].[entPolicy] ep with(nolock)
                inner join [db-au-cmdwh].[dbo].[penPolicy] p with(nolock) on
                    p.PolicyKey = ep.PolicyKey
                inner join [db-au-cmdwh].[dbo].[penPolicyTraveller] ptv with(nolock) on
                    ptv.PolicyKey = p.PolicyKey and
                    ptv.PolicyTravellerKey = ep.Reference
            where
                ep.CustomerID = ec.CustomerID
            order by
                p.IssueDate desc
        ) lp
        outer apply
        (
            select top 1 
                9001 BlockScore
            from
                [db-au-cmdwh].dbo.entBlacklist bl
            where
                bl.CustomerID = ec.CustomerID
        ) bl
    where
        not exists
        (
            select
                null
            from
                [db-au-workspace].[opsupport].[ev_relation] r
            where
                r.CustomerID = t.CustomerID and
                r.RelatedCustomerID = t.RelatedCustomerID and
                r.Relation = t.Relation
        )
            

    --cache network (in JSON)
    insert into [db-au-workspace].[opsupport].[ev_network] 
    (
        [CustomerID],
        [JSONNetwork]
    )
    select 
        ec.CustomerID,
        (
            select distinct
                ec.CustomerName [name],
                ec.PrimaryScore [size],
                (
                    select distinct
                        Relation [name],
                        (
                            select 
                                sum(RelatedSize)
                            from
                                [db-au-workspace].[opsupport].[ev_relation] gc
                            where
                                gc.CustomerID = c.CustomerID and
                                gc.Relation = c.Relation
                        ) [size],
                        (
                            select distinct
                                CustomerName [name],
                                RelatedSize [size]
                            from
                                [db-au-workspace].[opsupport].[ev_relation] gc
                            where
                                gc.CustomerID = c.CustomerID and
                                gc.Relation = c.Relation
                            for json auto
                        ) [children]

                        --(
                        --    select distinct
                        --        DataID [name],
                        --        (
                        --            select 
                        --                sum(RelatedSize)
                        --            from
                        --                [db-au-workspace].[opsupport].[ev_relation] ggc
                        --            where
                        --                ggc.CustomerID = gc.CustomerID and
                        --                ggc.Relation = gc.Relation and
                        --                ggc.DataID = gc.DataID
                        --        ) [size],
                        --        (
                        --            select distinct
                        --                CustomerName [name],
                        --                RelatedSize [size]
                        --            from
                        --                [db-au-workspace].[opsupport].[ev_relation] ggc
                        --            where
                        --                ggc.CustomerID = gc.CustomerID and
                        --                ggc.Relation = gc.Relation and
                        --                ggc.DataID = gc.DataID
                        --            for json auto
                        --        ) [children]
                        --    from
                        --        [db-au-workspace].[opsupport].[ev_relation] gc
                        --    where
                        --        gc.CustomerID = c.CustomerID and
                        --        gc.Relation = c.Relation
                        --    for json auto
                        --) [children]
                    from
                        [db-au-workspace].[opsupport].[ev_relation] c
                    where
                        c.CustomerID = t.CustomerID
                    for json auto
                ) [children]
            from
                [db-au-workspace].[opsupport].[ev_relation] t
            where
                t.CustomerID = ec.CustomerID
            for json path, without_array_wrapper


        ) JSONNetwork
    from
        [db-au-workspace].[opsupport].[ev_customer] ec
    where
        ec.CustomerID in 
        (
            select 
                CustomerID 
            from 
                @Customer
        ) and
        not exists
        (
            select
                null
            from 
                [db-au-workspace].[opsupport].[ev_network] r
            where
                r.CustomerID = ec.CustomerID
        )

end
GO
