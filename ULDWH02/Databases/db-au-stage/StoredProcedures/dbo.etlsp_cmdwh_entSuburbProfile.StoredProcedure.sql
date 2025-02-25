USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_entSuburbProfile]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_entSuburbProfile]
as
begin

    if object_id('tempdb..#dump') is not null
        drop table #dump

    select 
        --sp.CountryDomain,
        sp.PostCode,
        sp.Suburb,
        sp.State,
        isnull(SuburbAvgAge, 'Unknown') SuburbAvgAge,
        NearestCity,
        DistanceToCity,
        case
            when 
                Suburb in 
                (
                    'Sydney',
                    'Launceston',
                    'Bunbury',
                    'Darwin',
                    'Geelong',
                    'Perth',
                    'Hobart',
                    'Adelaide',
                    'Melbourne',
                    'Canberra',
                    'Brisbane',
                    'Newcastle'
                )
            then 0
            when NearestCity is null then 1000
            when DistanceToCity = '--' then 1000
            when charindex('hour', DistanceToCity) = 0 then try_convert(int, left(DistanceToCity, charindex(' ', DistanceToCity)))
            else 
                try_convert(int, left(DistanceToCity, charindex(' ', DistanceToCity))) * 60 + 
                try_convert(int, left(substring(DistanceToCity, charindex(' ', DistanceToCity, charindex(' ', DistanceToCity) + 1) + 1, 100), 2))
        end DrivingDistanceToCityInMinutes,
        try_convert(decimal(5,2), isnull(Owned, 0)) Owned,
        try_convert(decimal(5,2), isnull(Purchasing, 0)) Purchasing,
        try_convert(decimal(5,2), isnull(Renting, 0)) Renting,
        try_convert(int, isnull(House2BCount, 0)) House2BCount,
        try_convert(int, isnull(House2BMedian, 0)) House2BMedian,
        try_convert(int, isnull(House3BCount, 0)) House3BCount,
        try_convert(int, isnull(House3BMedian, 0)) House3BMedian,
        try_convert(int, isnull(House4BCount, 0)) House4BCount,
        try_convert(int, isnull(House4BMedian, 0)) House4BMedian,
        try_convert(int, isnull(Unit1BCount, 0)) Unit1BCount,
        try_convert(int, isnull(Unit1BMedian, 0)) Unit1BMedian,
        try_convert(int, isnull(Unit2BCount, 0)) Unit2BCount,
        try_convert(int, isnull(Unit2BMedian, 0)) Unit2BMedian,
        try_convert(int, isnull(Unit3BCount, 0)) Unit3BCount,
        try_convert(int, isnull(Unit3BMedian, 0)) Unit3BMedian
    into #dump
    from
        [db-au-cmdwh]..usrSuburbProfile sp
        cross apply
        (
            select
                json_value(sp.JSONData, '$.average_age') SuburbAvgAge,
                json_value(sp.JSONData, '$.nearest_city') NearestCity,
                json_value(sp.JSONData, '$.nearest_city_travel_car') DistanceToCity,
                json_value(sp.JSONData, '$.fully_owned') Owned,
                json_value(sp.JSONData, '$.purchasing') Purchasing,
                json_value(sp.JSONData, '$.renting') Renting,
                json_value(sp.JSONData, '$.market_data."2bdHouse".numbersold') House2BCount,
                json_value(sp.JSONData, '$.market_data."2bdHouse".mediansoldprice') House2BMedian,
                json_value(sp.JSONData, '$.market_data."3bdHouse".numbersold') House3BCount,
                json_value(sp.JSONData, '$.market_data."3bdHouse".mediansoldprice') House3BMedian,
                json_value(sp.JSONData, '$.market_data."4bdHouse".numbersold') House4BCount,
                json_value(sp.JSONData, '$.market_data."4bdHouse".mediansoldprice') House4BMedian,
                json_value(sp.JSONData, '$.market_data."1bdUnit".numbersold') Unit1BCount,
                json_value(sp.JSONData, '$.market_data."1bdUnit".mediansoldprice') Unit1BMedian,
                json_value(sp.JSONData, '$.market_data."2bdUnit".numbersold') Unit2BCount,
                json_value(sp.JSONData, '$.market_data."2bdUnit".mediansoldprice') Unit2BMedian,
                json_value(sp.JSONData, '$.market_data."3bdUnit".numbersold') Unit3BCount,
                json_value(sp.JSONData, '$.market_data."3bdUnit".mediansoldprice') Unit3BMedian
        ) jd
    where
        sp.CountryDomain = 'AU'

    if object_id('tempdb..#median') is not null
        drop table #median

    select 
        PostCode,
        Suburb,
        State,
        case
            when DrivingDistanceToCityInMinutes < 30 then 'Metropolitan'
            when DrivingDistanceToCityInMinutes < 120 then 'Suburban'
            else 'Rural'
        end LocationDemo,
        case
            when Owned + Purchasing > 0.8 then 'Owned'
            when Purchasing > 0.5 then 'Purchasing'
            when Renting > 0.5 then 'Rental'
            else 'Mixed'
        end Ownership,
        MedianPrice,
        NearestCity,
        DrivingDistanceToCityInMinutes
    into #median
    from
        #dump t
        cross apply
        (
            select 
                max(MedianPrice) MedianPrice
            from
                (
                    select t.House2BMedian MedianPrice
                    union all
                    select t.House3BMedian
                    union all
                    select t.House3BMedian
                    union all
                    select t.Unit1BMedian
                    union all
                    select t.Unit2BMedian
                    union all
                    select t.Unit1BMedian
                ) r
        ) m

    if object_id('tempdb..#ranked') is not null
        drop table #ranked

    select 
        PostCode,
        Suburb,
        State,
        LocationDemo DemographyLocation,
        Ownership DemographyOwnership,
        --t.MedianPrice,
        --t.DrivingDistanceToCityInMinutes,
        percent_rank() over (partition by State order by mp.MedianPrice) DemographyRank
    into #ranked
    from
        #median t
        outer apply
        (
            select top 1
                r.MedianPrice
            from
                #median r
            where
                t.NearestCity = r.Suburb + ', ' + r.State
        ) c
        outer apply
        (
            select 
                case
                    when t.MedianPrice <> 0 then t.MedianPrice
                    when t.DrivingDistanceToCityInMinutes <= 20 then c.MedianPrice
                    when t.DrivingDistanceToCityInMinutes <= 60 then c.MedianPrice * 0.8
                    when t.DrivingDistanceToCityInMinutes <= 90 then c.MedianPrice * 0.7
                    when t.DrivingDistanceToCityInMinutes <= 120 then c.MedianPrice * 0.6
                    else isnull(c.MedianPrice * 1 / (t.DrivingDistanceToCityInMinutes * 1.00 / 120), 100000)
                end MedianPrice
        ) mp
    --order by
    --    8 desc 

    update sp
    set
        sp.DemographyLocation = r.DemographyLocation,
        sp.DemographyOwnership = r.DemographyOwnership,
        sp.DemographyRank = r.DemographyRank * 10
    from
        [db-au-cmdwh]..usrSuburbProfile sp
        cross apply
        (
            select top 1 
                r.DemographyLocation,
                r.DemographyOwnership,
                r.DemographyRank
            from
                #ranked r
            where
                r.PostCode = sp.PostCode and
                r.Suburb = sp.Suburb
        ) r
    where
        sp.CountryDomain = 'AU'

end

GO
