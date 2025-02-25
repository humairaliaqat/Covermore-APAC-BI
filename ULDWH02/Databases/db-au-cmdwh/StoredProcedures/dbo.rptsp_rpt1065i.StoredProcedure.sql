USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1065i]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[rptsp_rpt1065i]
AS 

begin


--/****************************************************************************************************/
----  Name				:	rptsp_rpt1065i
----  Description		:	Claims Performance Dashboard - IDR Rate
----  Author			:	Yi Yang
----  Date Created		:	20190705
----  Parameters		:	
----  Change History	:	
--/****************************************************************************************************/




set nocount on


--uncomment to debug
declare
    @Country nvarchar(5),
    @SuperGroup nvarchar(4000),
    @Group nvarchar(4000),
	  @SubGroup nvarchar(4000),
	  @Underwriter nvarchar(4000),
    @ReportingPeriod varchar(30),
    @StartDate date,
    @EndDate date
select
    @Country = 'AU',
    @SuperGroup = 'All',
    @Group = 'All',
	  @SubGroup = 'All',
	  @Underwriter = 'All',
    @ReportingPeriod = 'Last 12 Months',
    @StartDate = '2016-01-01',
    @EndDate = '2016-02-10'


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

--select
--    aa.*,
--    @FYsd as [CYTD Start Date],
--    @FYed as [CYTD End Date]
--from
--(--aa
--    /*
--    BEGIN - Current Period
--    */
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
        convert(date, w.CompletionDate) as CompletionDate,
        isnull(
            [Time in current status],
            datediff(day, w.CreationDate, w.CompletionDate) + 1 -
            (
                select
                    count(d.[Date])
                from
                    Calendar d with(nolock)
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
        e5Work w with(nolock)
        outer apply
        (
            select top 1
                Work_ID ParentID
            from
                e5Work p with(nolock)
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
                e5WorkActivity wa with(nolock)
                inner join e5WorkItems wi with(nolock) on
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
                vClaimPortfolio cpf with(nolock)
            where
                cpf.[e5 Reference] = w.Reference and
                w.StatusName in ('Active', 'Diarised')
        ) cpf
        outer apply
        (
            select top 1
                wi.Name IDROutcome
            from
                e5WorkActivity wa with(nolock)
                inner join e5WorkActivityProperties wap with(nolock) on
                    wap.Work_ID = wa.Work_ID and
                    wap.WorkActivity_ID = wa.ID
                inner join e5WorkItems wi with(nolock) on
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
                clmClaim cl with(nolock)
                outer apply
                (
                    select
                        sum(isnull(cs.EstimateValue, 0)) CurrentEstimate,
                        sum(isnull(cp.Paid, 0)) CurrentPaid
                    from
                        clmSection cs with(nolock)
                        outer apply
                        (
                            select
                                sum(isnull(PaymentAmount, 0)) Paid
                            from
                                clmPayment cp with(nolock)
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
                e5WorkProperties wp with(nolock)
                left join e5WorkItems wi with(nolock) on
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
                penPolicyTransSummary pt with(nolock)
				inner join penPolicy pp with(nolock)
					on pt.PolicyKey = pp.PolicyKey
                inner join penOutlet o with(nolock) on
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
        ) and
        (
            @SubGroup = 'All' or
            o.SubGroupName in
            (
                select
                    Item
                from
                    dbo.fn_DelimitedSplit8K(@SubGroup, ',')
            )
        ) and
        (
            @Underwriter = 'All' or
            o.Underwriter in
            (
                select
                    Item
                from
                    dbo.fn_DelimitedSplit8K(@Underwriter, ',')
            )
        )
    --order by
    --    w.GroupType

/*
END - Current Period
*/
end
GO
