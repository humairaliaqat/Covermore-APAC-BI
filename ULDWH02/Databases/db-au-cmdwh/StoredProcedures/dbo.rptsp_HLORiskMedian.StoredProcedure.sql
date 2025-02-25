USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_HLORiskMedian]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_HLORiskMedian]
    @ReportingPeriod varchar(255),
    @Group varchar(255),
    @State varchar(255)

as
begin

--debug
--declare
--    @ReportingPeriod varchar(255),
--    @Group varchar(255),
--    @State varchar(255)

--select
--    @ReportingPeriod = '2015-01',
--    @Group = 'helloworld franchise',
--    @State = 'All'

    set nocount on

    declare 
        @date date,
        @rowcount bigint,
        @MedianLeadTime int,
        @MedianDuration int,
        @MedianAge int,
        @MedianCanx bigint

    set @date =
        dateadd(
            month,
            -6,
            convert(
                date,
                replace(
                    replace(
                        @ReportingPeriod, 
                        '[Date].[Fiscal Date Hierarchy].[Fiscal Year Month].&[', 
                        ''
                    ),
                    ']',
                    ''
                ) + '-01'
            )
        ) 
    
    if object_id('tempdb..#cy') is not null
        drop table #cy

    --current year
    select 
        GroupName,
        LeadTime, 
        Duration, 
        CancellationCover,
        Age,
        EMCPolicy
    into #cy
    from 
        [db-au-workspace]..vHLORisk
    where 
        IssueDate >= @date and
        IssueDate <  dateadd(month, 1, @date) and
        (
            @State = 'All' or
            StateSalesArea = @State
        )
        
    create nonclustered index il on #cy (LeadTime)
    create nonclustered index id on #cy (Duration)
    create nonclustered index ia on #cy (Age)
    create nonclustered index ic on #cy (CancellationCover)
    create nonclustered index ig on #cy (GroupName) include (LeadTime,Duration,Age,CancellationCover)

    select 
        @rowcount = count(*)
    from
        #cy

    select 
        @MedianLeadTime = avg(1.0 * LeadTime)
    from 
        (
            select 
                LeadTime
            from
                #cy
            order by 
                LeadTime
            offset (@rowcount - 1) / 2 rows
            fetch next 1 + (1 - @rowcount % 2) rows only
        ) t

    select 
        @MedianDuration = avg(1.0 * Duration)
    from 
        (
            select 
                Duration
            from
                #cy
            order by 
                Duration
            offset (@rowcount - 1) / 2 rows
            fetch next 1 + (1 - @rowcount % 2) rows only
        ) t

    select 
        @MedianAge = avg(1.0 * Age)
    from 
        (
            select 
                Age
            from
                #cy
            order by 
                Age
            offset (@rowcount - 1) / 2 rows
            fetch next 1 + (1 - @rowcount % 2) rows only
        ) t

    select 
        @MedianCanx = avg(1.0 * CancellationCover)
    from 
        (
            select 
                CancellationCover
            from
                #cy
            order by 
                CancellationCover
            offset (@rowcount - 1) / 2 rows
            fetch next 1 + (1 - @rowcount % 2) rows only
        ) t

    if object_id('tempdb..#output') is not null
        drop table #output

    select 
        convert(varchar(5), 'All') Scope,
        'Current Year' Period,
        @MedianLeadTime MedianLeadTime,
        @MedianDuration MedianDuration,
        @MedianAge MedianAge,
        @MedianCanx MedianCanx
    into #output

    select 
        @rowcount = count(*)
    from
        #cy
    where
        GroupName = @Group

    select 
        @MedianLeadTime = avg(1.0 * LeadTime)
    from 
        (
            select 
                LeadTime
            from
                #cy
            where
                GroupName = @Group
            order by 
                LeadTime
            offset (@rowcount - 1) / 2 rows
            fetch next 1 + (1 - @rowcount % 2) rows only
        ) t

    select 
        @MedianDuration = avg(1.0 * Duration)
    from 
        (
            select 
                Duration
            from
                #cy
            where
                GroupName = @Group
            order by 
                Duration
            offset (@rowcount - 1) / 2 rows
            fetch next 1 + (1 - @rowcount % 2) rows only
        ) t

    select 
        @MedianAge = avg(1.0 * Age)
    from 
        (
            select 
                Age
            from
                #cy
            where
                GroupName = @Group
            order by 
                Age
            offset (@rowcount - 1) / 2 rows
            fetch next 1 + (1 - @rowcount % 2) rows only
        ) t

    select 
        @MedianCanx = avg(1.0 * CancellationCover)
    from 
        (
            select 
                CancellationCover
            from
                #cy
            where
                GroupName = @Group
            order by 
                CancellationCover
            offset (@rowcount - 1) / 2 rows
            fetch next 1 + (1 - @rowcount % 2) rows only
        ) t

    insert into #output
    select 
        'Group' Scope,
        'Current Year' Period,
        @MedianLeadTime MedianLeadTime,
        @MedianDuration MedianDuration,
        @MedianAge MedianAge,
        @MedianCanx MedianCanx

    --prior year
    if object_id('tempdb..#py') is not null
        drop table #py

    select 
        GroupName,
        LeadTime, 
        Duration, 
        CancellationCover,
        Age,
        EMCPolicy
    into #py
    from 
        [db-au-workspace]..vHLORisk
    where 
        dateadd(year, 1, IssueDate) >= @date and
        dateadd(year, 1, IssueDate) <  dateadd(month, 1, @date) and
        (
            @State = 'All' or
            StateSalesArea = @State
        )
        
    create nonclustered index il on #py (LeadTime)
    create nonclustered index id on #py (Duration)
    create nonclustered index ia on #py (Age)
    create nonclustered index ic on #py (CancellationCover)
    create nonclustered index ig on #py (GroupName) include (LeadTime,Duration,Age,CancellationCover)

    select 
        @rowcount = count(*)
    from
        #py

    select 
        @MedianLeadTime = avg(1.0 * LeadTime)
    from 
        (
            select 
                LeadTime
            from
                #py
            order by 
                LeadTime
            offset (@rowcount - 1) / 2 rows
            fetch next 1 + (1 - @rowcount % 2) rows only
        ) t

    select 
        @MedianDuration = avg(1.0 * Duration)
    from 
        (
            select 
                Duration
            from
                #py
            order by 
                Duration
            offset (@rowcount - 1) / 2 rows
            fetch next 1 + (1 - @rowcount % 2) rows only
        ) t

    select 
        @MedianAge = avg(1.0 * Age)
    from 
        (
            select 
                Age
            from
                #py
            order by 
                Age
            offset (@rowcount - 1) / 2 rows
            fetch next 1 + (1 - @rowcount % 2) rows only
        ) t

    select 
        @MedianCanx = avg(1.0 * CancellationCover)
    from 
        (
            select 
                CancellationCover
            from
                #py
            order by 
                CancellationCover
            offset (@rowcount - 1) / 2 rows
            fetch next 1 + (1 - @rowcount % 2) rows only
        ) t

    insert into #output
    select 
        'All' Scope,
        'Prior Year' Period,
        @MedianLeadTime MedianLeadTime,
        @MedianDuration MedianDuration,
        @MedianAge MedianAge,
        @MedianCanx MedianCanx

    select 
        @rowcount = count(*)
    from
        #py
    where
        GroupName = @Group

    select 
        @MedianLeadTime = avg(1.0 * LeadTime)
    from 
        (
            select 
                LeadTime
            from
                #py
            where
                GroupName = @Group
            order by 
                LeadTime
            offset (@rowcount - 1) / 2 rows
            fetch next 1 + (1 - @rowcount % 2) rows only
        ) t

    select 
        @MedianDuration = avg(1.0 * Duration)
    from 
        (
            select 
                Duration
            from
                #py
            where
                GroupName = @Group
            order by 
                Duration
            offset (@rowcount - 1) / 2 rows
            fetch next 1 + (1 - @rowcount % 2) rows only
        ) t

    select 
        @MedianAge = avg(1.0 * Age)
    from 
        (
            select 
                Age
            from
                #py
            where
                GroupName = @Group
            order by 
                Age
            offset (@rowcount - 1) / 2 rows
            fetch next 1 + (1 - @rowcount % 2) rows only
        ) t

    select 
        @MedianCanx = avg(1.0 * CancellationCover)
    from 
        (
            select 
                CancellationCover
            from
                #py
            where
                GroupName = @Group
            order by 
                CancellationCover
            offset (@rowcount - 1) / 2 rows
            fetch next 1 + (1 - @rowcount % 2) rows only
        ) t

    insert into #output
    select 
        'Group' Scope,
        'Prior Year' Period,
        @MedianLeadTime MedianLeadTime,
        @MedianDuration MedianDuration,
        @MedianAge MedianAge,
        @MedianCanx MedianCanx

    select *
    from
        #output
    
end
GO
