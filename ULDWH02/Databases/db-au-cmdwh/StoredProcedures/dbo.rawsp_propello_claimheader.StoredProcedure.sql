USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_propello_claimheader]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rawsp_propello_claimheader]
    @DateRange varchar(30) = 'Yesterday',
    @StartDate date = null,
    @EndDate date = null,
    @Type varchar(10) = 'New'

as
begin
--20161101, LL, productionised
--20161207, LL, change outcome definition

    set nocount on

    declare
        @start date,
        @end date

    if @DateRange = '_User Defined' 
        select 
            @start = @StartDate,
            @end = @EndDate
    else
        select 
            @start = StartDate,
            @end = EndDate
        from
            vDateRange
        where
            DateRange = @DateRange

    ;with
    cte_base as
    (
        select --top 1000
            cl.ClaimKey,
            p.PolicyKey,
            p.PolicyNumber,
            p.CountryKey + '-' + p.PolicyNumber [POLICY_ID]
        from
            [db-au-cmdwh].dbo.clmClaim cl with(nolock)
            --deliberate inner join, exclude CMC and PNR as Propello needs customer data
            inner join [db-au-cmdwh].dbo.penPolicyTransSummary pt with(nolock) on
                pt.PolicyTransactionKey = cl.PolicyTransactionKey
            inner join [db-au-cmdwh].dbo.penPolicy p with(nolock) on
                p.PolicyKey = pt.PolicyKey
        where
            cl.CountryKey in ('AU','NZ') and
            p.IssueDate >= '2011-07-01' and
            (
                (
                    @Type = 'New' and
                    cl.CreateDate >= @start and
                    cl.CreateDate <  dateadd(day, 1, @end)
                ) 
                or
                (
                    @Type = 'Delta' and
                    exists
                    (
                        select
                            null
                        from
                            [db-au-cmdwh].dbo.clmAuditPayment cap with(nolock)
                        where
                            cap.ClaimKey = cl.ClaimKey and
                            cap.PaymentStatus in ('PAID', 'RECY') and
                            cap.AuditDateTime >= @start and
                            cap.AuditDateTime <  dateadd(day, 1, @end)
                    )
                )
            )
    ),
    cte_out as
    (
        select --top 100 
            cl.CountryKey [COUNTRY],
            cl.ClaimNo [CLAIM_ID],
            b.[POLICY_ID],
            ce.EventID [EVENT_ID],
            convert(varchar(10), ce.EventDate, 120) [EVENT_DATE],
            [db-au-workspace].[dbo].[fn_cleanexcel](replace(coalesce(oce.Detail, ce.EventDesc, ''), '|', ' ')) [CLAIM_DESCRIPTION],
            isnull(ce.EventCountryName, '') [CLAIM_COUNTRY],
            isnull(cn.Claimant, '') [CLAIMANT],
            case
                when cl.OnlineClaim = 1 then 'Online'
                else 'Offline'
            end [CHANNEL],
            convert(varchar(10), cl.CreateDate, 120) [CREATED_DATE],
            isnull(convert(varchar(10), wcp.CompletionDate, 120), '') [FINALISED_DATE],
            isnull(wcp.StatusName, '') [STATUS],
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
            end [OUTCOME],
            isnull(cs.FirstEstimate, 0) [CLAIM_AMOUNT],
            isnull(cs.Paid, 0) [TOTAL_PAID]
        from
            cte_base b
            inner join [db-au-cmdwh].dbo.clmClaim cl with(nolock) on
                cl.ClaimKey = b.ClaimKey
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
    )
    select
        case
            when @Type = 'New' then 'claim_header_' + replace(convert(varchar(10), getdate(), 120), '-', '') + '.txt' 
            else 'delta_claim_header_' + replace(convert(varchar(10), getdate(), 120), '-', '') + '.txt' 
        end xOutputFileNamex,
        convert(varchar(10), @start, 120) + '_' + convert(varchar(10), @end, 120) xDataIDx,
        0 xDataValuex,
        cast('COUNTRY|CLAIM_ID|POLICY_ID|EVENT_ID|EVENT_DATE|CLAIM_DESCRIPTION|CLAIM_COUNTRY|CLAIMANT|CHANNEL|CREATED_DATE|FINALISED_DATE|STATUS|OUTCOME|CLAIM_AMOUNT|TOTAL_PAID' as nvarchar(max)) Data
        
    union all

    select
        'claim_header_' + replace(convert(varchar(10), getdate(), 120), '-', '') + '.txt' xOutputFileNamex,
        convert(varchar(50), [CLAIM_ID]) xDataIDx,
        0 xDataValuex,
        cast
        (
            isnull([COUNTRY], '') + '|' +
            isnull(convert(varchar(50), [CLAIM_ID]), '') + '|' +
            isnull([POLICY_ID], '') + '|' +
            isnull(convert(varchar(50), [EVENT_ID]), '') + '|' +
            isnull([EVENT_DATE], '') + '|' +
            isnull([CLAIM_DESCRIPTION], '') + '|' +
            isnull([CLAIM_COUNTRY], '') + '|' +
            isnull([CLAIMANT], '') + '|' +
            isnull([CHANNEL], '') + '|' +
            isnull([CREATED_DATE], '') + '|' +
            isnull([FINALISED_DATE], '') + '|' +
            isnull([STATUS], '') + '|' +
            isnull([OUTCOME], '') + '|' +
            isnull(convert(varchar(50), [CLAIM_AMOUNT]), '') + '|' +
            isnull(convert(varchar(50), [TOTAL_PAID]), '') 
            as nvarchar(max)
        ) Data
    from
        cte_out

    --union all

    --select
    --    case
    --        when @Type = 'New' then 'claim_header_' + replace(convert(varchar(10), getdate(), 120), '-', '') + '.txt' 
    --        else 'delta_claim_header_' + replace(convert(varchar(10), getdate(), 120), '-', '') + '.txt' 
    --    end xOutputFileNamex,
    --    convert(varchar(10), @start, 120) + '_' + convert(varchar(10), @end, 120) xDataIDx,
    --    0 xDataValuex,
    --    cast(' ' as nvarchar(max)) Data

end
GO
