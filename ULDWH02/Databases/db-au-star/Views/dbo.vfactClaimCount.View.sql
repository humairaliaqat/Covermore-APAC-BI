USE [db-au-star]
GO
/****** Object:  View [dbo].[vfactClaimCount]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vfactClaimCount] as
select --top 1000
    BIRowID, 
    case
        when AccountingDate < '2001-01-01' then '2000-01-01'
        else AccountingDate
    end AccountingDate,
    case
        when UnderwritingDate < '2001-01-01' then '2000-01-01'
        else UnderwritingDate
    end UnderwritingDate,
    case
        when DevelopmentDay > 11688 then 11688
        else DevelopmentDay
    end DevelopmentDay,
    LossDevelopmentDay,
    DomainSK, 
    OutletSK, 
    AreaSK, 
    ProductSK, 
    ClaimSK, 
    ClaimEventSK, 
    BenefitSK, 
    ClaimKey, 
    PolicyTransactionKey, 
    SectionKey,
    ClaimSizeType,
    CreateBatchID,
    isnull(AgeBandSK, -1) AgeBandSK,
    isnull(DurationSK, -1) DurationSK,
    isnull(PolicySK, -1) PolicySK,
    isnull(DestinationSK, -1) DestinationSK
from
    factClaimCount t
    outer apply
    (
        select top 1
            AgeBandSK,
            DurationSK,
            PolicySK,
            DestinationSK
        from
            factPolicyTransaction pt
        where
            pt.PolicyTransactionKey = t.PolicyTransactionKey
    ) pt
    outer apply
    (
        select top 1 
            EventDate,
            RegisterDate
        from
            dimClaim dcl
        where
            dcl.ClaimKey = t.ClaimKey
    ) dcl
    outer apply
    (
        select
            convert(
                bigint,
                case
                    when datediff(day, convert(date, isnull(dcl.EventDate, dcl.RegisterDate)), t.AccountingDate) < 0 then 0
                    when datediff(day, convert(date, isnull(dcl.EventDate, dcl.RegisterDate)), t.AccountingDate) > 11688 then 11688
                    else datediff(day, convert(date, isnull(dcl.EventDate, dcl.RegisterDate)), t.AccountingDate)
                end 
            ) LossDevelopmentDay
    ) ldd

GO
