USE [db-au-workspace]
GO
/****** Object:  UserDefinedFunction [opsupport].[fn_EnterpriseSearchInPeriod]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [opsupport].[fn_EnterpriseSearchInPeriod]
(
    @Period varchar(1024),
    @SpecificDate date
)
returns @out table
(
    CustomerID bigint,
    forceInclude bit
)
as
begin 
    

    declare 
        @start date,
        @end date

    if @SpecificDate is null
        select
            @start = StartDate,
            @end = EndDate
        from
            [db-au-cmdwh].dbo.vDateRange
        where
            DateRange = @Period

    else
        select 
            @start = @SpecificDate,
            @end = @SpecificDate

    select
        @end = 
        case
            when @end = dateadd(day, -1, convert(date, getdate())) then convert(date, getdate())
            else @end
        end

    --consecutive policies
    declare @policy table 
        (
            PolicyKey varchar(50),
            TripStart date,
            TripEnd date,
            CustomerID bigint
        )

    insert into @policy
    (
        PolicyKey,
        TripStart,
        TripEnd,
        CustomerID
    )
    select
        p.PolicyKey,
        TripStart,
        TripEnd,
        CustomerID
    from
        [db-au-cmdwh].dbo.penPolicy p with(nolock)
        cross apply
        (
            select distinct
                ep.CustomerID
            from
                [db-au-cmdwh].dbo.entPolicy ep with(nolock)
            where
                ep.PolicyKey = p.PolicyKey and
                ep.ClaimKey is null
        ) ep
    where
        p.CountryKey in ('AU', 'NZ') and
        p.IssueDate >= @start and
        p.IssueDate <  dateadd(day, 1, @end) and
        p.TripDuration >= 300 and
        isnull(p.TripType, 'Single Trip') <> 'Annual Multi Trip' and
        p.StatusDescription = 'Active'

    --blocked
    insert into @out
    (
        CustomerID,
        forceInclude
    )
    select 
        p.CustomerID,
        1
    from
        @policy p
    where
        --exists
        --(
        --    select
        --        null
        --    from
        --        [db-au-cmdwh].dbo.entPolicy rep with(nolock)
        --        inner join [db-au-cmdwh].dbo.penPolicy r with(nolock) on
        --            r.PolicyKey = rep.PolicyKey
        --    where
        --        rep.CustomerID = p.CustomerID and
        --        rep.PolicyKey <> p.PolicyKey and
        --        r.TripEnd between dateadd(day, -7, p.TripStart) and dateadd(day, 7, p.TripStart) and
        --        isnull(r.TripType, 'Single Trip') <> 'Annual Multi Trip' and
        --        r.StatusDescription = 'Active' and
        --        r.TripDuration >= 300
        --) or
        exists
        (
            select
                null
            from
                [db-au-cmdwh].dbo.entBlacklist eb
            where
                eb.CustomerID = p.CustomerID
        )

    --claims
    declare @claims table
    (
        PolicyKey varchar(50),
        FirstName nvarchar(100),
        Surname nvarchar(100)
    )

    insert into @claims
    (
        PolicyKey,
        FirstName,
        Surname
    )
    select
        pt.PolicyKey,
        cn.Firstname,
        cn.Surname
    from
        [db-au-cmdwh].dbo.clmClaim cl with(nolock)
        inner join [db-au-cmdwh].dbo.clmClaimIncurredMovement cim with(nolock) on
            cim.ClaimKey = cl.ClaimKey
        inner join [db-au-cmdwh].dbo.penPolicyTransSummary pt with(nolock) on
            cl.PolicyTransactionKey = pt.PolicyTransactionKey
        inner join [db-au-cmdwh].dbo.clmName cn with(nolock) on
            cn.ClaimKey = cl.ClaimKey and
            cn.isPrimary = 1
    where
        cl.CountryKey in ('AU', 'NZ') and
        (
            (
                cl.CreateDate >= @start and
                cl.CreateDate <  dateadd(day, 1, @end)
            ) or
            (
                cim.IncurredDate >= @start and
                cim.IncurredDate <  dateadd(day, 1, @end) and
                (
                    cim.EstimateMovement > 0 or
                    cim.PaymentMovement > 0
                )
            )
        )

    insert into @out
    (
        CustomerID,
        forceInclude
    )
    select distinct
        ec.CustomerID,
        0
    from
        @claims cl
        cross apply
        (
            select top 1 
                ec.CustomerID
            from
                [db-au-cmdwh].dbo.entPolicy ep with(nolock)
                inner join [db-au-cmdwh].dbo.entCustomer ec with(nolock) on
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


    ----searched
    --insert into @out
    --(
    --    CustomerID
    --)
    --select distinct
    --    Reference
    --from
    --    [db-au-cmdwh].[dbo].[entActionLog] with(nolock)
    --where
    --    Calls = 'rptsp_EnterpriseTimeline' and
    --    LogTime >= @start and
    --    LogTime <  dateadd(day, 1, @end)

    --insert into @out
    --(
    --    CustomerID
    --)
    --select distinct
    --    json_value(data, '$.CustomerID')
    --from
    --    [bhdwh03].[db-au-opsupport].[dbo].portalLogAction
    --where
    --    Action = 'EV (BETA)' and
    --    ActionTime >= convert(date, getdate()) and
    --    UserName not in
    --    (
    --        'Justin.Hourigan@covermore.com',
    --        'Ryan.Power@covermore.com',
    --        'Dane.Murray@covermore.com',
    --        'Leonardus.Setyabudi@covermore.com'
    --    )


    return

end
GO
