USE [db-au-workspace]
GO
/****** Object:  View [dbo].[cba_tde_policy]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--outlet filler

--date filler

--csr filler

--policy 
CREATE view [dbo].[cba_tde_policy] as
with cte_policy as
(
    select --top 100
        --o.GroupName,
        --o.SubGroupName,
        o.Channel,
        o.AlphaCode ChannelRefID,
        o.OutletName ChannelRefDescription,
        isnull(csr.CSRName, '') CSR,

        p.PolicyNumber,

        p.TripType,
        p.AreaType,
        p.PrimaryCountry PrimaryDestination,

        p.ProductCode,
        p.ProductDisplayName ProductName,
        p.Excess,

        case 
            when isnumeric(p.TripCost) = 0 then 'Unknown' 
            when try_convert(int, p.TripCost) = 0 then '0' 
            when try_convert(int, p.TripCost) < 2000 then '< 2k' 
            when try_convert(int, p.TripCost) < 4000 then '2-3k' 
            when try_convert(int, p.TripCost) < 7000 then '4-6k' 
            when try_convert(int, p.TripCost) < 11000 then '7-10k' 
            when try_convert(int, p.TripCost) < 21000 then '11-20k' 
            when try_convert(int, p.TripCost) <= 200000 then '21-200k' 
            when try_convert(int, p.TripCost) < 1000000 then '200-900k' 
            else '>1m' 
        end TripCostBand,

        convert(date, p.IssueDate) IssueDate,
        convert(date, pt.PostingDate) AmendmentDate,
        convert(date, p.TripStart) DepartureDate,
        convert(date, p.TripEnd) ReturnDate,
        p.MaxDuration AMTMaxDuration,

        isnull(pro.PromoCode, 'N/A') PromoCode,

        p.StatusDescription PolicyStatus,
        pt.TransactionType AmendmentType,

        pt.BasePolicyCount PolicyCount,
        pt.GrossPremium SellPrice,
        pt.UnadjGrossPremium - pt.GrossPremium SellPriceDiscount,
        pt.Commission + pt.GrossAdminFee Commission,
        pt.GrossPremium - (pt.Commission + pt.GrossAdminFee) CBACost,

        ptvc.TravellerCount,

        ptv.State TravellerState,
        ptv.Suburb TravellerSuburb,
        ptv.PostCode TravellerPostCode,
        ptv.Age TravellerAge,
        ptv.Gender TravellerGender,
        ptv.TravellerConsent,
        ptv.CardNumber,
        ptv.CardType,

        prem.BasePremium,
        prem.MedicalPremium,
        prem.EMCPremium,
        prem.CruisePremium,
        prem.LuggagePremium,
        prem.WinterSportPremium,
        prem.BusinessPremium,
        prem.AgeCoverPremium,
        prem.RentalCarPremium,
        prem.MotorcyclePremium,
        prem.OtherPacksPremium
    
        --,pt.policytransactionkey
    from
        [db-au-cmdwh]..penOutlet o with(nolock)
        inner join [db-au-cmdwh]..penPolicy p with(nolock) on
            p.OutletAlphaKey = o.OutletAlphaKey
        cross apply
        (
            select  
                sum(1) TravellerCount
            from
                [db-au-cmdwh]..penPolicyTraveller ptvc
            where
                ptvc.PolicyKey = p.PolicyKey
        ) ptvc
        cross apply
        (
            select top 1 
                ptv.State,
                ptv.Suburb,
                ptv.PostCode,
                ptv.Age,
                ptv.Gender,
                case
                    when ptv.MarketingConsent = 1 then 'Yes'
                    else 'No'
                end TravellerConsent,
                ptv.MemberNumber CardNumber,
                case
                    when isnull(try_convert(bigint, ptv.MemberNumber), 0) = 0 then 'Non Member'
                    when try_convert(bigint, ptv.MemberNumber) % 4 = 0 then 'Platinum'
                    when try_convert(bigint, ptv.MemberNumber) % 4 = 1 then 'Gold'
                    when try_convert(bigint, ptv.MemberNumber) % 4 = 2 then 'Diamond'
                    when try_convert(bigint, ptv.MemberNumber) % 4 = 3 then 'Corporate'
                end CardType
            from
                [db-au-cmdwh]..penPolicyTraveller ptv
            where
                ptv.isPrimary = 1 and
                ptv.PolicyKey = p.PolicyKey
        ) ptv
        inner join [db-au-cmdwh]..penPolicyTransSummary pt with(nolock) on
            pt.PolicyKey = p.PolicyKey
        outer apply
        (
            select top 1 
                rpt.CRMUserName OriginalCSR
            from
                [db-au-cmdwh]..penPolicyTransSummary rpt with(nolock)
            where
                rpt.PolicyKey = p.PolicyKey and
                rpt.ParentID = pt.PolicyTransactionID and 
                isnull(rpt.CRMUserName, '') <> ''
        ) rpt
        outer apply
        (
            select top 1 
                pro.PromoCode
            from
                [db-au-cmdwh]..penPolicyTransSummary ptpro with(nolock)
                inner join [db-au-cmdwh]..penPolicyTransactionPromo pro with(nolock) on
                    pro.PolicyTransactionKey = ptpro.PolicyTransactionKey
            where
                ptpro.PolicyKey = p.PolicyKey and
                pro.IsApplied = 1 and
                pro.ApplyOrder = 1
        ) pro
        cross apply
        (
            select
                sum
                ( 
                    case
                        when PriceCategory = 'Base Rate' then GrossPremiumAfterDiscount
                        else 0
                    end 
                ) BasePremium,
                sum
                ( 
                    case
                        when PriceCategory = 'Medical' then GrossPremiumAfterDiscount
                        else 0
                    end 
                ) MedicalPremium,
                sum
                ( 
                    case
                        when PriceCategory = 'EMC' then GrossPremiumAfterDiscount
                        else 0
                    end 
                ) EMCPremium,
                sum
                ( 
                    case
                        when PriceCategory = 'Cruise' then GrossPremiumAfterDiscount
                        else 0
                    end 
                ) CruisePremium,
                sum
                ( 
                    case
                        when PriceCategory in ('Luggage', 'Optional Luggage Cover', 'Premium Luggage Cover') then GrossPremiumAfterDiscount
                        else 0
                    end 
                ) LuggagePremium,
                sum
                ( 
                    case
                        when PriceCategory in ('Winter Sport', 'Snow Sports', 'Snow Sports +') then GrossPremiumAfterDiscount
                        else 0
                    end 
                ) WinterSportPremium,
                sum
                ( 
                    case
                        when PriceCategory = 'Business' then GrossPremiumAfterDiscount
                        else 0
                    end 
                ) BusinessPremium,
                sum
                ( 
                    case
                        when PriceCategory = 'Age Cover' then GrossPremiumAfterDiscount
                        else 0
                    end 
                ) AgeCoverPremium,
                sum
                ( 
                    case
                        when PriceCategory = 'Rental Car' then GrossPremiumAfterDiscount
                        else 0
                    end 
                ) RentalCarPremium,
                sum
                ( 
                    case
                        when PriceCategory in ('Motorcycle', 'Motorcycle/Moped Riding') then GrossPremiumAfterDiscount
                        else 0
                    end 
                ) MotorcyclePremium,
                sum
                ( 
                    case
                        when PriceCategory in
                        (
                            'Base Rate',
                            'Medical',
                            'EMC',
                            'Cruise',
                            'Luggage',
                            'Optional Luggage Cover',
                            'Premium Luggage Cover',
                            'Winter Sport', 
                            'Snow Sports', 
                            'Snow Sports +',
                            'Business',
                            'Age Cover',
                            'Rental Car',
                            'Motorcycle', 
                            'Motorcycle/Moped Riding'
                        )
                        then 0
                        else GrossPremiumAfterDiscount
                    end 
                ) OtherPacksPremium
            from
                [db-au-cmdwh]..vpenPolicyPriceComponentOptimise prem with(nolock)
            where
                prem.PolicyTransactionKey = pt.PolicyTransactionKey
        ) prem
        outer apply
        (
            select 
                crm.FirstName + ' ' + crm.LastName CSRName
            from
                [db-au-cmdwh]..penCRMUser crm with(nolock)
            where
                crm.UserName = isnull(rpt.OriginalCSR, pt.CRMUserName)
        ) csr
    where
        o.CountryKey = 'AU' and
        o.OutletStatus = 'Current' and
        o.GroupCode = 'MB' and
        p.IssueDate >= '2018-01-01'
)
select 
    Channel,
    ChannelRefID,
    ChannelRefDescription,
    CSR,

    PolicyNumber,
    TripType,
    AreaType,
    PrimaryDestination,
    ProductCode,
    ProductName,
    Excess,
    TripCostBand,
    IssueDate,
    AmendmentDate,
    DepartureDate,
    ReturnDate,
    AMTMaxDuration,
    PromoCode,
    PolicyStatus,
    AmendmentType,
    
    TravellerCount,
    TravellerState,
    TravellerSuburb,
    TravellerPostCode,
    TravellerAge,
    TravellerGender,
    TravellerConsent,
    CardNumber,
    CardType,

    PolicyCount,
    SellPrice,
    SellPriceDiscount,
    Commission,
    CBACost,

    BasePremium,
    MedicalPremium,
    EMCPremium,
    CruisePremium,
    LuggagePremium,
    WinterSportPremium,
    BusinessPremium,
    AgeCoverPremium,
    RentalCarPremium,
    MotorcyclePremium,
    OtherPacksPremium

    --sum(isnull(PolicyCount, 0)) PolicyCount,
    --sum(isnull(SellPrice, 0)) SellPrice,
    --sum(isnull(Commission, 0)) Commission,
    --sum(isnull(BasePremium, 0)) BasePremium,
    --sum(isnull(MedicalPremium, 0)) MedicalPremium,
    --sum(isnull(EMCPremium, 0)) EMCPremium,
    --sum(isnull(CruisePremium, 0)) EMCPremium,
    --sum(isnull(LuggagePremium, 0)) EMCPremium,
    --sum(isnull(WinterSportPremium, 0)) EMCPremium,
    --sum(isnull(BusinessPremium, 0)) BusinessPremium,
    --sum(isnull(AgeCoverPremium, 0)) AgeCoverPremium,
    --sum(isnull(RentalCarPremium, 0)) RentalCarPremium,
    --sum(isnull(MotorcyclePremium, 0)) MotorcyclePremium,
    --sum(isnull(OtherPacksPremium, 0)) OtherPacksPremium
from
    cte_policy
--group by
--    Channel,
--    ChannelRefID,
--    ChannelRefDescription,
--    CSR,
--    TripType,
--    AreaType,
--    PrimaryDestination,
--    ProductCode,
--    ProductName,
--    Excess,
--    TripCostBand,
--    IssueDate,
--    AmendmentDate,
--    DepartureDate,
--    ReturnDate,
--    AMTMaxDuration,
--    PromoCode,
--    PolicyStatus,
--    AmendmentType

GO
