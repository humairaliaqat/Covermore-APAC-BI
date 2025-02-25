USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_EnterpriseRelation]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[fn_EnterpriseRelation] (@CustomerID bigint, @ParentID bigint)
returns @out table
(
    ParentID bigint,
    CustomerID bigint,
    CustomerName nvarchar(255),
    Relation varchar(100),
    PrimaryScore int,
    SecondaryScore int,
    Multiplier float
)
as
begin

    insert into @out
    select distinct
        @CustomerID ParentID,
        ec.CustomerID,
        ec.CustomerName,
        'Shared account(s)' Relation,
        coalesce(ec.ClaimScore, ec.PrimaryScore) PrimaryScore,
        ec.SecondaryScore,
        0.85 Multiplier
    from
        entCustomer ec with(nolock)
        inner join entAccounts ea with(nolock) on
            ea.CustomerID = ec.CustomerID
    where
        ec.CustomerID = isnull(ec.MergedTo, ec.CustomerID) and
        (
            @ParentID is null or
            ec.CustomerID <> @ParentID
        ) and
        ea.AccountID in
        (
            select
                AccountID
            from
                entAccounts with(nolock)
            where
                CustomerID = @CustomerID
        ) and
        ec.CustomerID <> @CustomerID and
        ec.CustomerID not in
        (
            select
                CustomerID
            from
                @out
        )

    insert into @out
    select distinct
        @CustomerID ParentID,
        ec.CustomerID,
        ec.CUstomerName,
        'Co-traveller(s)' Relation,
        coalesce(ec.ClaimScore, ec.PrimaryScore) PrimaryScore,
        ec.SecondaryScore,
        case
            when count(ec.CustomerID) over () < 5 then 0.5
            when count(ec.CustomerID) over () < 8 then 0.3
            else 0.05
        end Multiplier
    from
        entPolicy t with(nolock)
        inner join entCustomer ec with(nolock) on
            ec.CustomerID = t.CustomerID
    where
        ec.CustomerID = isnull(ec.MergedTo, ec.CustomerID) and
        (
            @ParentID is null or
            ec.CustomerID <> @ParentID
        ) and
        PolicyKey in
        (
            select
                r.PolicyKey
            from
                entPolicy r with(nolock)
                inner join penPolicy p on
                    p.PolicyKey = r.PolicyKey
            where
                r.CustomerID = @CustomerID and
                p.GroupName = ''
        ) and
        t.CustomerID <> @CustomerID and
        ClaimKey is null and
        ec.CustomerID not in
        (
            select
                CustomerID
            from
                @out
        )

    insert into @out
    select distinct
        @CustomerID ParentID,
        CustomerID,
        CustomerName,
        'Co-resident(s)' Relation,
        coalesce(ec.ClaimScore, ec.PrimaryScore) PrimaryScore,
        ec.SecondaryScore,
        case
            when count(ec.CustomerID) over () < 5 then 0.4
            when count(ec.CustomerID) over () < 8 then 0.2
            else 0.01
        end Multiplier
    from
        entCustomer ec with(nolock)
    where
        ec.CustomerID = isnull(ec.MergedTo, ec.CustomerID) and
        @ParentID is null and
        (
            @ParentID is null or
            ec.CustomerID <> @ParentID
        ) and
        CurrentAddress in
        (
            select
                CurrentAddress
            from
                entCustomer with(nolock)
            where
                CustomerID = @CustomerID
        ) and
        CustomerID <> @CustomerID and
        CurrentAddress <> '' and
        CustomerID not in
        (
            select
                CustomerID
            from
                @out
        )


    insert into @out
    select distinct
        @CustomerID ParentID,
        ec.CustomerID,
        ec.CustomerName,
        'Shared email(s)' Relation,
        coalesce(ec.ClaimScore, ec.PrimaryScore) PrimaryScore,
        ec.SecondaryScore,
        case
            when count(ec.CustomerID) over () < 5 then 0.3
            when count(ec.CustomerID) over () < 8 then 0.1
            else 0.001
        end Multiplier
    from
        entEmail t with(nolock)
        inner join entCustomer ec with(nolock) on
            ec.CustomerID = t.CustomerID
    where
        ec.CustomerID = isnull(ec.MergedTo, ec.CustomerID) and
        @ParentID is null and
        EmailAddress in
        (
            select
                EmailAddress
            from
                entEmail r with(nolock)
            where
                r.CustomerID = @CustomerID
        ) and
        ec.CustomerID <> @CustomerID and
        rtrim(EmailAddress) <> '' and
        ec.CustomerID not in
        (
            select
                CustomerID
            from
                @out
        )


    --insert into @out
    --select distinct
    --    @CustomerID ParentID,
    --    ec.CustomerID,
    --    ec.CustomerName,
    --    'Shared phone(s)' Relation
    --from
    --    entPhone t with(nolock)
    --    inner join entCustomer ec with(nolock) on
    --        ec.CustomerID = t.CustomerID
    --where
    --    (
    --        @ParentID is null or
    --        ec.CustomerID <> @ParentID
    --    ) and
    --    PhoneNumber in
    --    (
    --        select
    --            PhoneNumber
    --        from
    --            entPhone r with(nolock)
    --        where
    --            r.CustomerID = @CustomerID
    --    ) and
    --    ec.CustomerID <> @CustomerID and
    --    PhoneNumber <> '' and
    --    ec.CustomerID not in
    --    (
    --        select
    --            CustomerID
    --        from
    --            @out
    --    )

    return

end

GO
