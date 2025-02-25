USE [db-au-workspace]
GO
/****** Object:  View [dbo].[fActuarialClaimCount]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[fActuarialClaimCount] as
select 
    AccountingDate,
    UnderwritingPeriod,
    DevelopmentDays,
    DomainSK,
    OutletSK,
    AreaSK,
    ProductSK,
    ClaimSK,
    ClaimEventSK,
    BenefitSK,
    SectionKey,
    [Transaction],
    TransactionType,
    TransactionStatus
from
    fActuarialClaimPayment

union

select
    AccountingDate,
    UnderwritingPeriod,
    DevelopmentDays,
    DomainSK,
    OutletSK,
    AreaSK,
    ProductSK,
    ClaimSK,
    ClaimEventSK,
    BenefitSK,
    SectionKey,
    [Transaction],
    TransactionType,
    TransactionStatus
from
    fActuarialClaimEstimate
GO
