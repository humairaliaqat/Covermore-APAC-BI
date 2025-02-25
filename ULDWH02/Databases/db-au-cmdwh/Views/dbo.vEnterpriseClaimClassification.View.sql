USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vEnterpriseClaimClassification]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vEnterpriseClaimClassification] as
select --top 1000
    cl.ClaimKey,
    cl.ClaimNo,
    --cf.EventCountryName,
    --cf.EventDescription,
    --ci.ClaimCost,
    --locs.LocationScore,
    --lugs.LuggageScore,
    --meds.MedicalScore,
    --isnull(invs.InvestigationScore, 0) InvestigationScore,
    --rcs.RentalCarScore,
    --hrs.HighRiskScore,
    --occ.haslostitem,
    --p.HasLuggageAddon,
    --ec.PriorClaimCount,
    case
        --when ci.ClaimCost < 500 and ec.PriorClaimCount <= 2 then ''
        when 
            (
                LuggageScore > 1 and 
                (
                    cf.EventDescription like '%lost%' or
                    cf.EventDescription like '%loss%' or
                    cf.CrimeVictimFlag = 1
                )
            ) or
            LocationScore > 1 or
            MedicalScore > 1 or
            InvestigationScore > 1 or
            RentalCarScore > 1 or
            HighRiskScore > 1 or
            FraudFlag = 1
        then 'Red'
        --when ci.ClaimCost < 1000 and ec.PriorClaimCount <= 5 then ''
        when ec.PriorClaimCount >= 20 then 'Red'
        when 
            (
                case when 
                    (
                        LuggageScore > 0 and 
                        (
                            cf.EventDescription like '%lost%' or
                            cf.EventDescription like '%loss%' or
                            cf.CrimeVictimFlag = 1
                        ) and
                        LocationScore > 0
                    )
                then 1 else 0 end +
                case when isnull(NewItemScore, 0) > 0 and cf.ElectronicsFlag = 1 then 1 else 0 end +
                case when MedicalScore > 0 then 1 else 0 end +
                case when ec.PriorClaimCount >= 4 then 1 else 0 end +
                0
            ) >= 2 
        then 'Amber'
        when ec.PriorClaimCount >= 15 then 'Amber'
        when
            (
                case when LeadTimeScore > 0 then 1 else 0 end +
                case when cf.NoProofRedFlag = 1 then 1 else 0 end +
                case when cf.OnlyElectronicRedFlag = 1 then 1 else 0 end +
                case when cf.NoReportRedFlag = 1 then 1 else 0 end +
                case when datediff(day, p.TripStart, cl.CreateDate) <= 2 then 1 else 0 end +
                case when datediff(day, p.IssueDate, cl.CreateDate) <= 1 then 1 else 0 end +
                case when datediff(day, p.TripEnd, cl.CreateDate) between 0 and 3 then 1 else 0 end +
                case when SamePolicyClaimCount > p.TravellerCount then 1 else 0 end +
                0
            ) >= 3
        then 'Yellow'
        when ec.PriorClaimCount >= 10 then 'Yellow'
    end Classification,
    case 
        when FraudFlag = 1 then 'Fraud detected'
        --when ci.ClaimCost < 500 and ec.PriorClaimCount <= 2 then ''
        when 
            --ci.ClaimCost < 1000 and 
            ec.PriorClaimCount <= 5 and
            not
            (
                (
                    LuggageScore > 1 and 
                    (
                        cf.EventDescription like '%lost%' or
                        cf.EventDescription like '%loss%' or
                        cf.CrimeVictimFlag = 1
                    )
                ) or
                LocationScore > 1 or
                MedicalScore > 1 or
                InvestigationScore > 1 or
                RentalCarScore > 1 or
                HighRiskScore > 1 
            )
        then ''
        else 
            case when LocationScore > 1 then 'High risk countries.' + char(10) else '' end +
            case 
                when 
                    LuggageScore > 1 and 
                    (
                        cf.EventDescription like '%lost%' or
                        cf.EventDescription like '%loss%' or
                        cf.CrimeVictimFlag = 1
                    ) 
                then 'Theft/loss > $8k on luggage.' + char(10)
                when 
                    LuggageScore > 0 and 
                    (
                        cf.EventDescription like '%lost%' or
                        cf.EventDescription like '%loss%' or
                        cf.CrimeVictimFlag = 1
                    )  and
                    LocationScore > 0
                then 'Theft/loss > $2k on luggage, red-flag.' + char(10)
                else ''
            end + 
            case 
                when MedicalScore > 1 then 'Medical/dental > $4k, red-flag.' + char(10) 
                when MedicalScore > 0 then 'High medical costs, red-flag.' + char(10) 
                else '' 
            end +
            case when InvestigationScore > 0 then 'Previous investigation.' + char(10) else '' end +
            case when RentalCarScore > 1 then 'Rental car, red-flag.' + char(10) else '' end +
            case when HighRiskScore > 1 then 'High risk circumstances.' + char(10) else '' end +
            case when isnull(NewItemScore, 0) > 0 and cf.ElectronicsFlag = 1 then 'Recently purchased electronics.' + char(10) else '' end +
            case when ec.PriorClaimCount >= 4 then 'Extensive claims history.' + char(10) else '' end +
            case when LeadTimeScore > 0 then 'Policy within 2 days of departure.' + char(10) else '' end +
            case when cf.NoProofRedFlag = 1 then 'Lack of receipts.' + char(10) else '' end +
            case when cf.OnlyElectronicRedFlag = 1 then 'Electronic claim without luggage.' + char(10) else '' end +
            case when cf.NoReportRedFlag = 1 then 'No loss reports.' + char(10) else '' end +
            case when abs(datediff(day, p.TripStart, cl.CreateDate)) <= 2 then 'Claims within 48 hours of travel.' + char(10) else '' end +
            case when datediff(day, p.IssueDate, cl.CreateDate) <= 1 then 'Claims within 24 hours of policy issued.' + char(10) else '' end +
            case when abs(datediff(day, p.TripEnd, cl.CreateDate)) <= 3 then 'Claims between 3 days of return.' + char(10) else '' end +
            case when SamePolicyClaimCount >= 3 then 'Multiple claims on same policy.' else '' end 
    end Details
    --,

    --0 Terminator

    --,
    --(
    --    select 
    --        occ.CostDescription + ' '
    --    from
    --        clmOnlineClaimCosts occ
    --    where
    --        occ.ClaimKey = cl.ClaimKey and
    --        occ.ExpenseType in ('Luggage', 'Other') and
    --        occ.CostDescription not like '%money%' and
    --        occ.CostDescription not like '%cash%' and
    --        occ.CostDescription not like '%card%' and
    --        occ.CostDescription not like '%passport%' and
    --        occ.CostDescription not like '%visa%'
    --    for xml path('')
    --) occ

    --,
    --(
    --    select 
    --        pta.AddOnText + ' '
    --    from
    --        penPolicyTransSummary pt
    --        inner join penPolicyTransSummary r on
    --            r.PolicyKey = pt.PolicyKey
    --        inner join penPolicyTransAddOn pta on
    --            pta.PolicyTransactionKey = r.PolicyTransactionKey
    --    where
    --        pt.PolicyTransactionKey = cl.PolicyTransactionKey and
    --        pta.AddOnGroup = 'Luggage'
    --    for xml path ('')
    --) p

from
    clmClaim cl
    outer apply
    (
        select top 1
            1 FraudFlag
        from
            e5Work w with(nolock)
        where
            w.ClaimKey = cl.ClaimKey and
            exists
            (
                select 
                    null
                from
                    e5WorkActivity wa with(nolock)
                    inner join e5WorkActivityProperties wap with(nolock) on
                        wap.WorkActivity_ID = wa.ID and
                        wap.Property_ID = 'InvestigationOutcome'
                    inner join e5WorkItems wi with(nolock) on
                        wi.ID = wap.PropertyValue
                where
                    wa.Work_ID = w.Work_ID and
                    wa.CategoryActivityName = 'Investigation Outcome' and
                    wa.CompletionDate is not null and
                    (
                        wi.Name like '%fraud%' or
                        wi.Name like '%withdrawn%'
                    )
            )
    ) inv
    outer apply
    (
        select 
            count(distinct ec.ClaimKey) PriorClaimCount,
            max(InvestigationScore) InvestigationScore
        from
            entPolicy ec
            inner join clmClaim rcl on
                rcl.ClaimKey = ec.ClaimKey
            outer apply
            (
                select
                    sum
                    (
                        case
                            when wa.Name like '%fraud%' then 3
                            when wa.Name like '%withdrawn%' then 2
                            when wa.Name like '%denied%' then 2
                            when wa.Name is not null then 1
                            else 0
                        end
                    ) InvestigationScore
                from
                    e5Work w with(nolock)
                    outer apply
                    (
                        select top 1
                            wi.Name
                        from
                            e5WorkActivity wa with(nolock)
                            inner join e5WorkActivityProperties wap with(nolock) on
                                wap.WorkActivity_ID = wa.ID and
                                wap.Property_ID = 'InvestigationOutcome'
                            inner join e5WorkItems wi with(nolock) on
                                wi.ID = wap.PropertyValue
                        where
                            wa.Work_ID = w.Work_ID and
                            wa.CategoryActivityName = 'Investigation Outcome' and
                            wa.CompletionDate is not null
                        order by
                            wa.CompletionDate desc
                    ) wa
                where
                    w.ClaimKey = rcl.ClaimKey 
                    --and
                    --WorkType = 'Investigation'
            ) invs
        where
            ec.CustomerID in
            (
                select 
                    r.CustomerID
                from
                    entPolicy r
                where
                    r.ClaimKey = cl.ClaimKey
            ) and
            ec.ClaimKey <> '' and
            ec.ClaimKey is not null and
            rcl.CreateDate <= cl.CreateDate 
            --and
            --exists
            --(
            --    select
            --        null
            --    from
            --        clmPayment cp
            --    where
            --        cp.ClaimKey = rcl.ClaimKey and
            --        cp.PayeeKey = ec.Reference
            --)
    ) ec
    inner join clmClaimFlags cf on
        cf.ClaimKey = cl.ClaimKey
    outer apply
    (
        select top 1
            p.IssueDate,
            p.TripStart,
            p.TripEnd,
            rcl.SamePolicyClaimCount,
            ptv.TravellerCount
        from
            penPolicyTransSummary pt
            inner join penPolicy p on
                p.PolicyKey = pt.PolicyKey
            outer apply
            (
                select
                    count(distinct rcl.Claimkey) SamePolicyClaimCount
                from
                    penPolicyTransSummary r
                    inner join clmClaim rcl on
                        rcl.PolicyTransactionKey = r.PolicyTransactionKey
                where
                    r.PolicyKey = pt.PolicyKey and
                    rcl.ClaimKey <> cl.ClaimKey
            ) rcl
            cross apply
            (
                select 
                    count(ptv.PolicyTravellerKey) TravellerCount
                from
                    penPolicyTraveller ptv
                where
                    ptv.PolicyKey = p.PolicyKey
            ) ptv
        where
            pt.PolicyTransactionKey = cl.PolicyTransactionKey
    ) p
    outer apply
    (
        select top 1
            1 HasLuggageAddon
        from
            penPolicyTransSummary pt
            inner join penPolicyTransSummary r on
                r.PolicyKey = pt.PolicyKey
            inner join penPolicyTransAddOn pta on
                pta.PolicyTransactionKey = r.PolicyTransactionKey
        where
            pt.PolicyTransactionKey = cl.PolicyTransactionKey and
            pta.AddOnGroup = 'Luggage'
    ) pa
    outer apply
    (
        select top 1
            1 HasLostItem
        from
            clmOnlineClaimCosts occ
        where
            occ.ClaimKey = cl.ClaimKey and
            occ.ExpenseType in ('Luggage', 'Other') and
            occ.CostDescription not like '%money%' and
            occ.CostDescription not like '%cash%' and
            occ.CostDescription not like '%card%' and
            occ.CostDescription not like '%passport%' and
            occ.CostDescription not like '%visa%'
    ) occ
    --outer apply
    --(
    --    select 
    --        sum(ci.PaymentDelta) Paid,
    --        sum(IncurredDelta) ClaimCost
    --    from
    --        vclmClaimIncurred ci with(nolock)
    --    where
    --        ci.ClaimKey = cl.ClaimKey
    --) ci
    outer apply
    (
        select 
            sum
            (
                case
                    when cb.ActuarialBenefitGroup = 'Luggage' then csi.IncurredDelta
                    else 0
                end
            ) LuggageClaimCost,
            sum
            (
                case
                    when cb.ActuarialBenefitGroup = 'Cancellation' then csi.IncurredDelta
                    else 0
                end
            ) CancellationClaimCost,
            sum
            (
                case
                    when cb.ActuarialBenefitGroup = 'Medical' then csi.IncurredDelta
                    else 0
                end
            ) MedicalClaimCost,
            sum
            (
                case
                    when cb.ActuarialBenefitGroup = 'Additional Expenses' then csi.IncurredDelta
                    else 0
                end
            ) AdditionalClaimCost
        from
            vclmClaimSectionIncurred csi with(nolock)
            inner join clmSection cs with(nolock) on
                cs.SectionKey = csi.SectionKey
            inner join vclmBenefitCategory cb with(nolock) on
                cb.BenefitSectionKey = cs.BenefitSectionKey
        where
            csi.ClaimKey = cl.ClaimKey
    ) csi
    outer apply
    (
        select top 1
            Continent
        from
            [db-au-star]..dimDestination co
        where
            co.Destination = cf.EventCountryName
    ) co
    outer apply
    (
        select
            case
                --africa
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%nigeria%' then 2
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%zimbabwe%' then 2
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%africa%' then 1
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%cameroon%' then 1

                --balkan
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%bosnia%' then 1
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%serbia%' then 1
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%croatia%' then 1

                --middle east
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%lebanon%' then 2
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%afghanistan%' then 2
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%uae%' then 1
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%arab%emir%' then 1
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%emirate%' then 1
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%egypt%' then 2
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%iran%' then 2
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%iraq%' then 2
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%syria%' then 2
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%ghana%' then 2
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%tanzania%' then 2

                --south asia
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%india%' then 1
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%pakistan%' then 2
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%bangladesh%' then 2
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%sri%lanka%' then 1

                --south east asia
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%cambodia%' then 1
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%vietnam%' then 1
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%indonesia%' then 1
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%bali%' then 1
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%laos%' then 1
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%philippines%' then 1
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%thailand%' then 1
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%bangkok%' then 1

                --south america
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%col_mbia%' then 1
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%mexico%' then 1
                when isnull(co.Continent, '') + isnull(cf.EventCountryName, '') + isnull(cf.EventLocation, '') like '%nicaragua%' then 1

                else 0
            end LocationScore
    ) locs
    outer apply
    (
        select
            case 
                when csi.LuggageClaimCost > 8000 then 2
                when csi.LuggageClaimCost > 2000 then 1
                when cf.LuggageFlag = 1 and occ.HasLostItem = 1 and pa.HasLuggageAddon = 1 then 1
                else 0
            end LuggageScore
    ) lugs
    outer apply
    (
        select
            case 
                when csi.MedicalClaimCost > 4000 and locs.LocationScore >= 1 then 2
                when 
                    csi.MedicalClaimCost > 1000 and
                    locs.LocationScore > 0
                then 1
                else 0
            end MedicalScore
    ) meds
    outer apply
    (
        select
            case
                when cf.RentalCarFlag = 1 and locs.LocationScore >= 1 then 2
                else 0
            end RentalCarScore
    ) rcs
    outer apply
    (
        select
            case
                when cf.CrimeVictimRedFlag = 1 then 2
                when cf.CrimeVictimFlag = 1 then 1
                when cf.SectionRedFlag = 1 then 1
                else 0
            end HighRiskScore
    ) hrs
    outer apply
    (
        select top 1
            1 NewItemScore
        from
            clmOnlineClaimCosts occ
        where
            occ.ClaimKey = cl.ClaimKey and
            occ.ExpenseType in ('Luggage', 'Other') and
            datediff(day, ExpenseDate, coalesce(p.IssueDate, cl.PolicyIssuedDate)) < 7
    ) nis
    outer apply
    (
        select
            case
                when datediff(day, p.IssueDate, p.TripStart) <= 2 then 1
                else 0
            end LeadTimeScore
    ) lts
--where
--    --cl.CreateDate >= '2017-05-01'
--    --and
--    cl.ClaimKey in
--    (

--select 
--    ClaimKey
    
--from
--    entCustomer ec
--    inner join entPolicy ep on
--        ep.CustomerID = ec.CustomerID
--where
--    --CUstomerName = 'Katrine Hermansen'
--    ec.CustomerID = 3086

--    )


GO
