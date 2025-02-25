USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vCorporateStampDuty]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vCorporateStampDuty] 
as
select 
    q.QuoteKey,
    t.TaxKey,
    dsd.Rate DomesticStampDutyRate,
    dsd.RateExSD DomesticStampDutyOnPremiumExSDRate,
    isd.Rate InternationalStampDutyRate,
    isd.RateExSD InternationalStampDutyOnPremiumExSDRate,
    isnull(
        (UWSaleExGST - (DomPremIncGST - GSTGross) - IntStamp) * isd.RateExSD,
        t.IntStamp
    ) CalculatedInternationalStampDuty,
    isnull(
        ((DomPremIncGST - GSTGross) - DomStamp + GSTGross) * dsd.RateExSD,
        t.DomStamp
    ) CalculatedDomesticStampDuty
from
    [db-au-cmdwh]..corpQuotes q
    inner join [db-au-cmdwh]..corpTaxes t on
        t.QuoteKey = q.QuoteKey
    left join [db-au-cmdwh]..Agency a on
        a.AgencyKey = q.AgencyKey and
        a.AgencyStatus = 'Current'
    inner join [db-au-cmdwh]..corpCompany c on
        c.CompanyKey = q.CompanyKey
    outer apply
    (
        select top 1 
            Rate,
            RateExSD
        from
            [db-au-cmdwh]..usrStampDuty sd
        where
            sd.Country = q.CountryKey and
            sd.State = isnull(c.State, a.AgencyGroupState) and
            sd.AreaType = 'Domestic' and
            sd.StartDate <= q.IssuedDate and
            (
                sd.EndDate is null or
                sd.EndDate >= q.IssuedDate
            )
        order by
            ID desc
    ) dsd
    outer apply
    (
        select top 1 
            Rate,
            RateExSD
        from
            [db-au-cmdwh]..usrStampDuty sd
        where
            sd.Country = q.CountryKey and
            sd.State = isnull(c.State, a.AgencyGroupState) and
            sd.AreaType = 'International' and
            sd.StartDate <= q.IssuedDate and
            (
                sd.EndDate is null or
                sd.EndDate >= q.IssuedDate
            )
        order by
            ID desc
    ) isd


GO
