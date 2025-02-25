USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vClaimAssessmentOutcome_counttest]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE  view [dbo].[vClaimAssessmentOutcome_counttest] as

with cte as (

select
   cl.ClaimKey,

    case
       when idr.IDRStatus in ('Active', 'Diarised') then 'Under Review'
        when inv.InvestigationStatus in ('Active', 'Diarised') then 'Under Review'
        when idr.IDRStatus = 'Complete' and isnull(idr.IDROutcome, '') <> '' then idr.IDROutcome
        when inv.InvestigationStatus = 'Complete' and inv.InvestigationOutcome like '%fraud%' then 'Fraud detected' 
        when inv.InvestigationStatus = 'Complete' and inv.InvestigationOutcome like '%withdrawn%' 
		or e5.AssessmentOutcome = 'Claim Withdrawn' then 'Claim Withdrawn'
        when e5.AssessmentOutcome = 'Under Excess' and isnull(FPPayments, 0) = 0 then 'Under Excess'
        when isnull(FPPayments, 0) > 0 then 'Approved'
        when e5.AssessmentOutcome = 'Deny' and isnull(FPPayments, 0) = 0 then 'Denied'
        when e5.AssessmentOutcome = 'Approve' and isnull(FPPayments, 0) = 0 and isnull(TPPayments, 0) = 0 then 'Denied'
        when e5.AssessmentOutcome = 'Approve' then 'Approved'
        when e5.AssessmentOutcome = 'No action required' and isnull(FPPayments, 0) + isnull(TPPayments, 0) > 0 then 'Approved'
        when e5.AssessmentOutcome = 'No action required' and isnull(FPPayments, 0) = 0 and isnull(TPPayments, 0) = 0 then 'Denied'
        when e5.CaseStatus = 'Complete' and isnull(FPPayments, 0) + isnull(TPPayments, 0) > 0 then 'Approved'
		--	Added 3 new AssessmentOutcome cases per INC0221634 
		when e5.AssessmentOutcome = 'Claim Under Excess' then 'Claim Under Excess'
		--when e5.AssessmentOutcome = 'Claim Withdrawn' then 'Claim Withdrawn'
		when e5.AssessmentOutcome = 'Partial Approval and Denial' then 'Partial Approval and Denial' 

       when e5.CaseStatus = 'Complete' and isnull(FPPayments, 0) = 0 and isnull(TPPayments, 0) = 0 then 'Denied'
        when e5.CaseStatus in ('Active', 'Diarised') then 'Pending'
        when e5.CaseStatus = 'Rejected' then 'Merged to other claim'
        when cl.CreateDate < '2010-01-01' then 'Pre e5'
        when e5.AssessmentOutcome is null and isnull(FPPayments, 0) = 0 and isnull(TPPayments, 0) = 0 then 'No assessment'
        when e5.AssessmentOutcome is null and isnull(FPPayments, 0) + isnull(TPPayments, 0) > 0 then 'No assessment - Paid'
        when e5.CaseID is null then 'No assessment' 

  


		end AssessmentOutcome
	
from
    [db-au-cmdwh].[dbo].[clmClaim] cl with(nolock)
    outer apply
    (
        select top 1 
            ce.EventDesc,
            ce.EventCountryName
        from
            [db-au-cmdwh].[dbo].[clmEvent] ce
        where
            ce.ClaimKey = cl.ClaimKey
    ) ce
    left join [db-au-cmdwh].[dbo].[clmClaimFlags] cf with(nolock) on
        cf.ClaimKey = cl.ClaimKey
    outer apply
    (
        select 
            sum(ci.PaymentDelta) Paid
        from
            [db-au-cmdwh].[dbo].vclmClaimIncurred ci with(nolock)
        where
            ci.ClaimKey = cl.ClaimKey
    ) ci
    outer apply
    (
        select top 1 
            cn.Firstname + ' ' + cn.Surname PrimaryClaimant
        from
            [db-au-cmdwh].[dbo].clmName cn
        where
            cn.ClaimKey = cl.ClaimKey and
            cn.isPrimary = 1
    ) pcn 
    outer apply
    (
        select top 1 
            w.Work_ID CaseID,
            w.Original_Work_ID,
            w.Reference CaseReference,
            w.StatusName CaseStatus,
            AssessmentOutcome
		from
            [db-au-cmdwh].[dbo].e5Work w with(nolock)
            outer apply
            (
                select top 1
                    wa.AssessmentOutcomeDescription AssessmentOutcome
                from
                    [db-au-cmdwh].[dbo].e5WorkActivity wa with(nolock)
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
            [db-au-cmdwh].[dbo].e5Work w with(nolock)
            outer apply
            (
                select top 1
                    wi.Name
                from
                    [db-au-cmdwh].[dbo].e5WorkActivity wa with(nolock)
                    inner join [db-au-cmdwh].[dbo].e5WorkActivityProperties wap with(nolock) on
                        wap.WorkActivity_ID = wa.ID and
                        wap.Property_ID = 'IDROutcome'
                    inner join [db-au-cmdwh].[dbo].e5WorkItems wi with(nolock) on
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
            [db-au-cmdwh].[dbo].e5Work w with(nolock)
            outer apply
            (
                select top 1
                    wi.Name
                from
                    [db-au-cmdwh].[dbo].e5WorkActivity wa with(nolock)
                    inner join [db-au-cmdwh].[dbo].e5WorkActivityProperties wap with(nolock) on
                        wap.WorkActivity_ID = wa.ID and
                        wap.Property_ID = 'InvestigationOutcome'
                    inner join [db-au-cmdwh].[dbo].e5WorkItems wi with(nolock) on
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
            [db-au-cmdwh].[dbo].clmPayment cp with(nolock)
            inner join [db-au-cmdwh].[dbo].clmName cn with(nolock) on
                cn.NameKey = cp.PayeeKey
        where
            cp.ClaimKey = cl.ClaimKey and
            cp.PaymentStatus in ('APPR', 'PAID')
    ) cp ) 

	select 
		ClaimKey, 
	count(case
                    when cte.AssessmentOutcome = 'Claim Under Excess' then 1
                    else null
                end
            ) as [Claim Under Excess Count], 

			count(
          
            case
                    when cte.AssessmentOutcome  = 'Claim Withdrawn' then 1
					  else null
				end

            ) as [Claim Withdrawn Count], 

			count(
               distinct
                case
                    when cte.AssessmentOutcome = 'Partial Approval and Denial' then 1
                    else null
                end
            ) as [Partial Approval and Denial Count]

			from cte

group by
	ClaimKey

	
GO
