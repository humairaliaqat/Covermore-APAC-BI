USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vclmClaimCombinedEstimate]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vclmClaimCombinedEstimate] 
as
with cte_incurred as
(
    select 
        ClaimKey,
        IncurredDate,
        sum(EstimateMovement) EstimateMovement,
        sum(CCEstimateMovement) CCEstimateMovement,
        sum(PaymentMovement) PaymentMovement
    from
        (
            select 
                ClaimKey,
                EstimateDate IncurredDate,
                EstimateMovement,
                0 CCEstimateMovement,
                0 PaymentMovement
            from
                clmClaimEstimateMovement

            union all
                
            select 
                ClaimKey,
                convert(date, CCEstimateDate),
                0 EstimateMovement,
                CCEstimatMovement,
                0 PaymentMovement
            from
                clmClaimCCEstimateMovement

            union all

            select 
                ClaimKey,
                PaymentDate,
                0 EstimateMovement,
                0 CCEstimateMovement,
                PaymentMovement + RecoveryPaymentMovement PaymentMovement
            from
                clmClaimPaymentMovement
        ) ci
    group by
        ClaimKey,
        IncurredDate
)
select 
    ClaimKey,
    IncurredDate,
    datediff(d, isnull(PreviousDate, IncurredDate), IncurredDate) IncurredAge,
    CCEstimate,
    Estimate,
    Paid,
    Estimate + Paid Inccured,
    CCEstimateMovement CCEstimateDelta,
    EstimateMovement EstimateDelta,
    PaymentMovement PaymentDelta,
    EstimateMovement + PaymentMovement IncurredDelta
from
    cte_incurred t
    cross apply
    (
        select
            sum(EstimateMovement) Estimate,
            sum(CCEstimateMovement) CCEstimate,
            sum(PaymentMovement) Paid
        from
            cte_incurred r
        where
            r.ClaimKey = t.ClaimKey and
            r.IncurredDate <= t.IncurredDate 
    ) r
    outer apply
    (
        select 
            max(IncurredDate) PreviousDate
        from
            cte_incurred r
        where
            r.ClaimKey = t.ClaimKey and
            r.IncurredDate < t.IncurredDate 
    ) pd
GO
