USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_etl026_GroupTarget]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_etl026_GroupTarget]
as
begin

/****************************************************************************************************/
--  Name:           dbo.etlsp_etl026_GroupTarget
--  Author:         Leonardus Setyabudi
--  Date Created:   20120831
--  Description:    Transform Group Target from template (unpivot & pivot)
--
--  Change History: 20120831 - LS - Created
--
/****************************************************************************************************/

    set nocount on

    /* clean up temporary tables */
    if object_id('tempdb..#unpivot') is not null
        drop table #unpivot

    if object_id('tempdb..#pivot') is not null
        drop table #pivot

    /* unpivot template target data from individual month colums */
    select
        Country,
        PartnerGroup,
        TargetType,
        MonthStartDate,
        MonthEndDate,
        TargetValue
    into #unpivot
    from
        (
            select
                YearStartDate,
                YearEndDate,
                Country,
                [Group] PartnerGroup,
                TargetType,
                [Jul],
                [Aug],
                [Sep],
                [Oct],
                [Nov],
                [Dec],
                [Jan],
                [Feb],
                [Mar],
                [Apr],
                [May],
                [Jun]
            from
                [db-au-stage].dbo.etl026_GroupTarget_Yearly
        ) t
        unpivot
        (
            TargetValue for
                [Month] in
                (
                    [Jul],
                    [Aug],
                    [Sep],
                    [Oct],
                    [Nov],
                    [Dec],
                    [Jan],
                    [Feb],
                    [Mar],
                    [Apr],
                    [May],
                    [Jun]
                )
        ) ut
        cross apply
        (
            select
                case
                    when [Month] in ('Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec') then convert(varchar(4), YearStartDate, 120)
                    else convert(varchar(4), YearEndDate, 120)
                end [Year]
        ) yr
        cross apply
        (
            select
                convert(datetime, [Month] + ' 1 ' + [Year]) MonthStartDate,
                dateadd(day, -1, dateadd(month, 1, convert(datetime, [Month] + ' 1 ' + [Year]))) MonthEndDate
        ) dr

    /* pivot unpivotted data to individual target column */
    select
        Country,
        PartnerGroup,
        MonthStartDate,
        MonthEndDate,
        isnull([Policy Count], 0) as PolicyTarget,
        isnull([NAP], 0) as NAPTarget,
        isnull([Sell Price], 0) as SellPriceTarget
    into #pivot
    from
        (
            select
                Country,
                PartnerGroup,
                TargetType,
                MonthStartDate,
                MonthEndDate,
                TargetValue
            from #unpivot
        ) t
        pivot
        (
            sum(TargetValue) for
                TargetType in
                (
                    [Policy Count],
                    [NAP],
                    [Sell Price]
                )
        ) pvt

    /* load into table */
    if not exists
        (
            select null
            from
                [db-au-cmdwh].INFORMATION_SCHEMA.TABLES
            where
                table_name = 'usrGTYearlyTarget'
        )
    begin

        create table [db-au-cmdwh].dbo.usrGTYearlyTarget
        (
            CountryKey varchar(2) not null,
            PartnerGroup varchar(100) not null,
            MonthStartDate datetime not null,
            MonthEndDate datetime not null,
            PolicyTarget money not null default 0,
            NAPTarget money not null default 0,
            SellPriceTarget money not null default 0
        )

        create clustered index idx_usrGTYearlyTarget_AgencyGroupCode on [db-au-cmdwh].dbo.usrGTYearlyTarget(PartnerGroup, CountryKey, MonthStartDate)
        create index idx_usrGTYearlyTarget_Dates on [db-au-cmdwh].dbo.usrGTYearlyTarget(MonthStartDate, MonthEndDate)

    end
    else
        truncate table [db-au-cmdwh].dbo.usrGTYearlyTarget


    insert into [db-au-cmdwh].dbo.usrGTYearlyTarget
    (
        CountryKey,
        PartnerGroup,
        MonthStartDate,
        MonthEndDate,
        PolicyTarget,
        NAPTarget,
        SellPriceTarget
    )
    select
        Country,
        PartnerGroup,
        MonthStartDate,
        MonthEndDate,
        PolicyTarget,
        NAPTarget,
        SellPriceTarget
    from
        #pivot



    /* load national holidays */
    if not exists
        (
            select null
            from
                [db-au-cmdwh].INFORMATION_SCHEMA.TABLES
            where
                table_name = 'usrGTNationalHolidays'
        )
    begin

        create table [db-au-cmdwh].dbo.usrGTNationalHolidays
        (
            [Date] datetime not null,
            Comment varchar(255) null
        )

        create clustered index idx_usrGTNationalHolidays_Date on [db-au-cmdwh].dbo.usrGTNationalHolidays(Date)

    end
    else
        truncate table [db-au-cmdwh].dbo.usrGTNationalHolidays

    insert into [db-au-cmdwh].dbo.usrGTNationalHolidays
    (
        [Date],
        Comment
    )
    select
        [Date],
        Comment
    from etl026_GroupTarget_Holiday

end

GO
