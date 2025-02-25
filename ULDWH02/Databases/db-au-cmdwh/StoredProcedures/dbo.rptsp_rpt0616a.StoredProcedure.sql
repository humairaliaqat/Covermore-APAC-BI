USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0616a]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[rptsp_rpt0616a]  
    @SuperGroup nvarchar(4000) = 'All',
    @Group nvarchar(4000) = 'All',
    @ReportingPeriod varchar(30),
    @StartDate date = null,
    @EndDate date = null

as
begin


--20160211, PZ, T22114, added "Same Period Last Year" data and new dimension "Period" for Year on Year comparison



--uncomment to debug
--declare 
--    @SuperGroup nvarchar(4000),
--    @Group nvarchar(4000),
--    @ReportingPeriod varchar(30),
--    @StartDate date,
--    @EndDate date
--select 
--    @SuperGroup = 'All',
--    @Group = 'All',
--    @ReportingPeriod = 'Last Month', 
--    @StartDate = null, 
--    @EndDate = null

    set nocount on
                                    
    declare 
        @rptStartDate datetime,
        @rptEndDate datetime,
		@rptStartDate_LY datetime,
        @rptEndDate_LY datetime

    --get reporting dates
    if @ReportingPeriod = '_User Defined'
        select 
            @rptStartDate = @StartDate,
            @rptEndDate = @EndDate,
			@rptStartDate_LY = dateadd(YEAR,-1,@StartDate),
			@rptEndDate_LY = dateadd(YEAR,-1,@EndDate)
            
    else
        select 
            @rptStartDate = StartDate, 
            @rptEndDate = EndDate,
			@rptStartDate_LY = dateadd(YEAR,-1,StartDate),
			@rptEndDate_LY = dateadd(YEAR,-1,EndDate)
        from 
            vDateRange
        where 
            DateRange = @ReportingPeriod



/*
BEGIN - Current Period
*/

    select 
        [Month],
        sum(isnull(PolicyCount, 0)) as PolicyCount,
        0 as ClaimCount,
		'Current' as [Period]
    from
        penOutlet o
        cross apply
        (
            select 
                convert(datetime, convert(varchar(8), pt.PostingDate, 120) + '01') [Month],
                sum(pt.BasePolicyCount) PolicyCount
            from
                penPolicyTransSummary pt 
            where
                pt.OutletAlphaKey = o.OutletAlphaKey and
                pt.PostingDate >= @rptStartDate and
                pt.PostingDate <  dateadd(day, 1, @rptEndDate)
            group by
                convert(datetime, convert(varchar(8), pt.PostingDate, 120) + '01')
        ) p
    where 
        o.OutletStatus = 'Current' and
        o.CountryKey = 'AU' and
        (
            @SuperGroup = 'All' or
            o.SuperGroupName in
            (
                select 
                    Item
                from
                    dbo.fn_DelimitedSplit8K(@SuperGroup, ',')
            )
        ) and
        (
            @Group = 'All' or
            o.GroupName in
            (
                select 
                    Item
                from
                    dbo.fn_DelimitedSplit8K(@Group, ',')
            )
        )
    group by
        [Month]

    union all

    select 
        [Month],
        0 as PolicyCount,
        sum(isnull(ClaimCount, 0)) as ClaimCount,
		'Current' as [Period]
    from
        penOutlet o
        cross apply
        (
            select 
                convert(datetime, convert(varchar(8), cl.CreateDate, 120) + '01') [Month],
                count(cl.ClaimKey) ClaimCount
            from
                clmClaim cl
            where
                cl.OutletKey = o.OutletKey and
                cl.CreateDate >= @rptStartDate and
                cl.CreateDate <  dateadd(day, 1, @rptEndDate)
            group by
                convert(datetime, convert(varchar(8), cl.CreateDate, 120) + '01')
        ) c
    where 
        o.OutletStatus = 'Current' and
        o.CountryKey = 'AU' and
        (
            @SuperGroup = 'All' or
            o.SuperGroupName in
            (
                select 
                    Item
                from
                    dbo.fn_DelimitedSplit8K(@SuperGroup, ',')
            )
        ) and
        (
            @Group = 'All' or
            o.GroupName in
            (
                select 
                    Item
                from
                    dbo.fn_DelimitedSplit8K(@Group, ',')
            )
        )
    group by
        [Month]


/*
END - Current Period
*/

union all


/*
BEGIN - Previous Period
*/

    select 
        [Month],
        sum(isnull(PolicyCount, 0)) as PolicyCount,
        0 as ClaimCount,
		'Previous' as [Period]
    from
        penOutlet o
        cross apply
        (
            select 
                convert(datetime, convert(varchar(8), pt.PostingDate, 120) + '01') [Month],
                sum(pt.BasePolicyCount) PolicyCount
            from
                penPolicyTransSummary pt 
            where
                pt.OutletAlphaKey = o.OutletAlphaKey and
                pt.PostingDate >= @rptStartDate_LY and
                pt.PostingDate <  dateadd(day, 1, @rptEndDate_LY)
            group by
                convert(datetime, convert(varchar(8), pt.PostingDate, 120) + '01')
        ) p
    where 
        o.OutletStatus = 'Current' and
        o.CountryKey = 'AU' and
        (
            @SuperGroup = 'All' or
            o.SuperGroupName in
            (
                select 
                    Item
                from
                    dbo.fn_DelimitedSplit8K(@SuperGroup, ',')
            )
        ) and
        (
            @Group = 'All' or
            o.GroupName in
            (
                select 
                    Item
                from
                    dbo.fn_DelimitedSplit8K(@Group, ',')
            )
        )
    group by
        [Month]

    union all

    select 
        [Month],
        0 PolicyCount,
        sum(isnull(ClaimCount, 0)) ClaimCount,
		'Previous' as [Period]
    from
        penOutlet o
        cross apply
        (
            select 
                convert(datetime, convert(varchar(8), cl.CreateDate, 120) + '01') [Month],
                count(cl.ClaimKey) ClaimCount
            from
                clmClaim cl
            where
                cl.OutletKey = o.OutletKey and
                cl.CreateDate >= @rptStartDate_LY and
                cl.CreateDate <  dateadd(day, 1, @rptEndDate_LY)
            group by
                convert(datetime, convert(varchar(8), cl.CreateDate, 120) + '01')
        ) c
    where 
        o.OutletStatus = 'Current' and
        o.CountryKey = 'AU' and
        (
            @SuperGroup = 'All' or
            o.SuperGroupName in
            (
                select 
                    Item
                from
                    dbo.fn_DelimitedSplit8K(@SuperGroup, ',')
            )
        ) and
        (
            @Group = 'All' or
            o.GroupName in
            (
                select 
                    Item
                from
                    dbo.fn_DelimitedSplit8K(@Group, ',')
            )
        )
    group by
        [Month]
       

/*
END - Previous Period
*/


end

GO
