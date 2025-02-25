USE [db-au-workspace]
GO
/****** Object:  View [dbo].[ClaimTopicCloud]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[ClaimTopicCloud]
as
select --top 1000
    cl.ClaimKey,
    cl.ReceivedDate,
    t.Topic,
    ce.Peril,
    ce.PerilCode,
    --cb.BenefitGroup,
    m.Country,
    d.SubContinent,
    d.Continent,
    case
        when ci.ClaimCost = 0 then null
        else ci.ClaimCost
    end ClaimCost,
    case
        when rpt.RepatClaimCost = 0 then null
        else rpt.RepatClaimCost
    end RepatClaimCost,
    case
        when hos.HospitalCost = 0 then null
        else hos.HospitalCost
    end HospitalCost,
    case
        when cx.CarrierCost = 0 then null
        else cx.CarrierCost
    end CarrierCost
from
    [db-au-cmdwh]..clmClaim cl with(nolock)
    inner join [db-au-cmdwh]..clmClaimFlags cf with(nolock) on
        cf.ClaimKey = cl.ClaimKey
    cross apply
    (
        select 
            sum(ci.IncurredDelta) ClaimCost,
            sum(ci.EstimateDelta) Estimate
        from
            [db-au-cmdwh].dbo.vclmClaimIncurred ci with(nolock)
        where
            ci.ClaimKey = cl.ClaimKey
    ) ci
    cross apply
    (
        select
            case
                when cf.EventCountryName = 'ANTARTICA' then 'Antarctica'
                when cf.EventCountryName = 'ANTILLES, NETHERLANDS' then 'Netherlands Antilles'
                when cf.EventCountryName = 'RUSSIAN STATES' then 'Russia'
                when cf.EventCountryName = 'BURMA' then 'Myanmar'
                when cf.EventCountryName = 'SOUTH WEST PACIFIC' then 'South West Pacific Cruise'
                when cf.EventCountryName = 'TIBET' then 'Nepal'
                when cf.EventCountryName = 'CARIBBEAN' then 'Cruise- Caribbean/Mexico'
                when cf.EventCountryName = 'SYRIAN ARAB REPUBLIC' then 'Syria'
                when cf.EventCountryName = 'LORD HOWE ISLAND' then 'Australia'
                when cf.EventCountryName = 'HAWAII' then 'United States of America'
                when cf.EventCountryName = 'URAGUAY' then 'Uruguay'
                when cf.EventCountryName = 'ANGORA' then 'Angola'
                else cf.EventCountryName
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
    inner join [db-au-workspace]..ClaimTopics ct on
        ct.ClaimKey = cl.ClaimKey
    cross apply
    (
        select
            case
                when ct.[Form] = 'housing' then 'accomodation'
                when ct.[Form] = 'ash' then 'natural disaster'
                when ct.[Form] = 'volcanic' then 'natural disaster'
                when ct.[Form] = 'volcano' then 'natural disaster'
                when ct.[Form] = 'eruption' then 'natural disaster'
                when ct.[Form] = 'sotrm' then 'natural disaster'
                when ct.[Form] = 'quake' then 'natural disaster'
                when ct.[Form] = 'natural catastrophe' then 'natural disaster'
                when ct.[Form] = 'lost' then 'lost item'
                when ct.[Form] = 'bag' then 'lost item'
                when ct.[Form] = 'relative' then 'relative''s health'
                when ct.[Form] = 'associate' then 'relative''s health'
                when ct.[Form] = 'partner' then 'relative''s health'
                when ct.[Form] = 'gastroenteritis' then 'gastro'
                else ct.[Form]
            end Topic
    ) t
    --inner join [db-au-cmdwh]..clmSection cs  with(nolock) on
    --    cs.ClaimKey = cl.ClaimKey
    --outer apply
    --(
    --    select top 1 
    --        cb.ActuarialBenefitGroup BenefitGroup
    --    from
    --        [db-au-cmdwh]..vclmBenefitCategory cb with(nolock)
    --    where
    --        cb.BenefitSectionKey = cs.BenefitSectionKey
    --) cb
    cross apply
    (
        select top 1
            ce.PerilDesc Peril,
            ce.PerilCode,
            ce.CatastropheCode
        from
            [db-au-cmdwh]..clmEvent ce with(nolock)
        where
            ce.ClaimKey = cl.ClaimKey
    ) ce
    --outer apply
    --(
    --    select 
    --        sum(csi.IncurredDelta) ClaimCost
    --    from
    --        [db-au-cmdwh]..vclmClaimSectionIncurred csi with(nolock)
    --    where
    --        csi.SectionKey = cs.SectionKey
    --) csi
    outer apply
    (
        select 
            sum(cp.PaymentAmount) RepatClaimCost
        from
            [db-au-cmdwh].dbo.clmPayment cp with(nolock)
            inner join [db-au-cmdwh].dbo.clmName cn with(nolock) on
                cn.NameKey = cp.PayeeKey
            inner join [db-au-cmdwh].dbo.clmSection cs with(nolock) on
                cs.SectionKey = cp.SectionKey
            inner join [db-au-cmdwh].dbo.vclmBenefitCategory cb with(nolock) on
                cb.BenefitSectionKey = cs.BenefitSectionKey
        where
            cp.isDeleted = 0 and
            cs.isDeleted = 0 and
            cb.ActuarialBenefitGroup = 'Additional Expenses' and
            cp.ClaimKey = cl.ClaimKey and
            cp.PaymentStatus in ('APPR', 'PAID') and
            cn.isThirdParty = 1 and
            (
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%corporate traveller%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%care%flight%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%life%flight%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%evac%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%rescue%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%jets%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%a-jet%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%air%ambulan%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%criti%air%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%medic%air%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%air%medic%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%air%response%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%0763325%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%assist%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%travmin%bangkok%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%siam%flying%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%mso%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%life%support%'
            )
    ) rpt
    outer apply
    (
        select 
            sum(cp.PaymentAmount) HospitalCost
        from
            [db-au-cmdwh].dbo.clmPayment cp with(nolock)
            inner join [db-au-cmdwh].dbo.clmName cn with(nolock) on
                cn.NameKey = cp.PayeeKey
            inner join [db-au-cmdwh].dbo.clmSection cs with(nolock) on
                cs.SectionKey = cp.SectionKey
            inner join [db-au-cmdwh].dbo.vclmBenefitCategory cb with(nolock) on
                cb.BenefitSectionKey = cs.BenefitSectionKey
        where
            cp.isDeleted = 0 and
            cs.isDeleted = 0 and
            cb.ActuarialBenefitGroup = 'Medical' and
            cp.ClaimKey = cl.ClaimKey and
            cp.PaymentStatus in ('APPR', 'PAID') and
            cn.isThirdParty = 1 and
            (
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%hospital%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%health%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%medic%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%clinic%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%gmmi%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%gem%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%travmin%bangkok%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%samitivej%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%assist%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%mso%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%bumrungrad%' or
                (isnull(cn.Surname, '') + isnull(cn.BusinessName, '')) like '%emergency%'
            )
    ) hos
    outer apply
    (
        select 
            sum(cp.PaymentAmount) CarrierCost
        from
            [db-au-cmdwh].dbo.clmPayment cp with(nolock)
            inner join [db-au-cmdwh].dbo.clmName cn with(nolock) on
                cn.NameKey = cp.PayeeKey
            inner join [db-au-cmdwh].dbo.clmSection cs with(nolock) on
                cs.SectionKey = cp.SectionKey
            inner join [db-au-cmdwh].dbo.vclmBenefitCategory cb with(nolock) on
                cb.BenefitSectionKey = cs.BenefitSectionKey
        where
            cp.isDeleted = 0 and
            cs.isDeleted = 0 and
            ce.PerilCode = 'CCD' and
            cb.ActuarialBenefitGroup = 'Cancellation' and
            cp.ClaimKey = cl.ClaimKey and
            cp.PaymentStatus in ('APPR', 'PAID')
    ) cx
where
    ci.Estimate = 0 and

    --ce.PerilCode = 'MCA' and

    ct.[Form] not in
    --stop words
    (
        '',
        'place',
        'policy',
        'politics',
        'left',
        'right',
        'doctor',
        'home',
        '$',
        'berm',

        'carrier',
        'lost',
        'relative',
        'associate',
        'partner',
        'injury',
        'electronics',
        ''
    )
--group by
--    t.Topic
--order by
--     2 desc
GO
