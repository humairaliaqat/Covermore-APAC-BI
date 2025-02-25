USE [db-au-star]
GO
/****** Object:  View [dbo].[v_ic_factClaimIncurred]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[v_ic_factClaimIncurred] 
as
select 
    isnull(pt.AgeBandSK, -1) AgeBandSK,
    isnull(pt.AreaSK, -1) AreaSK,
    isnull(pt.ConsultantSK, -1) ConsultantSK,
    
    isnull(dd.Date_SK, -1) DateSK,
    isnull(pt.DestinationSK, -1) DestinationSK,
    isnull(dm.DomainSK, -1) DomainSK,
    isnull(pt.DurationSK, -1) DurationSK,
    isnull(pt.LeadTimeSK, -1) LeadTimeSK,
    isnull(pt.OutletSK, -1) OutletSK,

    coalesce(lp.PolicySK, cp.PolicySK, -1) PolicySK,

    isnull(pt.ProductSK, -1) ProductSK,

    isnull(pt.DepartureDateSK, '2000-01-01') DepartureDateSK,
    isnull(pt.ReturnDateSK, '2000-01-01') ReturnDateSK,
    isnull(pt.IssueDateSK, '2000-01-01') IssueDateSK,
    isnull(pt.UnderwriterCode, 'OTHER') UnderwriterCode,

    convert(date, cim.IncurredTime) IncurredDate,
    null UnderwritingDate,
    0 DevelopmentDay, 
    0 LossDevelopmentDay,

    isnull(dcl.ClaimSK, -1) ClaimSK, 
    null ClaimEventSK, 
    null BenefitSK, 
    null ClaimKey, 

    null SectionKey, 
    null ClaimSizeType,
    null EstimateGroup, 
    null EstimateCategory, 
    cim.EstimateMovement, 
    cim.PaymentMovement,
    cim.RecoveryMovement,
    cim.EstimateMovement + cim.PaymentMovement + cim.RecoveryMovement IncurredMovement,
    
    cim.NetPaymentMovement,
    cim.NetRecoveryMovement,
    cim.NetPaymentMovement + cim.NetRecoveryMovement NetPaymentMovementIncRecoveries,
    cim.NetPaymentMovement + cim.NetRecoveryMovement + cim.EstimateMovement NetIncurredMovement,
    cim.NetRealRecoveryMovement,
    cim.NetApprovedPaymentMovement

from
    [db-au-actuary].ws.ClaimIncurredMovement cim with(nolock)
    outer apply
    (
        select top 1 
            dd.Date_SK
        from
            Dim_Date dd with(nolock)
        where
            dd.[Date] = convert(date, cim.IncurredTime)
    ) dd
    outer apply
    (
        select top 1 
            dm.DomainSK
        from
            dimDomain dm with(nolock)
        where
            dm.CountryCode = cim.[Domain Country]
    ) dm
    outer apply
    (
        select top 1 
            PolicySK
        from
            [db-au-star].dbo.dimPolicy dp with(nolock)
        where
            dp.PolicyNumber = cim.PolicyNo and
            dp.Country = cim.[Domain Country]
    ) lp
    outer apply
    (
        select top 1 
            PolicySK
        from
            [db-au-star].dbo.v_ic_Corporate cp with(nolock)
        where
            cim.ClaimProduct = 'CMC' and
            cp.Country = cim.[Domain Country] and
            cp.PolicyNumber = cim.PolicyNo
    ) cp
    outer apply
    (
        select top 1 
            AgeBandSK,
            AreaSK,
            ConsultantSK,
    
            DestinationSK,
            DurationSK,
            LeadTimeSK,
            OutletSK,
            ProductSK,
            
            DepartureDateSK,
            ReturnDateSK,
            IssueDateSK,
            UnderwriterCode
        from
            [db-au-star].[dbo].[v_ic_factPolicyTransaction] pt with(nolock)
        where
            pt.PolicySK = coalesce(lp.PolicySK, cp.PolicySK, -1)
    ) pt
    outer apply
    (
        select top 1
            dcl.ClaimSK
        from
            [db-au-star].[dbo].v_ic_dimClaim dcl
        where
            dcl.ClaimKey = cim.ClaimKey
    ) dcl




GO
