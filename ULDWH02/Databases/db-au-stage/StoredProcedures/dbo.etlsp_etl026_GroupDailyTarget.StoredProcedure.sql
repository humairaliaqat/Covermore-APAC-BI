USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_etl026_GroupDailyTarget]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_etl026_GroupDailyTarget]
    @Country varchar(2) = 'AU',
    @ExecuteDate date

as
begin
/****************************************************************************************************/
--  Name:           dbo.etlsp_etl026_GroupDailyTarget
--  Author:         Leonardus Setyabudi
--  Date Created:   20120831
--  Description:    Calculate weighting and target by Partner & Date
--  Logic:
--                  *Day of Week Weight, calculated within Partner Group
--                  1 for weekdays
--                  else average weekend days sales / average weekdays sales
--
--                  *Day of Month Weight, calculated within Partner Group
--                  sales for the day divided by total sales for the month
--
--                  *Targets, calculated within Partner Group for next fiscal year
--                  Day of Month Weight applied to monthly Target
--
--  Change History: 20120831 - LS - Created
--                  20121023 - LS - Use daily average for each alpha if there's no actual sales for yago
--                  20121024 - LS - Use floating point for actual/target ratio on policy count
--
/****************************************************************************************************/

--uncomment to debug
--declare @Country varchar(2)
--declare @ExecuteDate date
--select
--    @Country = 'AU',
--    @ExecuteDate = '2011-07-01'

    set nocount on

    /* define month dates */
    declare @StartDate date
    declare @EndDate date

    set @StartDate = convert(varchar(8), @ExecuteDate, 120) + '01'
    set @EndDate = dateadd(day, -1, dateadd(month, 1, @StartDate))

    /* clean up temporary tables */
    if object_id('tempdb..#daycount') is not null
        drop table #daycount

    if object_id('tempdb..#testagencies') is not null
        drop table #testagencies

    if object_id('tempdb..#actual') is not null
        drop table #actual

    if object_id('tempdb..#extrapolate') is not null
        drop table #extrapolate

    if object_id('tempdb..#partnergroup') is not null
        drop table #partnergroup

    /* generate days count */
    select
        sum(
            case
                when datename(dw, [Date]) not in ('Saturday', 'Sunday') then 1
                else 0
            end
        ) WeekDaysCount,
        sum(
            case
                when datename(dw, [Date]) in ('Saturday') then 1
                else 0
            end
        ) SaturdayCount,
        sum(
            case
                when datename(dw, [Date]) in ('Sunday') then 1
                else 0
            end
        ) SundayCount
    into #daycount
    from
        [db-au-cmdwh].dbo.Calendar
    where
        [Date] between @StartDate and @EndDate

    /* generate actual sales */
    select distinct AgencyCode
    into #testagencies
    from
        [db-au-cmdwh].dbo.Agency
    where
        CountryKey = @Country and
        (
            (
                AgencyName like '%test%' and
                AgencyCode <> 'ZAAV132'
            ) or
            AgencyName like '%training%'
        )

    select
        p.IssuedDate as CreateDate,
        p.AgencyKey,
        sum(
            case
                when p.PolicyType in ('N', 'E') then 1
                when p.PolicyType = 'R' and p.OldPolicyType in ('N', 'E') then -1
                else 0
            end
        ) PolicyCount,
        sum(p.GrossPremiumExGSTBeforeDiscount - p.CommissionAmount) NAP,
        sum(p.GrossPremiumExGSTBeforeDiscount) SellPrice
    into #actual
    from
        [db-au-cmdwh].dbo.Policy p
        inner join [db-au-cmdwh].dbo.Agency a on
            a.AgencyKey = p.AgencyKey and
            a.AgencyStatus = 'Current'
        left join #testagencies ta on
            ta.AgencyCode = a.AgencyCode
    where
        p.IssuedDate between @StartDate and @EndDate and
        a.CountryKey = @Country and
        ta.AgencyCode is null
    group by
        p.IssuedDate,
        p.AgencyKey

    create clustered index cidx on #actual (CreateDate, AgencyKey)

    /* generate all dates & agencies sales */
    select
        c.[Date],
        datename(dw, c.[Date]) DOW,
        @Country CountryKey,
        pg.AgencyKey,
        pg.AgencyCode,
        PartnerGroup,
        isnull(PolicyCount, 0) PolicyCount,
        isnull(SellPrice, 0) SellPrice,
        isnull(NAP, 0) NAP
    into #extrapolate
    from
        [db-au-cmdwh].dbo.Calendar c
        cross apply
        (
            select
                a.AgencyCode,
                AgencyKey,
                case
                    when AgencySuperGroupName in ('AAA','Australia Post', 'Medibank', 'Flight Centre', 'STA') then AgencySuperGroupName
                    when AgencySuperGroupName = 'TCIS' then 'Travellers Choice'
                    when AgencySuperGroupName = 'Stella' and AgencyGroupName in ('Concorde Transonic', 'Transonic') then 'Concorde'
                    when AgencySuperGroupName = 'Stella' then AgencyGroupName
                    when AgencySuperGroupName in ('Independents', 'Brokers') then 'Indies'
                    --when AgencySuperGroupName in ('Independents') then 'Indies'
                    when AgencySuperGroupName = 'Direct' and AgencySubGroupCode = 'PH' then 'Direct Phone Sales'
                    when AgencySuperGroupName = 'Direct' and AgencySubGroupCode in ('WE', 'MS') then 'Direct Web Sales'
                    else null
                end PartnerGroup
            from
                [db-au-cmdwh].dbo.Agency a
                left join #testagencies ta on
                    ta.AgencyCode = a.AgencyCode
            where
                a.CountryKey = @Country and
                a.AgencyStatus = 'Current' and
                ta.AgencyCode is null
        ) pg
        left join #actual p on
            p.CreateDate = c.[Date] and
            p.AgencyKey = pg.AgencyKey
    where
        c.Date between @StartDate and @EndDate

    create clustered index cidx on #extrapolate ([Date], PartnerGroup)

    /* summarize on partner group level */
    if not exists
        (
            select null
            from
                [db-au-cmdwh].INFORMATION_SCHEMA.TABLES
            where
                table_name = 'usrGTDailyWeighting'
        )
    begin

        create table [db-au-cmdwh].dbo.usrGTDailyWeighting
        (
            CountryKey varchar(2) not null,
            PartnerGroup varchar(100) not null,
            [Date] datetime not null,
            DOW varchar(10) not null,
            DOWWeight decimal(5,4) not null default 0,
            DOWRatio decimal(5,4) not null default 0,
            TotalPolicyCount int not null default 0,
            TotalNAP money not null default 0,
            TotalSellPrice money not null default 0,
            PolicyCountTarget int not null default 0,
            NAPTarget money not null default 0,
            SellPriceTarget money not null default 0
        )

        create clustered index idx_usrGTDailyWeighting_PartnerGroup on [db-au-cmdwh].dbo.usrGTDailyWeighting(PartnerGroup, CountryKey, [Date])
        create index idx_usrGTDailyWeighting_Date on [db-au-cmdwh].dbo.usrGTDailyWeighting([Date], CountryKey)

    end
    else
    begin

        delete [db-au-cmdwh].dbo.usrGTDailyWeighting
        where
            CountryKey = @Country and
            [Date] between @StartDate and @EndDate

    end

    ;with cte_partnergroup as
    (
        select
            PartnerGroup,
            sum(
                case
                    when r.DOW not in ('Saturday', 'Sunday') then cast(SellPrice as float)
                    else 0
                end
            ) WeekDaysTotalSellPrice,
            WeekDaysCount,
            sum(
                case
                    when r.DOW in ('Saturday') then cast(SellPrice as float)
                    else 0
                end
            ) SaturdayTotalSellPrice,
            SaturdayCount,
            sum(
                case
                    when r.DOW in ('Sunday') then cast(SellPrice as float)
                    else 0
                end
            ) SundayTotalSellPrice,
            SundayCount,
            sum(PolicyCount) TotalPolicyCount,
            sum(cast(NAP as float)) TotalNAP,
            sum(cast(SellPrice as float)) TotalSellPrice
        from
            #extrapolate r
            cross apply
            (
                select
                    WeekDaysCount,
                    SaturdayCount,
                    SundayCount
                from
                    #daycount
            ) dc
        where
            PartnerGroup is not null
        group by
            PartnerGroup,
            WeekDaysCount,
            SaturdayCount,
            SundayCount
    ),
    cte_average as
    (
        select
            PartnerGroup,
            WeekDaysTotalSellPrice / WeekDaysCount WeekDaysAvgSellPrice,
            SaturdayTotalSellPrice / SaturdayCount SaturdayAvgSellPrice,
            SundayTotalSellPrice / SundayCount SundayAvgSellPrice,
            TotalPolicyCount,
            TotalNAP,
            TotalSellPrice
        from
            cte_partnergroup
    )
    insert into [db-au-cmdwh].dbo.usrGTDailyWeighting
    (
        CountryKey,
        PartnerGroup,
        [Date],
        DOW,
        DOWWeight,
        TotalPolicyCount,
        TotalNAP,
        TotalSellPrice,
        PolicyCountTarget,
        NAPTarget,
        SellPriceTarget
    )
    select
        @Country CountryKey,
        ca.PartnerGroup,
        c.[Date],
        DOW,
        --WeekDaysAvgSellPrice,
        --SaturdayAvgSellPrice,
        --SundayAvgSellPrice,
        dww.DOWWeight,
        TotalPolicyCount,
        TotalNAP,
        TotalSellPrice,
        yt.PolicyTarget,
        yt.NAPTarget,
        yt.SellPriceTarget
    from
        cte_average ca
        inner join [db-au-cmdwh].dbo.Calendar c on
            c.[Date] between @StartDate and @EndDate
        cross apply
        (
            select
                datename(dw, c.[Date]) DOW
        ) dw
        left join [db-au-cmdwh].dbo.usrGTNationalHolidays ph on
            ph.[Date] = c.[Date]
        left join [db-au-cmdwh].dbo.usrGTYearlyTarget yt on
            yt.PartnerGroup = ca.PartnerGroup and
            yt.CountryKey = @Country and
            yt.MonthStartDate = convert(varchar(8), dateadd(year, 1, c.[Date]), 120) + '01'
        cross apply
        (
            select
                case
                    when ph.[Date] is not null then 0
                    when dw.DOW not in ('Saturday', 'Sunday') then 1
                    when dw.DOW = 'Saturday' then
                        case
                            when WeekDaysAvgSellPrice = 0 then 0
                            else SaturdayAvgSellPrice / WeekDaysAvgSellPrice
                        end
                    when dw.DOW = 'Sunday' then
                        case
                            when WeekDaysAvgSellPrice = 0 then 0
                            else SundayAvgSellPrice / WeekDaysAvgSellPrice
                        end
                end DOWWeight
        ) dww

    /* calculate DOW Ratio */
    ;with cte_cydow as
    (
        select
            CountryKey,
            PartnerGroup,
            sum(DOWWeight) DOWWeight
        from
            [db-au-cmdwh].dbo.usrGTDailyWeighting
        where
            Date between @StartDate and @EndDate
        group by
            CountryKey,
            PartnerGroup
    ),
    cte_nydow as
    (
        select
            CountryKey,
            PartnerGroup,
            sum(
                case
                    when ph.Date is not null then 0
                    else DOWWeight
                end
            ) DOWWeight
        from
            [db-au-cmdwh].dbo.Calendar c
            left join [db-au-cmdwh].dbo.usrGTNationalHolidays ph on
                ph.Date = c.Date
            cross apply
            (
                select
                    CountryKey,
                    PartnerGroup,
                    /* use max, some of the days can be 0 due to national holiday */
                    max(DOWWeight) DOWWeight
                from
                    [db-au-cmdwh].dbo.usrGTDailyWeighting
                where
                    Date between @StartDate and @EndDate and
                    DOW = datename(dw, c.Date)
                group by
                    CountryKey,
                    PartnerGroup
            ) pg
        where
            c.Date >= dateadd(year, 1, @StartDate) and
            c.Date <  dateadd(month, 1, dateadd(year, 1, @StartDate))
        group by
            CountryKey,
            PartnerGroup
    )
    update dw
    set
        DOWRatio =
            case
                when cy.DOWWeight = 0 then cast(0 as decimal(5,4))
                else ny.DOWWeight / cy.DOWWeight
            end
    from
        [db-au-cmdwh].dbo.usrGTDailyWeighting dw
        inner join cte_cydow cy on
            cy.CountryKey = dw.CountryKey and
            cy.PartnerGroup = dw.PartnerGroup
        inner join cte_nydow ny on
            ny.CountryKey = dw.CountryKey and
            ny.PartnerGroup = dw.PartnerGroup
    where
        dw.Date between @StartDate and @EndDate


    /* break down to agency level */
    if not exists
        (
            select null
            from
                [db-au-cmdwh].INFORMATION_SCHEMA.TABLES
            where
                table_name = 'usrGTDailyTarget'
        )
    begin

        create table [db-au-cmdwh].dbo.usrGTDailyTarget
        (
            CountryKey varchar(2) not null,
            AgencyKey varchar(10) not null,
            AgencyCode varchar(7) not null,
            PartnerGroup varchar(100) not null,
            [Date] datetime not null,
            PolicyCount int not null default 0,
            NAP money not null default 0,
            SellPrice money not null default 0,
            PolicyCountTarget int not null default 0,
            NAPTarget money not null default 0,
            SellPriceTarget money not null default 0
        )

        create clustered index idx_usrGTDailyTarget_AgencyKey on [db-au-cmdwh].dbo.usrGTDailyTarget(AgencyKey, [Date])
        create index idx_usrGTDailyTarget_AgencyCode on [db-au-cmdwh].dbo.usrGTDailyTarget(AgencyCode, [Date])
        create index idx_usrGTDailyTarget_Date on [db-au-cmdwh].dbo.usrGTDailyTarget([Date], CountryKey)
        create index idx_usrGTDailyTarget_PartnerGroup on [db-au-cmdwh].dbo.usrGTDailyTarget(PartnerGroup, CountryKey, [Date])

    end
    else
    begin

        delete [db-au-cmdwh].dbo.usrGTDailyTarget
        where
            CountryKey = @Country and
            [Date] between @StartDate and @EndDate

    end

    insert into [db-au-cmdwh].dbo.usrGTDailyTarget
    (
        CountryKey,
        AgencyKey,
        AgencyCode,
        PartnerGroup,
        [Date],
        PolicyCount,
        NAP,
        SellPrice,
        PolicyCountTarget,
        NAPTarget,
        SellPriceTarget
    )
    select
        @Country CountryKey,
        AgencyKey,
        AgencyCode,
        PartnerGroup,
        [Date],
        d.PolicyCount,
        d.NAP,
        d.SellPrice,
        case
            when pg.TotalPolicyCount = 0 then pg.PolicyCountTarget * 1.0 / DayCount / AlphaCount
            else d.PolicyCount * (pg.PolicyCountTarget * 1.0 / pg.TotalPolicyCount)
        end PolicyCountTarget,
        case
            when pg.TotalNAP = 0 then pg.NAPTarget / DayCount / AlphaCount
            else d.NAP * (pg.NAPTarget / pg.TotalNAP)
        end NAPTarget,
        case
            when pg.TotalSellPrice = 0 then pg.SellPriceTarget / DayCount / AlphaCount
            else d.SellPrice * (pg.SellPriceTarget / pg.TotalSellPrice )
        end SellPriceTarget
    from
        #extrapolate d
        cross apply
        (
            select top 1
                TotalPolicyCount,
                TotalNAP,
                TotalSellPrice,
                PolicyCountTarget,
                NAPTarget,
                SellPriceTarget
            from
                [db-au-cmdwh].dbo.usrGTDailyWeighting pg
            where
                pg.CountryKey = @Country and
                pg.PartnerGroup = d.PartnerGroup and
                pg.[Date] = d.[Date]
        ) pg
        cross apply
        (
            select
                datepart(d, dateadd(day, -1, dateadd(month, 1, convert(varchar(8), [Date], 120) + '01'))) DayCount
        ) dn
        cross apply
        (
            select
                count(distinct AgencyKey) AlphaCount
            from
                #extrapolate r
            where
                r.[Date] = d.[Date] and
                r.PartnerGroup = d.PartnerGroup
        ) an

end

GO
