USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0497]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0497] @DateRange varchar(30),
									  @StartDate datetime,
									  @EndDate datetime					
as

SET NOCOUNT ON

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0497
--  Author:         Linus Tor
--  Date Created:   20170118
--  Description:    This stored procedure returns IAL finalised claims and respective outcomes
--					Based on rawsp_propello_claimheader stored proc.
--  Parameters:     @Country: valid country code (AU, NZ etc..)
--                  @SuperGroup: valid super group
--					@DateRange: standard date range or _User Defined.
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--   
--  Change History: 20170108 - LT - Created
--
/****************************************************************************************************/



--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate datetime
declare @EndDate datetime
select @DateRange = 'Last Month', @StartDate = null, @EndDate = null
*/

declare
    @rptStartDate date,
    @rptEndDate date

if @DateRange = '_User Defined' 
    select 
        @rptStartDate = @StartDate,
        @rptEndDate = @EndDate
else
    select 
        @rptStartDate = StartDate,
        @rptEndDate = EndDate
    from
        vDateRange
    where
        DateRange = @DateRange

select
    cl.CountryKey as Country,
	o.SuperGroupName as SuperGroupName,
	o.GroupName as GroupName,
	o.SubGroupName as SubGroupName,
	o.AlphaCode as AgencyCode,
	o.OutletName as AgencyName,
    cl.ClaimNo as ClaimNumber,
	cl.ReceivedDate,
    ce.EventID,
    convert(varchar(10), ce.EventDate, 120) as EventDate,
    [db-au-workspace].[dbo].[fn_cleanexcel](replace(coalesce(oce.Detail, ce.EventDesc, ''), '|', ' ')) as EventDescription,
    isnull(ce.EventCountryName, '') as EventCountry,
	ce.PerilDesc as Peril,
	p.PolicyNumber,
	p.ProductCode,
	cl.PolicyPlanCode as PlanCode,
	p.AreaType,
	p.IssueDate,
	p.DepartureDate,
	p.ReturnDate,
	p.TripDuration,
	p.Consultant,
    convert(varchar(10), cl.CreateDate, 120) as CreateDate,
    isnull(convert(varchar(10), wcp.CompletionDate, 120), '') as FinalisedDate,
	fpay.FirstPaymentDate as ApprovedDate,
    isnull(wcp.StatusName, '') as Status,
    case
        when idr.IDRStatus in ('Active', 'Diarised') then 'Under Review'
        when inv.InvestigationStatus in ('Active', 'Diarised') then 'Under Review'
        when idr.IDRStatus = 'Complete' and isnull(idr.IDROutcome, '') <> '' then idr.IDROutcome
        when inv.InvestigationStatus = 'Complete' and inv.InvestigationOutcome like '%fraud%' then 'Fraud detected'
        when inv.InvestigationStatus = 'Complete' and inv.InvestigationOutcome like '%withdrawn%' then 'Claim withdrawn'
        when e5.AssessmentOutcome = 'Under Excess' and isnull(FPPayments, 0) = 0 then 'Under Excess'
        when isnull(FPPayments, 0) > 0 then 'Approved'
        when e5.AssessmentOutcome = 'Deny' and isnull(FPPayments, 0) = 0 then 'Denied'
        when e5.AssessmentOutcome = 'Approve' and isnull(FPPayments, 0) = 0 and isnull(TPPayments, 0) = 0 then 'Denied'
        when e5.AssessmentOutcome = 'Approve' then 'Approved'
        when e5.AssessmentOutcome = 'No action required' and isnull(FPPayments, 0) + isnull(TPPayments, 0) > 0 then 'Approved'
        when e5.AssessmentOutcome = 'No action required' and isnull(FPPayments, 0) = 0 and isnull(TPPayments, 0) = 0 then 'Denied'
        when e5.CaseStatus = 'Complete' and isnull(FPPayments, 0) + isnull(TPPayments, 0) > 0 then 'Approved'
        when e5.CaseStatus = 'Complete' and isnull(FPPayments, 0) = 0 and isnull(TPPayments, 0) = 0 then 'Denied'
        when e5.CaseStatus in ('Active', 'Diarised') then 'Pending'
        when e5.CaseStatus = 'Rejected' then 'Merged to other claim'
        when e5.AssessmentOutcome is null and isnull(FPPayments, 0) = 0 and isnull(TPPayments, 0) = 0 then 'No assessment'
        when e5.CaseID is null then 'No assessment'
    end as Outcome,
    isnull(cs.FirstEstimate, 0) as ClaimAmount,
    isnull(cs.Paid, 0) as TotalPaid,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate
from
	dbo.clmClaim cl
	inner join dbo.penOutlet o on 
		cl.OutletKey = o.OutletKey and 
		o.OutletStatus = 'Current'
	outer apply
	(
		select top 1 pp.PolicyNumber, pp.ProductCode, pp.AreaType, pp.IssueDate, pp.TripStart as DepartureDate, pp.TripEnd as ReturnDate, pp.TripDuration, u.FirstName + ' ' + u.LastName as Consultant
		from
			dbo.penPolicy pp
			inner join penPolicyTransSummary pts on pp.PolicyKey = pts.PolicyKey
			inner join penUser u on pts.UserKey = u.UserKey and u.UserStatus = 'Current'
		where
			pts.PolicyTransactionKey = cl.PolicyTransactionKey
	) p
	outer apply
	(
		select top 1 FirstPayment as FirstPaymentDate
		from clmClaimSummary
		where ClaimKey = cl.ClaimKey
	) fpay
    outer apply
    (
        select top 1 
            w.StatusName,
            w.CompletionDate
        from
            [db-au-cmdwh].dbo.e5Work w with(nolock)
        where
            w.ClaimKey = cl.ClaimKey and
            w.WorkType like '%claim%' and
            w.WorkType not like '%audit%'
        order by
            isnull(w.CompletionDate, getdate()) desc
    ) wcp
    inner join [db-au-cmdwh].dbo.clmevent ce with(nolock) on
        ce.ClaimKey = cl.ClaimKey
    outer apply
    (
        select top 1 
            oce.Detail
        from
            [db-au-cmdwh].dbo.clmOnlineClaimEvent oce with(nolock)
        where
            oce.ClaimKey = cl.ClaimKey
    ) oce
    outer apply
    (
        select top 1 
            cn.Firstname + ' ' + cn.Surname Claimant
        from
            [db-au-cmdwh].dbo.clmName cn with(nolock)
        where
            cn.ClaimKey = cl.ClaimKey and
            cn.isPrimary = 1
    ) cn
    outer apply
    (
        select 
            sum(isnull(FirstEstimate, 0)) FirstEstimate,
            sum(isnull(Paid, 0)) Paid
        from
            [db-au-cmdwh].dbo.clmSection cs with(nolock)
            outer apply
            (
                select
                    case
                        when csi.IncurredTime = min(csi.IncurredTime) over (partition by csi.SectionKey) then EstimateDelta
                        else 0
                    end FirstEstimate,
                    csi.PaymentDelta Paid
                from
                    [db-au-cmdwh].dbo.vclmClaimSectionIncurredIntraDay csi with(nolock)
                where
                    csi.SectionKey = cs.SectionKey
            ) csi
        where
            cs.ClaimKey = cl.ClaimKey and
            cs.EventKey = ce.EventKey
    ) cs
    outer apply
    (
        select top 1 
            w.Work_ID CaseID,
            w.Reference CaseReference,
            w.StatusName CaseStatus,
            AssessmentOutcome
        from
            e5Work w
            outer apply
            (
                select top 1
                    wa.AssessmentOutcomeDescription AssessmentOutcome
                from
                    e5WorkActivity wa
                where
                    wa.Work_ID = w.Work_ID and
                    wa.CategoryActivityName = 'Assessment Outcome' and
                    wa.CompletionDate is not null
                order by
                    wa.CompletionDate desc
            ) wa
        where
            w.ClaimKey = cl.ClaimKey and
            w.WorkType = 'Claim'
        order by
            w.CreationDate desc
    ) e5
    outer apply
    (
        select top 1
            w.StatusName IDRStatus,
            w.Reference IDRReference,
            w.Work_ID IDRID,
            wa.Name IDROutcome
        from
            e5Work w
            outer apply
            (
                select top 1
                    wi.Name
                from
                    e5WorkActivity wa
                    inner join e5WorkActivityProperties wap on
                        wap.WorkActivity_ID = wa.ID and
                        wap.Property_ID = 'IDROutcome'
                    inner join e5WorkItems wi on
                        wi.ID = wap.PropertyValue
                where
                    wa.Work_ID = w.Work_ID and
                    wa.CategoryActivityName = 'IDR Outcome' and
                    wa.CompletionDate is not null
                order by
                    wa.CompletionDate desc
            ) wa
        where
            w.ClaimKey = cl.ClaimKey and
            WorkType = 'Complaints' and
            GroupType = 'IDR'
        order by
            CreationDate desc
    ) idr
    outer apply
    (
        select top 1
            w.StatusName InvestigationStatus,
            w.Reference InvestigationReference,
            w.Work_ID InvestigationID,
            wa.Name InvestigationOutcome
        from
            e5Work w
            outer apply
            (
                select top 1
                    wi.Name
                from
                    e5WorkActivity wa
                    inner join e5WorkActivityProperties wap on
                        wap.WorkActivity_ID = wa.ID and
                        wap.Property_ID = 'InvestigationOutcome'
                    inner join e5WorkItems wi on
                        wi.ID = wap.PropertyValue
                where
                    wa.Work_ID = w.Work_ID and
                    wa.CategoryActivityName = 'Investigation Outcome' and
                    wa.CompletionDate is not null
                order by
                    wa.CompletionDate desc
            ) wa
        where
            w.ClaimKey = cl.ClaimKey and
            WorkType = 'Investigation'
        order by
            CreationDate desc
    ) inv
    outer apply
    (
        select 
            sum
            (
                case
                    when isnull(cn.isThirdParty, 0) = 0 then cp.PaymentAmount
                    else 0
                end 
            ) FPPayments,
            sum
            (
                case
                    when isnull(cn.isThirdParty, 0) = 1 then cp.PaymentAmount
                    else 0
                end 
            ) TPPayments
        from
            clmPayment cp
            inner join clmName cn on
                cn.NameKey = cp.PayeeKey
        where
            cp.ClaimKey = cl.ClaimKey and
            cp.PaymentStatus in ('APPR', 'PAID')
    ) cp
where
	cl.CountryKey = 'AU' and
	o.SuperGroupName = 'IAL' and
	wcp.CompletionDate >= @rptStartDate and
	wcp.CompletionDate < dateadd(d,1,@rptEndDate)
GO
