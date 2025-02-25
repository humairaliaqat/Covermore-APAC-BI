USE [db-au-workspace]
GO
/****** Object:  View [dbo].[clmClaimIncurredTags_KLPAYMENTS]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[clmClaimIncurredTags_KLPAYMENTS] as
select 
    AlphaCode,
    PolicyNumber,
    ClaimNo,
    EventID,
    SectionID,
    IssueDate,
    IssueMonth,
    IssueQuarter,
    LossDate,
    LossMonth,
    LossQuarter,
    ReceiptDate,
    ReceiptMonth,
    ReceiptQuarter,
    SectionDate,
    SectionMonth,
    SectionQuarter,
    TriangleDate,
    TriangleMonth,
    TriangleQuarter,
    GroupName,
    BenefitCategory,
    EstimateMovement,
    PaymentMovement,
    IncurredMovement,
    SectionType,
    MovementType,
    CloseType,
    FixType,
    r.Estimate,
    r.Payment,
    r.Incurred
from
    [db-au-workspace]..clmClaimIncurredTags_raw2 t
    outer apply
    (
        select 
            sum(EstimateMovement) Estimate, 
            sum(PaymentMovement) Payment, 
            sum(IncurredMovement) Incurred
        from
            [db-au-workspace]..clmClaimIncurredTags_raw2 r
        where
            r.ClaimNo = t.ClaimNo and
            r.SectionID = t.SectionID and
            r.CumulativeTime <= t.CumulativeTime
    ) r

GO
