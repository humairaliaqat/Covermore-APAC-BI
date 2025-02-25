USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vpenPolicyStampDuty_test]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vpenPolicyStampDuty_test]
as
select 
    pt.PolicyTransactionKey,
    sd.Rate StampDutyRate,
    sd.RateExSD StampDutyOnPremiumExSDRate,
    CalculatedGST,
    isnull(
        (pp.[Sell Price (excl GST)] - pp.[Stamp Duty on Sell Price] + CalculatedGST) * RateExSD,
        pp.[Stamp Duty on Sell Price]
    ) CalculatedStampDuty
from
   [db-au-cmdwh].dbo.penPolicyTransSummary pt
    inner join  [db-au-cmdwh].dbo.penPolicy p on
        p.PolicyKey = pt.PolicyKey
    inner join  [db-au-cmdwh].dbo.vPenguinPolicyPremiums pp on 
        pp.PolicyTransactionKey = pt.PolicyTransactionKey
    inner join  [db-au-workspace].dbo.penOutlet_test o on
        o.OutletAlphaKey = pt.OutletAlphaKey and
        o.OutletStatus = 'Current'
    cross apply
    (
        select
            case
                when p.AreaType = 'Domestic (Inbound)' then 0
                when p.CompanyKey = 'CM' then pp.[GST on Sell Price]
                when p.AreaType = 'International' then 0
                else 0.1 * pp.[Sell Price] - pp.[Stamp Duty on Sell Price]
            end CalculatedGST
    ) gst
    outer apply
    (
        select top 1 
            ptv.State AddressState
        from
             [db-au-cmdwh].dbo.penPolicyTraveller ptv
        where
            ptv.PolicyKey = p.PolicyKey and
            ptv.isPrimary = 1
        --order by
        --    ptv.PolicyTravellerID
    ) c
    outer apply
    (
        select top 1 
            Rate,
            RateExSD
        from
             [db-au-cmdwh].dbo.usrStampDuty sd
        where
            sd.Country = p.CountryKey and
            sd.State = isnull(c.AddressState, o.StateSalesArea) and
            sd.AreaType = p.AreaType and
            sd.StartDate <= pt.IssueDate and
            (
                sd.EndDate is null or
                sd.EndDate >= pt.IssueDate
            )
        --order by
        --    StartDate desc
    ) sd


GO
