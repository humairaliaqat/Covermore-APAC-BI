USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL032_factQuoteSummaryBot]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_ETL032_factQuoteSummaryBot]
    @DateRange varchar(30),
    @StartDate varchar(10),
    @EndDate varchar(10)
    
as
begin


--2016-02-01, LS, merge Impulse 2.0, use new bot tables
--2016-02-03, LS, WTF!!!! copy paste error, should've been @rptStartDate instead of @start
--2016-02-16, LS, another WTF moment. not sure why the change on 20150831 in main penQuoteSummary wasn't replicated here
--2016-06-22, LS, include Lead Time (T25480)
--2018-06-01, LT, Removed Impulse2 Version1 quote source, and added Impulse2 Version2 quote source
--2019-01-24, RS, Quote processing happens in GCP now. utilizing the data downloaded from GCP for dimensional/cube processing.
--2019-11-19, RS, Removing references to CBA tables. post data segregation.

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select 
    @DateRange = '_User Defined', 
    @StartDate = '2018-02-01', 
    @EndDate = '2018-03-31'
*/

    set nocount on

    declare
        @batchid int,
        @start date,
        @end date,
        @rptStartDate date,
        @rptEndDate date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    declare @mergeoutput table (MergeAction varchar(20))

    
    set @batchid = -1

    --get date range
    if @DateRange = '_User Defined'
        select 
            @rptStartDate = @StartDate, 
            @rptEndDate = @EndDate
    else
        select 
            @rptStartDate = StartDate,
            @rptEndDate = EndDate
        from 
            [db-au-cmdwh].dbo.vDateRange
        where 
            DateRange = @DateRange

    --Commented by Ratnesh on 24-Jan-2019 since Quote processing is mostly happening in GCP now. 
	/*
    if object_id('etl_penQuoteSummaryBot') is not null
        drop table etl_penQuoteSummaryBot
      
    --penQuote, no optimisation as it's relatively ok
    select 
        convert(date, q.CreateDate) QuoteDate,
        1 QuoteSource,
        q.CountryKey,
        q.CompanyKey,
        q.OutletAlphaKey,
        q.StoreCode,
        u.UserKey,
        cu.CRMUserKey,
        q.SaveStep,
        q.CurrencyCode,
        q.Area,
        q.Destination,
        q.PurchasePath,
        isnull(q.CountryKey,'') + '-' + isnull(q.CompanyKey,'') + '' + convert(varchar,isnull(q.DomainID,0)) + '-' + isnull(q.ProductCode,'') + '-' + isnull(q.ProductName,'') + '-' + isnull(q.ProductDisplayName,'') + '-' + isnull(q.PlanName,'') ProductKey,
        q.ProductCode,
        q.ProductName,
        q.PlanCode,
        q.PlanName,
        q.PlanType,
        q.MaxDuration,
        q.Duration,
        case
            when datediff(day, q.CreateDate, q.DepartureDate) < 0 then 0
            else datediff(day, q.CreateDate, q.DepartureDate)
        end LeadTime,
        q.Excess,
        qcmp.CompetitorName,
        case
            when qcmp.CompetitorPrice is null or q.QuotedPrice is null then 0
            else round((q.QuotedPrice - qcmp.CompetitorPrice) / 50.0, 0) * 50
        end CompetitorGap,
        qpc.PrimaryCustomerAge,
        qpc.PrimaryCustomerSuburb,
        qpc.PrimaryCustomerState,
        qpc.YoungestAge,
        qpc.OldestAge,
        sum(isnull(q.NumberOfChildren, 0)) NumberOfChildren,
        sum(isnull(q.NumberOfAdults, 0)) NumberOfAdults,
        sum(isnull(q.NumberOfPersons, 0)) NumberOfPersons,
        sum(isnull(q.QuotedPrice, 0)) QuotedPrice,
        count(distinct q.SessionID) QuoteSessionCount,
        count(case when q.ParentQuoteID is null then q.QuoteKey else null end) QuoteCount,
        sum(
            case
                when q.ParentQuoteID is null and q.QuotedPrice is not null then 1
                else 0
            end 
        ) QuoteWithPriceCount,
        sum(case when q.ParentQuoteID is null and isnull(q.IsSaved,0) = 1 then 1 else 0 end) SavedQuoteCount,
        sum(
            case
                when isnull(q.PolicyKey, '') <> '' then 1
                else 0
            end 
        ) ConvertedCount,
        sum(case when q.ParentQuoteID is null and isnull(q.IsExpo,0) = 1 then 1 else 0 end) ExpoQuoteCount,
        sum(case when q.ParentQuoteID is null and isnull(q.IsAgentSpecial, 0) = 1 then 1 else 0 end) AgentSpecialQuoteCount,
        sum(
            case
                when q.ParentQuoteID is null and isnull(q.PromoCode, '') <> '' then 1
                else 0
            end 
        ) PromoQuoteCount,
        sum(case when q.ParentQuoteID is null and isnull(q.IsUpSell,0) = 1 then 1 else 0 end) UpsellQuoteCount,
        sum(case when q.ParentQuoteID is null and isnull(q.IsPriceBeat, 0) = 1 then 1 else 0 end) PriceBeatQuoteCount,
        sum(
            case
                when q.ParentQuoteID is null and q.PreviousPolicyNumber is not null then 1
                else 0
            end 
        ) QuoteRenewalCount,
        sum(case when q.ParentQuoteID is null and isnull(qa.HasCancellation, 0) = 1 then 1 else 0 end) CancellationQuoteCount,
        sum(case when q.ParentQuoteID is null and isnull(qa.HasLuggage, 0) = 1 then 1 else 0 end) LuggageQuoteCount,
        sum(case when q.ParentQuoteID is null and isnull(qa.HasMotorcycle, 0) = 1 then 1 else 0 end) MotorcycleQuoteCount,
        sum(case when q.ParentQuoteID is null and isnull(qa.HasWinter, 0) = 1 then 1 else 0 end) WinterQuoteCount,
        sum(case when q.ParentQuoteID is null and isnull(qpc.HasEMC, 0) = 1 then 1 else 0 end) EMCQuoteCount
    into etl_penQuoteSummaryBot
    from
        [db-au-cmdwh]..penQuote q
        outer apply
        (
            select top 1
                CompetitorName,
                CompetitorPrice
            from
                [db-au-cmdwh]..penQuoteCompetitor qcmp
            where
                qcmp.QuoteKey = q.QuoteCountryKey
        ) qcmp
        outer apply
        (
            select 
                max(
                    case
                        when IsPrimary = 1 then qc.Age 
                        else 0
                    end 
                ) PrimaryCustomerAge,
                max(c.Town) PrimaryCustomerSuburb,
                max(c.[State]) PrimaryCustomerState,
                max(0 + qc.HasEMC) HasEMC,
                min(qc.Age) YoungestAge,
                max(qc.Age) OldestAge
            from
                [db-au-cmdwh]..penQuoteCustomer qc
                left join [db-au-cmdwh]..penCustomer c on
                    c.CustomerKey = qc.CustomerKey and
                    qc.IsPrimary = 1
            where
                qc.QuoteCountryKey = q.QuoteCountryKey
        ) qpc
        outer apply
        (
            select 
                max(
                    case
                        when AddOnGroup = 'Cancellation' then 1
                        else 0
                    end
                ) HasCancellation,
                max(
                    case
                        when AddOnGroup = 'Luggage' then 1
                        else 0
                    end
                ) HasLuggage,
                max(
                    case
                        when AddOnGroup = 'Motorcycle' then 1
                        else 0
                    end
                ) HasMotorcycle,
                max(
                    case
                        when AddOnGroup = 'Winter Sport' then 1
                        else 0
                    end
                ) HasWinter
            from
                [db-au-cmdwh]..penQuoteAddOn qa
            where
                qa.QuoteCountryKey = q.QuoteCountryKey
        ) qa
        outer apply
        (
            select top 1
                UserKey
            from
                [db-au-cmdwh]..penUser u
                inner join [db-au-cmdwh]..penOutlet o on
                    o.OutletKey = u.OutletKey and
                    o.OutletStatus = 'Current'
            where
                u.UserStatus = 'Current' and
                u.[Login] = q.UserName and
                o.OutletAlphaKey = q.OutletAlphaKey
        ) u
        outer apply
        (
            select top 1
                CRMUserKey
            from
                [db-au-cmdwh]..penCRMUser cu
            where
                cu.UserName = q.CRMUserName
        ) cu
    where
        q.CreateDate >= @rptStartDate and
        q.CreateDate <  dateadd(day, 1, @rptEndDate) and
        q.CreateDate <  convert(date, getdate()) and
        q.QuoteKey not like 'AU-CM-%' and        --excludes duplicate quotekey records
        q.QuoteKey not like 'AU-TIP-%' and
        exists
        (
            select 
                null
            from
                [db-au-cmdwh]..botQuotePenguin qb
            where
                qb.QuoteKey = q.QuoteKey and
                qb.BotFlag = 1
        )
    group by
        convert(date, q.CreateDate),
        q.CountryKey,
        q.CompanyKey,
        q.OutletAlphaKey,
        q.StoreCode,
        u.UserKey,
        cu.CRMUserKey,
        q.SaveStep,
        q.CurrencyCode,
        q.Area,
        q.Destination,
        q.PurchasePath,
        isnull(q.CountryKey,'') + '-' + isnull(q.CompanyKey,'') + '' + convert(varchar,isnull(q.DomainID,0)) + '-' + isnull(q.ProductCode,'') + '-' + isnull(q.ProductName,'') + '-' + isnull(q.ProductDisplayName,'') + '-' + isnull(q.PlanName,''),
        q.ProductCode,
        q.ProductName,
        q.PlanCode,
        q.PlanName,
        q.PlanType,
        q.MaxDuration,
        q.Duration,
        case
            when datediff(day, q.CreateDate, q.DepartureDate) < 0 then 0
            else datediff(day, q.CreateDate, q.DepartureDate)
        end,
        q.Excess,
        qcmp.CompetitorName,
        case
            when qcmp.CompetitorPrice is null or q.QuotedPrice is null then 0
            else round((q.QuotedPrice - qcmp.CompetitorPrice) / 50.0, 0) * 50
        end,
        qpc.PrimaryCustomerAge,
        qpc.PrimaryCustomerSuburb,
        qpc.PrimaryCustomerState,
        qpc.YoungestAge,
        qpc.OldestAge


        
    --cdgQuote, optimised
    if object_id('tempdb..#cdgQuote') is not null
        drop table #cdgQuote

	--Impulse1
    select 
        convert(varchar(66), null) GroupIndex,
        convert(date, q.TransactionTime) QuoteDate,
        convert(nvarchar(50), null) OutletAlphaKey,
        isnull(ltrim(rtrim(q.Currency)), '') CurrencyCode,
        isnull(ltrim(rtrim(q.Region)), '') Area,
        isnull(ltrim(rtrim(q.DestinationCountry)), '') Destination,
        isnull(ltrim(rtrim(q.PathType)), '') PurchasePath,
        isnull(ltrim(rtrim(pk.ProductKey)), '') ProductKey,
        isnull(ltrim(rtrim(q.ProductCode)), '') ProductCode,
        isnull(ltrim(rtrim(q.Product)), '') ProductName,
        isnull(ltrim(rtrim(q.PlanCode)), '') PlanCode,
        isnull(datediff(day, q.StartDate, q.EndDate) + 1, 0) Duration,
        case
            when isnull(datediff(day, q.TransactionTime, q.StartDate), 0) < 0 then 0
            else isnull(datediff(day, q.TransactionTime, q.StartDate), 0)
        end LeadTime,
        0 PrimaryCustomerAge,
        0 YoungestAge,
        0 OldestAge,
        isnull(q.NumChildren, 0) * q.IsPrimaryTraveller NumberOfChildren,
        isnull(q.NumAdults, 0) * q.IsPrimaryTraveller NumberOfAdults,
        isnull(q.GrossIncludingTax, 0) * q.IsPrimaryTraveller QuotedPrice,        
		convert(varchar(128), q.CampaignSessionID) as CampaignSessionID,
        convert(varchar(128), q.ImpressionID) as ImpressionID,
        case
            when q.GrossIncludingTax is not null then convert(varchar(128), q.ImpressionID)
            else null
        end QuoteWithPriceID,
        case
            when q.PolicyID = 0 then null
            else convert(varchar(128), q.PolicyID)
        end ConvertedQuoteID,
        q.TravellerAge,
        q.IsPrimaryTraveller,
        q.Domain,
        q.BusinessUnit,
        q.Channel
    into #cdgQuote
    from
        [db-au-cmdwh]..cdgQuote q
        outer apply
        (
            select top 1 
                ProductKey
            from
                [db-au-cmdwh]..usrCDGQuoteProduct qp
            where
                qp.ProductID = q.ProductID
        ) pk
    where
        q.TransactionTime >= @rptStartDate and
        q.TransactionTime <  dateadd(day, 1, @rptEndDate) and
        q.isDeleted = 0
        --20150930, LS, bug, modify filter, don't mess up age grouping by session below
        and exists
        (
            select 
                null
            from
                [db-au-cmdwh]..botQuoteImpulse qb
                inner join [db-au-cmdwh]..cdgQuote r on
                    qb.PlatformVersion = 1 and
                    qb.AnalyticsSessionID = convert(varchar(128), r.AnalyticsSessionID) and
                    qb.BotFlag = 1
            where
                r.CampaignSessionID = q.CampaignSessionID
        )

    --index for primary, youngest & oldest age grouping
    create nonclustered index idx on #cdgQuote(CampaignSessionID) include(IsPrimaryTraveller,TravellerAge)
	 
	
    --cdg alpha mapping & age info
    update q
    set
        q.OutletAlphaKey = om.OutletAlphaKey,
        q.PrimaryCustomerAge = isnull(qc.PrimaryCustomerAge, 0),
        q.YoungestAge = isnull(qc.YoungestAge, 0),
        q.OldestAge = isnull(qc.OldestAge, 0)
    from
        #cdgQuote q
        outer apply
        (
            select top 1
                om.OutletAlphaKey
            from
                [db-au-cmdwh]..usrCDGQuoteAlpha om
            where
                om.Domain = q.Domain and
                om.BusinessUnit = q.BusinessUnit and
                om.Channel = q.Channel
        ) om
        cross apply
        (
            select
                max(qc.IsPrimaryTraveller * qc.TravellerAge) PrimaryCustomerAge,
                min(TravellerAge) YoungestAge,
                max(TravellerAge) OldestAge
            from
                #cdgQuote qc
            where
                qc.CampaignSessionID = q.CampaignSessionID
        ) qc

    --hash distinct groups
    update #cdgQuote
    set
        GroupIndex =
            convert(
                varchar(66),
                hashbytes(
                    'sha1', /*using sha1 as there are collisions on binary_checksum or even when using md5*/
                    convert(varchar(10), QuoteDate, 120) + '|' +
                    OutletAlphaKey + '|' +
                    CurrencyCode + '|' +
                    Area + '|' +
                    Destination + '|' +
                    PurchasePath + '|' +
                    ProductKey + '|' +
                    ProductCode + '|' +
                    ProductName + '|' +
                    PlanCode + '|' +
                    convert(varchar, Duration) + '|' +
                    convert(varchar, LeadTime) + '|' +
                    convert(varchar, PrimaryCustomerAge) + '|' +
                    convert(varchar, YoungestAge) + '|' +
                    convert(varchar, OldestAge)
                ),
                1
            )

    --index on hash, optimise distinct counts
    create index idx_group on #cdgQuote (GroupIndex)
        include
        (
            QuoteDate,
            OutletAlphaKey,
            CurrencyCode,
            Area,
            Destination,
            PurchasePath,
            ProductKey,
            ProductCode,
            ProductName,
            PlanCode,
            Duration,
            LeadTime,
            PrimaryCustomerAge,
            YoungestAge,
            OldestAge,
            NumberOfChildren,
            NumberOfAdults,
            ImpressionID,
            CampaignSessionID,
            QuoteWithPriceID,
            ConvertedQuoteID,
            QuotedPrice
        )

    --distinct counts performed on hashes
    if object_id('tempdb..#compressed') is not null
        drop table #compressed

    select
        GroupIndex,
        count(distinct ImpressionID) QuoteCount,
        count(distinct 
            case
                when ImpressionID is null then null
                else CampaignSessionID
            end
        ) QuoteSessionCount,
        count(distinct QuoteWithPriceID) QuoteWithPriceCount,
        count(distinct ConvertedQuoteID) ConvertedQuoteCount,
        sum(QuotedPrice) QuotedPrice,
        sum(NumberOfChildren) NumberOfChildren,
        sum(NumberOfAdults) NumberOfAdults
    into #compressed
    from
        #cdgQuote q
    group by
        GroupIndex

    --expand hashes to the original groupings
    if object_id('tempdb..#rolled') is not null
        drop table #rolled

    select 
        QuoteDate,
        2 QuoteSource,
        o.CountryKey,
        o.CompanyKey,
        OutletAlphaKey,
        convert(varchar(10), null) StoreCode,
        u.UserKey,
        convert(varchar(41), null) CRMUserKey,
        0 SaveStep,
        CurrencyCode,
        Area,
        Destination,
        PurchasePath,
        ProductKey,
        ProductCode,
        ProductName,
        PlanCode,
        null PlanName,
        case
            when ProductName like '%Annual Multi%' then 'Annual Multi Trip'
            else 'Single Trip'
        end PlanType,
        null MaxDuration,
        Duration,
        LeadTime,
        null Excess,
        null CompetitorName,
        0 CompetitorGap,
        PrimaryCustomerAge,
        null PrimaryCustomerSuburb,
        null PrimaryCustomerState,
        YoungestAge,
        OldestAge,
        NumberOfChildren,
        NumberOfAdults,
        NumberOfChildren + NumberOfAdults NumberOfPersons,
        QuoteCount,
        QuoteSessionCount,
        QuoteWithPriceCount,
        ConvertedQuoteCount,
        QuotedPrice,
        0 ExpoQuoteCount,
        0 AgentSpecialQuoteCount,
        0 PromoQuoteCount,
        0 UpsellQuoteCount,
        0 PriceBeatQuoteCount,
        0 QuoteRenewalCount,
        0 CancellationQuoteCount,
        0 LuggageQuoteCount,
        0 MotorcycleQuoteCount,
        0 WinterQuoteCount,
        0 EMCQuoteCount
    into #rolled
    from
        #compressed t
        cross apply
        (
            select top 1 
                QuoteDate,
                OutletAlphaKey,
                CurrencyCode,
                Area,
                Destination,
                PurchasePath,
                ProductKey,
                ProductCode,
                ProductName,
                PlanCode,
                Duration,
                LeadTime,
                PrimaryCustomerAge,
                YoungestAge,
                OldestAge
            from
                #cdgQuote r
            where
                r.GroupIndex = t.GroupIndex
        ) r
        cross apply 
        (
            select top 1
                o.CountryKey,
                o.CompanyKey,
                o.OutletKey
            from
                [db-au-cmdwh]..penOutlet o
            where
                o.OutletAlphaKey = r.OutletAlphaKey and
                o.OutletStatus = 'Current'
        ) o
        outer apply
        (
            select top 1 
                UserKey
            from
                [db-au-cmdwh]..penUser u
            where
                u.UserStatus = 'Current' and
                u.OutletKey = o.OutletKey and
                u.[Login] = 'webuser'
        ) u

        
    insert into etl_penQuoteSummaryBot
    select 
        QuoteDate,
        QuoteSource,
        CountryKey,
        CompanyKey,
        OutletAlphaKey,
        StoreCode,
        UserKey,
        CRMUserKey,
        SaveStep,
        CurrencyCode,
        Area,
        Destination,
        PurchasePath,
        ProductKey,
        ProductCode,
        ProductName,
        PlanCode,
        PlanName,
        PlanType,
        MaxDuration,
        Duration,
        LeadTime,
        Excess,
        CompetitorName,
        CompetitorGap,
        PrimaryCustomerAge,
        PrimaryCustomerSuburb,
        PrimaryCustomerState,
        YoungestAge,
        OldestAge,
        NumberOfChildren,
        NumberOfAdults,
        NumberOfPersons,
        QuotedPrice,
        QuoteSessionCount,
        QuoteCount,
        QuoteWithPriceCount,
        0 SavedQuoteCount,
        ConvertedQuoteCount ConvertedCount,
        ExpoQuoteCount,
        AgentSpecialQuoteCount,
        PromoQuoteCount,
        UpsellQuoteCount,
        PriceBeatQuoteCount,
        QuoteRenewalCount,
        CancellationQuoteCount,
        LuggageQuoteCount,
        MotorcycleQuoteCount,
        WinterQuoteCount,
        EMCQuoteCount
    from
        #rolled
     

	--Impulse2 Version2 (MS SQL)

    --cdgQuote, optimised
    if object_id('tempdb..#cdgQuote2') is not null
        drop table #cdgQuote2

	select 
        convert(varchar(66), null) GroupIndex,
        convert(date, q.QuoteDate) QuoteDate,
        convert(nvarchar(50), null) OutletAlphaKey,
        isnull(ltrim(rtrim(q.CurrencyCode)), '') CurrencyCode,
        isnull(ltrim(rtrim(q.RegionName)), '') Area,
        isnull(ltrim(rtrim(q.Destination)), '') Destination,
        '' as PurchasePath,
        isnull(ltrim(rtrim(pk.ProductKey)), '') ProductKey,
        isnull(ltrim(rtrim(q.ProductCode)), '') ProductCode,
        isnull(ltrim(rtrim(q.ProductName)), '') ProductName,
        isnull(ltrim(rtrim(q.PlanCode)), '') PlanCode,
        isnull(datediff(day, q.TripStart, q.TripEnd) + 1, 0) Duration,
        case
            when isnull(datediff(day, q.QuoteDate, q.TripStart), 0) < 0 then 0
            else isnull(datediff(day, q.QuoteDate, q.TripStart), 0)
        end LeadTime,
        trv.TravellerAge as PrimaryCustomerAge,
        trvage.YoungestAge,
        trvage.OldestAge,
        isnull(q.ChildCount, 0) NumberOfChildren,
        isnull(q.AdultCount, 0) NumberOfAdults,
        isnull(q.TotalGrossPremium, 0) QuotedPrice,
        count(distinct q.SessionID) as  QuoteCount,
        case when q.factQuoteID is null then 0
             else 1
        end QuoteSessionCount,
        case when q.TotalGrossPremium is not null then 1
			 else 0
		end as QuoteWithPriceCount,
        case when s.IsPolicyPurchased = 1 then 1
			 else 0
		end as ConvertedQuoteCount,
        trv.TravellerAge,
        trv.IsPrimaryTraveller,
        s.Domain,
        q.BusinessUnitName as BusinessUnit,
        '' as Channel,
		s.AffiliateCode as AlphaCode
    into #cdgquote2
    from
		[db-au-cmdwh].dbo.cdgfactSession s
        inner join [db-au-cmdwh].dbo.cdgfactQuote q on s.factSessionID = q.SessionID
		outer apply														--isPrimaryTraveller is assumed to be the first entry denoted by the minimum session ID
		(
			select top 1
				t.Age as TravellerAge,
				1 as isPrimaryTraveller
			from
				[db-au-cmdwh].dbo.cdgfactTraveler t
			where
				t.SessionID = s.factSessionID
			order by t.SessionID asc
		) trv
		outer apply													
		(
			select 
				min(t.Age) as YoungestAge,
				max(t.Age) as OldestAge
			from
				[db-au-cmdwh].dbo.cdgfactTraveler t
			where
				t.SessionID = s.factSessionID			
		) trvage
        outer apply													
        (
            select top 1 
                ProductKey
            from
                [db-au-cmdwh]..usrCDGQuoteProduct qp
            where
                qp.ProductID = q.ProductID
        ) pk
    where
		q.BusinessUnitName in ('AirNZ-NZ-WL','AUPost','CMAU-B2C','FMG-NZ-WL','HKE-WL','IAL-NRMA2','Medibank','VirginNZ-INT','Westpac-NZ') and
        q.QuoteDate >= @rptStartDate and
        q.QuoteDate <  dateadd(d,1,@rptEndDate) and
        exists
        (
            select 
                null
            from
                [db-au-cmdwh]..botQuoteImpulse qb
                inner join [db-au-cmdwh]..cdgfactSession r on
                    qb.PlatformVersion = 3 and
                    r.factSessionID = qb.AnalyticsSessionID and
                    qb.BotFlag = 1
            where
                r.factSessionID = q.SessionID
        )
	group by
        convert(date, q.QuoteDate),
        isnull(ltrim(rtrim(q.CurrencyCode)), ''),
        isnull(ltrim(rtrim(q.RegionName)), ''),
        isnull(ltrim(rtrim(q.Destination)), ''),
        isnull(ltrim(rtrim(pk.ProductKey)), ''),
        isnull(ltrim(rtrim(q.ProductCode)), ''),
        isnull(ltrim(rtrim(q.ProductName)), ''),
        isnull(ltrim(rtrim(q.PlanCode)), ''),
        isnull(datediff(day, q.TripStart, q.TripEnd) + 1, 0),
        case
            when isnull(datediff(day, q.QuoteDate, q.TripStart), 0) < 0 then 0
            else isnull(datediff(day, q.QuoteDate, q.TripStart), 0)
        end,
        trv.TravellerAge,
        trvage.YoungestAge,
        trvage.OldestAge,
        isnull(q.ChildCount, 0),
        isnull(q.AdultCount, 0),
        isnull(q.TotalGrossPremium, 0),
        case when q.factQuoteID is null then 0
             else 1
        end,
        case when q.TotalGrossPremium is not null then 1
			 else 0
		end,
        case when s.IsPolicyPurchased = 1 then 1
			 else 0
		end,
        trv.TravellerAge,
        trv.IsPrimaryTraveller,
        s.Domain,
        q.BusinessUnitName,
		s.AffiliateCode
		   
	union all

    select 
        convert(varchar(66), null) GroupIndex,
        convert(date, s.SessionCreateDate) QuoteDate,
        convert(nvarchar(50), null) OutletAlphaKey,
        q.CurrencyCode,
        q.Area,
        q.Destination,
        '' as PurchasePath,
        isnull(ltrim(rtrim(pk.ProductKey)), '') ProductKey,
        q.ProductCode,
        q.ProductName,
        q.PlanCode,
        q.Duration,
        q.LeadTime,
        trv.TravellerAge as PrimaryCustomerAge,
        trvage.YoungestAge,
        trvage.OldestAge,
        q.NumberOfChildren,
        q.NumberOfAdults,
        q.QuotedPrice,
        count(distinct s.factSessionID) as  QuoteCount,
        q.QuoteSessionCount,
        q.QuoteWithPriceCount,
        case when s.IsPolicyPurchased = 1 then 1
			 else 0
		end as ConvertedQuoteCount,
        trv.TravellerAge,
        trv.IsPrimaryTraveller,
        s.Domain,
        bu.BusinessUnit,
        '' as Channel,
		s.AffiliateCode as AlphaCode
    from
		[db-au-cmdwh].dbo.cdgfactSession s
		inner join [db-au-cmdwh].dbo.cdgBusinessUnit bu on s.BusinessUnitID = bu.BusinessUnitID
		outer apply
		(
			select top 1
			    isnull(ltrim(rtrim(CurrencyCode)), '') CurrencyCode,
				isnull(ltrim(rtrim(RegionName)), '') Area,
				isnull(ltrim(rtrim(Destination)), '') Destination,				
				isnull(ltrim(rtrim(ProductCode)), '') ProductCode,
				isnull(ltrim(rtrim(ProductName)), '') ProductName,
				isnull(ltrim(rtrim(PlanCode)), '') PlanCode,
				isnull(datediff(day, TripStart, TripEnd) + 1, 0) Duration,
				case
					when isnull(datediff(day, OfferDate, TripStart), 0) < 0 then 0
					else isnull(datediff(day, OfferDate, TripStart), 0)
				end LeadTime,
				isnull(ChildCount, 0) NumberOfChildren,
				isnull(AdultCount, 0) NumberOfAdults,
				isnull(TotalGrossPremium, 0) QuotedPrice,
			   case when factOfferID is null then 0
					 else 1
				end QuoteSessionCount,
				case when TotalGrossPremium is not null then 1
					 else 0
				end as QuoteWithPriceCount,
				ProductID
			from
				[db-au-cmdwh].dbo.cdgfactOffer
			where
				SessionID = s.factSessionID

			union

			select top 1
			    isnull(ltrim(rtrim(CurrencyCode)), '') CurrencyCode,
				isnull(ltrim(rtrim(RegionName)), '') Area,
				isnull(ltrim(rtrim(Destination)), '') Destination,				
				isnull(ltrim(rtrim(ProductCode)), '') ProductCode,
				isnull(ltrim(rtrim(ProductName)), '') ProductName,
				isnull(ltrim(rtrim(PlanCode)), '') PlanCode,
				isnull(datediff(day, TripStart, TripEnd) + 1, 0) Duration,
				case
					when isnull(datediff(day, QuoteDate, TripStart), 0) < 0 then 0
					else isnull(datediff(day, QuoteDate, TripStart), 0)
				end LeadTime,
				isnull(ChildCount, 0) NumberOfChildren,
				isnull(AdultCount, 0) NumberOfAdults,
				isnull(TotalGrossPremium, 0) QuotedPrice,
			   case when factQuoteID is null then 0
					 else 1
				end QuoteSessionCount,
				case when TotalGrossPremium is not null then 1
					 else 0
				end as QuoteWithPriceCount,
				ProductID
			from
				[db-au-cmdwh].dbo.cdgfactQuote
			where
				SessionID = s.factSessionID
		) q
		outer apply														--isPrimaryTraveller is assumed to be the first entry denoted by the minimum session ID
		(
			select top 1
				t.Age as TravellerAge,
				1 as isPrimaryTraveller
			from
				[db-au-cmdwh].dbo.cdgfactTraveler t
			where
				t.SessionID = s.factSessionID
			order by t.SessionID asc
		) trv
		outer apply													
		(
			select 
				min(t.Age) as YoungestAge,
				max(t.Age) as OldestAge
			from
				[db-au-cmdwh].dbo.cdgfactTraveler t
			where
				t.SessionID = s.factSessionID			
		) trvage
        outer apply													
        (
            select top 1 
                ProductKey
            from
                [db-au-cmdwh]..usrCDGQuoteProduct qp
            where
                qp.ProductID = q.ProductID
        ) pk
    where
        s.SessionCreateDate >= @rptStartDate and
        s.SessionCreateDate <  dateadd(d,1,@rptEndDate) and
		s.BusinessUnitID not in 
		(	26, --AirNZ-NZ-WL
			20, --AUPost
			59, --CMAU-B2C
			87, --FMG-NZ-WL
			80, --HKE-WL
			90, --IAL-NRMA2
			32, --Medibank
			57, --VirginNZ-INT
			60	--Westpac-NZ
		) and
        exists
        (
            select 
                null
            from
                [db-au-cmdwh]..botQuoteImpulse qb
                inner join [db-au-cmdwh]..cdgfactSession r on
                    qb.PlatformVersion = 3 and
                    r.factSessionID = qb.AnalyticsSessionID and
                    qb.BotFlag = 1
            where
                r.factSessionID = s.factSessionID
        )
	group by        
        convert(date, s.SessionCreateDate),
        q.CurrencyCode,
        q.Area,
        q.Destination,
        isnull(ltrim(rtrim(pk.ProductKey)), ''),
        q.ProductCode,
        q.ProductName,
        q.PlanCode,
        q.Duration,
        q.LeadTime,
        trv.TravellerAge,
        trvage.YoungestAge,
        trvage.OldestAge,
        q.NumberOfChildren,
        q.NumberOfAdults,
        q.QuotedPrice,
        q.QuoteSessionCount,
        q.QuoteWithPriceCount,
        case when s.IsPolicyPurchased = 1 then 1
				else 0
		end,
        trv.TravellerAge,
        trv.IsPrimaryTraveller,
        s.Domain,
        bu.BusinessUnit,
		s.AffiliateCode


    --cdg alpha mapping info
    update q
    set
        q.OutletAlphaKey = isnull(o.OutletAlphaKey,isnull(om.OutletAlphaKey,om2.OutletAlphaKey))
    from
        #cdgQuote2 q
        outer apply						--LT: try mapping to penOutlet first
        (
            select top 1 po.OutletAlphaKey
            from
                [db-au-cmdwh].dbo.penOutlet po with(nolock)
            where
                po.CountryKey = q.Domain and
				po.AlphaCode = q.AlphaCode and
				po.OutletStatus = 'Current' 
        ) o
        outer apply						--LT: if penOutlet mapping fails, try manual CDG alpha mapping. Note Impulse SQL version2 does not use channel.
        (
            select top 1
                om.OutletAlphaKey
            from
                [db-au-cmdwh]..usrCDGQuoteAlpha om
            where
                om.Domain = q.Domain and
                om.BusinessUnit = q.BusinessUnit and
				q.AlphaCode is null
        ) om
        outer apply						--LT: if manual CDG alpha mapping fails, get the first OutletAlphaKey where #cdgQuote2 alpha code is not null
        (
            select top 1
                om.OutletAlphaKey
            from
                [db-au-cmdwh]..usrCDGQuoteAlpha om
            where
                om.Domain = q.Domain and
				om.AlphaCode = q.AlphaCode and
				q.AlphaCode is not null
        ) om2        
 


     --expand hashes to the original groupings
    if object_id('tempdb..#rolled2') is not null
        drop table #rolled2

    select 
        QuoteDate,
        3 QuoteSource,
        o.CountryKey,
        o.CompanyKey,
        OutletAlphaKey,
        convert(varchar(10), null) StoreCode,
        u.UserKey,
        convert(varchar(41), null) CRMUserKey,
        0 SaveStep,
        CurrencyCode,
        Area,
        Destination,
        PurchasePath,
        ProductKey,
        ProductCode,
        ProductName,
        PlanCode,
        null PlanName,
        case
            when ProductName like '%Annual Multi%' then 'Annual Multi Trip'
            else 'Single Trip'
        end PlanType,
        null MaxDuration,
        Duration,
        LeadTime,
        null Excess,
        null CompetitorName,
        0 CompetitorGap,
        PrimaryCustomerAge,
        null PrimaryCustomerSuburb,
        null PrimaryCustomerState,
        YoungestAge,
        OldestAge,
        NumberOfChildren,
        NumberOfAdults,
        NumberOfChildren + NumberOfAdults NumberOfPersons,
        QuoteCount,
        QuoteSessionCount,
        QuoteWithPriceCount,
        ConvertedQuoteCount,
        QuotedPrice,
        0 ExpoQuoteCount,
        0 AgentSpecialQuoteCount,
        0 PromoQuoteCount,
        0 UpsellQuoteCount,
        0 PriceBeatQuoteCount,
        0 QuoteRenewalCount,
        0 CancellationQuoteCount,
        0 LuggageQuoteCount,
        0 MotorcycleQuoteCount,
        0 WinterQuoteCount,
        0 EMCQuoteCount
    into #rolled2
    from
		#cdgQuote2 t
        cross apply 
        (
            select top 1
                o.CountryKey,
                o.CompanyKey,
                o.OutletKey
            from
                [db-au-cmdwh]..penOutlet o with(nolock)
            where
                o.OutletAlphaKey = t.OutletAlphaKey and
                o.OutletStatus = 'Current'
        ) o
        outer apply
        (
            select top 1 
                UserKey
            from
                [db-au-cmdwh]..penUser u with(nolock)
            where                
                u.OutletKey = o.OutletKey and
                u.[Login] = 'webuser'
        ) u


    insert into etl_penQuoteSummaryBot
    select 
        QuoteDate,
        QuoteSource,
        CountryKey,
        CompanyKey,
        OutletAlphaKey,
        StoreCode,
        UserKey,
        CRMUserKey,
        SaveStep,
        CurrencyCode,
        Area,
        Destination,
        PurchasePath,
        ProductKey,
        ProductCode,
        ProductName,
        PlanCode,
        PlanName,
        PlanType,
        MaxDuration,
        Duration,
        LeadTime,
        Excess,
        CompetitorName,
        CompetitorGap,
        PrimaryCustomerAge,
        PrimaryCustomerSuburb,
        PrimaryCustomerState,
        YoungestAge,
        OldestAge,
        NumberOfChildren,
        NumberOfAdults,
        NumberOfPersons,
        QuotedPrice,
        QuoteSessionCount,
        QuoteCount,
        QuoteWithPriceCount,
        0 SavedQuoteCount,
        ConvertedQuoteCount ConvertedCount,
        ExpoQuoteCount,
        AgentSpecialQuoteCount,
        PromoQuoteCount,
        UpsellQuoteCount,
        PriceBeatQuoteCount,
        QuoteRenewalCount,
        CancellationQuoteCount,
        LuggageQuoteCount,
        MotorcycleQuoteCount,
        WinterQuoteCount,
        EMCQuoteCount
    from
        #rolled2       
		*/


    if object_id('[db-au-stage].dbo.etl_factQuoteSummaryBotTemp') is not null 
        drop table [db-au-stage].dbo.etl_factQuoteSummaryBotTemp
        
    select 
        dt.Date_SK DateSK,
        isnull(dom.DomainSK, -1) DomainSK,
        isnull(do.OutletSK, -1) OutletSK,
        isnull(econ.ConsultantSK, isnull(con.ConsultantSK, -1)) ConsultantSK,
        isnull(area.AreaSK, -1) AreaSK,
        isnull(dest.DestinationSK, -1) DestinationSK,
        isnull(duration.DurationSK, -1) DurationSK,
        isnull(LeadTime, -1) LeadTime,
        isnull(age.AgeBandSK, -1) AgeBandSK,
        isnull(product.ProductSK, -1) ProductSK,
        -sum(QuoteSessionCount) QuoteSessionCount,
        -sum(QuoteCount) QuoteCount,
        -sum(QuoteWithPriceCount) QuoteWithPriceCount,
        -sum(SavedQuoteCount) SavedQuoteCount,
        -sum(ConvertedCount) ConvertedCount,
        -sum(ExpoQuoteCount) ExpoQuoteCount,
        -sum(AgentSpecialQuoteCount) AgentSpecialQuoteCount,
        -sum(PromoQuoteCount) PromoQuoteCount,
        -sum(UpsellQuoteCount) UpsellQuoteCount,
        -sum(PriceBeatQuoteCount) PriceBeatQuoteCount,
        -sum(QuoteRenewalCount) QuoteRenewalCount,
        -sum(CancellationQuoteCount) CancellationQuoteCount,
        -sum(LuggageQuoteCount) LuggageQuoteCount,
        -sum(MotorcycleQuoteCount) MotorcycleQuoteCount,
        -sum(WinterQuoteCount) WinterQuoteCount,
        -sum(EMCQuoteCount) EMCQuoteCount
    into [db-au-stage].dbo.etl_factQuoteSummaryBotTemp
    from
        etl_penQuoteSummaryBot qs
        cross apply
        (
            select top 1
                dt.Date_SK
            from
                [db-au-star].dbo.Dim_Date dt
            where
                dt.[Date] = convert(date, qs.QuoteDate)
        ) dt
        outer apply
        (
            select top 1
                dom.DomainSK,
                DomainID
            from
                [db-au-star].dbo.dimDomain dom
            where
                dom.CountryCode = qs.CountryKey
        ) dom
        outer apply
        (
            select top 1 
                o.OutletSK,
                o.AlphaCode
            from
                [db-au-star].dbo.dimOutlet o
            where
                o.OutletAlphaKey = qs.OutletAlphaKey and
                o.ValidStartDate <= qs.QuoteDate and
                o.ValidEndDate >= qs.QuoteDate
        ) do
        outer apply
        (
            select top 1 
                UserID ConsultantID
            from
                [db-au-cmdwh]..penUser u
            where
                u.UserKey = qs.UserKey and
                u.UserStatus = 'Current'
        ) u
        outer apply
        (
            select top 1 
                UserName CRMUserName
            from
                [db-au-cmdwh]..penCRMUser cu
            where
                cu.CRMUserKey = qs.CRMUserKey
        ) cu
        cross apply
        (
            select
                qs.CountryKey + isnull(do.AlphaCode, '') + isnull(convert(varchar, ConsultantID), isnull(CRMUserName, '')) DerivedConsultant
        ) dcon
        outer apply
        (
            select top 1
                con.ConsultantSK
            from
                [db-au-star].dbo.dimConsultant con
            where
                con.ConsultantKey = qs.UserKey
        ) econ
        outer apply
        (
            select top 1
                con.ConsultantSK
            from
                [db-au-star].dbo.dimConsultant con
            where
                con.ConsultantKey = DerivedConsultant
        ) con
        outer apply
        (
            select top 1
                area.AreaSK
            from
                [db-au-star].dbo.dimArea area
            where
                area.Country = qs.CountryKey and
                area.AreaName = qs.Area
        ) area
        outer apply
        (
            select top 1
                dest.DestinationSK
            from
                [db-au-star].dbo.dimDestination dest
            where
                dest.Destination = qs.Destination
            order by
                dest.DestinationSK desc
        ) dest
        outer apply
        (
            select top 1
                duration.DurationSK
            from
                [db-au-star].dbo.dimDuration duration
            where
                duration.Duration = qs.Duration
        ) duration
        outer apply
        (
            select top 1
                age.AgeBandSK
            from
                [db-au-star].dbo.dimAgeBand age
            where
                age.Age = qs.PrimaryCustomerAge
        ) age
        outer apply
        (
            select top 1
                product.ProductSK
            from
                [db-au-star].dbo.dimProduct product
            where
                product.ProductKey = qs.ProductKey
        ) product
    group by
        dt.Date_SK,
        isnull(dom.DomainSK, -1),
        isnull(do.OutletSK, -1),
        isnull(econ.ConsultantSK, isnull(con.ConsultantSK, -1)),
        isnull(area.AreaSK, -1),
        isnull(dest.DestinationSK, -1),
        isnull(duration.DurationSK, -1),
        isnull(LeadTime, -1),
        isnull(age.AgeBandSK, -1),
        isnull(product.ProductSK, -1)



    --create factQuoteSummaryBot if table does not exist
    if object_id('[db-au-star].dbo.factQuoteSummaryBot') is null
    begin
    
        create table [db-au-star].dbo.factQuoteSummaryBot
        (
            BIRowID bigint not null identity(1,1),
            DateSK int not null,
            DomainSK int not null,
            OutletSK int not null,
            ConsultantSK int not null,
            AreaSK int not null,
            DestinationSK int not null,
            DurationSK int not null,
            LeadTime int not null default -1,
            AgeBandSK int not null,
            ProductSK int not null,
            QuoteSessionCount int not null default 0,
            QuoteCount int not null default 0,
            QuoteWithPriceCount int not null default 0,
            SavedQuoteCount int not null default 0,
            ConvertedCount int not null default 0,
            ExpoQuoteCount int not null default 0,
            AgentSpecialQuoteCount int not null default 0,
            PromoQuoteCount int not null default 0,
            UpsellQuoteCount int not null default 0,
            PriceBeatQuoteCount int not null default 0,
            QuoteRenewalCount int not null default 0,
            CancellationQuoteCount int not null default 0,
            LuggageQuoteCount int not null default 0,
            MotorcycleQuoteCount int not null default 0,
            WinterQuoteCount int not null default 0,
            EMCQuoteCount int not null default 0,
            LoadDate datetime not null,
            LoadID int not null,
            updateDate datetime null,
            updateID int null

        )
        
        create clustered index idx_factQuoteSummaryBot_BIRowID on [db-au-star].dbo.factQuoteSummaryBot(BIRowID)
        create nonclustered index idx_factQuoteSummaryBot_DateSK on [db-au-star].dbo.factQuoteSummaryBot(DateSK) include(DomainSK)
        create nonclustered index idx_factQuoteSummaryBot_DomainSK on [db-au-star].dbo.factQuoteSummaryBot(DomainSK)
        create nonclustered index idx_factQuoteSummaryBot_OutletSK on [db-au-star].dbo.factQuoteSummaryBot(OutletSK)
        create nonclustered index idx_factQuoteSummaryBot_ConsultantSK on [db-au-star].dbo.factQuoteSummaryBot(ConsultantSK) include(OutletSK,DateSK)
        create nonclustered index idx_factQuoteSummaryBot_AreaSK on [db-au-star].dbo.factQuoteSummaryBot(AreaSK)
        create nonclustered index idx_factQuoteSummaryBot_DestinationSK on [db-au-star].dbo.factQuoteSummaryBot(DestinationSK)
        create nonclustered index idx_factQuoteSummaryBot_DurationSK on [db-au-star].dbo.factQuoteSummaryBot(DurationSK)
        create nonclustered index idx_factQuoteSummaryBot_AgeBandSK on [db-au-star].dbo.factQuoteSummaryBot(AgeBandSK)
        create nonclustered index idx_factQuoteSummaryBot_ProductSK on [db-au-star].dbo.factQuoteSummaryBot(ProductSK)
        create nonclustered index idx_factQuoteSummaryBot_LeadTime on [db-au-star].dbo.factQuoteSummaryBot(LeadTime)
        
    end
    
    select
        @sourcecount = count(*)
    from
        [db-au-stage].dbo.etl_factQuoteSummaryBotTemp

    begin transaction
    begin try

        delete [db-au-star].dbo.factQuoteSummaryBot
        where
            DateSK in
            (
                select 
                    dt.Date_SK
                from
                    [db-au-star].dbo.Dim_Date dt
                where
                    dt.[Date] >= @rptStartDate and
                    dt.[Date] <  dateadd(day, 1, @rptEndDate)

            )

        insert into [db-au-star].dbo.factQuoteSummaryBot with (tablockx)
        (
            DateSK,
            DomainSK,
            OutletSK,
            ConsultantSK,
            AreaSK,
            DestinationSK,
            DurationSK,
            LeadTime,
            AgeBandSK,
            ProductSK,
            QuoteSessionCount,
            QuoteCount,
            QuoteWithPriceCount,
            SavedQuoteCount,
            ConvertedCount,
            ExpoQuoteCount,
            AgentSpecialQuoteCount,
            PromoQuoteCount,
            UpsellQuoteCount,
            PriceBeatQuoteCount,
            QuoteRenewalCount,
            CancellationQuoteCount,
            LuggageQuoteCount,
            MotorcycleQuoteCount,
            WinterQuoteCount,
            EMCQuoteCount,
            LoadDate,
            LoadID,
            updateDate,
            updateID
        )
        select
            DateSK,
            DomainSK,
            OutletSK,
            ConsultantSK,
            AreaSK,
            DestinationSK,
            DurationSK,
            LeadTime,
            AgeBandSK,
            ProductSK,
            QuoteSessionCount,
            QuoteCount,
            QuoteWithPriceCount,
            SavedQuoteCount,
            ConvertedCount,
            ExpoQuoteCount,
            AgentSpecialQuoteCount,
            PromoQuoteCount,
            UpsellQuoteCount,
            PriceBeatQuoteCount,
            QuoteRenewalCount,
            CancellationQuoteCount,
            LuggageQuoteCount,
            MotorcycleQuoteCount,
            WinterQuoteCount,
            EMCQuoteCount,
            getdate() as LoadDate,
            -1 as LoadID,
            null as updateDate,
            null as updateID
        from
            [db-au-stage].dbo.etl_factQuoteSummaryBotTemp

			/* Commented on 20191119 for data segregation
			--new code to insert CBA data 
	insert into [db-au-star].dbo.factQuoteSummaryBot with (tablockx)
        (
            DateSK,
            DomainSK,
            OutletSK,
            ConsultantSK,
            AreaSK,
            DestinationSK,
            DurationSK,
            LeadTime,
            AgeBandSK,
            ProductSK,
            QuoteSessionCount,
            QuoteCount,
            QuoteWithPriceCount,
            SavedQuoteCount,
            ConvertedCount,
            ExpoQuoteCount,
            AgentSpecialQuoteCount,
            PromoQuoteCount,
            UpsellQuoteCount,
            PriceBeatQuoteCount,
            QuoteRenewalCount,
            CancellationQuoteCount,
            LuggageQuoteCount,
            MotorcycleQuoteCount,
            WinterQuoteCount,
            EMCQuoteCount,
            LoadDate,
            LoadID,
            updateDate,
            updateID
        )
        select
           DateSK,
            DomainSK,
            OutletSK,
            ConsultantSK,
            AreaSK,
            DestinationSK,
            DurationSK,
            LeadTime,
            AgeBandSK,
            ProductSK,
            QuoteSessionCount,
            QuoteCount,
            QuoteWithPriceCount,
            SavedQuoteCount,
            ConvertedCount,
            ExpoQuoteCount,
            AgentSpecialQuoteCount,
            PromoQuoteCount,
            UpsellQuoteCount,
            PriceBeatQuoteCount,
            QuoteRenewalCount,
            CancellationQuoteCount,
            LuggageQuoteCount,
            MotorcycleQuoteCount,
            WinterQuoteCount,
            EMCQuoteCount,
            LoadDate,
            LoadID,
            updateDate,
            updateID
        from
            [db-au-star]..factQuoteSummaryBotCBA fqsbc
			 where
            fqsbc.DateSK in
            (
                select 
                    dt.Date_SK
                from
                    [db-au-star].dbo.Dim_Date dt
                where
                    dt.[Date] >= @rptStartDate and
                    dt.[Date] <  dateadd(day, 1, @rptEndDate)
					)
					and not exists (select 1
					from [db-au-star].dbo.factQuoteSummaryBot fqsb
					  where fqsb.DateSK         = fqsbc.DateSK        and 
							fqsb.DomainSK       = fqsbc.DomainSK      and 
							fqsb.OutletSK       = fqsbc.OutletSK      and 
							fqsb.ConsultantSK   = fqsbc.ConsultantSK  and 
							fqsb.AreaSK         = fqsbc.AreaSK        and 
							fqsb.DestinationSK  = fqsbc.DestinationSK and 
							fqsb.DurationSK     = fqsbc.DurationSK    and 
							fqsb.LeadTime       = fqsbc.LeadTime      and 
							fqsb.AgeBandSK      = fqsbc.AgeBandSK     and 
							fqsb.ProductSK      = fqsbc.ProductSK )

			*/
                
    end try

    begin catch

        if @@trancount > 0
            rollback transaction

        if @batchid <> - 1
            exec syssp_genericerrorhandler
                @SourceInfo = 'data refresh failed',
                @LogToTable = 1,
                @ErrorCode = '-100',
                @BatchID = @batchid,
                @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction


end
GO
