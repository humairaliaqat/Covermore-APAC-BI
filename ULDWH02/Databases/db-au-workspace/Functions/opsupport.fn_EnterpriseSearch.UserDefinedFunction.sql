USE [db-au-workspace]
GO
/****** Object:  UserDefinedFunction [opsupport].[fn_EnterpriseSearch]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [opsupport].[fn_EnterpriseSearch]
(
    @SearchString varchar(1024)
)
returns @out table
(
    CustomerID bigint,
    forceInclude bit
)
as
begin 

    declare 
        @parsed nvarchar(1024),
        @skipTransaction bit,
        @advancedSearch bit

    set @SearchString = lower(replace(@SearchString, char(9), ' '))

    set @parsed = ''
    set @advancedSearch = 0

    set @skipTransaction = 0

    if patindex('%[a-z ]%', lower(@SearchString)) > 0
        set @skipTransaction = 1

    if charindex('=', @SearchString) > 0 
        set @advancedSearch = 1

    if charindex('@', @SearchString) > 0 and charindex('=', @SearchString) = 0 
    begin

        set @advancedSearch = 1
        set @SearchString = 'email=' + replace(@SearchString, '.', '%')

    end

    if rtrim(@SearchString) <> '' 
    begin

        if @advancedSearch = 1 
        begin

            set @parsed = rtrim(ltrim(substring(@SearchString, charindex('=', @SearchString) + 1, 1024)))

            --blacklist
            if charindex('blacklist=', @SearchString) > 0 
            begin

                insert into @out
                (
                    CustomerID
                )
                select 
                    CustomerID
                from
                    [db-au-cmdwh].dbo.entBlacklist with(nolock)

            end

            --demo
            else if charindex('demo=', @SearchString) > 0 
            begin

                insert into @out
                (
                    CustomerID
                )
                select
                    try_convert(bigint, ltrim(rtrim(Item)))
                    --,
                    --ltrim(rtrim(replace(replace(Item, char(10), ''), char(12), '')))
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K('104589,20301686,16387490,22765,99070,264082,15305817,99409,133421,106255,4768143,16926,15496565,4768004,1032339,72862,1976212,70982,1649168', ',')

            end


            --search by collection of ids
            else if charindex('ids=', @SearchString) > 0 and ltrim(rtrim(@parsed)) <> ''
            begin

                insert into @out
                (
                    CustomerID
                )
                select 
                    try_convert(bigint, Item) ID
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@parsed, ' ')

            end


            --search by id
            else if charindex('id=', @SearchString) > 0 and ltrim(rtrim(@parsed)) <> ''
            begin

                insert into @out
                (
                    CustomerID
                )
                select 
                    try_convert(bigint, @parsed)

            end

            --search by full name
            else if charindex('name=', @SearchString) > 0 and ltrim(rtrim(@parsed)) <> ''
            begin

                insert into @out
                (
                    CustomerID
                )
                select top 30
                    ec.CustomerID
                from
                    [db-au-cmdwh].dbo.entCustomer ec with(nolock)
                where
                    ec.CustomerName like replace(@parsed, ' ', '%') + '%'


                insert into @out
                (
                    CustomerID
                )
                select top 30 
                    ec.CustomerID
                from
                    [db-au-cmdwh].dbo.entAlias ec with(nolock)
                where
                    ec.Alias like replace(@parsed, ' ', '%') + '%'

            end

            --search by policy number
            else if charindex('policy=', @SearchString) > 0 and ltrim(rtrim(@parsed)) <> ''
            begin

                insert into @out
                (
                    CustomerID
                )
                select top 30
                    ep.CustomerID
                from
                    [db-au-cmdwh].dbo.entPolicy ep with(nolock) 
                    inner join [db-au-cmdwh].dbo.penPolicyTransSummary pt with(nolock) on
                        pt.PolicyKey = ep.PolicyKey
                where
                    pt.PolicyNumber = @parsed

            end

            --search by claim number
            else if charindex('claim=', @SearchString) > 0 and ltrim(rtrim(@parsed)) <> ''
            begin

                insert into @out
                (
                    CustomerID
                )
                select top 30
                    ep.CustomerID
                from
                    [db-au-cmdwh].dbo.entPolicy ep with(nolock)
                    inner join [db-au-cmdwh].dbo.penPolicyTransSummary pt with(nolock) on
                        pt.PolicyKey = ep.PolicyKey
                    inner join [db-au-cmdwh].dbo.clmClaim cl with(nolock) on
                        cl.PolicyTransactionKey = pt.PolicyTransactionKey
                where
                    cl.ClaimNo = try_convert(int, @parsed)

                insert into @out
                (
                    CustomerID
                )
                select top 30
                    ep.CustomerID
                from
                    [db-au-cmdwh].dbo.entPolicy ep with(nolock)
                    inner join [db-au-cmdwh].dbo.clmClaim cl with(nolock) on
                        cl.ClaimKey = ep.ClaimKey
                where
                    cl.ClaimNo = try_convert(int, @parsed)

            end

            --search by account
            else if charindex('account=', @SearchString) > 0 and ltrim(rtrim(@parsed)) <> ''
            begin

                insert into @out
                (
                    CustomerID
                )
                select top 30
                    CustomerID
                from
                    [db-au-cmdwh].dbo.entAccounts with(nolock)
                where
                    AccountID like '0%' + ltrim(rtrim(@parsed)) + '%'

            end

            --search by phone number
            else if charindex('phone=', @SearchString) > 0 and ltrim(rtrim(@parsed)) <> ''
            begin

                insert into @out
                (
                    CustomerID
                )
                select top 30
                    ep.CustomerID
                from
                    [db-au-cmdwh].dbo.entPhone ep with(nolock)
                where
                    (
                        ep.PhoneNumber like '61' +
                            case
                                when left(@parsed, 1) = '0' then right(@parsed, len(@parsed) - 1)
                                when left(@parsed, 1) = '+' then right(@parsed, len(@parsed) - 1)
                                when left(@parsed, 2) = '61' then right(@parsed, len(@parsed) - 2)
                                when left(@parsed, 3) = '+61' then right(@parsed, len(@parsed) - 3)
                                else @parsed
                            end + '%'
                    ) or
                    (
                        ep.PhoneNumber like '64' +
                            case
                                when left(@parsed, 1) = '0' then right(@parsed, len(@parsed) - 1)
                                when left(@parsed, 1) = '+' then right(@parsed, len(@parsed) - 1)
                                when left(@parsed, 2) = '64' then right(@parsed, len(@parsed) - 2)
                                when left(@parsed, 3) = '+64' then right(@parsed, len(@parsed) - 3)
                                else @parsed
                            end + '%'
                    )

            end

            --search by email
            else if charindex('email=', @SearchString) > 0 and ltrim(rtrim(@parsed)) <> ''
            begin

                insert into @out
                (
                    CustomerID
                )
                select top 30
                    ee.CustomerID
                from
                    [db-au-cmdwh].dbo.entEmail ee with(nolock)
                where
                    ee.EmailAddress like replace(replace(@parsed, '@', '%'), '.', '%') + '%'

            end

        end

        else
        begin

            --simple search
            select 
                @parsed = @parsed +
                Item + 
                case
                    when ItemNumber = max(ItemNumber) over () then ''
                    else ' and '
                end
            from
                [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SearchString, ' ')
            where
                rtrim(Item) <> ''


            insert into @out
            (
                CustomerID
            )
            select top 30
                ec.CustomerID
            from
                [db-au-cmdwh].dbo.entCustomer ec with(nolock)
            where
                contains(ec.FTS, @parsed) 

            insert into @out
            (
                CustomerID
            )
            select top 30
                ec.CustomerID
            from
                [db-au-cmdwh].dbo.entAlias ec with(nolock)
            where
                ec.Alias like ltrim(rtrim(@SearchString)) + '%'


            if @skipTransaction = 0
            begin

                insert into @out
                (
                    CustomerID
                )
                select 
                    ep.CustomerID
                from
                    [db-au-cmdwh].[dbo].entPolicy ep with(nolock)
                where
                    ep.FTS like @parsed + '%'

            end


        end

    end


    return

end
GO
