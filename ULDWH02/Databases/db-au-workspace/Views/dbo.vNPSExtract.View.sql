USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vNPSExtract]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--select top 1000 *
--from
--    tmpNPS
--where
--    ClaimKey is not null and
--    TopicRelevance is not null



--assessor: first & last
--benefit
--value
CREATE view [dbo].[vNPSExtract] as
select 
    d.BIRowID,
    d.[FileName],
    d.DomainCountry,
    d.SuperGroup,
    d.[Policy No],
    d.[Claim No],
    d.[MA Case No],
    nt.TopicRelevance,
    nt.Topic,
    nt.TopicArea,
    ns.ScoreTag,
    ns.Agreement,
    ns.Subjectivity,
    ns.Confidence,
    ns.Irony,
    nc.ClassificationCode,
    nc.ClassificationRelevance,
    nc.RelevanceRank,
    r.[Overall Score],
    r.[Score Comment],
    r.[Recommendation Score],
    r.[Claim Score],
    r.[Claim Comment],
    r.[MA Score],
    r.[MA Comment],
    r.[GlobalSIM Score],
    r.[GlobalSIM Comment],
    r.RecommendedScore,
    r.ClmSFScore_Response,
    r.ClmSFScore_Engagement,
    r.ClmSFScore_StaffKnowledge,
    r.ClmSFScore_Timing,
    r.GlobalSIMSFScore,
    r.GlobalSIMRecScore,
    r.ResponsiveSFScore,
    r.EngagementSFScore,
    r.OverallSFScore,
    case
        when Benefit like '%luggage%' then 'Luggage'
        when Benefit like '%cancel%' then 'Canx'
        when Benefit like '%medical%' then 'Medical'
        else 'Other'
    end BenefitGroup,
    cl.*
from
    [db-au-cmdwh]..npsData d
    inner join [db-au-cmdwh]..npsResponse r on
        r.BIRowID = d.BIRowID
    outer apply
    (
        select
            nt.Relevance TopicRelevance,
            nt.Topic,
            nt.TopicArea
        from
            [db-au-cmdwh]..npsTopic nt
        where
            nt.BIRowID = d.BIRowID
    ) nt
    outer apply
    (
        select
            ns.ScoreTag,
            ns.Agreement,
            ns.Subjectivity,
            ns.Confidence,
            ns.Irony
        from
            [db-au-cmdwh]..npsSentiment ns
        where
            ns.BIRowID = d.BIRowID
    ) ns
    outer apply
    (
        select
            nc.Classification ClassificationCode,
            nc.Relevance ClassificationRelevance,
            nc.RelevanceRank
        from
            [db-au-cmdwh]..npsClassification nc
        where
            nc.BIRowID = d.BIRowID
    ) nc
    outer apply
    (
        select
            ce.PerilDesc [Peril],
            [Benefit],
            [BenefitValue],
            IncurredValue,
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
            [Has Approved Assessment],
            [Has Denied Assessment]
        from
            [db-au-cmdwh]..clmClaim cl 
            cross apply
            (
                select top 1
                    ci.IncurredValue
                from
                    [db-au-cmdwh]..vclmClaimIncurred ci
                where
                    ci.ClaimKey = cl.ClaimKey
                order by
                    ci.IncurredDate desc
            ) ci
            inner join [db-au-cmdwh]..clmEvent ce on
                ce.ClaimKey = cl.ClaimKey
            outer apply
            (
                select 
                    cb.BenefitCategory Benefit,
                    sum(cs.EstimateValue) + sum(isnull(cp.Paid, 0)) BenefitValue
                from
                    [db-au-cmdwh]..clmSection cs
                    inner join [db-au-cmdwh]..vclmBenefitCategory cb on
                        cb.BenefitSectionKey = cs.BenefitSectionKey
                    outer apply
                    (
                        select 
                            sum(PaymentAmount) Paid
                        from
                            [db-au-cmdwh]..clmPayment cp
                        where
                            cp.SectionKey = cs.SectionKey and
                            cp.isDeleted = 0 and
                            cp.PaymentStatus in ('PAID', 'RECY')
                    ) cp
                where
                    isDeleted = 0 and
                    cs.ClaimKey = cl.ClaimKey
                group by
                    cb.BenefitCategory
            ) cb
            outer apply
            (
                select top 1 
                    w.StatusName [e5 Status],
                    isnull(LastRealClosedDate, w.CompletionDate) [e5 Complete Date],
                    [First assessment by],
                    [Last assessment by],
                    [Has Denied Assessment],
                    [Has Approved Assessment]
                from
                    [db-au-cmdwh]..e5Work w
                    outer apply
                    (
                        select top 1 
                            wa.CompletionUser [First assessment by]
                        from
                            [db-au-cmdwh]..e5WorkActivity wa
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
                            [db-au-cmdwh]..e5WorkActivity wa
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
                            [db-au-cmdwh]..e5WorkEvent we
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
                            [db-au-cmdwh]..e5WorkActivity wa
                            inner join [db-au-cmdwh]..e5WorkItems wi on
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
            cl.ClaimKey = r.ClaimKey
    ) cl


GO
