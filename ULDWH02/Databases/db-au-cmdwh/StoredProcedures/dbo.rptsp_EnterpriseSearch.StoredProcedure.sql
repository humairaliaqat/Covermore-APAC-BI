USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_EnterpriseSearch]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_EnterpriseSearch]
    @SearchMethod varchar(30) = '',
    @SearchDate date = null,
    @SearchString varchar(1024) = '',
    @AllowWildCard bit = 0,
    @ResultCount int = 25,
    @Domain varchar(5) = '',
    @LogUser varchar(50) = ''

as
begin

    set nocount on

    set @SearchMethod = rtrim(@SearchMethod)

    if @SearchString <> ''
    begin

        if object_id('entActionLog') is null
        begin
        
            create table entActionLog
            (
                BIRowID bigint not null identity(1,1),
                LogTime datetime,
                UserName varchar(max),
                Calls varchar(max),
                Reference varchar(max)
            )

            create unique clustered index cidx on entActionLog (BIRowID)

        end

        insert into entActionLog
        (
            LogTime,
            UserName,
            Calls,
            Reference
        )
        select
            getdate(),
            @LogUser,
            'search',
            @SearchString

    end

    --initialize result
    if object_id('tempdb..#ids') is not null
        drop table #ids

    create table #ids
    (
        CustomerID bigint,
        forceInclude bit
    )
    
    --search by text
    if @SearchMethod = 'SearchByText'
    begin

        declare 
            @parsed nvarchar(1024),
            @skipTransaction bit,
            @advancedSearch bit

        set @SearchString = lower(replace(@SearchString, char(9), ' '))

        set @parsed = ''
        set @advancedSearch = 0

        if @ResultCount < 1 
            set @ResultCount = 1

        if @ResultCount > 100 
            set @ResultCount = 100

        --set @SearchString = '"' + @SearchString + '"'
    
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

                    set @ResultCount = 1000

                    insert into #ids
                    (
                        CustomerID
                    )
                    select 
                        CustomerID
                    from
                        entBlacklist

                end

                --watchlist
                else if charindex('demo=', @SearchString) > 0 
                begin

                    set @ResultCount = 1000

                    insert into #ids
                    (
                        CustomerID
                    )
                    select 16387490
                    union
                    select 22765
                    union
                    select 99070
                    union
                    select 264082 
                    union
                    select 15305817
                    union
                    select 99409
                    union 
                    select 133421
                    union 
                    select 106255
                    union
                    select 4768143
                    union
                    select 16926
                    union
                    select 15496565
                    union
                    select 4768004

                end

                --watchlist
                else if charindex('watchlist=', @SearchString) > 0 
                begin

                    set @ResultCount = 1000

                    insert into #ids
                    (
                        CustomerID
                    )
                    select 
                        CustomerID
                    from
                        [db-au-workspace]..live_dashboard_watchlist wl
                    where
                        CustomerID not in
                        (
                            select 
                                r.CustomerID
                            from
                                entBlacklist r
                        )

                end

                --search by collection of ids
                else if charindex('ids=', @SearchString) > 0 and ltrim(rtrim(@parsed)) <> ''
                begin

                    insert into #ids
                    (
                        CustomerID
                    )
                    select 
                        try_convert(bigint, Item) ID
                    from
                        dbo.fn_DelimitedSplit8K(@parsed, ' ')

                end


                --search by id
                else if charindex('id=', @SearchString) > 0 and ltrim(rtrim(@parsed)) <> ''
                begin

                    insert into #ids
                    (
                        CustomerID
                    )
                    select 
                        try_convert(bigint, @parsed)

                end

                --search by full name
                else if charindex('name=', @SearchString) > 0 and ltrim(rtrim(@parsed)) <> ''
                begin

                    insert into #ids
                    (
                        CustomerID
                    )
                    select
                        ec.CustomerID
                    from
                        entCustomer ec with(nolock)
                    where
                        ec.CustomerName like replace(@parsed, ' ', '%') + '%'


                    insert into #ids
                    (
                        CustomerID
                    )
                    select
                        ec.CustomerID
                    from
                        entAlias ec with(nolock)
                    where
                        ec.Alias like replace(@parsed, ' ', '%') + '%'

                end

                --search by policy number
                else if charindex('policy=', @SearchString) > 0 and ltrim(rtrim(@parsed)) <> ''
                begin

                    insert into #ids
                    (
                        CustomerID
                    )
                    select
                        ep.CustomerID
                    from
                        entPolicy ep with(nolock) 
                        inner join penPolicyTransSummary pt with(nolock) on
                            pt.PolicyKey = ep.PolicyKey
                    where
                        pt.PolicyNumber = @parsed

                end

                --search by claim number
                else if charindex('claim=', @SearchString) > 0 and ltrim(rtrim(@parsed)) <> ''
                begin

                    insert into #ids
                    (
                        CustomerID
                    )
                    select 
                        ep.CustomerID
                    from
                        entPolicy ep with(nolock)
                        inner join penPolicyTransSummary pt with(nolock) on
                            pt.PolicyKey = ep.PolicyKey
                        inner join clmClaim cl with(nolock) on
                            cl.PolicyTransactionKey = pt.PolicyTransactionKey
                    where
                        cl.ClaimNo = try_convert(int, @parsed)

                    insert into #ids
                    (
                        CustomerID
                    )
                    select
                        ep.CustomerID
                    from
                        entPolicy ep with(nolock)
                        inner join clmClaim cl with(nolock) on
                            cl.ClaimKey = ep.ClaimKey
                    where
                        cl.ClaimNo = try_convert(int, @parsed)

                end

                --search by phone number
                else if charindex('phone=', @SearchString) > 0 and ltrim(rtrim(@parsed)) <> ''
                begin

                    insert into #ids
                    (
                        CustomerID
                    )
                    select
                        ep.CustomerID
                    from
                        entPhone ep with(nolock)
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

                    insert into #ids
                    (
                        CustomerID
                    )
                    select
                        ee.CustomerID
                    from
                        entEmail ee with(nolock)
                    where
                        ee.EmailAddress like replace(replace(@parsed, '@', '%'), '.', '%') + '%'

                end

            end

            else
            begin

                --simple search
                if not @AllowWildCard = 1 
                begin

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

                end

                else
                begin

                    select
                        @parsed = @parsed +
                        case
                            when len(Item) < 3 then Item
                            else '"' + Item + '*"'
                        end +
                        case
                            when ItemNumber = max(ItemNumber) over () then ''
                            else ' and '
                        end
                    from
                        [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SearchString, ' ')
                    where
                        rtrim(Item) <> ''

                end

                insert into #ids
                (
                    CustomerID
                )
                select
                    ec.CustomerID
                from
                    entCustomer ec with(nolock)
                where
                    contains(ec.FTS, @parsed) 

                insert into #ids
                (
                    CustomerID
                )
                select
                    ec.CustomerID
                from
                    entAlias ec with(nolock)
                where
                    ec.Alias like ltrim(rtrim(@SearchString)) + '%'


                if @skipTransaction = 0
                begin

                    insert into #ids
                    (
                        CustomerID
                    )
                    select 
                        ep.CustomerID
                    from
                        entPolicy ep with(nolock)
                    where
                        ep.FTS like @parsed + '%'

                end


            end

        end

    end


    else if @SearchMethod <> ''
    --search by date (highlights)
    begin

        declare 
            @start date,
            @end date

        if @SearchMethod = '_User Defined' 
            select 
                @start = @SearchDate,
                @end = @SearchDate
        else
            select 
                @start = StartDate,
                @end = EndDate
            from
                vDateRange
            where
                DateRange = @SearchMethod

        --consecutive policies & blocked
        if object_id('tempdb..#policy') is not null
            drop table #policy

        select
            p.PolicyKey,
            TripStart,
            TripEnd,
            CustomerID
        into #policy
        from
            penPolicy p with(nolock)
            cross apply
            (
                select distinct
                    ep.CustomerID
                from
                    entPolicy ep with(nolock)
                where
                    ep.PolicyKey = p.PolicyKey and
                    ep.ClaimKey is null
            ) ep
        where
            p.CountryKey in ('AU', 'NZ') and
            (
                @Domain = '' or
                p.CountryKey = @Domain
            ) and
            p.IssueDate >= @start and
            p.IssueDate <  dateadd(day, 1, @end) and
            p.TripDuration >= 300 and
            isnull(p.TripType, 'Single Trip') <> 'Annual Multi Trip' and
            p.StatusDescription = 'Active'

        insert into #ids
        (
            CustomerID,
            forceInclude
        )
        select 
            p.CustomerID,
            1
        from
            #policy p
        where
            exists
            (
                select
                    null
                from
                    entPolicy rep with(nolock)
                    inner join penPolicy r with(nolock) on
                        r.PolicyKey = rep.PolicyKey
                where
                    rep.CustomerID = p.CustomerID and
                    rep.PolicyKey <> p.PolicyKey and
                    r.TripEnd between dateadd(day, -7, p.TripStart) and dateadd(day, 7, p.TripStart) and
                    isnull(r.TripType, 'Single Trip') <> 'Annual Multi Trip' and
                    r.StatusDescription = 'Active' and
                    r.TripDuration >= 300
            ) or
            exists
            (
                select
                    null
                from
                    entBlacklist eb
                where
                    eb.CustomerID = p.CustomerID
            )


        if object_id('tempdb..#claims') is not null
            drop table #claims

        select
            pt.PolicyKey,
            cn.Firstname,
            cn.Surname
        into #claims
        from
            clmClaim cl with(nolock)
            inner join penPolicyTransSummary pt with(nolock) on
                cl.PolicyTransactionKey = pt.PolicyTransactionKey
            inner join clmName cn with(nolock) on
                cn.ClaimKey = cl.ClaimKey and
                cn.isPrimary = 1
        where
            cl.CountryKey in ('AU', 'NZ') and
            (
                @Domain = '' or
                cl.CountryKey = @Domain
            ) and
            cl.CreateDate >= @start and
            cl.CreateDate <  dateadd(day, 1, @end)


        insert into #ids
        (
            CustomerID
        )
        select 
            ec.CustomerID
        from
            #claims cl
            cross apply
            (
                select top 1 
                    ec.CustomerID
                from
                    entPolicy ep with(nolock)
                    inner join entCustomer ec with(nolock) on
                        ec.CustomerID = ep.CustomerID
                where
                    ep.PolicyKey = cl.PolicyKey
                order by
                    case
                        when soundex(cl.[Firstname]) = soundex(ec.CUstomerName) then -2
                        when left(soundex(cl.[Firstname]), 2) = left(soundex(ec.CUstomerName), 2) then -1
                        else ec.CustomerID
                    end
            ) ec

        set @ResultCount = 300

    end

    select top (@ResultCount)
        [CustomerID],
        [MergedTo],
        [CreateDate],
        [UpdateDate],
        [Status],
        [CustomerName],
        [CustomerRole],
        [Title],
        [FirstName],
        [MidName],
        [LastName],
        [Gender],
        [MaritalStatus],
        isnull([DOB], '1900-01-01') [DOB],
        [isDeceased],
        [CurrentAddress],
        [CurrentEmail],
        [CurrentContact],
        ForceFlag * 10000 + isnull(BlockFlag, 0) * 100000 + isnull(ClaimScore, PrimaryScore) [SortID],
        isnull(ClaimScore, PrimaryScore) PrimaryScore,
        SecondaryScore,
        case
            when isnull(BlockScore, 0) > 0 then 'Blocked'
            when ec.ClaimScore >= 3000 then 'Very high risk'
            when ec.ClaimScore >= 500 then 'High risk'
            when ec.ClaimScore >= 10 then 'Medium risk'

            when ec.PrimaryScore >= 5000 then 'Very high risk'
            when ec.SecondaryScore >= 6000 then 'Very high risk by association'
            when ec.PrimaryScore >= 3000 then 'High risk'
            when ec.SecondaryScore >= 4000 then 'High risk by association'
            when ec.PrimaryScore > 1500 then 'Medium risk'
            when ec.SecondaryScore > 2000 then 'Medium risk by association'
            else 'Low Risk'
        end RiskCategory,
        ForceFlag,
        isnull(BlockFlag, 0) BlockFlag,
        ea.Alias
    from
        entCustomer ec with(nolock)
        cross apply
        (
            select
                case
                    when
                        exists
                        (
                            select 
                                null
                            from 
                                #ids r
                            where
                                r.CustomerID = ec.CustomerID and
                                r.forceInclude = 1
                        )
                    then 1
                    else 0
                end ForceFlag
        ) f
        outer apply
        (
            select top 1 
                9001 BlockScore,
                1 BlockFlag
            from
                entBlacklist bl
            where
                bl.CustomerID = ec.CustomerID
        ) bl
        outer apply
        (
            select top 1 
                dbo.fn_ProperCase(ea.Alias) Alias
            from
                entAlias ea with(nolock)
            where
                ea.CustomerID = ec.CustomerID and
                lower(ea.Alias) <> ec.CUstomerName
        ) ea
    where
        @SearchMethod <> '' and
        ec.CustomerID = isnull(ec.MergedTo, ec.CustomerID) and
        (
            @SearchMethod = 'SearchByText' or
            (
                ClaimScore >= 10 or
                (
                    ClaimScore is null and
                    (
                        PrimaryScore > 1000 or
                        SecondaryScore > 1500
                    )
                ) or
                ForceFlag = 1 or
                exists
                (
                    select
                        null
                    from
                        [db-au-workspace]..live_dashboard_watchlist wl
                    where
                        wl.CustomerID = ec.CustomerID
                )
            ) 
        ) and
        ec.CustomerID in 
        (
            select 
                CustomerID 
            from 
                #ids
        )
    order by
        PrimaryScore desc


end
GO
