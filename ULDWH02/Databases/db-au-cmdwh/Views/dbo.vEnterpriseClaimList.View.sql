USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vEnterpriseClaimList]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[vEnterpriseClaimList]
as
select --top 1000
    ec.CustomerID,
    cl.CLaimNo,
    cl.CreateDate,
    cl.PolicyNo PolicyNumber,
    isnull(ci.Paid, 0) Paid,
    isnull(ci.Estimate, 0) Estimate,
    coalesce(cf.EventDescription, ce.EventDesc, '') EventDescription,
    isnull(cf.EventLocation, '') EventLocation,
    coalesce(cf.EventCountryName, ce.EventCountryName, '') EventCountryName,
    isnull(cf.MentalHealthFlag, 0) MentalHealthFlag,
    isnull(cf.LuggageFlag, 0) LuggageFlag,
    isnull(cf.ElectronicsFlag, 0) ElectronicsFlag,
    isnull(cf.CruiseFlag, 0) CruiseFlag,
    isnull(cf.MopedFlag, 0) MopedFlag,
    isnull(cf.RentalCarFlag, 0) RentalCarFlag,
    isnull(cf.WinterSportFlag, 0) WinterSportFlag,
    isnull(cf.CrimeVictimFlag, 0) CrimeVictimFlag,
    isnull(cf.FoodPoisoningFlag, 0) FoodPoisoningFlag,
    isnull(cf.AnimalFlag, 0) AnimalFlag,
    isnull(cf.LocationRedFlag, 0) LocationRedFlag,
    isnull(cf.LuggageRedFlag, 0) LuggageRedFlag,
    isnull(cf.SectionRedFlag, 0) SectionRedFlag,
    isnull(cf.MedicalCostFlag, 0) MedicalCostFlag,
    isnull(cf.HighValueLuggageRedFlag, 0) HighValueLuggageRedFlag,
    isnull(cf.MultipleElectronicRedFlag, 0) MultipleElectronicRedFlag,
    isnull(cf.OnlyElectronicRedFlag, 0) OnlyElectronicRedFlag,
    isnull(cf.NoProofRedFlag, 0) NoProofRedFlag,
    isnull(cf.NoReportRedFlag, 0) NoReportRedFlag,
    isnull(cf.CrimeVictimRedFlag, 0) CrimeVictimRedFlag,
    isnull(wa.WithdrawnCount, 0) InvestigationWithdrawnCount,
    isnull(wa.DeniedCount, 0) InvestigationDeniedCount,
    isnull(wa.FraudCount, 0) InvestigationFraudCount,
    isnull(wa.NoResponseCount, 0) InvestigationNoResponseCount,
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
    end AssessmentOutcome,
    PrimaryClaimant,
    'http://e5.covermore.com/sites/CoverMore/AU/_layouts/15/e5/WorkProcessFrame.aspx?source=FindWork&id=' + convert(varchar(50), e5.Original_Work_ID) e5URL,
    cl.ClaimKey,
    isnull(ecc.Classification, '') ClaimClassification,
    case
        when isnull(ecc.Classification, '') <> '' then ecc.Details
        else ''
    end Details
from
    entCustomer ec with(nolock)
    cross apply
    (
        select distinct
            ep.PolicyKey
        from
            entPolicy ep with(nolock)
        where
            ep.CustomerID = ec.CustomerID
    ) ep
    inner join penPolicyTransSummary pt with(nolock) on
        pt.PolicyKey = ep.PolicyKey
    inner join clmClaim cl with(nolock) on
        cl.PolicyTransactionKey = pt.PolicyTransactionKey
    outer apply
    (
        select top 1 
            ce.EventDesc,
            ce.EventCountryName
        from
            clmEvent ce
        where
            ce.ClaimKey = cl.ClaimKey
    ) ce
    left join clmClaimFlags cf with(nolock) on
        cf.ClaimKey = cl.ClaimKey
    outer apply
    (
        select 
            sum(ci.PaymentDelta) Paid,
            sum(ci.EstimateDelta) Estimate
        from
            vclmClaimIncurred ci with(nolock)
        where
            ci.ClaimKey = cl.ClaimKey
    ) ci
    outer apply
    (
        select top 1 
            cn.Firstname + ' ' + cn.Surname PrimaryClaimant
        from
            clmName cn
        where
            cn.ClaimKey = cl.ClaimKey and
            cn.isPrimary = 1
    ) pcn
    outer apply
    (
        select 
            sum(case when wa.Name = 'Withdrawn' then 1 else 0 end) WithdrawnCount,
            sum(case when wa.Name in ('Denied - Other', 'Denied - Policy Condition') then 1 else 0 end) DeniedCount,
            sum(case when wa.Name = 'Denied - Fraud and/or UGF' then 1 else 0 end) FraudCount,
            sum(case when wa.Name = 'No Response from Insured  ' then 1 else 0 end) NoResponseCount
        from
            e5Work w with(nolock)
            cross apply
            (
                select top 1
                    wi.Name
                from
                    e5WorkActivity wa with(nolock)
                    inner join e5WorkActivityProperties wap with(nolock) on
                        wap.WorkActivity_ID = wa.ID and
                        wap.Property_ID = 'InvestigationOutcome'
                    inner join e5WorkItems wi with(nolock) on
                        wi.ID = wap.PropertyValue
                where
                    wa.Work_ID = w.Work_ID and
                    wa.CategoryActivityName = 'Investigation Outcome' and
                    wa.CompletionDate is not null
                order by
                    wa.CompletionDate desc
            ) wa
        where
            w.WorkType = 'Investigation' and
            w.ClaimKey = cl.ClaimKey
    ) wa
    outer apply
    (
        select top 1 
            w.Work_ID CaseID,
            w.Original_Work_ID,
            w.Reference CaseReference,
            w.StatusName CaseStatus,
            AssessmentOutcome
        from
            e5Work w with(nolock)
            outer apply
            (
                select top 1
                    wa.AssessmentOutcomeDescription AssessmentOutcome
                from
                    e5WorkActivity wa with(nolock)
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
            e5Work w with(nolock)
            outer apply
            (
                select top 1
                    wi.Name
                from
                    e5WorkActivity wa with(nolock)
                    inner join e5WorkActivityProperties wap with(nolock) on
                        wap.WorkActivity_ID = wa.ID and
                        wap.Property_ID = 'IDROutcome'
                    inner join e5WorkItems wi with(nolock) on
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
            e5Work w with(nolock)
            outer apply
            (
                select top 1
                    wi.Name
                from
                    e5WorkActivity wa with(nolock)
                    inner join e5WorkActivityProperties wap with(nolock) on
                        wap.WorkActivity_ID = wa.ID and
                        wap.Property_ID = 'InvestigationOutcome'
                    inner join e5WorkItems wi with(nolock) on
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
            clmPayment cp with(nolock)
            inner join clmName cn with(nolock) on
                cn.NameKey = cp.PayeeKey
        where
            cp.ClaimKey = cl.ClaimKey and
            cp.PaymentStatus in ('APPR', 'PAID')
    ) cp
    left join vEnterpriseClaimClassification ecc with(nolock) on
        ecc.Claimkey = cl.Claimkey

where
    not exists
    (
        select
            null
        from
            penPolicy p with(nolock)
        where
            p.PolicyKey = ep.PolicyKey and
            p.ProductName like '%Base'
    ) or
    exists
    (
        select
            null
        from
            entPolicy pcl with(nolock)
        where
            pcl.ClaimKey = cl.ClaimKey and
            pcl.CustomerID = ec.CustomerID
    )


--where
--    ec.CustomerID = 104589






GO
