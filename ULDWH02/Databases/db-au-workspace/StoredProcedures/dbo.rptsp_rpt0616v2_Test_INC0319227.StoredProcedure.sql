USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0616v2_Test_INC0319227]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0616v2_Test_INC0319227]
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
--  Name:          rptsp_rpt0616
--  Author:        Leonardus Setyabudi
--  Date Created:  ???
--  Description:   This stored procedure extract Complain, IDR, Claim and Policy data
--
--                    20150310, LS, F23493, add supergroup & group
--                    20150408, LS, F23845, add additional info
--                    20150701, LS, T16626, change date, include received & completed
--                    20150702, LS, T16626, add EDR
--                    20150709, LS, F25324, enable csv on supergroup & group
--                    20160211, PZ, TFS22114, add "Same Period Last Year" data and new dimension "Period" 
--									for Year on Year comparison
--                    20160304, PZ, TFS22114, add "Current FYTD" data, add 2 new columns for YTD start and end date
--                    20160311, PZ, TFS22114, add new prompt of "Country"
--					  20161011, PZ, TFS27751, add subgroupname as stored proc parameter	and in the output
--					  20170717, SD, INC0039837, add Underwriter as Stored Procedure parameter and in the output
--					  20171101, LT, Updated UW definition for ETI and ERV
/****************************************************************************************************/



--uncomment to debug
--declare
--    @Country nvarchar(5),
--    @SuperGroup nvarchar(4000),
--    @Group nvarchar(4000),
--	  @SubGroup nvarchar(4000),
--	  @Underwriter nvarchar(4000),
--    @ReportingPeriod varchar(30),
--    @StartDate date,
--    @EndDate date
--select
--    @Country = 'AU',
--    @SuperGroup = 'All',
--    @Group = 'All',
--	  @SubGroup = 'All',
--	  @Underwriter = 'All',
--    @ReportingPeriod = 'Current Month',
--    @StartDate = '2016-01-01',
--    @EndDate = '2016-02-10'


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

-------------------------------------------------------

select
    aa.*,
    @FYsd as [CYTD Start Date],
    @FYed as [CYTD End Date]
from
(--aa
    /*
    BEGIN - Current Period
    */
    select
        w.GroupType,
        w.Reference,
        w.ClaimNumber,
        isnull(w.PolicyNumber, isnull(wp.ComplaintsPolicyNumber, '')) as PolicyNumber,
        o.SuperGroupName,
        o.GroupName,
		o.SubGroupName,
		o.Underwriter,
        w.CreationDate,
        w.CompletionDate,
        isnull(
            [Time in current status],
            datediff(day, w.CreationDate, w.CompletionDate) + 1 -
            (
                select
                    count(d.[Date])
                from
                    [db-au-cmdwh].dbo.Calendar d with(nolock)
                where
                    d.[Date] >= convert(date, w.CreationDate) and
                    d.[Date] <  dateadd(day, 1, convert(date, w.CompletionDate)) and
                    (
                        d.isHoliday = 1 or
                        d.isWeekEnd = 1
                    )
            )
        ) as Age,
        w.CreationUser,
        isnull(CurrentEstimate, 0) as CurrentEstimate,
        isnull(CurrentPaid, 0) as CurrentPaid,
        isnull(wp.ReasonForComplaint, '') as ReasonForComplaint,
        isnull(wp.PolicyExclusion, '') as PolicyExclusion,
        wp.ComplaintDateLodged,
        isnull(wp.ReasonForDispute, '') as ReasonForDispute,
        @rptStartDate as rptStartDate,
        @rptEndDate as rptEndDate,
        LastAssessmentOutcome as ClaimDecision,
        w.StatusName,
        IDROutcome,
        case
            when isnull(EDRReferral, 0) = 0 then 'No'
            else 'Yes'
        end as EDRReferral,
        'Current' as [Period]
    from
        [db-au-cmdwh].dbo.e5Work w with(nolock)
        outer apply
        (
            select top 1
                Work_ID ParentID
            from
                [db-au-cmdwh].dbo.e5Work p with(nolock)
            where
                p.ClaimKey = w.ClaimKey and
                (
                    p.WorkType like '%claim%'
                )
        ) parent
        outer apply
        (
            select top 1
                wi.Name LastAssessmentOutcome
            from
                [db-au-cmdwh].dbo.e5WorkActivity wa with(nolock)
                inner join [db-au-cmdwh].dbo.e5WorkItems wi with(nolock) on
                    wi.ID = wa.AssessmentOutcome
            where
                wa.Work_ID = parent.ParentID and
                wa.CategoryActivityName = 'Assessment Outcome'
            order by
                wa.CompletionDate desc
        ) pla
        outer apply
        (
            select top 1
                cpf.[Time in current status]
            from
                [db-au-cmdwh].dbo.vClaimPortfolio cpf with(nolock)
            where
                cpf.[e5 Reference] = w.Reference and
                w.StatusName in ('Active', 'Diarised')
        ) cpf
        outer apply
        (
            select top 1
                wi.Name IDROutcome
            from
                [db-au-cmdwh].dbo.e5WorkActivity wa with(nolock)
                inner join [db-au-cmdwh].dbo.e5WorkActivityProperties wap with(nolock) on
                    wap.Work_ID = wa.Work_ID and
                    wap.WorkActivity_ID = wa.ID
                inner join [db-au-cmdwh].dbo.e5WorkItems wi with(nolock) on
                    wi.ID = wap.PropertyValue
            where
                wa.Work_ID = w.Work_ID and
                wa.CategoryActivityName = 'IDR Outcome'
            order by
                wa.CompletionDate desc
        ) idro
        outer apply
        (
            select top 1
                CurrentEstimate,
                CurrentPaid
            from
                [db-au-cmdwh].dbo.clmClaim cl with(nolock)
                outer apply
                (
                    select
                        sum(isnull(cs.EstimateValue, 0)) CurrentEstimate,
                        sum(isnull(cp.Paid, 0)) CurrentPaid
                    from
                        [db-au-cmdwh].dbo.clmSection cs with(nolock)
                        outer apply
                        (
                            select
                                sum(isnull(PaymentAmount, 0)) Paid
                            from
                                [db-au-cmdwh].dbo.clmPayment cp with(nolock)
                            where
                                cp.SectionKey = cs.SectionKey and
                                cp.isDeleted = 0 and
                                cp.PaymentStatus = 'PAID'
                        ) cp
                    where
                        cs.isDeleted = 0 and
                        cs.ClaimKey = cl.ClaimKey
                ) cs
            where
                cl.ClaimKey = w.ClaimKey
        ) cl
        outer apply
        (
            select
                max(
                    case
                        when wp.Property_ID = 'ComplaintsPolicyNumber' then convert(nvarchar(50), wp.PropertyValue)
                        else ''
                    end
                ) ComplaintsPolicyNumber,
                max(
                    case
                        when wp.Property_ID = 'ReasonForComplaint' then wi.Name
                        else ''
                    end
                ) ReasonForComplaint,
                max(
                    case
                        when wp.Property_ID = 'PolicyExclusionifapplicable' then wi.Name
                        else ''
                    end
                ) PolicyExclusion,
                max(
                    case
                        when wp.Property_ID = 'ReasonforDispute' then wi.Name
                        else ''
                    end
                ) ReasonForDispute,
                max(
                    case
                        when wp.Property_ID = 'ComplaintDateLodged' then convert(datetime, PropertyValue)
                        else null
                    end
                ) ComplaintDateLodged,
                max(
                    case
                        when wp.Property_ID = 'EDRReferral' then convert(varchar, PropertyValue)
                        else null
                    end
                ) EDRReferral
            from
                [db-au-cmdwh].dbo.e5WorkProperties wp with(nolock)
                left join [db-au-cmdwh].dbo.e5WorkItems wi with(nolock) on
                    wi.ID = wp.PropertyValue
            where
                wp.Work_ID = w.Work_ID and
                wp.Property_ID in
                (
                    'ReasonForComplaint',
                    'PolicyExclusionifapplicable',
                    'ReasonforDispute',
                    'ComplaintDateLodged',
                    'ComplaintsPolicyNumber',
                    'EDRReferral'
                )
        ) wp
        outer apply
        (
            select top 1
                o.SuperGroupName,
                o.GroupName,
				o.SubGroupName,
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
				end [Underwriter]
            from
                [db-au-cmdwh].dbo.penPolicyTransSummary pt with(nolock)
				inner join [db-au-cmdwh].dbo.penPolicy pp with(nolock)
					on pt.PolicyKey = pp.PolicyKey
                inner join [db-au-cmdwh].dbo.penOutlet o with(nolock) on
                    o.OutletAlphaKey = pt.OutletAlphaKey and
                    o.OutletStatus = 'Current'
            where
                o.CountryKey = @Country and
                pt.PolicyNumber = isnull(w.PolicyNumber, wp.ComplaintsPolicyNumber)
        ) o
    where
        isnull(w.Country, 'AU') = @Country and
        w.WorkType = 'Complaints' and
        w.GroupType in ('NEW', 'IDR') and
        (
            (
                w.CreationDate >= @rptStartDate and
                w.CreationDate < dateadd(day, 1, @rptEndDate)
            ) or
            (
                w.CompletionDate >= @rptStartDate and
                w.CompletionDate < dateadd(day, 1, @rptEndDate)
            )
        ) and
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
        ) and
        (
            @SubGroup = 'All' or
            o.SubGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SubGroup, ',')
            )
        ) and
        (
            @Underwriter = 'All' or
            o.Underwriter in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Underwriter, ',')
            )
        )
    --order by
    --    w.GroupType

/*
END - Current Period
*/

union all


/*
BEGIN - Previous Period
*/

    select
        w.GroupType,
        w.Reference,
        w.ClaimNumber,
        isnull(w.PolicyNumber, isnull(wp.ComplaintsPolicyNumber, '')) as PolicyNumber,
        o.SuperGroupName,
        o.GroupName,
		o.Subgroupname,
		o.Underwriter,
        w.CreationDate,
        w.CompletionDate,
        isnull(
            [Time in current status],

            datediff(day, w.CreationDate, w.CompletionDate) + 1 -
            (
                select
                    count(d.[Date])
                from
                    [db-au-cmdwh].dbo.Calendar d with(nolock)
                where
                    d.[Date] >= convert(date, w.CreationDate) and
                    d.[Date] <  dateadd(day, 1, convert(date, w.CompletionDate)) and
                    (
                        d.isHoliday = 1 or
                        d.isWeekEnd = 1
                    )
            )
        ) as Age,
        w.CreationUser,
        isnull(CurrentEstimate, 0) as CurrentEstimate,
        isnull(CurrentPaid, 0) as CurrentPaid,
        isnull(wp.ReasonForComplaint, '') as ReasonForComplaint,
        isnull(wp.PolicyExclusion, '') as PolicyExclusion,
        wp.ComplaintDateLodged,
        isnull(wp.ReasonForDispute, '') as ReasonForDispute,
        @rptStartDate_LY as rptStartDate,
        @rptEndDate_LY as rptEndDate,
        LastAssessmentOutcome as ClaimDecision,
        w.StatusName,
        IDROutcome,
        case
            when isnull(EDRReferral, 0) = 0 then 'No'
            else 'Yes'
        end as EDRReferral,
        'Previous' as [Period]
    from
        [db-au-cmdwh].dbo.e5Work w with(nolock)
        outer apply
        (
            select top 1
                Work_ID ParentID
            from
                [db-au-cmdwh].dbo.e5Work p with(nolock)
            where
                p.ClaimKey = w.ClaimKey and
                (
                    p.WorkType like '%claim%'
                )
        ) parent
        outer apply
        (
            select top 1
                wi.Name LastAssessmentOutcome
            from
                [db-au-cmdwh].dbo.e5WorkActivity wa with(nolock)
                inner join [db-au-cmdwh].dbo.e5WorkItems wi with(nolock) on
                    wi.ID = wa.AssessmentOutcome
            where
                wa.Work_ID = parent.ParentID and
                wa.CategoryActivityName = 'Assessment Outcome'
            order by
                wa.CompletionDate desc
        ) pla
        outer apply
        (
            select top 1
                cpf.[Time in current status]
            from
                [db-au-cmdwh].dbo.vClaimPortfolio cpf with(nolock)
            where
                cpf.[e5 Reference] = w.Reference and
                w.StatusName in ('Active', 'Diarised')
        ) cpf
        outer apply
        (
            select top 1
                wi.Name IDROutcome
            from
                [db-au-cmdwh].dbo.e5WorkActivity wa with(nolock)
                inner join [db-au-cmdwh].dbo.e5WorkActivityProperties wap with(nolock) on
                    wap.Work_ID = wa.Work_ID and
                    wap.WorkActivity_ID = wa.ID
                inner join [db-au-cmdwh].dbo.e5WorkItems wi with(nolock) on
                    wi.ID = wap.PropertyValue
            where
                wa.Work_ID = w.Work_ID and
                wa.CategoryActivityName = 'IDR Outcome'
            order by
                wa.CompletionDate desc
        ) idro
        outer apply
        (
            select top 1
                CurrentEstimate,
                CurrentPaid
            from
                [db-au-cmdwh].dbo.clmClaim cl with(nolock)
                outer apply
                (
                    select
                        sum(isnull(cs.EstimateValue, 0)) CurrentEstimate,
                        sum(isnull(cp.Paid, 0)) CurrentPaid
                    from
                        [db-au-cmdwh].dbo.clmSection cs with(nolock)
                        outer apply
                        (
                            select
                                sum(isnull(PaymentAmount, 0)) Paid
                            from
                                [db-au-cmdwh].dbo.clmPayment cp with(nolock)
                            where
                                cp.SectionKey = cs.SectionKey and
                                cp.isDeleted = 0 and
                                cp.PaymentStatus = 'PAID'
                        ) cp
                    where
                        cs.isDeleted = 0 and
                        cs.ClaimKey = cl.ClaimKey
                ) cs
            where
                cl.ClaimKey = w.ClaimKey
        ) cl
        outer apply
        (
            select
                max(
                    case
                        when wp.Property_ID = 'ComplaintsPolicyNumber' then convert(nvarchar(50), wp.PropertyValue)
                        else ''
                    end
                ) ComplaintsPolicyNumber,
                max(
                    case
                        when wp.Property_ID = 'ReasonForComplaint' then wi.Name
                        else ''
                    end
                ) ReasonForComplaint,
                max(
                    case
                        when wp.Property_ID = 'PolicyExclusionifapplicable' then wi.Name
                        else ''
                    end
                ) PolicyExclusion,
                max(
                    case
                        when wp.Property_ID = 'ReasonforDispute' then wi.Name
                        else ''
                    end
                ) ReasonForDispute,
                max(
                    case
                        when wp.Property_ID = 'ComplaintDateLodged' then convert(datetime, PropertyValue)
                        else null
                    end
                ) ComplaintDateLodged,
                max(
                    case
                        when wp.Property_ID = 'EDRReferral' then convert(varchar, PropertyValue)
                        else null
                    end
                ) EDRReferral
            from
                [db-au-cmdwh].dbo.e5WorkProperties wp with(nolock)
                left join [db-au-cmdwh].dbo.e5WorkItems wi with(nolock) on
                    wi.ID = wp.PropertyValue
            where
                wp.Work_ID = w.Work_ID and
                wp.Property_ID in
                (
                    'ReasonForComplaint',
                    'PolicyExclusionifapplicable',
                    'ReasonforDispute',
                    'ComplaintDateLodged',
                    'ComplaintsPolicyNumber',
                    'EDRReferral'
                )
        ) wp
        outer apply
        (
            select top 1
                o.SuperGroupName,
                o.GroupName,
				o.SubGroupName,
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
				end [Underwriter]
            from
                [db-au-cmdwh].dbo.penPolicyTransSummary pt with(nolock)
				inner join [db-au-cmdwh].dbo.penPolicy pp with(nolock)
					on pt.PolicyKey = pp.PolicyKey
                inner join [db-au-cmdwh].dbo.penOutlet o with(nolock) on
                    o.OutletAlphaKey = pt.OutletAlphaKey and
                    o.OutletStatus = 'Current'
            where
                o.CountryKey = @Country and
                pt.PolicyNumber = isnull(w.PolicyNumber, wp.ComplaintsPolicyNumber)
        ) o
    where
        isnull(w.Country, 'AU') = @Country and
        w.WorkType = 'Complaints' and
        w.GroupType in ('NEW', 'IDR') and
        (
            (
                w.CreationDate >= @rptStartDate_LY and
                w.CreationDate < dateadd(day, 1, @rptEndDate_LY)
            ) or
            (
                w.CompletionDate >= @rptStartDate_LY and
                w.CompletionDate < dateadd(day, 1, @rptEndDate_LY)
            )
        ) 
		
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
        ) and
        (
            @Underwriter = 'All' or
            o.Underwriter in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Underwriter, ',')
            )
        )





/*
END - Previous Period
*/


union all


/*
BEGIN - Current YTD
*/

    select
        w.GroupType,
        w.Reference,
        w.ClaimNumber,
        isnull(w.PolicyNumber, isnull(wp.ComplaintsPolicyNumber, '')) as PolicyNumber,
        o.SuperGroupName,
        o.GroupName,
		o.SubGroupName,
		o.Underwriter,
        w.CreationDate,
        w.CompletionDate,
        isnull(
            [Time in current status],
            datediff(day, w.CreationDate, w.CompletionDate) + 1 -
            (
                select
                    count(d.[Date])
                from
                    [db-au-cmdwh].dbo.Calendar d with(nolock)
                where
                    d.[Date] >= convert(date, w.CreationDate) and
                    d.[Date] <  dateadd(day, 1, convert(date, w.CompletionDate)) and
                    (
                        d.isHoliday = 1 or
                        d.isWeekEnd = 1
                    )
            )
        ) as Age,
        w.CreationUser,
        isnull(CurrentEstimate, 0) as CurrentEstimate,
        isnull(CurrentPaid, 0) as CurrentPaid,
        isnull(wp.ReasonForComplaint, '') as ReasonForComplaint,
        isnull(wp.PolicyExclusion, '') as PolicyExclusion,
        wp.ComplaintDateLodged,
        isnull(wp.ReasonForDispute, '') as ReasonForDispute,
        @rptStartDate as rptStartDate,
        @rptEndDate as rptEndDate,
        LastAssessmentOutcome as ClaimDecision,
        w.StatusName,
        IDROutcome,
        case
            when isnull(EDRReferral, 0) = 0 then 'No'
            else 'Yes'
        end as EDRReferral,
        'Current FYTD' as [Period]
    from
        [db-au-cmdwh].dbo.e5Work w with(nolock)
        outer apply
        (
            select top 1
                Work_ID ParentID
            from
                [db-au-cmdwh].dbo.e5Work p with(nolock)
            where
                p.ClaimKey = w.ClaimKey and
                (
                    p.WorkType like '%claim%'
                )
        ) parent
        outer apply
        (
            select top 1
                wi.Name LastAssessmentOutcome
            from
                [db-au-cmdwh].dbo.e5WorkActivity wa with(nolock)
                inner join [db-au-cmdwh].dbo.e5WorkItems wi with(nolock) on
                    wi.ID = wa.AssessmentOutcome
            where
                wa.Work_ID = parent.ParentID and
                wa.CategoryActivityName = 'Assessment Outcome'
            order by
                wa.CompletionDate desc
        ) pla
        outer apply
        (
            select top 1
                cpf.[Time in current status]
            from
                [db-au-cmdwh].dbo.vClaimPortfolio cpf with(nolock)
            where
                cpf.[e5 Reference] = w.Reference and
                w.StatusName in ('Active', 'Diarised')
        ) cpf
        outer apply
        (
            select top 1
                wi.Name IDROutcome
            from
                [db-au-cmdwh].dbo.e5WorkActivity wa with(nolock)
                inner join [db-au-cmdwh].dbo.e5WorkActivityProperties wap with(nolock) on
                    wap.Work_ID = wa.Work_ID and
                    wap.WorkActivity_ID = wa.ID
                inner join [db-au-cmdwh].dbo.e5WorkItems wi with(nolock) on
                    wi.ID = wap.PropertyValue
            where
                wa.Work_ID = w.Work_ID and
                wa.CategoryActivityName = 'IDR Outcome'
            order by
                wa.CompletionDate desc
        ) idro
        outer apply
        (
            select top 1
                CurrentEstimate,
                CurrentPaid
            from
                [db-au-cmdwh].dbo.clmClaim cl with(nolock)
                outer apply
                (
                    select
                        sum(isnull(cs.EstimateValue, 0)) CurrentEstimate,
                        sum(isnull(cp.Paid, 0)) CurrentPaid
                    from
                        [db-au-cmdwh].dbo.clmSection cs with(nolock)
                        outer apply
                        (
                            select
                                sum(isnull(PaymentAmount, 0)) Paid
                            from
                                [db-au-cmdwh].dbo.clmPayment cp with(nolock)
                            where
                                cp.SectionKey = cs.SectionKey and
                                cp.isDeleted = 0 and
                                cp.PaymentStatus = 'PAID'
                        ) cp
                    where
                        cs.isDeleted = 0 and
                        cs.ClaimKey = cl.ClaimKey
                ) cs
            where
                cl.ClaimKey = w.ClaimKey
        ) cl
        outer apply
        (
            select
                max(
                    case
                        when wp.Property_ID = 'ComplaintsPolicyNumber' then convert(nvarchar(50), wp.PropertyValue)
                        else ''
                    end
                ) ComplaintsPolicyNumber,
                max(
                    case
                        when wp.Property_ID = 'ReasonForComplaint' then wi.Name
                        else ''
                    end
                ) ReasonForComplaint,
                max(
                    case
                        when wp.Property_ID = 'PolicyExclusionifapplicable' then wi.Name
                        else ''
                    end
                ) PolicyExclusion,
                max(
                    case
                        when wp.Property_ID = 'ReasonforDispute' then wi.Name
                        else ''
                    end
                ) ReasonForDispute,
                max(
                    case
                        when wp.Property_ID = 'ComplaintDateLodged' then convert(datetime, PropertyValue)
                        else null
                    end
                ) ComplaintDateLodged,
                max(
                    case
                        when wp.Property_ID = 'EDRReferral' then convert(varchar, PropertyValue)
                        else null
                    end
                ) EDRReferral
            from
                [db-au-cmdwh].dbo.e5WorkProperties wp with(nolock)
                left join [db-au-cmdwh].dbo.e5WorkItems wi with(nolock) on
                    wi.ID = wp.PropertyValue
            where
                wp.Work_ID = w.Work_ID and
                wp.Property_ID in
                (
                    'ReasonForComplaint',
                    'PolicyExclusionifapplicable',
                    'ReasonforDispute',
                    'ComplaintDateLodged',
                    'ComplaintsPolicyNumber',
                    'EDRReferral'
                )
        ) wp
        outer apply
        (
            select top 1
                o.SuperGroupName,
                o.GroupName,
				o.SubGroupName,
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
				end [Underwriter]
            from
                [db-au-cmdwh].dbo.penPolicyTransSummary pt with(nolock)
				inner join [db-au-cmdwh].dbo.penPolicy pp
					on pt.PolicyKey = pp.PolicyKey
                inner join [db-au-cmdwh].dbo.penOutlet o with(nolock) on
                    o.OutletAlphaKey = pt.OutletAlphaKey and
                    o.OutletStatus = 'Current'
            where
                o.CountryKey = @Country and
                pt.PolicyNumber = isnull(w.PolicyNumber, wp.ComplaintsPolicyNumber)
        ) o
    where
        isnull(w.Country, 'AU') = @Country and
        w.WorkType = 'Complaints' and
        w.GroupType in ('NEW', 'IDR') and
        (
            (
                w.CreationDate >= @FYsd and
                w.CreationDate < dateadd(day, 1, @FYed)
            ) or
            (
                w.CompletionDate >= @FYsd and
                w.CompletionDate < dateadd(day, 1, @FYed)
            )
        ) and
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
        ) and
        (
            @SubGroup = 'All' or
            o.SubGroupName in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SubGroup, ',')
            )
        ) and
        (
            @Underwriter = 'All' or
            o.Underwriter in
            (
                select
                    Item
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Underwriter, ',')
            )
        )

/*
END - Current YTD
*/

)as aa

end
GO
