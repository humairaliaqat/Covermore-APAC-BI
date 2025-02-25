USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_entCustomerDemography]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_entCustomerDemography]
    @StartDate date = null,
    @EndDate date = null

as
begin

/*
    20170706, LL, create
*/

    set nocount on

    exec etlsp_StagingIndex_EnterpriseMDM

    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    declare @mergeoutput table (MergeAction varchar(20))

    begin try

        exec syssp_getrunningbatch
            @SubjectArea = 'EnterpriseMDM ODS',
            @BatchID = @batchid out,
            @StartDate = @start out,
            @EndDate = @end out

    end try

    begin catch

        set @batchid = -1

    end catch

    print 'here'

    set @start = coalesce(@StartDate, @start, getdate())
    set @end = coalesce(@EndDate, @end, getdate())

    select
        @name = object_name(@@procid)

    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'

    if object_id('[db-au-cmdwh].dbo.entCustomerDemography') is null
    begin

        create table [db-au-cmdwh].dbo.entCustomerDemography
        (
            BIRowID bigint identity(1,1) not null,
            CustomerID bigint not null,
            RiskProfile varchar(50),
            AgeGroup varchar(50),
            ProductPreference varchar(50),
            ChannelPreference varchar(50),
            BrandAffiliation varchar(50),
            TravelPattern varchar(50),
            TravelGroup varchar(50),
            DestinationGroup varchar(50),
            LocationProfile varchar(50),
            OwnershipProfile varchar(50),
            SuburbRank decimal(4,2),
            UpdateBatchID bigint
        )

        create unique clustered index idx_cluster on [db-au-cmdwh]..entCustomerDemography (BIRowID)
        create index idx_customer on [db-au-cmdwh]..entCustomerDemography (CustomerID) include 
            (
                RiskProfile,
                AgeGroup,
                ProductPreference,
                ChannelPreference,
                BrandAffiliation,
                TravelPattern,
                TravelGroup,
                DestinationGroup,
                LocationProfile,
                OwnershipProfile,
                SuburbRank 
            )

    end

    if object_id('tempdb..#demo') is not null
        drop table #demo

    select
        CustomerID,
        CustomerName,
        FirstName,
        Lastname,
        Gender,
        DOB,
        CurrentAddress,
        CurrentEmail,
        ClaimScore,
        PrimaryScore,
        SecondaryScore
    into #demo
    from
        [db-au-cmdwh]..entCustomer t
    where
        CustomerID = MergedTo and
        (
            (
                @batchid <> -1 and
                UpdateBatchID = @batchid
            ) or
            (
                UpdateDate >= @start and
                UpdateDate <  dateadd(day, 1, @end)
            )
        )


    --risk profile
    if object_id('tempdb..#demorisk') is not null
        drop table #demorisk

    select 
        ec.CustomerID,
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
            else 'Low risk'
        end RiskProfile
    into #demorisk
    from
        #demo ec
        outer apply
        (
            select top 1 
                9001 BlockScore,
                1 BlockFlag
            from
                [db-au-cmdwh]..entBlacklist bl
            where
                bl.CustomerID = ec.CustomerID
        ) bl


    --age group
    if object_id('tempdb..#demoage') is not null
        drop table #demoage

    select 
        ec.CustomerID,
        case
            when datepart(year, ec.DOB) < 1925 then 'GI'
            when datepart(year, ec.DOB) < 1943 then 'Silent G'
            when datepart(year, ec.DOB) < 1970 then 'Baby boomers'
            when datepart(year, ec.DOB) < 1982 then 'Gen X'
            when datepart(year, ec.DOB) < 2005 then 'Millenials'
            else 'Unknown'
        end AgeGroup
    into #demoage
    from
        #demo ec

    --product preference
    if object_id('tempdb..#demoproduct') is not null
        drop table #demoproduct

    select 
        ec.CustomerID,
        case
            when ep.AllPolicyCount <> 0 and ep.BusinessCount * 1.00  / ep.AllPolicyCount >= 0.5 then 'Business'
            when ep.AllPolicyCount <> 0 and ep.PromoCount * 1.00  / ep.AllPolicyCount >= 0.5 then 'Bargain lover'
            when ep.AllPolicyCount <> 0 and ep.ValueCount * 1.00  / ep.AllPolicyCount >= 0.5 then 'Value'
            when ep.AllPolicyCount <> 0 and ep.PremiumCount * 1.00  / ep.AllPolicyCount >= 0.5 then 'Premium'
            else 'Basic'
        end ProductPreference
        --ep.*
    into #demoproduct
    from
        #demo ec
        cross apply
        (
            select 
                --p.PolicyNumber,
                --PromoCount
                sum(1) AllPolicyCount,
                sum(isnull(PromoCount, 0)) PromoCount,
                sum(isnull(ValueCount, 0)) ValueCount,
                sum(isnull(BusinessCount, 0)) BusinessCount,
                sum(isnull(PremiumCount, 0)) PremiumCount,
                sum(isnull(AverageJoeCount, 0)) AverageJoeCount
            from
                [db-au-cmdwh].dbo.penPolicy p with(nolock)
                outer apply
                (
                    select top 1 
                        1 PromoCount
                    from
                        [db-au-cmdwh].dbo.penPolicyTransSummary pt with(nolock)
                    where
                        pt.PolicyKey = p.PolicyKey and
                        (
                            pt.isPriceBeat = 1 or
                            pt.isExpo = 1 or
                            pt.GrossPremium < pt.UnAdjGrossPremium or
                            exists
                            (
                                select
                                    null
                                from
                                    [db-au-cmdwh].dbo.penPolicyTransactionPromo ptp with(nolock)
                                where
                                    ptp.PolicyTransactionKey = pt.PolicyTransactionKey and
                                    ptp.IsApplied = 1
                            )
                        )
                ) pp
                outer apply
                (
                    select top 1 
                        case 
                            when dpr.ProductClassification = 'Value' then 1 
                            else 0 
                        end ValueCount,
                        case 
                            when dpr.ProductClassification = 'Business' then 1 
                            when dpr.ProductClassification = 'Corporate' then 1
                            else 0 
                        end BusinessCount,
                        case 
                            when dpr.ProductClassification = 'Comprehensive' then 1 
                            else 0 
                        end PremiumCount,
                        case 
                            when dpr.ProductClassification = 'Value' then 0
                            when dpr.ProductClassification = 'Business' then 0
                            when dpr.ProductClassification = 'Corporate' then 0
                            when dpr.ProductClassification = 'Comprehensive' then 0
                            else 1
                        end AverageJoeCount
                    from
                        [db-au-star].dbo.dimPolicy dp with(nolock)
                        inner join [db-au-star].dbo.factPolicyTransaction fpt with(nolock) on
                            fpt.PolicySK = dp.PolicySK
                        inner join [db-au-star].dbo.dimProduct dpr with(nolock) on
                            dpr.ProductSK = fpt.ProductSK
                    where
                        dp.PolicyKey = p.PolicyKey and
                        dpr.ProductClassification = 'Value'
                ) pv
            where
                p.StatusDescription = 'Active' and
                p.PolicyKey in
                (
                    select 
                        ep.PolicyKey
                    from
                        [db-au-cmdwh].dbo.entPolicy ep with(nolock)
                    where
                        ep.CustomerID = ec.CustomerID and
                        ep.Claimkey is null
                )
        ) ep
    

    --channel preference
    if object_id('tempdb..#demochannel') is not null
        drop table #demochannel

    select
        ec.CustomerID,
        ChannelPreference
    into #demochannel
    from
        #demo ec
        cross apply
        (
            select top 1
                case
                    when AllPolicyCount = 0 then 'Mixed'
                    when PolicyCount * 1.00 / AllPolicyCount > 0.75 then Channel
                    else 'Mixed'
                end ChannelPreference
            from
                (
                    select --top 1
                        do.Channel,
                        count(ep.PolicyKey) over (partition by do.Channel) PolicyCount,
                        count(ep.PolicyKey) over () AllPolicyCount
                    from
                        [db-au-cmdwh].dbo.entPolicy ep with(nolock)
                        inner join [db-au-cmdwh].dbo.penPolicy p with(nolock) on
                            p.PolicyKey = ep.PolicyKey
                        inner join [db-au-star].dbo.dimOutlet do with(nolock) on
                            do.OutletAlphaKey = p.OutletAlphaKey and
                            do.isLatest = 'Y'
                    where
                        ep.CustomerID = ec.CustomerID and
                        ep.Claimkey is null
                ) t
            order by
                t.PolicyCount desc
        ) ep


    --brand affiliation & travel pattern
    if object_id('tempdb..#demotravel') is not null
        drop table #demotravel

    select 
        ec.CustomerID,
        case
            when ep.AllCount <= 1 then 'One-off traveller'
            when ep.AllCount >= 4 and ep.LongLeadTimeCount * 1.00 / ep.AllCount >= 0.6 then 'Planner'
            when ep.AllCount >= 4 then 'Frequent traveller'
            else 'Repeat traveller'
        end TravelPattern,
        case 
            when ep.AllCount >= 5 and ep.BrandCount = 1 then 'Strong brand affiliation'
            when ep.AllCount >= 5 and ep.BrandCount = 2 then 'Alternate affiliation'
            else 'No affiliation'
        end BrandAffiliation
        --,
        --ep.*
    into #demotravel
    from
        #demo ec
        cross apply
        (
            select 
                sum(1) AllCount,
                sum
                (
                    case
                        when datediff(day, p.IssueDate, p.TripStart) >= 214 then 1 --Pricing group 5, 6+ months
                       else 0
                    end 
                ) LongLeadTimeCount,
                count(distinct left(AlphaCode, 2)) BrandCount
            from
                [db-au-cmdwh].dbo.penPolicy p
            where
                p.StatusDescription = 'Active' and
                p.PolicyKey in
                (
                    select 
                        ep.PolicyKey
                    from
                        [db-au-cmdwh].dbo.entPolicy ep with(nolock)
                    where
                        ep.CustomerID = ec.CustomerID and
                        ep.Claimkey is null
                )
        ) ep
    


    --travel group
    if object_id('tempdb..#demotravelgroup') is not null
        drop table #demotravelgroup

    select 
        ec.CustomerID,
        --ec.CUstomerName,
        case
            --Family with kids
            --Family with adults
            --Couple
            --Group
            --Lone traveller
            --Mix
            when 
                (
                    ep.FamilyCount * 1.00 / ep.AllCount >= 0.6 or
                    ep.FamilyKidsCount * 1.00 / ep.AllCount >= 0.6
                ) and 
                ep.FamilyKidsCount >= ep.FamilyCount 
            then 'Family with kids'
            when 
                (
                    ep.FamilyCount * 1.00 / ep.AllCount >= 0.6 or
                    ep.FamilyKidsCount * 1.00 / ep.AllCount >= 0.6
                ) 
            then 'Family'
            when ep.CoupleCount * 1.00 / ep.AllCount >= 0.6 then 'Couple'
            when ep.singleCount * 1.00 / ep.AllCount >= 0.6 then 'Lone traveller'
            when ep.GroupCount * 1.00 / ep.AllCount >= 0.6 then 'Group'
            else 'Mix'
        end TravelGroup
        --,
        --ep.*
    into #demotravelgroup
    from
        #demo ec
        cross apply
        (
            select 
                --p.PolicyNumber,
                sum(1) AllCount,
                sum
                (
                    case
                        when 
                            isnull(rep.TravellersCount, 0) > 1 and
                            isnull(rep.TravellersCount, 0) = isnull(FamilyCount, 0) and
                            isnull(rep.TravellersCount, 0) = isnull(AdultCount, 0) 
                        then 1
                        else 0
                    end
                ) FamilyCount,
                sum
                (
                    case
                        when 
                            isnull(rep.TravellersCount, 0) > 1 and
                            isnull(rep.TravellersCount, 0) = isnull(FamilyCount, 0) and
                            isnull(rep.TravellersCount, 0) > isnull(AdultCount, 0) 
                        then 1
                        else 0
                    end
                ) FamilyKidsCount,
                sum
                (
                    case
                        when 
                            isnull(rep.TravellersCount, 0) = 2 and
                            isnull(rep.TravellersCount, 0) = isnull(AdultCount, 0) 
                        then 1
                        else 0
                    end
                ) CoupleCount,
                sum
                (
                    case
                        when 
                            isnull(rep.TravellersCount, 0) = 1 and
                            isnull(rep.TravellersCount, 0) = isnull(AdultCount, 0) 
                        then 1
                        else 0
                    end
                ) SingleCount,
                sum
                (
                    case
                        when isnull(rep.TravellersCount, 0) >= 10 then 1
                        else 0
                    end
                ) GroupCount
                --sum(isnull(rep.TravellersCount, 0)) TravellersCount,
                --sum(isnull(rep.FamilyCount, 0)) FamilyCount2,
                --sum(isnull(rep.AdultCount, 0)) AdultCount
            from
                [db-au-cmdwh].dbo.penPolicy p with(nolock)
                outer apply
                (
                    select 
                        sum(1) TravellersCount,
                        sum(Family) FamilyCount,
                        sum(IsAdult) AdultCount
                    from
                        (
                            select 
                                case
                                    when rec.LastName = ec.LastName then 1
                                    when rec.CurrentAddress = ec.CurrentAddress then 1
                                    else 0
                                end Family,
                                case
                                    when datediff(year, rec.DOB, p.IssueDate) >= 18 then 1
                                    else 0
                                end IsAdult
                            from
                                [db-au-cmdwh].dbo.entCustomer rec with(nolock)
                            where
                                rec.CustomerID in
                                (
                                    select
                                        rep.CustomerID
                                    from
                                        [db-au-cmdwh].dbo.entPolicy rep with(nolock)
                                    where
                                        rep.PolicyKey = p.PolicyKey
                                )
                        ) t
                ) rep
            where
                p.StatusDescription = 'Active' and
                p.PolicyKey in
                (
                    select 
                        ep.PolicyKey
                    from
                        [db-au-cmdwh].dbo.entPolicy ep with(nolock)
                    where
                        ep.CustomerID = ec.CustomerID and
                        ep.Claimkey is null
                )
            --group by
            --    p.PolicyNumber
        ) ep




    --destination group
    if object_id('tempdb..#demodestinationgroup') is not null
        drop table #demodestinationgroup

    select
        ec.CustomerID,
        --ec.CUstomerName,
        case
            when ep.AllCount <> 0 and ep.LocalCount * 1.00 / ep.AllCount >= 0.90 then 'Local traveller'
            when ep.AllCount <> 0 and ep.CruiseCount * 1.00 / ep.AllCount >= 0.90 then 'Cruiser'
            when ep.AllCount > 3 and ep.DestinationCount = 1 and ep.LocalCount * 1.00 / ep.AllCount <= 0.25 then 'Going home'
            when ep.AllCount > 3 and ep.AfricaCount * 1.00 / ep.AllCount >= 0.75 then 'Africa'
            when ep.AllCount > 3 and ep.AsiaCount * 1.00 / ep.AllCount >= 0.75 then 'Asia'
            when ep.AllCount > 3 and ep.EuropeCount * 1.00 / ep.AllCount >= 0.75 then 'Europe'
            when ep.AllCount > 3 and ep.OceaniaCount * 1.00 / ep.AllCount >= 0.75 then 'Oceania'
            when ep.AllCount > 3 and ep.AmericaCount * 1.00 / ep.AllCount >= 0.75 then 'America'
            when 
                (
                    (
                        case when ep.AfricaCount > 0 then 1 else 0 end +
                        case when ep.AsiaCount > 0 then 1 else 0 end +
                        case when ep.EuropeCount > 0 then 1 else 0 end +
                        case when ep.OceaniaCount > 0 then 1 else 0 end +
                        case when ep.AmericaCount > 0 then 1 else 0 end
                    ) >= 4 or
                    ep.DestinationCount >= 7
                ) and
                ep.LocalCount * 1.00 / ep.AllCount <= 0.25 then 'World Explorer'
            else 'Mix'
        end Destination
        --,
        --ep.*
    into #demodestinationgroup
    from
        #demo ec
        cross apply
        (
            select 
                sum(1) AllCount,
                sum
                (
                    case
                        when p.CountryKey = 'AU' and p.PrimaryCountry = 'Australia' then 1
                        when p.CountryKey = 'NZ' and p.PrimaryCountry = 'New Zealand' then 1
                        else 0
                    end 
                ) LocalCount,
                sum
                (
                    case
                        when p.PrimaryCountry like '%cruise%' then 1
                        when isnull(pta.CruisePremium, 0) > 0 then 1
                        else 0
                    end 
                ) CruiseCount,
                count
                (
                    distinct
                    case
                        when p.CountryKey = 'AU' and p.PrimaryCountry = 'Australia' then null
                        when p.CountryKey = 'NZ' and p.PrimaryCountry = 'New Zealand' then null
                        else p.PrimaryCountry
                    end 
                ) DestinationCount,
                sum
                (
                    case
                        when co.Continent = 'Africa' then 1
                        else 0
                    end
                ) AfricaCount,
                sum
                (
                    case
                        when co.Continent = 'Asia' then 1
                        else 0
                    end
                ) AsiaCount,
                sum
                (
                    case
                        when co.Continent = 'Europe' then 1
                        else 0
                    end
                ) EuropeCount,
                sum
                (
                    case
                        when co.Continent = 'Oceania' then 1
                        when co.Continent = 'Antarctica' then 1
                        else 0
                    end
                ) OceaniaCount,
                sum
                (
                    case
                        when co.Continent = 'North America' then 1
                        when co.Continent = 'South America' then 1
                        else 0
                    end
                ) AmericaCount
            from
                [db-au-cmdwh].dbo.penPolicy p with(nolock)
                outer apply
                (
                    select top 1 
                        dd.Continent
                    from
                        [db-au-star].dbo.dimPolicy dp with(nolock)
                        inner join [db-au-star].dbo.factPolicyTransaction fpt with(nolock) on
                            fpt.PolicySK = dp.PolicySK
                        inner join [db-au-star].dbo.dimDestination dd with(nolock) on
                            dd.DestinationSK = fpt.DestinationSK
                    where
                        dp.PolicyKey = p.PolicyKey
                ) co
                outer apply
                (
                    select
                        sum(pta.GrossPremium) CruisePremium
                    from
                        [db-au-cmdwh].dbo.penPolicyTransSummary pt with(nolock)
                        inner join [db-au-cmdwh].dbo.penPolicyTransAddOn pta with(nolock) on
                            pta.PolicyTransactionKey = pt.PolicyTransactionKey
                    where
                        pt.PolicyKey = p.PolicyKey and
                        pta.AddOnGroup = 'Cruise'
                ) pta
            where
                p.StatusDescription = 'Active' and
                p.PolicyKey in
                (
                    select 
                        ep.PolicyKey
                    from
                        [db-au-cmdwh].dbo.entPolicy ep with(nolock)
                    where
                        ep.CustomerID = ec.CustomerID and
                        ep.Claimkey is null
                )
        ) ep


    --location demo
    if object_id('tempdb..#demosuburb') is not null
        drop table #demosuburb

    select
        ec.CustomerID,
        --ec.CUstomerName,
        --ec.CurrentAddress,
        --ea.PostCode,
        --ea.Suburb,
        sp.DemographyLocation,
        sp.DemographyOwnership,
        sp.DemographyRank
    into #demosuburb
    from
        #demo ec
        cross apply
        (
            select top 1
                ea.PostCode,
                ea.Suburb
            from
                [db-au-cmdwh]..entAddress ea with(nolock)
            where
                ea.CustomerID = ec.CustomerID and
                ea.CountryCode = 'AUS'
            order by
                UpdateDate desc
        ) ea
        outer apply
        (
            select top 1 
                DemographyLocation,
                DemographyOwnership,
                DemographyRank
            from
                [db-au-cmdwh]..usrSuburbProfile sp with(nolock)
            where
                sp.PostCode = ea.PostCode
            order by
                case
                    when sp.Suburb = ea.Suburb then 1
                    else 2
                end
        ) sp

    begin transaction

    begin try

        --combine
        delete 
        from
            [db-au-cmdwh]..entCustomerDemography
        where
            CustomerID in
            (
                select
                    CustomerID
                from
                    #demo
            )

        insert into [db-au-cmdwh]..entCustomerDemography
        (
            CustomerID,
            RiskProfile,
            AgeGroup,
            ProductPreference,
            ChannelPreference,
            BrandAffiliation,
            TravelPattern,
            TravelGroup,
            DestinationGroup,
            LocationProfile,
            OwnershipProfile,
            SuburbRank,
            UpdateBatchID
        )
        select 
            ec.CustomerID,
            isnull(dr.RiskProfile, 'Unknown') RiskProfile,
            isnull(da.AgeGroup, 'Unknown') AgeGroup,
            isnull(dp.ProductPreference, 'Unknown') ProductPreference,
            isnull(dc.ChannelPreference, 'Unknown') ChannelPreference,
            isnull(dt.TravelPattern, 'Unknown') TravelPattern,
            isnull(dt.BrandAffiliation, 'Unknown') BrandAffiliation,
            isnull(dtg.TravelGroup, 'Unknown') TravelGroup,
            isnull(ddg.Destination, 'Unknown') DestinationGroup,
            isnull(ds.DemographyLocation, 'Unknown') LocationProfile,
            isnull(ds.DemographyOwnership, 'Unknown') OwnershipProfile,
            isnull(ds.DemographyRank, 0) SuburbRank,
            @batchid
        from
            #demo ec
            outer apply
            (
                select 
                    dr.RiskProfile
                from
                    #demorisk dr
                where
                    dr.CustomerID = ec.CustomerID
            ) dr
            outer apply
            (
                select 
                    da.AgeGroup
                from
                    #demoage da
                where
                    da.CustomerID = ec.CustomerID
            ) da
            outer apply
            (
                select 
                    dp.ProductPreference
                from
                    #demoproduct dp
                where
                    dp.CustomerID = ec.CustomerID
            ) dp
            outer apply
            (
                select 
                    dc.ChannelPreference
                from
                    #demochannel dc
                where
                    dc.CustomerID = ec.CustomerID
            ) dc
            outer apply
            (
                select 
                    dt.TravelPattern,
                    dt.BrandAffiliation
                from
                    #demotravel dt
                where
                    dt.CustomerID = ec.CustomerID
            ) dt
            outer apply
            (
                select 
                    dtg.TravelGroup
                from
                    #demotravelgroup dtg
                where
                    dtg.CustomerID = ec.CustomerID
            ) dtg
            outer apply
            (
                select 
                    ddg.Destination
                from
                    #demodestinationgroup ddg
                where
                    ddg.CustomerID = ec.CustomerID
            ) ddg
            outer apply
            (
                select 
                    ds.DemographyLocation,
                    ds.DemographyOwnership,
                    ds.DemographyRank
                from
                    #demosuburb ds
                where
                    ds.CustomerID = ec.CustomerID
            ) ds
    
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
            @SourceInfo = 'entCustomer data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction

end
GO
