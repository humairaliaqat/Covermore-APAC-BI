USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vclmClaimSectionIncurredUTC]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vclmClaimSectionIncurredUTC]
as
with cte_incurred as
(
    select 
        ClaimKey,
        SectionKey,
        IncurredDate,
        sum(EstimateMovement) EstimateMovement,
        sum(PaymentMovement) PaymentMovement,
        sum(EstimateMovement + PaymentMovement) IncurredMovement,
        sum(Redundant) RedundantMovements,
        sum(New) NewMovements,
        sum(Reopened) ReopenedMovements
    from
        (
            select
                case
                    when EstimateCategory = 'Redundant' and EstimateMovement <> 0 then 1
                    when EstimateCategory = 'Deleted' and EstimateMovement <> 0 then 1
                    else 0
                end Redundant,
                case
                    when EstimateCategory = 'New' and EstimateMovement <> 0 then 1
                    else 0
                end New,
                case
                    when EstimateCategory = 'Reopened' and EstimateMovement <> 0 then 1
                    when EstimateCategory = 'Progress on Nil' and EstimateMovement > 0 then 1
                    else 0
                end Reopened,
                ClaimKey,
                SectionKey,
                EstimateDateUTC IncurredDate,
                EstimateMovement,
                0 PaymentMovement
            from
                clmClaimEstimateMovement

            union all
                
            select 
                0 Redundant,
                0 New,
                0 Reopened,
                ClaimKey,
                SectionKey,
                PaymentDateUTC,
                0 EstimateMovement,
                PaymentMovement + RecoveryPaymentMovement PaymentMovement
            from
                clmClaimPaymentMovement
                
        ) ci
    group by
        ClaimKey,
        SectionKey,
        IncurredDate
),
cte_inccuredbydate as
(
    select 
        ClaimKey,
        SectionKey,
        cb.Bucket,
        IncurredDate,
        datediff(d, isnull(PreviousDate, IncurredDate), IncurredDate) IncurredAge,
        Estimate,
        Paid,
        IncurredValue,
        Estimate - EstimateMovement PreviousEstimate,
        Paid - PaymentMovement PreviousPaid,
        IncurredValue - IncurredMovement PreviousIncurred,
        EstimateMovement EstimateDelta,
        PaymentMovement PaymentDelta,
        IncurredMovement IncurredDelta,
        RedundantMovements,
        NewMovements,
        ReopenedMovements
    from
        cte_incurred t
        cross apply
        (
            select
                sum(EstimateMovement) Estimate,
                sum(PaymentMovement) Paid,
                sum(IncurredMovement) IncurredValue
            from
                cte_incurred r
            where
                r.ClaimKey = t.ClaimKey and
                r.SectionKey = t.SectionKey and
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
                r.SectionKey = t.SectionKey and
                r.IncurredDate < t.IncurredDate 
        ) pd
        outer apply
        (
            select
                case
                    when 
                        exists
                        (
                            select 
                                null
                            from
                                [db-au-cmdwh]..clmSection cs
                                inner join [db-au-cmdwh]..clmEvent ce on
                                    ce.EventKey = cs.EventKey
                                inner join [db-au-cmdwh]..clmCatastrophe cc on
                                    cc.CountryKey = ce.CountryKey and
                                    cc.CatastropheCode = ce.CatastropheCode
                            where
                                cs.SectionKey = t.SectionKey and
                                isnull(ce.CatastropheCode, '') not in ('', 'CC', 'REC')
                        ) then 'CAT'
                    else 'Underlying'
                end Bucket
        ) cb
)
select 
    ClaimKey,
    SectionKey,
    case
        when Bucket = 'CAT' then 'CAT'
        when
            exists
            (
                select 
                    null
                from
                    cte_inccuredbydate icd
                where
                    icd.ClaimKey = t.ClaimKey and
                    icd.SectionKey = t.SectionKey and
                    (
                        (
                            icd.ClaimKey not like 'UK%' and
                            icd.IncurredValue > 15000
                        ) or
                        (
                            icd.ClaimKey like 'UK%' and
                            icd.IncurredValue > 10000
                        ) 
                    )
            ) then 'Large'
            else Bucket
    end Bucket,
    IncurredDate IncurredDateUTC,
    IncurredAge,
    Estimate,
    Paid,
    IncurredValue,
    PreviousEstimate,
    PreviousPaid,
    PreviousIncurred,
    EstimateDelta,
    PaymentDelta,
    IncurredDelta,
    RedundantMovements,
    NewMovements,
    ReopenedMovements
from
    cte_inccuredbydate t










GO
