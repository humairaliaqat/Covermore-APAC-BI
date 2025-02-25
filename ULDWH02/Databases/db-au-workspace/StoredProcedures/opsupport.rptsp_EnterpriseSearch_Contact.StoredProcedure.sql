USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [opsupport].[rptsp_EnterpriseSearch_Contact]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [opsupport].[rptsp_EnterpriseSearch_Contact]
    @Customer EVSearch readonly

as
begin

    --cache address
    insert into [db-au-workspace].[opsupport].[ev_contact]
    (
        [CustomerID],
        [ContactType],
        [ContactValue],
        [MinDate],
        [MaxDate]
    )
    select 
        ec.CustomerID,
        'Address',
        fa.FormattedAddress,
        ea.MinDate,
        ea.MaxDate 
    from
        [db-au-workspace].[opsupport].[ev_customer] ec
        left join [db-au-cmdwh].dbo.entAddress ea with(nolock) on
            ea.CustomerID = ec.CustomerID
        outer apply
        (
            select
                isnull(ea.Address, '') + 
                isnull(' ' + ea.Suburb, '') + 
                isnull(' ' + ea.State, '') + 
                isnull(' ' + ea.PostCode, '') + 
                isnull(', ' + ea.Country, '')FormattedAddress
        ) fa
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
                [db-au-workspace].[opsupport].[ev_contact] r
            where
                r.CustomerID = ec.CustomerID and
                r.ContactType = 'Address' and
                r.ContactValue = fa.FormattedAddress
        )

    --cache alias
    insert into [db-au-workspace].[opsupport].[ev_contact]
    (
        [CustomerID],
        [ContactType],
        [ContactValue]
    )
    select distinct
        ec.CustomerID,
        'Alias',
        ea.Alias 
    from
        [db-au-workspace].[opsupport].[ev_customer] ec
        left join [db-au-cmdwh].dbo.entAlias ea with(nolock) on
            ea.CustomerID = ec.CustomerID 
            --and
            --ea.Alias <> ec.CustomerName
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
                [db-au-workspace].[opsupport].[ev_contact] r
            where
                r.CustomerID = ec.CustomerID and
                r.ContactType = 'Alias' and
                r.ContactValue = ea.Alias
        )

    --cache phone
    insert into [db-au-workspace].[opsupport].[ev_contact]
    (
        [CustomerID],
        [ContactType],
        [ContactValue],
        [MaxDate]
    )
    select 
        ec.CustomerID,
        'Phone',
        ep.PhoneNumber,
        max(ep.UpdateDate) LastUpdate 
    from
        [db-au-workspace].[opsupport].[ev_customer] ec
        left join [db-au-cmdwh].dbo.entPhone ep with(nolock) on
            ep.CustomerID = ec.CustomerID
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
                [db-au-workspace].[opsupport].[ev_contact] r
            where
                r.CustomerID = ec.CustomerID and
                r.ContactType = 'Phone' and
                r.ContactValue = ep.PhoneNumber
        )
    group by
        ec.CustomerID,
        ep.PhoneNumber

    --cache email
    insert into [db-au-workspace].[opsupport].[ev_contact]
    (
        [CustomerID],
        [ContactType],
        [ContactValue]
    )
    select distinct
        ec.CustomerID,
        'Email',
        ee.EmailAddress
    from
        [db-au-workspace].[opsupport].[ev_customer] ec
        left join [db-au-cmdwh].dbo.entEmail ee with(nolock) on
            ee.CustomerID = ec.CustomerID
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
                [db-au-workspace].[opsupport].[ev_contact] r
            where
                r.CustomerID = ec.CustomerID and
                r.ContactType = 'Email' and
                r.ContactValue = ee.EmailAddress
        )

end
GO
