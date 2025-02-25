USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0616a_v2_Test_INC0319227]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0616a_v2_Test_INC0319227]
    @country nvarchar(5),
    @SuperGroup nvarchar(4000) = 'All',
    @Group nvarchar(4000) = 'All',
	@SubGroup nvarchar(4000) = 'All',
	@Underwriter nvarchar(4000) = 'All',
    @ReportingPeriod varchar(30),
    @StartDate date = null,
    @EndDate date = null

as
begin

/****************************************************************************************************/
--  Name:          rptsp_rpt0616a_v2
--  Author:        Leonardus Setyabudi
--  Date Created:  20160120
--  Description:   This stored procedure extract Complain, IDR, Claim and Policy data
--  
--					20160211, PZ, TFS22114, added "Same Period Last Year" data and new dimension "Period" 
--								  for Year on Year comparison
--					20160304, PZ, TFS22114, add "Current FYTD" data
--			        20160311, PZ, TFS22114, add new prompt of "Country"
--					20161011, PZ, TFS27751, add subgroupname as stored proc parameter
--					20170720, SD, INC0039837, add Underwriter as stored proc parameter
--					20171101, LT, Updated UW definition for ETI and ERV
--
/****************************************************************************************************/





--uncomment to debug
--declare
--	@Country nvarchar(5),
--    @SuperGroup nvarchar(4000),
--    @Group nvarchar(4000),
--	@SubGroup nvarchar(4000),
--	@Underwriter nvarchar(4000),
--    @ReportingPeriod varchar(30),
--    @StartDate date,
--    @EndDate date
--select
--	@Country = 'AU',
--    @SuperGroup = 'All',
--    @Group = 'All',
--	@SubGroup = 'All',
--	@Underwriter = 'All',
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


	-- Get start date and end date for current fiscal year
    declare @FYsd date = (select c.CurFiscalYearStart from Calendar c where c.[Date] = @rptEndDate)
    declare @FYed date = (select c.CurMonthEnd from Calendar c where c.[Date] = @rptEndDate)



If @Underwriter = 'ALL'

/*
BEGIN - Current Period
*/

    select
        [Month],
        sum(isnull(PolicyCount, 0)) as PolicyCount,
        0 as ClaimCount,
        'Current' as [Period]
    from
        [db-au-cmdwh]..penOutlet o with(nolock)
        cross apply
        (
            select
                convert(datetime, convert(varchar(8), pt.PostingDate, 120) + '01') [Month],
                sum(pt.BasePolicyCount) PolicyCount
            from
                [db-au-cmdwh]..penPolicyTransSummary pt with(nolock)
            where
                pt.OutletAlphaKey = o.OutletAlphaKey and
                pt.PostingDate >= @rptStartDate and
                pt.PostingDate <  dateadd(day, 1, @rptEndDate)
            group by
                convert(datetime, convert(varchar(8), pt.PostingDate, 120) + '01')
        ) p
    where
        o.OutletStatus = 'Current' and
        o.CountryKey = @Country 
		and
        (
            @SuperGroup = 'All' or
            o.SuperGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SuperGroup, ',')
            )
        ) 
		and
        (
            @Group = 'All' or
            o.GroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Group, ',')
            )
        )
		and
        (
            @SubGroup = 'All' or
            o.SubGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SubGroup, ',')
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
        [db-au-cmdwh]..penOutlet o with(nolock)
        cross apply
        (
            select
                convert(datetime, convert(varchar(8), cl.CreateDate, 120) + '01') [Month],
                count(cl.ClaimKey) ClaimCount
            from
                [db-au-cmdwh]..clmClaim cl with(nolock)
            where
                cl.OutletKey = o.OutletKey and
                cl.CreateDate >= @rptStartDate and
                cl.CreateDate <  dateadd(day, 1, @rptEndDate)
            group by
                convert(datetime, convert(varchar(8), cl.CreateDate, 120) + '01')
        ) c
    where
        o.OutletStatus = 'Current' and
        o.CountryKey = @Country 
		and
        (
            @SuperGroup = 'All' or
            o.SuperGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SuperGroup, ',')
            )
        ) 
		and
        (
            @Group = 'All' or
            o.GroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Group, ',')
            )
        )
		and
        (
            @SubGroup = 'All' or
            o.SubGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SubGroup, ',')
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
        [db-au-cmdwh]..penOutlet o with(nolock)
        cross apply
        (
            select
                convert(datetime, convert(varchar(8), pt.PostingDate, 120) + '01') [Month],
                sum(pt.BasePolicyCount) PolicyCount
            from
                [db-au-cmdwh]..penPolicyTransSummary pt with(nolock)
            where
                pt.OutletAlphaKey = o.OutletAlphaKey and
                pt.PostingDate >= @rptStartDate_LY and
                pt.PostingDate <  dateadd(day, 1, @rptEndDate_LY)
            group by
                convert(datetime, convert(varchar(8), pt.PostingDate, 120) + '01')
        ) p
    where
        o.OutletStatus = 'Current' and
        o.CountryKey = @Country and
        (
            @SuperGroup = 'All' or
            o.SuperGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SuperGroup, ',')
            )
        ) and
        (
            @Group = 'All' or
            o.GroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Group, ',')
            )
        )
		and
        (
            @SubGroup = 'All' or
            o.SubGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SubGroup, ',')
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
        [db-au-cmdwh]..penOutlet o with(nolock)
        cross apply
        (
            select
                convert(datetime, convert(varchar(8), cl.CreateDate, 120) + '01') [Month],
                count(cl.ClaimKey) ClaimCount
            from
                [db-au-cmdwh]..clmClaim cl with(nolock)
            where
                cl.OutletKey = o.OutletKey and
                cl.CreateDate >= @rptStartDate_LY and
                cl.CreateDate <  dateadd(day, 1, @rptEndDate_LY)
            group by
                convert(datetime, convert(varchar(8), cl.CreateDate, 120) + '01')
        ) c
    where
        o.OutletStatus = 'Current' and
        o.CountryKey = @Country and
        (
            @SuperGroup = 'All' or
            o.SuperGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SuperGroup, ',')
            )
        ) and
        (
            @Group = 'All' or
            o.GroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Group, ',')
            )
        )
		and
        (
            @SubGroup = 'All' or
            o.SubGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SubGroup, ',')
            )
        )
    group by
        [Month]


/*
END - Previous Period
*/


union all


/*
BEGIN - Current FYTD
*/

    select
        [Month],
        sum(isnull(PolicyCount, 0)) as PolicyCount,
        0 as ClaimCount,
        'Current FYTD' as [Period]
    from
        [db-au-cmdwh]..penOutlet o with(nolock)
        cross apply
        (
            select
                convert(datetime, convert(varchar(8), pt.PostingDate, 120) + '01') [Month],
                sum(pt.BasePolicyCount) PolicyCount
            from
                [db-au-cmdwh]..penPolicyTransSummary pt with(nolock)
            where
                pt.OutletAlphaKey = o.OutletAlphaKey and
				pt.PostingDate >= @FYsd and
				pt.PostingDate <  dateadd(day, 1, @FYed)
            group by
                convert(datetime, convert(varchar(8), pt.PostingDate, 120) + '01')
        ) p
    where
        o.OutletStatus = 'Current' and
        o.CountryKey = @Country and
        (
            @SuperGroup = 'All' or
            o.SuperGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SuperGroup, ',')
            )
        ) and
        (
            @Group = 'All' or
            o.GroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Group, ',')
            )
        )
		and
        (
            @SubGroup = 'All' or
            o.SubGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SubGroup, ',')
            )
        )
    group by
        [Month]

    union all

    select
        [Month],
        0 PolicyCount,
        sum(isnull(ClaimCount, 0)) ClaimCount,
        'Current FYTD' as [Period]
    from
        [db-au-cmdwh]..penOutlet o with(nolock)
        cross apply
        (
            select
                convert(datetime, convert(varchar(8), cl.CreateDate, 120) + '01') [Month],
                count(cl.ClaimKey) ClaimCount
            from
                [db-au-cmdwh]..clmClaim cl with(nolock)
            where
                cl.OutletKey = o.OutletKey and
                cl.CreateDate >= @FYsd and
                cl.CreateDate <  dateadd(day, 1, @FYed)
            group by
                convert(datetime, convert(varchar(8), cl.CreateDate, 120) + '01')
        ) c
    where
        o.OutletStatus = 'Current' and
        o.CountryKey = @Country and
        (
            @SuperGroup = 'All' or
            o.SuperGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SuperGroup, ',')
            )
        ) and
        (
            @Group = 'All' or
            o.GroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Group, ',')
            )
        )
		and
        (
            @SubGroup = 'All' or
            o.SubGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SubGroup, ',')
            )
        )
    group by
        [Month]


/*
END - Current FYTD
*/


Else

/*
BEGIN - Current Period
*/

    select
        [Month],
        sum(isnull(PolicyCount, 0)) as PolicyCount,
        0 as ClaimCount,
        'Current' as [Period],
		Underwriter
    from
        [db-au-cmdwh]..penOutlet o with(nolock)
        cross apply
        (
            select
                convert(datetime, convert(varchar(8), pt.PostingDate, 120) + '01') [Month],
                sum(pt.BasePolicyCount) PolicyCount,
				uw1.Underwriter
            from
                [db-au-cmdwh]..penPolicyTransSummary pt with(nolock)
				inner join [db-au-cmdwh]..penPolicy pp
					on pt.PolicyKey = pp.PolicyKey
				inner join [db-au-cmdwh]..penOutlet po with(nolock)
					on po.OutletAlphaKey = pt.OutletAlphaKey and
						po.OutletStatus = 'Current'

         outer apply (
SELECT 
case 
					   when pt.CompanyKey = 'TIP' and (pp.IssueDate < '2017-06-01' OR (o.AlphaCode in ('APN0004', 'APN0005') and pp.IssueDate < '2017-07-01')) then 'TIP-GLA'
					   when pt.CompanyKey = 'TIP' and (pp.IssueDate >= '2017-06-01' OR (o.AlphaCode in ('APN0004','APN0005') and pp.IssueDate >= '2017-07-01')) then 'TIP-ZURICH'
					   when pt.CountryKey in ('AU', 'NZ') and pp.IssueDate >= '2009-07-01' and pp.IssueDate < '2017-06-01' then 'GLA'
					   when pt.CountryKey in ('AU', 'NZ') and pp.IssueDate >= '2017-06-01' then 'ZURICH' 
					   when pt.CountryKey in ('AU', 'NZ') and pp.IssueDate <= '2009-06-30' then 'VERO' 
					   when pt.CountryKey in ('UK') and pp.IssueDate >= '2009-09-01' and pp.IssueDate < '2017-07-01' then 'ETI' 
					   when pt.CountryKey in ('UK') and pp.IssueDate >= '2017-07-01' then 'ERV' 
					   when pt.CountryKey in ('UK') and pp.IssueDate < '2009-09-01' then 'UKU' 
					   when pt.CountryKey in ('MY', 'SG') then 'ETIQA' 
					   when pt.CountryKey in ('CN') then 'CCIC' 
					   when pt.CountryKey in ('ID') then 'Simas Net' 
					   when pt.CountryKey in ('US') then 'AON'
					   else 'OTHER' 
					end as Underwriter )uw1

            where
                pt.OutletAlphaKey = o.OutletAlphaKey and
                pt.PostingDate >= @rptStartDate and
                pt.PostingDate <  dateadd(day, 1, @rptEndDate) and
				(
					@Underwriter = 'All' or
					case 
					   when pt.CompanyKey = 'TIP' and (pp.IssueDate < '2017-06-01' OR (o.AlphaCode in ('APN0004', 'APN0005') and pp.IssueDate < '2017-07-01')) then 'TIP-GLA'
					   when pt.CompanyKey = 'TIP' and (pp.IssueDate >= '2017-06-01' OR (o.AlphaCode in ('APN0004','APN0005') and pp.IssueDate >= '2017-07-01')) then 'TIP-ZURICH'
					   when pt.CountryKey in ('AU', 'NZ') and pp.IssueDate >= '2009-07-01' and pp.IssueDate < '2017-06-01' then 'GLA'
					   when pt.CountryKey in ('AU', 'NZ') and pp.IssueDate >= '2017-06-01' then 'ZURICH' 
					   when pt.CountryKey in ('AU', 'NZ') and pp.IssueDate <= '2009-06-30' then 'VERO' 
					   when pt.CountryKey in ('UK') and pp.IssueDate >= '2009-09-01' and pp.IssueDate < '2017-07-01' then 'ETI' 
					   when pt.CountryKey in ('UK') and pp.IssueDate >= '2017-07-01' then 'ERV' 
					   when pt.CountryKey in ('UK') and pp.IssueDate < '2009-09-01' then 'UKU' 
					   when pt.CountryKey in ('MY', 'SG') then 'ETIQA' 
					   when pt.CountryKey in ('CN') then 'CCIC' 
					   when pt.CountryKey in ('ID') then 'Simas Net' 
					   when pt.CountryKey in ('US') then 'AON'
					   else 'OTHER' 
					end in
						(
							select
								Item
							from
								[db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Underwriter, ',')
						)
					)
            group by
                convert(datetime, convert(varchar(8), pt.PostingDate, 120) + '01'),
				uw1.Underwriter
				
        ) p
    where
        o.OutletStatus = 'Current' and
        o.CountryKey = @Country 
		and
        (
            @SuperGroup = 'All' or
            o.SuperGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SuperGroup, ',')
            )
        ) 
		and
        (
            @Group = 'All' or
            o.GroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Group, ',')
            )
        )
		and
        (
            @SubGroup = 'All' or
            o.SubGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SubGroup, ',')
            )
        )
    group by
        [Month],
		Underwriter

    union all

    select
        [Month],
        0 as PolicyCount,
        sum(isnull(ClaimCount, 0)) as ClaimCount,
        'Current' as [Period],
		Underwriter
    from
        [db-au-cmdwh]..penOutlet o with(nolock)
        cross apply
        (
            select
                convert(datetime, convert(varchar(8), cl.CreateDate, 120) + '01') [Month],
                count(cl.ClaimKey) ClaimCount,
				uw2.Underwriter
            from
                [db-au-cmdwh]..clmClaim cl with(nolock)
				left join [db-au-cmdwh]..penPolicy pp1 with(nolock)
					on cl.PolicyNo = pp1.PolicyNumber and cl.CountryKey = pp1.CountryKey
				left join [db-au-cmdwh]..penOutlet po1 with(nolock)
					on po1.OutletAlphaKey = pp1.OutletAlphaKey and po1.OutletStatus = 'Current'

outer apply (
select 
case 
					   when pp1.CompanyKey = 'TIP' and (pp1.IssueDate < '2017-06-01' OR (po1.AlphaCode in ('APN0004', 'APN0005') and pp1.IssueDate < '2017-07-01')) then 'TIP-GLA'
					   when pp1.CompanyKey = 'TIP' and (pp1.IssueDate >= '2017-06-01' OR (po1.AlphaCode in ('APN0004','APN0005') and pp1.IssueDate >= '2017-07-01')) then 'TIP-ZURICH'
					   when pp1.CountryKey in ('AU', 'NZ') and pp1.IssueDate >= '2009-07-01' and pp1.IssueDate < '2017-06-01' then 'GLA'
					   when pp1.CountryKey in ('AU', 'NZ') and pp1.IssueDate >= '2017-06-01' then 'ZURICH' 
					   when pp1.CountryKey in ('AU', 'NZ') and pp1.IssueDate <= '2009-06-30' then 'VERO' 
					   when pp1.CountryKey in ('UK') and pp1.IssueDate >= '2009-09-01' and pp1.IssueDate < '2017-07-01' then 'ETI' 
					   when pp1.CountryKey in ('UK') and pp1.IssueDate >= '2017-07-01' then 'ERV' 
					   when pp1.CountryKey in ('UK') and pp1.IssueDate < '2009-09-01' then 'UKU' 
					   when pp1.CountryKey in ('MY', 'SG') then 'ETIQA' 
					   when pp1.CountryKey in ('CN') then 'CCIC' 
					   when pp1.CountryKey in ('ID') then 'Simas Net' 
					   when pp1.CountryKey in ('US') then 'AON'
					   else 'OTHER' 
					end as Underwriter )uw2


            where
                cl.OutletKey = o.OutletKey and
                cl.CreateDate >= @rptStartDate and
                cl.CreateDate <  dateadd(day, 1, @rptEndDate) and
				(
					@Underwriter = 'All' or
					case 
					   when pp1.CompanyKey = 'TIP' and (pp1.IssueDate < '2017-06-01' OR (po1.AlphaCode in ('APN0004', 'APN0005') and pp1.IssueDate < '2017-07-01')) then 'TIP-GLA'
					   when pp1.CompanyKey = 'TIP' and (pp1.IssueDate >= '2017-06-01' OR (po1.AlphaCode in ('APN0004','APN0005') and pp1.IssueDate >= '2017-07-01')) then 'TIP-ZURICH'
					   when pp1.CountryKey in ('AU', 'NZ') and pp1.IssueDate >= '2009-07-01' and pp1.IssueDate < '2017-06-01' then 'GLA'
					   when pp1.CountryKey in ('AU', 'NZ') and pp1.IssueDate >= '2017-06-01' then 'ZURICH' 
					   when pp1.CountryKey in ('AU', 'NZ') and pp1.IssueDate <= '2009-06-30' then 'VERO' 
					   when pp1.CountryKey in ('UK') and pp1.IssueDate >= '2009-09-01' and pp1.IssueDate < '2017-07-01' then 'ETI' 
					   when pp1.CountryKey in ('UK') and pp1.IssueDate >= '2017-07-01' then 'ERV' 
					   when pp1.CountryKey in ('UK') and pp1.IssueDate < '2009-09-01' then 'UKU' 
					   when pp1.CountryKey in ('MY', 'SG') then 'ETIQA' 
					   when pp1.CountryKey in ('CN') then 'CCIC' 
					   when pp1.CountryKey in ('ID') then 'Simas Net' 
					   when pp1.CountryKey in ('US') then 'AON'
					   else 'OTHER' 
					end in
						(
							select
								Item
							from
								[db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Underwriter, ',')
						)
					)
            group by
                convert(datetime, convert(varchar(8), cl.CreateDate, 120) + '01'),
				uw2.Underwriter
        ) c
    where
        o.OutletStatus = 'Current' and
        o.CountryKey = @Country 
		and
        (
            @SuperGroup = 'All' or
            o.SuperGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SuperGroup, ',')
            )
        ) 
		and
        (
            @Group = 'All' or
            o.GroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Group, ',')
            )
        )
		and
        (
            @SubGroup = 'All' or
            o.SubGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SubGroup, ',')
            )
        )
    group by
        [Month],
		Underwriter


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
        'Previous' as [Period],
		Underwriter
    from
        [db-au-cmdwh]..penOutlet o with(nolock)
        cross apply
        (
            select
                convert(datetime, convert(varchar(8), pt.PostingDate, 120) + '01') [Month],
                sum(pt.BasePolicyCount) PolicyCount,
				uw3.Underwriter
            from
                [db-au-cmdwh]..penPolicyTransSummary pt with(nolock)
				inner join [db-au-cmdwh]..penPolicy pp
					on pt.PolicyKey = pp.PolicyKey
				inner join [db-au-cmdwh]..penOutlet po with(nolock)
					on po.OutletAlphaKey = pt.OutletAlphaKey and
						po.OutletStatus = 'Current'

outer apply (
select 
case 
					   when pt.CompanyKey = 'TIP' and (pp.IssueDate < '2017-06-01' OR (o.AlphaCode in ('APN0004', 'APN0005') and pp.IssueDate < '2017-07-01')) then 'TIP-GLA'
					   when pt.CompanyKey = 'TIP' and (pp.IssueDate >= '2017-06-01' OR (o.AlphaCode in ('APN0004','APN0005') and pp.IssueDate >= '2017-07-01')) then 'TIP-ZURICH'
					   when pt.CountryKey in ('AU', 'NZ') and pp.IssueDate >= '2009-07-01' and pp.IssueDate < '2017-06-01' then 'GLA'
					   when pt.CountryKey in ('AU', 'NZ') and pp.IssueDate >= '2017-06-01' then 'ZURICH' 
					   when pt.CountryKey in ('AU', 'NZ') and pp.IssueDate <= '2009-06-30' then 'VERO' 
					   when pt.CountryKey in ('UK') and pp.IssueDate >= '2009-09-01' and pp.IssueDate < '2017-07-01' then 'ETI' 
					   when pt.CountryKey in ('UK') and pp.IssueDate >= '2017-07-01' then 'ERV' 
					   when pt.CountryKey in ('UK') and pp.IssueDate < '2009-09-01' then 'UKU' 
					   when pt.CountryKey in ('MY', 'SG') then 'ETIQA' 
					   when pt.CountryKey in ('CN') then 'CCIC' 
					   when pt.CountryKey in ('ID') then 'Simas Net' 
					   when pt.CountryKey in ('US') then 'AON'
					   else 'OTHER' 
					end as Underwriter )uw3

            where
                pt.OutletAlphaKey = o.OutletAlphaKey and
                pt.PostingDate >= @rptStartDate_LY and
                pt.PostingDate <  dateadd(day, 1, @rptEndDate_LY) and
				(
					@Underwriter = 'All' or
					case 
					   when pt.CompanyKey = 'TIP' and (pp.IssueDate < '2017-06-01' OR (o.AlphaCode in ('APN0004', 'APN0005') and pp.IssueDate < '2017-07-01')) then 'TIP-GLA'
					   when pt.CompanyKey = 'TIP' and (pp.IssueDate >= '2017-06-01' OR (o.AlphaCode in ('APN0004','APN0005') and pp.IssueDate >= '2017-07-01')) then 'TIP-ZURICH'
					   when pt.CountryKey in ('AU', 'NZ') and pp.IssueDate >= '2009-07-01' and pp.IssueDate < '2017-06-01' then 'GLA'
					   when pt.CountryKey in ('AU', 'NZ') and pp.IssueDate >= '2017-06-01' then 'ZURICH' 
					   when pt.CountryKey in ('AU', 'NZ') and pp.IssueDate <= '2009-06-30' then 'VERO' 
					   when pt.CountryKey in ('UK') and pp.IssueDate >= '2009-09-01' and pp.IssueDate < '2017-07-01' then 'ETI' 
					   when pt.CountryKey in ('UK') and pp.IssueDate >= '2017-07-01' then 'ERV' 
					   when pt.CountryKey in ('UK') and pp.IssueDate < '2009-09-01' then 'UKU' 
					   when pt.CountryKey in ('MY', 'SG') then 'ETIQA' 
					   when pt.CountryKey in ('CN') then 'CCIC' 
					   when pt.CountryKey in ('ID') then 'Simas Net' 
					   when pt.CountryKey in ('US') then 'AON'
					   else 'OTHER' 
					end in
						(
							select
								Item
							from
								[db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Underwriter, ',')
						)
					)
            group by
                convert(datetime, convert(varchar(8), pt.PostingDate, 120) + '01'),
				uw3.Underwriter
        ) p
    where
        o.OutletStatus = 'Current' and
        o.CountryKey = @Country and
        (
            @SuperGroup = 'All' or
            o.SuperGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SuperGroup, ',')
            )
        ) and
        (
            @Group = 'All' or
            o.GroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Group, ',')
            )
        )
		and
        (
            @SubGroup = 'All' or
            o.SubGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SubGroup, ',')
            )
        )
    group by
        [Month],
		Underwriter

    union all

    select
        [Month],
        0 PolicyCount,
        sum(isnull(ClaimCount, 0)) ClaimCount,
        'Previous' as [Period],
		Underwriter
    from
        [db-au-cmdwh]..penOutlet o with(nolock)
        cross apply
        (
            select
                convert(datetime, convert(varchar(8), cl.CreateDate, 120) + '01') [Month],
                count(cl.ClaimKey) ClaimCount,
				uw4.Underwriter
            from
                [db-au-cmdwh]..clmClaim cl with(nolock)
				left join [db-au-cmdwh]..penPolicy pp1 with(nolock)
					on cl.PolicyNo = pp1.PolicyNumber and cl.CountryKey = pp1.CountryKey
				left join [db-au-cmdwh]..penOutlet po1 with(nolock)
					on po1.OutletAlphaKey = pp1.OutletAlphaKey and po1.OutletStatus = 'Current'

outer apply (
select 
case 
					   when pp1.CompanyKey = 'TIP' and (pp1.IssueDate < '2017-06-01' OR (po1.AlphaCode in ('APN0004', 'APN0005') and pp1.IssueDate < '2017-07-01')) then 'TIP-GLA'
					   when pp1.CompanyKey = 'TIP' and (pp1.IssueDate >= '2017-06-01' OR (po1.AlphaCode in ('APN0004','APN0005') and pp1.IssueDate >= '2017-07-01')) then 'TIP-ZURICH'
					   when pp1.CountryKey in ('AU', 'NZ') and pp1.IssueDate >= '2009-07-01' and pp1.IssueDate < '2017-06-01' then 'GLA'
					   when pp1.CountryKey in ('AU', 'NZ') and pp1.IssueDate >= '2017-06-01' then 'ZURICH' 
					   when pp1.CountryKey in ('AU', 'NZ') and pp1.IssueDate <= '2009-06-30' then 'VERO' 
					   when pp1.CountryKey in ('UK') and pp1.IssueDate >= '2009-09-01' and pp1.IssueDate < '2017-07-01' then 'ETI' 
					   when pp1.CountryKey in ('UK') and pp1.IssueDate >= '2017-07-01' then 'ERV' 
					   when pp1.CountryKey in ('UK') and pp1.IssueDate < '2009-09-01' then 'UKU' 
					   when pp1.CountryKey in ('MY', 'SG') then 'ETIQA' 
					   when pp1.CountryKey in ('CN') then 'CCIC' 
					   when pp1.CountryKey in ('ID') then 'Simas Net' 
					   when pp1.CountryKey in ('US') then 'AON'
					   else 'OTHER' 
					end as Underwriter )uw4

            where
                cl.OutletKey = o.OutletKey and
                cl.CreateDate >= @rptStartDate_LY and
                cl.CreateDate <  dateadd(day, 1, @rptEndDate_LY) and
				(
					@Underwriter = 'All' or
					case 
					   when pp1.CompanyKey = 'TIP' and (pp1.IssueDate < '2017-06-01' OR (po1.AlphaCode in ('APN0004', 'APN0005') and pp1.IssueDate < '2017-07-01')) then 'TIP-GLA'
					   when pp1.CompanyKey = 'TIP' and (pp1.IssueDate >= '2017-06-01' OR (po1.AlphaCode in ('APN0004','APN0005') and pp1.IssueDate >= '2017-07-01')) then 'TIP-ZURICH'
					   when pp1.CountryKey in ('AU', 'NZ') and pp1.IssueDate >= '2009-07-01' and pp1.IssueDate < '2017-06-01' then 'GLA'
					   when pp1.CountryKey in ('AU', 'NZ') and pp1.IssueDate >= '2017-06-01' then 'ZURICH' 
					   when pp1.CountryKey in ('AU', 'NZ') and pp1.IssueDate <= '2009-06-30' then 'VERO' 
					   when pp1.CountryKey in ('UK') and pp1.IssueDate >= '2009-09-01' and pp1.IssueDate < '2017-07-01' then 'ETI' 
					   when pp1.CountryKey in ('UK') and pp1.IssueDate >= '2017-07-01' then 'ERV' 
					   when pp1.CountryKey in ('UK') and pp1.IssueDate < '2009-09-01' then 'UKU' 
					   when pp1.CountryKey in ('MY', 'SG') then 'ETIQA' 
					   when pp1.CountryKey in ('CN') then 'CCIC' 
					   when pp1.CountryKey in ('ID') then 'Simas Net' 
					   when pp1.CountryKey in ('US') then 'AON'
					   else 'OTHER' 
					end in
						(
							select
								Item
							from
								[db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Underwriter, ',')
						)
					)
            group by
                convert(datetime, convert(varchar(8), cl.CreateDate, 120) + '01'),
				uw4.Underwriter
        ) c
    where
        o.OutletStatus = 'Current' and
        o.CountryKey = @Country and
        (
            @SuperGroup = 'All' or
            o.SuperGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SuperGroup, ',')
            )
        ) and
        (
            @Group = 'All' or
            o.GroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Group, ',')
            )
        )
		and
        (
            @SubGroup = 'All' or
            o.SubGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SubGroup, ',')
            )
        )
    group by
        [Month],
		Underwriter


/*
END - Previous Period
*/


union all


/*
BEGIN - Current FYTD
*/

    select
        [Month],
        sum(isnull(PolicyCount, 0)) as PolicyCount,
        0 as ClaimCount,
        'Current FYTD' as [Period],
		Underwriter
    from
        [db-au-cmdwh]..penOutlet o with(nolock)
        cross apply
        (
            select
                convert(datetime, convert(varchar(8), pt.PostingDate, 120) + '01') [Month],
                sum(pt.BasePolicyCount) PolicyCount,
				uw5.Underwriter
            from
                [db-au-cmdwh]..penPolicyTransSummary pt with(nolock)
				inner join [db-au-cmdwh]..penPolicy pp
					on pt.PolicyKey = pp.PolicyKey
				inner join [db-au-cmdwh]..penOutlet po with(nolock)
					on po.OutletAlphaKey = pt.OutletAlphaKey and
						po.OutletStatus = 'Current'

outer apply(
select
case 
					   when pt.CompanyKey = 'TIP' and (pp.IssueDate < '2017-06-01' OR (o.AlphaCode in ('APN0004', 'APN0005') and pp.IssueDate < '2017-07-01')) then 'TIP-GLA'
					   when pt.CompanyKey = 'TIP' and (pp.IssueDate >= '2017-06-01' OR (o.AlphaCode in ('APN0004','APN0005') and pp.IssueDate >= '2017-07-01')) then 'TIP-ZURICH'
					   when pt.CountryKey in ('AU', 'NZ') and pp.IssueDate >= '2009-07-01' and pp.IssueDate < '2017-06-01' then 'GLA'
					   when pt.CountryKey in ('AU', 'NZ') and pp.IssueDate >= '2017-06-01' then 'ZURICH' 
					   when pt.CountryKey in ('AU', 'NZ') and pp.IssueDate <= '2009-06-30' then 'VERO' 
					   when pt.CountryKey in ('UK') and pp.IssueDate >= '2009-09-01' and pp.IssueDate < '2017-07-01' then 'ETI' 
					   when pt.CountryKey in ('UK') and pp.IssueDate >= '2017-07-01' then 'ERV' 
					   when pt.CountryKey in ('UK') and pp.IssueDate < '2009-09-01' then 'UKU' 
					   when pt.CountryKey in ('MY', 'SG') then 'ETIQA' 
					   when pt.CountryKey in ('CN') then 'CCIC' 
					   when pt.CountryKey in ('ID') then 'Simas Net' 
					   when pt.CountryKey in ('US') then 'AON'
					   else 'OTHER' 
					end as Underwriter )uw5

            where
                pt.OutletAlphaKey = o.OutletAlphaKey and
				pt.PostingDate >= @FYsd and
				pt.PostingDate <  dateadd(day, 1, @FYed) and
				(
					@Underwriter = 'All' or
					case 
					   when pt.CompanyKey = 'TIP' and (pp.IssueDate < '2017-06-01' OR (o.AlphaCode in ('APN0004', 'APN0005') and pp.IssueDate < '2017-07-01')) then 'TIP-GLA'
					   when pt.CompanyKey = 'TIP' and (pp.IssueDate >= '2017-06-01' OR (o.AlphaCode in ('APN0004','APN0005') and pp.IssueDate >= '2017-07-01')) then 'TIP-ZURICH'
					   when pt.CountryKey in ('AU', 'NZ') and pp.IssueDate >= '2009-07-01' and pp.IssueDate < '2017-06-01' then 'GLA'
					   when pt.CountryKey in ('AU', 'NZ') and pp.IssueDate >= '2017-06-01' then 'ZURICH' 
					   when pt.CountryKey in ('AU', 'NZ') and pp.IssueDate <= '2009-06-30' then 'VERO' 
					   when pt.CountryKey in ('UK') and pp.IssueDate >= '2009-09-01' and pp.IssueDate < '2017-07-01' then 'ETI' 
					   when pt.CountryKey in ('UK') and pp.IssueDate >= '2017-07-01' then 'ERV' 
					   when pt.CountryKey in ('UK') and pp.IssueDate < '2009-09-01' then 'UKU' 
					   when pt.CountryKey in ('MY', 'SG') then 'ETIQA' 
					   when pt.CountryKey in ('CN') then 'CCIC' 
					   when pt.CountryKey in ('ID') then 'Simas Net' 
					   when pt.CountryKey in ('US') then 'AON'
					   else 'OTHER' 
					end in
						(
							select
								Item
							from
								[db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Underwriter, ',')
						)
					)
            group by
                convert(datetime, convert(varchar(8), pt.PostingDate, 120) + '01'),
				uw5.Underwriter
        ) p
    where
        o.OutletStatus = 'Current' and
        o.CountryKey = @Country and
        (
            @SuperGroup = 'All' or
            o.SuperGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SuperGroup, ',')
            )
        ) and
        (
            @Group = 'All' or
            o.GroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Group, ',')
            )
        )
		and
        (
            @SubGroup = 'All' or
            o.SubGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SubGroup, ',')
            )
        )
    group by
        [Month],
		Underwriter

    union all

    select
        [Month],
        0 PolicyCount,
        sum(isnull(ClaimCount, 0)) ClaimCount,
        'Current FYTD' as [Period],
		Underwriter
    from
        [db-au-cmdwh]..penOutlet o with(nolock)
        cross apply
        (
            select
                convert(datetime, convert(varchar(8), cl.CreateDate, 120) + '01') [Month],
                count(cl.ClaimKey) ClaimCount,
				uw6.Underwriter
            from
                [db-au-cmdwh]..clmClaim cl with(nolock)
				left join [db-au-cmdwh]..penPolicy pp1 with(nolock)
					on cl.PolicyNo = pp1.PolicyNumber and cl.CountryKey = pp1.CountryKey
				left join [db-au-cmdwh]..penOutlet po1 with(nolock)
					on po1.OutletAlphaKey = pp1.OutletAlphaKey and po1.OutletStatus = 'Current'

outer apply (
select
case 
					   when pp1.CompanyKey = 'TIP' and (pp1.IssueDate < '2017-06-01' OR (po1.AlphaCode in ('APN0004', 'APN0005') and pp1.IssueDate < '2017-07-01')) then 'TIP-GLA'
					   when pp1.CompanyKey = 'TIP' and (pp1.IssueDate >= '2017-06-01' OR (po1.AlphaCode in ('APN0004','APN0005') and pp1.IssueDate >= '2017-07-01')) then 'TIP-ZURICH'
					   when pp1.CountryKey in ('AU', 'NZ') and pp1.IssueDate >= '2009-07-01' and pp1.IssueDate < '2017-06-01' then 'GLA'
					   when pp1.CountryKey in ('AU', 'NZ') and pp1.IssueDate >= '2017-06-01' then 'ZURICH' 
					   when pp1.CountryKey in ('AU', 'NZ') and pp1.IssueDate <= '2009-06-30' then 'VERO' 
					   when pp1.CountryKey in ('UK') and pp1.IssueDate >= '2009-09-01' and pp1.IssueDate < '2017-07-01' then 'ETI' 
					   when pp1.CountryKey in ('UK') and pp1.IssueDate >= '2017-07-01' then 'ERV' 
					   when pp1.CountryKey in ('UK') and pp1.IssueDate < '2009-09-01' then 'UKU' 
					   when pp1.CountryKey in ('MY', 'SG') then 'ETIQA' 
					   when pp1.CountryKey in ('CN') then 'CCIC' 
					   when pp1.CountryKey in ('ID') then 'Simas Net' 
					   when pp1.CountryKey in ('US') then 'AON'
					   else 'OTHER' 
					end as Underwriter )uw6

            where
                cl.OutletKey = o.OutletKey and
                cl.CreateDate >= @FYsd and
                cl.CreateDate <  dateadd(day, 1, @FYed) and
				(
					@Underwriter = 'All' or
					case 
					   when pp1.CompanyKey = 'TIP' and (pp1.IssueDate < '2017-06-01' OR (po1.AlphaCode in ('APN0004', 'APN0005') and pp1.IssueDate < '2017-07-01')) then 'TIP-GLA'
					   when pp1.CompanyKey = 'TIP' and (pp1.IssueDate >= '2017-06-01' OR (po1.AlphaCode in ('APN0004','APN0005') and pp1.IssueDate >= '2017-07-01')) then 'TIP-ZURICH'
					   when pp1.CountryKey in ('AU', 'NZ') and pp1.IssueDate >= '2009-07-01' and pp1.IssueDate < '2017-06-01' then 'GLA'
					   when pp1.CountryKey in ('AU', 'NZ') and pp1.IssueDate >= '2017-06-01' then 'ZURICH' 
					   when pp1.CountryKey in ('AU', 'NZ') and pp1.IssueDate <= '2009-06-30' then 'VERO' 
					   when pp1.CountryKey in ('UK') and pp1.IssueDate >= '2009-09-01' and pp1.IssueDate < '2017-07-01' then 'ETI' 
					   when pp1.CountryKey in ('UK') and pp1.IssueDate >= '2017-07-01' then 'ERV' 
					   when pp1.CountryKey in ('UK') and pp1.IssueDate < '2009-09-01' then 'UKU' 
					   when pp1.CountryKey in ('MY', 'SG') then 'ETIQA' 
					   when pp1.CountryKey in ('CN') then 'CCIC' 
					   when pp1.CountryKey in ('ID') then 'Simas Net' 
					   when pp1.CountryKey in ('US') then 'AON'
					   else 'OTHER' 
					end in
						(
							select
								Item
							from
								[db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Underwriter, ',')
						)
					)
            group by
                convert(datetime, convert(varchar(8), cl.CreateDate, 120) + '01'),
				uw6.Underwriter
        ) c
    where
        o.OutletStatus = 'Current' and
        o.CountryKey = @Country and
        (
            @SuperGroup = 'All' or
            o.SuperGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SuperGroup, ',')
            )
        ) and
        (
            @Group = 'All' or
            o.GroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Group, ',')
            )
        )
		and
        (
            @SubGroup = 'All' or
            o.SubGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SubGroup, ',')
            )
        )
    group by
        [Month],
		Underwriter


/*
END - Current FYTD
*/


end
GO
