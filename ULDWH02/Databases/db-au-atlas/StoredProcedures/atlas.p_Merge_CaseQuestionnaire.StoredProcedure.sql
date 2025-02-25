USE [db-au-atlas]
GO
/****** Object:  StoredProcedure [atlas].[p_Merge_CaseQuestionnaire]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [atlas].[p_Merge_CaseQuestionnaire]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LastDateTime DATETIME

	SELECT @LastDateTime = LastDateTime FROM atlas.JobConfig WHERE EntityName = 'atlas.[CaseQuestionnaire]';

	MERGE atlas.[CaseQuestionnaire] DST
	USING (
		SELECT	stgc.[Id], 
			stgc.[IsDeleted], 
			stgc.[Currency_ISOCode], 
			stgc.[CreatedById], 
			stgc.[CreatedDate], 
			stgc.[LastModifiedDate], 
			stgc.[LastModifiedById], 
			stgc.[LastReferencedDate], 
			stgc.[LastViewedDate], 
			stgc.[SystemModstamp], 
			stgc.[Name], 
			stgc.[AccommodationCosts_c], 
			stgc.[ActivationConfirmedbyInsurer__c], 
			stgc.[AdditionalInformation1_c], 
			stgc.[AdditionalInformation__c], 
			stgc.[AdviceProvidedToCaller_c], 
			stgc.[AirlineCosts_c], 
			stgc.[Amenities__c], 
			stgc.[AMEXCardVerified_c], 
			stgc.[AMEXNACPolicy_c], 
			stgc.[AnyExclusionsApply_c], 
			stgc.[AnySpecialConditionsPreferred_c], 
			stgc.[APConfirmedAuthorisedBusinessTravel_c], 
			stgc.[APUpdatedCaseOpened_c], 
			stgc.[AreTheyImpactedByTheEvent_c], 
			stgc.[AreTheyInDanger_c], 
			stgc.[AreTheyInjured_c], 
			stgc.[AreTheyNearTheIncident_c], 
			stgc.[ArrivalDate_c], 
			stgc.[AssistanceRequired_c], 
			stgc.[AuthorizationLetterAddress_c], 
			stgc.[BenefitDetails_c], 
			stgc.[BINNumber__c], 
			stgc.[BookingReference_c], 
			stgc.[BudgetForItem_c], 
			stgc.[BudgetPerNight_c], 
			stgc.[Budget_c], 
			stgc.[CancellationInterruptionReason_c], 
			stgc.[CaseType_c], 
			stgc.[Case_c], 
			stgc.[Category_c], 
			stgc.[CityStateCountry_c], 
			stgc.[ClassOfFlight_c], 
			stgc.[Colour_c], 
			stgc.[CommercialPropertyDetails_c], 
			stgc.[CompInsuranceWithHireCarProvider_c], 
			stgc.[ConfirmedByWhichAP_c], 
			stgc.[ContactDetails_c], 
			stgc.[CountryOfCitizenship_c], 
			stgc.[CountryOfExpatInpatResidence_c], 
			stgc.[CoveredUnderTheBTAPlan_c], 
			stgc.[CoveredVehicleDefinitionMet_c], 
			stgc.[Currency_c], 
			stgc.[CurrentlyReceivingTreatment_c], 
			stgc.[CustomersCurrentLocation_c], 
			stgc.[CustomersRelationshipToEmployee_c], 
			stgc.[DateAndTimeOfTheAccidentincident_c], 
			stgc.[DateAndTime_c], 
			stgc.[DateofBookingTrip_c], 
			stgc.[DateOfNextScheduledHomeLeave_c], 
			stgc.[DatetimelocationOfFlightevent_c], 
			stgc.[DeliveryAddress_c], 
			stgc.[DeliveryDatetimeRangeRequested_c], 
			stgc.[DepartureAndArrivingLocation_c], 
			stgc.[DepartureCity1_c], 
			stgc.[DepartureDate_c], 
			stgc.[DescribeAnyInjuriesSustained__c], 
			stgc.[DescribeHowTheInjuryOccurred_c], 
			stgc.[DescriptionOfTheIllnessinjury_c], 
			stgc.[DestinationCity1_c], 
			stgc.[DetailedDescriptionOfLocation_c], 
			stgc.[DetailsOfAutoInsuranceIfNotified_c], 
			stgc.[DetailsOfVehicleInvolved_c], 
			stgc.[DiagnosisIfApplicable_c], 
			stgc.[Diagnosis_c], 
			stgc.[DidAnInjuryOccur_c], 
			stgc.[DocumentIssuer_c], 
			stgc.[DocumentLost_c], 
			stgc.[DocumentMedicalAidInformation_c], 
			stgc.[DoesTheDriverHaveCDW_c], 
			stgc.[DoesTheDriverHoldARelevantLicence_c], 
			stgc.[DoTheyHaveMedicalAidInSouthAfrica_c], 
			stgc.[DropOffLocation_c], 
			stgc.[DrugsOrAlcoholInvolved_c], 
			stgc.[DxAndTxPlan_C], 
			stgc.[EligibilityDetails_c], 
			stgc.[EmbassyconsulateNotified_c], 
			stgc.[EmployeesJobTitle__c], 
			stgc.[EndDateOfExpatInpatAssignment_c], 
			stgc.[EntertainmentType_c], 
			stgc.[ExactLocationOfTheAccidentincident_c], 
			stgc.[ExcessAccountedFor_c], 
			stgc.[ExcessOnHireVehiclePolicy_c], 
			stgc.[Excess_c], 
			stgc.[ExcludedSport_c], 
			stgc.[ExistingPrescriptionForTheMedication__c], 
			stgc.[ExplainClaimsProcessAndSendFormlin_c], 
			stgc.[FamilyFriendContactInformation__c], 
			stgc.[FinalAmount_c], 
			stgc.[FullCreditCardName_c], 
			stgc.[HasALawyerBeenEngaged_c], 
			stgc.[HaveTheyBeenContacted_c], 
			stgc.[HealthClubName_c], 
			stgc.[HighChairBoosterRequired_c], 
			stgc.[HiredFrom_c], 
			stgc.[HomeAddress_c], 
			stgc.[HomeAssistanceOrganised_c], 
			stgc.[HotelName_c], 
			stgc.[HowDoYouWantToReceiveFeedback_c], 
			stgc.[HowManyTravellersAreOnTheCancelled_c], 
			stgc.[HowWasExcessAccountedFor_c], 
			stgc.[HowWasTheTripBooked_c], 
			stgc.[InitiatorOfCancellationInterruption_c], 
			stgc.[InjuryOrDentalPainBenefit_c], 
			stgc.[IsTheSuspectPresent_c], 
			stgc.[IsThisAAssurantPolicy_c], 
			stgc.[IsThisARoadsideOrHomeAssistanceCase__c], 
			stgc.[ItemDescription1_c], 
			stgc.[ItemDescription_c], 
			stgc.[LengthOfDelay_c], 
			stgc.[LimitationsBenefitMaximumApply_c], 
			stgc.[ListDrugsalcohol_c], 
			stgc.[ListOfItemsLoststolen__c], 
			stgc.[LMOSpecialistDetails_c], 
			stgc.[LocationOfIncident_c], 
			stgc.[Location_c], 
			stgc.[MakeAndModel_c], 
			stgc.[MaxBenefitExceededForPrimaryInsurance_c], 
			stgc.[MedicalCondition_c], 
			stgc.[MedicalName_c], 
			stgc.[MessageOnDeliveryCardBox_c], 
			stgc.[Message_c], 
			stgc.[NameAndContactDetails_c], 
			stgc.[NameOfEmployerCompany_c], 
			stgc.[NameOfPersonEmployedByThisCompany_c], 
			stgc.[NameOfTheDriver_c], 
			stgc.[NameOfVehicleOwner_c], 
			stgc.[NamesOnTheTickets__c], 
			stgc.[NatureOfProblem_c], 
			stgc.[Note10_c], 
			stgc.[Note11_c], 
			stgc.[Note1_c], 
			stgc.[Note2_c], 
			stgc.[Note3_c], 
			stgc.[Note4_c], 
			stgc.[Note5_c], 
			stgc.[Note6_c], 
			stgc.[Note7_c], 
			stgc.[Note8_c], 
			stgc.[Note9_c], 
			stgc.[Note_c], 
			stgc.[NumberOfChildren_c], 
			stgc.[NumberOfPeople1_c], 
			stgc.[NumberOfPeople_c], 
			stgc.[NumberOfPets_c], 
			stgc.[ObtainAndDocumentContactInformation__c], 
			stgc.[OriginalCostOfTravel_c], 
			stgc.[OtherCosts_c], 
			stgc.[OtherDestination_c], 
			stgc.[OtherPartiesInvolved_c], 
			stgc.[OtherPrePaidArrangementsImpacted_c], 
			stgc.[OtherPrimaryCauseDetails__c], 
			stgc.[OtherTravelProviderName_c], 
			stgc.[PetDescriptionBreeds_c], 
			stgc.[PhotoIdentificationAvailable_c], 
			stgc.[PickUpLocation_c], 
			stgc.[PlanType_c], 
			stgc.[PoliceIncidentReportRequested_c], 
			stgc.[PoliceReportNumber_c], 
			stgc.[PolicyEndDate_c], 
			stgc.[PolicyStartDate_c], 
			stgc.[Policy_c], 
			stgc.[PreferredAppointmentDateTime_c], 
			stgc.[PreferredColour_c], 
			stgc.[PreferredDateAndTime_c], 
			stgc.[PreferredSize_c], 
			stgc.[PrescribersContactDetails_c], 
			stgc.[PreviousTreatmentDetails_c], 
			stgc.[PrimaryCauseOfTheInjury_c], 
			stgc.[PrimaryDestinationOfTrip_c], 
			stgc.[PrimaryReasonForTheNonMedicalCase_c], 
			stgc.[PrimarySecurityReason_c], 
			stgc.[ProfessionalEvent_c], 
			stgc.[ProgramClientName_c], 
			stgc.[Program_c], 
			stgc.[ProvideADescriptionOfTheCase_c], 
			stgc.[PurposeOfTrip_c], 
			stgc.[QuantityConsumed_c], 
			stgc.[Questionnaire_c], 
			stgc.[ReasonForDelay_c], 
			stgc.[Recipient_c], 
			stgc.[Registration_c], 
			stgc.[RelatedDetails_c], 
			stgc.[RelatedTreatmentHistory_c], 
			stgc.[RelationshipToPrimaryCardHolder_c], 
			stgc.[RelevantNotes_c], 
			stgc.[RentalAgencyDetails_c], 
			stgc.[RentalPeriod_c], 
			stgc.[ReplacementRequiredUrgently__c], 
			stgc.[ReportedToThePoliceAuthority_c], 
			stgc.[ReportedTo_c], 
			stgc.[ReportIDreferenceNumber_c], 
			stgc.[ReservationBookingDescription_c], 
			stgc.[RestaurantName_c], 
			stgc.[ReturnDate_c], 
			stgc.[RoadsideOrganised_c], 
			stgc.[SelectThePolicy_c], 
			stgc.[SelfPaidAmount_c], 
			stgc.[SendReplacementTicketsTo_c], 
			stgc.[SmokingRoom_c], 
			stgc.[SoughtTx_c], 
			stgc.[SpecialAssistanceDetails_c], 
			stgc.[SpecialRequests_c], 
			stgc.[SportName_c], 
			stgc.[SSAndDuration_c], 
			stgc.[StartDateOfExpatInpatAssignment__c], 
			stgc.[StudentStaffIDNumber_c], 
			stgc.[Subtype_c], 
			stgc.[TicketCategoryClass_c], 
			stgc.[TicketPurchasedOnTheCreditCard_c], 
			stgc.[TimeFrameInRelationToIncident_c], 
			stgc.[TotalCostsPaid_c], 
			stgc.[TravelBookingDate_c], 
			stgc.[TravelCreditExpiryDate_c], 
			stgc.[TravelCreditReimbursmentDetails__c], 
			stgc.[TravelDocumentsLostStolen_c], 
			stgc.[TravelingForBusiness_c], 
			stgc.[TravellingCompanionDetails_c], 
			stgc.[TravelProviderName_c], 
			stgc.[TreatmentPlanIfApplicable_c], 
			stgc.[UnableToLeaveOrCallAuthorities__c], 
			stgc.[VehicleDescription_c], 
			stgc.[VenueNameLocation_c], 
			stgc.[WasAReferralOffered_c], 
			stgc.[WasItReportedToPolice_c], 
			stgc.[WereAllPartiesWearingAHelmet_c], 
			stgc.[WereThereAnyCostsSelfPaid_c], 
			stgc.[WhatIsTheCategory_c], 
			stgc.[WhatIsTheEligibleAmount_c], 
			stgc.[WhatIsTheRequest1_c], 
			stgc.[WhatIsTheRequest_c], 
			stgc.[WhatTypeOfTicketsAreThey_c], 
			stgc.[WhenDidTheSymptomsFirstStart_c], 
			stgc.[WhenWasTreatmentSought_c], 
			stgc.[When_c], 
			stgc.[WhereDidTheyPurchaseTheirPolicy__c], 
			stgc.[WhereHowTicketsWerePurchased_c], 
			stgc.[WhereWasTreatmentSought_c], 
			stgc.[Where_c], 
			stgc.[WhoWasAtFault_c], 
			stgc.[WitnessDetails_c], 
			stgc.[WTPToArrangePaymentWithProvider_c]
		FROM [RDSLnk].[STG_RDS].[dbo].[STG_CaseQuestionnaire] stgc
			INNER JOIN atlas.[Case] c
				ON stgc.Case_c = c.Id
		WHERE stgc.[SystemModstamp] > ISNULL(@LastDateTime, '1900-01-01')
		) AS SRC
	ON DST.Id = SRC.Id

	WHEN NOT MATCHED THEN
	INSERT ([Id], 
			[IsDeleted], 
			[Currency_ISOCode], 
			[CreatedById], 
			[CreatedDate], 
			[LastModifiedDate], 
			[LastModifiedById], 
			[LastReferencedDate], 
			[LastViewedDate], 
			[SystemModstamp], 
			[Name], 
			[AccommodationCosts_c], 
			[ActivationConfirmedbyInsurer__c], 
			[AdditionalInformation1_c], 
			[AdditionalInformation__c], 
			[AdviceProvidedToCaller_c], 
			[AirlineCosts_c], 
			[Amenities__c], 
			[AMEXCardVerified_c], 
			[AMEXNACPolicy_c], 
			[AnyExclusionsApply_c], 
			[AnySpecialConditionsPreferred_c], 
			[APConfirmedAuthorisedBusinessTravel_c], 
			[APUpdatedCaseOpened_c], 
			[AreTheyImpactedByTheEvent_c], 
			[AreTheyInDanger_c], 
			[AreTheyInjured_c], 
			[AreTheyNearTheIncident_c], 
			[ArrivalDate_c], 
			[AssistanceRequired_c], 
			[AuthorizationLetterAddress_c], 
			[BenefitDetails_c], 
			[BINNumber__c], 
			[BookingReference_c], 
			[BudgetForItem_c], 
			[BudgetPerNight_c], 
			[Budget_c], 
			[CancellationInterruptionReason_c], 
			[CaseType_c], 
			[Case_c], 
			[Category_c], 
			[CityStateCountry_c], 
			[ClassOfFlight_c], 
			[Colour_c], 
			[CommercialPropertyDetails_c], 
			[CompInsuranceWithHireCarProvider_c], 
			[ConfirmedByWhichAP_c], 
			[ContactDetails_c], 
			[CountryOfCitizenship_c], 
			[CountryOfExpatInpatResidence_c], 
			[CoveredUnderTheBTAPlan_c], 
			[CoveredVehicleDefinitionMet_c], 
			[Currency_c], 
			[CurrentlyReceivingTreatment_c], 
			[CustomersCurrentLocation_c], 
			[CustomersRelationshipToEmployee_c], 
			[DateAndTimeOfTheAccidentincident_c], 
			[DateAndTime_c], 
			[DateofBookingTrip_c], 
			[DateOfNextScheduledHomeLeave_c], 
			[DatetimelocationOfFlightevent_c], 
			[DeliveryAddress_c], 
			[DeliveryDatetimeRangeRequested_c], 
			[DepartureAndArrivingLocation_c], 
			[DepartureCity1_c], 
			[DepartureDate_c], 
			[DescribeAnyInjuriesSustained__c], 
			[DescribeHowTheInjuryOccurred_c], 
			[DescriptionOfTheIllnessinjury_c], 
			[DestinationCity1_c], 
			[DetailedDescriptionOfLocation_c], 
			[DetailsOfAutoInsuranceIfNotified_c], 
			[DetailsOfVehicleInvolved_c], 
			[DiagnosisIfApplicable_c], 
			[Diagnosis_c], 
			[DidAnInjuryOccur_c], 
			[DocumentIssuer_c], 
			[DocumentLost_c], 
			[DocumentMedicalAidInformation_c], 
			[DoesTheDriverHaveCDW_c], 
			[DoesTheDriverHoldARelevantLicence_c], 
			[DoTheyHaveMedicalAidInSouthAfrica_c], 
			[DropOffLocation_c], 
			[DrugsOrAlcoholInvolved_c], 
			[DxAndTxPlan_C], 
			[EligibilityDetails_c], 
			[EmbassyconsulateNotified_c], 
			[EmployeesJobTitle__c], 
			[EndDateOfExpatInpatAssignment_c], 
			[EntertainmentType_c], 
			[ExactLocationOfTheAccidentincident_c], 
			[ExcessAccountedFor_c], 
			[ExcessOnHireVehiclePolicy_c], 
			[Excess_c], 
			[ExcludedSport_c], 
			[ExistingPrescriptionForTheMedication__c], 
			[ExplainClaimsProcessAndSendFormlin_c], 
			[FamilyFriendContactInformation__c], 
			[FinalAmount_c], 
			[FullCreditCardName_c], 
			[HasALawyerBeenEngaged_c], 
			[HaveTheyBeenContacted_c], 
			[HealthClubName_c], 
			[HighChairBoosterRequired_c], 
			[HiredFrom_c], 
			[HomeAddress_c], 
			[HomeAssistanceOrganised_c], 
			[HotelName_c], 
			[HowDoYouWantToReceiveFeedback_c], 
			[HowManyTravellersAreOnTheCancelled_c], 
			[HowWasExcessAccountedFor_c], 
			[HowWasTheTripBooked_c], 
			[InitiatorOfCancellationInterruption_c], 
			[InjuryOrDentalPainBenefit_c], 
			[IsTheSuspectPresent_c], 
			[IsThisAAssurantPolicy_c], 
			[IsThisARoadsideOrHomeAssistanceCase__c], 
			[ItemDescription1_c], 
			[ItemDescription_c], 
			[LengthOfDelay_c], 
			[LimitationsBenefitMaximumApply_c], 
			[ListDrugsalcohol_c], 
			[ListOfItemsLoststolen__c], 
			[LMOSpecialistDetails_c], 
			[LocationOfIncident_c], 
			[Location_c], 
			[MakeAndModel_c], 
			[MaxBenefitExceededForPrimaryInsurance_c], 
			[MedicalCondition_c], 
			[MedicalName_c], 
			[MessageOnDeliveryCardBox_c], 
			[Message_c], 
			[NameAndContactDetails_c], 
			[NameOfEmployerCompany_c], 
			[NameOfPersonEmployedByThisCompany_c], 
			[NameOfTheDriver_c], 
			[NameOfVehicleOwner_c], 
			[NamesOnTheTickets__c], 
			[NatureOfProblem_c], 
			[Note10_c], 
			[Note11_c], 
			[Note1_c], 
			[Note2_c], 
			[Note3_c], 
			[Note4_c], 
			[Note5_c], 
			[Note6_c], 
			[Note7_c], 
			[Note8_c], 
			[Note9_c], 
			[Note_c], 
			[NumberOfChildren_c], 
			[NumberOfPeople1_c], 
			[NumberOfPeople_c], 
			[NumberOfPets_c], 
			[ObtainAndDocumentContactInformation__c], 
			[OriginalCostOfTravel_c], 
			[OtherCosts_c], 
			[OtherDestination_c], 
			[OtherPartiesInvolved_c], 
			[OtherPrePaidArrangementsImpacted_c], 
			[OtherPrimaryCauseDetails__c], 
			[OtherTravelProviderName_c], 
			[PetDescriptionBreeds_c], 
			[PhotoIdentificationAvailable_c], 
			[PickUpLocation_c], 
			[PlanType_c], 
			[PoliceIncidentReportRequested_c], 
			[PoliceReportNumber_c], 
			[PolicyEndDate_c], 
			[PolicyStartDate_c], 
			[Policy_c], 
			[PreferredAppointmentDateTime_c], 
			[PreferredColour_c], 
			[PreferredDateAndTime_c], 
			[PreferredSize_c], 
			[PrescribersContactDetails_c], 
			[PreviousTreatmentDetails_c], 
			[PrimaryCauseOfTheInjury_c], 
			[PrimaryDestinationOfTrip_c], 
			[PrimaryReasonForTheNonMedicalCase_c], 
			[PrimarySecurityReason_c], 
			[ProfessionalEvent_c], 
			[ProgramClientName_c], 
			[Program_c], 
			[ProvideADescriptionOfTheCase_c], 
			[PurposeOfTrip_c], 
			[QuantityConsumed_c], 
			[Questionnaire_c], 
			[ReasonForDelay_c], 
			[Recipient_c], 
			[Registration_c], 
			[RelatedDetails_c], 
			[RelatedTreatmentHistory_c], 
			[RelationshipToPrimaryCardHolder_c], 
			[RelevantNotes_c], 
			[RentalAgencyDetails_c], 
			[RentalPeriod_c], 
			[ReplacementRequiredUrgently__c], 
			[ReportedToThePoliceAuthority_c], 
			[ReportedTo_c], 
			[ReportIDreferenceNumber_c], 
			[ReservationBookingDescription_c], 
			[RestaurantName_c], 
			[ReturnDate_c], 
			[RoadsideOrganised_c], 
			[SelectThePolicy_c], 
			[SelfPaidAmount_c], 
			[SendReplacementTicketsTo_c], 
			[SmokingRoom_c], 
			[SoughtTx_c], 
			[SpecialAssistanceDetails_c], 
			[SpecialRequests_c], 
			[SportName_c], 
			[SSAndDuration_c], 
			[StartDateOfExpatInpatAssignment__c], 
			[StudentStaffIDNumber_c], 
			[Subtype_c], 
			[TicketCategoryClass_c], 
			[TicketPurchasedOnTheCreditCard_c], 
			[TimeFrameInRelationToIncident_c], 
			[TotalCostsPaid_c], 
			[TravelBookingDate_c], 
			[TravelCreditExpiryDate_c], 
			[TravelCreditReimbursmentDetails__c], 
			[TravelDocumentsLostStolen_c], 
			[TravelingForBusiness_c], 
			[TravellingCompanionDetails_c], 
			[TravelProviderName_c], 
			[TreatmentPlanIfApplicable_c], 
			[UnableToLeaveOrCallAuthorities__c], 
			[VehicleDescription_c], 
			[VenueNameLocation_c], 
			[WasAReferralOffered_c], 
			[WasItReportedToPolice_c], 
			[WereAllPartiesWearingAHelmet_c], 
			[WereThereAnyCostsSelfPaid_c], 
			[WhatIsTheCategory_c], 
			[WhatIsTheEligibleAmount_c], 
			[WhatIsTheRequest1_c], 
			[WhatIsTheRequest_c], 
			[WhatTypeOfTicketsAreThey_c], 
			[WhenDidTheSymptomsFirstStart_c], 
			[WhenWasTreatmentSought_c], 
			[When_c], 
			[WhereDidTheyPurchaseTheirPolicy__c], 
			[WhereHowTicketsWerePurchased_c], 
			[WhereWasTreatmentSought_c], 
			[Where_c], 
			[WhoWasAtFault_c], 
			[WitnessDetails_c], 
			[WTPToArrangePaymentWithProvider_c])
	VALUES (SRC.[Id], 
			SRC.[IsDeleted], 
			SRC.[Currency_ISOCode], 
			SRC.[CreatedById], 
			SRC.[CreatedDate], 
			SRC.[LastModifiedDate], 
			SRC.[LastModifiedById], 
			SRC.[LastReferencedDate], 
			SRC.[LastViewedDate], 
			SRC.[SystemModstamp], 
			SRC.[Name], 
			SRC.[AccommodationCosts_c], 
			SRC.[ActivationConfirmedbyInsurer__c], 
			SRC.[AdditionalInformation1_c], 
			SRC.[AdditionalInformation__c], 
			SRC.[AdviceProvidedToCaller_c], 
			SRC.[AirlineCosts_c], 
			SRC.[Amenities__c], 
			SRC.[AMEXCardVerified_c], 
			SRC.[AMEXNACPolicy_c], 
			SRC.[AnyExclusionsApply_c], 
			SRC.[AnySpecialConditionsPreferred_c], 
			SRC.[APConfirmedAuthorisedBusinessTravel_c], 
			SRC.[APUpdatedCaseOpened_c], 
			SRC.[AreTheyImpactedByTheEvent_c], 
			SRC.[AreTheyInDanger_c], 
			SRC.[AreTheyInjured_c], 
			SRC.[AreTheyNearTheIncident_c], 
			SRC.[ArrivalDate_c], 
			SRC.[AssistanceRequired_c], 
			SRC.[AuthorizationLetterAddress_c], 
			SRC.[BenefitDetails_c], 
			SRC.[BINNumber__c], 
			SRC.[BookingReference_c], 
			SRC.[BudgetForItem_c], 
			SRC.[BudgetPerNight_c], 
			SRC.[Budget_c], 
			SRC.[CancellationInterruptionReason_c], 
			SRC.[CaseType_c], 
			SRC.[Case_c], 
			SRC.[Category_c], 
			SRC.[CityStateCountry_c], 
			SRC.[ClassOfFlight_c], 
			SRC.[Colour_c], 
			SRC.[CommercialPropertyDetails_c], 
			SRC.[CompInsuranceWithHireCarProvider_c], 
			SRC.[ConfirmedByWhichAP_c], 
			SRC.[ContactDetails_c], 
			SRC.[CountryOfCitizenship_c], 
			SRC.[CountryOfExpatInpatResidence_c], 
			SRC.[CoveredUnderTheBTAPlan_c], 
			SRC.[CoveredVehicleDefinitionMet_c], 
			SRC.[Currency_c], 
			SRC.[CurrentlyReceivingTreatment_c], 
			SRC.[CustomersCurrentLocation_c], 
			SRC.[CustomersRelationshipToEmployee_c], 
			SRC.[DateAndTimeOfTheAccidentincident_c], 
			SRC.[DateAndTime_c], 
			SRC.[DateofBookingTrip_c], 
			SRC.[DateOfNextScheduledHomeLeave_c], 
			SRC.[DatetimelocationOfFlightevent_c], 
			SRC.[DeliveryAddress_c], 
			SRC.[DeliveryDatetimeRangeRequested_c], 
			SRC.[DepartureAndArrivingLocation_c], 
			SRC.[DepartureCity1_c], 
			SRC.[DepartureDate_c], 
			SRC.[DescribeAnyInjuriesSustained__c], 
			SRC.[DescribeHowTheInjuryOccurred_c], 
			SRC.[DescriptionOfTheIllnessinjury_c], 
			SRC.[DestinationCity1_c], 
			SRC.[DetailedDescriptionOfLocation_c], 
			SRC.[DetailsOfAutoInsuranceIfNotified_c], 
			SRC.[DetailsOfVehicleInvolved_c], 
			SRC.[DiagnosisIfApplicable_c], 
			SRC.[Diagnosis_c], 
			SRC.[DidAnInjuryOccur_c], 
			SRC.[DocumentIssuer_c], 
			SRC.[DocumentLost_c], 
			SRC.[DocumentMedicalAidInformation_c], 
			SRC.[DoesTheDriverHaveCDW_c], 
			SRC.[DoesTheDriverHoldARelevantLicence_c], 
			SRC.[DoTheyHaveMedicalAidInSouthAfrica_c], 
			SRC.[DropOffLocation_c], 
			SRC.[DrugsOrAlcoholInvolved_c], 
			SRC.[DxAndTxPlan_C], 
			SRC.[EligibilityDetails_c], 
			SRC.[EmbassyconsulateNotified_c], 
			SRC.[EmployeesJobTitle__c], 
			SRC.[EndDateOfExpatInpatAssignment_c], 
			SRC.[EntertainmentType_c], 
			SRC.[ExactLocationOfTheAccidentincident_c], 
			SRC.[ExcessAccountedFor_c], 
			SRC.[ExcessOnHireVehiclePolicy_c], 
			SRC.[Excess_c], 
			SRC.[ExcludedSport_c], 
			SRC.[ExistingPrescriptionForTheMedication__c], 
			SRC.[ExplainClaimsProcessAndSendFormlin_c], 
			SRC.[FamilyFriendContactInformation__c], 
			SRC.[FinalAmount_c], 
			SRC.[FullCreditCardName_c], 
			SRC.[HasALawyerBeenEngaged_c], 
			SRC.[HaveTheyBeenContacted_c], 
			SRC.[HealthClubName_c], 
			SRC.[HighChairBoosterRequired_c], 
			SRC.[HiredFrom_c], 
			SRC.[HomeAddress_c], 
			SRC.[HomeAssistanceOrganised_c], 
			SRC.[HotelName_c], 
			SRC.[HowDoYouWantToReceiveFeedback_c], 
			SRC.[HowManyTravellersAreOnTheCancelled_c], 
			SRC.[HowWasExcessAccountedFor_c], 
			SRC.[HowWasTheTripBooked_c], 
			SRC.[InitiatorOfCancellationInterruption_c], 
			SRC.[InjuryOrDentalPainBenefit_c], 
			SRC.[IsTheSuspectPresent_c], 
			SRC.[IsThisAAssurantPolicy_c], 
			SRC.[IsThisARoadsideOrHomeAssistanceCase__c], 
			SRC.[ItemDescription1_c], 
			SRC.[ItemDescription_c], 
			SRC.[LengthOfDelay_c], 
			SRC.[LimitationsBenefitMaximumApply_c], 
			SRC.[ListDrugsalcohol_c], 
			SRC.[ListOfItemsLoststolen__c], 
			SRC.[LMOSpecialistDetails_c], 
			SRC.[LocationOfIncident_c], 
			SRC.[Location_c], 
			SRC.[MakeAndModel_c], 
			SRC.[MaxBenefitExceededForPrimaryInsurance_c], 
			SRC.[MedicalCondition_c], 
			SRC.[MedicalName_c], 
			SRC.[MessageOnDeliveryCardBox_c], 
			SRC.[Message_c], 
			SRC.[NameAndContactDetails_c], 
			SRC.[NameOfEmployerCompany_c], 
			SRC.[NameOfPersonEmployedByThisCompany_c], 
			SRC.[NameOfTheDriver_c], 
			SRC.[NameOfVehicleOwner_c], 
			SRC.[NamesOnTheTickets__c], 
			SRC.[NatureOfProblem_c], 
			SRC.[Note10_c], 
			SRC.[Note11_c], 
			SRC.[Note1_c], 
			SRC.[Note2_c], 
			SRC.[Note3_c], 
			SRC.[Note4_c], 
			SRC.[Note5_c], 
			SRC.[Note6_c], 
			SRC.[Note7_c], 
			SRC.[Note8_c], 
			SRC.[Note9_c], 
			SRC.[Note_c], 
			SRC.[NumberOfChildren_c], 
			SRC.[NumberOfPeople1_c], 
			SRC.[NumberOfPeople_c], 
			SRC.[NumberOfPets_c], 
			SRC.[ObtainAndDocumentContactInformation__c], 
			SRC.[OriginalCostOfTravel_c], 
			SRC.[OtherCosts_c], 
			SRC.[OtherDestination_c], 
			SRC.[OtherPartiesInvolved_c], 
			SRC.[OtherPrePaidArrangementsImpacted_c], 
			SRC.[OtherPrimaryCauseDetails__c], 
			SRC.[OtherTravelProviderName_c], 
			SRC.[PetDescriptionBreeds_c], 
			SRC.[PhotoIdentificationAvailable_c], 
			SRC.[PickUpLocation_c], 
			SRC.[PlanType_c], 
			SRC.[PoliceIncidentReportRequested_c], 
			SRC.[PoliceReportNumber_c], 
			SRC.[PolicyEndDate_c], 
			SRC.[PolicyStartDate_c], 
			SRC.[Policy_c], 
			SRC.[PreferredAppointmentDateTime_c], 
			SRC.[PreferredColour_c], 
			SRC.[PreferredDateAndTime_c], 
			SRC.[PreferredSize_c], 
			SRC.[PrescribersContactDetails_c], 
			SRC.[PreviousTreatmentDetails_c], 
			SRC.[PrimaryCauseOfTheInjury_c], 
			SRC.[PrimaryDestinationOfTrip_c], 
			SRC.[PrimaryReasonForTheNonMedicalCase_c], 
			SRC.[PrimarySecurityReason_c], 
			SRC.[ProfessionalEvent_c], 
			SRC.[ProgramClientName_c], 
			SRC.[Program_c], 
			SRC.[ProvideADescriptionOfTheCase_c], 
			SRC.[PurposeOfTrip_c], 
			SRC.[QuantityConsumed_c], 
			SRC.[Questionnaire_c], 
			SRC.[ReasonForDelay_c], 
			SRC.[Recipient_c], 
			SRC.[Registration_c], 
			SRC.[RelatedDetails_c], 
			SRC.[RelatedTreatmentHistory_c], 
			SRC.[RelationshipToPrimaryCardHolder_c], 
			SRC.[RelevantNotes_c], 
			SRC.[RentalAgencyDetails_c], 
			SRC.[RentalPeriod_c], 
			SRC.[ReplacementRequiredUrgently__c], 
			SRC.[ReportedToThePoliceAuthority_c], 
			SRC.[ReportedTo_c], 
			SRC.[ReportIDreferenceNumber_c], 
			SRC.[ReservationBookingDescription_c], 
			SRC.[RestaurantName_c], 
			SRC.[ReturnDate_c], 
			SRC.[RoadsideOrganised_c], 
			SRC.[SelectThePolicy_c], 
			SRC.[SelfPaidAmount_c], 
			SRC.[SendReplacementTicketsTo_c], 
			SRC.[SmokingRoom_c], 
			SRC.[SoughtTx_c], 
			SRC.[SpecialAssistanceDetails_c], 
			SRC.[SpecialRequests_c], 
			SRC.[SportName_c], 
			SRC.[SSAndDuration_c], 
			SRC.[StartDateOfExpatInpatAssignment__c], 
			SRC.[StudentStaffIDNumber_c], 
			SRC.[Subtype_c], 
			SRC.[TicketCategoryClass_c], 
			SRC.[TicketPurchasedOnTheCreditCard_c], 
			SRC.[TimeFrameInRelationToIncident_c], 
			SRC.[TotalCostsPaid_c], 
			SRC.[TravelBookingDate_c], 
			SRC.[TravelCreditExpiryDate_c], 
			SRC.[TravelCreditReimbursmentDetails__c], 
			SRC.[TravelDocumentsLostStolen_c], 
			SRC.[TravelingForBusiness_c], 
			SRC.[TravellingCompanionDetails_c], 
			SRC.[TravelProviderName_c], 
			SRC.[TreatmentPlanIfApplicable_c], 
			SRC.[UnableToLeaveOrCallAuthorities__c], 
			SRC.[VehicleDescription_c], 
			SRC.[VenueNameLocation_c], 
			SRC.[WasAReferralOffered_c], 
			SRC.[WasItReportedToPolice_c], 
			SRC.[WereAllPartiesWearingAHelmet_c], 
			SRC.[WereThereAnyCostsSelfPaid_c], 
			SRC.[WhatIsTheCategory_c], 
			SRC.[WhatIsTheEligibleAmount_c], 
			SRC.[WhatIsTheRequest1_c], 
			SRC.[WhatIsTheRequest_c], 
			SRC.[WhatTypeOfTicketsAreThey_c], 
			SRC.[WhenDidTheSymptomsFirstStart_c], 
			SRC.[WhenWasTreatmentSought_c], 
			SRC.[When_c], 
			SRC.[WhereDidTheyPurchaseTheirPolicy__c], 
			SRC.[WhereHowTicketsWerePurchased_c], 
			SRC.[WhereWasTreatmentSought_c], 
			SRC.[Where_c], 
			SRC.[WhoWasAtFault_c], 
			SRC.[WitnessDetails_c], 
			SRC.[WTPToArrangePaymentWithProvider_c])

	WHEN MATCHED AND (
			ISNULL(SRC.[IsDeleted],	'1')	<>	ISNULL(DST.[IsDeleted]	,	'1')	OR
			ISNULL(SRC.[Currency_ISOCode], 	'NULL')	<>	ISNULL(DST.[Currency_ISOCode] 	,	'NULL')	OR
			ISNULL(SRC.[CreatedById], 	'NULL')	<>	ISNULL(DST.[CreatedById] 	,	'NULL')	OR
			ISNULL(SRC.[CreatedDate], 	'1900-01-01')	<>	ISNULL(DST.[CreatedDate] 	,	'1900-01-01')	OR
			ISNULL(SRC.[LastModifiedDate], 	'1900-01-01')	<>	ISNULL(DST.[LastModifiedDate] 	,	'1900-01-01')	OR
			ISNULL(SRC.[LastModifiedById], 	'NULL')	<>	ISNULL(DST.[LastModifiedById] 	,	'NULL')	OR
			ISNULL(SRC.[LastReferencedDate], 	'1900-01-01')	<>	ISNULL(DST.[LastReferencedDate] 	,	'1900-01-01')	OR
			ISNULL(SRC.[LastViewedDate], 	'1900-01-01')	<>	ISNULL(DST.[LastViewedDate] 	,	'1900-01-01')	OR
			ISNULL(SRC.[SystemModstamp], 	'1900-01-01')	<>	ISNULL(DST.[SystemModstamp] 	,	'1900-01-01')	OR
			ISNULL(SRC.[Name], 	'NULL')	<>	ISNULL(DST.[Name] 	,	'NULL')	OR
			ISNULL(SRC.[AccommodationCosts_c], 	'NULL')	<>	ISNULL(DST.[AccommodationCosts_c] 	,	'NULL')	OR
			ISNULL(SRC.[ActivationConfirmedbyInsurer__c], 	'NULL')	<>	ISNULL(DST.[ActivationConfirmedbyInsurer__c] 	,	'NULL')	OR
			ISNULL(SRC.[AdditionalInformation1_c], 	'NULL')	<>	ISNULL(DST.[AdditionalInformation1_c] 	,	'NULL')	OR
			ISNULL(SRC.[AdditionalInformation__c], 	'NULL')	<>	ISNULL(DST.[AdditionalInformation__c] 	,	'NULL')	OR
			ISNULL(SRC.[AdviceProvidedToCaller_c], 	'NULL')	<>	ISNULL(DST.[AdviceProvidedToCaller_c] 	,	'NULL')	OR
			ISNULL(SRC.[AirlineCosts_c], 	'NULL')	<>	ISNULL(DST.[AirlineCosts_c] 	,	'NULL')	OR
			ISNULL(SRC.[Amenities__c], 	'NULL')	<>	ISNULL(DST.[Amenities__c] 	,	'NULL')	OR
			ISNULL(SRC.[AMEXCardVerified_c], 	'NULL')	<>	ISNULL(DST.[AMEXCardVerified_c] 	,	'NULL')	OR
			ISNULL(SRC.[AMEXNACPolicy_c], 	'NULL')	<>	ISNULL(DST.[AMEXNACPolicy_c] 	,	'NULL')	OR
			ISNULL(SRC.[AnyExclusionsApply_c], 	'NULL')	<>	ISNULL(DST.[AnyExclusionsApply_c] 	,	'NULL')	OR
			ISNULL(SRC.[AnySpecialConditionsPreferred_c], 	'NULL')	<>	ISNULL(DST.[AnySpecialConditionsPreferred_c] 	,	'NULL')	OR
			ISNULL(SRC.[APConfirmedAuthorisedBusinessTravel_c], 	'NULL')	<>	ISNULL(DST.[APConfirmedAuthorisedBusinessTravel_c] 	,	'NULL')	OR
			ISNULL(SRC.[APUpdatedCaseOpened_c], 	'NULL')	<>	ISNULL(DST.[APUpdatedCaseOpened_c] 	,	'NULL')	OR
			ISNULL(SRC.[AreTheyImpactedByTheEvent_c], 	'NULL')	<>	ISNULL(DST.[AreTheyImpactedByTheEvent_c] 	,	'NULL')	OR
			ISNULL(SRC.[AreTheyInDanger_c], 	'NULL')	<>	ISNULL(DST.[AreTheyInDanger_c] 	,	'NULL')	OR
			ISNULL(SRC.[AreTheyInjured_c], 	'NULL')	<>	ISNULL(DST.[AreTheyInjured_c] 	,	'NULL')	OR
			ISNULL(SRC.[AreTheyNearTheIncident_c], 	'NULL')	<>	ISNULL(DST.[AreTheyNearTheIncident_c] 	,	'NULL')	OR
			ISNULL(SRC.[ArrivalDate_c], 	'1900-01-01')	<>	ISNULL(DST.[ArrivalDate_c] 	,	'1900-01-01')	OR
			ISNULL(SRC.[AssistanceRequired_c], 	'NULL')	<>	ISNULL(DST.[AssistanceRequired_c] 	,	'NULL')	OR
			ISNULL(SRC.[AuthorizationLetterAddress_c], 	'NULL')	<>	ISNULL(DST.[AuthorizationLetterAddress_c] 	,	'NULL')	OR
			ISNULL(SRC.[BenefitDetails_c], 	'NULL')	<>	ISNULL(DST.[BenefitDetails_c] 	,	'NULL')	OR
			ISNULL(SRC.[BINNumber__c], 	'NULL')	<>	ISNULL(DST.[BINNumber__c] 	,	'NULL')	OR
			ISNULL(SRC.[BookingReference_c], 	'NULL')	<>	ISNULL(DST.[BookingReference_c] 	,	'NULL')	OR
			ISNULL(SRC.[BudgetForItem_c], 	'NULL')	<>	ISNULL(DST.[BudgetForItem_c] 	,	'NULL')	OR
			ISNULL(SRC.[BudgetPerNight_c], 	'NULL')	<>	ISNULL(DST.[BudgetPerNight_c] 	,	'NULL')	OR
			ISNULL(SRC.[Budget_c], 	'NULL')	<>	ISNULL(DST.[Budget_c] 	,	'NULL')	OR
			ISNULL(SRC.[CancellationInterruptionReason_c], 	'NULL')	<>	ISNULL(DST.[CancellationInterruptionReason_c] 	,	'NULL')	OR
			ISNULL(SRC.[CaseType_c], 	'NULL')	<>	ISNULL(DST.[CaseType_c] 	,	'NULL')	OR
			ISNULL(SRC.[Case_c], 	'NULL')	<>	ISNULL(DST.[Case_c] 	,	'NULL')	OR
			ISNULL(SRC.[Category_c], 	'NULL')	<>	ISNULL(DST.[Category_c] 	,	'NULL')	OR
			ISNULL(SRC.[CityStateCountry_c], 	'NULL')	<>	ISNULL(DST.[CityStateCountry_c] 	,	'NULL')	OR
			ISNULL(SRC.[ClassOfFlight_c], 	'NULL')	<>	ISNULL(DST.[ClassOfFlight_c] 	,	'NULL')	OR
			ISNULL(SRC.[Colour_c], 	'NULL')	<>	ISNULL(DST.[Colour_c] 	,	'NULL')	OR
			ISNULL(SRC.[CommercialPropertyDetails_c], 	'NULL')	<>	ISNULL(DST.[CommercialPropertyDetails_c] 	,	'NULL')	OR
			ISNULL(SRC.[CompInsuranceWithHireCarProvider_c], 	'NULL')	<>	ISNULL(DST.[CompInsuranceWithHireCarProvider_c] 	,	'NULL')	OR
			ISNULL(SRC.[ConfirmedByWhichAP_c], 	'NULL')	<>	ISNULL(DST.[ConfirmedByWhichAP_c] 	,	'NULL')	OR
			ISNULL(SRC.[ContactDetails_c], 	'NULL')	<>	ISNULL(DST.[ContactDetails_c] 	,	'NULL')	OR
			ISNULL(SRC.[CountryOfCitizenship_c], 	'NULL')	<>	ISNULL(DST.[CountryOfCitizenship_c] 	,	'NULL')	OR
			ISNULL(SRC.[CountryOfExpatInpatResidence_c], 	'NULL')	<>	ISNULL(DST.[CountryOfExpatInpatResidence_c] 	,	'NULL')	OR
			ISNULL(SRC.[CoveredUnderTheBTAPlan_c], 	'NULL')	<>	ISNULL(DST.[CoveredUnderTheBTAPlan_c] 	,	'NULL')	OR
			ISNULL(SRC.[CoveredVehicleDefinitionMet_c], 	'NULL')	<>	ISNULL(DST.[CoveredVehicleDefinitionMet_c] 	,	'NULL')	OR
			ISNULL(SRC.[Currency_c], 	'NULL')	<>	ISNULL(DST.[Currency_c] 	,	'NULL')	OR
			ISNULL(SRC.[CurrentlyReceivingTreatment_c], 	'NULL')	<>	ISNULL(DST.[CurrentlyReceivingTreatment_c] 	,	'NULL')	OR
			ISNULL(SRC.[CustomersCurrentLocation_c], 	'NULL')	<>	ISNULL(DST.[CustomersCurrentLocation_c] 	,	'NULL')	OR
			ISNULL(SRC.[CustomersRelationshipToEmployee_c], 	'NULL')	<>	ISNULL(DST.[CustomersRelationshipToEmployee_c] 	,	'NULL')	OR
			ISNULL(SRC.[DateAndTimeOfTheAccidentincident_c], 	'1900-01-01')	<>	ISNULL(DST.[DateAndTimeOfTheAccidentincident_c] 	,	'1900-01-01')	OR
			ISNULL(SRC.[DateAndTime_c], 	'1900-01-01')	<>	ISNULL(DST.[DateAndTime_c] 	,	'1900-01-01')	OR
			ISNULL(SRC.[DateofBookingTrip_c], 	'1900-01-01')	<>	ISNULL(DST.[DateofBookingTrip_c] 	,	'1900-01-01')	OR
			ISNULL(SRC.[DateOfNextScheduledHomeLeave_c], 	'1900-01-01')	<>	ISNULL(DST.[DateOfNextScheduledHomeLeave_c] 	,	'1900-01-01')	OR
			ISNULL(SRC.[DatetimelocationOfFlightevent_c], 	'NULL')	<>	ISNULL(DST.[DatetimelocationOfFlightevent_c] 	,	'NULL')	OR
			ISNULL(SRC.[DeliveryAddress_c], 	'NULL')	<>	ISNULL(DST.[DeliveryAddress_c] 	,	'NULL')	OR
			ISNULL(SRC.[DeliveryDatetimeRangeRequested_c], 	'NULL')	<>	ISNULL(DST.[DeliveryDatetimeRangeRequested_c] 	,	'NULL')	OR
			ISNULL(SRC.[DepartureAndArrivingLocation_c], 	'NULL')	<>	ISNULL(DST.[DepartureAndArrivingLocation_c] 	,	'NULL')	OR
			ISNULL(SRC.[DepartureCity1_c], 	'NULL')	<>	ISNULL(DST.[DepartureCity1_c] 	,	'NULL')	OR
			ISNULL(SRC.[DepartureDate_c], 	'1900-01-01')	<>	ISNULL(DST.[DepartureDate_c] 	,	'1900-01-01')	OR
			ISNULL(SRC.[DescribeAnyInjuriesSustained__c], 	'NULL')	<>	ISNULL(DST.[DescribeAnyInjuriesSustained__c] 	,	'NULL')	OR
			ISNULL(SRC.[DescribeHowTheInjuryOccurred_c], 	'NULL')	<>	ISNULL(DST.[DescribeHowTheInjuryOccurred_c] 	,	'NULL')	OR
			ISNULL(SRC.[DescriptionOfTheIllnessinjury_c], 	'NULL')	<>	ISNULL(DST.[DescriptionOfTheIllnessinjury_c] 	,	'NULL')	OR
			ISNULL(SRC.[DestinationCity1_c], 	'NULL')	<>	ISNULL(DST.[DestinationCity1_c] 	,	'NULL')	OR
			ISNULL(SRC.[DetailedDescriptionOfLocation_c], 	'NULL')	<>	ISNULL(DST.[DetailedDescriptionOfLocation_c] 	,	'NULL')	OR
			ISNULL(SRC.[DetailsOfAutoInsuranceIfNotified_c], 	'NULL')	<>	ISNULL(DST.[DetailsOfAutoInsuranceIfNotified_c] 	,	'NULL')	OR
			ISNULL(SRC.[DetailsOfVehicleInvolved_c], 	'NULL')	<>	ISNULL(DST.[DetailsOfVehicleInvolved_c] 	,	'NULL')	OR
			ISNULL(SRC.[DiagnosisIfApplicable_c], 	'NULL')	<>	ISNULL(DST.[DiagnosisIfApplicable_c] 	,	'NULL')	OR
			ISNULL(SRC.[Diagnosis_c], 	'NULL')	<>	ISNULL(DST.[Diagnosis_c] 	,	'NULL')	OR
			ISNULL(SRC.[DidAnInjuryOccur_c], 	'NULL')	<>	ISNULL(DST.[DidAnInjuryOccur_c] 	,	'NULL')	OR
			ISNULL(SRC.[DocumentIssuer_c], 	'NULL')	<>	ISNULL(DST.[DocumentIssuer_c] 	,	'NULL')	OR
			ISNULL(SRC.[DocumentLost_c], 	'NULL')	<>	ISNULL(DST.[DocumentLost_c] 	,	'NULL')	OR
			ISNULL(SRC.[DocumentMedicalAidInformation_c], 	'NULL')	<>	ISNULL(DST.[DocumentMedicalAidInformation_c] 	,	'NULL')	OR
			ISNULL(SRC.[DoesTheDriverHaveCDW_c], 	'NULL')	<>	ISNULL(DST.[DoesTheDriverHaveCDW_c] 	,	'NULL')	OR
			ISNULL(SRC.[DoesTheDriverHoldARelevantLicence_c], 	'NULL')	<>	ISNULL(DST.[DoesTheDriverHoldARelevantLicence_c] 	,	'NULL')	OR
			ISNULL(SRC.[DoTheyHaveMedicalAidInSouthAfrica_c], 	'NULL')	<>	ISNULL(DST.[DoTheyHaveMedicalAidInSouthAfrica_c] 	,	'NULL')	OR
			ISNULL(SRC.[DropOffLocation_c], 	'NULL')	<>	ISNULL(DST.[DropOffLocation_c] 	,	'NULL')	OR
			ISNULL(SRC.[DrugsOrAlcoholInvolved_c], 	'NULL')	<>	ISNULL(DST.[DrugsOrAlcoholInvolved_c] 	,	'NULL')	OR
			ISNULL(SRC.[DxAndTxPlan_C], 	'NULL')	<>	ISNULL(DST.[DxAndTxPlan_C] 	,	'NULL')	OR
			ISNULL(SRC.[EligibilityDetails_c], 	'NULL')	<>	ISNULL(DST.[EligibilityDetails_c] 	,	'NULL')	OR
			ISNULL(SRC.[EmbassyconsulateNotified_c], 	'NULL')	<>	ISNULL(DST.[EmbassyconsulateNotified_c] 	,	'NULL')	OR
			ISNULL(SRC.[EmployeesJobTitle__c], 	'NULL')	<>	ISNULL(DST.[EmployeesJobTitle__c] 	,	'NULL')	OR
			ISNULL(SRC.[EndDateOfExpatInpatAssignment_c], 	'1900-01-01')	<>	ISNULL(DST.[EndDateOfExpatInpatAssignment_c] 	,	'1900-01-01')	OR
			ISNULL(SRC.[EntertainmentType_c], 	'NULL')	<>	ISNULL(DST.[EntertainmentType_c] 	,	'NULL')	OR
			ISNULL(SRC.[ExactLocationOfTheAccidentincident_c], 	'NULL')	<>	ISNULL(DST.[ExactLocationOfTheAccidentincident_c] 	,	'NULL')	OR
			ISNULL(SRC.[ExcessAccountedFor_c], 	'NULL')	<>	ISNULL(DST.[ExcessAccountedFor_c] 	,	'NULL')	OR
			ISNULL(SRC.[ExcessOnHireVehiclePolicy_c], 	'NULL')	<>	ISNULL(DST.[ExcessOnHireVehiclePolicy_c] 	,	'NULL')	OR
			ISNULL(SRC.[Excess_c], 	'NULL')	<>	ISNULL(DST.[Excess_c] 	,	'NULL')	OR
			ISNULL(SRC.[ExcludedSport_c], 	'NULL')	<>	ISNULL(DST.[ExcludedSport_c] 	,	'NULL')	OR
			ISNULL(SRC.[ExistingPrescriptionForTheMedication__c], 	'NULL')	<>	ISNULL(DST.[ExistingPrescriptionForTheMedication__c] 	,	'NULL')	OR
			ISNULL(SRC.[ExplainClaimsProcessAndSendFormlin_c], 	'NULL')	<>	ISNULL(DST.[ExplainClaimsProcessAndSendFormlin_c] 	,	'NULL')	OR
			ISNULL(SRC.[FamilyFriendContactInformation__c], 	'NULL')	<>	ISNULL(DST.[FamilyFriendContactInformation__c] 	,	'NULL')	OR
			ISNULL(SRC.[FinalAmount_c], 	'NULL')	<>	ISNULL(DST.[FinalAmount_c] 	,	'NULL')	OR
			ISNULL(SRC.[FullCreditCardName_c], 	'NULL')	<>	ISNULL(DST.[FullCreditCardName_c] 	,	'NULL')	OR
			ISNULL(SRC.[HasALawyerBeenEngaged_c], 	'NULL')	<>	ISNULL(DST.[HasALawyerBeenEngaged_c] 	,	'NULL')	OR
			ISNULL(SRC.[HaveTheyBeenContacted_c], 	'NULL')	<>	ISNULL(DST.[HaveTheyBeenContacted_c] 	,	'NULL')	OR
			ISNULL(SRC.[HealthClubName_c], 	'NULL')	<>	ISNULL(DST.[HealthClubName_c] 	,	'NULL')	OR
			ISNULL(SRC.[HighChairBoosterRequired_c], 	'NULL')	<>	ISNULL(DST.[HighChairBoosterRequired_c] 	,	'NULL')	OR
			ISNULL(SRC.[HiredFrom_c], 	'NULL')	<>	ISNULL(DST.[HiredFrom_c] 	,	'NULL')	OR
			ISNULL(SRC.[HomeAddress_c], 	'NULL')	<>	ISNULL(DST.[HomeAddress_c] 	,	'NULL')	OR
			ISNULL(SRC.[HomeAssistanceOrganised_c], 	'NULL')	<>	ISNULL(DST.[HomeAssistanceOrganised_c] 	,	'NULL')	OR
			ISNULL(SRC.[HotelName_c], 	'NULL')	<>	ISNULL(DST.[HotelName_c] 	,	'NULL')	OR
			ISNULL(SRC.[HowDoYouWantToReceiveFeedback_c], 	'NULL')	<>	ISNULL(DST.[HowDoYouWantToReceiveFeedback_c] 	,	'NULL')	OR
			ISNULL(SRC.[HowManyTravellersAreOnTheCancelled_c], 	'NULL')	<>	ISNULL(DST.[HowManyTravellersAreOnTheCancelled_c] 	,	'NULL')	OR
			ISNULL(SRC.[HowWasExcessAccountedFor_c], 	'NULL')	<>	ISNULL(DST.[HowWasExcessAccountedFor_c] 	,	'NULL')	OR
			ISNULL(SRC.[HowWasTheTripBooked_c], 	'NULL')	<>	ISNULL(DST.[HowWasTheTripBooked_c] 	,	'NULL')	OR
			ISNULL(SRC.[InitiatorOfCancellationInterruption_c], 	'NULL')	<>	ISNULL(DST.[InitiatorOfCancellationInterruption_c] 	,	'NULL')	OR
			ISNULL(SRC.[InjuryOrDentalPainBenefit_c], 	'NULL')	<>	ISNULL(DST.[InjuryOrDentalPainBenefit_c] 	,	'NULL')	OR
			ISNULL(SRC.[IsTheSuspectPresent_c], 	'NULL')	<>	ISNULL(DST.[IsTheSuspectPresent_c] 	,	'NULL')	OR
			ISNULL(SRC.[IsThisAAssurantPolicy_c], 	'NULL')	<>	ISNULL(DST.[IsThisAAssurantPolicy_c] 	,	'NULL')	OR
			ISNULL(SRC.[IsThisARoadsideOrHomeAssistanceCase__c], 	'NULL')	<>	ISNULL(DST.[IsThisARoadsideOrHomeAssistanceCase__c] 	,	'NULL')	OR
			ISNULL(SRC.[ItemDescription1_c], 	'NULL')	<>	ISNULL(DST.[ItemDescription1_c] 	,	'NULL')	OR
			ISNULL(SRC.[ItemDescription_c], 	'NULL')	<>	ISNULL(DST.[ItemDescription_c] 	,	'NULL')	OR
			ISNULL(SRC.[LengthOfDelay_c], 	'NULL')	<>	ISNULL(DST.[LengthOfDelay_c] 	,	'NULL')	OR
			ISNULL(SRC.[LimitationsBenefitMaximumApply_c], 	'NULL')	<>	ISNULL(DST.[LimitationsBenefitMaximumApply_c] 	,	'NULL')	OR
			ISNULL(SRC.[ListDrugsalcohol_c], 	'NULL')	<>	ISNULL(DST.[ListDrugsalcohol_c] 	,	'NULL')	OR
			ISNULL(SRC.[ListOfItemsLoststolen__c], 	'NULL')	<>	ISNULL(DST.[ListOfItemsLoststolen__c] 	,	'NULL')	OR
			ISNULL(SRC.[LMOSpecialistDetails_c], 	'NULL')	<>	ISNULL(DST.[LMOSpecialistDetails_c] 	,	'NULL')	OR
			ISNULL(SRC.[LocationOfIncident_c], 	'NULL')	<>	ISNULL(DST.[LocationOfIncident_c] 	,	'NULL')	OR
			ISNULL(SRC.[Location_c], 	'NULL')	<>	ISNULL(DST.[Location_c] 	,	'NULL')	OR
			ISNULL(SRC.[MakeAndModel_c], 	'NULL')	<>	ISNULL(DST.[MakeAndModel_c] 	,	'NULL')	OR
			ISNULL(SRC.[MaxBenefitExceededForPrimaryInsurance_c], 	'NULL')	<>	ISNULL(DST.[MaxBenefitExceededForPrimaryInsurance_c] 	,	'NULL')	OR
			ISNULL(SRC.[MedicalCondition_c], 	'NULL')	<>	ISNULL(DST.[MedicalCondition_c] 	,	'NULL')	OR
			ISNULL(SRC.[MedicalName_c], 	'NULL')	<>	ISNULL(DST.[MedicalName_c] 	,	'NULL')	OR
			ISNULL(SRC.[MessageOnDeliveryCardBox_c], 	'NULL')	<>	ISNULL(DST.[MessageOnDeliveryCardBox_c] 	,	'NULL')	OR
			ISNULL(SRC.[Message_c], 	'NULL')	<>	ISNULL(DST.[Message_c] 	,	'NULL')	OR
			ISNULL(SRC.[NameAndContactDetails_c], 	'NULL')	<>	ISNULL(DST.[NameAndContactDetails_c] 	,	'NULL')	OR
			ISNULL(SRC.[NameOfEmployerCompany_c], 	'NULL')	<>	ISNULL(DST.[NameOfEmployerCompany_c] 	,	'NULL')	OR
			ISNULL(SRC.[NameOfPersonEmployedByThisCompany_c], 	'NULL')	<>	ISNULL(DST.[NameOfPersonEmployedByThisCompany_c] 	,	'NULL')	OR
			ISNULL(SRC.[NameOfTheDriver_c], 	'NULL')	<>	ISNULL(DST.[NameOfTheDriver_c] 	,	'NULL')	OR
			ISNULL(SRC.[NameOfVehicleOwner_c], 	'NULL')	<>	ISNULL(DST.[NameOfVehicleOwner_c] 	,	'NULL')	OR
			ISNULL(SRC.[NamesOnTheTickets__c], 	'NULL')	<>	ISNULL(DST.[NamesOnTheTickets__c] 	,	'NULL')	OR
			ISNULL(SRC.[NatureOfProblem_c], 	'NULL')	<>	ISNULL(DST.[NatureOfProblem_c] 	,	'NULL')	OR
			ISNULL(SRC.[Note10_c], 	'NULL')	<>	ISNULL(DST.[Note10_c] 	,	'NULL')	OR
			ISNULL(SRC.[Note11_c], 	'NULL')	<>	ISNULL(DST.[Note11_c] 	,	'NULL')	OR
			ISNULL(SRC.[Note1_c], 	'NULL')	<>	ISNULL(DST.[Note1_c] 	,	'NULL')	OR
			ISNULL(SRC.[Note2_c], 	'NULL')	<>	ISNULL(DST.[Note2_c] 	,	'NULL')	OR
			ISNULL(SRC.[Note3_c], 	'NULL')	<>	ISNULL(DST.[Note3_c] 	,	'NULL')	OR
			ISNULL(SRC.[Note4_c], 	'NULL')	<>	ISNULL(DST.[Note4_c] 	,	'NULL')	OR
			ISNULL(SRC.[Note5_c], 	'NULL')	<>	ISNULL(DST.[Note5_c] 	,	'NULL')	OR
			ISNULL(SRC.[Note6_c], 	'NULL')	<>	ISNULL(DST.[Note6_c] 	,	'NULL')	OR
			ISNULL(SRC.[Note7_c], 	'NULL')	<>	ISNULL(DST.[Note7_c] 	,	'NULL')	OR
			ISNULL(SRC.[Note8_c], 	'NULL')	<>	ISNULL(DST.[Note8_c] 	,	'NULL')	OR
			ISNULL(SRC.[Note9_c], 	'NULL')	<>	ISNULL(DST.[Note9_c] 	,	'NULL')	OR
			ISNULL(SRC.[Note_c], 	'NULL')	<>	ISNULL(DST.[Note_c] 	,	'NULL')	OR
			ISNULL(SRC.[NumberOfChildren_c], 	'NULL')	<>	ISNULL(DST.[NumberOfChildren_c] 	,	'NULL')	OR
			ISNULL(SRC.[NumberOfPeople1_c], 	'NULL')	<>	ISNULL(DST.[NumberOfPeople1_c] 	,	'NULL')	OR
			ISNULL(SRC.[NumberOfPeople_c], 	'NULL')	<>	ISNULL(DST.[NumberOfPeople_c] 	,	'NULL')	OR
			ISNULL(SRC.[NumberOfPets_c], 	'NULL')	<>	ISNULL(DST.[NumberOfPets_c] 	,	'NULL')	OR
			ISNULL(SRC.[ObtainAndDocumentContactInformation__c], 	'NULL')	<>	ISNULL(DST.[ObtainAndDocumentContactInformation__c] 	,	'NULL')	OR
			ISNULL(SRC.[OriginalCostOfTravel_c], 	'NULL')	<>	ISNULL(DST.[OriginalCostOfTravel_c] 	,	'NULL')	OR
			ISNULL(SRC.[OtherCosts_c], 	'NULL')	<>	ISNULL(DST.[OtherCosts_c] 	,	'NULL')	OR
			ISNULL(SRC.[OtherDestination_c], 	'NULL')	<>	ISNULL(DST.[OtherDestination_c] 	,	'NULL')	OR
			ISNULL(SRC.[OtherPartiesInvolved_c], 	'NULL')	<>	ISNULL(DST.[OtherPartiesInvolved_c] 	,	'NULL')	OR
			ISNULL(SRC.[OtherPrePaidArrangementsImpacted_c], 	'NULL')	<>	ISNULL(DST.[OtherPrePaidArrangementsImpacted_c] 	,	'NULL')	OR
			ISNULL(SRC.[OtherPrimaryCauseDetails__c], 	'NULL')	<>	ISNULL(DST.[OtherPrimaryCauseDetails__c] 	,	'NULL')	OR
			ISNULL(SRC.[OtherTravelProviderName_c], 	'NULL')	<>	ISNULL(DST.[OtherTravelProviderName_c] 	,	'NULL')	OR
			ISNULL(SRC.[PetDescriptionBreeds_c], 	'NULL')	<>	ISNULL(DST.[PetDescriptionBreeds_c] 	,	'NULL')	OR
			ISNULL(SRC.[PhotoIdentificationAvailable_c], 	'NULL')	<>	ISNULL(DST.[PhotoIdentificationAvailable_c] 	,	'NULL')	OR
			ISNULL(SRC.[PickUpLocation_c], 	'NULL')	<>	ISNULL(DST.[PickUpLocation_c] 	,	'NULL')	OR
			ISNULL(SRC.[PlanType_c], 	'NULL')	<>	ISNULL(DST.[PlanType_c] 	,	'NULL')	OR
			ISNULL(SRC.[PoliceIncidentReportRequested_c], 	'NULL')	<>	ISNULL(DST.[PoliceIncidentReportRequested_c] 	,	'NULL')	OR
			ISNULL(SRC.[PoliceReportNumber_c], 	'NULL')	<>	ISNULL(DST.[PoliceReportNumber_c] 	,	'NULL')	OR
			ISNULL(SRC.[PolicyEndDate_c], 	'1900-01-01')	<>	ISNULL(DST.[PolicyEndDate_c] 	,	'1900-01-01')	OR
			ISNULL(SRC.[PolicyStartDate_c], 	'1900-01-01')	<>	ISNULL(DST.[PolicyStartDate_c] 	,	'1900-01-01')	OR
			ISNULL(SRC.[Policy_c], 	'NULL')	<>	ISNULL(DST.[Policy_c] 	,	'NULL')	OR
			ISNULL(SRC.[PreferredAppointmentDateTime_c], 	'1900-01-01')	<>	ISNULL(DST.[PreferredAppointmentDateTime_c] 	,	'1900-01-01')	OR
			ISNULL(SRC.[PreferredColour_c], 	'NULL')	<>	ISNULL(DST.[PreferredColour_c] 	,	'NULL')	OR
			ISNULL(SRC.[PreferredDateAndTime_c], 	'1900-01-01')	<>	ISNULL(DST.[PreferredDateAndTime_c] 	,	'1900-01-01')	OR
			ISNULL(SRC.[PreferredSize_c], 	'NULL')	<>	ISNULL(DST.[PreferredSize_c] 	,	'NULL')	OR
			ISNULL(SRC.[PrescribersContactDetails_c], 	'NULL')	<>	ISNULL(DST.[PrescribersContactDetails_c] 	,	'NULL')	OR
			ISNULL(SRC.[PreviousTreatmentDetails_c], 	'NULL')	<>	ISNULL(DST.[PreviousTreatmentDetails_c] 	,	'NULL')	OR
			ISNULL(SRC.[PrimaryCauseOfTheInjury_c], 	'NULL')	<>	ISNULL(DST.[PrimaryCauseOfTheInjury_c] 	,	'NULL')	OR
			ISNULL(SRC.[PrimaryDestinationOfTrip_c], 	'NULL')	<>	ISNULL(DST.[PrimaryDestinationOfTrip_c] 	,	'NULL')	OR
			ISNULL(SRC.[PrimaryReasonForTheNonMedicalCase_c], 	'NULL')	<>	ISNULL(DST.[PrimaryReasonForTheNonMedicalCase_c] 	,	'NULL')	OR
			ISNULL(SRC.[PrimarySecurityReason_c], 	'NULL')	<>	ISNULL(DST.[PrimarySecurityReason_c] 	,	'NULL')	OR
			ISNULL(SRC.[ProfessionalEvent_c], 	'NULL')	<>	ISNULL(DST.[ProfessionalEvent_c] 	,	'NULL')	OR
			ISNULL(SRC.[ProgramClientName_c], 	'NULL')	<>	ISNULL(DST.[ProgramClientName_c] 	,	'NULL')	OR
			ISNULL(SRC.[Program_c], 	'NULL')	<>	ISNULL(DST.[Program_c] 	,	'NULL')	OR
			ISNULL(SRC.[ProvideADescriptionOfTheCase_c], 	'NULL')	<>	ISNULL(DST.[ProvideADescriptionOfTheCase_c] 	,	'NULL')	OR
			ISNULL(SRC.[PurposeOfTrip_c], 	'NULL')	<>	ISNULL(DST.[PurposeOfTrip_c] 	,	'NULL')	OR
			ISNULL(SRC.[QuantityConsumed_c], 	'NULL')	<>	ISNULL(DST.[QuantityConsumed_c] 	,	'NULL')	OR
			ISNULL(SRC.[Questionnaire_c], 	'NULL')	<>	ISNULL(DST.[Questionnaire_c] 	,	'NULL')	OR
			ISNULL(SRC.[ReasonForDelay_c], 	'NULL')	<>	ISNULL(DST.[ReasonForDelay_c] 	,	'NULL')	OR
			ISNULL(SRC.[Recipient_c], 	'NULL')	<>	ISNULL(DST.[Recipient_c] 	,	'NULL')	OR
			ISNULL(SRC.[Registration_c], 	'NULL')	<>	ISNULL(DST.[Registration_c] 	,	'NULL')	OR
			ISNULL(SRC.[RelatedDetails_c], 	'NULL')	<>	ISNULL(DST.[RelatedDetails_c] 	,	'NULL')	OR
			ISNULL(SRC.[RelatedTreatmentHistory_c], 	'NULL')	<>	ISNULL(DST.[RelatedTreatmentHistory_c] 	,	'NULL')	OR
			ISNULL(SRC.[RelationshipToPrimaryCardHolder_c], 	'NULL')	<>	ISNULL(DST.[RelationshipToPrimaryCardHolder_c] 	,	'NULL')	OR
			ISNULL(SRC.[RelevantNotes_c], 	'NULL')	<>	ISNULL(DST.[RelevantNotes_c] 	,	'NULL')	OR
			ISNULL(SRC.[RentalAgencyDetails_c], 	'NULL')	<>	ISNULL(DST.[RentalAgencyDetails_c] 	,	'NULL')	OR
			ISNULL(SRC.[RentalPeriod_c], 	'NULL')	<>	ISNULL(DST.[RentalPeriod_c] 	,	'NULL')	OR
			ISNULL(SRC.[ReplacementRequiredUrgently__c], 	'NULL')	<>	ISNULL(DST.[ReplacementRequiredUrgently__c] 	,	'NULL')	OR
			ISNULL(SRC.[ReportedToThePoliceAuthority_c], 	'NULL')	<>	ISNULL(DST.[ReportedToThePoliceAuthority_c] 	,	'NULL')	OR
			ISNULL(SRC.[ReportedTo_c], 	'NULL')	<>	ISNULL(DST.[ReportedTo_c] 	,	'NULL')	OR
			ISNULL(SRC.[ReportIDreferenceNumber_c], 	'NULL')	<>	ISNULL(DST.[ReportIDreferenceNumber_c] 	,	'NULL')	OR
			ISNULL(SRC.[ReservationBookingDescription_c], 	'NULL')	<>	ISNULL(DST.[ReservationBookingDescription_c] 	,	'NULL')	OR
			ISNULL(SRC.[RestaurantName_c], 	'NULL')	<>	ISNULL(DST.[RestaurantName_c] 	,	'NULL')	OR
			ISNULL(SRC.[ReturnDate_c], 	'1900-01-01')	<>	ISNULL(DST.[ReturnDate_c] 	,	'1900-01-01')	OR
			ISNULL(SRC.[RoadsideOrganised_c], 	'NULL')	<>	ISNULL(DST.[RoadsideOrganised_c] 	,	'NULL')	OR
			ISNULL(SRC.[SelectThePolicy_c], 	'NULL')	<>	ISNULL(DST.[SelectThePolicy_c] 	,	'NULL')	OR
			ISNULL(SRC.[SelfPaidAmount_c], 	'NULL')	<>	ISNULL(DST.[SelfPaidAmount_c] 	,	'NULL')	OR
			ISNULL(SRC.[SendReplacementTicketsTo_c], 	'NULL')	<>	ISNULL(DST.[SendReplacementTicketsTo_c] 	,	'NULL')	OR
			ISNULL(SRC.[SmokingRoom_c], 	'NULL')	<>	ISNULL(DST.[SmokingRoom_c] 	,	'NULL')	OR
			ISNULL(SRC.[SoughtTx_c], 	'NULL')	<>	ISNULL(DST.[SoughtTx_c] 	,	'NULL')	OR
			ISNULL(SRC.[SpecialAssistanceDetails_c], 	'NULL')	<>	ISNULL(DST.[SpecialAssistanceDetails_c] 	,	'NULL')	OR
			ISNULL(SRC.[SpecialRequests_c], 	'NULL')	<>	ISNULL(DST.[SpecialRequests_c] 	,	'NULL')	OR
			ISNULL(SRC.[SportName_c], 	'NULL')	<>	ISNULL(DST.[SportName_c] 	,	'NULL')	OR
			ISNULL(SRC.[SSAndDuration_c], 	'NULL')	<>	ISNULL(DST.[SSAndDuration_c] 	,	'NULL')	OR
			ISNULL(SRC.[StartDateOfExpatInpatAssignment__c], 	'1900-01-01')	<>	ISNULL(DST.[StartDateOfExpatInpatAssignment__c] 	,	'1900-01-01')	OR
			ISNULL(SRC.[StudentStaffIDNumber_c], 	'NULL')	<>	ISNULL(DST.[StudentStaffIDNumber_c] 	,	'NULL')	OR
			ISNULL(SRC.[Subtype_c], 	'NULL')	<>	ISNULL(DST.[Subtype_c] 	,	'NULL')	OR
			ISNULL(SRC.[TicketCategoryClass_c], 	'NULL')	<>	ISNULL(DST.[TicketCategoryClass_c] 	,	'NULL')	OR
			ISNULL(SRC.[TicketPurchasedOnTheCreditCard_c], 	'NULL')	<>	ISNULL(DST.[TicketPurchasedOnTheCreditCard_c] 	,	'NULL')	OR
			ISNULL(SRC.[TimeFrameInRelationToIncident_c], 	'NULL')	<>	ISNULL(DST.[TimeFrameInRelationToIncident_c] 	,	'NULL')	OR
			ISNULL(SRC.[TotalCostsPaid_c], 	'NULL')	<>	ISNULL(DST.[TotalCostsPaid_c] 	,	'NULL')	OR
			ISNULL(SRC.[TravelBookingDate_c], 	'1900-01-01')	<>	ISNULL(DST.[TravelBookingDate_c] 	,	'1900-01-01')	OR
			ISNULL(SRC.[TravelCreditExpiryDate_c], 	'1900-01-01')	<>	ISNULL(DST.[TravelCreditExpiryDate_c] 	,	'1900-01-01')	OR
			ISNULL(SRC.[TravelCreditReimbursmentDetails__c], 	'NULL')	<>	ISNULL(DST.[TravelCreditReimbursmentDetails__c] 	,	'NULL')	OR
			ISNULL(SRC.[TravelDocumentsLostStolen_c], 	'NULL')	<>	ISNULL(DST.[TravelDocumentsLostStolen_c] 	,	'NULL')	OR
			ISNULL(SRC.[TravelingForBusiness_c], 	'NULL')	<>	ISNULL(DST.[TravelingForBusiness_c] 	,	'NULL')	OR
			ISNULL(SRC.[TravellingCompanionDetails_c], 	'NULL')	<>	ISNULL(DST.[TravellingCompanionDetails_c] 	,	'NULL')	OR
			ISNULL(SRC.[TravelProviderName_c], 	'NULL')	<>	ISNULL(DST.[TravelProviderName_c] 	,	'NULL')	OR
			ISNULL(SRC.[TreatmentPlanIfApplicable_c], 	'NULL')	<>	ISNULL(DST.[TreatmentPlanIfApplicable_c] 	,	'NULL')	OR
			ISNULL(SRC.[UnableToLeaveOrCallAuthorities__c], 	'NULL')	<>	ISNULL(DST.[UnableToLeaveOrCallAuthorities__c] 	,	'NULL')	OR
			ISNULL(SRC.[VehicleDescription_c], 	'NULL')	<>	ISNULL(DST.[VehicleDescription_c] 	,	'NULL')	OR
			ISNULL(SRC.[VenueNameLocation_c], 	'NULL')	<>	ISNULL(DST.[VenueNameLocation_c] 	,	'NULL')	OR
			ISNULL(SRC.[WasAReferralOffered_c], 	'NULL')	<>	ISNULL(DST.[WasAReferralOffered_c] 	,	'NULL')	OR
			ISNULL(SRC.[WasItReportedToPolice_c], 	'NULL')	<>	ISNULL(DST.[WasItReportedToPolice_c] 	,	'NULL')	OR
			ISNULL(SRC.[WereAllPartiesWearingAHelmet_c], 	'NULL')	<>	ISNULL(DST.[WereAllPartiesWearingAHelmet_c] 	,	'NULL')	OR
			ISNULL(SRC.[WereThereAnyCostsSelfPaid_c], 	'NULL')	<>	ISNULL(DST.[WereThereAnyCostsSelfPaid_c] 	,	'NULL')	OR
			ISNULL(SRC.[WhatIsTheCategory_c], 	'NULL')	<>	ISNULL(DST.[WhatIsTheCategory_c] 	,	'NULL')	OR
			ISNULL(SRC.[WhatIsTheEligibleAmount_c], 	'NULL')	<>	ISNULL(DST.[WhatIsTheEligibleAmount_c] 	,	'NULL')	OR
			ISNULL(SRC.[WhatIsTheRequest1_c], 	'NULL')	<>	ISNULL(DST.[WhatIsTheRequest1_c] 	,	'NULL')	OR
			ISNULL(SRC.[WhatIsTheRequest_c], 	'NULL')	<>	ISNULL(DST.[WhatIsTheRequest_c] 	,	'NULL')	OR
			ISNULL(SRC.[WhatTypeOfTicketsAreThey_c], 	'NULL')	<>	ISNULL(DST.[WhatTypeOfTicketsAreThey_c] 	,	'NULL')	OR
			ISNULL(SRC.[WhenDidTheSymptomsFirstStart_c], 	'1900-01-01')	<>	ISNULL(DST.[WhenDidTheSymptomsFirstStart_c] 	,	'1900-01-01')	OR
			ISNULL(SRC.[WhenWasTreatmentSought_c], 	'1900-01-01')	<>	ISNULL(DST.[WhenWasTreatmentSought_c] 	,	'1900-01-01')	OR
			ISNULL(SRC.[When_c], 	'NULL')	<>	ISNULL(DST.[When_c] 	,	'NULL')	OR
			ISNULL(SRC.[WhereDidTheyPurchaseTheirPolicy__c], 	'NULL')	<>	ISNULL(DST.[WhereDidTheyPurchaseTheirPolicy__c] 	,	'NULL')	OR
			ISNULL(SRC.[WhereHowTicketsWerePurchased_c], 	'NULL')	<>	ISNULL(DST.[WhereHowTicketsWerePurchased_c] 	,	'NULL')	OR
			ISNULL(SRC.[WhereWasTreatmentSought_c], 	'NULL')	<>	ISNULL(DST.[WhereWasTreatmentSought_c] 	,	'NULL')	OR
			ISNULL(SRC.[Where_c], 	'NULL')	<>	ISNULL(DST.[Where_c] 	,	'NULL')	OR
			ISNULL(SRC.[WhoWasAtFault_c], 	'NULL')	<>	ISNULL(DST.[WhoWasAtFault_c] 	,	'NULL')	OR
			ISNULL(SRC.[WitnessDetails_c], 	'NULL')	<>	ISNULL(DST.[WitnessDetails_c] 	,	'NULL')	OR
			ISNULL(SRC.[WTPToArrangePaymentWithProvider_c],	'NULL')	<>	ISNULL(DST.[WTPToArrangePaymentWithProvider_c]	,	'NULL')
		)
	THEN UPDATE
		SET DST.[IsDeleted] 	=	SRC.[IsDeleted],
			DST.[Currency_ISOCode] 	=	SRC.[Currency_ISOCode] ,
			DST.[CreatedById] 	=	SRC.[CreatedById] ,
			DST.[CreatedDate] 	=	SRC.[CreatedDate] ,
			DST.[LastModifiedDate] 	=	SRC.[LastModifiedDate] ,
			DST.[LastModifiedById] 	=	SRC.[LastModifiedById] ,
			DST.[LastReferencedDate] 	=	SRC.[LastReferencedDate] ,
			DST.[LastViewedDate] 	=	SRC.[LastViewedDate] ,
			DST.[SystemModstamp] 	=	SRC.[SystemModstamp] ,
			DST.[Name] 	=	SRC.[Name] ,
			DST.[AccommodationCosts_c] 	=	SRC.[AccommodationCosts_c] ,
			DST.[ActivationConfirmedbyInsurer__c] 	=	SRC.[ActivationConfirmedbyInsurer__c] ,
			DST.[AdditionalInformation1_c] 	=	SRC.[AdditionalInformation1_c] ,
			DST.[AdditionalInformation__c] 	=	SRC.[AdditionalInformation__c] ,
			DST.[AdviceProvidedToCaller_c] 	=	SRC.[AdviceProvidedToCaller_c] ,
			DST.[AirlineCosts_c] 	=	SRC.[AirlineCosts_c] ,
			DST.[Amenities__c] 	=	SRC.[Amenities__c] ,
			DST.[AMEXCardVerified_c] 	=	SRC.[AMEXCardVerified_c] ,
			DST.[AMEXNACPolicy_c] 	=	SRC.[AMEXNACPolicy_c] ,
			DST.[AnyExclusionsApply_c] 	=	SRC.[AnyExclusionsApply_c] ,
			DST.[AnySpecialConditionsPreferred_c] 	=	SRC.[AnySpecialConditionsPreferred_c] ,
			DST.[APConfirmedAuthorisedBusinessTravel_c] 	=	SRC.[APConfirmedAuthorisedBusinessTravel_c],
			DST.[APUpdatedCaseOpened_c] 	=	SRC.[APUpdatedCaseOpened_c] ,
			DST.[AreTheyImpactedByTheEvent_c] 	=	SRC.[AreTheyImpactedByTheEvent_c] ,
			DST.[AreTheyInDanger_c] 	=	SRC.[AreTheyInDanger_c] ,
			DST.[AreTheyInjured_c] 	=	SRC.[AreTheyInjured_c] ,
			DST.[AreTheyNearTheIncident_c] 	=	SRC.[AreTheyNearTheIncident_c] ,
			DST.[ArrivalDate_c] 	=	SRC.[ArrivalDate_c] ,
			DST.[AssistanceRequired_c] 	=	SRC.[AssistanceRequired_c] ,
			DST.[AuthorizationLetterAddress_c] 	=	SRC.[AuthorizationLetterAddress_c] ,
			DST.[BenefitDetails_c] 	=	SRC.[BenefitDetails_c] ,
			DST.[BINNumber__c] 	=	SRC.[BINNumber__c] ,
			DST.[BookingReference_c] 	=	SRC.[BookingReference_c] ,
			DST.[BudgetForItem_c] 	=	SRC.[BudgetForItem_c] ,
			DST.[BudgetPerNight_c] 	=	SRC.[BudgetPerNight_c] ,
			DST.[Budget_c] 	=	SRC.[Budget_c] ,
			DST.[CancellationInterruptionReason_c] 	=	SRC.[CancellationInterruptionReason_c] ,
			DST.[CaseType_c] 	=	SRC.[CaseType_c] ,
			DST.[Case_c] 	=	SRC.[Case_c] ,
			DST.[Category_c] 	=	SRC.[Category_c] ,
			DST.[CityStateCountry_c] 	=	SRC.[CityStateCountry_c] ,
			DST.[ClassOfFlight_c] 	=	SRC.[ClassOfFlight_c] ,
			DST.[Colour_c] 	=	SRC.[Colour_c] ,
			DST.[CommercialPropertyDetails_c] 	=	SRC.[CommercialPropertyDetails_c] ,
			DST.[CompInsuranceWithHireCarProvider_c] 	=	SRC.[CompInsuranceWithHireCarProvider_c] ,
			DST.[ConfirmedByWhichAP_c] 	=	SRC.[ConfirmedByWhichAP_c] ,
			DST.[ContactDetails_c] 	=	SRC.[ContactDetails_c] ,
			DST.[CountryOfCitizenship_c] 	=	SRC.[CountryOfCitizenship_c] ,
			DST.[CountryOfExpatInpatResidence_c] 	=	SRC.[CountryOfExpatInpatResidence_c] ,
			DST.[CoveredUnderTheBTAPlan_c] 	=	SRC.[CoveredUnderTheBTAPlan_c] ,
			DST.[CoveredVehicleDefinitionMet_c] 	=	SRC.[CoveredVehicleDefinitionMet_c] ,
			DST.[Currency_c] 	=	SRC.[Currency_c] ,
			DST.[CurrentlyReceivingTreatment_c] 	=	SRC.[CurrentlyReceivingTreatment_c] ,
			DST.[CustomersCurrentLocation_c] 	=	SRC.[CustomersCurrentLocation_c] ,
			DST.[CustomersRelationshipToEmployee_c] 	=	SRC.[CustomersRelationshipToEmployee_c] ,
			DST.[DateAndTimeOfTheAccidentincident_c] 	=	SRC.[DateAndTimeOfTheAccidentincident_c] ,
			DST.[DateAndTime_c] 	=	SRC.[DateAndTime_c] ,
			DST.[DateofBookingTrip_c] 	=	SRC.[DateofBookingTrip_c] ,
			DST.[DateOfNextScheduledHomeLeave_c] 	=	SRC.[DateOfNextScheduledHomeLeave_c] ,
			DST.[DatetimelocationOfFlightevent_c] 	=	SRC.[DatetimelocationOfFlightevent_c] ,
			DST.[DeliveryAddress_c] 	=	SRC.[DeliveryAddress_c] ,
			DST.[DeliveryDatetimeRangeRequested_c] 	=	SRC.[DeliveryDatetimeRangeRequested_c] ,
			DST.[DepartureAndArrivingLocation_c] 	=	SRC.[DepartureAndArrivingLocation_c] ,
			DST.[DepartureCity1_c] 	=	SRC.[DepartureCity1_c] ,
			DST.[DepartureDate_c] 	=	SRC.[DepartureDate_c] ,
			DST.[DescribeAnyInjuriesSustained__c] 	=	SRC.[DescribeAnyInjuriesSustained__c] ,
			DST.[DescribeHowTheInjuryOccurred_c] 	=	SRC.[DescribeHowTheInjuryOccurred_c] ,
			DST.[DescriptionOfTheIllnessinjury_c] 	=	SRC.[DescriptionOfTheIllnessinjury_c] ,
			DST.[DestinationCity1_c] 	=	SRC.[DestinationCity1_c] ,
			DST.[DetailedDescriptionOfLocation_c] 	=	SRC.[DetailedDescriptionOfLocation_c] ,
			DST.[DetailsOfAutoInsuranceIfNotified_c] 	=	SRC.[DetailsOfAutoInsuranceIfNotified_c] ,
			DST.[DetailsOfVehicleInvolved_c] 	=	SRC.[DetailsOfVehicleInvolved_c] ,
			DST.[DiagnosisIfApplicable_c] 	=	SRC.[DiagnosisIfApplicable_c] ,
			DST.[Diagnosis_c] 	=	SRC.[Diagnosis_c] ,
			DST.[DidAnInjuryOccur_c] 	=	SRC.[DidAnInjuryOccur_c] ,
			DST.[DocumentIssuer_c] 	=	SRC.[DocumentIssuer_c] ,
			DST.[DocumentLost_c] 	=	SRC.[DocumentLost_c] ,
			DST.[DocumentMedicalAidInformation_c] 	=	SRC.[DocumentMedicalAidInformation_c] ,
			DST.[DoesTheDriverHaveCDW_c] 	=	SRC.[DoesTheDriverHaveCDW_c] ,
			DST.[DoesTheDriverHoldARelevantLicence_c] 	=	SRC.[DoesTheDriverHoldARelevantLicence_c] ,
			DST.[DoTheyHaveMedicalAidInSouthAfrica_c] 	=	SRC.[DoTheyHaveMedicalAidInSouthAfrica_c] ,
			DST.[DropOffLocation_c] 	=	SRC.[DropOffLocation_c] ,
			DST.[DrugsOrAlcoholInvolved_c] 	=	SRC.[DrugsOrAlcoholInvolved_c] ,
			DST.[DxAndTxPlan_C] 	=	SRC.[DxAndTxPlan_C] ,
			DST.[EligibilityDetails_c] 	=	SRC.[EligibilityDetails_c] ,
			DST.[EmbassyconsulateNotified_c] 	=	SRC.[EmbassyconsulateNotified_c] ,
			DST.[EmployeesJobTitle__c] 	=	SRC.[EmployeesJobTitle__c] ,
			DST.[EndDateOfExpatInpatAssignment_c] 	=	SRC.[EndDateOfExpatInpatAssignment_c] ,
			DST.[EntertainmentType_c] 	=	SRC.[EntertainmentType_c] ,
			DST.[ExactLocationOfTheAccidentincident_c] 	=	SRC.[ExactLocationOfTheAccidentincident_c] ,
			DST.[ExcessAccountedFor_c] 	=	SRC.[ExcessAccountedFor_c] ,
			DST.[ExcessOnHireVehiclePolicy_c] 	=	SRC.[ExcessOnHireVehiclePolicy_c] ,
			DST.[Excess_c] 	=	SRC.[Excess_c] ,
			DST.[ExcludedSport_c] 	=	SRC.[ExcludedSport_c] ,
			DST.[ExistingPrescriptionForTheMedication__c] 	=	SRC.[ExistingPrescriptionForTheMedication__c] ,
			DST.[ExplainClaimsProcessAndSendFormlin_c] 	=	SRC.[ExplainClaimsProcessAndSendFormlin_c] ,
			DST.[FamilyFriendContactInformation__c] 	=	SRC.[FamilyFriendContactInformation__c] ,
			DST.[FinalAmount_c] 	=	SRC.[FinalAmount_c] ,
			DST.[FullCreditCardName_c] 	=	SRC.[FullCreditCardName_c] ,
			DST.[HasALawyerBeenEngaged_c] 	=	SRC.[HasALawyerBeenEngaged_c] ,
			DST.[HaveTheyBeenContacted_c] 	=	SRC.[HaveTheyBeenContacted_c] ,
			DST.[HealthClubName_c] 	=	SRC.[HealthClubName_c] ,
			DST.[HighChairBoosterRequired_c] 	=	SRC.[HighChairBoosterRequired_c] ,
			DST.[HiredFrom_c] 	=	SRC.[HiredFrom_c] ,
			DST.[HomeAddress_c] 	=	SRC.[HomeAddress_c] ,
			DST.[HomeAssistanceOrganised_c] 	=	SRC.[HomeAssistanceOrganised_c] ,
			DST.[HotelName_c] 	=	SRC.[HotelName_c] ,
			DST.[HowDoYouWantToReceiveFeedback_c] 	=	SRC.[HowDoYouWantToReceiveFeedback_c] ,
			DST.[HowManyTravellersAreOnTheCancelled_c] 	=	SRC.[HowManyTravellersAreOnTheCancelled_c] ,
			DST.[HowWasExcessAccountedFor_c] 	=	SRC.[HowWasExcessAccountedFor_c] ,
			DST.[HowWasTheTripBooked_c] 	=	SRC.[HowWasTheTripBooked_c] ,
			DST.[InitiatorOfCancellationInterruption_c] 	=	SRC.[InitiatorOfCancellationInterruption_c] ,
			DST.[InjuryOrDentalPainBenefit_c] 	=	SRC.[InjuryOrDentalPainBenefit_c] ,
			DST.[IsTheSuspectPresent_c] 	=	SRC.[IsTheSuspectPresent_c] ,
			DST.[IsThisAAssurantPolicy_c] 	=	SRC.[IsThisAAssurantPolicy_c] ,
			DST.[IsThisARoadsideOrHomeAssistanceCase__c] 	=	SRC.[IsThisARoadsideOrHomeAssistanceCase__c] ,
			DST.[ItemDescription1_c] 	=	SRC.[ItemDescription1_c] ,
			DST.[ItemDescription_c] 	=	SRC.[ItemDescription_c] ,
			DST.[LengthOfDelay_c] 	=	SRC.[LengthOfDelay_c] ,
			DST.[LimitationsBenefitMaximumApply_c] 	=	SRC.[LimitationsBenefitMaximumApply_c] ,
			DST.[ListDrugsalcohol_c] 	=	SRC.[ListDrugsalcohol_c] ,
			DST.[ListOfItemsLoststolen__c] 	=	SRC.[ListOfItemsLoststolen__c] ,
			DST.[LMOSpecialistDetails_c] 	=	SRC.[LMOSpecialistDetails_c] ,
			DST.[LocationOfIncident_c] 	=	SRC.[LocationOfIncident_c] ,
			DST.[Location_c] 	=	SRC.[Location_c] ,
			DST.[MakeAndModel_c] 	=	SRC.[MakeAndModel_c] ,
			DST.[MaxBenefitExceededForPrimaryInsurance_c] 	=	SRC.[MaxBenefitExceededForPrimaryInsurance_c] ,
			DST.[MedicalCondition_c] 	=	SRC.[MedicalCondition_c] ,
			DST.[MedicalName_c] 	=	SRC.[MedicalName_c] ,
			DST.[MessageOnDeliveryCardBox_c] 	=	SRC.[MessageOnDeliveryCardBox_c] ,
			DST.[Message_c] 	=	SRC.[Message_c] ,
			DST.[NameAndContactDetails_c] 	=	SRC.[NameAndContactDetails_c] ,
			DST.[NameOfEmployerCompany_c] 	=	SRC.[NameOfEmployerCompany_c] ,
			DST.[NameOfPersonEmployedByThisCompany_c] 	=	SRC.[NameOfPersonEmployedByThisCompany_c] ,
			DST.[NameOfTheDriver_c] 	=	SRC.[NameOfTheDriver_c] ,
			DST.[NameOfVehicleOwner_c] 	=	SRC.[NameOfVehicleOwner_c] ,
			DST.[NamesOnTheTickets__c] 	=	SRC.[NamesOnTheTickets__c] ,
			DST.[NatureOfProblem_c] 	=	SRC.[NatureOfProblem_c] ,
			DST.[Note10_c] 	=	SRC.[Note10_c] ,
			DST.[Note11_c] 	=	SRC.[Note11_c] ,
			DST.[Note1_c] 	=	SRC.[Note1_c] ,
			DST.[Note2_c] 	=	SRC.[Note2_c] ,
			DST.[Note3_c] 	=	SRC.[Note3_c] ,
			DST.[Note4_c] 	=	SRC.[Note4_c] ,
			DST.[Note5_c] 	=	SRC.[Note5_c] ,
			DST.[Note6_c] 	=	SRC.[Note6_c] ,
			DST.[Note7_c] 	=	SRC.[Note7_c] ,
			DST.[Note8_c] 	=	SRC.[Note8_c] ,
			DST.[Note9_c] 	=	SRC.[Note9_c] ,
			DST.[Note_c] 	=	SRC.[Note_c] ,
			DST.[NumberOfChildren_c] 	=	SRC.[NumberOfChildren_c] ,
			DST.[NumberOfPeople1_c] 	=	SRC.[NumberOfPeople1_c] ,
			DST.[NumberOfPeople_c] 	=	SRC.[NumberOfPeople_c] ,
			DST.[NumberOfPets_c] 	=	SRC.[NumberOfPets_c] ,
			DST.[ObtainAndDocumentContactInformation__c] 	=	SRC.[ObtainAndDocumentContactInformation__c] ,
			DST.[OriginalCostOfTravel_c] 	=	SRC.[OriginalCostOfTravel_c] ,
			DST.[OtherCosts_c] 	=	SRC.[OtherCosts_c] ,
			DST.[OtherDestination_c] 	=	SRC.[OtherDestination_c] ,
			DST.[OtherPartiesInvolved_c] 	=	SRC.[OtherPartiesInvolved_c] ,
			DST.[OtherPrePaidArrangementsImpacted_c] 	=	SRC.[OtherPrePaidArrangementsImpacted_c] ,
			DST.[OtherPrimaryCauseDetails__c] 	=	SRC.[OtherPrimaryCauseDetails__c] ,
			DST.[OtherTravelProviderName_c] 	=	SRC.[OtherTravelProviderName_c] ,
			DST.[PetDescriptionBreeds_c] 	=	SRC.[PetDescriptionBreeds_c] ,
			DST.[PhotoIdentificationAvailable_c] 	=	SRC.[PhotoIdentificationAvailable_c] ,
			DST.[PickUpLocation_c] 	=	SRC.[PickUpLocation_c] ,
			DST.[PlanType_c] 	=	SRC.[PlanType_c] ,
			DST.[PoliceIncidentReportRequested_c] 	=	SRC.[PoliceIncidentReportRequested_c] ,
			DST.[PoliceReportNumber_c] 	=	SRC.[PoliceReportNumber_c] ,
			DST.[PolicyEndDate_c] 	=	SRC.[PolicyEndDate_c] ,
			DST.[PolicyStartDate_c] 	=	SRC.[PolicyStartDate_c] ,
			DST.[Policy_c] 	=	SRC.[Policy_c] ,
			DST.[PreferredAppointmentDateTime_c] 	=	SRC.[PreferredAppointmentDateTime_c] ,
			DST.[PreferredColour_c] 	=	SRC.[PreferredColour_c] ,
			DST.[PreferredDateAndTime_c] 	=	SRC.[PreferredDateAndTime_c] ,
			DST.[PreferredSize_c] 	=	SRC.[PreferredSize_c] ,
			DST.[PrescribersContactDetails_c] 	=	SRC.[PrescribersContactDetails_c] ,
			DST.[PreviousTreatmentDetails_c] 	=	SRC.[PreviousTreatmentDetails_c] ,
			DST.[PrimaryCauseOfTheInjury_c] 	=	SRC.[PrimaryCauseOfTheInjury_c] ,
			DST.[PrimaryDestinationOfTrip_c] 	=	SRC.[PrimaryDestinationOfTrip_c] ,
			DST.[PrimaryReasonForTheNonMedicalCase_c] 	=	SRC.[PrimaryReasonForTheNonMedicalCase_c] ,
			DST.[PrimarySecurityReason_c] 	=	SRC.[PrimarySecurityReason_c] ,
			DST.[ProfessionalEvent_c] 	=	SRC.[ProfessionalEvent_c] ,
			DST.[ProgramClientName_c] 	=	SRC.[ProgramClientName_c] ,
			DST.[Program_c] 	=	SRC.[Program_c] ,
			DST.[ProvideADescriptionOfTheCase_c] 	=	SRC.[ProvideADescriptionOfTheCase_c] ,
			DST.[PurposeOfTrip_c] 	=	SRC.[PurposeOfTrip_c] ,
			DST.[QuantityConsumed_c] 	=	SRC.[QuantityConsumed_c] ,
			DST.[Questionnaire_c] 	=	SRC.[Questionnaire_c] ,
			DST.[ReasonForDelay_c] 	=	SRC.[ReasonForDelay_c] ,
			DST.[Recipient_c] 	=	SRC.[Recipient_c] ,
			DST.[Registration_c] 	=	SRC.[Registration_c] ,
			DST.[RelatedDetails_c] 	=	SRC.[RelatedDetails_c] ,
			DST.[RelatedTreatmentHistory_c] 	=	SRC.[RelatedTreatmentHistory_c] ,
			DST.[RelationshipToPrimaryCardHolder_c] 	=	SRC.[RelationshipToPrimaryCardHolder_c] ,
			DST.[RelevantNotes_c] 	=	SRC.[RelevantNotes_c] ,
			DST.[RentalAgencyDetails_c] 	=	SRC.[RentalAgencyDetails_c] ,
			DST.[RentalPeriod_c] 	=	SRC.[RentalPeriod_c] ,
			DST.[ReplacementRequiredUrgently__c] 	=	SRC.[ReplacementRequiredUrgently__c] ,
			DST.[ReportedToThePoliceAuthority_c] 	=	SRC.[ReportedToThePoliceAuthority_c] ,
			DST.[ReportedTo_c] 	=	SRC.[ReportedTo_c] ,
			DST.[ReportIDreferenceNumber_c] 	=	SRC.[ReportIDreferenceNumber_c] ,
			DST.[ReservationBookingDescription_c] 	=	SRC.[ReservationBookingDescription_c] ,
			DST.[RestaurantName_c] 	=	SRC.[RestaurantName_c] ,
			DST.[ReturnDate_c] 	=	SRC.[ReturnDate_c] ,
			DST.[RoadsideOrganised_c] 	=	SRC.[RoadsideOrganised_c] ,
			DST.[SelectThePolicy_c] 	=	SRC.[SelectThePolicy_c] ,
			DST.[SelfPaidAmount_c] 	=	SRC.[SelfPaidAmount_c] ,
			DST.[SendReplacementTicketsTo_c] 	=	SRC.[SendReplacementTicketsTo_c] ,
			DST.[SmokingRoom_c] 	=	SRC.[SmokingRoom_c] ,
			DST.[SoughtTx_c] 	=	SRC.[SoughtTx_c] ,
			DST.[SpecialAssistanceDetails_c] 	=	SRC.[SpecialAssistanceDetails_c] ,
			DST.[SpecialRequests_c] 	=	SRC.[SpecialRequests_c] ,
			DST.[SportName_c] 	=	SRC.[SportName_c] ,
			DST.[SSAndDuration_c] 	=	SRC.[SSAndDuration_c] ,
			DST.[StartDateOfExpatInpatAssignment__c] 	=	SRC.[StartDateOfExpatInpatAssignment__c] ,
			DST.[StudentStaffIDNumber_c] 	=	SRC.[StudentStaffIDNumber_c] ,
			DST.[Subtype_c] 	=	SRC.[Subtype_c] ,
			DST.[TicketCategoryClass_c] 	=	SRC.[TicketCategoryClass_c] ,
			DST.[TicketPurchasedOnTheCreditCard_c] 	=	SRC.[TicketPurchasedOnTheCreditCard_c] ,
			DST.[TimeFrameInRelationToIncident_c] 	=	SRC.[TimeFrameInRelationToIncident_c] ,
			DST.[TotalCostsPaid_c] 	=	SRC.[TotalCostsPaid_c] ,
			DST.[TravelBookingDate_c] 	=	SRC.[TravelBookingDate_c] ,
			DST.[TravelCreditExpiryDate_c] 	=	SRC.[TravelCreditExpiryDate_c] ,
			DST.[TravelCreditReimbursmentDetails__c] 	=	SRC.[TravelCreditReimbursmentDetails__c] ,
			DST.[TravelDocumentsLostStolen_c] 	=	SRC.[TravelDocumentsLostStolen_c] ,
			DST.[TravelingForBusiness_c] 	=	SRC.[TravelingForBusiness_c] ,
			DST.[TravellingCompanionDetails_c] 	=	SRC.[TravellingCompanionDetails_c] ,
			DST.[TravelProviderName_c] 	=	SRC.[TravelProviderName_c] ,
			DST.[TreatmentPlanIfApplicable_c] 	=	SRC.[TreatmentPlanIfApplicable_c] ,
			DST.[UnableToLeaveOrCallAuthorities__c] 	=	SRC.[UnableToLeaveOrCallAuthorities__c] ,
			DST.[VehicleDescription_c] 	=	SRC.[VehicleDescription_c] ,
			DST.[VenueNameLocation_c] 	=	SRC.[VenueNameLocation_c] ,
			DST.[WasAReferralOffered_c] 	=	SRC.[WasAReferralOffered_c] ,
			DST.[WasItReportedToPolice_c] 	=	SRC.[WasItReportedToPolice_c] ,
			DST.[WereAllPartiesWearingAHelmet_c] 	=	SRC.[WereAllPartiesWearingAHelmet_c] ,
			DST.[WereThereAnyCostsSelfPaid_c] 	=	SRC.[WereThereAnyCostsSelfPaid_c] ,
			DST.[WhatIsTheCategory_c] 	=	SRC.[WhatIsTheCategory_c] ,
			DST.[WhatIsTheEligibleAmount_c] 	=	SRC.[WhatIsTheEligibleAmount_c] ,
			DST.[WhatIsTheRequest1_c] 	=	SRC.[WhatIsTheRequest1_c] ,
			DST.[WhatIsTheRequest_c] 	=	SRC.[WhatIsTheRequest_c] ,
			DST.[WhatTypeOfTicketsAreThey_c] 	=	SRC.[WhatTypeOfTicketsAreThey_c] ,
			DST.[WhenDidTheSymptomsFirstStart_c] 	=	SRC.[WhenDidTheSymptomsFirstStart_c] ,
			DST.[WhenWasTreatmentSought_c] 	=	SRC.[WhenWasTreatmentSought_c] ,
			DST.[When_c] 	=	SRC.[When_c] ,
			DST.[WhereDidTheyPurchaseTheirPolicy__c] 	=	SRC.[WhereDidTheyPurchaseTheirPolicy__c] ,
			DST.[WhereHowTicketsWerePurchased_c] 	=	SRC.[WhereHowTicketsWerePurchased_c] ,
			DST.[WhereWasTreatmentSought_c] 	=	SRC.[WhereWasTreatmentSought_c] ,
			DST.[Where_c] 	=	SRC.[Where_c] ,
			DST.[WhoWasAtFault_c] 	=	SRC.[WhoWasAtFault_c] ,
			DST.[WitnessDetails_c] 	=	SRC.[WitnessDetails_c] ,
			DST.[WTPToArrangePaymentWithProvider_c]	=	SRC.[WTPToArrangePaymentWithProvider_c];
END
GO
