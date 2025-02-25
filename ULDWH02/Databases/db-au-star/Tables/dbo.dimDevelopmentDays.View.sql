USE [db-au-star]
GO
/****** Object:  View [dbo].[dimDevelopmentDays]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[dimDevelopmentDays] as
select 
    convert(bigint, DevelopmentDay) DevelopmentDay,
    DevelopmentYear,
    --DevelopmentMonth + 12 * DevelopmentYear DevelopmentMonth,
    DevelopmentMonth,
    --((DevelopmentMonth - 1) / 3) + 4 * DevelopmentYear DevelopmentQuarter,
    (DevelopmentMonth - 1) / 3 DevelopmentQuarter,
    convert(bigint, DevelopmentDay - 1) / 7 DevelopmentWeek
    --DevelopmentMonth,
    --(DevelopmentMonth - 1) / 3 DevelopmentQuarter
from
    (
        select 
            row_number() over (order by [Date]) DevelopmentDay
        from
            [db-au-cmdwh]..Calendar
            cross apply
            (
                select 1 Multiplier
                union
                select 2
            ) m
    ) d
    cross apply
    (
        select
            (d.DevelopmentDay - 1) / 365 DevelopmentYear
    ) y
    cross apply
    (
        select
            --case
            --    when DevelopmentDay >= (DevelopmentYear + 1) * 360 then 11
            --    else (d.DevelopmentDay - 1) / 30 % 12 
            --end DevelopmentMonth
            (d.DevelopmentDay - 1) / 30 DevelopmentMonth
    ) m

union all

select 
    0 DevelopmentDay,
    0 DevelopmentYear,
    0 DevelopmentMonth,
    0 DevelopmentQuarter,
    0 DevelopmentWeek

GO
