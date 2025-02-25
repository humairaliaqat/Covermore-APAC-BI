USE [db-au-stage]
GO
/****** Object:  View [dbo].[tmp_topic]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[tmp_topic] as
select --top 100 
    ClaimKey,
    m.Country,
    d.SubContinent,
    d.Continent,
    case
        when Form = 'lost' then 'lost item'
        when Form = 'bag' then 'lost item'
        when Form = 'relative' then 'relative''s health'
        when Form = 'associate' then 'relative''s health'
        when Form = 'partner' then 'relative''s health'
        else Form
    end Form,
    Sementity,
    Relevance,
    BenefitGroup,
    ClaimCost
from
    (
    select 
        ct.ClaimKey,
        cf.EventCountryName Country,
        json_value(r.value, '$.form') Form,
        json_value(r.value, '$.sementity.type') Sementity,
        json_value(r.value, '$.relevance') Relevance,
        isnull(csi.ClaimCost, 0) ClaimCost,
        BenefitGroup
    from
        [db-au-cmdwh]..clmClaimTags ct with(nolock)
        cross apply openjson(ct.ClassificationText, '$.concept_list') r
        inner join [db-au-cmdwh]..clmClaimFlags cf with(nolock) on
            cf.ClaimKey = ct.ClaimKey
        inner join [db-au-cmdwh]..clmSection cs  with(nolock) on
            cs.ClaimKey = cf.ClaimKey
        outer apply
        (
            select 
                sum(csi.IncurredDelta) ClaimCost
            from
                [db-au-cmdwh]..vclmClaimSectionIncurred csi with(nolock)
            where
                csi.SectionKey = cs.SectionKey
        ) csi
        outer apply
        (
            select top 1 
                cb.ActuarialBenefitGroup BenefitGroup
            from
                [db-au-cmdwh]..vclmBenefitCategory cb with(nolock)
            where
                cb.BenefitSectionKey = cs.BenefitSectionKey
        ) cb
    where
        Classification = 'TOPICS' and
        try_convert(int, json_value(r.value, '$.relevance')) >= 30
    ) t
    cross apply
    (
        select
            case
                when Country = 'ANTARTICA' then 'Antarctica'
                when Country = 'ANTILLES, NETHERLANDS' then 'Netherlands Antilles'
                when Country = 'RUSSIAN STATES' then 'Russia'
                when Country = 'BURMA' then 'Myanmar'
                when Country = 'SOUTH WEST PACIFIC' then 'South West Pacific Cruise'
                when Country = 'TIBET' then 'Nepal'
                when Country = 'CARIBBEAN' then 'Cruise- Caribbean/Mexico'
                when Country = 'SYRIAN ARAB REPUBLIC' then 'Syria'
                when Country = 'LORD HOWE ISLAND' then 'Australia'
                when Country = 'HAWAII' then 'United States of America'
                when Country = 'URAGUAY' then 'Uruguay'
                when Country = 'ANGORA' then 'Angola'
                else Country
            end Country
    ) m
    outer apply
    (
        select top 1 
            d.Continent,
            d.SubContinent
        from
            [db-au-star]..dimDestination d
        where
            d.Destination = m.Country
    ) d
where
    Form not in
    --stop words
    (
        'place',
        'policy',
        'politics',
        'left',
        'right',
        'doctor'
    )
GO
