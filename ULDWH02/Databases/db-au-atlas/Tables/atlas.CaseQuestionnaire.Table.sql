USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[CaseQuestionnaire]    Script Date: 21/02/2025 11:28:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[CaseQuestionnaire](
	[Id] [varchar](25) NOT NULL,
	[IsDeleted] [bit] NULL,
	[Currency_ISOCode] [varchar](10) NULL,
	[CreatedById] [varchar](20) NULL,
	[CreatedDate] [datetime] NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastModifiedById] [varchar](25) NULL,
	[LastReferencedDate] [datetime] NULL,
	[LastViewedDate] [datetime] NULL,
	[SystemModstamp] [datetime] NULL,
	[Name] [nvarchar](255) NULL,
	[AccommodationCosts_c] [varchar](255) NULL,
	[ActivationConfirmedbyInsurer__c] [nvarchar](255) NULL,
	[AdditionalInformation1_c] [varchar](255) NULL,
	[AdditionalInformation__c] [varchar](255) NULL,
	[AdviceProvidedToCaller_c] [varchar](255) NULL,
	[AirlineCosts_c] [varchar](255) NULL,
	[Amenities__c] [varchar](255) NULL,
	[AMEXCardVerified_c] [nvarchar](255) NULL,
	[AMEXNACPolicy_c] [nvarchar](255) NULL,
	[AnyExclusionsApply_c] [varchar](255) NULL,
	[AnySpecialConditionsPreferred_c] [varchar](255) NULL,
	[APConfirmedAuthorisedBusinessTravel_c] [nvarchar](255) NULL,
	[APUpdatedCaseOpened_c] [nvarchar](255) NULL,
	[AreTheyImpactedByTheEvent_c] [nvarchar](255) NULL,
	[AreTheyInDanger_c] [nvarchar](255) NULL,
	[AreTheyInjured_c] [nvarchar](255) NULL,
	[AreTheyNearTheIncident_c] [nvarchar](255) NULL,
	[ArrivalDate_c] [date] NULL,
	[AssistanceRequired_c] [varchar](255) NULL,
	[AuthorizationLetterAddress_c] [varchar](255) NULL,
	[BenefitDetails_c] [varchar](255) NULL,
	[BINNumber__c] [varchar](255) NULL,
	[BookingReference_c] [varchar](255) NULL,
	[BudgetForItem_c] [varchar](255) NULL,
	[BudgetPerNight_c] [varchar](255) NULL,
	[Budget_c] [varchar](255) NULL,
	[CancellationInterruptionReason_c] [varchar](255) NULL,
	[CaseType_c] [nvarchar](255) NULL,
	[Case_c] [varchar](25) NULL,
	[Category_c] [nvarchar](255) NULL,
	[CityStateCountry_c] [varchar](255) NULL,
	[ClassOfFlight_c] [varchar](255) NULL,
	[Colour_c] [varchar](255) NULL,
	[CommercialPropertyDetails_c] [varchar](255) NULL,
	[CompInsuranceWithHireCarProvider_c] [varchar](255) NULL,
	[ConfirmedByWhichAP_c] [varchar](255) NULL,
	[ContactDetails_c] [varchar](255) NULL,
	[CountryOfCitizenship_c] [varchar](255) NULL,
	[CountryOfExpatInpatResidence_c] [varchar](255) NULL,
	[CoveredUnderTheBTAPlan_c] [nvarchar](255) NULL,
	[CoveredVehicleDefinitionMet_c] [varchar](255) NULL,
	[Currency_c] [varchar](255) NULL,
	[CurrentlyReceivingTreatment_c] [nvarchar](255) NULL,
	[CustomersCurrentLocation_c] [varchar](255) NULL,
	[CustomersRelationshipToEmployee_c] [nvarchar](255) NULL,
	[DateAndTimeOfTheAccidentincident_c] [datetime] NULL,
	[DateAndTime_c] [datetime] NULL,
	[DateofBookingTrip_c] [date] NULL,
	[DateOfNextScheduledHomeLeave_c] [date] NULL,
	[DatetimelocationOfFlightevent_c] [varchar](255) NULL,
	[DeliveryAddress_c] [varchar](255) NULL,
	[DeliveryDatetimeRangeRequested_c] [varchar](255) NULL,
	[DepartureAndArrivingLocation_c] [varchar](255) NULL,
	[DepartureCity1_c] [varchar](25) NULL,
	[DepartureDate_c] [date] NULL,
	[DescribeAnyInjuriesSustained__c] [varchar](255) NULL,
	[DescribeHowTheInjuryOccurred_c] [varchar](255) NULL,
	[DescriptionOfTheIllnessinjury_c] [varchar](255) NULL,
	[DestinationCity1_c] [varchar](25) NULL,
	[DetailedDescriptionOfLocation_c] [varchar](255) NULL,
	[DetailsOfAutoInsuranceIfNotified_c] [varchar](255) NULL,
	[DetailsOfVehicleInvolved_c] [varchar](255) NULL,
	[DiagnosisIfApplicable_c] [varchar](255) NULL,
	[Diagnosis_c] [varchar](25) NULL,
	[DidAnInjuryOccur_c] [nvarchar](255) NULL,
	[DocumentIssuer_c] [varchar](255) NULL,
	[DocumentLost_c] [varchar](255) NULL,
	[DocumentMedicalAidInformation_c] [varchar](255) NULL,
	[DoesTheDriverHaveCDW_c] [varchar](255) NULL,
	[DoesTheDriverHoldARelevantLicence_c] [nvarchar](255) NULL,
	[DoTheyHaveMedicalAidInSouthAfrica_c] [nvarchar](255) NULL,
	[DropOffLocation_c] [varchar](255) NULL,
	[DrugsOrAlcoholInvolved_c] [nvarchar](255) NULL,
	[DxAndTxPlan_C] [varchar](255) NULL,
	[EligibilityDetails_c] [varchar](255) NULL,
	[EmbassyconsulateNotified_c] [varchar](255) NULL,
	[EmployeesJobTitle__c] [varchar](255) NULL,
	[EndDateOfExpatInpatAssignment_c] [date] NULL,
	[EntertainmentType_c] [varchar](255) NULL,
	[ExactLocationOfTheAccidentincident_c] [varchar](255) NULL,
	[ExcessAccountedFor_c] [nvarchar](255) NULL,
	[ExcessOnHireVehiclePolicy_c] [varchar](255) NULL,
	[Excess_c] [varchar](255) NULL,
	[ExcludedSport_c] [nvarchar](255) NULL,
	[ExistingPrescriptionForTheMedication__c] [nvarchar](255) NULL,
	[ExplainClaimsProcessAndSendFormlin_c] [varchar](255) NULL,
	[FamilyFriendContactInformation__c] [varchar](255) NULL,
	[FinalAmount_c] [varchar](255) NULL,
	[FullCreditCardName_c] [nvarchar](255) NULL,
	[HasALawyerBeenEngaged_c] [nvarchar](255) NULL,
	[HaveTheyBeenContacted_c] [nvarchar](255) NULL,
	[HealthClubName_c] [varchar](255) NULL,
	[HighChairBoosterRequired_c] [nvarchar](255) NULL,
	[HiredFrom_c] [varchar](255) NULL,
	[HomeAddress_c] [varchar](255) NULL,
	[HomeAssistanceOrganised_c] [nvarchar](255) NULL,
	[HotelName_c] [varchar](255) NULL,
	[HowDoYouWantToReceiveFeedback_c] [varchar](255) NULL,
	[HowManyTravellersAreOnTheCancelled_c] [varchar](255) NULL,
	[HowWasExcessAccountedFor_c] [nvarchar](255) NULL,
	[HowWasTheTripBooked_c] [nvarchar](255) NULL,
	[InitiatorOfCancellationInterruption_c] [nvarchar](255) NULL,
	[InjuryOrDentalPainBenefit_c] [nvarchar](255) NULL,
	[IsTheSuspectPresent_c] [nvarchar](255) NULL,
	[IsThisAAssurantPolicy_c] [nvarchar](255) NULL,
	[IsThisARoadsideOrHomeAssistanceCase__c] [nvarchar](255) NULL,
	[ItemDescription1_c] [varchar](255) NULL,
	[ItemDescription_c] [varchar](255) NULL,
	[LengthOfDelay_c] [varchar](255) NULL,
	[LimitationsBenefitMaximumApply_c] [nvarchar](255) NULL,
	[ListDrugsalcohol_c] [varchar](255) NULL,
	[ListOfItemsLoststolen__c] [varchar](255) NULL,
	[LMOSpecialistDetails_c] [varchar](255) NULL,
	[LocationOfIncident_c] [varchar](255) NULL,
	[Location_c] [varchar](255) NULL,
	[MakeAndModel_c] [varchar](255) NULL,
	[MaxBenefitExceededForPrimaryInsurance_c] [nvarchar](255) NULL,
	[MedicalCondition_c] [varchar](255) NULL,
	[MedicalName_c] [varchar](255) NULL,
	[MessageOnDeliveryCardBox_c] [varchar](255) NULL,
	[Message_c] [varchar](255) NULL,
	[NameAndContactDetails_c] [varchar](255) NULL,
	[NameOfEmployerCompany_c] [varchar](255) NULL,
	[NameOfPersonEmployedByThisCompany_c] [varchar](255) NULL,
	[NameOfTheDriver_c] [varchar](255) NULL,
	[NameOfVehicleOwner_c] [varchar](255) NULL,
	[NamesOnTheTickets__c] [varchar](255) NULL,
	[NatureOfProblem_c] [varchar](255) NULL,
	[Note10_c] [varchar](8000) NULL,
	[Note11_c] [varchar](255) NULL,
	[Note1_c] [varchar](8000) NULL,
	[Note2_c] [varchar](8000) NULL,
	[Note3_c] [varchar](8000) NULL,
	[Note4_c] [varchar](8000) NULL,
	[Note5_c] [varchar](8000) NULL,
	[Note6_c] [varchar](8000) NULL,
	[Note7_c] [varchar](8000) NULL,
	[Note8_c] [varchar](8000) NULL,
	[Note9_c] [varchar](8000) NULL,
	[Note_c] [varchar](8000) NULL,
	[NumberOfChildren_c] [varchar](255) NULL,
	[NumberOfPeople1_c] [varchar](255) NULL,
	[NumberOfPeople_c] [varchar](255) NULL,
	[NumberOfPets_c] [varchar](255) NULL,
	[ObtainAndDocumentContactInformation__c] [varchar](255) NULL,
	[OriginalCostOfTravel_c] [varchar](255) NULL,
	[OtherCosts_c] [varchar](255) NULL,
	[OtherDestination_c] [varchar](255) NULL,
	[OtherPartiesInvolved_c] [nvarchar](255) NULL,
	[OtherPrePaidArrangementsImpacted_c] [varchar](255) NULL,
	[OtherPrimaryCauseDetails__c] [varchar](255) NULL,
	[OtherTravelProviderName_c] [varchar](255) NULL,
	[PetDescriptionBreeds_c] [varchar](255) NULL,
	[PhotoIdentificationAvailable_c] [nvarchar](255) NULL,
	[PickUpLocation_c] [varchar](255) NULL,
	[PlanType_c] [varchar](25) NULL,
	[PoliceIncidentReportRequested_c] [nvarchar](255) NULL,
	[PoliceReportNumber_c] [nvarchar](255) NULL,
	[PolicyEndDate_c] [date] NULL,
	[PolicyStartDate_c] [date] NULL,
	[Policy_c] [varchar](255) NULL,
	[PreferredAppointmentDateTime_c] [datetime] NULL,
	[PreferredColour_c] [varchar](255) NULL,
	[PreferredDateAndTime_c] [datetime] NULL,
	[PreferredSize_c] [varchar](255) NULL,
	[PrescribersContactDetails_c] [varchar](255) NULL,
	[PreviousTreatmentDetails_c] [varchar](255) NULL,
	[PrimaryCauseOfTheInjury_c] [nvarchar](255) NULL,
	[PrimaryDestinationOfTrip_c] [nvarchar](255) NULL,
	[PrimaryReasonForTheNonMedicalCase_c] [nvarchar](255) NULL,
	[PrimarySecurityReason_c] [nvarchar](255) NULL,
	[ProfessionalEvent_c] [nvarchar](255) NULL,
	[ProgramClientName_c] [varchar](25) NULL,
	[Program_c] [nvarchar](255) NULL,
	[ProvideADescriptionOfTheCase_c] [varchar](255) NULL,
	[PurposeOfTrip_c] [nvarchar](255) NULL,
	[QuantityConsumed_c] [varchar](255) NULL,
	[Questionnaire_c] [varchar](max) NULL,
	[ReasonForDelay_c] [varchar](255) NULL,
	[Recipient_c] [varchar](255) NULL,
	[Registration_c] [varchar](255) NULL,
	[RelatedDetails_c] [varchar](255) NULL,
	[RelatedTreatmentHistory_c] [nvarchar](255) NULL,
	[RelationshipToPrimaryCardHolder_c] [varchar](255) NULL,
	[RelevantNotes_c] [varchar](255) NULL,
	[RentalAgencyDetails_c] [varchar](255) NULL,
	[RentalPeriod_c] [varchar](255) NULL,
	[ReplacementRequiredUrgently__c] [nvarchar](255) NULL,
	[ReportedToThePoliceAuthority_c] [nvarchar](255) NULL,
	[ReportedTo_c] [varchar](255) NULL,
	[ReportIDreferenceNumber_c] [varchar](255) NULL,
	[ReservationBookingDescription_c] [varchar](255) NULL,
	[RestaurantName_c] [varchar](255) NULL,
	[ReturnDate_c] [date] NULL,
	[RoadsideOrganised_c] [nvarchar](255) NULL,
	[SelectThePolicy_c] [nvarchar](255) NULL,
	[SelfPaidAmount_c] [varchar](255) NULL,
	[SendReplacementTicketsTo_c] [varchar](255) NULL,
	[SmokingRoom_c] [nvarchar](255) NULL,
	[SoughtTx_c] [nvarchar](255) NULL,
	[SpecialAssistanceDetails_c] [varchar](255) NULL,
	[SpecialRequests_c] [varchar](255) NULL,
	[SportName_c] [varchar](255) NULL,
	[SSAndDuration_c] [varchar](255) NULL,
	[StartDateOfExpatInpatAssignment__c] [date] NULL,
	[StudentStaffIDNumber_c] [varchar](255) NULL,
	[Subtype_c] [nvarchar](255) NULL,
	[TicketCategoryClass_c] [varchar](255) NULL,
	[TicketPurchasedOnTheCreditCard_c] [nvarchar](255) NULL,
	[TimeFrameInRelationToIncident_c] [varchar](255) NULL,
	[TotalCostsPaid_c] [varchar](255) NULL,
	[TravelBookingDate_c] [date] NULL,
	[TravelCreditExpiryDate_c] [date] NULL,
	[TravelCreditReimbursmentDetails__c] [varchar](255) NULL,
	[TravelDocumentsLostStolen_c] [nvarchar](255) NULL,
	[TravelingForBusiness_c] [nvarchar](255) NULL,
	[TravellingCompanionDetails_c] [varchar](255) NULL,
	[TravelProviderName_c] [nvarchar](255) NULL,
	[TreatmentPlanIfApplicable_c] [varchar](255) NULL,
	[UnableToLeaveOrCallAuthorities__c] [nvarchar](255) NULL,
	[VehicleDescription_c] [varchar](255) NULL,
	[VenueNameLocation_c] [varchar](255) NULL,
	[WasAReferralOffered_c] [nvarchar](255) NULL,
	[WasItReportedToPolice_c] [nvarchar](255) NULL,
	[WereAllPartiesWearingAHelmet_c] [nvarchar](255) NULL,
	[WereThereAnyCostsSelfPaid_c] [nvarchar](255) NULL,
	[WhatIsTheCategory_c] [varchar](255) NULL,
	[WhatIsTheEligibleAmount_c] [varchar](255) NULL,
	[WhatIsTheRequest1_c] [varchar](255) NULL,
	[WhatIsTheRequest_c] [nvarchar](255) NULL,
	[WhatTypeOfTicketsAreThey_c] [varchar](255) NULL,
	[WhenDidTheSymptomsFirstStart_c] [datetime] NULL,
	[WhenWasTreatmentSought_c] [date] NULL,
	[When_c] [varchar](255) NULL,
	[WhereDidTheyPurchaseTheirPolicy__c] [varchar](255) NULL,
	[WhereHowTicketsWerePurchased_c] [varchar](255) NULL,
	[WhereWasTreatmentSought_c] [varchar](255) NULL,
	[Where_c] [varchar](255) NULL,
	[WhoWasAtFault_c] [varchar](255) NULL,
	[WitnessDetails_c] [varchar](255) NULL,
	[WTPToArrangePaymentWithProvider_c] [nvarchar](255) NULL,
	[SysStartTime] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTime] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_CaseQuestionnaire] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [atlas].[CaseQuestionnaire_Hist])
)
GO
ALTER TABLE [atlas].[CaseQuestionnaire]  WITH CHECK ADD  CONSTRAINT [FK_CaseQuestionnaire_Case] FOREIGN KEY([Case_c])
REFERENCES [atlas].[Case] ([Id])
GO
ALTER TABLE [atlas].[CaseQuestionnaire] CHECK CONSTRAINT [FK_CaseQuestionnaire_Case]
GO
