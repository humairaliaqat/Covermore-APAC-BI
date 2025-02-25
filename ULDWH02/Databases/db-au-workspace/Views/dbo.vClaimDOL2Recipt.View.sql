USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vClaimDOL2Recipt]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vClaimDOL2Recipt] 
as
select --top 1000 
    cl.CountryKey [Domain],
    coalesce(p.AlphaCode, cl.AgencyCode) [Alpha Code],
    coalesce(p.PolicyNumber, cl.PolicyNo) [Policy Number],
    SuperGroupName [Group],
    cl.ClaimNo [Claim Number],
    cb.EventID [Event ID],
    cb.SectionID [Section ID],
    convert(date, coalesce(p.IssueDate, cl.PolicyIssuedDate)) [Issue Date],
    id.IssueMonth [Issue Month],
    id.IssueQuarter [Issue Quarter],
    cb.EventDate [Loss Date],
    ld.LossMonth [Loss Month],
    ld.LossQuarter [Loss Quarter],
    convert(date, cl.ReceivedDateTimeUTC) [Receipt Date],
    rd.ReceiptMonth [Receipt Month],
    rd.ReceiptMonth [Receipt Quarter],
    csd.SectionDate [Section Date],
    csq.SectionQuarter [Section Quarter],
    TriangleMonth [Triangle Month],
    TriangleQuarter [Triangle Quarter],
    cb.BenefitCategory [Section],
    Bucket,
    EstimateToDate [Estimate],
    PaymentToDate [Paid To Date],
    IncurredToDate [Incurred],
    isnull(EstimateDelta, 0) [Estimate Movement],
    isnull(PaymentDelta, 0) [Payment Movment],
    isnull(IncurredDelta, 0) [Incurred Movement],
    case
        when ld.LossQuarter < csq.SectionQuarter then 1
        else 0
    end [DOL < Rec]
from
    [db-au-cmdwh]..clmClaim cl
    cross apply
    (
        select 
            cs.SectionKey
        from
            [db-au-cmdwh]..vclmClaimSectionIncurred cs
        where
            cs.ClaimKey = cl.ClaimKey
        group by
            cs.SectionKey
    ) cs
    outer apply
    (
        select top 1 
            r.SectionID,
            cb.BenefitCategory,
            ce.EventID,
            convert(date, [db-au-cmdwh].dbo.xfn_ConvertLocaltoUTC(ce.EventDate, 'AUS Eastern Standard Time')) EventDate
        from
            [db-au-cmdwh]..clmSection r
            left join [db-au-cmdwh]..clmEvent ce on
                ce.EventKey = r.EventKey
            left join [db-au-cmdwh]..vclmBenefitCategory cb on
                cb.BenefitSectionKey = r.BenefitSectionKey
        where
            r.SectionKey = cs.SectionKey
    ) cb
    outer apply
    (
        select top 1 
            p.PolicyNumber,
            convert(date, p.IssueDateUTC) IssueDate,
            o.AlphaCode,
            o.OutletKey
        from
            [db-au-cmdwh]..penPolicyTransSummary pt
            inner join [db-au-cmdwh]..penPolicy p on
                p.PolicyKey = pt.PolicyKey
            inner join [db-au-cmdwh]..penOutlet o on
                o.OutletAlphaKey = pt.OutletAlphaKey and
                o.OutletStatus = 'Current'
        where
            pt.PolicyTransactionKey = cl.PolicyTransactionKey
    ) p
    outer apply
    (
        select 
            convert(date, d.CurMonthStart) IssueMonth,
            convert(date, d.CurQuarterEnd) IssueQuarter
        from
            [db-au-cmdwh]..Calendar d
        where
            d.[Date] = convert(date, coalesce(p.IssueDate, cl.PolicyIssuedDate))
    ) id
    outer apply
    (
        select 
            convert(date, d.CurMonthStart) LossMonth,
            convert(date, d.CurQuarterEnd) LossQuarter
        from
            [db-au-cmdwh]..Calendar d
        where
            d.[Date] = cb.EventDate
    ) ld
    outer apply
    (
        select 
            convert(date, d.CurMonthStart) ReceiptMonth,
            convert(date, d.CurQuarterEnd) ReceiptQuarter
        from
            [db-au-cmdwh]..Calendar d
        where
            d.[Date] = convert(date, cl.ReceivedDateTimeUTC)
    ) rd
    outer apply
    (
        select
            min(convert(date, SectionDate)) SectionDate
        from
            (
                select 
                    AuditDateTimeUTC SectionDate
                from
                    [db-au-cmdwh]..clmAuditSection cas
                where
                    cas.SectionKey = cs.SectionKey

                union

                select 
                    EHCreateDateTimeUTC
                from
                    [db-au-cmdwh]..clmEstimateHistory ceh
                where
                    ceh.SectionKey = cs.SectionKey
            ) csd
    ) csd
    outer apply
    (
        select top 1 
            convert(date, CurMonthStart) SectionMonth,
            convert(date, CurQuarterEnd) SectionQuarter
        from
            [db-au-cmdwh]..Calendar d
        where
            d.[Date] = csd.SectionDate
    ) csq
    cross apply
    (
        select 
            convert(date, td.[Date]) TriangleMonth,
            convert(date, td.CurMonthEnd) TriangleMonthEnd,
            convert(date, td.CurQuarterEnd) TriangleQuarter
        from
            [db-au-cmdwh]..Calendar td
        where
            td.Date >= csq.SectionMonth and
            td.Date <= convert(date, getdate()) and
            datepart(day, td.[Date]) = 1
    ) td
    outer apply
    (
        select top 1 
            do.SuperGroupName
        from
            [db-au-star]..dimOutlet do
        where
            do.OutletKey = coalesce(p.OutletKey, cl.OutletKey) and
            do.isLatest = 'Y'
    ) o
    outer apply
    (
        select 
            min(Bucket) Bucket,
            sum(EstimateDelta) EstimateToDate,
            sum(PaymentDelta) PaymentToDate,
            sum(IncurredDelta) IncurredToDate
        from
            [db-au-cmdwh]..vclmClaimSectionIncurredUTC csi
        where
            csi.SectionKey = cs.SectionKey and
            csi.IncurredDateUTC <= td.TriangleMonthEnd
    ) csi
    outer apply
    (
        select 
            sum(EstimateDelta) EstimateDelta,
            sum(PaymentDelta) PaymentDelta,
            sum(IncurredDelta) IncurredDelta
        from
            [db-au-cmdwh]..vclmClaimSectionIncurredUTC csi
        where
            csi.SectionKey = cs.SectionKey and
            csi.IncurredDateUTC >= td.TriangleMonth and
            csi.IncurredDateUTC <= td.TriangleMonthEnd
    ) csid

GO
