USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_cdgQuote]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[etlsp_cmdwh_cdgQuote]
as
begin
/*
    20141013, LS,   create
    20141020, LS,   handle policy key where it's not available in penguin's data but marked as converted in cdg data
    20141021, LS,   remove cdgQuote -> penQuote translation, this should go into penQuoteSummary instead
    20150106, LS,   store dimensions and lookup into it
                    add deleted flag
    20160118, LS,   add Impulse 2.0 data
                    as the data storage impact would be massive if we combine Impulse & Impulse 2.0 as of now I've opted to separate it
                    the culprit: ids in Impulse2 are varchar(8190)

                    e.g. CampaignSessionID, bigint (8 bytes) -> varchar (30 bytes; current max length + null termination + buffer) = +22 bytes / record
                    current record count = +350,000,000
                    extra storage needed = 350,000,000 * 22 = 7,700,000,000 ~ 7GB * 6 columns ~ 42GB waste of space and porrer index performance
    20160404, LS,   fix missing isPrimaryTraveller on Impulse 2
    20160420, LS,   add Helloworld Integration & Medibank to Impulse 2
    20160601, LS,   add to Impulse 2
                    60, --Westpac-NZ
                    61, --FC-KTTW
                    66, --Aunt-Betty-WL
                    67, --Aunt-Betty-INT
                    71  --Volo
    20160624, LL,   add to Impulse 2
                    52, --FCAU-WL
    20160831, LL,   add
                    72, --HIF
                    73, --Princess-Cruises
                    74, --BYOJET2
                    75, --AHM
	20170526, VL,   add business unit
					76, --BYOJET-AU-WL
					77, --BYOJET-UK-WL
					78, --CM-UK-2
					79, --ImpulseV2-Sample-WL-NZ
					80, --HKE-WL
					81, --Virgil
					82, --PO-NZ-Int
					83, --PO-AU-Int
					84, --Helloworld-B2B
					85, --HKE-Japan
					86, --CMNZ2
					87, --FMG-NZ-WL
					88, --Coles-B2B
					89, --Coles-INT
					90, --IAL-NRMA2
					91, --MAMY2
					92, --MAAU2
					93, --Globenet
					94 --MASG2
	20180109, VL,	add business unit
					5,	--CMNZ
					11,	--FCNZ
					26,	--AirNZ-NZ-WL
					27	--AirNZ-NZ-INT
	20180124, RL,	update Channel soured from BusinessUnit, as Channel is no longer exist in the new Innate DW and cdgChannel is no longer updated
	20180214, RL,	add business unit
					64,	--Impulsev2-Sample
					97	--BYOJET-UK-INT
	20180226, RL,	rearrange business unit ids

*/

    set nocount on

    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int,
        @sql varchar(max)

    declare @mergeoutput table (MergeAction varchar(20))

    exec syssp_getrunningbatch
        @SubjectArea = 'CDG Quote',
        @BatchID = @batchid out,
        @StartDate = @start out,
        @EndDate = @end out

    select
        @name = object_name(@@procid)

    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'

    if object_id('[db-au-cmdwh].dbo.cdgQuote') is null
    begin

        create table [db-au-cmdwh].dbo.cdgQuote
        (
            [BIRowID] bigint not null identity(1,1),
            [AnalyticsSessionID] bigint not null,
            [TransactionTime] datetime null,
            [CampaignID] int null,
            [Campaign] nvarchar(255) null,
            [CampaignSessionID] bigint null,
            [BusinessUnitID] int null,
            [Domain] nvarchar(255) null,
            [BusinessUnit] nvarchar(255) null,
            [ChannelID] int null,
            [Channel] nvarchar(255) null,
            [Currency] nvarchar(3) null,
            [TravellerID] bigint null,
            [ImpressionID] bigint null,
            [TransactionType] nvarchar(1) null,
            [PathType] nvarchar(1) null,
            [ConstructID] int null,
            [Construct] nvarchar(255) null,
            [OfferID] int null,
            [Offer] nvarchar(255) null,
            [ProductID] int null,
            [Product] nvarchar(100) null,
            [ProductCode] nvarchar(255) null,
            [PlanCode] nvarchar(255) null,
            [StartDate] datetime null,
            [EndDate] datetime null,
            [RegionID] int null,
            [Region] nvarchar(4000) null,
            [DestinationType] nvarchar(1) null,
            [DestinationCountryID] int null,
            [DestinationCountryCode] nvarchar(3) null,
            [DestinationCountry] nvarchar(50) null,
            [TripType] nvarchar(1) null,
            [IsSessionClosed] bit null,
            [IsOfferPurchased] bit null,
            [PoliciesPerTrip] int null,
            [PolicyCurrency] nvarchar(3) null,
            [GrossIncludingTax] numeric(19, 5) null,
            [GrossExcludingTax] numeric(19, 5) null,
            [NumAdults] int null,
            [NumChildren] int null,
            [TravellerAge] int null,
            [IsAdult] bit null,
            [TravellerGender] nvarchar(1) null,
            [IsPrimaryTraveller] bit null,
            [AlphaCode] nvarchar(20) null,
            [PolicyNumber] int null,
            [PolicyID] int null,
            [TripCost] numeric(8, 2) null,
            [CreateBatchID] int null,
            [UpdateBatchID] int null,
            [isDeleted] bit not null default 0 
        )
        
        create clustered index idx_cdgQuote_BIRowID on [db-au-cmdwh].dbo.cdgQuote(BIRowID)
        create nonclustered index idx_cdgQuote_AnalyticsSessionID on [db-au-cmdwh].dbo.cdgQuote(AnalyticsSessionID) include(BIRowID,IsPrimaryTraveller,NumChildren,NumAdults,GrossIncludingTax)
        create nonclustered index idx_cdgQuote_TransactionTime on [db-au-cmdwh].dbo.cdgQuote(TransactionTime) include(BIRowID,Currency,Region,DestinationCountry,PathType,ProductID,ProductCode,Product,PlanCode,StartDate,EndDate,NumChildren,IsPrimaryTraveller,NumAdults,GrossIncludingTax,CampaignSessionID,ImpressionID,PolicyID,TravellerAge,Domain,BusinessUnit,Channel)
        create nonclustered index idx_cdgQuote_AlphaMap on [db-au-cmdwh].dbo.cdgQuote(Domain,BusinessUnit,Channel) include(TransactionTime)
		create nonclustered index idx_cdgQuote_TransactionTime_IsDeleted on [db-au-cmdwh].dbo.cdgQuote (TransactionTime,isDeleted)

    end

    if object_id('etl_cdgQuote') is not null
        drop table etl_cdgQuote

    select 
        AnalyticsSessionID,
        TransactionTime,
        CampaignID,
        Campaign,
        CampaignSessionID,
        BusinessUnitID,
        Domain,
        BusinessUnit,
        ChannelID,
        Channel,
        Currency,
        TravellerID,
        ImpressionID,
        TransactionType,
        PathType,
        ConstructID,
        Construct,
        OfferID,
        Offer,
        ProductID,
        Product,
        ProductCode,
        PlanCode,
        StartDate,
        EndDate,
        RegionID,
        Region,
        DestinationType,
        DestinationCountryID,
        DestinationCountryCode,
        DestinationCountry,
        TripType,
        IsSessionClosed,
        IsOfferPurchased,
        PoliciesPerTrip,
        PolicyCurrency,
        GrossIncludingTax,
        GrossExcludingTax,
        NumAdults,
        NumChildren,
        TravellerAge,
        IsAdult,
        TravellerGender,
        IsPrimaryTraveller,
        AlphaCode collate database_default AlphaCode,
        pt.PolicyNumber,
        PolicyID,
        TripCost
    into etl_cdgQuote
    from
        cdg_AnalyticsSessions2_AU a
        outer apply
        (
            select top 1
                bu.BusinessUnit,
                bu.Domain
            from
                [db-au-cmdwh]..cdgBusinessUnit bu
            where
                bu.BusinessUnitId = a.BusinessUnitID
        ) bu
        outer apply
        (
            select top 1
                c.Campaign
            from
                [db-au-cmdwh]..cdgCampaign c
            where
                c.CampaignId = a.CampaignID
        ) c
        outer apply
        (
            select top 1
                ch.Channel,
                ch.Currency
            from
                [db-au-cmdwh]..cdgChannel ch
            where
                ch.ChannelId = a.ChannelID
        ) ch
        outer apply
        (
            select top 1
                ct.Construct
            from
                [db-au-cmdwh]..cdgConstruct ct
            where
                ct.ConstructId = a.ConstructID
        ) ct
        outer apply
        (
            select top 1
                cn.DestinationCountryCode,
                cn.DestinationCountry
            from
                [db-au-cmdwh]..cdgDestination cn
            where
                cn.DestinationCountryID = a.DestinationCountryID
        ) cn
        outer apply
        (
            select top 1
                o.Offer
            from
                [db-au-cmdwh]..cdgOffer o
            where
                o.OfferId = a.OfferID
        ) o
        outer apply
        (
            select top 1
                p.Product,
                p.ProductCode,
                p.PlanCode
            from
                [db-au-cmdwh]..cdgProduct p
            where
                p.ProductId = a.ProductID
        ) p
        outer apply
        (
            select top 1
                r.Region
            from
                [db-au-cmdwh]..cdgRegion r
            where
                r.RegionId = a.RegionID
        ) r
        outer apply
        (
            select top 1 
                PolicyNumber
            from
                cdg_Policy_AU pt
            where
                pt.PolicyId = a.PolicyID
        ) pt


    set @sourcecount = @@rowcount

    begin transaction

    begin try

        merge into [db-au-cmdwh].dbo.cdgQuote with(tablock) t
        using etl_cdgQuote s on
            s.AnalyticsSessionID = t.AnalyticsSessionID

        when matched then

            update
            set
                TransactionTime = s.TransactionTime,
                CampaignID = s.CampaignID,
                Campaign = s.Campaign,
                CampaignSessionID = s.CampaignSessionID,
                BusinessUnitID = s.BusinessUnitID,
                Domain = s.Domain,
                BusinessUnit = s.BusinessUnit,
                ChannelID = s.ChannelID,
                Channel = s.BusinessUnit,
                Currency = s.Currency,
                TravellerID = s.TravellerID,
                ImpressionID = s.ImpressionID,
                TransactionType = s.TransactionType,
                PathType = s.PathType,
                ConstructID = s.ConstructID,
                Construct = s.Construct,
                OfferID = s.OfferID,
                Offer = s.Offer,
                ProductID = s.ProductID,
                Product = s.Product,
                ProductCode = s.ProductCode,
                PlanCode = s.PlanCode,
                StartDate = s.StartDate,
                EndDate = s.EndDate,
                RegionID = s.RegionID,
                Region = s.Region,
                DestinationType = s.DestinationType,
                DestinationCountryID = s.DestinationCountryID,
                DestinationCountryCode = s.DestinationCountryCode,
                DestinationCountry = s.DestinationCountry,
                TripType = s.TripType,
                IsSessionClosed = s.IsSessionClosed,
                IsOfferPurchased = s.IsOfferPurchased,
                PoliciesPerTrip = s.PoliciesPerTrip,
                PolicyCurrency = s.PolicyCurrency,
                GrossIncludingTax = s.GrossIncludingTax,
                GrossExcludingTax = s.GrossExcludingTax,
                NumAdults = s.NumAdults,
                NumChildren = s.NumChildren,
                TravellerAge = s.TravellerAge,
                IsAdult = s.IsAdult,
                TravellerGender = s.TravellerGender,
                IsPrimaryTraveller = s.IsPrimaryTraveller,
                AlphaCode = s.AlphaCode,
                PolicyNumber = s.PolicyNumber,
                PolicyID = s.PolicyID,
                TripCost = s.TripCost,
                isDeleted = 0,
                UpdateBatchID = @batchid

        when not matched by target then
            insert
            (
                AnalyticsSessionID,
                TransactionTime,
                CampaignID,
                Campaign,
                CampaignSessionID,
                BusinessUnitID,
                Domain,
                BusinessUnit,
                ChannelID,
                Channel,
                Currency,
                TravellerID,
                ImpressionID,
                TransactionType,
                PathType,
                ConstructID,
                Construct,
                OfferID,
                Offer,
                ProductID,
                Product,
                ProductCode,
                PlanCode,
                StartDate,
                EndDate,
                RegionID,
                Region,
                DestinationType,
                DestinationCountryID,
                DestinationCountryCode,
                DestinationCountry,
                TripType,
                IsSessionClosed,
                IsOfferPurchased,
                PoliciesPerTrip,
                PolicyCurrency,
                GrossIncludingTax,
                GrossExcludingTax,
                NumAdults,
                NumChildren,
                TravellerAge,
                IsAdult,
                TravellerGender,
                IsPrimaryTraveller,
                AlphaCode,
                PolicyNumber,
                PolicyID,
                TripCost,
                CreateBatchID
            )
            values
            (
                s.AnalyticsSessionID,
                s.TransactionTime,
                s.CampaignID,
                s.Campaign,
                s.CampaignSessionID,
                s.BusinessUnitID,
                s.Domain,
                s.BusinessUnit,
                s.ChannelID,
                s.Channel,
                s.Currency,
                s.TravellerID,
                s.ImpressionID,
                s.TransactionType,
                s.PathType,
                s.ConstructID,
                s.Construct,
                s.OfferID,
                s.Offer,
                s.ProductID,
                s.Product,
                s.ProductCode,
                s.PlanCode,
                s.StartDate,
                s.EndDate,
                s.RegionID,
                s.Region,
                s.DestinationType,
                s.DestinationCountryID,
                s.DestinationCountryCode,
                s.DestinationCountry,
                s.TripType,
                s.IsSessionClosed,
                s.IsOfferPurchased,
                s.PoliciesPerTrip,
                s.PolicyCurrency,
                s.GrossIncludingTax,
                s.GrossExcludingTax,
                s.NumAdults,
                s.NumChildren,
                s.TravellerAge,
                s.IsAdult,
                s.TravellerGender,
                s.IsPrimaryTraveller,
                s.AlphaCode,
                s.PolicyNumber,
                s.PolicyID,
                s.TripCost,
                @batchid
            )

        when 
            not matched by source and
            t.isDeleted = 0 and
            t.TransactionTime >= @start and
            t.TransactionTime <  dateadd(day, 1, @end)
        then
            update
            set
                isDeleted = 1,
                UpdateBatchID = @batchid

        output $action into @mergeoutput
        ;

        select
            @insertcount =
                sum(
                    case
                        when MergeAction = 'insert' then 1
                        else 0
                    end
                ),
            @updatecount =
                sum(
                    case
                        when MergeAction = 'update' then 1
                        else 0
                    end
                )
        from
            @mergeoutput

        exec syssp_genericerrorhandler
            @LogToTable = 1,
            @ErrorCode = '0',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Finished',
            @LogSourceCount = @sourcecount,
            @LogInsertCount = @insertcount,
            @LogUpdateCount = @updatecount

    end try

    begin catch

        if @@trancount > 0
            rollback transaction

        exec syssp_genericerrorhandler
            @SourceInfo = 'cdgQuote data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction



/* 20180314 - LT - exclude Impulse2 Version1 temporary due to table definition change from Innate.

    --Impulse 2.0

    if object_id('[db-au-cmdwh].dbo.cdgQuote_Impulse2') is null
    begin

        create table [db-au-cmdwh].dbo.cdgQuote_Impulse2
        (
            [BIRowID] bigint not null identity(1,1),
            [AnalyticsSessionID] bigint not null,
            [TransactionTime] datetime null,
            [CampaignID] varchar(max),
            [Campaign] nvarchar(255) null,
            [CampaignSessionID] varchar(255),
            [BusinessUnitID] int null,
            [Domain] nvarchar(255) null,
            [BusinessUnit] nvarchar(255) null,
            [ChannelID] int null,
            [Channel] nvarchar(255) null,
            [Currency] nvarchar(3) null,
            [TravellerID] varchar(max),
            [ImpressionID] varchar(max),
            [TransactionType] nvarchar(1) null,
            [PathType] nvarchar(1) null,
            [ConstructID] int null,
            [Construct] nvarchar(255) null,
            [OfferID] int null,
            [Offer] nvarchar(255) null,
            [ProductID] int null,
            [Product] nvarchar(100) null,
            [ProductCode] nvarchar(255) null,
            [PlanCode] nvarchar(255) null,
            [StartDate] datetime null,
            [EndDate] datetime null,
            [RegionID] int null,
            [Region] nvarchar(4000) null,
            [DestinationType] nvarchar(1) null,
            [DestinationCountryID] int null,
            [DestinationCountryCode] nvarchar(3) null,
            [DestinationCountry] nvarchar(50) null,
            [TripType] nvarchar(1) null,
            [IsSessionClosed] bit null,
            [IsOfferPurchased] bit null,
            [PoliciesPerTrip] int null,
            [PolicyCurrency] nvarchar(3) null,
            [GrossIncludingTax] numeric(19, 5) null,
            [GrossExcludingTax] numeric(19, 5) null,
            [NumAdults] int null,
            [NumChildren] int null,
            [TravellerAge] int null,
            [IsAdult] bit null,
            [TravellerGender] nvarchar(1) null,
            [IsPrimaryTraveller] bit null,
            [AlphaCode] nvarchar(20) null,
            [PolicyNumber] varchar(max) null,
            [PolicyID] varchar(max) null,
            [TripCost] numeric(8, 2) null,
            [DepartureAirport] nvarchar(max),
            [DestinationAirport] nvarchar(max),
            [CreateBatchID] int null,
            [UpdateBatchID] int null,
            [isDeleted] bit not null default 0 
        )
        
        create clustered index idx_cdgQuote_BIRowID on [db-au-cmdwh].dbo.cdgQuote_Impulse2(BIRowID)
        create nonclustered index idx_cdgQuote_AnalyticsSessionID on [db-au-cmdwh].dbo.cdgQuote_Impulse2(AnalyticsSessionID) include(BIRowID,IsPrimaryTraveller,NumChildren,NumAdults,GrossIncludingTax)
        create nonclustered index idx_cdgQuote_TransactionTime on [db-au-cmdwh].dbo.cdgQuote_Impulse2(TransactionTime) include(BIRowID,Currency,Region,DestinationCountry,PathType,ProductID,ProductCode,Product,PlanCode,StartDate,EndDate,NumChildren,IsPrimaryTraveller,NumAdults,GrossIncludingTax,CampaignSessionID,ImpressionID,PolicyID,TravellerAge,Domain,BusinessUnit,Channel)
        create nonclustered index idx_cdgQuote_AlphaMap on [db-au-cmdwh].dbo.cdgQuote_Impulse2(Domain,BusinessUnit,Channel) include(TransactionTime)
        create nonclustered index idx_cdgQuote_CampaignSessionID on [db-au-cmdwh].dbo.cdgQuote_Impulse2(CampaignSessionID,IsPrimaryTraveller) include(TravellerID)
		create nonclustered index idx_cdgQuote_TransactionTime_IsDeleted on [db-au-cmdwh].dbo.cdgQuote_Impulse2 (TransactionTime,isDeleted)

    end


	if object_id('[db-au-stage].dbo.cdg_AnalyticsSessions2_AU2') is not null
            drop table [db-au-stage].dbo.cdg_AnalyticsSessions2_AU2;

    set @sql =
        'select *
        into [db-au-stage].dbo.cdg_AnalyticsSessions2_AU2
        from
            openquery
            (
                CDGQUOTE2,
                ''
                select 
                    *
                from
                    public.analytics_sessions
                where
                    transaction_time >= ''''' + convert(varchar(20), @start, 120) + ''''' and
                    transaction_time <  ''''' + convert(varchar(20), dateadd(day, 1, @end), 120) + ''''' and
                    business_unit_id in
                    (
                        --business units that have moved to Impulse 2.0 platform
                        -- AU
						20, --Australia Post
                        32, --Medibank
                        52, --FCAU-WL
                        53, --Virgin AU White Label
                        54, --Virgin AU Integrated
                        59, --CM Australia
                        61, --FC-KTTW
                        62, --Helloworld Integration
						64,	--Impulsev2-Sample
                        66, --Aunt-Betty-WL
                        67, --Aunt-Betty-INT
                        72, --HIF
                        74, --BYOJET2
                        75,  --AHM
						76, --BYOJET-AU-WL
						81, --Virgil
						83, --PO-AU-Int
						84, --Helloworld-B2B
						88, --Coles-B2B
						89, --Coles-INT
						90, --IAL-NRMA2
						92, --MAAU2
						93, --Globenet
						-- NZ
						5,	--CMNZ
						11,	--FCNZ
						26,	--AirNZ-NZ-WL
						27,	--AirNZ-NZ-INT
						45,
						46,
                        56, --Virgin NZ White Label
                        57, --Virgin NZ Integrated
                        60, --Westpac-NZ
                        71, --Volo
                        73, --Princess-Cruises
						79, --ImpulseV2-Sample-WL-NZ
						82, --PO-NZ-Int
						86, --CMNZ2
						87, --FMG-NZ-WL
						-- UK
						77, --BYOJET-UK-WL
						78, --CM-UK-2
						97,	--BYOJET-UK-INT
						-- MY
						7,
						91, --MAMY2
						-- US
						42,
						43,
						100,
						-- Other
						80, --HKE-WL
						85, --HKE-Japan
						94 --MASG2
                    )
                ''
            ) t
        '

    exec(@sql)


    if object_id('[db-au-stage].dbo.etl_cdgQuote_Impulse2') is not null
        drop table [db-au-stage].dbo.etl_cdgQuote_Impulse2

    select 
        id AnalyticsSessionID,
        transaction_time TransactionTime,
        campaign_id CampaignID,
        Campaign,
        campaign_session_id CampaignSessionID,
        business_unit_id BusinessUnitID,
        Domain,
        BusinessUnit,
        channel_id ChannelID,
        Channel,
        Currency,
        traveller_id TravellerID,
        impression_id ImpressionID,
        null TransactionType,
        null PathType,
        construct_id ConstructID,
        Construct,
        offer_id OfferID,
        Offer,
        product_id ProductID,
        Product,
        ProductCode,
        PlanCode,
        [start_date] StartDate,
        end_date EndDate,
        region_id RegionID,
        Region,
        destination_type DestinationType,
        destination_country_id DestinationCountryID,
        DestinationCountryCode,
        DestinationCountry,
        trip_type TripType,
        is_session_closed IsSessionClosed,
        is_offer_purchased IsOfferPurchased,
        policies_per_trip PoliciesPerTrip,
        policy_currency PolicyCurrency,
        gross_including_tax GrossIncludingTax,
        gross_excluding_tax GrossExcludingTax,
        num_adults NumAdults,
        num_children NumChildren,
        traveller_age TravellerAge,
        is_adult IsAdult,
        traveller_gender TravellerGender,
        is_primary_traveller IsPrimaryTraveller,
        alpha_code collate database_default AlphaCode,
        policy_number PolicyNumber,
        policy_id PolicyID,
        trip_cost TripCost,
        departure_airport_code DepartureAirport,
        destination_airport_code DestinationAirport
    into [db-au-stage].dbo.etl_cdgQuote_Impulse2
    from
        [db-au-stage].dbo.cdg_AnalyticsSessions2_AU2 a
        outer apply
        (
            select top 1
                bu.BusinessUnit,
                bu.Domain
            from
                [db-au-cmdwh]..cdgBusinessUnit bu
            where
                bu.BusinessUnitId = a.business_unit_id
        ) bu
        outer apply
        (
            select top 1
                c.Campaign
            from
                [db-au-cmdwh]..cdgCampaign c
            where
                c.CampaignId = a.campaign_id
        ) c
        outer apply
        (
            select top 1
                ch.Channel,
                ch.Currency
            from
                [db-au-cmdwh]..cdgChannel ch
            where
                ch.ChannelId = a.channel_id
        ) ch
        outer apply
        (
            select top 1
                ct.Construct
            from
                [db-au-cmdwh]..cdgConstruct ct
            where
                ct.ConstructId = a.construct_id
        ) ct
        outer apply
        (
            select top 1
                cn.DestinationCountryCode,
                cn.DestinationCountry
            from
                [db-au-cmdwh]..cdgDestination cn
            where
                cn.DestinationCountryID = a.destination_country_id
        ) cn
        outer apply
        (
            select top 1
                o.Offer
            from
                [db-au-cmdwh]..cdgOffer o
            where
                o.OfferId = a.offer_id
        ) o
        outer apply
        (
            select top 1
                p.Product,
                p.ProductCode,
                p.PlanCode
            from
                [db-au-cmdwh]..cdgProduct p
            where
                p.ProductId = a.product_id
        ) p
        outer apply
        (
            select top 1
                r.Region
            from
                [db-au-cmdwh]..cdgRegion r
            where
                r.RegionId = a.region_id
        ) r


    set @sourcecount = @@rowcount

    begin transaction

    begin try

        merge into [db-au-cmdwh].dbo.cdgQuote_Impulse2 with(tablock) t
        using [db-au-stage].dbo.etl_cdgQuote_Impulse2 s on
            s.AnalyticsSessionID = t.AnalyticsSessionID

        when matched then

            update
            set
                TransactionTime = s.TransactionTime,
                CampaignID = s.CampaignID,
                Campaign = s.Campaign,
                CampaignSessionID = s.CampaignSessionID,
                BusinessUnitID = s.BusinessUnitID,
                Domain = s.Domain,
                BusinessUnit = s.BusinessUnit,
                ChannelID = s.ChannelID,
                Channel = s.BusinessUnit,
                Currency = s.Currency,
                TravellerID = s.TravellerID,
                ImpressionID = s.ImpressionID,
                TransactionType = s.TransactionType,
                PathType = s.PathType,
                ConstructID = s.ConstructID,
                Construct = s.Construct,
                OfferID = s.OfferID,
                Offer = s.Offer,
                ProductID = s.ProductID,
                Product = s.Product,
                ProductCode = s.ProductCode,
                PlanCode = s.PlanCode,
                StartDate = s.StartDate,
                EndDate = s.EndDate,
                RegionID = s.RegionID,
                Region = s.Region,
                DestinationType = s.DestinationType,
                DestinationCountryID = s.DestinationCountryID,
                DestinationCountryCode = s.DestinationCountryCode,
                DestinationCountry = s.DestinationCountry,
                TripType = s.TripType,
                IsSessionClosed = s.IsSessionClosed,
                IsOfferPurchased = s.IsOfferPurchased,
                PoliciesPerTrip = s.PoliciesPerTrip,
                PolicyCurrency = s.PolicyCurrency,
                GrossIncludingTax = s.GrossIncludingTax,
                GrossExcludingTax = s.GrossExcludingTax,
                NumAdults = s.NumAdults,
                NumChildren = s.NumChildren,
                TravellerAge = s.TravellerAge,
                IsAdult = s.IsAdult,
                TravellerGender = s.TravellerGender,
                IsPrimaryTraveller = s.IsPrimaryTraveller,
                AlphaCode = s.AlphaCode,
                PolicyNumber = s.PolicyNumber,
                PolicyID = s.PolicyID,
                TripCost = s.TripCost,
                DepartureAirport = s.DepartureAirport,
                DestinationAirport = s.DestinationAirport,
                isDeleted = 0,
                UpdateBatchID = @batchid

        when not matched by target then
            insert
            (
                AnalyticsSessionID,
                TransactionTime,
                CampaignID,
                Campaign,
                CampaignSessionID,
                BusinessUnitID,
                Domain,
                BusinessUnit,
                ChannelID,
                Channel,
                Currency,
                TravellerID,
                ImpressionID,
                TransactionType,
                PathType,
                ConstructID,
                Construct,
                OfferID,
                Offer,
                ProductID,
                Product,
                ProductCode,
                PlanCode,
                StartDate,
                EndDate,
                RegionID,
                Region,
                DestinationType,
                DestinationCountryID,
                DestinationCountryCode,
                DestinationCountry,
                TripType,
                IsSessionClosed,
                IsOfferPurchased,
                PoliciesPerTrip,
                PolicyCurrency,
                GrossIncludingTax,
                GrossExcludingTax,
                NumAdults,
                NumChildren,
                TravellerAge,
                IsAdult,
                TravellerGender,
                IsPrimaryTraveller,
                AlphaCode,
                PolicyNumber,
                PolicyID,
                TripCost,
                DepartureAirport,
                DestinationAirport,
                CreateBatchID
            )
            values
            (
                s.AnalyticsSessionID,
                s.TransactionTime,
                s.CampaignID,
                s.Campaign,
                s.CampaignSessionID,
                s.BusinessUnitID,
                s.Domain,
                s.BusinessUnit,
                s.ChannelID,
                s.Channel,
                s.Currency,
                s.TravellerID,
                s.ImpressionID,
                s.TransactionType,
                s.PathType,
                s.ConstructID,
                s.Construct,
                s.OfferID,
                s.Offer,
                s.ProductID,
                s.Product,
                s.ProductCode,
                s.PlanCode,
                s.StartDate,
                s.EndDate,
                s.RegionID,
                s.Region,
                s.DestinationType,
                s.DestinationCountryID,
                s.DestinationCountryCode,
                s.DestinationCountry,
                s.TripType,
                s.IsSessionClosed,
                s.IsOfferPurchased,
                s.PoliciesPerTrip,
                s.PolicyCurrency,
                s.GrossIncludingTax,
                s.GrossExcludingTax,
                s.NumAdults,
                s.NumChildren,
                s.TravellerAge,
                s.IsAdult,
                s.TravellerGender,
                s.IsPrimaryTraveller,
                s.AlphaCode,
                s.PolicyNumber,
                s.PolicyID,
                s.TripCost,
                s.DepartureAirport,
                s.DestinationAirport,
                @batchid
            )

        when 
            not matched by source and
            t.isDeleted = 0 and
            t.TransactionTime >= @start and
            t.TransactionTime <  dateadd(day, 1, @end)
        then
            update
            set
                isDeleted = 1,
                UpdateBatchID = @batchid

        output $action into @mergeoutput
        ;

        select
            @insertcount =
                sum(
                    case
                        when MergeAction = 'insert' then 1
                        else 0
                    end
                ),
            @updatecount =
                sum(
                    case
                        when MergeAction = 'update' then 1
                        else 0
                    end
                )
        from
            @mergeoutput

        exec syssp_genericerrorhandler
            @LogToTable = 1,
            @ErrorCode = '0',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Finished',
            @LogSourceCount = @sourcecount,
            @LogInsertCount = @insertcount,
            @LogUpdateCount = @updatecount

    end try

    begin catch

        if @@trancount > 0
            rollback transaction

        exec syssp_genericerrorhandler
            @SourceInfo = 'cdgQuote Impulse 2.0 data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction





    /*fix isPrimary on Impulse 2*/
    if object_id('tempdb..#missingprimary') is not null
        drop table #missingprimary

    select 
        CampaignSessionID,
        min(TravellerID) TravellerID
    into #missingprimary
    from
        [db-au-cmdwh].dbo.cdgQuote_Impulse2 t
    where
        not exists
        (
            select null
            from
                [db-au-cmdwh].dbo.cdgQuote_Impulse2 r
            where
                r.CampaignSessionID = t.CampaignSessionID and
                r.IsPrimaryTraveller = 1
        )
    group by
        CampaignSessionID

    update t
    set
        t.IsPrimaryTraveller = 1
    from
        #missingprimary r
        inner join [db-au-cmdwh].dbo.cdgQuote_Impulse2 t on
            t.CampaignSessionID = r.CampaignSessionID and
            t.TravellerID = r.TravellerID
    where
        isnull(r.TravellerID, '') <> ''
*/

end



GO
