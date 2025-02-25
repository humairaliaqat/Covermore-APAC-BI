USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vEnterpriseProfile]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vEnterpriseProfile]
as
select 
    ec.CustomerID,
    ec.CustomerName,
    ec.MaritalStatus,
    ec.isDeceased,
    ec.Gender,
    ec.CurrentEmail,
    isnull(datename(day, ec.DOB) + ' ' + datename(month, ec.DOB) + ' ' + datename(year, ec.DOB), '') DOB,
    isnull(ee.EmailAddress, '') EmailAddress,
    ep.PhoneID,
    case
        when isnull(ep.PhoneNumber, '') <> '' and isnull(ep.PhoneNumber, '') = CurrentContact then isnull(ep.PhoneNumber, '') + ' (primary)'
        else isnull(ep.PhoneNumber, '')
    end PhoneNumber,
    ea.MinDate,
    ea.MaxDate,
    fa.FormattedAddress Address,
    isnull(ea.Country, '') Country,
    isnull(emc.HasEMC, 0) HasEMC,
    --'No comment' Comment,
    isnull(ec.ClaimScore, ec.PrimaryScore) - isnull(bl.BlockScore, 0) PrimaryScore,
    isnull(ec.SecondarySCore, 0) SecondaryScore,
    isnull(ec.ClaimScore, ec.PrimaryScore) + isnull(ec.SecondarySCore, 0) - isnull(bl.BlockScore, 0) Score,
    isnull(bl.BlockScore, 0) BlockScore,
    case
        when isnull(bl.BlockScore, 0) > 0 then 'BLOCKED! ' + char(10) + char(10)
        else ''
    end +
    case
        when ec.ClaimScore >= 3000 then 'Very high risk' + char(10)
        when ec.ClaimScore >= 500 then 'High risk' + char(10)
        when ec.ClaimScore >= 10 then 'Medium risk' + char(10)

        when ec.PrimaryScore - isnull(bl.BlockScore, 0) >= 5000 then 'Very high risk. ' + char(10)
        when ec.SecondaryScore >= 5000 then 'Very high risk by association. ' + char(10)
        when ec.PrimaryScore - isnull(bl.BlockScore, 0) >= 2000 then 'High risk. ' + char(10)
        when ec.SecondaryScore >= 2000 then 'High risk by association. ' + char(10)
        when ec.PrimaryScore - isnull(bl.BlockScore, 0) > 750 then 'Medium risk. ' + char(10)
        when ec.SecondaryScore > 750 then 'Medium risk by association. ' + char(10)
        else ''--'Low Risk'
    end +
    --coalesce(bl.Reason, fl.Comment, '') + char(10) + 
    isnull(bl.Reason, '') + char(10) + 
    case
        when bl.Reason is not null then ''
        else
            --isnull
            --(
            --    'Last 5 high risk claims: ' + char(10) +
            --    (
            --        select top 5
            --            convert(varchar, ClaimNo) + ' (' + Classification + '): ' + replace(Details, char(10), ' ') + char(10)
            --        from
            --            vEnterpriseClaimClassification
            --        where
            --            ClaimKey in
            --            (
            --                select 
            --                    ClaimKey
            --                from
            --                    entCustomer ec
            --                    inner join entPolicy ep on
            --                        ep.CustomerID = ec.CustomerID
            --                where
            --                    --ec.CustomerID = 1209131
            --                    ec.CUstomerName = 'katrine hermansen'
            --            ) and
            --            Classification in ('Red', 'Amber', 'Yelow')
            --        order by
            --            case
            --                when Classification = 'Red' then 1
            --                when Classification = 'Amber' then 2
            --                when Classification = 'Yellow' then 3
            --                else 4
            --            end,
            --            ClaimNo desc
            --        for xml path ('')
            --    ),
            --    ''
            --)
            isnull
            (
                (
                    select 
                        convert(varchar, count(ClaimNo)) + ' category ' + Classification + ' claims.' + char(10)
                    from
                        vEnterpriseClaimClassification
                    where
                        ClaimKey in
                        (
                            select 
                                ClaimKey
                            from
                                entPolicy ep
                            where
                                ep.CustomerID = ec.CustomerID
                                --ec.CUstomerName = 'katrine hermansen'
                        ) and
                        Classification in ('Red', 'Amber', 'Yellow')
                    group by
                        Classification
                    order by
                        case
                            when Classification = 'Red' then 1
                            when Classification = 'Amber' then 2
                            when Classification = 'Yellow' then 3
                            else 4
                        end
                    for xml path ('')
                ),
                ''
            )
    end + char(10) +
    case
        when isnull(SanctionScore, 0) < 5 then ''
        when SanctionScore < 10 then 'Low risk Sanction check, matched last name and year of birth'
        when SanctionScore < 15 then 'Low risk Sanction check, matched last name, year and month of birth'
        when SanctionScore < 25 then 'Low risk Sanction check, matched combination of names, within 1 day variance of date of birth'
        when SanctionScore < 30 then 'Medium risk Sanction check, matched last name, same date of birth'
        else 'High risk Sanction check, matched combination of names, same data of birth'
    end Comment
from
    entCustomer ec with(nolock)
    outer apply
    (
        select top 1 
            REASON,
            9001 BlockScore
        from
            entBlacklist bl
        where
            bl.CustomerID = ec.CustomerID
    ) bl
    --outer apply
    --(
    --    select
    --        case
    --            when InvestigationFraudCount > 0 then convert(varchar, InvestigationFraudCount) + ' claims marked as Fraud on investigation.' + char(10)
    --            else ''
    --        end +
    --        case
    --            when InvestigationWithdrawnCount > 0 then convert(varchar, InvestigationWithdrawnCount) + ' claims marked as withdrwan on investigation.' + char(10)
    --            else ''
    --        end +
    --        case
    --            when InvestigationDeniedCount > 0 then convert(varchar, InvestigationDeniedCount) + ' claims denied on investigation.' + char(10)
    --            else ''
    --        end +
    --        case
    --            when InvestigationNoResponseCount > 1 then convert(varchar, InvestigationNoResponseCount) + ' claims unresponsive to investigation.' + char(10)
    --            else ''
    --        end +
    --        case
    --            when MedicalCount > 3 then convert(varchar, MedicalCount) + ' repeat medical claims.' + char(10)
    --            else ''
    --        end +
    --        case
    --            when LocationCount > 4 then convert(varchar, LocationCount) + ' claim(s) in suspicious countries.' + char(10)
    --            else ''
    --        end +
    --        case
    --            when SectionCount > 0 then convert(varchar, SectionCount) + ' accidental death/kidnap/hijackin/personal liability claim(s).' + char(10)
    --            else ''
    --        end +
    --        case
    --            when HighValueCount > 1 then convert(varchar, HighValueCount) + ' high value luggage claim(s).' + char(10)
    --            else ''
    --        end +
    --        case
    --            when MultipleElecCount > 1 then convert(varchar, MultipleElecCount) + ' claim(s) with multiple electronic items.' + char(10)
    --            else ''
    --        end +
    --        case
    --            when ElectronicCount > 2 then convert(varchar, ElectronicCount) + ' claim(s) on electronic items without luggages.' + char(10)
    --            else ''
    --        end +
    --        case
    --            when NoProofCount > 1 then convert(varchar, NoProofCount) + ' loss claim(s) with no proof of purchase.' + char(10)
    --            else ''
    --        end +
    --        case
    --            when NoReportCount > 1 then convert(varchar, NoReportCount) + ' loss claim(s) with no authority reports.' + char(10)
    --            else ''
    --        end +
    --        case
    --            when CrimeCount > 0 then convert(varchar, CrimeCount) + ' crime related loss claim(s).' + char(10)
    --            else ''
    --        end +
    --        '' Comment
    --    from
    --        (
    --            select 
    --                sum(convert(int, MedicalCostFlag)) MedicalCount,
    --                sum(convert(int, LocationRedFlag)) LocationCount,
    --                sum(convert(int, SectionRedFlag)) SectionCount,
    --                sum(convert(int, HighValueLuggageRedFlag)) HighValueCount,
    --                sum(convert(int, MultipleElectronicRedFlag)) MultipleElecCount,
    --                sum(convert(int, OnlyElectronicRedFlag)) ElectronicCount,
    --                sum(convert(int, NoProofRedFlag)) NoProofCount,
    --                sum(convert(int, NoReportRedFlag)) NoReportCount,
    --                sum(convert(int, CrimeVictimRedFlag)) CrimeCount,
    --                sum(InvestigationWithdrawnCount) InvestigationWithdrawnCount,
    --                sum(InvestigationDeniedCount) InvestigationDeniedCount,
    --                sum(InvestigationFraudCount) InvestigationFraudCount,
    --                sum(InvestigationNoResponseCount) InvestigationNoResponseCount
    --            from
    --                vEnterpriseClaimList t
    --            where
    --                t.CustomerID = ec.CustomerID
    --        ) t
    --) fl
    left join entEmail ee with(nolock) on
        ee.CustomerID = ec.CustomerID
    left join entPhone ep with(nolock) on
        ep.CustomerID = ec.CustomerID
    left join entAddress ea with(nolock) on
        ea.CustomerID = ec.CustomerID
    outer apply
    (
        select
            isnull(ea.Address, '') + 
            isnull(' ' + ea.Suburb, '') + 
            isnull(' ' + ea.State, '') + 
            isnull(' ' + ea.PostCode, '') FormattedAddress
    ) fa
    outer apply
    (
        select top 1
            1 HasEMC
            --,pe.EMCRef
        from
            emcApplicants ea 
        where
            ea.CustomerID = ec.CustomerID
    ) emc



























GO
