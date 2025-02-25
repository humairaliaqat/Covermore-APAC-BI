USE [db-au-star]
GO
/****** Object:  View [dbo].[v_ic_dimDemography]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[v_ic_dimDemography] as
select --top 100
    PolicySK,
    CustomerID, 
    case when isnull(RiskProfile, '') = '' then 'UNKNOWN' else RiskProfile end as RiskProfile, 
    case when isnull(AgeGroup, '') = '' then 'UNKNOWN' else AgeGroup end as AgeGroup, 
    case when isnull(ProductPreference, '') = '' then 'UNKNOWN' else ProductPreference end as ProductPreference, 
    case when isnull(BrandAffiliation, '') = '' then 'UNKNOWN' else BrandAffiliation end as TravelPattern, 
    case when isnull(TravelGroup, '') = '' then 'UNKNOWN' else TravelGroup end as TravelGroup, 
    case 
        when isnull(usp.suburb, '') <> '' then isnull(usp.suburb, '')
        when isnull(dd.Suburb, '') = '' then 'UNKNOWN' 
        else dd.Suburb 
    end as Suburb, 
    case
        when isnull(usp.[State], '') = 'N/A' and usp.CountryDomain = 'NZ' then 'NEW ZEALAND'
        when isnull(usp.[State], '') <> '' then isnull(usp.[State], '')
        when isnull(dd.[State], '') = '' then 'UNKNOWN' 
        else dd.State 
    end as [State]
from
    dimDemography dd with(nolock)
    outer apply
    (
        select top 1 
            usp.Suburb,
            usp.State,
            usp.CountryDomain
        from
            [db-au-cmdwh]..usrSuburbProfile usp with(nolock)
        where
            usp.PostCode = dd.PostCode
        order by
            case
                when usp.Suburb = dd.Suburb then 1
                else 9
            end
    ) usp
where
    PolicySK is not null

union all

select 
    BIRowID * -10 PolicySK,
    -1 CustomerID,
    'UNKNOWN' RiskProfile, 
    'UNKNOWN' AgeGroup, 
    'UNKNOWN' ProductPreference, 
    'UNKNOWN' TravelPattern, 
    'UNKNOWN' TravelGroup, 
    'UNKNOWN' Suburb, 
    'UNKNOWN' [State]
from
    v_ic_Corporate


GO
