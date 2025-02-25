USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vPolicyStampDuty]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vPolicyStampDuty] 
as
select 
    p.PolicyKey,
    sd.Rate StampDutyRate,
    sd.RateExSD StampDutyOnPremiumExSDRate,
    CalculatedGST,
    isnull(
        (ActualGrossPremiumAfterDiscount - StampDuty + CalculatedGST) * RateExSD,
        p.StampDuty
    ) CalculatedStampDuty
from
    Policy p
    inner join Agency a on
        a.AgencyKey = p.AgencyKey and
        a.AgencyStatus = 'Current'
    cross apply
    (
        select
            case
                when AreaType = 'Domestic (Inbound)' then 0
                when p.CompanyKey = 'CM' then GSTonGrossPremium
                when AreaType = 'International' then 0
                else 0.1 * (ActualGrossPremiumAfterDiscount - StampDuty)
            end CalculatedGST
    ) gst
    outer apply
    (
        select top 1 
            AddressState
        from
            Customer c
        where
            c.CustomerKey = p.CustomerKey and
            c.isPrimary = 1
        order by
            CustomerID
    ) c
    outer apply
    (
        select top 1 
            Rate,
            RateExSD
        from
            usrStampDuty sd
        where
            sd.Country = p.CountryKey and
            sd.State = isnull(c.AddressState, a.AgencyGroupState) and
            sd.AreaType = p.AreaType and
            sd.StartDate <= p.IssuedDate and
            (
                sd.EndDate is null or
                sd.EndDate >= p.IssuedDate
            )
        order by
            ID desc
    ) sd

GO
