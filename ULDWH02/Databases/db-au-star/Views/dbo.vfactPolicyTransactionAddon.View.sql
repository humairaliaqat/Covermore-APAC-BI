USE [db-au-star]
GO
/****** Object:  View [dbo].[vfactPolicyTransactionAddon]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[vfactPolicyTransactionAddon] as
with cte_addons as
(
    select 
        'Point in time' as OutletReference,
        PolicyTransactionKey,
        sum(
            case
                when AddOnGroup = 'Medical' then pta.UnAdjGrossPremium
                else 0
            end
        ) MedicalUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup = 'Medical' then pta.GrossPremium
                else 0
            end
        ) MedicalSellPrice,
        sum(
            case
                when AddOnGroup = 'Cruise' then pta.UnAdjGrossPremium
                else 0
            end
        ) CruiseUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup = 'Cruise' then pta.GrossPremium
                else 0
            end
        ) CruiseSellPrice,
        sum(
            case
                when AddOnGroup = 'Luggage' then pta.UnAdjGrossPremium
                else 0
            end
        ) LuggageUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup = 'Luggage' then pta.GrossPremium
                else 0
            end
        ) LuggageSellPrice,
        sum(
            case
                when AddOnGroup = 'Motorcycle' then pta.UnAdjGrossPremium
                else 0
            end
        ) MotorcycleUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup = 'Motorcycle' then pta.GrossPremium
                else 0
            end
        ) MotorcycleSellPrice,
        sum(
            case
                when AddOnGroup = 'Rental Car' then pta.UnAdjGrossPremium
                else 0
            end
        ) RentalCarUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup = 'Rental Car' then pta.GrossPremium
                else 0
            end
        ) RentalCarSellPrice,
        sum(
            case
                when AddOnGroup in ('Snow Board', 'Snow Ski', 'Winter Sport') then pta.UnAdjGrossPremium
                else 0
            end
        ) WinterSportUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup in ('Snow Board', 'Snow Ski', 'Winter Sport') then pta.GrossPremium
                else 0
            end
        ) WinterSportSellPrice,
        sum(
            case
                when AddOnGroup = 'Cancellation' then pta.UnAdjGrossPremium
                else 0
            end
        ) CanxUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup = 'Cancellation' then pta.GrossPremium
                else 0
            end
        ) CanxSellPrice,

		sum(
            case
                when AddOnGroup ='Cancellation Plus Cover' then pta.UnAdjGrossPremium
                else 0
            end
        ) CancellationPlusCoverUnadjustedSellPrice,


		sum(
            case
                when AddOnGroup ='Cancellation Plus Cover' then pta.GrossPremium
                else 0
            end
        ) CancellationPlusCoverSellPrice,

        sum(
            case
                when AddOnGroup not in ('Medical', 'EMC Group', 'Cruise', 'Luggage', 'Motorcycle', 'Rental Car', 'Snow Board', 'Snow Ski', 'Winter Sport', 'Cancellation', 'Cancellation Plus Cover') then pta.UnAdjGrossPremium
                else 0
            end
        ) OtherUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup not in ('Medical', 'EMC Group', 'Cruise', 'Luggage', 'Motorcycle', 'Rental Car', 'Snow Board', 'Snow Ski', 'Winter Sport', 'Cancellation', 'Cancellation Plus Cover') then pta.GrossPremium
                else 0
            end
        ) OtherSellPrice
    from
        [db-au-cmdwh]..penPolicyTransAddOn pta
    group by
        PolicyTransactionKey

    union all

    select 
        'Latest alpha' as OutletReference,
        PolicyTransactionKey,
        sum(
            case
                when AddOnGroup = 'Medical' then pta.UnAdjGrossPremium
                else 0
            end
        ) MedicalUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup = 'Medical' then pta.GrossPremium
                else 0
            end
        ) MedicalSellPrice,
        sum(
            case
                when AddOnGroup = 'Cruise' then pta.UnAdjGrossPremium
                else 0
            end
        ) CruiseUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup = 'Cruise' then pta.GrossPremium
                else 0
            end
        ) CruiseSellPrice,
        sum(
            case
                when AddOnGroup = 'Luggage' then pta.UnAdjGrossPremium
                else 0
            end
        ) LuggageUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup = 'Luggage' then pta.GrossPremium
                else 0
            end
        ) LuggageSellPrice,
        sum(
            case
                when AddOnGroup = 'Motorcycle' then pta.UnAdjGrossPremium
                else 0
            end
        ) MotorcycleUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup = 'Motorcycle' then pta.GrossPremium
                else 0
            end
        ) MotorcycleSellPrice,
        sum(
            case
                when AddOnGroup = 'Rental Car' then pta.UnAdjGrossPremium
                else 0
            end
        ) RentalCarUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup = 'Rental Car' then pta.GrossPremium
                else 0
            end
        ) RentalCarSellPrice,
        sum(
            case
                when AddOnGroup in ('Snow Board', 'Snow Ski', 'Winter Sport') then pta.UnAdjGrossPremium
                else 0
            end
        ) WinterSportUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup in ('Snow Board', 'Snow Ski', 'Winter Sport') then pta.GrossPremium
                else 0
            end
        ) WinterSportSellPrice,
        sum(
            case
                when AddOnGroup = 'Cancellation' then pta.UnAdjGrossPremium
                else 0
            end
        ) CanxUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup = 'Cancellation' then pta.GrossPremium
                else 0
            end
        ) CanxSellPrice,

		sum(
            case
                when AddOnGroup ='Cancellation Plus Cover' then pta.UnAdjGrossPremium
                else 0
            end
        ) CancellationPlusCoverUnadjustedSellPriceSellPrice,

		sum(
            case
                when AddOnGroup ='Cancellation Plus Cover' then pta.GrossPremium
                else 0
            end
        ) CancellationPlusCoverSellPriceSellPrice,

        sum(
            case
                when AddOnGroup not in ('Medical', 'EMC Group', 'Cruise', 'Luggage', 'Motorcycle', 'Rental Car', 'Snow Board', 'Snow Ski', 'Winter Sport', 'Cancellation', 'Cancellation Plus Cover') then pta.UnAdjGrossPremium
                else 0
            end
        ) OtherUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup not in ('Medical', 'EMC Group', 'Cruise', 'Luggage', 'Motorcycle', 'Rental Car', 'Snow Board', 'Snow Ski', 'Winter Sport', 'Cancellation', 'Cancellation Plus Cover') then pta.GrossPremium
                else 0
            end
        ) OtherSellPrice
    from
        [db-au-cmdwh]..penPolicyTransAddOn pta
    group by
        PolicyTransactionKey
)
select 
    pt.DateSK,
    pt.DomainSK,
    pt.OutletSK,
    pt.PolicySK,
    pt.ConsultantSK,
    pt.AreaSK,
    pt.DestinationSK,
    pt.DurationSK,
    pt.ProductSK,
    pt.AgeBandSK,
    pt.PromotionSK,
    a.*,
    case
        when datediff([day], p.issuedate, p.tripstart) < -1 then -1
        when datediff([day], p.issuedate, p.tripstart) > 2000 then -1
        else datediff([day], p.issuedate, p.tripstart)
    end LeadTime
from
    cte_addons a
    inner join factPolicyTransaction pt on
        pt.PolicyTransactionKey = a.PolicyTransactionKey
    inner join dimpolicy as p on 
        p.PolicySK = pt.PolicySK
where
    pt.DateSK >= 20150101












GO
