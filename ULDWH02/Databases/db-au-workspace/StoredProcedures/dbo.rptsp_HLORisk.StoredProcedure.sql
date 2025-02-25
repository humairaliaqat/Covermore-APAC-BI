USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_HLORisk]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_HLORisk]
    @ReportingPeriod varchar(255),
    @Group varchar(255),
    @State varchar(255)

as
begin

    set nocount on

    declare 
        @date date,
        @rowcount bigint,
        @MedianLeadTime int,
        @MedianDuration int,
        @MedianAge int

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
    
    if object_id('tempdb..#alldata') is not null
        drop table #alldata

    select 
        p.PolicyKey,
        case 
            when isnull(datediff(dd, p.IssueDate, p.TripStart), 0) < 0 then 0 
            else isnull(datediff(dd, p.IssueDate, p.TripStart), 0) 
        end LeadTime, 
        case 
            when isnull(TripDuration, 0) < 0 then 0 
            else isnull(TripDuration, 0)
        end Duration, 
        p.IssueDate, 
        p.CancellationCover,
        ptv.Age,
        case 
            when isnull(EMCCount, 0) = 0 then 0 
            else 1 
        end EMCPolicy,
        do.GroupName,
        do.StateSalesArea
    into #alldata
    from 
        [db-au-cmdwh]..penPolicy p
        inner join [db-au-cmdwh]..penOutlet o on 
            o.OutletAlphaKey = p.OutletAlphaKey and 
            o.OutletStatus = 'Current'
        inner join [db-au-cmdwh]..penOutlet lo on 
            lo.OutletStatus = 'Current' and
            lo.OutletKey = o.LatestOutletKey
        cross apply
        (
            select top 1 
                do.SuperGroupName,
                do.GroupName,
                do.StateSalesArea
            from
                [db-au-star]..dimOutlet do
            where
                do.OutletAlphaKey = lo.OutletAlphaKey and
                do.isLatest = 'Y'
        ) do
        cross apply
        (
            select top 1
                Age
            from
                [db-au-cmdwh]..penPolicyTraveller ptv
            where
                p.policykey = ptv.policykey and 
                ptv.isprimary = 1
        ) ptv
        outer apply
        (
            select 
                sum(pt.EMCCount) EMCCount
            from  
                [db-au-cmdwh]..penPolicyTransSummary pt
            where  
                pt.PolicyKey = p.PolicyKey
        ) e
    where 
        do.SuperGroupName = ('helloworld') and 
        o.CountryKey = 'AU' and
        p.AreaType = 'International' and
        p.IssueDate >= @date and
        p.IssueDate <  dateadd(month, 1, @date) and
        o.GroupName = @Group and
        (
            @State = 'All' or
            o.StateSalesArea = @Group
        )

    set @rowcount = @@rowcount

    select 
        @MedianLeadTime = avg(1.0 * LeadTime)
    from 
        (
            select 
                LeadTime
            from
                #alldata
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
                #alldata
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
                #alldata
            order by 
                Age
            offset (@rowcount - 1) / 2 rows
            fetch next 1 + (1 - @rowcount % 2) rows only
        ) t

    select 
        *,
        @MedianLeadTime MedianLeadTime,
        @MedianDuration MedianDuration,
        @MedianAge MedianAge
    from
        #alldata

end
GO
