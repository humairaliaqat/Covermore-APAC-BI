USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL054_RedshiftQuote_ProcessImpulse]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL054_RedshiftQuote_ProcessImpulse]
as
begin
/************************************************************************************************************************************
Author:         Leonardus S L
Date:           20160201
Description:    process Impulse data
Parameters:     
Change History:
                20160201 - LS - create
                20160422 - LS - whitelist transaction hour MA for migrated business units
                                whitelist specific migration date
                20160531 - LS - MB, re-enable bot processing
                                set quote history avg to start after migration date
                20161115 - LL - AHM, no bot processing in the first 3 months

*************************************************************************************************************************************/

    set nocount on

    execute
    (
    '
    drop table if exists process_cdgquote
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_cdgquote
    as
    select 
        q.PlatformVersion,
        q.AnalyticsSessionID,
        q.BusinessUnitID,
        q.OutletGroup,
        cast(q.TransactionTime as date) QuoteDate,
        q.CampaignSessionID,
        q.ImpressionID,
        q.TransactionHour,
        q.Destination,
        q.Duration,
        q.LeadTime,
        q.TravellerAge Age,
        q.NumAdults AdultCount,
        q.NumChildren ChildrenCount,
        q.ConvertedFlag,
        q.isPrimaryTraveller,
        max(isnull(b.BotFlag, 0)) BotFlag
    from
        innate_quote q
        left join innate_quote_ma b on
            q.PlatformVersion = b.PlatformVersion and
            q.AnalyticsSessionID = b.AnalyticsSessionID
    where
        isDeleted = 0 and
        TransactionTime >= dateadd(month, -6, dateadd(day, -15, getdate()))
    group by
        q.PlatformVersion,
        q.AnalyticsSessionID,
        q.BusinessUnitID,
        q.OutletGroup,
        cast(q.TransactionTime as date),
        q.CampaignSessionID,
        q.ImpressionID,
        q.TransactionHour,
        q.Destination,
        q.Duration,
        q.LeadTime,
        q.TravellerAge,
        q.NumAdults,
        q.NumChildren,
        q.ConvertedFlag,
        q.isPrimaryTraveller,
        isnull(b.BotFlag, 0)
    '
    ) at [CMDWH-REDSHIFT-PROD]

    raiserror('data dumped', 1, 1) with nowait

    --destination    
    execute
    (
    '
    drop table if exists process_cdgquote_destination
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_cdgquote_destination
    as
    select 
        BusinessUnitID,
        OutletGroup,
        Destination,
        QuoteDate,
        row_number() over (partition by BusinessUnitID,OutletGroup,Destination order by QuoteDate) RowNum,
        cast(count(distinct ImpressionID) as float) QuoteCount,
        cast(count(distinct case when BotFlag = 1 then ImpressionID else null end) as float) BotCount
    from
        process_cdgquote
    group by
        BusinessUnitID,
        OutletGroup,
        Destination,
        QuoteDate
    '
    ) at [CMDWH-REDSHIFT-PROD]

    --select *
    --from
    --    openquery
    --    (
    --        [CMDWH-REDSHIFT-PROD],
    --        '
    --        select top 1000 * 
    --        from 
    --            process_cdgquote_destination
    --        where
    --            botcount > 0
    --        '
    --    )

    execute
    (
    '
    drop table if exists process_cdgquote_destination_rank
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_cdgquote_destination_rank
    as
    select 
        *,
        cast(QuoteDate as varchar(7)) QuoteMonth,
        row_number() over (partition by BusinessUnitID,OutletGroup,Destination,cast(QuoteDate as varchar(7)) order by QuoteCount desc) RankInMonth,
        count(QuoteDate) over (partition by BusinessUnitID,OutletGroup,Destination,cast(QuoteDate as varchar(7))) RecordNum
    from
        process_cdgquote_destination
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_cdgquote_destination_outlier
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_cdgquote_destination_outlier
    as
    select 
        *,
        case
            when RecordNum < 3 then 0
            when RankInMonth <= 0.15 * RecordNum then 1
            when RankInMonth >= 0.75 * RecordNum then 1
            else 0
        end isOutlier
    from
        process_cdgquote_destination_rank
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_cdgquote_destination_ma
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_cdgquote_destination_ma
    as
    select 
        BusinessUnitID,
        OutletGroup,
        Destination,
        QuoteDate,
        RowNum,
        QuoteCount,
        RankInMonth,
        isOutlier,
        coalesce
        (
            (
                select 
                    avg(r.QuoteCount - r.BotCount)
                from
                    process_cdgquote_destination_outlier r
                where
                    r.BusinessUnitID = t.BusinessUnitID and
                    r.OutletGroup = t.OutletGroup and
                    r.Destination = t.Destination and
                    --hard-coded MA window, no sub-sub-query in redshift
                    r.RowNum < t.RowNum and
                    r.RowNum >= t.RowNum - 90 and
                    r.isOutlier = 0
                    --migration aware part
                    and
                    (
                        BusinessUnitID not in (32) or 
                        (
                            BusinessUnitID = 32 and
                            (
                                (
                                    t.QuoteDate >= ''2016-04-19'' and
                                    r.QuoteDate >= ''2016-04-19''
                                ) or
                                t.QuoteDate < ''2016-04-19''
                            )
                        )
                    )
            ),
            t.QuoteCount
        ) DestinationMA
    from
        process_cdgquote_destination_outlier t
    '
    ) at [CMDWH-REDSHIFT-PROD]

    raiserror('destination processed', 1, 1) with nowait

    --duration    
    execute
    (
    '
    drop table if exists process_cdgquote_duration
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_cdgquote_duration
    as
    select 
        BusinessUnitID,
        OutletGroup,
        duration,
        QuoteDate,
        row_number() over (partition by BusinessUnitID,OutletGroup,duration order by QuoteDate) RowNum,
        cast(count(distinct ImpressionID) as float) QuoteCount,
        cast(count(distinct case when BotFlag = 1 then ImpressionID else null end) as float) BotCount
    from
        process_cdgquote
    group by
        BusinessUnitID,
        OutletGroup,
        duration,
        QuoteDate
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_cdgquote_duration_rank
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_cdgquote_duration_rank
    as
    select 
        *,
        cast(QuoteDate as varchar(7)) QuoteMonth,
        row_number() over (partition by BusinessUnitID,OutletGroup,duration,cast(QuoteDate as varchar(7)) order by QuoteCount desc) RankInMonth,
        count(QuoteDate) over (partition by BusinessUnitID,OutletGroup,duration,cast(QuoteDate as varchar(7))) RecordNum
    from
        process_cdgquote_duration
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_cdgquote_duration_outlier
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_cdgquote_duration_outlier
    as
    select 
        *,
        case
            when RecordNum < 3 then 0
            when RankInMonth <= 0.15 * RecordNum then 1
            when RankInMonth >= 0.75 * RecordNum then 1
            else 0
        end isOutlier
    from
        process_cdgquote_duration_rank
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_cdgquote_duration_ma
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_cdgquote_duration_ma
    as
    select 
        BusinessUnitID,
        OutletGroup,
        duration,
        QuoteDate,
        RowNum,
        QuoteCount,
        RankInMonth,
        isOutlier,
        coalesce
        (
            (
                select 
                    avg(r.QuoteCount - r.BotCount)
                from
                    process_cdgquote_duration_outlier r
                where
                    r.BusinessUnitID = t.BusinessUnitID and
                    r.OutletGroup = t.OutletGroup and
                    r.duration = t.duration and
                    --hard-coded MA window, no sub-sub-query in redshift
                    r.RowNum < t.RowNum and
                    r.RowNum >= t.RowNum - 90 and
                    r.isOutlier = 0
                    --migration aware part
                    and
                    (
                        BusinessUnitID not in (32) or 
                        (
                            BusinessUnitID = 32 and
                            (
                                (
                                    t.QuoteDate >= ''2016-04-19'' and
                                    r.QuoteDate >= ''2016-04-19''
                                ) or
                                t.QuoteDate < ''2016-04-19''
                            )
                        )
                    )
            ),
            t.QuoteCount
        ) durationMA
    from
        process_cdgquote_duration_outlier t
    '
    ) at [CMDWH-REDSHIFT-PROD]

    raiserror('duration processed', 1, 1) with nowait

    --leadtime
    execute
    (
    '
    drop table if exists process_cdgquote_leadtime
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_cdgquote_leadtime
    as
    select 
        BusinessUnitID,
        OutletGroup,
        leadtime,
        QuoteDate,
        row_number() over (partition by BusinessUnitID,OutletGroup,leadtime order by QuoteDate) RowNum,
        cast(count(distinct ImpressionID) as float) QuoteCount,
        cast(count(distinct case when BotFlag = 1 then ImpressionID else null end) as float) BotCount
    from
        process_cdgquote
    group by
        BusinessUnitID,
        OutletGroup,
        leadtime,
        QuoteDate
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_cdgquote_leadtime_rank
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_cdgquote_leadtime_rank
    as
    select 
        *,
        cast(QuoteDate as varchar(7)) QuoteMonth,
        row_number() over (partition by BusinessUnitID,OutletGroup,leadtime,cast(QuoteDate as varchar(7)) order by QuoteCount desc) RankInMonth,
        count(QuoteDate) over (partition by BusinessUnitID,OutletGroup,leadtime,cast(QuoteDate as varchar(7))) RecordNum
    from
        process_cdgquote_leadtime
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_cdgquote_leadtime_outlier
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_cdgquote_leadtime_outlier
    as
    select 
        *,
        case
            when RecordNum < 3 then 0
            when RankInMonth <= 0.15 * RecordNum then 1
            when RankInMonth >= 0.75 * RecordNum then 1
            else 0
        end isOutlier
    from
        process_cdgquote_leadtime_rank
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_cdgquote_leadtime_ma
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_cdgquote_leadtime_ma
    as
    select 
        BusinessUnitID,
        OutletGroup,
        leadtime,
        QuoteDate,
        RowNum,
        QuoteCount,
        RankInMonth,
        isOutlier,
        coalesce
        (
            (
                select 
                    avg(r.QuoteCount - r.BotCount)
                from
                    process_cdgquote_leadtime_outlier r
                where
                    r.BusinessUnitID = t.BusinessUnitID and
                    r.OutletGroup = t.OutletGroup and
                    r.leadtime = t.leadtime and
                    --hard-coded MA window, no sub-sub-query in redshift
                    r.RowNum < t.RowNum and
                    r.RowNum >= t.RowNum - 90 and
                    r.isOutlier = 0
                    --migration aware part
                    and
                    (
                        BusinessUnitID not in (32) or 
                        (
                            BusinessUnitID = 32 and
                            (
                                (
                                    t.QuoteDate >= ''2016-04-19'' and
                                    r.QuoteDate >= ''2016-04-19''
                                ) or
                                t.QuoteDate < ''2016-04-19''
                            )
                        )
                    )
            ),
            t.QuoteCount
        ) leadtimeMA
    from
        process_cdgquote_leadtime_outlier t
    '
    ) at [CMDWH-REDSHIFT-PROD]

    raiserror('leadtime processed', 1, 1) with nowait

    --age
    execute
    (
    '
    drop table if exists process_cdgquote_age
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_cdgquote_age
    as
    select 
        BusinessUnitID,
        OutletGroup,
        age,
        QuoteDate,
        row_number() over (partition by BusinessUnitID,OutletGroup,age order by QuoteDate) RowNum,
        cast(count(distinct ImpressionID) as float) QuoteCount,
        cast(count(distinct case when BotFlag = 1 then ImpressionID else null end) as float) BotCount
    from
        process_cdgquote
    group by
        BusinessUnitID,
        OutletGroup,
        age,
        QuoteDate
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_cdgquote_age_rank
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_cdgquote_age_rank
    as
    select 
        *,
        cast(QuoteDate as varchar(7)) QuoteMonth,
        row_number() over (partition by BusinessUnitID,OutletGroup,age,cast(QuoteDate as varchar(7)) order by QuoteCount desc) RankInMonth,
        count(QuoteDate) over (partition by BusinessUnitID,OutletGroup,age,cast(QuoteDate as varchar(7))) RecordNum
    from
        process_cdgquote_age
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_cdgquote_age_outlier
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_cdgquote_age_outlier
    as
    select 
        *,
        case
            when RecordNum < 3 then 0
            when RankInMonth <= 0.15 * RecordNum then 1
            when RankInMonth >= 0.75 * RecordNum then 1
            else 0
        end isOutlier
    from
        process_cdgquote_age_rank
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_cdgquote_age_ma
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_cdgquote_age_ma
    as
    select 
        BusinessUnitID,
        OutletGroup,
        age,
        QuoteDate,
        RowNum,
        QuoteCount,
        RankInMonth,
        isOutlier,
        coalesce
        (
            (
                select 
                    avg(r.QuoteCount - r.BotCount)
                from
                    process_cdgquote_age_outlier r
                where
                    r.BusinessUnitID = t.BusinessUnitID and
                    r.OutletGroup = t.OutletGroup and
                    r.age = t.age and
                    --hard-coded MA window, no sub-sub-query in redshift
                    r.RowNum < t.RowNum and
                    r.RowNum >= t.RowNum - 90 and
                    r.isOutlier = 0
                    --migration aware part
                    and
                    (
                        BusinessUnitID not in (32) or 
                        (
                            BusinessUnitID = 32 and
                            (
                                (
                                    t.QuoteDate >= ''2016-04-19'' and
                                    r.QuoteDate >= ''2016-04-19''
                                ) or
                                t.QuoteDate < ''2016-04-19''
                            )
                        )
                    )
            ),
            t.QuoteCount
        ) ageMA
    from
        process_cdgquote_age_outlier t
    '
    ) at [CMDWH-REDSHIFT-PROD]

    raiserror('age processed', 1, 1) with nowait


    --transactionhour
    execute
    (
    '
    drop table if exists process_cdgquote_transactionhour
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_cdgquote_transactionhour
    as
    select 
        BusinessUnitID,
        OutletGroup,
        transactionhour,
        QuoteDate,
        row_number() over (partition by BusinessUnitID,OutletGroup,transactionhour order by QuoteDate) RowNum,
        cast(count(distinct ImpressionID) as float) QuoteCount,
        cast(count(distinct case when BotFlag = 1 then ImpressionID else null end) as float) BotCount
    from
        process_cdgquote
    group by
        BusinessUnitID,
        OutletGroup,
        transactionhour,
        QuoteDate
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_cdgquote_transactionhour_rank
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_cdgquote_transactionhour_rank
    as
    select 
        *,
        cast(QuoteDate as varchar(7)) QuoteMonth,
        row_number() over (partition by BusinessUnitID,OutletGroup,transactionhour,cast(QuoteDate as varchar(7)) order by QuoteCount desc) RankInMonth,
        count(QuoteDate) over (partition by BusinessUnitID,OutletGroup,transactionhour,cast(QuoteDate as varchar(7))) RecordNum
    from
        process_cdgquote_transactionhour
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_cdgquote_transactionhour_outlier
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_cdgquote_transactionhour_outlier
    as
    select 
        *,
        case
            when RecordNum < 3 then 0
            when RankInMonth <= 0.15 * RecordNum then 1
            when RankInMonth >= 0.75 * RecordNum then 1
            else 0
        end isOutlier
    from
        process_cdgquote_transactionhour_rank
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_cdgquote_transactionhour_ma
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_cdgquote_transactionhour_ma
    as
    select 
        BusinessUnitID,
        OutletGroup,
        transactionhour,
        QuoteDate,
        RowNum,
        QuoteCount,
        RankInMonth,
        isOutlier,
        coalesce
        (
            (
                select 
                    avg(r.QuoteCount - r.BotCount)
                from
                    process_cdgquote_transactionhour_outlier r
                where
                    r.BusinessUnitID = t.BusinessUnitID and
                    r.OutletGroup = t.OutletGroup and
                    r.transactionhour = t.transactionhour and
                    --hard-coded MA window, no sub-sub-query in redshift
                    r.RowNum < t.RowNum and
                    r.RowNum >= t.RowNum - 90 and
                    r.isOutlier = 0
                    --migration aware part
                    and
                    (
                        BusinessUnitID not in (32) or 
                        (
                            BusinessUnitID = 32 and
                            (
                                (
                                    t.QuoteDate >= ''2016-04-19'' and
                                    r.QuoteDate >= ''2016-04-19''
                                ) or
                                t.QuoteDate < ''2016-04-19''
                            )
                        )
                    )
            ),
            t.QuoteCount
        ) transactionhourMA
    from
        process_cdgquote_transactionhour_outlier t
    '
    ) at [CMDWH-REDSHIFT-PROD]


    raiserror('transactionhour processed', 1, 1) with nowait

    --overall ma
    execute
    (
    '
    drop table if exists ma_cdgquote
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table ma_cdgquote
    as
    select
        a.platformversion,
        a.analyticssessionid,
        a.BusinessUnitID,
        a.QuoteDate,
        case 
            when DestinationMA = 0 then 0 
            else (b.QuoteCount - DestinationMA) / DestinationMA
        end as DestinationMA,
        case 
            when DurationMA = 0 then 0 
            /*specific treatment for RACV*/
            when (a.BusinessUnitID = 14) and ((a.Duration % 7) = 0) then (c.QuoteCount - (DurationMA / 8)) / (DurationMA / 8)
            when (a.BusinessUnitID = 14) and ((a.Duration % 30) = 0) then (c.QuoteCount - (DurationMA / 8)) / (DurationMA / 8)

            when (a.Duration >= 28) and ((a.Duration % 7) = 0) then (c.QuoteCount - (DurationMA / 8)) / (DurationMA / 8)
            when (a.Duration > 30) and ((a.Duration % 30) = 0) then (c.QuoteCount - (DurationMA / 8)) / (DurationMA / 8)
            else (c.QuoteCount - DurationMA) / DurationMA
        end as DurationMA,
        case 
            when LeadTimeMA = 0 then 0 
            else (d.QuoteCount - LeadTimeMA) / LeadTimeMA
        end as LeadTimeMA,
        case 
            when AgeMA = 0 then 0 
            /*specific treatment for RACV*/
            when (a.BusinessUnitID = 14) and (a.Age >= 70) then (e.QuoteCount - (AgeMA / 4)) / (AgeMA / 4)
            else (e.QuoteCount - AgeMA) / AgeMA
        end as AgeMA,
        case 
            when TransactionHourMA = 0 then 0 
            /*specific treatment for migrated business unit (impulse 1 -> 2) due to timezone diff*/
            /*MB*/
            when (a.BusinessUnitID in (32)) then (f.QuoteCount - TransactionHourMA) / TransactionHourMA / 6
            else (f.QuoteCount - TransactionHourMA) / TransactionHourMA
        end as TransactionHourMA,
        ssq.SameSessionQuoteCount,
        ConvertedFlag
    from
        process_cdgquote a
        left join process_cdgquote_destination_ma b on 
            a.BusinessUnitID = b.BusinessUnitID and
            a.OutletGroup = b.OutletGroup and
            a.QuoteDate = b.QuoteDate and
            a.Destination = b.Destination
        left join process_cdgquote_duration_ma c on 
            a.BusinessUnitID = c.BusinessUnitID and
            a.OutletGroup = c.OutletGroup and
            a.QuoteDate = c.QuoteDate and
            a.duration = c.duration
        left join process_cdgquote_leadtime_ma d on 
            a.BusinessUnitID = d.BusinessUnitID and
            a.OutletGroup = d.OutletGroup and
            a.QuoteDate = d.QuoteDate and
            a.leadtime = d.leadtime
        left join process_cdgquote_age_ma e on 
            a.BusinessUnitID = e.BusinessUnitID and
            a.OutletGroup = e.OutletGroup and
            a.QuoteDate = e.QuoteDate and
            a.age = e.age
        left join process_cdgquote_transactionhour_ma f on 
            a.BusinessUnitID = f.BusinessUnitID and
            a.OutletGroup = f.OutletGroup and
            a.QuoteDate = f.QuoteDate and
            a.transactionhour = f.transactionhour
        left join
        (
            select 
                CampaignSessionID, 
                count(1) SameSessionQuoteCount
            from
                process_cdgquote
            where
                isPrimaryTraveller = 1
            group by
                CampaignSessionID
        ) ssq on 
            a.CampaignSessionID = ssq.CampaignSessionID
    where
        a.QuoteDate >= dateadd(day, -15, getdate())
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists flagged_cdgquote
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table flagged_cdgquote
    as
    select
        platformversion,
        analyticssessionid,
        DestinationMA,
        DurationMA,
        LeadTimeMA,
        AgeMA,
        TransactionHourMA,
        SameSessionQuoteCount,
        ConvertedFlag,
        max(
            case 
                when ConvertedFlag = 1 then 0
                
                /*whitelist impulse platform migration*/
                /*MB*/
                when BusinessUnitID = 32 and QuoteDate between ''2016-04-19'' and ''2016-05-31'' then 0
                /*AHM*/
                when BusinessUnitID = 75 and QuoteDate < ''2016-12-01'' then 0

                when
                    (
                        (
                            case 
                                when LeadTimeMA >= 3*6 then 2 
                                when LeadTimeMA >= 3 then 1 
                                when LeadTimeMA > 1 then 0.125
                                else 0 
                            end
                        ) * 2.0 + 
                        (
                            case 
                                when DurationMA >= 3*8 then 3
                                when DurationMA >= 3*6 then 2 
                                when DurationMA >= 3*3 then 1.5
                                when DurationMA >= 3 then 1 
                                when DurationMA > 1 then 0.25
                                else 0 
                            end
                        ) * 1.0 + 
                        (
                            case
                                when AgeMA >= 3*6 then 3
                                when AgeMA >= 3*3 then 2 
                                when AgeMA >= 3 then 1 
                                when AgeMA > 1 then 0.25
                                else 0 
                            end
                        ) * 1 + 
                        (
                            case 
                                when DestinationMA >= 3*6 then 2 
                                when DestinationMA >= 3 then 1 
                                when DestinationMA > 1 then 0.5
                                else 0 
                            end
                        ) * 0.5 +
                        (
                            case 
                                when TransactionHourMA >= 3*6 then 2 
                                when TransactionHourMA >= 3 then 1 
                                else 0 
                            end
                        ) * 0.25
                    ) > 2 then 1
                else 0
            end 
        ) BotFlag
    from
        ma_cdgquote a
    group by
        platformversion,
        analyticssessionid,
        DestinationMA,
        DurationMA,
        LeadTimeMA,
        AgeMA,
        TransactionHourMA,
        SameSessionQuoteCount,
        ConvertedFlag
    '
    ) at [CMDWH-REDSHIFT-PROD]

    raiserror('flagged', 1, 1) with nowait


    --select *
    --from
    --    openquery
    --    (
    --        [CMDWH-REDSHIFT-PROD],
    --        'select top 1000 * from flagged_cdgquote'
    --    ) t

    execute
    (
    '
    delete from innate_quote_ma
    using flagged_cdgquote
    where 
        innate_quote_ma.analyticssessionid = flagged_cdgquote.analyticssessionid and
        innate_quote_ma.PlatformVersion = flagged_cdgquote.PlatformVersion
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    insert into innate_quote_ma
    select 
        *,
        convert_timezone(''Australia/Sydney'', getdate())
    from 
        flagged_cdgquote 
    '
    ) at [CMDWH-REDSHIFT-PROD]

    raiserror('saved', 1, 1) with nowait


    --execute
    --(
    --'
    --delete from innate_quote_ma
    --'
    --) at [CMDWH-REDSHIFT-PROD]
    --go

end
GO
