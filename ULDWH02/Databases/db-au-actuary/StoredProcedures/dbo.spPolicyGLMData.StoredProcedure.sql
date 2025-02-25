USE [db-au-actuary]
GO
/****** Object:  StoredProcedure [dbo].[spPolicyGLMData]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spPolicyGLMData]
    @DateRange varchar(30) = 'Yesterday-to-now',
    @StartDate date = null,
    @EndDate date = null,
    @BatchMode bit = 0

as
begin

--20161209, LL, data prep for GLM
--20170316, LL, rewrite and optimise, fix business logics, save traveller dobs into separate table

--declare
--    @DateRange varchar(30) = '_User Defined',
--    @StartDate date = '2017-02-01',
--    @EndDate date = '2017-02-28',
--    @BatchMode bit = 1

    set nocount on

    if @DateRange <> '_User Defined'
        select
            @StartDate = StartDate,
            @EndDate = EndDate
        from
            [db-au-cmdwh].dbo.vDateRange
        where
            DateRange = @DateRange

    if object_id('tempdb.dbo.#transaction') is not null
        drop table #transaction

    select 
        PolicyTransactionKey
    into #transaction
    from
        [db-au-cmdwh].dbo.penPolicyTransaction pt
        inner join [db-au-cmdwh].dbo.penPolicy p with(nolock) on
            p.PolicyKey = pt.PolicyKey
    where
        @BatchMode = 1 and
        p.IssueDate >= @StartDate and
        p.IssueDate <  dateadd(day, 1, @EndDate)

    insert into #transaction
    select 
        PolicyTransactionKey
    from
        [db-au-cmdwh].dbo.penPolicyTransaction pt
    where
        @BatchMode = 0 and
        pt.IssueDate >= @StartDate and
        pt.IssueDate <  dateadd(day, 1, @EndDate)

    insert into #transaction
    select 
        PolicyTransactionKey
    from
        [db-au-cmdwh].dbo.penPolicyTransaction pt
    where
        @BatchMode = 0 and
        pt.PaymentDate >= @StartDate and
        pt.PaymentDate <  dateadd(day, 1, @EndDate)

    insert into #transaction
    select 
        PolicyTransactionKey
    from
        [db-au-cmdwh].dbo.penPolicyTransaction pt
    where
        @BatchMode = 0 and
        pt.TransactionDateTime >= @StartDate and
        pt.TransactionDateTime <  dateadd(day, 1, @EndDate)
    

    if object_id('tempdb.dbo.#penPolicyGLM') is not null
        drop table #penPolicyGLM

    select --top 1000
        pt.PolicyKey,
        pt.PolicyTransactionKey,
        pt.IssueDate IssueTime,
        pt.TransactionDateTime PostingTime,
        pt.TransactionType,
        pt.TransactionStatus,
        isnull(pt.TransactionStart, p.TripStart) TransactionStart,
        isnull(pt.TransactionEnd, p.TripEnd) TransactionEnd,
        p.MaxDuration,
        pt.TripCost TripCostString,
        case
            when pt.TripCost like '%unlimited%' then 1000000
            when pt.TripCost like '%null%' then 250000
            when pt.TripCost like '%object%' then 250000
            when pt.TripCost like '%init%' then 250000
            else [db-au-cmdwh].dbo.fn_StrToInt(CleanTripCost)
        end *
        case
            when pt.IssueDate < '2011-10-01' then 1
            when pt.TransactionType = 'Base' and pt.TransactionStatus like 'Cancelled%' then 0
            when pt.TransactionStatus = 'Active' then 1
            when pt.TransactionStatus like 'Cancelled%' then 1
            else 0
        end TripCostDelta,
        p.PrimaryCountry,
        case 
            when isnull(pta.Luggage, 0) > 0 then 1 
            when isnull(pta.Luggage, 0) < 0 then -1
            else 0
        end HasLuggage,
        case 
            when isnull(pta.EMC, 0) > 0 then 1 
            when isnull(pta.EMC, 0) < 0 then -1
            else 0
        end HasEMC,
        case 
            when p.ProductCode in ('FCO', 'FCT') and pt.TransactionType = 'Base' and pt.TransactionStatus = 'Active' then 1
            when p.ProductCode in ('FCO', 'FCT') and pt.TransactionType = 'Base' and pt.TransactionStatus <> 'Active' then -1
            when isnull(pta.Motorcycle, 0) > 0 then 1 
            when isnull(pta.Motorcycle, 0) < 0 then -1
            else 0
        end HasMotorcycle,
        case 
            when p.ProductCode in ('FCO', 'FCT') then 1
            else 0
        end BundledMotorcycle,
        case 
            when isnull(pta.WinterSports, 0) > 0 then 1 
            when isnull(pta.WinterSports, 0) < 0 then -1 
            else 0
        end HasWintersport,
        case 
            when isnull(pta.Cruise, 0) > 0 then 1 
            when isnull(pta.Cruise, 0) < 0 then -1 
            else 0
        end HasCruise,
        ptv.YoungestChargedDOB,
        ptv.OldestChargedDOB,
        ptv.PostCode,
        pt.AutoComments
    into #penPolicyGLM
    from
        [db-au-cmdwh].dbo.penPolicyTransaction pt with(nolock)
        cross apply
        (
            select
                replace
                (
                    replace
                    (
                        replace
                        (
                            ltrim(isnull(pt.TripCost, '')),
                            '.00',
                            ''
                        ),
                        'DA-$',
                        ''
                    ),
                    'D-$',
                    ''
                ) CleanTripCost
        ) tc
        outer apply
        (
            select 
                sum
                (
                    case
                        when pta.AddOnGroup = 'Medical' then pta.GrossPremium
                        else 0
                    end 
                ) EMC,
                sum
                (
                    case
                        when pta.AddOnGroup = 'Luggage' then pta.GrossPremium
                        else 0
                    end 
                ) Luggage,
                sum
                (
                    case
                        when pta.AddOnGroup = 'Winter Sport' then pta.GrossPremium
                        else 0
                    end 
                ) WinterSports,
                sum
                (
                    case
                        when pta.AddOnGroup = 'Motorcycle' then pta.GrossPremium
                        else 0
                    end 
                ) Motorcycle,
                sum
                (
                    case
                        when pta.AddOnGroup = 'Cruise' then pta.GrossPremium
                        else 0
                    end 
                ) Cruise
            from
                [db-au-cmdwh].dbo.penPolicyTransAddOn pta with(nolock)
            where
                pta.PolicyTransactionKey = pt.PolicyTransactionKey
        ) pta
        inner join [db-au-cmdwh].dbo.penPolicy p with(nolock) on
            p.PolicyKey = pt.PolicyKey
        outer apply
        (
            select
                max(convert(date, ptv.DOB)) YoungestChargedDOB,
                min(convert(date, ptv.DOB)) OldestChargedDOB,
                max(ptv.PostCode) PostCode
            from
                [db-au-cmdwh].dbo.penPolicyTraveller ptv with(nolock)
            where
                ptv.PolicyKey = p.PolicyKey and
                ptv.AdultCharge > 0
        ) ptv
    where
        pt.PolicyTransactionKey in
        (
            select
                PolicyTransactionKey
            from
                #transaction
        )

    --select count(*)
    --from
    --    #penPolicyGLM


    if object_id('[db-au-actuary].ws.PolicyTransactionGLM') is null
    begin

        --drop table [db-au-actuary].ws.PolicyTransactionGLM
        create table [db-au-actuary].ws.PolicyTransactionGLM
        (
            [BIRowID] bigint not null identity(1,1),
            [PolicyKey] varchar(41) null,
            [TransactionOrder] int null,
            [PolicyTransactionKey] varchar(41) not null,
            [IssueTime] datetime null,
            [PostingTime] datetime null,
            [TransactionType] varchar(50) null,
            [TransactionStatus] nvarchar(50) null,
            [AutoComments] nvarchar(max) null,
            
            [DepartureDate] date null,
            [ReturnDate] date null,
            [MaxAMTDuration] int null,
            [PrimaryCountry] nvarchar(max) null,
            [PostCode] nvarchar(50) null,

            [Previous_DepartureDate] date null,
            [Previous_ReturnDate] date null,
            [Previous_MaxAMTDuration] int null,
            [Previous_PrimaryCountry] nvarchar(max) null,
            [Previous_PostCode] nvarchar(50) null,

            [YoungestChargedDOB] date null,
            [OldestChargedDOB] date null,

            [HasLuggage] smallint null,
            [HasEMC] smallint null,
            [HasMotorcycle] smallint null,
            [HasWintersport] smallint null,
            [HasCruise] smallint null,
            [TripCostString] varchar(50),
            [TripCostDelta] int null,

            [Running_HasLuggage] smallint null,
            [Running_HasEMC] smallint null,
            [Running_HasMotorcycle] smallint null,
            [Running_HasWintersport] smallint null,
            [Running_HasCruise] smallint null,
            [Running_TripCost] int null,

            [Bundled_Luggage] bit null,
            [Bundled_EMC] bit null,
            [Bundled_Motorcycle] bit null,
            [Bundled_Wintersport] bit null,
            [Bundled_Cruise] bit null
        ) 

        create unique clustered index cidx_penPolicyTransactionGLM on [db-au-actuary].ws.PolicyTransactionGLM(BIRowID)
        create nonclustered index idx_penPolicyTransactionGLM_PolicyTransactionKey on [db-au-actuary].ws.PolicyTransactionGLM(PolicyTransactionKey) 
        create nonclustered index idx_penPolicyTransactionGLM_PolicyKey on [db-au-actuary].ws.PolicyTransactionGLM([PolicyKey],[TransactionOrder]) 
            include 
            (
                [PolicyTransactionKey],
                [TransactionType],
                [TransactionStatus],
                [IssueTime],
                [PostingTime],
                [DepartureDate],
                [ReturnDate],
                [MaxAMTDuration],
                [PrimaryCountry],
                [YoungestChargedDOB],
                [OldestChargedDOB],
                [PostCode],
                [Previous_DepartureDate],
                [Previous_ReturnDate],
                [Previous_MaxAMTDuration],
                [Previous_PrimaryCountry],
                [Previous_PostCode],
                [HasLuggage],
                [HasEMC],
                [HasMotorcycle],
                [HasWintersport],
                [HasCruise],
                [TripCostDelta]
            )
        --create nonclustered index idx_penPolicyTransactionGLM_PolicyKeyTime on [db-au-actuary].ws.PolicyTransactionGLM([PolicyKey],[IssueTime]) 
        --    include 
        --    (
        --        [PolicyTransactionKey],
        --        [TransactionType],
        --        [TransactionStatus]
        --    )

    end

    delete 
    from
        [db-au-actuary].ws.PolicyTransactionGLM
    where
        PolicyTransactionKey in
        (
            select
                PolicyTransactionKey
            from
                #penPolicyGLM
        )

    insert into [db-au-actuary].ws.PolicyTransactionGLM
    (
        [PolicyKey],
        [TransactionOrder],
        [PolicyTransactionKey],
        [IssueTime],
        [PostingTime],
        [TransactionType],
        [TransactionStatus],
        [AutoComments],
            
        [DepartureDate],
        [ReturnDate],
        [MaxAMTDuration],
        [PrimaryCountry],
        [PostCode],

        [Previous_DepartureDate],
        [Previous_ReturnDate],
        [Previous_MaxAMTDuration],
        [Previous_PrimaryCountry],
        [Previous_PostCode],

        [HasLuggage],
        [HasEMC],
        [HasMotorcycle],
        [HasWintersport],
        [HasCruise],
        [TripCostString],
        [TripCostDelta],

        [Running_HasLuggage],
        [Running_HasEMC],
        [Running_HasMotorcycle],
        [Running_HasWintersport],
        [Running_HasCruise],
        [Running_TripCost],

        [Bundled_Luggage],
        [Bundled_EMC],
        [Bundled_Motorcycle],
        [Bundled_Wintersport],
        [Bundled_Cruise]
    )
    --drop table #test

    select --top 1000
        PolicyKey,
        -1 TransactionOrder,
        PolicyTransactionKey,
        IssueTime,
        PostingTime,
        TransactionType,
        TransactionStatus,
        AutoComments,

        TransactionStart DepartureDate,
        TransactionEnd ReturnDate,
        isnull(parsed.MaxAMTDuration, t.MaxDuration) MaxAMTDuration,
        isnull(parsed.Country, t.PrimaryCountry) PrimaryCountry,
        isnull(
            case
                when charindex(';', parsed.PostCode) > 0 then left(parsed.PostCode, charindex(';', parsed.PostCode) - 1)
                else parsed.PostCode
            end,
            t.PostCode
        ) PostCode,

        parsed.Previous_DepartureDate,
        parsed.Previous_ReturnDate,
        parsed.Previous_MaxAMTDuration,
        parsed.Previous_PrimaryCountry,
        parsed.Previous_PostCode,

        HasLuggage,
        HasEMC,
        HasMotorcycle,
        HasWintersport,
        HasCruise,
        TripCostString,
        TripCostDelta,

        0 Running_HasLuggage,
        0 Running_HasEMC,
        0 Running_HasMotorcycle,
        0 Running_HasWintersport,
        0 Running_HasCruise,
        0 Running_TripCostDelta,

        0 Bundled_Luggage,
        0 Bundled_EMC,
        BundledMotorcycle Bundled_Motorcycle,
        0 Bundled_Wintersport,
        0 Bundled_Cruise

    --into #test
    from
        #penPolicyGLM t
        cross apply
        (
            select
                case
                    --Policy dates changed. Depart date was 23/11/2016, now 22/11/2016. Return date was 23/11/2016, now 22/11/2016.
                    when 
                        t.TransactionType = 'Extend' and 
                        charindex('depart date was ', t.AutoComments) > 0 
                    then 
                        patindex('%depart date was [0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]%', t.AutoComments) + len('depart date was') + 1

                end DepartureStringStart,

                case
                    --Policy dates changed. Depart date was 23/11/2016, now 22/11/2016. Return date was 23/11/2016, now 22/11/2016.
                    when 
                        t.TransactionType = 'Extend' and 
                        charindex('Return date was ', t.AutoComments) > 0 
                    then 
                        patindex('%Return date was [0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]%', t.AutoComments) + len('Return date was') + 1

                    --Policy Extended from 31/10/2011 to 12/11/2011
                    when 
                        t.TransactionType = 'Extend' and 
                        charindex('Policy Extended from ', t.AutoComments) > 0 
                    then 
                        patindex('%Policy Extended from [0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]%', t.AutoComments) + len('Policy Extended from') + 1

                    --Partial Refund Issued. Old return date (13/07/2017), new return Date(14/11/2016).
                    --Partial Refund Issued. Old return date (31/08/2017), new return Date(20/10/2016).
                    when 
                        t.TransactionType = 'Partial Refund' and 
                        charindex('Old return date ', t.AutoComments) > 0 
                    then 
                        patindex('%Old return date ([0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]%', t.AutoComments) + len('Old return date (')

                end ReturnStringStart,
                
                case
                    --AMT max trip duration has been changed from 30 days to 45 days
                    when 
                        t.TransactionType = 'Upgrade AMT Max Trip Duration' and 
                        t.AutoComments like '%AMT max trip duration has been changed%' and 
                        t.AutoComments not like '%OldValue%' and 
                        t.AutoComments not like '%NewValue%' 
                    then
                        patindex('%AMT max trip duration has been changed from %', t.AutoComments) + len('AMT max trip duration has been changed from') + 1
                end OldAMTStringStart,

                case
                    --Contact postcode changed from 6007 to 6021.;
                    when 
                        t.TransactionType = 'Edit Traveller Detail' and 
                        t.AutoComments like '%Contact postcode changed%'
                    then
                        patindex('%Contact postcode changed from %', t.AutoComments) + len('Contact postcode changed from') + 1
                end OldPostCodeStringStart,

                case
                    --Destination changed from England to Republic of Ireland.; 
                    when 
                        t.TransactionType = 'Change Country' and 
                        t.AutoComments like '%Destination changed%'
                    then
                        patindex('%Destination changed from %', t.AutoComments) + len('Destination changed from')
                end OldCountryStringStart

        ) r1
        cross apply
        (
            select
                charindex('days to ', t.AutoComments, OldAMTStringStart + 1) + len('days to ') + 1 NewAMTStringStart,
                charindex('to ', t.AutoComments, OldPostCodeStringStart + 1) + len('to ') + 1 NewPostCodeStringStart,
                charindex(' to ', t.AutoComments, OldCountryStringStart + 1) + len(' to ') + 1 NewCountryStringStart
        ) r2
        cross apply
        (
            select
                try_convert(date, substring(t.AutoComments, DepartureStringStart, 10), 103) Previous_DepartureDate,
                try_convert(date, substring(t.AutoComments, ReturnStringStart, 10), 103) Previous_ReturnDate,
                try_convert(int, substring(t.AutoComments, OldAMTStringStart, charindex(' ', t.AutoComments, OldAMTStringStart + 1) - OldAMTStringStart)) Previous_MaxAMTDuration,
                try_convert(int, substring(t.AutoComments, NewAMTStringStart, charindex(' ', t.AutoComments, NewAMTStringStart + 1) - NewAMTStringStart)) MaxAMTDuration,
                case
                    when t.AutoComments like '%Contact postcode changed from  to%' then ''
                    else ltrim(rtrim(substring(t.AutoComments, OldPostCodeStringStart, charindex(' ', t.AutoComments, OldPostCodeStringStart + 1) - OldPostCodeStringStart))) 
                end Previous_PostCode,
                case
                    when t.AutoComments like '%Contact postcode changed from %to .;%' then ''
                    else ltrim(rtrim(substring(t.AutoComments, NewPostCodeStringStart, charindex(';', t.AutoComments, NewPostCodeStringStart + 1) - NewPostCodeStringStart))) 
                end PostCode,
                case
                    when t.AutoComments like '%Destination changed from  to%' then ''
                    else ltrim(rtrim(substring(t.AutoComments, OldCountryStringStart, charindex(' to ', t.AutoComments, OldCountryStringStart + 1) - OldCountryStringStart))) 
                end Previous_PrimaryCountry,
                case
                    when t.AutoComments like '%Destination changed from %to .;%' then ''
                    when t.AutoComments like '%Destination changed from %to %.' then ltrim(rtrim(substring(t.AutoComments, NewCountryStringStart, charindex('.', t.AutoComments, NewCountryStringStart + 1) - NewCountryStringStart))) 
                    else ltrim(rtrim(substring(t.AutoComments, NewCountryStringStart, charindex('.;', t.AutoComments, NewCountryStringStart + 1) - NewCountryStringStart))) 
                end Country
        ) parsed

    --select *
    --from
    --    tempdb.INFORMATION_SCHEMA.columns
    --where
    --    table_name like '#test%'

    --select top 100 *
    --from
    --    #test
    --order by
    --    len(PostCode) desc

    --where
    --    AutoComments like '%Destination changed %.'
    --    PolicyKey = 'AU-CM7-8796312'

    --select *
    --from
    --    #penPolicyGLM
    --where
    --    --AutoComments like '%Contact postcode changed from % to .;%'
    --    --PolicyKey = 'AU-CM7-8796312'


    --transaction order
    if object_id('tempdb.dbo.#TransactionOrder') is not null
        drop table #TransactionOrder

    select --top 100 
        PolicyTransactionKey,
        case
            when TransactionType = 'Base' and TransactionStatus = 'Active' then 0
            else row_number() over (partition by pt.PolicyKey order by pt.IssueTime)
        end TransactionOrder
    into #TransactionOrder
    from
        [db-au-actuary].ws.PolicyTransactionGLM pt
    where
        PolicyKey in
        (
            select 
                PolicyKey
            from
                #penPolicyGLM
        )

    create index i on #TransactionOrder (PolicyTransactionKey) include (TransactionOrder)

    update t
    set
        TransactionOrder =
        (
            select top 1 
                TransactionOrder
            from
                #TransactionOrder r
            where
                r.PolicyTransactionKey = t.PolicyTransactionKey
        )
    from
        [db-au-actuary].ws.PolicyTransactionGLM t
    where
        PolicyKey in
        (
            select 
                PolicyKey
            from
                #penPolicyGLM
        )

    --Trip dates
    -------------------------------------------------------------------------------------------------------------------------------------------

    --select top 10
    --    PolicyKey,
    --    count(distinct DepartureDate)
    --from
    --    [db-au-actuary].ws.PolicyTransactionGLM
    --group by
    --    PolicyKey
    --order by 2 desc

    --select *
    --from
    --    [db-au-actuary].ws.PolicyTransactionGLM
    --where
    --    PolicyKey = 'AU-TIP7-915249'

    --select top 100 *
    --from
    --    [db-au-actuary].ws.PolicyTransactionGLM
    --where
    --    TransactionOrder = 0 and
    --    DepartureDate is null
    
    update t
    set
        DepartureDate = coalesce(nx.Previous_DepartureDate, pv.DepartureDate, t.DepartureDate)
    from
        [db-au-actuary].ws.PolicyTransactionGLM t
        outer apply
        (
            select top 1 
                r.Previous_DepartureDate,
                r.Previous_ReturnDate
            from
                [db-au-actuary].ws.PolicyTransactionGLM r
            where
                r.PolicyKey = t.PolicyKey and
                r.TransactionOrder > t.TransactionOrder and
                r.Previous_DepartureDate is not null
            order by
                r.TransactionOrder
        ) nx
        outer apply
        (
            select top 1 
                r.DepartureDate,
                r.ReturnDate
            from
                [db-au-actuary].ws.PolicyTransactionGLM r
            where
                r.PolicyKey = t.PolicyKey and
                r.TransactionOrder < t.TransactionOrder and
                r.DepartureDate is not null 
            order by
                r.TransactionOrder desc
        ) pv
    where
        PolicyKey in
        (
            select 
                PolicyKey
            from
                #penPolicyGLM
        ) and
        not
        (
            TransactionType in ('Extend', 'Partial Refund') and 
            TransactionStatus = 'Active'
        )

    update t
    set
        ReturnDate = coalesce(nx.Previous_ReturnDate, pv.ReturnDate, t.ReturnDate)
    from
        [db-au-actuary].ws.PolicyTransactionGLM t
        outer apply
        (
            select top 1 
                r.Previous_DepartureDate,
                r.Previous_ReturnDate
            from
                [db-au-actuary].ws.PolicyTransactionGLM r
            where
                r.PolicyKey = t.PolicyKey and
                r.TransactionOrder > t.TransactionOrder and
                r.Previous_ReturnDate is not null
            order by
                r.TransactionOrder
        ) nx
        outer apply
        (
            select top 1 
                r.DepartureDate,
                r.ReturnDate
            from
                [db-au-actuary].ws.PolicyTransactionGLM r
            where
                r.PolicyKey = t.PolicyKey and
                r.TransactionOrder < t.TransactionOrder and
                r.ReturnDate is not null    
            order by
                r.TransactionOrder desc
        ) pv
    where
        PolicyKey in
        (
            select 
                PolicyKey
            from
                #penPolicyGLM
        ) and
        not
        (
            TransactionType in ('Extend', 'Partial Refund') and 
            TransactionStatus = 'Active'
        )

    --AMT
    -------------------------------------------------------------------------------------------------------------------------------------------

    --select top 10
    --    PolicyKey,
    --    count(distinct MaxAMTDuration)
    --from
    --    [db-au-actuary].ws.PolicyTransactionGLM
    --group by
    --    PolicyKey
    --order by 2 desc

    --select *
    --from
    --    [db-au-actuary].ws.PolicyTransactionGLM
    --where
    --    PolicyKey = 'AU-TIP7-926434'
    
    update t
    set
        MaxAMTDuration = coalesce(r.Previous_MaxAMTDuration, t.MaxAMTDuration, 0)
    from
        [db-au-actuary].ws.PolicyTransactionGLM t
        outer apply
        (
            select top 1 
                r.Previous_MaxAMTDuration
            from
                [db-au-actuary].ws.PolicyTransactionGLM r
            where
                r.PolicyKey = t.PolicyKey and
                r.TransactionOrder > t.TransactionOrder and
                r.Previous_MaxAMTDuration is not null
            order by
                r.TransactionOrder
        ) r
    where
        PolicyKey in
        (
            select 
                PolicyKey
            from
                #penPolicyGLM
        )

    update t
    set
        Previous_MaxAMTDuration = coalesce(r.MaxAMTDuration, t.MaxAMTDuration)
    from
        [db-au-actuary].ws.PolicyTransactionGLM t
        outer apply
        (
            select top 1 
                r.MaxAMTDuration
            from
                [db-au-actuary].ws.PolicyTransactionGLM r
            where
                r.PolicyKey = t.PolicyKey and
                r.TransactionOrder < t.TransactionOrder and
                r.MaxAMTDuration is not null
            order by
                r.TransactionOrder desc
        ) r
    where
        PolicyKey in
        (
            select 
                PolicyKey
            from
                #penPolicyGLM
        ) and
        Previous_MaxAMTDuration is null


    --postcode
    -------------------------------------------------------------------------------------------------------------------------------------------
    --select top 10
    --    PolicyKey,
    --    count(distinct PostCode)
    --from
    --    [db-au-actuary].ws.PolicyTransactionGLM
    --group by
    --    PolicyKey
    --order by 2 desc

    --select *
    --from
    --    [db-au-actuary].ws.PolicyTransactionGLM
    --where
    --    PolicyKey = 'AU-CM7-1894888'
        
    update t
    set
        PostCode = coalesce(r.Previous_PostCode, t.PostCode, '')
    from
        [db-au-actuary].ws.PolicyTransactionGLM t
        outer apply
        (
            select top 1 
                r.Previous_PostCode
            from
                [db-au-actuary].ws.PolicyTransactionGLM r
            where
                r.PolicyKey = t.PolicyKey and
                r.TransactionOrder > t.TransactionOrder and
                r.Previous_PostCode is not null
            order by
                r.TransactionOrder
        ) r
    where
        PolicyKey in
        (
            select 
                PolicyKey
            from
                #penPolicyGLM
        )

    update t
    set
        Previous_PostCode = coalesce(r.PostCode, t.PostCode)
    from
        [db-au-actuary].ws.PolicyTransactionGLM t
        outer apply
        (
            select top 1 
                r.PostCode
            from
                [db-au-actuary].ws.PolicyTransactionGLM r
            where
                r.PolicyKey = t.PolicyKey and
                r.TransactionOrder < t.TransactionOrder and
                r.PostCode is not null
            order by
                r.TransactionOrder desc
        ) r
    where
        PolicyKey in
        (
            select 
                PolicyKey
            from
                #penPolicyGLM
        ) and
        Previous_PostCode is null



    --country
    -------------------------------------------------------------------------------------------------------------------------------------------
    --select top 10
    --    PolicyKey,
    --    count(distinct PrimaryCountry)
    --from
    --    [db-au-actuary].ws.PolicyTransactionGLM
    --group by
    --    PolicyKey
    --order by 2 desc

    --select *
    --from
    --    [db-au-actuary].ws.PolicyTransactionGLM
    --where
    --    PolicyKey = 'AU-CM7-1968668'
        
    update t
    set
        PrimaryCountry = coalesce(r.Previous_PrimaryCountry, t.PrimaryCountry, '')
    from
        [db-au-actuary].ws.PolicyTransactionGLM t
        outer apply
        (
            select top 1 
                r.Previous_PrimaryCountry
            from
                [db-au-actuary].ws.PolicyTransactionGLM r
            where
                r.PolicyKey = t.PolicyKey and
                r.TransactionOrder > t.TransactionOrder and
                r.Previous_PrimaryCountry is not null
            order by
                r.TransactionOrder
        ) r
    where
        PolicyKey in
        (
            select 
                PolicyKey
            from
                #penPolicyGLM
        )

    update t
    set
        Previous_PrimaryCountry = coalesce(r.PrimaryCountry, t.PrimaryCountry)
    from
        [db-au-actuary].ws.PolicyTransactionGLM t
        outer apply
        (
            select top 1 
                r.PrimaryCountry
            from
                [db-au-actuary].ws.PolicyTransactionGLM r
            where
                r.PolicyKey = t.PolicyKey and
                r.TransactionOrder < t.TransactionOrder and
                r.PrimaryCountry is not null
            order by
                r.TransactionOrder desc
        ) r
    where
        PolicyKey in
        (
            select 
                PolicyKey
            from
                #penPolicyGLM
        ) and
        Previous_PrimaryCountry is null




    --DOB
    -------------------------------------------------------------------------------------------------------------------------------------------

    if object_id('[db-au-actuary].ws.PolicyTraveller') is null
    begin

        --drop table [db-au-actuary].ws.PolicyTraveller
        create table [db-au-actuary].ws.PolicyTraveller
        (
            [BIRowID] bigint not null identity(1,1),
            [PolicyKey] varchar(41) null,
            [TransactionOrder] int null,
            [PolicyTravellerKey] varchar(41) not null,
            [DOB] date null,
            [AdultCharge] numeric(18,5)
        ) 

        create unique clustered index cidx_PolicyTraveller on [db-au-actuary].ws.PolicyTraveller(BIRowID)
        create nonclustered index idx_PolicyTraveller_PolicyKey on [db-au-actuary].ws.PolicyTraveller([PolicyKey],[TransactionOrder] desc) 
            include 
            (
                [PolicyTravellerKey],
                [DOB],
                [AdultCharge]
            )

    end

    --collect traveller DOBs
    if object_id('tempdb.dbo.#traveller') is not null
        drop table #traveller

    select 
        pt.PolicyKey,
        pt.IssueTime,
        pt.TransactionOrder,
        pt.AutoComments,
        ptv.PolicyTravellerKey,
        ptv.DOB,
        --cast(null as date) Previous_DOB,
        ptv.AdultCharge
    into #traveller
    from
        [db-au-actuary].ws.PolicyTransactionGLM pt with(nolock)
        inner join [db-au-cmdwh].dbo.penPolicyTraveller ptv with(nolock) on
            ptv.PolicyKey = pt.PolicyKey
    where
        pt.PolicyKey in
        (
            select 
                PolicyKey
            from
                #penPolicyGLM
        ) and
        --pt.PolicyKey = 'AU-CM7-1702558' and
        (
            (
                pt.TransactionType = 'Edit Traveller Detail' and
                pt.AutoComments like '%Traveller DOB changed%'
            ) or
            pt.TransactionOrder = 0
        )

    --select *
    --from
    --    #traveller
    --order by
    --    TransactionOrder desc,
    --    PolicyTravellerKey

    create index idx on #traveller (TransactionOrder) include (IssueTime,AutoComments,PolicyTravellerKey,DOB)
    create index idx2 on #traveller (PolicyTravellerKey,TransactionOrder)

    --update transaction with valid dob changes
    --loop ... yay, fun!!1!one!
    declare @reverse int
    declare cloop cursor local for
        select 
            TransactionOrder
        from
            #traveller
        group by
            TransactionOrder
        order by
            TransactionOrder desc

    open cloop

    fetch next from cloop into @reverse

    while @@fetch_status = 0
    begin

        print @reverse

        if object_id('tempdb.dbo.#dobupdater') is not null
            drop table #dobupdater

        select 
            TransactionOrder,
            PolicyTravellerKey,
            DOB,
            ac.FromDOB Previous_DOB
        into #dobupdater
        from
            #traveller tv
            cross apply
            (
                select 
                    dateadd(
                        day, 
                        case
                            when tv.IssueTime < '2012-12-01' then 0 --Penguin's UTC transition
                            else 1
                        end, 
                        try_convert(date, substring(Item, charindex('from ', Item) + 5, 10), 103)
                    ) FromDOB,
                    dateadd(
                        day, 
                        case
                            when tv.IssueTime < '2012-12-01' then 0
                            else 1
                        end, 
                        try_convert(date, substring(Item, charindex(' to ', Item) + 4, 10), 103)
                    ) ToDOB
                from
                    [db-au-stage].dbo.fn_DelimitedSplit8K(AutoComments, ';') ac
                where
                    Item like '%Traveller DOB changed%'
            ) ac
        where
            --tv.TransactionOrder = 2 and
            tv.TransactionOrder = @reverse and
            tv.DOB = ac.ToDOB

        --update t
        --set
        --    t.Previous_DOB = r.Previous_DOB
        --from
        --    #traveller t
        --    inner join #dobupdater r on
        --        r.PolicyTravellerKey = t.PolicyTravellerKey and
        --        r.TransactionOrder = t.TransactionOrder

        update t
        set
            t.DOB = r.Previous_DOB
        from
            #traveller t
            inner join #dobupdater r on
                r.PolicyTravellerKey = t.PolicyTravellerKey and
                t.TransactionOrder < r.TransactionOrder

        --select *
        --from
        --    #dobupdater

        fetch next from cloop into @reverse

    end

    close cloop
    deallocate cloop


    delete 
    from
        [db-au-actuary].ws.PolicyTraveller
    where
        [PolicyKey] in
        (
            select
                PolicyKey
            from
                #penPolicyGLM
        )

    insert into [db-au-actuary].ws.PolicyTraveller
    (
        [PolicyKey],
        [TransactionOrder],
        [PolicyTravellerKey],
        [DOB],
        [AdultCharge]
    ) 
    select
        PolicyKey,
        TransactionOrder,
        PolicyTravellerKey,
        DOB,
        AdultCharge
    from
        #traveller

    --select *
    --from
    --    [db-au-actuary].ws.PolicyTransactionGLM t
    --where
    --    PolicyKey = 'AU-CM7-1702558'


    update t
    set
        OldestChargedDOB = r.OldestChargedDOB,
        YoungestChargedDOB = r.YoungestChargedDOB
    from
        [db-au-actuary].ws.PolicyTransactionGLM t
        outer apply
        (
            select top 1 
                min(r.DOB) OldestChargedDOB,
                max(r.DOB) YoungestChargedDOB
            from
                [db-au-actuary].ws.PolicyTraveller r
            where
                r.PolicyKey = t.PolicyKey and
                r.AdultCharge <> 0 and
                r.TransactionOrder <= t.TransactionOrder 
            group by
                TransactionOrder
            order by
                r.TransactionOrder desc
        ) r
    where
        PolicyKey in
        (
            select 
                PolicyKey
            from
                #penPolicyGLM rr
        )        

    update t
    set
        t.Running_HasLuggage =
            case
                when isnull(r.HasLuggage, 0) < 0 then -1
                when isnull(r.HasLuggage, 0) > 0 then 1
                else 0
            end,
        t.Running_HasEMC =
            case
                when isnull(r.HasEMC, 0) < 0 then -1
                when isnull(r.HasEMC, 0) > 0 then 1
                else 0
            end,
        t.Running_HasMotorcycle =
            case
                when isnull(r.HasMotorcycle, 0) < 0 then -1
                when isnull(r.HasMotorcycle, 0) > 0 then 1
                else 0
            end,
        t.Running_HasWintersport =
            case
                when isnull(r.HasWintersport, 0) < 0 then -1
                when isnull(r.HasWintersport, 0) > 0 then 1
                else 0
            end,
        t.Running_HasCruise =
            case
                when isnull(r.HasCruise, 0) < 0 then -1
                when isnull(r.HasCruise, 0) > 0 then 1
                else 0
            end
    from
        [db-au-actuary].ws.PolicyTransactionGLM t
        cross apply
        (
            select 
                sum(isnull(r.HasLuggage, 0)) HasLuggage,
                sum(isnull(r.HasEMC, 0)) HasEMC,
                sum(isnull(r.HasMotorcycle, 0)) HasMotorcycle,
                sum(isnull(r.HasWintersport, 0)) HasWintersport,
                sum(isnull(r.HasCruise, 0)) HasCruise
            from
                [db-au-actuary].ws.PolicyTransactionGLM r
            where
                r.PolicyKey = t.PolicyKey and
                r.TransactionOrder <= t.TransactionOrder
        ) r
    where
        PolicyKey in
        (
            select 
                PolicyKey
            from
                #penPolicyGLM rr
        )        

end


--declare 
--    @start date,
--    @end date,
--    @err varchar(max)

--set @start = '2012-01-01'

--while @start < '2017-04-01'
--begin

--    set @end = dateadd(day, -1, dateadd(month, 1, @start))

--    exec [db-au-stage].dbo.etlsp_cmdwh_penPolicyTransactionGLM
--        @DateRange = '_User Defined',
--        @StartDate = @start,
--        @EndDate = @end,
--        @BatchMode = 1

--    set @err = convert(varchar(10), @start, 120) + char(9) + convert(varchar, getdate(), 120)

--    raiserror(@err, 1, 1) with nowait

--    set @start = dateadd(month, 1, @start)

--end
GO
