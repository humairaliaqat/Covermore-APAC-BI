USE [db-au-workspace]
GO
/****** Object:  View [dbo].[fActuarialClaimEstimate]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[fActuarialClaimEstimate] as
select --top 1000 
    f.MovementDate AccountingDate,
    convert(date, cl.PolicyIssuedDate) UnderwritingPeriod,
    case
        when convert(bigint, datediff(day, cl.PolicyIssuedDate, f.MovementDate)) < 0 then 0
        else convert(bigint, datediff(day, cl.PolicyIssuedDate, f.MovementDate)) 
    end DevelopmentDays,
    DomainSK,
    OutletSK,
    AreaSK,
    ProductSK,
    ClaimSK,
    ClaimEventSK,
    BenefitSK,
    SectionKey,
    'Estimate' [Transaction],
    EstimateGroup TransactionType,
    EstimateCategory TransactionStatus,
    EstimateMovement PaymentEstimate,
    0 RecoveryEstimate
from
    [db-au-star]..factClaimIncurredMovement f
    inner join [db-au-cmdwh]..clmClaim cl on
        cl.ClaimKey = f.ClaimKey
where
    PaymentKey is null and
    EstimateGroup <> 'Unknown'

GO
