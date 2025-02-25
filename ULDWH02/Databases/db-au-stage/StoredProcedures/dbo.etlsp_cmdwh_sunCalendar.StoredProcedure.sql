USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_sunCalendar]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_sunCalendar] @FYear int
as

SET NOCOUNT ON


--uncomment to debug
/*
declare @FYear int
select @FYear = 2012
*/

if @FYear = 0 or @FYear is null
    select @FYear = case when month(getdate()) between 7 and 12 then year(getdate()) + 1
                         else year(getdate())
                    end

if object_id('[db-au-cmdwh].dbo.sunCalendar') is null
begin
    create table [db-au-cmdwh].dbo.sunCalendar
    (
        Period int NOT NULL,                        --SUN period format YYYYNNN    eg 2012001 for FY2012 july
        FMonthNum int NOT NULL,                        --Fiscal month number eg 1 = jul, 2 = aug, 3 = sep, ... 12 = jun
        CMonthNum int NOT NULL,                        --Calendar month number eg 1 = jan, 2 = feb, 3 = mar, ... 12 = dec
        FYearNum int NOT NULL,                        --Fiscal year number
        CYearNum int NOT NULL,                        --Calendar year number
        FQuarterNum int NOT NULL,                    --Fiscal quarter number eg 1 = jul, aug, sep; 2 = oct, nov, dec; etc..
        CQuarterNum int NOT NULL,                    --Calendar quarter number eg 1 = jan, feb, mar; 2 = apr, may, jun; etc..
        FMonthStart smalldatetime NOT NULL,            --Fiscal Month Start Date
        FMonthEnd smalldatetime NOT NULL,            --Fiscal Month End Date
        CMonthStart smalldatetime NOT NULL,            --Calendar Month Start Date
        CMonthEnd smalldatetime NOT NULL,            --Calendar Month End Date
        FYearStart smalldatetime NOT NULL,            --Fiscal Year Start Date
        FYearEnd smalldatetime NOT NULL,            --Fiscal Year End Date
        CYearStart smalldatetime NOT NULL,            --Calendar Year Start Date
        CYearEnd smalldatetime NOT NULL                --Calendar Year End Date
    )


    if exists(select name from sys.indexes where name = 'idx_sunCalendar_Period')
    drop index idx_sunCalendar_Period on sunCalendar.[Period]

    create index idx_sunCalendar_Period on [db-au-cmdwh].dbo.sunCalendar([Period])
end
else
    delete [db-au-cmdwh].dbo.sunCalendar
    where FYearNum = @FYear

declare @StartCounter varchar(3)
declare @EndCounter varchar(3)
select @StartCounter = '001', @EndCounter = '012'

while cast(@StartCounter as int) <= cast(@EndCounter as int)
begin
    insert [db-au-cmdwh].dbo.sunCalendar
    select    cast(cast(@FYear as varchar) + @StartCounter as int) as Period,
            cast(@StartCounter as int) as FMonthNum,
            case cast(@StartCounter as int) when 1 then 7
                                            when 2 then 8
                                            when 3 then 9
                                            when 4 then 10
                                            when 5 then 11
                                            when 6 then 12
                                            when 7 then 1
                                            when 8 then 2
                                            when 9 then 3
                                            when 10 then 4
                                            when 11 then 5
                                            when 12 then 6
            end as CMonthNum,
            @FYear as FYearNum,
            case when cast(@StartCounter as int) in (1,2,3,4,5,6) then @FYear - 1
                 else @FYear
            end as CYearNum,
            case when cast(@StartCounter as int) in (1,2,3) then 1
                 when cast(@StartCounter as int) in (4,5,6) then 2
                 when cast(@StartCounter as int) in (7,8,9) then 3
                 when cast(@StartCounter as int) in (10,11,12) then 4
            end as FQuarterNum,
            case when cast(@StartCounter as int) in (1,2,3) then 3
                 when cast(@StartCounter as int) in (4,5,6) then 4
                 when cast(@StartCounter as int) in (7,8,9) then 1
                 when cast(@StartCounter as int) in (10,11,12) then 2
            end as CQuarterNum,
            case cast(@StartCounter as int) when 1 then convert(smalldatetime,convert(varchar,@FYear - 1) + '-07-01')
                                            when 2 then convert(smalldatetime,convert(varchar,@FYear - 1) + '-08-01')
                                            when 3 then convert(smalldatetime,convert(varchar,@FYear - 1) + '-09-01')
                                            when 4 then convert(smalldatetime,convert(varchar,@FYear - 1) + '-10-01')
                                            when 5 then convert(smalldatetime,convert(varchar,@FYear - 1) + '-11-01')
                                            when 6 then convert(smalldatetime,convert(varchar,@FYear - 1) + '-12-01')
                                            when 7 then convert(smalldatetime,convert(varchar,@FYear) + '-01-01')
                                            when 8 then convert(smalldatetime,convert(varchar,@FYear) + '-02-01')
                                            when 9 then convert(smalldatetime,convert(varchar,@FYear) + '-03-01')
                                            when 10 then convert(smalldatetime,convert(varchar,@FYear) + '-04-01')
                                            when 11 then convert(smalldatetime,convert(varchar,@FYear) + '-05-01')
                                            when 12 then convert(smalldatetime,convert(varchar,@FYear) + '-06-01')
            end as FMonthStart,
            case when cast(@StartCounter as int) = 1 then convert(smalldatetime,convert(varchar,@FYear - 1) + '-07-31')
                 when cast(@StartCounter as int) = 2 then convert(smalldatetime,convert(varchar,@FYear - 1) + '-08-31')
                 when cast(@StartCounter as int) = 3 then convert(smalldatetime,convert(varchar,@FYear - 1) + '-09-30')
                 when cast(@StartCounter as int) = 4 then convert(smalldatetime,convert(varchar,@FYear - 1) + '-10-31')
                 when cast(@StartCounter as int) = 5 then convert(smalldatetime,convert(varchar,@FYear - 1) + '-11-30')
                 when cast(@StartCounter as int) = 6 then convert(smalldatetime,convert(varchar,@FYear - 1) + '-12-31')
                 when cast(@StartCounter as int) = 7 then convert(smalldatetime,convert(varchar,@FYear) + '-01-31')
                 when cast(@StartCounter as int) = 8 then --check for leap year
                    case when [db-au-cmdwh].dbo.fn_isLeapYear(@FYear) = 1 then convert(smalldatetime,convert(varchar,@FYear) + '-02-29')
                         else convert(smalldatetime,convert(varchar,@FYear) + '-02-28')
                    end
                 when cast(@StartCounter as int) = 9 then convert(smalldatetime,convert(varchar,@FYear) + '-03-31')
                 when cast(@StartCounter as int) = 10 then convert(smalldatetime,convert(varchar,@FYear) + '-04-30')
                 when cast(@StartCounter as int) = 11 then convert(smalldatetime,convert(varchar,@FYear) + '-05-31')
                 when cast(@StartCounter as int) = 12 then convert(smalldatetime,convert(varchar,@FYear) + '-06-30')
            end as FMonthEnd,
            case cast(@StartCounter as int) when 1 then convert(smalldatetime,convert(varchar,@FYear - 1) + '-07-01')
                                            when 2 then convert(smalldatetime,convert(varchar,@FYear - 1) + '-08-01')
                                            when 3 then convert(smalldatetime,convert(varchar,@FYear - 1) + '-09-01')
                                            when 4 then convert(smalldatetime,convert(varchar,@FYear - 1) + '-10-01')
                                            when 5 then convert(smalldatetime,convert(varchar,@FYear - 1) + '-11-01')
                                            when 6 then convert(smalldatetime,convert(varchar,@FYear - 1) + '-12-01')
                                            when 7 then convert(smalldatetime,convert(varchar,@FYear) + '-01-01')
                                            when 8 then convert(smalldatetime,convert(varchar,@FYear) + '-02-01')
                                            when 9 then convert(smalldatetime,convert(varchar,@FYear) + '-03-01')
                                            when 10 then convert(smalldatetime,convert(varchar,@FYear) + '-04-01')
                                            when 11 then convert(smalldatetime,convert(varchar,@FYear) + '-05-01')
                                            when 12 then convert(smalldatetime,convert(varchar,@FYear) + '-06-01')
            end as CMonthStart,
            case when cast(@StartCounter as int) = 1 then convert(smalldatetime,convert(varchar,@FYear - 1) + '-07-31')
                 when cast(@StartCounter as int) = 2 then convert(smalldatetime,convert(varchar,@FYear - 1) + '-08-31')
                 when cast(@StartCounter as int) = 3 then convert(smalldatetime,convert(varchar,@FYear - 1) + '-09-30')
                 when cast(@StartCounter as int) = 4 then convert(smalldatetime,convert(varchar,@FYear - 1) + '-10-31')
                 when cast(@StartCounter as int) = 5 then convert(smalldatetime,convert(varchar,@FYear - 1) + '-11-30')
                 when cast(@StartCounter as int) = 6 then convert(smalldatetime,convert(varchar,@FYear - 1) + '-12-31')
                 when cast(@StartCounter as int) = 7 then convert(smalldatetime,convert(varchar,@FYear) + '-01-31')
                 when cast(@StartCounter as int) = 8 then --check for leap year
                    case when [db-au-cmdwh].dbo.fn_isLeapYear(@FYear) = 1 then convert(smalldatetime,convert(varchar,@FYear) + '-02-29')
                         else convert(smalldatetime,convert(varchar,@FYear) + '-02-28')
                    end
                 when cast(@StartCounter as int) = 9 then convert(smalldatetime,convert(varchar,@FYear) + '-03-31')
                 when cast(@StartCounter as int) = 10 then convert(smalldatetime,convert(varchar,@FYear) + '-04-30')
                 when cast(@StartCounter as int) = 11 then convert(smalldatetime,convert(varchar,@FYear) + '-05-31')
                 when cast(@StartCounter as int) = 12 then convert(smalldatetime,convert(varchar,@FYear) + '-06-30')
            end as CMonthEnd,
            convert(smalldatetime,convert(varchar,@FYear - 1) + '-07-01') as FYearStart,
            convert(smalldatetime,cast(@FYear as varchar) + '-06-30') as FYearEnd,
            convert(smalldatetime,convert(varchar,@FYear - 1) + '-01-01') as CYearStart,
            convert(smalldatetime,cast(@FYear-1 as varchar) + '-12-31') as CYearEnd

    select @StartCounter = case when cast(@StartCounter as int) + 1 < 10 then '00' + cast(cast(replace(@StartCounter,'0','') as int) + 1 as varchar)
                                else '0' + cast(cast(@StartCounter as int) + 1 as varchar)
                           end
end


GO
