USE [db-au-star]
GO
/****** Object:  View [dbo].[vfactPolicyTransactionAddon_Test007_backup20240816]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[vfactPolicyTransactionAddon_Test007_backup20240816] as
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
                when AddOnGroup in ('Cruise','Cruise Cover2') then pta.UnAdjGrossPremium
                else 0
            end
        ) CruiseUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup in ('Cruise','Cruise Cover2') then pta.GrossPremium
                else 0
            end
        ) CruiseSellPrice,
        sum(
            case
                when AddOnGroup IN ('Luggage','Premium Luggage Cover','Optional Luggage Cover') then pta.UnAdjGrossPremium
                else 0
            end
        ) LuggageUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup IN ('Luggage','Premium Luggage Cover','Optional Luggage Cover') then pta.GrossPremium
                else 0
            end
        ) LuggageSellPrice,
        sum(
            case
                when AddOnGroup IN ('Motorcycle','Motorcycle/Moped Riding') then pta.UnAdjGrossPremium
                else 0
            end
        ) MotorcycleUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup IN ('Motorcycle','Motorcycle/Moped Riding') then pta.GrossPremium
                else 0
            end
        ) MotorcycleSellPrice,
        sum(
            case
                when AddOnGroup IN ('Rental Car','Self-Skippered Boat Excess') then pta.UnAdjGrossPremium
                else 0
            end
        ) RentalCarUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup IN ('Rental Car','Self-Skippered Boat Excess') then pta.GrossPremium
                else 0
            end
        ) RentalCarSellPrice,
        sum(
            case
                when AddOnGroup in ('Snow Board', 'Snow Ski', 'Winter Sport','Snow Sports','Snow Sports +','Snow Sports3','Snow Extras') then pta.UnAdjGrossPremium
                else 0
            end
        ) WinterSportUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup in ('Snow Board', 'Snow Ski', 'Winter Sport','Snow Sports','Snow Sports +','Snow Sports3','Snow Extras') then pta.GrossPremium
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
                when AddOnGroup in ('Adventure Activities','Adventure Activities 2','Adventure Activities3','Adventure Plus') then pta.UnAdjGrossPremium
                else 0
            end
        ) AdventureActivitiesUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup in ('Adventure Activities','Adventure Activities 2','Adventure Activities3','Adventure Plus') then pta.GrossPremium
                else 0
            end
        ) AdventureActivitiesSellPrice,

		 sum(
            case
                when AddOnGroup = 'Aged Cover' then pta.UnAdjGrossPremium
                else 0
            end
        ) AgedCoverUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup = 'Aged Cover' then pta.GrossPremium
                else 0
            end
        ) AgedCoverSellPrice,

		sum(
            case
                when AddOnGroup = 'Ancillary Products' then pta.UnAdjGrossPremium
                else 0
            end
        ) AncillaryProductsUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup = 'Ancillary Products' then pta.GrossPremium
                else 0
            end
        ) AncillaryProductsSellPrice,

		sum(
            case
                when AddOnGroup = 'Cancel For Any Reason' then pta.UnAdjGrossPremium
                else 0
            end
        ) CancelForAnyReasonUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup = 'Cancel For Any Reason' then pta.GrossPremium
                else 0
            end
        ) CancelForAnyReasonSellPrice,

		sum(
            case
                when AddOnGroup = 'COVID-19 Cover' then pta.UnAdjGrossPremium
                else 0
            end
        ) COVID19CoverUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup = 'COVID-19 Cover' then pta.GrossPremium
                else 0
            end
        ) COVID19CoverSellPrice,

		sum(
            case
                when AddOnGroup = 'Electronics' then pta.UnAdjGrossPremium
                else 0
            end
        ) ElectronicsUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup = 'Electronics' then pta.GrossPremium
                else 0
            end
        ) ElectronicsSellPrice,

		sum(
            case
                when AddOnGroup IN ('Freely Activity Packs','Freely Benefit Packs') then pta.UnAdjGrossPremium
                else 0
            end
        ) FreelyPacksUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup IN ('Freely Activity Packs','Freely Benefit Packs') then pta.GrossPremium
                else 0
            end
        ) FreelyPacksSellPrice,

		sum(
            case
                when AddOnGroup ='TICKET' then pta.UnAdjGrossPremium
                else 0
            end
        ) TICKETUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup ='TICKET' then pta.GrossPremium
                else 0
            end
        ) TICKETSellPrice,

		sum(
            case
                when AddOnGroup ='DUTY' then pta.UnAdjGrossPremium
                else 0
            end
        ) DUTYUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup ='DUTY' then pta.GrossPremium
                else 0
            end
        ) DUTYSellPrice,

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
                when AddOnGroup not in ('Medical', 'EMC Group', 'Cruise','Cruise Cover2', 'Luggage','Premium Luggage Cover','Optional Luggage Cover',
				'Motorcycle','Motorcycle/Moped Riding', 'Rental Car','Self-Skippered Boat Excess', 
				'Snow Board', 'Snow Ski', 'Winter Sport','Snow Sports','Snow Sports +','Snow Sports3','Snow Extras', 
				'Cancellation','Adventure Activities','Adventure Activities 2','Adventure Activities3','Adventure Plus',
				'Aged Cover','Ancillary Products','Cancel For Any Reason','COVID-19 Cover','Electronics',
				'Freely Activity Packs','Freely Benefit Packs','TICKET','DUTY','Cancellation Plus Cover') then pta.UnAdjGrossPremium
                else 0
            end
        ) OtherUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup not in ('Medical', 'EMC Group', 'Cruise','Cruise Cover2', 'Luggage','Premium Luggage Cover','Optional Luggage Cover',
				'Motorcycle','Motorcycle/Moped Riding', 'Rental Car','Self-Skippered Boat Excess', 
				'Snow Board', 'Snow Ski', 'Winter Sport','Snow Sports','Snow Sports +','Snow Sports3','Snow Extras', 
				'Cancellation','Adventure Activities','Adventure Activities 2','Adventure Activities3','Adventure Plus',
				'Aged Cover','Ancillary Products','Cancel For Any Reason','COVID-19 Cover','Electronics',
				'Freely Activity Packs','Freely Benefit Packs','TICKET','DUTY','Cancellation Plus Cover') then pta.GrossPremium
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
                when AddOnGroup in ('Cruise','Cruise Cover2') then pta.UnAdjGrossPremium
                else 0
            end
        ) CruiseUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup in ('Cruise','Cruise Cover2') then pta.GrossPremium
                else 0
            end
        ) CruiseSellPrice,
        sum(
            case
                when AddOnGroup IN ('Luggage','Premium Luggage Cover','Optional Luggage Cover') then pta.UnAdjGrossPremium
                else 0
            end
        ) LuggageUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup IN ('Luggage','Premium Luggage Cover','Optional Luggage Cover') then pta.GrossPremium
                else 0
            end
        ) LuggageSellPrice,
        sum(
            case
                when AddOnGroup IN ('Motorcycle','Motorcycle/Moped Riding') then pta.UnAdjGrossPremium
                else 0
            end
        ) MotorcycleUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup IN ('Motorcycle','Motorcycle/Moped Riding') then pta.GrossPremium
                else 0
            end
        ) MotorcycleSellPrice,
        sum(
            case
                when AddOnGroup IN ('Rental Car','Self-Skippered Boat Excess') then pta.UnAdjGrossPremium
                else 0
            end
        ) RentalCarUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup IN ('Rental Car','Self-Skippered Boat Excess') then pta.GrossPremium
                else 0
            end
        ) RentalCarSellPrice,
        sum(
            case
                when AddOnGroup in ('Snow Board', 'Snow Ski', 'Winter Sport','Snow Sports','Snow Sports +','Snow Sports3','Snow Extras') then pta.UnAdjGrossPremium
                else 0
            end
        ) WinterSportUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup in ('Snow Board', 'Snow Ski', 'Winter Sport','Snow Sports','Snow Sports +','Snow Sports3','Snow Extras') then pta.GrossPremium
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
                when AddOnGroup in ('Adventure Activities','Adventure Activities 2','Adventure Activities3','Adventure Plus') then pta.UnAdjGrossPremium
                else 0
            end
        ) AdventureActivitiesUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup in ('Adventure Activities','Adventure Activities 2','Adventure Activities3','Adventure Plus') then pta.GrossPremium
                else 0
            end
        ) AdventureActivitiesSellPrice,

		 sum(
            case
                when AddOnGroup = 'Aged Cover' then pta.UnAdjGrossPremium
                else 0
            end
        ) AgedCoverUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup = 'Aged Cover' then pta.GrossPremium
                else 0
            end
        ) AgedCoverSellPrice,

		sum(
            case
                when AddOnGroup = 'Ancillary Products' then pta.UnAdjGrossPremium
                else 0
            end
        ) AncillaryProductsUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup = 'Ancillary Products' then pta.GrossPremium
                else 0
            end
        ) AncillaryProductsSellPrice,

		sum(
            case
                when AddOnGroup = 'Cancel For Any Reason' then pta.UnAdjGrossPremium
                else 0
            end
        ) CancelForAnyReasonUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup = 'Cancel For Any Reason' then pta.GrossPremium
                else 0
            end
        ) CancelForAnyReasonSellPrice,

		sum(
            case
                when AddOnGroup = 'COVID-19 Cover' then pta.UnAdjGrossPremium
                else 0
            end
        ) COVID19CoverUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup = 'COVID-19 Cover' then pta.GrossPremium
                else 0
            end
        ) COVID19CoverSellPrice,

		sum(
            case
                when AddOnGroup = 'Electronics' then pta.UnAdjGrossPremium
                else 0
            end
        ) ElectronicsUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup = 'Electronics' then pta.GrossPremium
                else 0
            end
        ) ElectronicsSellPrice,

		sum(
            case
                when AddOnGroup IN ('Freely Activity Packs','Freely Benefit Packs') then pta.UnAdjGrossPremium
                else 0
            end
        ) FreelyPacksUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup IN ('Freely Activity Packs','Freely Benefit Packs') then pta.GrossPremium
                else 0
            end
        ) FreelyPacksSellPrice,

		sum(
            case
                when AddOnGroup ='TICKET' then pta.UnAdjGrossPremium
                else 0
            end
        ) TICKETUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup ='TICKET' then pta.GrossPremium
                else 0
            end
        ) TICKETSellPrice,

		sum(
            case
                when AddOnGroup ='DUTY' then pta.UnAdjGrossPremium
                else 0
            end
        ) DUTYUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup ='DUTY' then pta.GrossPremium
                else 0
            end
        ) DUTYSellPrice,

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
                when AddOnGroup not in ('Medical', 'EMC Group', 'Cruise','Cruise Cover2', 'Luggage','Premium Luggage Cover','Optional Luggage Cover',
				'Motorcycle','Motorcycle/Moped Riding', 'Rental Car','Self-Skippered Boat Excess', 
				'Snow Board', 'Snow Ski', 'Winter Sport','Snow Sports','Snow Sports +','Snow Sports3','Snow Extras', 
				'Cancellation','Adventure Activities','Adventure Activities 2','Adventure Activities3','Adventure Plus',
				'Aged Cover','Ancillary Products','Cancel For Any Reason','COVID-19 Cover','Electronics',
				'Freely Activity Packs','Freely Benefit Packs','TICKET','DUTY','Cancellation Plus Cover') then pta.UnAdjGrossPremium
                else 0
            end
        ) OtherUnadjustedSellPrice,
        sum(
            case
                when AddOnGroup not in ('Medical', 'EMC Group', 'Cruise','Cruise Cover2', 'Luggage','Premium Luggage Cover','Optional Luggage Cover',
				'Motorcycle','Motorcycle/Moped Riding', 'Rental Car','Self-Skippered Boat Excess', 
				'Snow Board', 'Snow Ski', 'Winter Sport','Snow Sports','Snow Sports +','Snow Sports3','Snow Extras', 
				'Cancellation','Adventure Activities','Adventure Activities 2','Adventure Activities3','Adventure Plus',
				'Aged Cover','Ancillary Products','Cancel For Any Reason','COVID-19 Cover','Electronics',
				'Freely Activity Packs','Freely Benefit Packs','TICKET','DUTY','Cancellation Plus Cover') then pta.GrossPremium
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
