USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL054_RedshiftQuote_ProcessPenguin]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL054_RedshiftQuote_ProcessPenguin]
as
begin
/************************************************************************************************************************************
Author:         Leonardus S L
Date:           20160201
Description:    process Penguin data
Parameters:     
Change History:
                20160201 - LS - create

*************************************************************************************************************************************/

    set nocount on

    execute
    (
    '
    drop table if exists process_penguinquote
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_penguinquote
    as
    select 
        q.QuoteKey,
        left(q.QuoteKey, 2) BusinessUnitID,
        q.OutletGroup,
        cast(q.CreateTime as date) QuoteDate,
        q.SessionID,
        q.TransactionHour,
        q.Destination,
        q.Duration,
        q.LeadTime,
        q.TravellerAge Age,
        q.NumberOfAdults AdultCount,
        q.NumberOfChildren ChildrenCount,
        q.ConvertedFlag,
        max(isnull(b.BotFlag, 0)) BotFlag
    from
        penguin_quote q
        left join penguin_quote_ma b on
            q.QuoteKey = b.QuoteKey
    where
        CreateTime >= dateadd(month, -6, dateadd(day, -15, getdate()))
    group by
        q.QuoteKey,
        left(q.QuoteKey, 2),
        q.OutletGroup,
        cast(q.CreateTime as date),
        q.SessionID,
        q.TransactionHour,
        q.Destination,
        q.Duration,
        q.LeadTime,
        q.TravellerAge,
        q.NumberOfAdults,
        q.NumberOfChildren,
        q.ConvertedFlag
    '
    ) at [CMDWH-REDSHIFT-PROD]

    raiserror('data dumped', 1, 1) with nowait

    --destination    
    execute
    (
    '
    drop table if exists process_penguinquote_destination
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_penguinquote_destination
    as
    select 
        BusinessUnitID,
        OutletGroup,
        Destination,
        QuoteDate,
        row_number() over (partition by BusinessUnitID,OutletGroup,Destination order by QuoteDate) RowNum,
        cast(count(distinct QuoteKey) as float) QuoteCount,
        cast(count(distinct case when BotFlag = 1 then QuoteKey else null end) as float) BotCount
    from
        process_penguinquote
    group by
        BusinessUnitID,
        OutletGroup,
        Destination,
        QuoteDate
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_penguinquote_destination_rank
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_penguinquote_destination_rank
    as
    select 
        *,
        cast(QuoteDate as varchar(7)) QuoteMonth,
        row_number() over (partition by BusinessUnitID,OutletGroup,Destination,cast(QuoteDate as varchar(7)) order by QuoteCount desc) RankInMonth,
        count(QuoteDate) over (partition by BusinessUnitID,OutletGroup,Destination,cast(QuoteDate as varchar(7))) RecordNum
    from
        process_penguinquote_destination
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_penguinquote_destination_outlier
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_penguinquote_destination_outlier
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
        process_penguinquote_destination_rank
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_penguinquote_destination_ma
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_penguinquote_destination_ma
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
                    process_penguinquote_destination_outlier r
                where
                    r.BusinessUnitID = t.BusinessUnitID and
                    r.OutletGroup = t.OutletGroup and
                    r.Destination = t.Destination and
                    --hard-coded MA window, no sub-sub-query in redshift
                    r.RowNum < t.RowNum and
                    r.RowNum >= t.RowNum - 60 and
                    r.isOutlier = 0
            ),
            t.QuoteCount
        ) DestinationMA
    from
        process_penguinquote_destination_outlier t
    '
    ) at [CMDWH-REDSHIFT-PROD]

    raiserror('destination processed', 1, 1) with nowait

    --duration    
    execute
    (
    '
    drop table if exists process_penguinquote_duration
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_penguinquote_duration
    as
    select 
        BusinessUnitID,
        OutletGroup,
        duration,
        QuoteDate,
        row_number() over (partition by BusinessUnitID,OutletGroup,duration order by QuoteDate) RowNum,
        cast(count(distinct QuoteKey) as float) QuoteCount,
        cast(count(distinct case when BotFlag = 1 then QuoteKey else null end) as float) BotCount
    from
        process_penguinquote
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
    drop table if exists process_penguinquote_duration_rank
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_penguinquote_duration_rank
    as
    select 
        *,
        cast(QuoteDate as varchar(7)) QuoteMonth,
        row_number() over (partition by BusinessUnitID,OutletGroup,duration,cast(QuoteDate as varchar(7)) order by QuoteCount desc) RankInMonth,
        count(QuoteDate) over (partition by BusinessUnitID,OutletGroup,duration,cast(QuoteDate as varchar(7))) RecordNum
    from
        process_penguinquote_duration
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_penguinquote_duration_outlier
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_penguinquote_duration_outlier
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
        process_penguinquote_duration_rank
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_penguinquote_duration_ma
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_penguinquote_duration_ma
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
                    process_penguinquote_duration_outlier r
                where
                    r.BusinessUnitID = t.BusinessUnitID and
                    r.OutletGroup = t.OutletGroup and
                    r.duration = t.duration and
                    --hard-coded MA window, no sub-sub-query in redshift
                    r.RowNum < t.RowNum and
                    r.RowNum >= t.RowNum - 60 and
                    r.isOutlier = 0
            ),
            t.QuoteCount
        ) durationMA
    from
        process_penguinquote_duration_outlier t
    '
    ) at [CMDWH-REDSHIFT-PROD]

    raiserror('duration processed', 1, 1) with nowait

    --leadtime
    execute
    (
    '
    drop table if exists process_penguinquote_leadtime
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_penguinquote_leadtime
    as
    select 
        BusinessUnitID,
        OutletGroup,
        leadtime,
        QuoteDate,
        row_number() over (partition by BusinessUnitID,OutletGroup,leadtime order by QuoteDate) RowNum,
        cast(count(distinct QuoteKey) as float) QuoteCount,
        cast(count(distinct case when BotFlag = 1 then QuoteKey else null end) as float) BotCount
    from
        process_penguinquote
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
    drop table if exists process_penguinquote_leadtime_rank
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_penguinquote_leadtime_rank
    as
    select 
        *,
        cast(QuoteDate as varchar(7)) QuoteMonth,
        row_number() over (partition by BusinessUnitID,OutletGroup,leadtime,cast(QuoteDate as varchar(7)) order by QuoteCount desc) RankInMonth,
        count(QuoteDate) over (partition by BusinessUnitID,OutletGroup,leadtime,cast(QuoteDate as varchar(7))) RecordNum
    from
        process_penguinquote_leadtime
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_penguinquote_leadtime_outlier
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_penguinquote_leadtime_outlier
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
        process_penguinquote_leadtime_rank
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_penguinquote_leadtime_ma
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_penguinquote_leadtime_ma
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
                    process_penguinquote_leadtime_outlier r
                where
                    r.BusinessUnitID = t.BusinessUnitID and
                    r.OutletGroup = t.OutletGroup and
                    r.leadtime = t.leadtime and
                    --hard-coded MA window, no sub-sub-query in redshift
                    r.RowNum < t.RowNum and
                    r.RowNum >= t.RowNum - 60 and
                    r.isOutlier = 0
            ),
            t.QuoteCount
        ) leadtimeMA
    from
        process_penguinquote_leadtime_outlier t
    '
    ) at [CMDWH-REDSHIFT-PROD]

    raiserror('lead time processed', 1, 1) with nowait


    --age
    execute
    (
    '
    drop table if exists process_penguinquote_age
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_penguinquote_age
    as
    select 
        BusinessUnitID,
        OutletGroup,
        age,
        QuoteDate,
        row_number() over (partition by BusinessUnitID,OutletGroup,age order by QuoteDate) RowNum,
        cast(count(distinct QuoteKey) as float) QuoteCount,
        cast(count(distinct case when BotFlag = 1 then QuoteKey else null end) as float) BotCount
    from
        process_penguinquote
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
    drop table if exists process_penguinquote_age_rank
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_penguinquote_age_rank
    as
    select 
        *,
        cast(QuoteDate as varchar(7)) QuoteMonth,
        row_number() over (partition by BusinessUnitID,OutletGroup,age,cast(QuoteDate as varchar(7)) order by QuoteCount desc) RankInMonth,
        count(QuoteDate) over (partition by BusinessUnitID,OutletGroup,age,cast(QuoteDate as varchar(7))) RecordNum
    from
        process_penguinquote_age
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_penguinquote_age_outlier
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_penguinquote_age_outlier
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
        process_penguinquote_age_rank
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_penguinquote_age_ma
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_penguinquote_age_ma
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
                    process_penguinquote_age_outlier r
                where
                    r.BusinessUnitID = t.BusinessUnitID and
                    r.OutletGroup = t.OutletGroup and
                    r.age = t.age and
                    --hard-coded MA window, no sub-sub-query in redshift
                    r.RowNum < t.RowNum and
                    r.RowNum >= t.RowNum - 60 and
                    r.isOutlier = 0
            ),
            t.QuoteCount
        ) ageMA
    from
        process_penguinquote_age_outlier t
    '
    ) at [CMDWH-REDSHIFT-PROD]

    raiserror('age processed', 1, 1) with nowait

    --transactionhour
    execute
    (
    '
    drop table if exists process_penguinquote_transactionhour
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_penguinquote_transactionhour
    as
    select 
        BusinessUnitID,
        OutletGroup,
        transactionhour,
        QuoteDate,
        row_number() over (partition by BusinessUnitID,OutletGroup,transactionhour order by QuoteDate) RowNum,
        cast(count(distinct QuoteKey) as float) QuoteCount,
        cast(count(distinct case when BotFlag = 1 then QuoteKey else null end) as float) BotCount
    from
        process_penguinquote
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
    drop table if exists process_penguinquote_transactionhour_rank
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_penguinquote_transactionhour_rank
    as
    select 
        *,
        cast(QuoteDate as varchar(7)) QuoteMonth,
        row_number() over (partition by BusinessUnitID,OutletGroup,transactionhour,cast(QuoteDate as varchar(7)) order by QuoteCount desc) RankInMonth,
        count(QuoteDate) over (partition by BusinessUnitID,OutletGroup,transactionhour,cast(QuoteDate as varchar(7))) RecordNum
    from
        process_penguinquote_transactionhour
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_penguinquote_transactionhour_outlier
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_penguinquote_transactionhour_outlier
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
        process_penguinquote_transactionhour_rank
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists process_penguinquote_transactionhour_ma
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table process_penguinquote_transactionhour_ma
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
                    process_penguinquote_transactionhour_outlier r
                where
                    r.BusinessUnitID = t.BusinessUnitID and
                    r.OutletGroup = t.OutletGroup and
                    r.transactionhour = t.transactionhour and
                    --hard-coded MA window, no sub-sub-query in redshift
                    r.RowNum < t.RowNum and
                    r.RowNum >= t.RowNum - 60 and
                    r.isOutlier = 0
            ),
            t.QuoteCount
        ) transactionhourMA
    from
        process_penguinquote_transactionhour_outlier t
    '
    ) at [CMDWH-REDSHIFT-PROD]

    raiserror('transactionhour processed', 1, 1) with nowait

    --overall ma
    execute
    (
    '
    drop table if exists ma_penguinquote
    '
    ) at [CMDWH-REDSHIFT-PROD]


    execute
    (
    '
    create table ma_penguinquote
    as
    select
        a.QuoteKey,
        case 
            when DestinationMA = 0 then 0 
            else (b.QuoteCount - DestinationMA) / DestinationMA
        end as DestinationMA,
        case 
            when DurationMA = 0 then 0 
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
            else (e.QuoteCount - AgeMA) / AgeMA
        end as AgeMA,
        case 
            when TransactionHourMA = 0 then 0 
            else (f.QuoteCount - TransactionHourMA) / TransactionHourMA
        end as TransactionHourMA,
        ssq.SameSessionQuoteCount,
        ConvertedFlag
    from
        process_penguinquote a
        left join process_penguinquote_destination_ma b on 
            a.BusinessUnitID = b.BusinessUnitID and
            a.QuoteDate = b.QuoteDate and
            a.OutletGroup = b.OutletGroup and
            a.Destination = b.Destination
        left join process_penguinquote_duration_ma c on 
            a.BusinessUnitID = c.BusinessUnitID and
            a.QuoteDate = c.QuoteDate and
            a.OutletGroup = c.OutletGroup and
            a.duration = c.duration
        left join process_penguinquote_leadtime_ma d on 
            a.BusinessUnitID = d.BusinessUnitID and
            a.QuoteDate = d.QuoteDate and
            a.OutletGroup = d.OutletGroup and
            a.leadtime = d.leadtime
        left join process_penguinquote_age_ma e on 
            a.BusinessUnitID = e.BusinessUnitID and
            a.QuoteDate = e.QuoteDate and
            a.OutletGroup = e.OutletGroup and
            a.age = e.age
        left join process_penguinquote_transactionhour_ma f on 
            a.BusinessUnitID = f.BusinessUnitID and
            a.QuoteDate = f.QuoteDate and
            a.OutletGroup = f.OutletGroup and
            a.transactionhour = f.transactionhour
        left join
        (
            select 
                SessionID, 
                count(1) SameSessionQuoteCount
            from
                process_penguinquote
            group by
                SessionID
        ) ssq on 
            a.SessionID = ssq.SessionID
    where
        a.QuoteDate >= dateadd(day, -15, getdate())
    '
    ) at [CMDWH-REDSHIFT-PROD]


    execute
    (
    '
    drop table if exists flagged_penguinquote
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table flagged_penguinquote
    as
    select
        QuoteKey,
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
        ma_penguinquote a
    group by
        QuoteKey,
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
    --        'select top 1000 * from flagged_penguinquote'
    --    ) t

    execute
    (
    '
    delete from penguin_quote_ma
    using flagged_penguinquote
    where 
        penguin_quote_ma.QuoteKey = flagged_penguinquote.QuoteKey
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    insert into penguin_quote_ma
    select 
        *,
        convert_timezone(''Australia/Sydney'', getdate())
    from 
        flagged_penguinquote 
    '
    ) at [CMDWH-REDSHIFT-PROD]


end
GO
