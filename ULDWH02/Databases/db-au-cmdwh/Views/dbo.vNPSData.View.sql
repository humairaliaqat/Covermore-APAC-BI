USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vNPSData]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vNPSData]
as
select 
    --top 100
    --distinct
    o.CountryKey,
    r.InteractionDate,

    p.PolicyNumber [Policy Number],
    p.IssueDate [Issue Date],
    p.TripStart [Departure Date],
    p.TripEnd [Return Date],
    ptv.MemberNumber [Member Number],
    ptv.FirstName [First Name],
    lower(ptv.EmailAddress) [Email Address],
    ptv.Age,
    case
        when ptv.OptFurtherContact is null then 'Unknown'
        when ptv.OptFurtherContact = 1 then 'Yes'
        else 'No'
    end [Opted In for Further Contact],
    case
        when ptv.MarketingConsent is null then 'Unknown'
        when ptv.MarketingConsent = 1 then 'Yes'
        else 'No'
    end [Given Consent for Marketing Purpose],
    o.SuperGroupName [Super Group Name],
    o.GroupName [Group Name],
    o.SubGroupName [Sub Group Name],
    o.AlphaCode [Alpha Code],
    o.BDMName [BDM Name],
    ptv.Suburb,
    ptv.State,
    ptv.PostCode [Post Code],
    p.TripDuration [Trip Duration],
    pt.[Sell Price],
    case
        when isnull([Medical Premium], 0) <> 0 then 'Yes'
        else 'No'
    end [Has EMC],
    p.ProductCode [Product], 
    p.PlanName [Plan Name],
    p.PlanId [Plan ID],
    p.Area,
    p.PrimaryCountry [Primary Country],
    pt.[Traveller Count],
    isnull(cl.[Claim Number], '') [Claim Number],
    isnull(cl.[Claimant First Name], '') [Claimant First Name],
    isnull(cl.[Claimant Last Name], '') [Claimant Last Name],
    isnull(cl.[Peril], '') [Peril],
    isnull(cl.[Country of Claim], '') [Country of Claim],
    isnull(cc.[Medical Assistance Number], '') [Medical Assistance Number],
    isnull(cl.[Benefit 1], '') [Benefit 1],
    isnull(cl.[Benefit 2], '') [Benefit 2],
    isnull(cl.[Benefit 3], '') [Benefit 3],
    isnull(cl.[Benefit 4], '') [Benefit 4],
    isnull(cl.[Benefit 1 Value], '') [Benefit 1 Incurred],
    isnull(cl.[Benefit 2 Value], '') [Benefit 2 Incurred],
    isnull(cl.[Benefit 3 Value], '') [Benefit 3 Incurred],
    isnull(cl.[Benefit 4 Value], '') [Benefit 4 Incurred],
    [Time to Closure],
    [Cycle Time to Date],
    isnull(cl.[First assessment by], '') [First assessment by],
    isnull(cl.[Last assessment by], '') [Last assessment by],
    isnull(cl.[Incurred Value], 0) [Incurred Value],
    case
        when isnull(cl.[Has Approved Assessment], 0) >= 1 then 'Yes'
        else 'No'
    end [Has Approved Assessment],
    case
        when isnull(cl.[Has Denied Assessment], 0) >= 1 then 'Yes'
        else 'No'
    end [Has Denied Assessment],
    cc.[Satisfaction Level],
    cc.CaseType [Case Type],
    cc.Protocol,
    cc.UWCoverStatus [UW Decission],
    cc.OpenDate [CC Open Date],
    cc.FirstCloseDate [CC First Close Date],
    cc.TimeToDecission [CC Time to Decission]
    --right(ptv.EmailAddress, len(ptv.EmailAddress) - charindex('@', ptv.EmailAddress))
from
    (
        select 
            pt.PolicyKey,
            convert(date, pt.PostingDate) InteractionDate
        from
            penPolicyTransSummary pt
            inner join penOutlet o on
                o.OutletAlphaKey = pt.OutletAlphaKey
            
        union

        select 
            pt.PolicyKey,
            convert(date, cl.CreateDate) InteractionDate
        from
            clmClaim cl
            inner join penPolicyTransSummary pt on
                pt.PolicyTransactionKey = cl.PolicyTransactionKey
            
        union

        select
            pt.PolicyKey,
            convert(date, c.OpenDate) InteractionDate
        from
            cbCase c
            inner join cbPolicy cp on
                cp.CaseKey = c.CaseKey
            inner join penPolicyTransSummary pt on
                pt.PolicyTransactionKey = cp.PolicyTransactionKey
            inner join penOutlet o on
                o.OutletAlphaKey = pt.OutletAlphaKey
    ) r
    inner join penPolicy p on
        p.PolicyKey = r.PolicyKey
    inner join penOutlet o on
        o.OutletAlphaKey = p.OutletAlphaKey and
        o.OutletStatus = 'Current'
    cross apply
    (
        select 
            sum(isnull(pt.GrossPremium, 0)) [Sell Price],
            sum(isnull([Medical Premium], 0)) [Medical Premium],
            sum(isnull(pt.TravellersCount, 0)) [Traveller Count]
        from
            penPolicyTransSummary pt
            outer apply
            (
                select 
                    sum(pap.Medical) [Medical Premium]
                from
                    [db-au-cmdwh]..vPenPolicyAddonPremium pap
                where
                    pap.PolicyTransactionKey = pt.PolicyTransactionKey
            ) pap
        where
            pt.PolicyKey = p.PolicyKey
    ) pt
    cross apply
    (
        select top 1 
            MemberNumber,
            FirstName,
            EmailAddress,
            Age,
            Suburb,
            State,
            PostCode,
            OptFurtherContact,
            MarketingConsent
        from
            penPolicyTraveller ptv
        where
            ptv.PolicyKey = p.PolicyKey and
            ptv.isPrimary = 1
    ) ptv
    outer apply
    (
        select top 1 
            cl.ClaimNo [Claim Number],
            isnull(cn.Firstname, '') [Claimant First Name],
            isnull(cn.Surname, '') [Claimant Last Name],
            ce.PerilDesc [Peril],
            [Benefit 1],
            [Benefit 1 Value],
            [Benefit 2],
            [Benefit 2 Value],
            [Benefit 3],
            [Benefit 3 Value],
            [Benefit 4],
            [Benefit 4 Value],
            datediff(
                day, 
                cl.ReceivedDate, 
                case
                    when e5.[e5 Status] = 'Complete' then e5.[e5 Complete Date]
                    when e5.[e5 Status] is null then cl.FinalisedDate
                    else null
                end
            ) [Time to Closure],
            datediff(
                day, 
                cl.ReceivedDate, 
                case
                    when e5.[e5 Status] = 'Complete' then null
                    else getdate()
                end
            ) [Cycle Time to Date],
            [First assessment by],
            [Last assessment by],
            [Incurred Value],
            ce.EventCountryName [Country of Claim],
            [Has Approved Assessment],
            [Has Denied Assessment],
            ce.CaseID CCCaseNo
        from
            clmClaim cl 
            inner join clmEvent ce on
                ce.ClaimKey = cl.ClaimKey
            outer apply
            (
                select 
                    sum(cs.EstimateValue) + sum(isnull(cp.Paid, 0)) [Incurred Value]
                from
                    clmSection cs
                    outer apply
                    (
                        select 
                            sum(PaymentAmount) Paid
                        from
                            clmPayment cp
                        where
                            cp.SectionKey = cs.SectionKey and
                            cp.isDeleted = 0 and
                            cp.PaymentStatus in ('PAID', 'RECY')
                    ) cp
                where
                    cs.ClaimKey = cl.ClaimKey and
                    cs.isDeleted = 0
            ) cs
            outer apply
            (
                select top 1 
                    cn.Firstname,
                    cn.Surname
                from
                    clmName cn
                where
                    cn.ClaimKey = cl.ClaimKey and
                    cn.isPrimary = 1
            ) cn
            outer apply
            (
                select
                    max(
                        case
                            when b.ItemNumber = 1 then b.Benefit
                            else ''
                        end 
                    ) [Benefit 1],
                    sum(
                        case
                            when b.ItemNumber = 1 then isnull(b.[Incurred Value], 0)
                            else 0
                        end 
                    ) [Benefit 1 Value],
                    max(
                        case
                            when b.ItemNumber = 2 then b.Benefit
                            else ''
                        end 
                    ) [Benefit 2],
                    sum(
                        case
                            when b.ItemNumber = 2 then isnull(b.[Incurred Value], 0)
                            else 0
                        end 
                    ) [Benefit 2 Value],
                    max(
                        case
                            when b.ItemNumber = 3 then b.Benefit
                            else ''
                        end 
                    ) [Benefit 3],
                    sum(
                        case
                            when b.ItemNumber = 3 then isnull(b.[Incurred Value], 0)
                            else 0
                        end 
                    ) [Benefit 3 Value],
                    max(
                        case
                            when b.ItemNumber = 4 then b.Benefit
                            else ''
                        end 
                    ) [Benefit 4],
                    sum(
                        case
                            when b.ItemNumber = 4 then isnull(b.[Incurred Value], 0)
                            else 0
                        end 
                    ) [Benefit 4 Value]
                from
                    (
                        select top 4
                            cb.BenefitDesc Benefit,
                            sum(cs.EstimateValue) + sum(isnull(cp.Paid, 0)) [Incurred Value],
                            row_number() over (order by sum(cs.EstimateValue) + sum(isnull(cp.Paid, 0)) desc) ItemNumber
                        from
                            clmSection cs
                            inner join clmBenefit cb on
                                cb.BenefitSectionKey = cs.BenefitSectionKey
                            outer apply
                            (
                                select 
                                    sum(PaymentAmount) Paid
                                from
                                    clmPayment cp
                                where
                                    cp.SectionKey = cs.SectionKey and
                                    cp.isDeleted = 0 and
                                    cp.PaymentStatus in ('PAID', 'RECY')
                            ) cp
                        where
                            isDeleted = 0 and
                            cs.ClaimKey = cl.ClaimKey
                        group by
                            cb.BenefitDesc
                        order by 
                            2 desc
                    ) b
            ) cb
            outer apply
            (
                select top 1 
                    w.StatusName [e5 Status],
                    --w.CompletionDate [e5 Complete Date],
                    isnull(LastRealClosedDate, w.CompletionDate) [e5 Complete Date],
                    [First assessment by],
                    [Last assessment by],
                    [Has Denied Assessment],
                    [Has Approved Assessment]
                from
                    e5Work w
                    outer apply
                    (
                        select top 1 
                            wa.CompletionUser [First assessment by]
                        from
                            e5WorkActivity wa
                        where
                            wa.Work_ID = w.Work_ID and
                            wa.CategoryActivityName = 'Assessment Outcome' and
                            wa.CompletionDate is not null
                        order by
                            wa.CompletionDate
                    ) fao
                    outer apply
                    (
                        select top 1 
                            wa.CompletionUser [Last assessment by]
                        from
                            e5WorkActivity wa
                        where
                            wa.Work_ID = w.Work_ID and
                            wa.CategoryActivityName = 'Assessment Outcome' and
                            wa.CompletionDate is not null
                        order by
                            wa.CompletionDate desc
                    ) lao
                    outer apply
                    (
                        select top 1 
                            EventDate LastRealClosedDate
                        from
                            e5WorkEvent we
                        where
                            we.Work_Id = w.Work_ID and
                            we.EventName = 'Changed Work Status' and
                            we.StatusName = 'Complete' and
                            we.EventUser <> 'PricingFixDec2014'
                        order by
                            EventDate desc
                    ) we
                    outer apply
                    (
                        select 
                            sum(
                                case
                                    when wi.Code like '%deny%' or wi.Code like '%denial%' then 1
                                    else 0
                                end
                            ) [Has Denied Assessment],
                            sum(
                                case
                                    when wi.Code like '%approv%' then 1
                                    else 0
                                end
                            ) [Has Approved Assessment]
                        from
                            e5WorkActivity wa
                            inner join e5WorkItems wi on
                                wi.ID = wa.AssessmentOutcome
                        where
                            wa.Work_ID = w.Work_ID and
                            wa.CategoryActivityName = 'Assessment Outcome' and
                            wa.CompletionDate is not null and
                            (
                                wi.Code like '%deny%' or
                                wi.Code like '%denial%' or
                                wi.Code like '%approv%'
                            )
                    ) ha
                where
                    w.ClaimKey = cl.ClaimKey and
                    w.WorkType like '%claim%'
                order by
                    w.CreationDate desc
            ) e5
        where
            cl.PolicyTransactionKey in 
            (
                select 
                    pt.PolicyTransactionKey
                from
                    penPolicyTransSummary pt
                where
                    pt.PolicyKey = r.PolicyKey
            )
        order by
            cl.CreateDate desc
    ) cl
    outer apply
    (
        select top 1 
            cc.CaseNo [Medical Assistance Number],
            cc.Surname [Medical Last Name],
            ce.Emotion [Satisfaction Level],
            cc.CaseType,
            cc.Protocol,
            cc.UWCoverStatus,
            cc.OpenDate,
            cc.FirstCloseDate,
            datediff(hh, cc.OpenTime, cfd.FirstDecission) TimeToDecission
        from
            cbCase cc
            left join cbPolicy cp on
                cp.CaseKey = cc.CaseKey
            outer apply
            (
                select top 1 
                    Emotion
                from
                    cbEmotion ce
                where
                    ce.CaseKey = cc.CaseKey
            ) ce
            outer apply
            (
                select 
                    min(NoteTime) FirstUWNote
                from
                    cbNote cn
                where
                    cn.CaseKey = cc.CaseKey and
                    cn.NoteCode in ('UC', 'UD')
            ) cn
            outer apply
            (
                select 
                    min(AuditDateTime) FirstUWCover
                from
                    cbAuditCase cac
                where
                    cac.CaseKey = cc.CaseKey and
                    (
                        cac.isUWCoverChanged = 1 or
                        cac.AuditAction = 'I'
                    ) and
                    cac.UWCoverStatus in ('Covered', 'Limited Cover', 'Cover Declined', 'Without Prejudice')
            ) cac
            outer apply
            (
                select 
                    case
                        when FirstUWNote < FirstUWCover then FirstUWNote
                        else FirstUWCover
                    end FirstDecission
            ) cfd
        where
            cp.PolicyTransactionKey in
            (
                select 
                    pt.PolicyTransactionKey
                from
                    penPolicyTransSummary pt
                where
                    pt.PolicyKey = r.PolicyKey
            ) 
            --or
            --cc.CaseNo = convert(varchar, cl.CCCaseNo)
        order by
            cc.OpenDate desc
    ) cc
where
    --exclude internals
    (
        ptv.EmailAddress not like '%@flightcentre.%' and
        ptv.EmailAddress not like '%@covermore.%' and
        ptv.EmailAddress not like '%@customercare.%' and
        ptv.EmailAddress not like '%@medicalassistance.%' and
        ptv.EmailAddress not like '%@travelinsurancepartners.%' and
        ptv.EmailAddress not like '%@escapetravel.%' and
        ptv.EmailAddress not like '%@studentflights.%' and
        ptv.EmailAddress not like '%@cruiseabout.%' and
        ptv.EmailAddress not like '%@travelassociates.%' and
        ptv.EmailAddress not like '%@helloworld.%' and
        ptv.EmailAddress not like '%@harveyworldtravel.%' and
        ptv.EmailAddress not like '%@travelscene.%'
    ) and
    --exclude death claims
    (
        isnull([Claimant First Name], '') not like '%estate%' and
        isnull([Claimant Last Name], '') not like '%estate%' and
        isnull([Peril], '') not like '%death%'
    ) and
    --exclude deceased assitance
    (
        isnull([Medical Last Name], '') not like '%decease%'
    ) 
    --and
    --r.CountryKey = 'AU' and
    --r.InteractionDate >= '2015-01-01' and
    --r.InteractionDate <  '2015-02-01'
--order by 1







GO
