USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vPenPolicyAddonPremium]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[vPenPolicyAddonPremium] as

--20171201 - LT - Added new addons:
					--MotorcycleMoped
					--Excess
					--Business
					--Golf
					--Student
					--SnowSki
					--SnowBoard
					--Pet
					--Education
					--EMC
					--Ticket
					--SelfSkipperedBoatExcess
					--SnowSports
					--SnowSportsPlus
					--OptionalLuggageCover
					--AdventureActivities
					--PremiumLuggage
					--CancelforAnyReason


select
    pt.PolicyTransactionKey,
    isnull(CancellationGrossPremium, 0) Cancellation,
    isnull(WinterSportGrossPremium, 0) WinterSport,
    isnull(RentalCarGrossPremium, 0) RentalCar,
    isnull(MotorcycleGrossPremium, 0) Motorcycle,
    isnull(LuggageGrossPremium, 0) Luggage,
    isnull(MedicalGrossPremium, 0) Medical,
    isnull(ElectronicsGrossPremium, 0) Electronic,
    isnull(CruiseGrossPremium, 0) Cruise,

	--20171206_LT - new addons (adjusted premium)
	isnull(MotorcycleMopedGrossPremium, 0) MotorcycleMoped,
	isnull(ExcessGrossPremium, 0) Excess,
	isnull(BusinessGrossPremium, 0) Business,
	isnull(GolfGrossPremium, 0)  Golf,
	isnull(StudentGrossPremium, 0) Student,
	isnull(SnowSkiGrossPremium, 0) SnowSki,
	isnull(SnowBoardGrossPremium, 0) SnowBoard,
	isnull(PetCoverGrossPremium, 0) Pet,
	isnull(EducationCoverGrossPremium, 0) Education,
	isnull(EMCGroupGrossPremium, 0) EMCGroup,
	isnull(TicketGrossPremium, 0) Ticket,
	isnull(SelfSkipperedBoatExcessGrossPremium, 0) SelfSkipperedBoatExcess,
	isnull(SnowSportsGrossPremium, 0) SnowSports,
	isnull(SnowSportsPlusGrossPremium, 0) SnowSportsPlus,
	isnull(OptionalLuggageCoverGrossPremium, 0) OptionalLuggageCover,
	isnull(AdventureActivitiesGrossPremium, 0) AdventureActivities,
	isnull(PremiumLuggageCoverGrossPremium, 0) PremiumLuggage,
	isnull(CancelForAnyReasonGrossPremium, 0) CancelForAnyReason,

    isnull(CancellationUnadjGrossPremium, 0) CancellationUnadj,
    isnull(WinterSportUnadjGrossPremium, 0) WinterSportUnadj,
    isnull(RentalCarUnadjGrossPremium, 0) RentalCarUnadj,
    isnull(MotorcycleUnadjGrossPremium, 0) MotorcycleUnadj,
    isnull(LuggageUnadjGrossPremium, 0) LuggageUnadj,
    isnull(MedicalUnadjGrossPremium, 0) MedicalUnadj,
    isnull(ElectronicsUnadjGrossPremium, 0) ElectronicUnadj,
    isnull(CruiseUnadjGrossPremium, 0) CruiseUnadj,

	--20171206_LT - new addons (unadjusted premium)
	isnull(MotorcycleMopedUnadjGrossPremium, 0) MotorcycleMopedUnadj,
	isnull(ExcessUnadjGrossPremium, 0) ExcessUnadj,
	isnull(BusinessUnadjGrossPremium, 0) BusinessUnadj,
	isnull(GolfUnadjGrossPremium, 0)  GolfUnadj,
	isnull(StudentUnadjGrossPremium, 0) StudentUnadj,
	isnull(SnowSkiUnadjGrossPremium, 0) SnowSkiUnadj,
	isnull(SnowBoardUnadjGrossPremium, 0) SnowBoardUnadj,
	isnull(PetCoverUnadjGrossPremium, 0) PetUnadj,
	isnull(EducationCoverUnadjGrossPremium, 0) EducationUnadj,
	isnull(EMCGroupUnadjGrossPremium, 0) EMCGroupUnadj,
	isnull(TicketUnadjGrossPremium, 0) TicketUnadj,
	isnull(SelfSkipperedBoatExcessUnadjGrossPremium, 0) SelfSkipperedBoatExcessUnadj,
	isnull(SnowSportsUnadjGrossPremium, 0) SnowSportsUnadj,
	isnull(SnowSportsPlusUnadjGrossPremium, 0) SnowSportsPlusUnadj,
	isnull(OptionalLuggageCoverUnadjGrossPremium, 0) OptionalLuggageCoverUnadj,
	isnull(AdventureActivitiesUnadjGrossPremium, 0) AdventureActivitiesUnadj,
	isnull(PremiumLuggageCoverUnadjGrossPremium, 0) PremiumLuggageUnadj,
	isnull(CancelForAnyReasonUnadjGrossPremium, 0) CancelForAnyReasonUnadj
from 
    penPolicyTransSummary pt 
    outer apply
    (
        select 
            sum(
                case
                    when AddOnGroup = 'Cancellation' then GrossPremium
                    else 0
                end
            ) CancellationGrossPremium,
            sum(
                case
                    when AddOnGroup = 'Winter Sport' then GrossPremium
                    else 0
                end
            ) WinterSportGrossPremium,
            sum(
                case
                    when AddOnGroup = 'Rental Car' then GrossPremium
                    else 0
                end
            ) RentalCarGrossPremium,
            sum(
                case
                    when AddOnGroup = 'Motorcycle' then GrossPremium
                    else 0
                end
            ) MotorcycleGrossPremium,
            sum(
                case
                    when AddOnGroup = 'Luggage' then GrossPremium
                    else 0
                end
            ) LuggageGrossPremium,
            sum(
                case
                    when AddOnGroup = 'Electronics' then GrossPremium
                    else 0
                end
            ) ElectronicsGrossPremium,
            sum(
                case
                    when AddOnGroup = 'Medical' then GrossPremium
                    else 0
                end
            ) MedicalGrossPremium,
            sum(
                case
                    when AddOnGroup = 'Cruise' then GrossPremium
                    else 0
                end
            ) CruiseGrossPremium,
			sum(
				case when AddonGroup = 'Motorcycle/Moped Riding' then GrossPremium
					 else 0
				end
			) MotorcycleMopedGrossPremium,

			sum(
				case when AddonGroup = 'Excess' then GrossPremium
					 else 0
				end
			) ExcessGrossPremium,

			sum(
				case when AddonGroup = 'Business' then GrossPremium
					 else 0
				end
			) BusinessGrossPremium,

			sum(
				case when AddonGroup = 'Golf' then GrossPremium
					 else 0
				end
			) GolfGrossPremium,

			sum(
				case when AddonGroup = 'Student' then GrossPremium
					 else 0
				end
			) StudentGrossPremium,

			sum(
				case when AddonGroup = 'Snow Ski' then GrossPremium
					 else 0
				end
			) SnowSkiGrossPremium,

			sum(
				case when AddonGroup = 'Snow Board' then GrossPremium
					 else 0
				end
			) SnowBoardGrossPremium,

			sum(
				case when AddonGroup = 'Pet Cover' then GrossPremium
					 else 0
				end
			) PetCoverGrossPremium,

			sum(
				case when AddonGroup = 'Education Cover' then GrossPremium
					 else 0
				end
			) EducationCoverGrossPremium,

			sum(
				case when AddonGroup = 'EMC Group' then GrossPremium
					 else 0
				end
			) EMCGroupGrossPremium,

			sum(
				case when AddonGroup = 'Ticket' then GrossPremium
					 else 0
				end
			) TicketGrossPremium,

			sum(
				case when AddonGroup = 'Self-Skippered Boat Excess' then GrossPremium
					 else 0
				end
			) SelfSkipperedBoatExcessGrossPremium,

			sum(
				case when AddonGroup = 'Snow Sports' then GrossPremium
					 else 0
				end
			) SnowSportsGrossPremium,

			sum(
				case when AddonGroup = 'Snow Sports +' then GrossPremium
					 else 0
				end
			) SnowSportsPlusGrossPremium,

			sum(
				case when AddonGroup = 'Optional Luggage Cover' then GrossPremium
					 else 0
				end
			) OptionalLuggageCoverGrossPremium,

			sum(
				case when AddonGroup = 'Adventure Activities' then GrossPremium
					 else 0
				end
			) AdventureActivitiesGrossPremium,

			sum(
				case when AddonGroup = 'Premium Luggage Cover' then GrossPremium
					 else 0
				end
			) PremiumLuggageCoverGrossPremium,

			sum(
				case when AddonGroup = 'Cancel For Any Reason' then GrossPremium
					 else 0
				end
			) CancelForAnyReasonGrossPremium,


			--Unadjusted
            sum(
                case
                    when AddOnGroup = 'Cancellation' then UnadjGrossPremium
                    else 0
                end
            ) CancellationUnadjGrossPremium,
            sum(
                case
                    when AddOnGroup = 'Winter Sport' then UnadjGrossPremium
                    else 0
                end
            ) WinterSportUnadjGrossPremium,
            sum(
                case
                    when AddOnGroup = 'Rental Car' then UnadjGrossPremium
                    else 0
                end
            ) RentalCarUnadjGrossPremium,
            sum(
                case
                    when AddOnGroup = 'Motorcycle' then UnadjGrossPremium
                    else 0
                end
            ) MotorcycleUnadjGrossPremium,
            sum(
                case
                    when AddOnGroup = 'Luggage' then UnadjGrossPremium
                    else 0
                end
            ) LuggageUnadjGrossPremium,
            sum(
                case
                    when AddOnGroup = 'Electronics' then UnadjGrossPremium
                    else 0
                end
            ) ElectronicsUnadjGrossPremium,
            sum(
                case
                    when AddOnGroup = 'Medical' then UnadjGrossPremium
                    else 0
                end
            ) MedicalUnadjGrossPremium,
            sum(
                case
                    when AddOnGroup = 'Cruise' then UnadjGrossPremium
                    else 0
                end
            ) CruiseUnadjGrossPremium,
			sum(
				case when AddonGroup = 'Motorcycle/Moped Riding' then UnadjGrossPremium
					 else 0
				end
			) MotorcycleMopedUnadjGrossPremium,

			sum(
				case when AddonGroup = 'Excess' then UnadjGrossPremium
					 else 0
				end
			) ExcessUnadjGrossPremium,

			sum(
				case when AddonGroup = 'Business' then UnadjGrossPremium
					 else 0
				end
			) BusinessUnadjGrossPremium,

			sum(
				case when AddonGroup = 'Golf' then UnadjGrossPremium
					 else 0
				end
			) GolfUnadjGrossPremium,

			sum(
				case when AddonGroup = 'Student' then UnadjGrossPremium
					 else 0
				end
			) StudentUnadjGrossPremium,

			sum(
				case when AddonGroup = 'Snow Ski' then UnadjGrossPremium
					 else 0
				end
			) SnowSkiUnadjGrossPremium,

			sum(
				case when AddonGroup = 'Snow Board' then UnadjGrossPremium
					 else 0
				end
			) SnowBoardUnadjGrossPremium,

			sum(
				case when AddonGroup = 'Pet Cover' then UnadjGrossPremium
					 else 0
				end
			) PetCoverUnadjGrossPremium,

			sum(
				case when AddonGroup = 'Education Cover' then UnadjGrossPremium
					 else 0
				end
			) EducationCoverUnadjGrossPremium,

			sum(
				case when AddonGroup = 'EMC Group' then UnadjGrossPremium
					 else 0
				end
			) EMCGroupUnadjGrossPremium,

			sum(
				case when AddonGroup = 'Ticket' then UnadjGrossPremium
					 else 0
				end
			) TicketUnadjGrossPremium,

			sum(
				case when AddonGroup = 'Self-Skippered Boat Excess' then UnadjGrossPremium
					 else 0
				end
			) SelfSkipperedBoatExcessUnadjGrossPremium,

			sum(
				case when AddonGroup = 'Snow Sports' then UnadjGrossPremium
					 else 0
				end
			) SnowSportsUnadjGrossPremium,

			sum(
				case when AddonGroup = 'Snow Sports +' then UnadjGrossPremium
					 else 0
				end
			) SnowSportsPlusUnadjGrossPremium,

			sum(
				case when AddonGroup = 'Optional Luggage Cover' then UnadjGrossPremium
					 else 0
				end
			) OptionalLuggageCoverUnadjGrossPremium,

			sum(
				case when AddonGroup = 'Adventure Activities' then UnadjGrossPremium
					 else 0
				end
			) AdventureActivitiesUnadjGrossPremium,

			sum(
				case when AddonGroup = 'Premium Luggage Cover' then UnadjGrossPremium
					 else 0
				end
			) PremiumLuggageCoverUnadjGrossPremium,

			sum(
				case when AddonGroup = 'Cancel For Any Reason' then UnadjGrossPremium
					 else 0
				end
			) CancelForAnyReasonUnadjGrossPremium
        from
            [db-au-cmdwh]..penPolicyTransAddOn pta
        where
            pt.PolicyTransactionKey = pta.PolicyTransactionKey
    ) pa




GO
