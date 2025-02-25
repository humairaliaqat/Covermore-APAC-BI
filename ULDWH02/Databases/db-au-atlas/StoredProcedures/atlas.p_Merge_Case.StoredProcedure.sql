USE [db-au-atlas]
GO
/****** Object:  StoredProcedure [atlas].[p_Merge_Case]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
        
        
CREATE PROCEDURE [atlas].[p_Merge_Case]        
AS        
BEGIN         
 SET NOCOUNT ON;        
        
 DECLARE @LastDateTime DATETIME        
        
 SELECT @LastDateTime = LastDateTime FROM atlas.JobConfig WHERE EntityName = 'atlas.[Case]';        
        
 MERGE atlas.[Case] DST        
 USING (SELECT         
    [Id],         
    [IsDeleted],         
    [Currency_ISOCode],         
    [CreatedById],         
    [CreatedDate],         
    [LastModifiedDate],         
    [LastModifiedById],         
    [LastReferencedDate],         
    [LastViewedDate],         
    [SystemModstamp],         
    [RecordTypeId],         
    [RecordType_DeveloperName],         
    [AccountId],         
    [CaseNumber],         
    [ClosedDate],         
    [ContactId],         
    [Subject],         
    [Description],         
    [IsClosed],         
    [IsClosedOnCreate],         
    [IsEscalated],         
    [Language],         
    [MasterRecordId],         
    [Origin],         
    [OwnerId],         
    [ParentId],         
    [Priority],         
    [Reason],         
    [Status],         
    [Type],         
    [TimeZone_c],         
    [SubType_c],         
    [CurrentState_c],         
    [CurrentCountry_c],         
    [CurrentStreet_c],         
    [CurrentCity_c],         
    [CurrentPostalCode_c],         
    [IncidentCity_c],         
    [IncidentCountry_c],         
    [IncidentState_c],         
    [IncidentStreet_c],         
    [IncidentPostalCode_c],         
    [RiskRating_c],         
    [RiskReason_c],         
    [ProgramType_c],         
    [ClaimNumber_c],         
    [Underwriter_c],         
    [SourceId],         
    [SuppliedCompany],         
    [SuppliedEmail],         
    [SuppliedName],         
    [SuppliedPhone],         
    [ActionPlanCreated_c],         
    [AmountToCollect_c],         
    [ApprovalDateTime_c],         
    [ApprovalSoughtDetails_c],         
    [Assistance_Team_c],         
    [AssistCasesCount_c],         
    [AvoidedLoss_c],         
    [BinNumberPortal_c],         
    [BINNumber_c],         
    [Buffer_c],         
    [BypassStatusChangeValidation_c],         
    [CallBackCustomerTaskCreated_c],         
    [CarRentalLicensePlate_c],         
    [Carrentalpickupdate_c],         
    [Carrentalreturndate_c],         
    [CarRentalVIN_c],         
    [CaseAge_c],         
    [CaseComment_c],         
    [CaseCreatedDate_c],         
    [CaseDecision_c],         
    [CaseFeeWaived_c],         
    [CaseIndicatorFlag_c],         
    [CaseNotProgressedSinceDays_c],         
    [CaseOwnerName_c],         
    [CaseQuestionnaire_c],         
    [CaseType_c],         
    [Case_Status_c],         
    [CashTransfer_c],         
    [CategoryRating_c],         
    [CCEligible_c],         
    [CCProvider_c],         
    [ClaimsStatus_c],         
    [ClaimStatus_c],         
    [ClientOrganization_c],         
    [ComplaintCategory_c],         
    [ConsentReceived_c],         
    [Consent_Flag_c],         
    [ContactAge_c],         
    [ContactBirthDate_c],         
    [ContactIntakeFields_c],         
    [CorporateAccount_c],         
    [CreatingThisCaseForSelf_c],         
    [CurrentDiagnosis_c],         
    CONVERT(VARCHAR(16), CONVERT(TIME, CurrentLocationTime_c)) [CurrentLocationTime_c],         
    [CurrentlyTravelling_c],         
    [CurrentTime_c],         
    [CustomerContactPermitted_c],         
    [CustomerCurrentCountry_c],         
    [CustomerCurrentState_c],         
    [DateofTreatmentInitialSought_c],         
    [DepartureDate_c],         
    [DesiredOutcome_c],         
    [DestinationCity_c],         
    [DestinationCountry_c],         
    [DestinationState_c],         
    [DirectionalCare_c],         
    [Dissatisfied_c],         
    [DueDate_c],         
    [EMCDetails_c],         
    [EMCReview_c],         
    [EmployerGroup_c],         
    [EmployerName_c],         
    [EscalationEmail_c],         
    [EscalationStatus_c],         
    [Estoppel_c],         
[ExcessPaid_c],         
    [ExternalClaimReference_c],         
    [FeedbackAbout_c],         
    [FeedbackType_c],         
    [FinalAmount_c],         
    [FitToFlyDate_c],         
    [FitToTravelDate_c],         
    [From_c],         
    [GCNLink_c],         
    [GHIP_c],         
    [Handover_c],         
    [HastheCustomerSoughtMedicalAdvise_c],         
    [ICDDescription_c],         
    [IncidentDate_c],         
    [IncidentLocation_c],         
    [IncidentSummary_c],         
    [IntakeQuestionnaire_c],         
    [IntakeRequiredFieldStandard_c],         
    [IntakeRequiredFields_c],         
    [InternalClaim_c],         
    [InvestigationOutcome_c],         
    [InvestigationReason_c],         
    [Investigation_c],         
    [ItemPurchaseDate_c],         
    [KnowledgeSearchKeywords_c],         
    [LargeLoss_c],         
    [LastCommunicationDateTime_c],         
    [LastStatusModifiedDate_c],         
    [MediaPartnerEmail_c],         
    [MedicalConsultantRecommendation_c],         
    [MedicalSought_c],         
    [MedicalSummary_c],         
    [MembershipNumber_c],         
    [MethodofTravel_c],         
    [NumberofTeleAppointmentsperCase_c],         
    [NumberOfTravellingCompanions_c],         
    [OtherReasonForDissatisfaction_c],         
    [PlanNumber_c],         
    [PlanType_c],         
    [PolicyCertificatePlanNumber_c],         
    [PolicyCountry_c],         
    [PolicyEndDate_c],         
    [PolicyMember_c],         
    [PolicyNumber1_c],         
    [PolicyNumber__c],         
    [PolicyStartDate_c],         
    [PolicyType_c],         
    [Policy_End_Date_c],         
    [Policy_Number_c],         
    [Policy_Start_Date_c],         
    [Policy_c],         
    [PortalCaseScreenNo_c],         
    [PotentialRecovery_c],         
    [PreferredContactMethod_c],         
    [PrimaryDiagnosisCode_c],         
    [PrimaryDiagnosis_c],         
    [PrivacyStatement_c],         
    [PrivateCase_c],         
    [Private_c],         
    [ProviderNameComplaint_c],         
    [ProviderName_c],         
    [Purpose_c],         
    [QANotes_c],         
    [ReasonForComplaint_c],         
    [ReasonForDissatisfaction_c],         
    [ReasonforMonitoring_c],         
    [ReceivedDate_c],         
    [ReciprocalHeathcareAgreements_c],         
    [RedactionDateTime_c],         
    [RentalAgencyDetails_c],         
    [ReopenedDateTime_c],         
    [ResolutionPlan_c],         
    [RespondCaseId_c],         
    [RespondCaseRef_c],         
    [ResponsibleBusinessArea_c],         
    [ReturnDate_c],         
    [ReviewReason_c],         
    [ReimbursedAmount_c],         
    [Sanctioned_c],         
    [SecondaryRiskReason_c],         
    [SecurityEvent_c],         
    [Sensitive_c],         
    [SpousePlanName_c],         
    [SpousePlanNumber_c],         
    [STAccidentalDeathDismemberment_c],         
    [STAmendedTravelArrangements_c],         
    [STArrangements_c],         
    [STAssistance_c],         
    [STBenestar_c],         
    [STClaimsDocumentAssistance_c],         
    [STCLDI_c],         
    [STCostContainmentComplaint_c],         
    [STCostContainmentMedicalMonitoring_c],         
    [STDeathCase_c],         
    [STDelayedLuggage_c],         
    [STDirectionalCare_c],         
    [STDuringTravel_c],         
    [STEmergencyCashTransfer_c],         
    [STEntertainment_c],         
    [STEvacuation_c],         
    [STEventManagement_c],         
    [STExtendedWarranty_c],         
    [STFlight_c],         
    [STGiftFloralBaskets_c],         
    [STGolf_c],         
    [STHireVehicleExcess_c],         
    [STHotel_c],         
    [STIllness_c],         
    [STInbound_c],         
    [STInformationDuringTrip_c],         
    [STInjury_c],         
    [STInPatient_c],         
    [STInternetSearchforItemAccessory_c],         
    [STLostStolenLuggage_c],         
    [STLostStolenTravelDocuments_c],         
    [STMedicalMonitoring_c],         
    [STMedicationPurchaseDelivery_c],         
 [STMessageCentreService_c],         
    [STNotification_c],         
    [STOther_c],         
    [STOutPatient_c],         
    [STPrescriptionReplacements_c],         
    [STPreTravel_c],         
    [STPreTripInformationMedical_c],         
    [STPreTripInformationSecurity_c],         
    [STPriceProtection_c],         
    [STProductComplaint_c],         
    [STProviderQualityComplaint_c],         
    [STPurchaseAssurance_c],         
    [STRepatriation_c],         
    [STReplacementOfLostStolenDocuments_c],     
    [STReservationBooking_c],         
    [STRestaurantReservation_c],         
    [STRoadSideHomeAssistance_c],         
    [STSecurityIncident_c],         
    [STServiceOtherComplaint_c],         
    [STServiceWTPComplaint_c],         
    [STShoppingHealthClubs_c],         
    [STTeleMedicine_c],         
    [STTravelAssistance_c],         
    [STTravelDelay_c],         
    [STTripCancellation_c],         
    [STTripInterruptionCurtailment_c],         
    [STVisaExtension_c],         
    [SubmissionDate_c],         
    [SubTypeInbound_c],         
    [Supervision_c],         
    [Symptoms_c],         
    [TaskDueDateTime_c],         
    [TaskDueDate_c],         
    [TemplateGroupName_c],         
    [ThirdPartyLiability_c],         
    [TimeTakenforDecision_c],         
    [TodaysDate_c],         
    [TotalClaimPaymentsReservedandPaid_c],         
    [TotalDiagnosis_c],         
    [TotalEstimate_c],         
    [TotalPayments_c],         
    [TravelerAddress_c],         
    [TravelerBirthdate_c],         
    [TravelerDeathDate_c],         
    [TravelerDefaulter_c],         
    [TravelerEmail_c],         
    [TravelerFirstName_c],         
    [TravelerFlag_c],         
    [TravelerGender_c],         
    [TravelerLanguage_c],         
    [TravelerName1_c],         
    [TravelerName_c],         
    [TravelerPhone_c],         
    [TravelerPotentialIssue_c],         
    [TravellerDateofBirth_c],         
    [TravellerName_c],         
    [TreatingTeamApproval_c],         
    [TripPurchaseDate_c],         
    [Trip_End_Date_c],         
    [Trip_Length_c],         
    [Trip_Start_Date_c],         
    [UnderwriterPortalLink_c],         
    [UnderwriterThresholdReached_c],         
    [UnreadEmail_c],         
    [Unread_c],         
    [UpdatedCostToDates_c],         
    [UrgentAssistance_c],         
    [UWApprovalDetails_c],         
    [UWApprovalRequiredFields_c],         
    [UWContact_c],         
    [VulnerableCustomer_c],         
    [WhatKindofvehicle_c],         
    [WhoInitialTreatmentWasSoughtFrom_c],         
    [WorkersComp_c],         
    [ZurichUKChannel_c],         
    [HandoverSummary_c],         
    [CreatedDateQLD] = DATEADD(HOUR, 10, CreatedDate),         
    [ClosedDateQLD] = DATEADD(HOUR, 10, ClosedDate),        
    [CaseFeeTypeOverride_c],      
 [First_Closed_Date_c]    
   FROM RDSLnk.STG_RDS.[dbo].[STG_Case] stgc        
   WHERE EXISTS (        
    SELECT 1        
    FROM atlas.[Account] a        
    WHERE stgc.AccountId = a.Id        
     OR stgc.AccountId IS NULL        
    )        
    AND stgc.[SystemModstamp] > ISNULL(@LastDateTime, '1900-01-01')        
  ) SRC        
 ON DST.Id = SRC.Id        
        
 WHEN NOT MATCHED THEN        
 INSERT (        
  [Id],         
  [IsDeleted],         
  [Currency_ISOCode],         
  [CreatedById],         
  [CreatedDate],         
  [LastModifiedDate],         
  [LastModifiedById],         
  [LastReferencedDate],         
  [LastViewedDate],         
  [SystemModstamp],         
  [RecordTypeId],         
  [RecordType_DeveloperName],         
  [AccountId],         
  [CaseNumber],         
  [ClosedDate],         
  [ContactId],         
  [Subject],         
  [Description],         
  [IsClosed],         
  [IsClosedOnCreate],         
  [IsEscalated],         
  [Language],         
  [MasterRecordId],         
  [Origin],         
  [OwnerId],         
  [ParentId],         
  [Priority],         
  [Reason],         
  [Status],         
  [Type],         
  [TimeZone_c],         
  [SubType_c],         
  [CurrentState_c],         
  [CurrentCountry_c],         
  [CurrentStreet_c],         
  [CurrentCity_c],         
  [CurrentPostalCode_c],         
  [IncidentCity_c],         
  [IncidentCountry_c],         
  [IncidentState_c],         
  [IncidentStreet_c],         
  [IncidentPostalCode_c],         
  [RiskRating_c],         
  [RiskReason_c],         
  [ProgramType_c],         
  [ClaimNumber_c],         
  [Underwriter_c],         
  [SourceId],         
  [SuppliedCompany],         
  [SuppliedEmail],         
  [SuppliedName],         
  [SuppliedPhone],         
  [ActionPlanCreated_c],         
  [AmountToCollect_c],         
  [ApprovalDateTime_c],         
  [ApprovalSoughtDetails_c],         
  [Assistance_Team_c],         
  [AssistCasesCount_c],         
 [AvoidedLoss_c],         
  [BinNumberPortal_c],         
  [BINNumber_c],         
  [Buffer_c],         
  [BypassStatusChangeValidation_c],         
  [CallBackCustomerTaskCreated_c],         
  [CarRentalLicensePlate_c],         
  [Carrentalpickupdate_c],         
  [Carrentalreturndate_c],         
  [CarRentalVIN_c],         
  [CaseAge_c],         
  [CaseComment_c],         
  [CaseCreatedDate_c],         
  [CaseDecision_c],         
  [CaseFeeWaived_c],         
  [CaseIndicatorFlag_c],         
  [CaseNotProgressedSinceDays_c],         
  [CaseOwnerName_c],         
  [CaseQuestionnaire_c],         
  [CaseType_c],         
  [Case_Status_c],         
  [CashTransfer_c],         
  [CategoryRating_c],         
  [CCEligible_c],         
  [CCProvider_c],         
  [ClaimsStatus_c],         
  [ClaimStatus_c],         
  [ClientOrganization_c],         
  [ComplaintCategory_c],         
  [ConsentReceived_c],         
  [Consent_Flag_c],         
  [ContactAge_c],         
  [ContactBirthDate_c],         
  [ContactIntakeFields_c],         
  [CorporateAccount_c],         
  [CreatingThisCaseForSelf_c],         
  [CurrentDiagnosis_c],         
  [CurrentLocationTime_c],         
  [CurrentlyTravelling_c],         
  [CurrentTime_c],         
  [CustomerContactPermitted_c],         
  [CustomerCurrentCountry_c],         
  [CustomerCurrentState_c],         
  [DateofTreatmentInitialSought_c],         
  [DepartureDate_c],         
  [DesiredOutcome_c],         
  [DestinationCity_c],         
  [DestinationCountry_c],         
  [DestinationState_c],         
  [DirectionalCare_c],         
  [Dissatisfied_c],         
  [DueDate_c],         
  [EMCDetails_c],         
  [EMCReview_c],         
  [EmployerGroup_c],         
  [EmployerName_c],         
  [EscalationEmail_c],         
  [EscalationStatus_c],         
  [Estoppel_c],         
  [ExcessPaid_c],         
  [ExternalClaimReference_c],         
  [FeedbackAbout_c],         
  [FeedbackType_c],         
  [FinalAmount_c],         
  [FitToFlyDate_c],         
  [FitToTravelDate_c],         
  [From_c],         
  [GCNLink_c],         
  [GHIP_c],         
  [Handover_c],         
  [HastheCustomerSoughtMedicalAdvise_c],         
  [ICDDescription_c],         
  [IncidentDate_c],         
  [IncidentLocation_c],         
  [IncidentSummary_c],         
  [IntakeQuestionnaire_c],         
  [IntakeRequiredFieldStandard_c],         
  [IntakeRequiredFields_c],         
  [InternalClaim_c],         
  [InvestigationOutcome_c],         
  [InvestigationReason_c],         
  [Investigation_c],         
  [ItemPurchaseDate_c],         
  [KnowledgeSearchKeywords_c],         
  [LargeLoss_c],         
  [LastCommunicationDateTime_c],         
  [LastStatusModifiedDate_c],         
  [MediaPartnerEmail_c],         
  [MedicalConsultantRecommendation_c],         
  [MedicalSought_c],         
  [MedicalSummary_c],         
  [MembershipNumber_c],         
  [MethodofTravel_c],         
  [NumberofTeleAppointmentsperCase_c],         
  [NumberOfTravellingCompanions_c],         
  [OtherReasonForDissatisfaction_c],         
  [PlanNumber_c],         
  [PlanType_c],         
  [PolicyCertificatePlanNumber_c],         
  [PolicyCountry_c],         
  [PolicyEndDate_c],         
  [PolicyMember_c],         
  [PolicyNumber1_c],         
  [PolicyNumber__c],         
  [PolicyStartDate_c],         
  [PolicyType_c],         
  [Policy_End_Date_c],         
  [Policy_Number_c],         
  [Policy_Start_Date_c],         
  [Policy_c],         
  [PortalCaseScreenNo_c],         
  [PotentialRecovery_c],         
  [PreferredContactMethod_c],         
  [PrimaryDiagnosisCode_c],         
  [PrimaryDiagnosis_c],         
  [PrivacyStatement_c],         
  [PrivateCase_c],         
  [Private_c],         
  [ProviderNameComplaint_c],         
  [ProviderName_c],         
  [Purpose_c],         
  [QANotes_c],         
  [ReasonForComplaint_c],         
  [ReasonForDissatisfaction_c],         
  [ReasonforMonitoring_c],         
  [ReceivedDate_c],         
  [ReciprocalHeathcareAgreements_c],         
  [RedactionDateTime_c],         
  [RentalAgencyDetails_c],         
  [ReopenedDateTime_c],         
  [ResolutionPlan_c],         
  [RespondCaseId_c],         
  [RespondCaseRef_c],         
  [ResponsibleBusinessArea_c],         
  [ReturnDate_c],         
  [ReviewReason_c],         
  [ReimbursedAmount_c],         
  [Sanctioned_c],         
  [SecondaryRiskReason_c],         
  [SecurityEvent_c],         
  [Sensitive_c],         
  [SpousePlanName_c],         
  [SpousePlanNumber_c],         
  [STAccidentalDeathDismemberment_c],         
  [STAmendedTravelArrangements_c],         
  [STArrangements_c],         
  [STAssistance_c],         
  [STBenestar_c],         
  [STClaimsDocumentAssistance_c],         
  [STCLDI_c],         
  [STCostContainmentComplaint_c],         
  [STCostContainmentMedicalMonitoring_c],         
  [STDeathCase_c],         
  [STDelayedLuggage_c],         
  [STDirectionalCare_c],         
  [STDuringTravel_c],         
  [STEmergencyCashTransfer_c],         
  [STEntertainment_c],         
  [STEvacuation_c],         
  [STEventManagement_c],         
  [STExtendedWarranty_c],         
  [STFlight_c],         
  [STGiftFloralBaskets_c],         
  [STGolf_c],         
  [STHireVehicleExcess_c],         
  [STHotel_c],         
  [STIllness_c],         
  [STInbound_c],         
  [STInformationDuringTrip_c],         
  [STInjury_c],         
  [STInPatient_c],         
  [STInternetSearchforItemAccessory_c],         
  [STLostStolenLuggage_c],         
  [STLostStolenTravelDocuments_c],         
  [STMedicalMonitoring_c],         
  [STMedicationPurchaseDelivery_c],         
  [STMessageCentreService_c],         
  [STNotification_c],         
  [STOther_c],         
  [STOutPatient_c],         
  [STPrescriptionReplacements_c],         
  [STPreTravel_c],         
  [STPreTripInformationMedical_c],         
  [STPreTripInformationSecurity_c],         
  [STPriceProtection_c],         
  [STProductComplaint_c],         
  [STProviderQualityComplaint_c],         
  [STPurchaseAssurance_c],         
  [STRepatriation_c],         
  [STReplacementOfLostStolenDocuments_c],         
  [STReservationBooking_c],         
  [STRestaurantReservation_c],         
  [STRoadSideHomeAssistance_c],         
  [STSecurityIncident_c],         
  [STServiceOtherComplaint_c],         
  [STServiceWTPComplaint_c],         
  [STShoppingHealthClubs_c],         
  [STTeleMedicine_c],         
  [STTravelAssistance_c],         
  [STTravelDelay_c],         
  [STTripCancellation_c],         
  [STTripInterruptionCurtailment_c],         
  [STVisaExtension_c],         
  [SubmissionDate_c],         
  [SubTypeInbound_c],         
  [Supervision_c],         
  [Symptoms_c],         
  [TaskDueDateTime_c],         
  [TaskDueDate_c],         
  [TemplateGroupName_c],         
  [ThirdPartyLiability_c],         
  [TimeTakenforDecision_c],         
  [TodaysDate_c],         
  [TotalClaimPaymentsReservedandPaid_c],         
  [TotalDiagnosis_c],         
  [TotalEstimate_c],         
  [TotalPayments_c],         
  [TravelerAddress_c],         
  [TravelerBirthdate_c],         
  [TravelerDeathDate_c],         
  [TravelerDefaulter_c],         
  [TravelerEmail_c],         
  [TravelerFirstName_c],         
  [TravelerFlag_c],      
  [TravelerGender_c],         
  [TravelerLanguage_c],         
  [TravelerName1_c],         
  [TravelerName_c],         
  [TravelerPhone_c],         
  [TravelerPotentialIssue_c],         
  [TravellerDateofBirth_c],         
  [TravellerName_c],         
  [TreatingTeamApproval_c],         
  [TripPurchaseDate_c],         
  [Trip_End_Date_c],         
  [Trip_Length_c],         
  [Trip_Start_Date_c],         
  [UnderwriterPortalLink_c],         
  [UnderwriterThresholdReached_c],         
  [UnreadEmail_c],         
  [Unread_c],         
  [UpdatedCostToDates_c],         
  [UrgentAssistance_c],         
  [UWApprovalDetails_c],         
  [UWApprovalRequiredFields_c],         
  [UWContact_c],         
  [VulnerableCustomer_c],         
  [WhatKindofvehicle_c],         
  [WhoInitialTreatmentWasSoughtFrom_c],         
  [WorkersComp_c],         
  [ZurichUKChannel_c],         
  [HandoverSummary_c],         
  [CreatedDateQLD],         
  [ClosedDateQLD],        
  [CaseFeeTypeOverride_c],      
  [First_Closed_Date_c]      
  )        
 VALUES (        
  SRC.[Id],         
  SRC.[IsDeleted],         
  SRC.[Currency_ISOCode],         
  SRC.[CreatedById],         
  SRC.[CreatedDate],         
  SRC.[LastModifiedDate],         
  SRC.[LastModifiedById],         
  SRC.[LastReferencedDate],         
  SRC.[LastViewedDate],         SRC.[SystemModstamp],         
  SRC.[RecordTypeId],         
  SRC.[RecordType_DeveloperName],         
  SRC.[AccountId],         
  SRC.[CaseNumber],         
  SRC.[ClosedDate],         
  SRC.[ContactId],         
  SRC.[Subject],         
  SRC.[Description],         
  SRC.[IsClosed],         
  SRC.[IsClosedOnCreate],         
  SRC.[IsEscalated],         
  SRC.[Language],         
  SRC.[MasterRecordId],         
  SRC.[Origin],         
  SRC.[OwnerId],         
  SRC.[ParentId],         
  SRC.[Priority],         
  SRC.[Reason],         
  SRC.[Status],         
  SRC.[Type],         
  SRC.[TimeZone_c],         
  SRC.[SubType_c],         
  SRC.[CurrentState_c],         
  SRC.[CurrentCountry_c],         
  SRC.[CurrentStreet_c],         
  SRC.[CurrentCity_c],         
  SRC.[CurrentPostalCode_c],         
  SRC.[IncidentCity_c],         
  SRC.[IncidentCountry_c],         
  SRC.[IncidentState_c],         
  SRC.[IncidentStreet_c],         
  SRC.[IncidentPostalCode_c],         
  SRC.[RiskRating_c],         
  SRC.[RiskReason_c],         
  SRC.[ProgramType_c],         
  SRC.[ClaimNumber_c],         
  SRC.[Underwriter_c],         
  SRC.[SourceId],         
  SRC.[SuppliedCompany],         
  SRC.[SuppliedEmail],         
  SRC.[SuppliedName],         
  SRC.[SuppliedPhone],         
  SRC.[ActionPlanCreated_c],         
  SRC.[AmountToCollect_c],         
  SRC.[ApprovalDateTime_c],         
  SRC.[ApprovalSoughtDetails_c],         
  SRC.[Assistance_Team_c],         
  SRC.[AssistCasesCount_c],         
  SRC.[AvoidedLoss_c],         
  SRC.[BinNumberPortal_c],         
  SRC.[BINNumber_c],         
  SRC.[Buffer_c],         
  SRC.[BypassStatusChangeValidation_c],         
  SRC.[CallBackCustomerTaskCreated_c],         
  SRC.[CarRentalLicensePlate_c],         
  SRC.[Carrentalpickupdate_c],         
  SRC.[Carrentalreturndate_c],         
  SRC.[CarRentalVIN_c],         
  SRC.[CaseAge_c],         
  SRC.[CaseComment_c],         
  SRC.[CaseCreatedDate_c],         
  SRC.[CaseDecision_c],         
  SRC.[CaseFeeWaived_c],         
  SRC.[CaseIndicatorFlag_c],         
  SRC.[CaseNotProgressedSinceDays_c],         
  SRC.[CaseOwnerName_c],         
  SRC.[CaseQuestionnaire_c],         
  SRC.[CaseType_c],         
  SRC.[Case_Status_c],         
  SRC.[CashTransfer_c],         
  SRC.[CategoryRating_c],         
  SRC.[CCEligible_c],         
  SRC.[CCProvider_c],         
  SRC.[ClaimsStatus_c],         
  SRC.[ClaimStatus_c],         
  SRC.[ClientOrganization_c],         
  SRC.[ComplaintCategory_c],         
  SRC.[ConsentReceived_c],         
  SRC.[Consent_Flag_c],         
  SRC.[ContactAge_c],         
  SRC.[ContactBirthDate_c],         
  SRC.[ContactIntakeFields_c],           SRC.[CorporateAccount_c],         
  SRC.[CreatingThisCaseForSelf_c],         
  SRC.[CurrentDiagnosis_c],         
  SRC.[CurrentLocationTime_c],         
  SRC.[CurrentlyTravelling_c],         
  SRC.[CurrentTime_c],         
  SRC.[CustomerContactPermitted_c],         
  SRC.[CustomerCurrentCountry_c],         
  SRC.[CustomerCurrentState_c],         
  SRC.[DateofTreatmentInitialSought_c],         
  SRC.[DepartureDate_c],         
  SRC.[DesiredOutcome_c],         
  SRC.[DestinationCity_c],         
  SRC.[DestinationCountry_c],         
  SRC.[DestinationState_c],         
  SRC.[DirectionalCare_c],         
  SRC.[Dissatisfied_c],         
  SRC.[DueDate_c],         
  SRC.[EMCDetails_c],         
  SRC.[EMCReview_c],         
  SRC.[EmployerGroup_c],         
  SRC.[EmployerName_c],         
  SRC.[EscalationEmail_c],         
  SRC.[EscalationStatus_c],         
  SRC.[Estoppel_c],         
  SRC.[ExcessPaid_c],         
  SRC.[ExternalClaimReference_c],         
  SRC.[FeedbackAbout_c],         
  SRC.[FeedbackType_c],         
  SRC.[FinalAmount_c],         
  SRC.[FitToFlyDate_c],         
  SRC.[FitToTravelDate_c],         
  SRC.[From_c],         
  SRC.[GCNLink_c],         
  SRC.[GHIP_c],         
  SRC.[Handover_c],         
  SRC.[HastheCustomerSoughtMedicalAdvise_c],         
  SRC.[ICDDescription_c],         
  SRC.[IncidentDate_c],         
  SRC.[IncidentLocation_c],         
  SRC.[IncidentSummary_c],         
  SRC.[IntakeQuestionnaire_c],         
  SRC.[IntakeRequiredFieldStandard_c],         
  SRC.[IntakeRequiredFields_c],         
  SRC.[InternalClaim_c],         
  SRC.[InvestigationOutcome_c],         
  SRC.[InvestigationReason_c],         
  SRC.[Investigation_c],         
  SRC.[ItemPurchaseDate_c],         
  SRC.[KnowledgeSearchKeywords_c],         
  SRC.[LargeLoss_c],         
  SRC.[LastCommunicationDateTime_c],         
  SRC.[LastStatusModifiedDate_c],         
  SRC.[MediaPartnerEmail_c],         
  SRC.[MedicalConsultantRecommendation_c],         
  SRC.[MedicalSought_c],         
  SRC.[MedicalSummary_c],         
  SRC.[MembershipNumber_c],         
  SRC.[MethodofTravel_c],         
  SRC.[NumberofTeleAppointmentsperCase_c],         
  SRC.[NumberOfTravellingCompanions_c],         
  SRC.[OtherReasonForDissatisfaction_c],         
  SRC.[PlanNumber_c],         
  SRC.[PlanType_c],         
  SRC.[PolicyCertificatePlanNumber_c],         
  SRC.[PolicyCountry_c],         
  SRC.[PolicyEndDate_c],         
  SRC.[PolicyMember_c],         
  SRC.[PolicyNumber1_c],         
  SRC.[PolicyNumber__c],         
  SRC.[PolicyStartDate_c],         
  SRC.[PolicyType_c],         
  SRC.[Policy_End_Date_c],         
  SRC.[Policy_Number_c],         
  SRC.[Policy_Start_Date_c],         
  SRC.[Policy_c],         
  SRC.[PortalCaseScreenNo_c],         
  SRC.[PotentialRecovery_c],         
  SRC.[PreferredContactMethod_c],         
  SRC.[PrimaryDiagnosisCode_c],         
  SRC.[PrimaryDiagnosis_c],         
  SRC.[PrivacyStatement_c],         
  SRC.[PrivateCase_c],         
  SRC.[Private_c],         
  SRC.[ProviderNameComplaint_c],         
  SRC.[ProviderName_c],         
  SRC.[Purpose_c],         
  SRC.[QANotes_c],         
  SRC.[ReasonForComplaint_c],         
  SRC.[ReasonForDissatisfaction_c],         
  SRC.[ReasonforMonitoring_c],         
  SRC.[ReceivedDate_c],         
  SRC.[ReciprocalHeathcareAgreements_c],         
  SRC.[RedactionDateTime_c],         
  SRC.[RentalAgencyDetails_c],         
  SRC.[ReopenedDateTime_c],         
  SRC.[ResolutionPlan_c],         
  SRC.[RespondCaseId_c],         
  SRC.[RespondCaseRef_c],         
  SRC.[ResponsibleBusinessArea_c],         
  SRC.[ReturnDate_c],         
  SRC.[ReviewReason_c],         
  SRC.[ReimbursedAmount_c],         
  SRC.[Sanctioned_c],         
  SRC.[SecondaryRiskReason_c],         
  SRC.[SecurityEvent_c],         
  SRC.[Sensitive_c],         
  SRC.[SpousePlanName_c],         
  SRC.[SpousePlanNumber_c],         
  SRC.[STAccidentalDeathDismemberment_c],         
  SRC.[STAmendedTravelArrangements_c],         
  SRC.[STArrangements_c],         
  SRC.[STAssistance_c],         
  SRC.[STBenestar_c],         
  SRC.[STClaimsDocumentAssistance_c],         
  SRC.[STCLDI_c],         
  SRC.[STCostContainmentComplaint_c],         
  SRC.[STCostContainmentMedicalMonitoring_c],         
  SRC.[STDeathCase_c],         
  SRC.[STDelayedLuggage_c],         
  SRC.[STDirectionalCare_c],         
  SRC.[STDuringTravel_c],         
  SRC.[STEmergencyCashTransfer_c],         
  SRC.[STEntertainment_c],         
  SRC.[STEvacuation_c],         
  SRC.[STEventManagement_c],         
  SRC.[STExtendedWarranty_c],         
  SRC.[STFlight_c],         
  SRC.[STGiftFloralBaskets_c],         
  SRC.[STGolf_c],         
  SRC.[STHireVehicleExcess_c],         
  SRC.[STHotel_c],         
  SRC.[STIllness_c],         
  SRC.[STInbound_c],         
  SRC.[STInformationDuringTrip_c],         
  SRC.[STInjury_c],         
  SRC.[STInPatient_c],         
  SRC.[STInternetSearchforItemAccessory_c],         
  SRC.[STLostStolenLuggage_c],         
  SRC.[STLostStolenTravelDocuments_c],         
  SRC.[STMedicalMonitoring_c],         
  SRC.[STMedicationPurchaseDelivery_c],         
  SRC.[STMessageCentreService_c],         
  SRC.[STNotification_c],         
  SRC.[STOther_c],         
  SRC.[STOutPatient_c],         
  SRC.[STPrescriptionReplacements_c],         
  SRC.[STPreTravel_c],         
  SRC.[STPreTripInformationMedical_c],         
  SRC.[STPreTripInformationSecurity_c],         
  SRC.[STPriceProtection_c],         
  SRC.[STProductComplaint_c],         
  SRC.[STProviderQualityComplaint_c],         
  SRC.[STPurchaseAssurance_c],         
  SRC.[STRepatriation_c],         
  SRC.[STReplacementOfLostStolenDocuments_c],         
  SRC.[STReservationBooking_c],         
  SRC.[STRestaurantReservation_c],         
  SRC.[STRoadSideHomeAssistance_c],     
  SRC.[STSecurityIncident_c],         
  SRC.[STServiceOtherComplaint_c],         
  SRC.[STServiceWTPComplaint_c],         
  SRC.[STShoppingHealthClubs_c],         
  SRC.[STTeleMedicine_c],         
  SRC.[STTravelAssistance_c],         
  SRC.[STTravelDelay_c],         
  SRC.[STTripCancellation_c],         
  SRC.[STTripInterruptionCurtailment_c],         
  SRC.[STVisaExtension_c],         
  SRC.[SubmissionDate_c],         
  SRC.[SubTypeInbound_c],         
  SRC.[Supervision_c],         
  SRC.[Symptoms_c],         
  SRC.[TaskDueDateTime_c],         
  SRC.[TaskDueDate_c],         
  SRC.[TemplateGroupName_c],         
  SRC.[ThirdPartyLiability_c],         
  SRC.[TimeTakenforDecision_c],         
  SRC.[TodaysDate_c],         
  SRC.[TotalClaimPaymentsReservedandPaid_c],         
  SRC.[TotalDiagnosis_c],         
  SRC.[TotalEstimate_c],         
  SRC.[TotalPayments_c],         
  SRC.[TravelerAddress_c],         
  SRC.[TravelerBirthdate_c],         
  SRC.[TravelerDeathDate_c],         
  SRC.[TravelerDefaulter_c],         
  SRC.[TravelerEmail_c],         
  SRC.[TravelerFirstName_c],         
  SRC.[TravelerFlag_c],         
  SRC.[TravelerGender_c],         
  SRC.[TravelerLanguage_c],         
  SRC.[TravelerName1_c],         
  SRC.[TravelerName_c],         
  SRC.[TravelerPhone_c],         
  SRC.[TravelerPotentialIssue_c],         
  SRC.[TravellerDateofBirth_c],         
  SRC.[TravellerName_c],         
  SRC.[TreatingTeamApproval_c],         
  SRC.[TripPurchaseDate_c],         
  SRC.[Trip_End_Date_c],         
  SRC.[Trip_Length_c],         
  SRC.[Trip_Start_Date_c],         
  SRC.[UnderwriterPortalLink_c],         
  SRC.[UnderwriterThresholdReached_c],         
  SRC.[UnreadEmail_c],         
  SRC.[Unread_c],         
  SRC.[UpdatedCostToDates_c],         
  SRC.[UrgentAssistance_c],         
  SRC.[UWApprovalDetails_c],         
  SRC.[UWApprovalRequiredFields_c],         
  SRC.[UWContact_c],         
  SRC.[VulnerableCustomer_c],         
  SRC.[WhatKindofvehicle_c],        
  SRC.[WhoInitialTreatmentWasSoughtFrom_c],         
  SRC.[WorkersComp_c],         
  SRC.[ZurichUKChannel_c],         
  SRC.[HandoverSummary_c],         
  SRC.[CreatedDateQLD],         
  SRC.[ClosedDateQLD],        
  SRC.[CaseFeeTypeOverride_c],      
  SRC.[First_Closed_Date_c]      
  )        
 WHEN MATCHED AND (        
  ISNULL(DST.[IsDeleted],  '1' ) <> ISNULL(SRC.[IsDeleted],  '1' ) OR        
  ISNULL(DST.[Currency_ISOCode],  '' ) <> ISNULL(SRC.[Currency_ISOCode],  '' ) OR        
  ISNULL(DST.[CreatedById],  '' ) <> ISNULL(SRC.[CreatedById],  '' ) OR        
  ISNULL(DST.[CreatedDate],  '1900-01-01' ) <> ISNULL(SRC.[CreatedDate],  '1900-01-01' ) OR        
  ISNULL(DST.[LastModifiedDate],  '1900-01-01' ) <> ISNULL(SRC.[LastModifiedDate],  '1900-01-01' ) OR        
  ISNULL(DST.[LastModifiedById],  '' ) <> ISNULL(SRC.[LastModifiedById],  '' ) OR        
  ISNULL(DST.[LastReferencedDate],  '1900-01-01' ) <> ISNULL(SRC.[LastReferencedDate],  '1900-01-01' ) OR        
  ISNULL(DST.[LastViewedDate],  '1900-01-01' ) <> ISNULL(SRC.[LastViewedDate],  '1900-01-01' ) OR        
  ISNULL(DST.[SystemModstamp],  '1900-01-01' ) <> ISNULL(SRC.[SystemModstamp],  '1900-01-01' ) OR        
  ISNULL(DST.[RecordTypeId],  '' ) <> ISNULL(SRC.[RecordTypeId],  '' ) OR        
  ISNULL(DST.[RecordType_DeveloperName],  '' ) <> ISNULL(SRC.[RecordType_DeveloperName],  '' ) OR        
  ISNULL(DST.[AccountId],  '' ) <> ISNULL(SRC.[AccountId],  '' ) OR        
  ISNULL(DST.[CaseNumber],  0 ) <> ISNULL(SRC.[CaseNumber],  0 ) OR        
  ISNULL(DST.[ClosedDate],  '1900-01-01' ) <> ISNULL(SRC.[ClosedDate],  '1900-01-01' ) OR        
  ISNULL(DST.[ContactId],  '' ) <> ISNULL(SRC.[ContactId],  '' ) OR        
  ISNULL(DST.[Subject],  '' ) <> ISNULL(SRC.[Subject],  '' ) OR        
  ISNULL(DST.[Description],  '' ) <> ISNULL(SRC.[Description],  '' ) OR        
  ISNULL(DST.[IsClosed],  '1' ) <> ISNULL(SRC.[IsClosed],  '1' ) OR        
  ISNULL(DST.[IsClosedOnCreate],  '1' ) <> ISNULL(SRC.[IsClosedOnCreate],  '1' ) OR        
  ISNULL(DST.[IsEscalated],  '1' ) <> ISNULL(SRC.[IsEscalated],  '1' ) OR        
  ISNULL(DST.[Language],  '' ) <> ISNULL(SRC.[Language],  '' ) OR        
  ISNULL(DST.[MasterRecordId],  '' ) <> ISNULL(SRC.[MasterRecordId],  '' ) OR        
  ISNULL(DST.[Origin],  '' ) <> ISNULL(SRC.[Origin],  '' ) OR        
  ISNULL(DST.[OwnerId],  '' ) <> ISNULL(SRC.[OwnerId],  '' ) OR        
  ISNULL(DST.[ParentId],  '' ) <> ISNULL(SRC.[ParentId],  '' ) OR        
  ISNULL(DST.[Priority],  '' ) <> ISNULL(SRC.[Priority],  '' ) OR        
  ISNULL(DST.[Reason],  '' ) <> ISNULL(SRC.[Reason],  '' ) OR        
  ISNULL(DST.[Status],  '' ) <> ISNULL(SRC.[Status],  '' ) OR        
  ISNULL(DST.[Type],  '' ) <> ISNULL(SRC.[Type],  '' ) OR        
  ISNULL(DST.[TimeZone_c],  '' ) <> ISNULL(SRC.[TimeZone_c],  '' ) OR        
  ISNULL(DST.[SubType_c],  '' ) <> ISNULL(SRC.[SubType_c],  '' ) OR        
  ISNULL(DST.[CurrentState_c],  '' ) <> ISNULL(SRC.[CurrentState_c],  '' ) OR        
  ISNULL(DST.[CurrentCountry_c],  '' ) <> ISNULL(SRC.[CurrentCountry_c],  '' ) OR        
  ISNULL(DST.[CurrentStreet_c],  '' ) <> ISNULL(SRC.[CurrentStreet_c],  '' ) OR        
  ISNULL(DST.[CurrentCity_c],  '' ) <> ISNULL(SRC.[CurrentCity_c],  '' ) OR        
  ISNULL(DST.[CurrentPostalCode_c],  '' ) <> ISNULL(SRC.[CurrentPostalCode_c],  '' ) OR        
  ISNULL(DST.[IncidentCity_c],  '' ) <> ISNULL(SRC.[IncidentCity_c],  '' ) OR        
  ISNULL(DST.[IncidentCountry_c],  '' ) <> ISNULL(SRC.[IncidentCountry_c],  '' ) OR        
  ISNULL(DST.[IncidentState_c],  '' ) <> ISNULL(SRC.[IncidentState_c],  '' ) OR        
  ISNULL(DST.[IncidentStreet_c],  '' ) <> ISNULL(SRC.[IncidentStreet_c],  '' ) OR        
  ISNULL(DST.[IncidentPostalCode_c],  '' ) <> ISNULL(SRC.[IncidentPostalCode_c],  '' ) OR        
  ISNULL(DST.[RiskRating_c],  '' ) <> ISNULL(SRC.[RiskRating_c],  '' ) OR        
  ISNULL(DST.[RiskReason_c],  '' ) <> ISNULL(SRC.[RiskReason_c],  '' ) OR        
  ISNULL(DST.[ProgramType_c],  '' ) <> ISNULL(SRC.[ProgramType_c],  '' ) OR        
  ISNULL(DST.[ClaimNumber_c],  '' ) <> ISNULL(SRC.[ClaimNumber_c],  '' ) OR        
  ISNULL(DST.[Underwriter_c],  '' ) <> ISNULL(SRC.[Underwriter_c],  '' ) OR        
  ISNULL(DST.[SourceId],  '' ) <> ISNULL(SRC.[SourceId],  '' ) OR        
  ISNULL(DST.[SuppliedCompany],  '' ) <> ISNULL(SRC.[SuppliedCompany],  '' ) OR        
  ISNULL(DST.[SuppliedEmail],  '' ) <> ISNULL(SRC.[SuppliedEmail],  '' ) OR        
  ISNULL(DST.[SuppliedName],  '' ) <> ISNULL(SRC.[SuppliedName],  '' ) OR        
  ISNULL(DST.[SuppliedPhone],  '' ) <> ISNULL(SRC.[SuppliedPhone],  '' ) OR        
  ISNULL(DST.[ActionPlanCreated_c],  '1' ) <> ISNULL(SRC.[ActionPlanCreated_c],  '1' ) OR        
  ISNULL(DST.[AmountToCollect_c],  0 ) <> ISNULL(SRC.[AmountToCollect_c],  0 ) OR        
  ISNULL(DST.[ApprovalDateTime_c],  '1900-01-01' ) <> ISNULL(SRC.[ApprovalDateTime_c],  '1900-01-01' ) OR        
  ISNULL(DST.[ApprovalSoughtDetails_c],  '' ) <> ISNULL(SRC.[ApprovalSoughtDetails_c],  '' ) OR        
  ISNULL(DST.[Assistance_Team_c],  '' ) <> ISNULL(SRC.[Assistance_Team_c],  '' ) OR        
  ISNULL(DST.[AssistCasesCount_c],  0 ) <> ISNULL(SRC.[AssistCasesCount_c],  0 ) OR        
  ISNULL(DST.[AvoidedLoss_c],  0 ) <> ISNULL(SRC.[AvoidedLoss_c],  0 ) OR        
  ISNULL(DST.[BinNumberPortal_c],  '' ) <> ISNULL(SRC.[BinNumberPortal_c],  '' ) OR        
  ISNULL(DST.[BINNumber_c],  '' ) <> ISNULL(SRC.[BINNumber_c],  '' ) OR        
  ISNULL(DST.[Buffer_c],  0 ) <> ISNULL(SRC.[Buffer_c],  0 ) OR        
  ISNULL(DST.[BypassStatusChangeValidation_c],  '1' ) <> ISNULL(SRC.[BypassStatusChangeValidation_c],  '1' ) OR        
  ISNULL(DST.[CallBackCustomerTaskCreated_c],  '1' ) <> ISNULL(SRC.[CallBackCustomerTaskCreated_c],  '1' ) OR        
  ISNULL(DST.[CarRentalLicensePlate_c],  '' ) <> ISNULL(SRC.[CarRentalLicensePlate_c],  '' ) OR        
  ISNULL(DST.[Carrentalpickupdate_c],  '1900-01-01' ) <> ISNULL(SRC.[Carrentalpickupdate_c],  '1900-01-01' ) OR        
  ISNULL(DST.[Carrentalreturndate_c],  '1900-01-01' ) <> ISNULL(SRC.[Carrentalreturndate_c],  '1900-01-01' ) OR        
  ISNULL(DST.[CarRentalVIN_c],  '' ) <> ISNULL(SRC.[CarRentalVIN_c],  '') OR        
  ISNULL(DST.[CaseAge_c],  0 ) <> ISNULL(SRC.[CaseAge_c],  0 ) OR        
  ISNULL(DST.[CaseComment_c],  '' ) <> ISNULL(SRC.[CaseComment_c],  '' ) OR        
  ISNULL(DST.[CaseCreatedDate_c],  '1900-01-01' ) <> ISNULL(SRC.[CaseCreatedDate_c],  '1900-01-01' ) OR        
  ISNULL(DST.[CaseDecision_c],  '' ) <> ISNULL(SRC.[CaseDecision_c],  '' ) OR        
  ISNULL(DST.[CaseFeeWaived_c],  '1' ) <> ISNULL(SRC.[CaseFeeWaived_c],  '1' ) OR        
  ISNULL(DST.[CaseIndicatorFlag_c],  '' ) <> ISNULL(SRC.[CaseIndicatorFlag_c],  '' ) OR        
  ISNULL(DST.[CaseNotProgressedSinceDays_c],  0 ) <> ISNULL(SRC.[CaseNotProgressedSinceDays_c],  0 ) OR        
  ISNULL(DST.[CaseOwnerName_c],  '' ) <> ISNULL(SRC.[CaseOwnerName_c],  '' ) OR        
  ISNULL(DST.[CaseQuestionnaire_c],  '' ) <> ISNULL(SRC.[CaseQuestionnaire_c],  '' ) OR        
  ISNULL(DST.[CaseType_c],  '' ) <> ISNULL(SRC.[CaseType_c],  '' ) OR        
  ISNULL(DST.[Case_Status_c],  '' ) <> ISNULL(SRC.[Case_Status_c],  '' ) OR        
  ISNULL(DST.[CashTransfer_c],  '' ) <> ISNULL(SRC.[CashTransfer_c],  '' ) OR        
  ISNULL(DST.[CategoryRating_c],  '' ) <> ISNULL(SRC.[CategoryRating_c],  '' ) OR        
  ISNULL(DST.[CCEligible_c],  '1' ) <> ISNULL(SRC.[CCEligible_c],  '1' ) OR        
  ISNULL(DST.[CCProvider_c],  '' ) <> ISNULL(SRC.[CCProvider_c],  '' ) OR        
  ISNULL(DST.[ClaimsStatus_c],  '' ) <> ISNULL(SRC.[ClaimsStatus_c],  '' ) OR        
  ISNULL(DST.[ClaimStatus_c],  '' ) <> ISNULL(SRC.[ClaimStatus_c],  '' ) OR        
  ISNULL(DST.[ClientOrganization_c],  '' ) <> ISNULL(SRC.[ClientOrganization_c],  '' ) OR        
  ISNULL(DST.[ComplaintCategory_c],  '' ) <> ISNULL(SRC.[ComplaintCategory_c],  '' ) OR        
  ISNULL(DST.[ConsentReceived_c],  '1' ) <> ISNULL(SRC.[ConsentReceived_c],  '1' ) OR        
  ISNULL(DST.[Consent_Flag_c],  '' ) <> ISNULL(SRC.[Consent_Flag_c],  '' ) OR        
  ISNULL(DST.[ContactAge_c],  0 ) <> ISNULL(SRC.[ContactAge_c],  0 ) OR        
  ISNULL(DST.[ContactBirthDate_c],  '1900-01-01' ) <> ISNULL(SRC.[ContactBirthDate_c],  '1900-01-01' ) OR        
  ISNULL(DST.[ContactIntakeFields_c],  '' ) <> ISNULL(SRC.[ContactIntakeFields_c],  '' ) OR        
  ISNULL(DST.[CorporateAccount_c],  '' ) <> ISNULL(SRC.[CorporateAccount_c],  '' ) OR        
  ISNULL(DST.[CreatingThisCaseForSelf_c],  '' ) <> ISNULL(SRC.[CreatingThisCaseForSelf_c],  '' ) OR        
  ISNULL(DST.[CurrentDiagnosis_c],  '' ) <> ISNULL(SRC.[CurrentDiagnosis_c],  '' ) OR        
  ISNULL(DST.[CurrentLocationTime_c],  '' ) <> ISNULL(SRC.[CurrentLocationTime_c],  '' ) OR        
  ISNULL(DST.[CurrentlyTravelling_c],  '1' ) <> ISNULL(SRC.[CurrentlyTravelling_c],  '1' ) OR        
  ISNULL(DST.[CurrentTime_c],  1 ) <> ISNULL(SRC.[CurrentTime_c],  1 ) OR        
  ISNULL(DST.[CustomerContactPermitted_c],  1 ) <> ISNULL(SRC.[CustomerContactPermitted_c],  1 ) OR        
  ISNULL(DST.[CustomerCurrentCountry_c],  '' ) <> ISNULL(SRC.[CustomerCurrentCountry_c],  '' ) OR        
  ISNULL(DST.[CustomerCurrentState_c],  '' ) <> ISNULL(SRC.[CustomerCurrentState_c],  '' ) OR        
  ISNULL(DST.[DateofTreatmentInitialSought_c],  '1900-01-01' ) <> ISNULL(SRC.[DateofTreatmentInitialSought_c],  '1900-01-01' ) OR        
  ISNULL(DST.[DepartureDate_c],  '1900-01-01' ) <> ISNULL(SRC.[DepartureDate_c],  '1900-01-01' ) OR        
  ISNULL(DST.[DesiredOutcome_c],  '' ) <> ISNULL(SRC.[DesiredOutcome_c],  '' ) OR        
  ISNULL(DST.[DestinationCity_c],  '' ) <> ISNULL(SRC.[DestinationCity_c],  '' ) OR        
  ISNULL(DST.[DestinationCountry_c],  '' ) <> ISNULL(SRC.[DestinationCountry_c],  '' ) OR        
  ISNULL(DST.[DestinationState_c],  '' ) <> ISNULL(SRC.[DestinationState_c],  '' ) OR        
  ISNULL(DST.[DirectionalCare_c],  '1' ) <> ISNULL(SRC.[DirectionalCare_c],  '1' ) OR        
  ISNULL(DST.[Dissatisfied_c],  '1' ) <> ISNULL(SRC.[Dissatisfied_c],  '1' ) OR        
  ISNULL(DST.[DueDate_c],  '1900-01-01' ) <> ISNULL(SRC.[DueDate_c],  '1900-01-01' ) OR        
  ISNULL(DST.[EMCDetails_c],  '' ) <> ISNULL(SRC.[EMCDetails_c],  '' ) OR        
  ISNULL(DST.[EMCReview_c],  '' ) <> ISNULL(SRC.[EMCReview_c], '' ) OR        
  ISNULL(DST.[EmployerGroup_c],  '' ) <> ISNULL(SRC.[EmployerGroup_c],  '' ) OR        
  ISNULL(DST.[EmployerName_c],  '' ) <> ISNULL(SRC.[EmployerName_c],  '' ) OR        
  ISNULL(DST.[EscalationEmail_c],  '' ) <> ISNULL(SRC.[EscalationEmail_c],  '' ) OR        
  ISNULL(DST.[EscalationStatus_c],  '' ) <> ISNULL(SRC.[EscalationStatus_c],  '' ) OR        
  ISNULL(DST.[Estoppel_c],  '1' ) <> ISNULL(SRC.[Estoppel_c],  '1' ) OR        
  ISNULL(DST.[ExcessPaid_c],  '' ) <> ISNULL(SRC.[ExcessPaid_c],  '' ) OR        
  ISNULL(DST.[ExternalClaimReference_c],  '' ) <> ISNULL(SRC.[ExternalClaimReference_c],  '' ) OR        
  ISNULL(DST.[FeedbackAbout_c],  '' ) <> ISNULL(SRC.[FeedbackAbout_c],  '' ) OR        
  ISNULL(DST.[FeedbackType_c],  '' ) <> ISNULL(SRC.[FeedbackType_c],  '' ) OR        
  ISNULL(DST.[FinalAmount_c],  0 ) <> ISNULL(SRC.[FinalAmount_c],  0 ) OR        
  ISNULL(DST.[FitToFlyDate_c],  '1900-01-01' ) <> ISNULL(SRC.[FitToFlyDate_c],  '1900-01-01' ) OR        
  ISNULL(DST.[FitToTravelDate_c],  '1900-01-01' ) <> ISNULL(SRC.[FitToTravelDate_c],  '1900-01-01' ) OR        
  ISNULL(DST.[From_c],  '' ) <> ISNULL(SRC.[From_c],  '' ) OR        
  ISNULL(DST.[GCNLink_c],  '' ) <> ISNULL(SRC.[GCNLink_c],  '' ) OR        
  ISNULL(DST.[GHIP_c],  '' ) <> ISNULL(SRC.[GHIP_c],  '' ) OR        
  ISNULL(DST.[Handover_c],  '1' ) <> ISNULL(SRC.[Handover_c],  '1' ) OR        
  ISNULL(DST.[HastheCustomerSoughtMedicalAdvise_c],  '' ) <> ISNULL(SRC.[HastheCustomerSoughtMedicalAdvise_c],  '' ) OR        
  ISNULL(DST.[ICDDescription_c],  '' ) <> ISNULL(SRC.[ICDDescription_c],  '' ) OR        
  ISNULL(DST.[IncidentDate_c],  '1900-01-01' ) <> ISNULL(SRC.[IncidentDate_c],  '1900-01-01' ) OR        
  ISNULL(DST.[IncidentLocation_c],  '' ) <> ISNULL(SRC.[IncidentLocation_c],  '' ) OR        
  ISNULL(DST.[IncidentSummary_c],  '' ) <> ISNULL(SRC.[IncidentSummary_c],  '' ) OR        
  ISNULL(DST.[IntakeQuestionnaire_c],  '' ) <> ISNULL(SRC.[IntakeQuestionnaire_c],  '' ) OR        
  ISNULL(DST.[IntakeRequiredFieldStandard_c],  '' ) <> ISNULL(SRC.[IntakeRequiredFieldStandard_c],  '' ) OR        
  ISNULL(DST.[IntakeRequiredFields_c],  '' ) <> ISNULL(SRC.[IntakeRequiredFields_c],  '' ) OR        
  ISNULL(DST.[InternalClaim_c],  '' ) <> ISNULL(SRC.[InternalClaim_c],  '' ) OR        
  ISNULL(DST.[InvestigationOutcome_c],  '' ) <> ISNULL(SRC.[InvestigationOutcome_c],  '' ) OR        
  ISNULL(DST.[InvestigationReason_c],  '' ) <> ISNULL(SRC.[InvestigationReason_c],  '' ) OR        
  ISNULL(DST.[Investigation_c],  '1' ) <> ISNULL(SRC.[Investigation_c],  '1' ) OR        
  ISNULL(DST.[ItemPurchaseDate_c],  '1900-01-01' ) <> ISNULL(SRC.[ItemPurchaseDate_c],  '1900-01-01' ) OR        
  ISNULL(DST.[KnowledgeSearchKeywords_c],  '' ) <> ISNULL(SRC.[KnowledgeSearchKeywords_c],  '' ) OR        
  ISNULL(DST.[LargeLoss_c],  '1' ) <> ISNULL(SRC.[LargeLoss_c],  '1' ) OR        
  ISNULL(DST.[LastCommunicationDateTime_c],  '1900-01-01' ) <> ISNULL(SRC.[LastCommunicationDateTime_c],  '1900-01-01' ) OR        
  ISNULL(DST.[LastStatusModifiedDate_c],  '1900-01-01' ) <> ISNULL(SRC.[LastStatusModifiedDate_c],  '1900-01-01' ) OR        
  ISNULL(DST.[MediaPartnerEmail_c],  '' ) <> ISNULL(SRC.[MediaPartnerEmail_c],  '' ) OR        
  ISNULL(DST.[MedicalConsultantRecommendation_c],  '' ) <> ISNULL(SRC.[MedicalConsultantRecommendation_c],  '' ) OR        
  ISNULL(DST.[MedicalSought_c],  '' ) <> ISNULL(SRC.[MedicalSought_c],  '' ) OR        
  ISNULL(DST.[MedicalSummary_c],  '' ) <> ISNULL(SRC.[MedicalSummary_c],  '' ) OR        
  ISNULL(DST.[MembershipNumber_c],  '' ) <> ISNULL(SRC.[MembershipNumber_c],  '' ) OR        
  ISNULL(DST.[MethodofTravel_c],  '' ) <> ISNULL(SRC.[MethodofTravel_c],  '' ) OR        
  ISNULL(DST.[NumberofTeleAppointmentsperCase_c],  0 ) <> ISNULL(SRC.[NumberofTeleAppointmentsperCase_c],  0 ) OR        
  ISNULL(DST.[NumberOfTravellingCompanions_c],  0 ) <> ISNULL(SRC.[NumberOfTravellingCompanions_c],  0 ) OR        
  ISNULL(DST.[OtherReasonForDissatisfaction_c],  '' ) <> ISNULL(SRC.[OtherReasonForDissatisfaction_c],  '' ) OR        
  ISNULL(DST.[PlanNumber_c],  '' ) <> ISNULL(SRC.[PlanNumber_c],  '' ) OR        
  ISNULL(DST.[PlanType_c],  '' ) <> ISNULL(SRC.[PlanType_c],  '' ) OR        
  ISNULL(DST.[PolicyCertificatePlanNumber_c],  '' ) <> ISNULL(SRC.[PolicyCertificatePlanNumber_c],  '' ) OR        
  ISNULL(DST.[PolicyCountry_c],  '' ) <> ISNULL(SRC.[PolicyCountry_c],  '' ) OR        
  ISNULL(DST.[PolicyEndDate_c],  '1900-01-01' ) <> ISNULL(SRC.[PolicyEndDate_c],  '1900-01-01' ) OR        
  ISNULL(DST.[PolicyMember_c],  '' ) <> ISNULL(SRC.[PolicyMember_c],  '' ) OR        
  ISNULL(DST.[PolicyNumber1_c],  '' ) <> ISNULL(SRC.[PolicyNumber1_c],  '' ) OR        
  ISNULL(DST.[PolicyNumber__c],  '' ) <> ISNULL(SRC.[PolicyNumber__c],  '' ) OR        
  ISNULL(DST.[PolicyStartDate_c],  '1900-01-01' ) <> ISNULL(SRC.[PolicyStartDate_c],  '1900-01-01' ) OR        
  ISNULL(DST.[PolicyType_c],  '' ) <> ISNULL(SRC.[PolicyType_c],  '' ) OR        
  ISNULL(DST.[Policy_End_Date_c],  '1900-01-01' ) <> ISNULL(SRC.[Policy_End_Date_c],  '1900-01-01' ) OR        
  ISNULL(DST.[Policy_Number_c],  '' ) <> ISNULL(SRC.[Policy_Number_c],  '' ) OR        
  ISNULL(DST.[Policy_Start_Date_c],  '1900-01-01' ) <> ISNULL(SRC.[Policy_Start_Date_c],  '1900-01-01' ) OR        
  ISNULL(DST.[Policy_c],  '' ) <> ISNULL(SRC.[Policy_c],  '' ) OR        
  ISNULL(DST.[PortalCaseScreenNo_c],  '' ) <> ISNULL(SRC.[PortalCaseScreenNo_c],  '' ) OR        
  ISNULL(DST.[PotentialRecovery_c],  '1' ) <> ISNULL(SRC.[PotentialRecovery_c],  '1' ) OR        
  ISNULL(DST.[PreferredContactMethod_c],  '' ) <> ISNULL(SRC.[PreferredContactMethod_c],  '' ) OR        
  ISNULL(DST.[PrimaryDiagnosisCode_c],  '' ) <> ISNULL(SRC.[PrimaryDiagnosisCode_c],  '' ) OR        
  ISNULL(DST.[PrimaryDiagnosis_c],  '' ) <> ISNULL(SRC.[PrimaryDiagnosis_c],  '' ) OR        
  ISNULL(DST.[PrivacyStatement_c],  '' ) <> ISNULL(SRC.[PrivacyStatement_c],  '' ) OR        
  ISNULL(DST.[PrivateCase_c],  '1' ) <> ISNULL(SRC.[PrivateCase_c],  '1' ) OR        
  ISNULL(DST.[Private_c],  '1' ) <> ISNULL(SRC.[Private_c],  '1' ) OR        
  ISNULL(DST.[ProviderNameComplaint_c],  '' ) <> ISNULL(SRC.[ProviderNameComplaint_c],  '' ) OR        
  ISNULL(DST.[ProviderName_c],  '' ) <> ISNULL(SRC.[ProviderName_c],  '' ) OR        
  ISNULL(DST.[Purpose_c],  '' ) <> ISNULL(SRC.[Purpose_c],  '' ) OR        
  ISNULL(DST.[QANotes_c],  '' ) <> ISNULL(SRC.[QANotes_c],  '' ) OR        
  ISNULL(DST.[ReasonForComplaint_c],  '' ) <> ISNULL(SRC.[ReasonForComplaint_c],  '' ) OR        
  ISNULL(DST.[ReasonForDissatisfaction_c],  '' ) <> ISNULL(SRC.[ReasonForDissatisfaction_c],  '' ) OR        
  ISNULL(DST.[ReasonforMonitoring_c],  '' ) <> ISNULL(SRC.[ReasonforMonitoring_c],  '' ) OR        
  ISNULL(DST.[ReceivedDate_c],  '1900-01-01' ) <> ISNULL(SRC.[ReceivedDate_c],  '1900-01-01' ) OR        
  ISNULL(DST.[ReciprocalHeathcareAgreements_c],  '1' ) <> ISNULL(SRC.[ReciprocalHeathcareAgreements_c],  '1' ) OR        
  ISNULL(DST.[RedactionDateTime_c],  '1900-01-01' ) <> ISNULL(SRC.[RedactionDateTime_c],  '1900-01-01' ) OR        
  ISNULL(DST.[RentalAgencyDetails_c],  '' ) <> ISNULL(SRC.[RentalAgencyDetails_c],  '' ) OR        
  ISNULL(DST.[ReopenedDateTime_c],  '1900-01-01' ) <> ISNULL(SRC.[ReopenedDateTime_c],  '1900-01-01' ) OR        
  ISNULL(DST.[ResolutionPlan_c],  '' ) <> ISNULL(SRC.[ResolutionPlan_c],  '' ) OR        
  ISNULL(DST.[RespondCaseId_c],  '' ) <> ISNULL(SRC.[RespondCaseId_c],  '' ) OR        
  ISNULL(DST.[RespondCaseRef_c],  '' ) <> ISNULL(SRC.[RespondCaseRef_c],  '' ) OR        
  ISNULL(DST.[ResponsibleBusinessArea_c],  '' ) <> ISNULL(SRC.[ResponsibleBusinessArea_c],  '' ) OR        
  ISNULL(DST.[ReturnDate_c],  '1900-01-01' ) <> ISNULL(SRC.[ReturnDate_c],  '1900-01-01' ) OR        
  ISNULL(DST.[ReviewReason_c],  '' ) <> ISNULL(SRC.[ReviewReason_c],  '' ) OR        
  ISNULL(DST.[ReimbursedAmount_c],  0 ) <> ISNULL(SRC.[ReimbursedAmount_c],  0 ) OR        
  ISNULL(DST.[Sanctioned_c],  '1' ) <> ISNULL(SRC.[Sanctioned_c],  '1' ) OR        
  ISNULL(DST.[SecondaryRiskReason_c],  '' ) <> ISNULL(SRC.[SecondaryRiskReason_c],  '' ) OR        
  ISNULL(DST.[SecurityEvent_c],  '' ) <> ISNULL(SRC.[SecurityEvent_c],  '' ) OR        
  ISNULL(DST.[Sensitive_c],  '1' ) <> ISNULL(SRC.[Sensitive_c],  '1' ) OR        
  ISNULL(DST.[SpousePlanName_c],  '' ) <> ISNULL(SRC.[SpousePlanName_c],  '' ) OR        
  ISNULL(DST.[SpousePlanNumber_c],  '' ) <> ISNULL(SRC.[SpousePlanNumber_c],  '' ) OR        
  ISNULL(DST.[STAccidentalDeathDismemberment_c],  '1' ) <> ISNULL(SRC.[STAccidentalDeathDismemberment_c],  '1' ) OR        
  ISNULL(DST.[STAmendedTravelArrangements_c],  '1' ) <> ISNULL(SRC.[STAmendedTravelArrangements_c],  '1' ) OR        
  ISNULL(DST.[STArrangements_c],  '1' ) <> ISNULL(SRC.[STArrangements_c],  '1' ) OR        
  ISNULL(DST.[STAssistance_c],  '1' ) <> ISNULL(SRC.[STAssistance_c],  '1' ) OR        
  ISNULL(DST.[STBenestar_c],  '1' ) <> ISNULL(SRC.[STBenestar_c],  '1' ) OR        
  ISNULL(DST.[STClaimsDocumentAssistance_c],  '1' ) <> ISNULL(SRC.[STClaimsDocumentAssistance_c],  '1' ) OR        
  ISNULL(DST.[STCLDI_c],  '1' ) <> ISNULL(SRC.[STCLDI_c],  '1' ) OR        
  ISNULL(DST.[STCostContainmentComplaint_c],  '1' ) <> ISNULL(SRC.[STCostContainmentComplaint_c],  '1' ) OR        
  ISNULL(DST.[STCostContainmentMedicalMonitoring_c],  '1' ) <> ISNULL(SRC.[STCostContainmentMedicalMonitoring_c],  '1' ) OR        
  ISNULL(DST.[STDeathCase_c],  '1' ) <> ISNULL(SRC.[STDeathCase_c],  '1' ) OR        
  ISNULL(DST.[STDelayedLuggage_c],  '1' ) <> ISNULL(SRC.[STDelayedLuggage_c],  '1' ) OR        
  ISNULL(DST.[STDirectionalCare_c],  '1' ) <> ISNULL(SRC.[STDirectionalCare_c],  '1' ) OR        
  ISNULL(DST.[STDuringTravel_c],  '1' ) <> ISNULL(SRC.[STDuringTravel_c],  '1' ) OR        
  ISNULL(DST.[STEmergencyCashTransfer_c],  '1' ) <> ISNULL(SRC.[STEmergencyCashTransfer_c],  '1' ) OR        
  ISNULL(DST.[STEntertainment_c],  '1' ) <> ISNULL(SRC.[STEntertainment_c],  '1' ) OR        
  ISNULL(DST.[STEvacuation_c],  '1' ) <> ISNULL(SRC.[STEvacuation_c],  '1' ) OR        
  ISNULL(DST.[STEventManagement_c],  '1' ) <> ISNULL(SRC.[STEventManagement_c],  '1' ) OR        
  ISNULL(DST.[STExtendedWarranty_c],  '1' ) <> ISNULL(SRC.[STExtendedWarranty_c],  '1' ) OR        
  ISNULL(DST.[STFlight_c],  '1' ) <> ISNULL(SRC.[STFlight_c],  '1' ) OR        
  ISNULL(DST.[STGiftFloralBaskets_c],  '1' ) <> ISNULL(SRC.[STGiftFloralBaskets_c],  '1' ) OR        
  ISNULL(DST.[STGolf_c],  '1' ) <> ISNULL(SRC.[STGolf_c],  '1' ) OR        
  ISNULL(DST.[STHireVehicleExcess_c],  '1' ) <> ISNULL(SRC.[STHireVehicleExcess_c],  '1' ) OR        
  ISNULL(DST.[STHotel_c],  '1' ) <> ISNULL(SRC.[STHotel_c],  '1' ) OR        
  ISNULL(DST.[STIllness_c],  '1' ) <> ISNULL(SRC.[STIllness_c], '1' ) OR        
  ISNULL(DST.[STInbound_c],  '1' ) <> ISNULL(SRC.[STInbound_c],  '1' ) OR        
  ISNULL(DST.[STInformationDuringTrip_c],  '1' ) <> ISNULL(SRC.[STInformationDuringTrip_c],  '1' ) OR        
  ISNULL(DST.[STInjury_c],  '1' ) <> ISNULL(SRC.[STInjury_c],  '1' ) OR        
  ISNULL(DST.[STInPatient_c],  '1' ) <> ISNULL(SRC.[STInPatient_c],  '1' ) OR        
  ISNULL(DST.[STInternetSearchforItemAccessory_c],  '1' ) <> ISNULL(SRC.[STInternetSearchforItemAccessory_c],  '1' ) OR        
  ISNULL(DST.[STLostStolenLuggage_c],  '1' ) <> ISNULL(SRC.[STLostStolenLuggage_c],  '1' ) OR        
  ISNULL(DST.[STLostStolenTravelDocuments_c],  '1' ) <> ISNULL(SRC.[STLostStolenTravelDocuments_c],  '1' ) OR        
  ISNULL(DST.[STMedicalMonitoring_c],  '1' ) <> ISNULL(SRC.[STMedicalMonitoring_c],  '1' ) OR        
  ISNULL(DST.[STMedicationPurchaseDelivery_c],  '1' ) <> ISNULL(SRC.[STMedicationPurchaseDelivery_c],  '1' ) OR        
  ISNULL(DST.[STMessageCentreService_c],  '1' ) <> ISNULL(SRC.[STMessageCentreService_c],  '1' ) OR        
  ISNULL(DST.[STNotification_c],  '1' ) <> ISNULL(SRC.[STNotification_c],  '1' ) OR        
  ISNULL(DST.[STOther_c],  '1' ) <> ISNULL(SRC.[STOther_c],  '1' ) OR        
  ISNULL(DST.[STOutPatient_c],  '1' ) <> ISNULL(SRC.[STOutPatient_c],  '1' ) OR        
  ISNULL(DST.[STPrescriptionReplacements_c],  '1' ) <> ISNULL(SRC.[STPrescriptionReplacements_c],  '1' ) OR        
  ISNULL(DST.[STPreTravel_c],  '1' ) <> ISNULL(SRC.[STPreTravel_c],  '1' ) OR        
  ISNULL(DST.[STPreTripInformationMedical_c],  '1' ) <> ISNULL(SRC.[STPreTripInformationMedical_c],  '1' ) OR        
  ISNULL(DST.[STPreTripInformationSecurity_c],  '1' ) <> ISNULL(SRC.[STPreTripInformationSecurity_c],  '1' ) OR        
  ISNULL(DST.[STPriceProtection_c],  '1' ) <> ISNULL(SRC.[STPriceProtection_c],  '1' ) OR        
  ISNULL(DST.[STProductComplaint_c],  '1' ) <> ISNULL(SRC.[STProductComplaint_c],  '1' ) OR        
  ISNULL(DST.[STProviderQualityComplaint_c],  '1' ) <> ISNULL(SRC.[STProviderQualityComplaint_c],  '1' ) OR        
  ISNULL(DST.[STPurchaseAssurance_c],  '1' ) <> ISNULL(SRC.[STPurchaseAssurance_c],  '1' ) OR        
  ISNULL(DST.[STRepatriation_c],  '1' ) <> ISNULL(SRC.[STRepatriation_c],  '1' ) OR        
  ISNULL(DST.[STReplacementOfLostStolenDocuments_c],  '1' ) <> ISNULL(SRC.[STReplacementOfLostStolenDocuments_c],  '1' ) OR        
  ISNULL(DST.[STReservationBooking_c],  '1' ) <> ISNULL(SRC.[STReservationBooking_c],  '1' ) OR        
  ISNULL(DST.[STRestaurantReservation_c],  '1' ) <> ISNULL(SRC.[STRestaurantReservation_c],  '1' ) OR        
  ISNULL(DST.[STRoadSideHomeAssistance_c],  '1' ) <> ISNULL(SRC.[STRoadSideHomeAssistance_c],  '1' ) OR        
  ISNULL(DST.[STSecurityIncident_c],  '1' ) <> ISNULL(SRC.[STSecurityIncident_c],  '1' ) OR        
  ISNULL(DST.[STServiceOtherComplaint_c],  '1' ) <> ISNULL(SRC.[STServiceOtherComplaint_c],  '1' ) OR        
  ISNULL(DST.[STServiceWTPComplaint_c],  '1' ) <> ISNULL(SRC.[STServiceWTPComplaint_c],  '1' ) OR        
  ISNULL(DST.[STShoppingHealthClubs_c],  '1' ) <> ISNULL(SRC.[STShoppingHealthClubs_c],  '1' ) OR        
  ISNULL(DST.[STTeleMedicine_c],  '1' ) <> ISNULL(SRC.[STTeleMedicine_c],  '1' ) OR        
  ISNULL(DST.[STTravelAssistance_c],  '1' ) <> ISNULL(SRC.[STTravelAssistance_c],  '1' ) OR        
  ISNULL(DST.[STTravelDelay_c],  '1' ) <> ISNULL(SRC.[STTravelDelay_c],  '1' ) OR        
  ISNULL(DST.[STTripCancellation_c],  '1' ) <> ISNULL(SRC.[STTripCancellation_c],  '1' ) OR        
  ISNULL(DST.[STTripInterruptionCurtailment_c],  '1' ) <> ISNULL(SRC.[STTripInterruptionCurtailment_c],  '1' ) OR        
  ISNULL(DST.[STVisaExtension_c],  '1' ) <> ISNULL(SRC.[STVisaExtension_c],  '1' ) OR        
  ISNULL(DST.[SubmissionDate_c],  '1900-01-01' ) <> ISNULL(SRC.[SubmissionDate_c],  '1900-01-01' ) OR        
  ISNULL(DST.[SubTypeInbound_c],  '' ) <> ISNULL(SRC.[SubTypeInbound_c],  '' ) OR        
  ISNULL(DST.[Supervision_c],  '1' ) <> ISNULL(SRC.[Supervision_c],  '1' ) OR        
  ISNULL(DST.[Symptoms_c],  '' ) <> ISNULL(SRC.[Symptoms_c],  '' ) OR        
  ISNULL(DST.[TaskDueDateTime_c],  '1900-01-01' ) <> ISNULL(SRC.[TaskDueDateTime_c],  '1900-01-01' ) OR        
  ISNULL(DST.[TaskDueDate_c],  '1900-01-01' ) <> ISNULL(SRC.[TaskDueDate_c],  '1900-01-01' ) OR        
  ISNULL(DST.[TemplateGroupName_c],  '' ) <> ISNULL(SRC.[TemplateGroupName_c],  '' ) OR        
  ISNULL(DST.[ThirdPartyLiability_c],  '' ) <> ISNULL(SRC.[ThirdPartyLiability_c],  '' ) OR        
  ISNULL(DST.[TimeTakenforDecision_c],  '' ) <> ISNULL(SRC.[TimeTakenforDecision_c],  '' ) OR        
  ISNULL(DST.[TodaysDate_c],  '1900-01-01' ) <> ISNULL(SRC.[TodaysDate_c],  '1900-01-01' ) OR        
  ISNULL(DST.[TotalClaimPaymentsReservedandPaid_c],  0 ) <> ISNULL(SRC.[TotalClaimPaymentsReservedandPaid_c],  0 ) OR        
  ISNULL(DST.[TotalDiagnosis_c],  0 ) <> ISNULL(SRC.[TotalDiagnosis_c],  0 ) OR        
  ISNULL(DST.[TotalEstimate_c],  0 ) <> ISNULL(SRC.[TotalEstimate_c],  0 ) OR        
  ISNULL(DST.[TotalPayments_c],  0 ) <> ISNULL(SRC.[TotalPayments_c],  0 ) OR        
  ISNULL(DST.[TravelerAddress_c],  '' ) <> ISNULL(SRC.[TravelerAddress_c],  '' ) OR        
  ISNULL(DST.[TravelerBirthdate_c],  '1900-01-01' ) <> ISNULL(SRC.[TravelerBirthdate_c],  '1900-01-01' ) OR        
  ISNULL(DST.[TravelerDeathDate_c],  '1900-01-01' ) <> ISNULL(SRC.[TravelerDeathDate_c],  '1900-01-01' ) OR        
  ISNULL(DST.[TravelerDefaulter_c],  '' ) <> ISNULL(SRC.[TravelerDefaulter_c],  '' ) OR        
  ISNULL(DST.[TravelerEmail_c],  '' ) <> ISNULL(SRC.[TravelerEmail_c],  '' ) OR        
  ISNULL(DST.[TravelerFirstName_c],  '' ) <> ISNULL(SRC.[TravelerFirstName_c],  '' ) OR        
  ISNULL(DST.[TravelerFlag_c],  '' ) <> ISNULL(SRC.[TravelerFlag_c],  '' ) OR        
  ISNULL(DST.[TravelerGender_c],  '' ) <> ISNULL(SRC.[TravelerGender_c],  '' ) OR        
  ISNULL(DST.[TravelerLanguage_c],  '' ) <> ISNULL(SRC.[TravelerLanguage_c],  '' ) OR        
  ISNULL(DST.[TravelerName1_c],  '' ) <> ISNULL(SRC.[TravelerName1_c],  '' ) OR        
  ISNULL(DST.[TravelerName_c],  '' ) <> ISNULL(SRC.[TravelerName_c],  '' ) OR        
  ISNULL(DST.[TravelerPhone_c],  '' ) <> ISNULL(SRC.[TravelerPhone_c],  '' ) OR        
  ISNULL(DST.[TravelerPotentialIssue_c],  '1' ) <> ISNULL(SRC.[TravelerPotentialIssue_c],  '1' ) OR        
  ISNULL(DST.[TravellerDateofBirth_c],  '1900-01-01' ) <> ISNULL(SRC.[TravellerDateofBirth_c],  '1900-01-01' ) OR        
  ISNULL(DST.[TravellerName_c],  '' ) <> ISNULL(SRC.[TravellerName_c],  '' ) OR        
  ISNULL(DST.[TreatingTeamApproval_c],  '' ) <> ISNULL(SRC.[TreatingTeamApproval_c],  '' ) OR        
  ISNULL(DST.[TripPurchaseDate_c],  '1900-01-01' ) <> ISNULL(SRC.[TripPurchaseDate_c],  '1900-01-01' ) OR        
  ISNULL(DST.[Trip_End_Date_c],  '1900-01-01' ) <> ISNULL(SRC.[Trip_End_Date_c], '1900-01-01' ) OR        
  ISNULL(DST.[Trip_Length_c],  0 ) <> ISNULL(SRC.[Trip_Length_c],  0 ) OR        
  ISNULL(DST.[Trip_Start_Date_c],  '1900-01-01' ) <> ISNULL(SRC.[Trip_Start_Date_c],  '1900-01-01' ) OR        
  ISNULL(DST.[UnderwriterPortalLink_c],  '' ) <> ISNULL(SRC.[UnderwriterPortalLink_c],  '' ) OR        
  ISNULL(DST.[UnderwriterThresholdReached_c],  '1' ) <> ISNULL(SRC.[UnderwriterThresholdReached_c],  '1' ) OR        
  ISNULL(DST.[UnreadEmail_c],  '1' ) <> ISNULL(SRC.[UnreadEmail_c],  '1' ) OR        
  ISNULL(DST.[Unread_c],  '1' ) <> ISNULL(SRC.[Unread_c],  '1' ) OR        
  ISNULL(DST.[UpdatedCostToDates_c],  0 ) <> ISNULL(SRC.[UpdatedCostToDates_c],  0 ) OR        
  ISNULL(DST.[UrgentAssistance_c],  '' ) <> ISNULL(SRC.[UrgentAssistance_c],  '' ) OR        
  ISNULL(DST.[UWApprovalDetails_c],  '' ) <> ISNULL(SRC.[UWApprovalDetails_c],  '' ) OR        
  ISNULL(DST.[UWApprovalRequiredFields_c],  '' ) <> ISNULL(SRC.[UWApprovalRequiredFields_c],  '' ) OR        
  ISNULL(DST.[UWContact_c],  '' ) <> ISNULL(SRC.[UWContact_c],  '' ) OR        
  ISNULL(DST.[VulnerableCustomer_c],  '1' ) <> ISNULL(SRC.[VulnerableCustomer_c],  '1' ) OR        
  ISNULL(DST.[WhatKindofvehicle_c],  '' ) <> ISNULL(SRC.[WhatKindofvehicle_c],  '' ) OR        
  ISNULL(DST.[WhoInitialTreatmentWasSoughtFrom_c],  '' ) <> ISNULL(SRC.[WhoInitialTreatmentWasSoughtFrom_c],  '' ) OR        
  ISNULL(DST.[WorkersComp_c],  '' ) <> ISNULL(SRC.[WorkersComp_c],  '' ) OR        
  ISNULL(DST.[ZurichUKChannel_c],  '' ) <> ISNULL(SRC.[ZurichUKChannel_c],  '' ) OR        
  ISNULL(DST.[HandoverSummary_c],  '' ) <> ISNULL(SRC.[HandoverSummary_c],  '' ) OR        
  ISNULL(DST.[CreatedDateQLD],  '1900-01-01' ) <> ISNULL(SRC.[CreatedDateQLD],  '1900-01-01' ) OR        
  ISNULL(DST.[ClosedDateQLD], '1900-01-01' ) <> ISNULL(SRC.[ClosedDateQLD], '1900-01-01' ) OR        
  ISNULL(DST.[CaseFeeTypeOverride_c],  '' ) <> ISNULL(SRC.[CaseFeeTypeOverride_c],  '' ) OR      
  ISNULL(DST.[First_Closed_Date_c],  '1900-01-01' ) <> ISNULL(SRC.[First_Closed_Date_c],  '1900-01-01' )      
 ) THEN         
 UPDATE SET        
  DST.[IsDeleted] = SRC.[IsDeleted],        
  DST.[Currency_ISOCode] = SRC.[Currency_ISOCode],        
  DST.[CreatedById] = SRC.[CreatedById],        
  DST.[CreatedDate] = SRC.[CreatedDate],        
  DST.[LastModifiedDate] = SRC.[LastModifiedDate],        
  DST.[LastModifiedById] = SRC.[LastModifiedById],        
  DST.[LastReferencedDate] = SRC.[LastReferencedDate],        
  DST.[LastViewedDate] = SRC.[LastViewedDate],        
  DST.[SystemModstamp] = SRC.[SystemModstamp],        
  DST.[RecordTypeId] = SRC.[RecordTypeId],        
  DST.[RecordType_DeveloperName] = SRC.[RecordType_DeveloperName],        
  DST.[AccountId] = SRC.[AccountId],        
  DST.[CaseNumber] = SRC.[CaseNumber],        
  DST.[ClosedDate] = SRC.[ClosedDate],        
  DST.[ContactId] = SRC.[ContactId],        
  DST.[Subject] = SRC.[Subject],        
  DST.[Description] = SRC.[Description],        
DST.[IsClosed] = SRC.[IsClosed],        
  DST.[IsClosedOnCreate] = SRC.[IsClosedOnCreate],        
  DST.[IsEscalated] = SRC.[IsEscalated],        
  DST.[Language] = SRC.[Language],        
  DST.[MasterRecordId] = SRC.[MasterRecordId],        
  DST.[Origin] = SRC.[Origin],        
  DST.[OwnerId] = SRC.[OwnerId],        
  DST.[ParentId] = SRC.[ParentId],        
  DST.[Priority] = SRC.[Priority],        
  DST.[Reason] = SRC.[Reason],        
  DST.[Status] = SRC.[Status],        
  DST.[Type] = SRC.[Type],        
  DST.[TimeZone_c] = SRC.[TimeZone_c],        
  DST.[SubType_c] = SRC.[SubType_c],        
  DST.[CurrentState_c] = SRC.[CurrentState_c],        
  DST.[CurrentCountry_c] = SRC.[CurrentCountry_c],        
  DST.[CurrentStreet_c] = SRC.[CurrentStreet_c],        
  DST.[CurrentCity_c] = SRC.[CurrentCity_c],        
  DST.[CurrentPostalCode_c] = SRC.[CurrentPostalCode_c],        
  DST.[IncidentCity_c] = SRC.[IncidentCity_c],        
  DST.[IncidentCountry_c] = SRC.[IncidentCountry_c],        
  DST.[IncidentState_c] = SRC.[IncidentState_c],        
  DST.[IncidentStreet_c] = SRC.[IncidentStreet_c],        
  DST.[IncidentPostalCode_c] = SRC.[IncidentPostalCode_c],        
  DST.[RiskRating_c] = SRC.[RiskRating_c],        
  DST.[RiskReason_c] = SRC.[RiskReason_c],        
  DST.[ProgramType_c] = SRC.[ProgramType_c],        
  DST.[ClaimNumber_c] = SRC.[ClaimNumber_c],        
  DST.[Underwriter_c] = SRC.[Underwriter_c],        
  DST.[SourceId] = SRC.[SourceId],        
  DST.[SuppliedCompany] = SRC.[SuppliedCompany],        
  DST.[SuppliedEmail] = SRC.[SuppliedEmail],        
  DST.[SuppliedName] = SRC.[SuppliedName],        
  DST.[SuppliedPhone] = SRC.[SuppliedPhone],        
  DST.[ActionPlanCreated_c] = SRC.[ActionPlanCreated_c],        
  DST.[AmountToCollect_c] = SRC.[AmountToCollect_c],        
  DST.[ApprovalDateTime_c] = SRC.[ApprovalDateTime_c],        
  DST.[ApprovalSoughtDetails_c] = SRC.[ApprovalSoughtDetails_c],        
  DST.[Assistance_Team_c] = SRC.[Assistance_Team_c],        
  DST.[AssistCasesCount_c] = SRC.[AssistCasesCount_c],        
  DST.[AvoidedLoss_c] = SRC.[AvoidedLoss_c],        
  DST.[BinNumberPortal_c] = SRC.[BinNumberPortal_c],        
  DST.[BINNumber_c] = SRC.[BINNumber_c],        
  DST.[Buffer_c] = SRC.[Buffer_c],        
  DST.[BypassStatusChangeValidation_c] = SRC.[BypassStatusChangeValidation_c],        
  DST.[CallBackCustomerTaskCreated_c] = SRC.[CallBackCustomerTaskCreated_c],        
  DST.[CarRentalLicensePlate_c] = SRC.[CarRentalLicensePlate_c],        
  DST.[Carrentalpickupdate_c] = SRC.[Carrentalpickupdate_c],        
  DST.[Carrentalreturndate_c] = SRC.[Carrentalreturndate_c],        
  DST.[CarRentalVIN_c] = SRC.[CarRentalVIN_c],        
  DST.[CaseAge_c] = SRC.[CaseAge_c],        
  DST.[CaseComment_c] = SRC.[CaseComment_c],        
  DST.[CaseCreatedDate_c] = SRC.[CaseCreatedDate_c],        
  DST.[CaseDecision_c] = SRC.[CaseDecision_c],        
  DST.[CaseFeeWaived_c] = SRC.[CaseFeeWaived_c],        
  DST.[CaseIndicatorFlag_c] = SRC.[CaseIndicatorFlag_c],        
  DST.[CaseNotProgressedSinceDays_c] = SRC.[CaseNotProgressedSinceDays_c],        
  DST.[CaseOwnerName_c] = SRC.[CaseOwnerName_c],        
  DST.[CaseQuestionnaire_c] = SRC.[CaseQuestionnaire_c],        
  DST.[CaseType_c] = SRC.[CaseType_c],        
  DST.[Case_Status_c] = SRC.[Case_Status_c],        
  DST.[CashTransfer_c] = SRC.[CashTransfer_c],        
  DST.[CategoryRating_c] = SRC.[CategoryRating_c],        
  DST.[CCEligible_c] = SRC.[CCEligible_c],        
  DST.[CCProvider_c] = SRC.[CCProvider_c],        
  DST.[ClaimsStatus_c] = SRC.[ClaimsStatus_c],        
  DST.[ClaimStatus_c] = SRC.[ClaimStatus_c],        
  DST.[ClientOrganization_c] = SRC.[ClientOrganization_c],        
  DST.[ComplaintCategory_c] = SRC.[ComplaintCategory_c],        
  DST.[ConsentReceived_c] = SRC.[ConsentReceived_c],        
  DST.[Consent_Flag_c] = SRC.[Consent_Flag_c],        
  DST.[ContactAge_c] = SRC.[ContactAge_c],        
  DST.[ContactBirthDate_c] = SRC.[ContactBirthDate_c],        
  DST.[ContactIntakeFields_c] = SRC.[ContactIntakeFields_c],        
  DST.[CorporateAccount_c] = SRC.[CorporateAccount_c],        
  DST.[CreatingThisCaseForSelf_c] = SRC.[CreatingThisCaseForSelf_c],        
  DST.[CurrentDiagnosis_c] = SRC.[CurrentDiagnosis_c],        
  DST.[CurrentLocationTime_c] = SRC.[CurrentLocationTime_c],        
  DST.[CurrentlyTravelling_c] = SRC.[CurrentlyTravelling_c],        
  DST.[CurrentTime_c] = SRC.[CurrentTime_c],        
  DST.[CustomerContactPermitted_c] = SRC.[CustomerContactPermitted_c],        
  DST.[CustomerCurrentCountry_c] = SRC.[CustomerCurrentCountry_c],        
  DST.[CustomerCurrentState_c] = SRC.[CustomerCurrentState_c],        
  DST.[DateofTreatmentInitialSought_c] = SRC.[DateofTreatmentInitialSought_c],        
  DST.[DepartureDate_c] = SRC.[DepartureDate_c],        
  DST.[DesiredOutcome_c] = SRC.[DesiredOutcome_c],        
  DST.[DestinationCity_c] = SRC.[DestinationCity_c],        
  DST.[DestinationCountry_c] = SRC.[DestinationCountry_c],        
  DST.[DestinationState_c] = SRC.[DestinationState_c],        
  DST.[DirectionalCare_c] = SRC.[DirectionalCare_c],        
  DST.[Dissatisfied_c] = SRC.[Dissatisfied_c],        
  DST.[DueDate_c] = SRC.[DueDate_c],        
  DST.[EMCDetails_c] = SRC.[EMCDetails_c],        
  DST.[EMCReview_c] = SRC.[EMCReview_c],        
  DST.[EmployerGroup_c] = SRC.[EmployerGroup_c],        
  DST.[EmployerName_c] = SRC.[EmployerName_c],        
  DST.[EscalationEmail_c] = SRC.[EscalationEmail_c],        
  DST.[EscalationStatus_c] = SRC.[EscalationStatus_c],        
  DST.[Estoppel_c] = SRC.[Estoppel_c],        
  DST.[ExcessPaid_c] = SRC.[ExcessPaid_c],        
  DST.[ExternalClaimReference_c] = SRC.[ExternalClaimReference_c],        
  DST.[FeedbackAbout_c] = SRC.[FeedbackAbout_c],        
  DST.[FeedbackType_c] = SRC.[FeedbackType_c],        
  DST.[FinalAmount_c] = SRC.[FinalAmount_c],        
  DST.[FitToFlyDate_c] = SRC.[FitToFlyDate_c],        
  DST.[FitToTravelDate_c] = SRC.[FitToTravelDate_c],        
  DST.[From_c] = SRC.[From_c],        
  DST.[GCNLink_c] = SRC.[GCNLink_c],        
  DST.[GHIP_c] = SRC.[GHIP_c],        
  DST.[Handover_c] = SRC.[Handover_c],        
  DST.[HastheCustomerSoughtMedicalAdvise_c] = SRC.[HastheCustomerSoughtMedicalAdvise_c],        
  DST.[ICDDescription_c] = SRC.[ICDDescription_c],        
  DST.[IncidentDate_c] = SRC.[IncidentDate_c],        
  DST.[IncidentLocation_c] = SRC.[IncidentLocation_c],        
  DST.[IncidentSummary_c] = SRC.[IncidentSummary_c],        
  DST.[IntakeQuestionnaire_c] = SRC.[IntakeQuestionnaire_c],        
  DST.[IntakeRequiredFieldStandard_c] = SRC.[IntakeRequiredFieldStandard_c],        
  DST.[IntakeRequiredFields_c] = SRC.[IntakeRequiredFields_c],        
  DST.[InternalClaim_c] = SRC.[InternalClaim_c],        
  DST.[InvestigationOutcome_c] = SRC.[InvestigationOutcome_c],        
  DST.[InvestigationReason_c] = SRC.[InvestigationReason_c],        
  DST.[Investigation_c] = SRC.[Investigation_c],        
  DST.[ItemPurchaseDate_c] = SRC.[ItemPurchaseDate_c],        
  DST.[KnowledgeSearchKeywords_c] = SRC.[KnowledgeSearchKeywords_c],        
  DST.[LargeLoss_c] = SRC.[LargeLoss_c],        
  DST.[LastCommunicationDateTime_c] = SRC.[LastCommunicationDateTime_c],        
  DST.[LastStatusModifiedDate_c] = SRC.[LastStatusModifiedDate_c],        
  DST.[MediaPartnerEmail_c] = SRC.[MediaPartnerEmail_c],        
  DST.[MedicalConsultantRecommendation_c] = SRC.[MedicalConsultantRecommendation_c],        
  DST.[MedicalSought_c] = SRC.[MedicalSought_c],        
  DST.[MedicalSummary_c] = SRC.[MedicalSummary_c],        
  DST.[MembershipNumber_c] = SRC.[MembershipNumber_c],        
  DST.[MethodofTravel_c] = SRC.[MethodofTravel_c],        
  DST.[NumberofTeleAppointmentsperCase_c] = SRC.[NumberofTeleAppointmentsperCase_c],        
  DST.[NumberOfTravellingCompanions_c] = SRC.[NumberOfTravellingCompanions_c],        
  DST.[OtherReasonForDissatisfaction_c] = SRC.[OtherReasonForDissatisfaction_c],        
  DST.[PlanNumber_c] = SRC.[PlanNumber_c],        
  DST.[PlanType_c] = SRC.[PlanType_c],        
  DST.[PolicyCertificatePlanNumber_c] = SRC.[PolicyCertificatePlanNumber_c],        
  DST.[PolicyCountry_c] = SRC.[PolicyCountry_c],        
  DST.[PolicyEndDate_c] = SRC.[PolicyEndDate_c],        
  DST.[PolicyMember_c] = SRC.[PolicyMember_c],        
  DST.[PolicyNumber1_c] = SRC.[PolicyNumber1_c],        
  DST.[PolicyNumber__c] = SRC.[PolicyNumber__c],        
  DST.[PolicyStartDate_c] = SRC.[PolicyStartDate_c],        
  DST.[PolicyType_c] = SRC.[PolicyType_c],        
  DST.[Policy_End_Date_c] = SRC.[Policy_End_Date_c],        
  DST.[Policy_Number_c] = SRC.[Policy_Number_c],        
  DST.[Policy_Start_Date_c] = SRC.[Policy_Start_Date_c],        
  DST.[Policy_c] = SRC.[Policy_c],        
  DST.[PortalCaseScreenNo_c] = SRC.[PortalCaseScreenNo_c],        
  DST.[PotentialRecovery_c] = SRC.[PotentialRecovery_c],        
  DST.[PreferredContactMethod_c] = SRC.[PreferredContactMethod_c],        
  DST.[PrimaryDiagnosisCode_c] = SRC.[PrimaryDiagnosisCode_c],        
  DST.[PrimaryDiagnosis_c] = SRC.[PrimaryDiagnosis_c],        
  DST.[PrivacyStatement_c] = SRC.[PrivacyStatement_c],        
  DST.[PrivateCase_c] = SRC.[PrivateCase_c],        
  DST.[Private_c] = SRC.[Private_c],        
  DST.[ProviderNameComplaint_c] = SRC.[ProviderNameComplaint_c],        
  DST.[ProviderName_c] = SRC.[ProviderName_c],        
  DST.[Purpose_c] = SRC.[Purpose_c],        
  DST.[QANotes_c] = SRC.[QANotes_c],        
  DST.[ReasonForComplaint_c] = SRC.[ReasonForComplaint_c],        
  DST.[ReasonForDissatisfaction_c] = SRC.[ReasonForDissatisfaction_c],        
  DST.[ReasonforMonitoring_c] = SRC.[ReasonforMonitoring_c],        
  DST.[ReceivedDate_c] = SRC.[ReceivedDate_c],        
  DST.[ReciprocalHeathcareAgreements_c] = SRC.[ReciprocalHeathcareAgreements_c],        
  DST.[RedactionDateTime_c] = SRC.[RedactionDateTime_c],        
  DST.[RentalAgencyDetails_c] = SRC.[RentalAgencyDetails_c],        
  DST.[ReopenedDateTime_c] = SRC.[ReopenedDateTime_c],        
  DST.[ResolutionPlan_c] = SRC.[ResolutionPlan_c],        
  DST.[RespondCaseId_c] = SRC.[RespondCaseId_c],        
  DST.[RespondCaseRef_c] = SRC.[RespondCaseRef_c],        
  DST.[ResponsibleBusinessArea_c] = SRC.[ResponsibleBusinessArea_c],        
  DST.[ReturnDate_c] = SRC.[ReturnDate_c],        
  DST.[ReviewReason_c] = SRC.[ReviewReason_c],        
  DST.[ReimbursedAmount_c] = SRC.[ReimbursedAmount_c],        
  DST.[Sanctioned_c] = SRC.[Sanctioned_c],        
  DST.[SecondaryRiskReason_c] = SRC.[SecondaryRiskReason_c],        
  DST.[SecurityEvent_c] = SRC.[SecurityEvent_c],        
  DST.[Sensitive_c] = SRC.[Sensitive_c],        
  DST.[SpousePlanName_c] = SRC.[SpousePlanName_c],        
  DST.[SpousePlanNumber_c] = SRC.[SpousePlanNumber_c],        
  DST.[STAccidentalDeathDismemberment_c] = SRC.[STAccidentalDeathDismemberment_c],        
  DST.[STAmendedTravelArrangements_c] = SRC.[STAmendedTravelArrangements_c],        
  DST.[STArrangements_c] = SRC.[STArrangements_c],        
  DST.[STAssistance_c] = SRC.[STAssistance_c],        
  DST.[STBenestar_c] = SRC.[STBenestar_c],        
  DST.[STClaimsDocumentAssistance_c] = SRC.[STClaimsDocumentAssistance_c],        
  DST.[STCLDI_c] = SRC.[STCLDI_c],        
  DST.[STCostContainmentComplaint_c] = SRC.[STCostContainmentComplaint_c],        
  DST.[STCostContainmentMedicalMonitoring_c] = SRC.[STCostContainmentMedicalMonitoring_c],        
  DST.[STDeathCase_c] = SRC.[STDeathCase_c],        
  DST.[STDelayedLuggage_c] = SRC.[STDelayedLuggage_c],        
  DST.[STDirectionalCare_c] = SRC.[STDirectionalCare_c],        
  DST.[STDuringTravel_c] = SRC.[STDuringTravel_c],        
  DST.[STEmergencyCashTransfer_c] = SRC.[STEmergencyCashTransfer_c],        
  DST.[STEntertainment_c] = SRC.[STEntertainment_c],        
  DST.[STEvacuation_c] = SRC.[STEvacuation_c],        
  DST.[STEventManagement_c] = SRC.[STEventManagement_c],        
  DST.[STExtendedWarranty_c] = SRC.[STExtendedWarranty_c],        
  DST.[STFlight_c] = SRC.[STFlight_c],        
  DST.[STGiftFloralBaskets_c] = SRC.[STGiftFloralBaskets_c],        
  DST.[STGolf_c] = SRC.[STGolf_c],        
  DST.[STHireVehicleExcess_c] = SRC.[STHireVehicleExcess_c],        
  DST.[STHotel_c] = SRC.[STHotel_c],        
  DST.[STIllness_c] = SRC.[STIllness_c],        
  DST.[STInbound_c] = SRC.[STInbound_c],        
  DST.[STInformationDuringTrip_c] = SRC.[STInformationDuringTrip_c],        
  DST.[STInjury_c] = SRC.[STInjury_c],        
  DST.[STInPatient_c] = SRC.[STInPatient_c],        
  DST.[STInternetSearchforItemAccessory_c] = SRC.[STInternetSearchforItemAccessory_c],        
  DST.[STLostStolenLuggage_c] = SRC.[STLostStolenLuggage_c],        
  DST.[STLostStolenTravelDocuments_c] = SRC.[STLostStolenTravelDocuments_c],        
  DST.[STMedicalMonitoring_c] = SRC.[STMedicalMonitoring_c],        
  DST.[STMedicationPurchaseDelivery_c] = SRC.[STMedicationPurchaseDelivery_c],        
  DST.[STMessageCentreService_c] = SRC.[STMessageCentreService_c],        
  DST.[STNotification_c] = SRC.[STNotification_c],        
  DST.[STOther_c] = SRC.[STOther_c],        
  DST.[STOutPatient_c] = SRC.[STOutPatient_c],        
  DST.[STPrescriptionReplacements_c] = SRC.[STPrescriptionReplacements_c],        
  DST.[STPreTravel_c] = SRC.[STPreTravel_c],        
  DST.[STPreTripInformationMedical_c] = SRC.[STPreTripInformationMedical_c],        
  DST.[STPreTripInformationSecurity_c] = SRC.[STPreTripInformationSecurity_c],        
  DST.[STPriceProtection_c] = SRC.[STPriceProtection_c],        
  DST.[STProductComplaint_c] = SRC.[STProductComplaint_c],        
  DST.[STProviderQualityComplaint_c] = SRC.[STProviderQualityComplaint_c],        
  DST.[STPurchaseAssurance_c] = SRC.[STPurchaseAssurance_c],        
  DST.[STRepatriation_c] = SRC.[STRepatriation_c],        
  DST.[STReplacementOfLostStolenDocuments_c] = SRC.[STReplacementOfLostStolenDocuments_c],        
  DST.[STReservationBooking_c] = SRC.[STReservationBooking_c],        
  DST.[STRestaurantReservation_c] = SRC.[STRestaurantReservation_c],        
  DST.[STRoadSideHomeAssistance_c] = SRC.[STRoadSideHomeAssistance_c],        
  DST.[STSecurityIncident_c] = SRC.[STSecurityIncident_c],        
  DST.[STServiceOtherComplaint_c] = SRC.[STServiceOtherComplaint_c],        
  DST.[STServiceWTPComplaint_c] = SRC.[STServiceWTPComplaint_c],        
  DST.[STShoppingHealthClubs_c] = SRC.[STShoppingHealthClubs_c],        
  DST.[STTeleMedicine_c] = SRC.[STTeleMedicine_c],        
  DST.[STTravelAssistance_c] = SRC.[STTravelAssistance_c],        
  DST.[STTravelDelay_c] = SRC.[STTravelDelay_c],        
  DST.[STTripCancellation_c] = SRC.[STTripCancellation_c],        
  DST.[STTripInterruptionCurtailment_c] = SRC.[STTripInterruptionCurtailment_c],        
  DST.[STVisaExtension_c] = SRC.[STVisaExtension_c],        
  DST.[SubmissionDate_c] = SRC.[SubmissionDate_c],        
  DST.[SubTypeInbound_c] = SRC.[SubTypeInbound_c],        
  DST.[Supervision_c] = SRC.[Supervision_c],        
  DST.[Symptoms_c] = SRC.[Symptoms_c],        
  DST.[TaskDueDateTime_c] = SRC.[TaskDueDateTime_c],        
  DST.[TaskDueDate_c] = SRC.[TaskDueDate_c],        
  DST.[TemplateGroupName_c] = SRC.[TemplateGroupName_c],        
  DST.[ThirdPartyLiability_c] = SRC.[ThirdPartyLiability_c],        
  DST.[TimeTakenforDecision_c] = SRC.[TimeTakenforDecision_c],        
  DST.[TodaysDate_c] = SRC.[TodaysDate_c],        
  DST.[TotalClaimPaymentsReservedandPaid_c] = SRC.[TotalClaimPaymentsReservedandPaid_c],        
  DST.[TotalDiagnosis_c] = SRC.[TotalDiagnosis_c],        
  DST.[TotalEstimate_c] = SRC.[TotalEstimate_c],        
  DST.[TotalPayments_c] = SRC.[TotalPayments_c],        
  DST.[TravelerAddress_c] = SRC.[TravelerAddress_c],        
  DST.[TravelerBirthdate_c] = SRC.[TravelerBirthdate_c],        
  DST.[TravelerDeathDate_c] = SRC.[TravelerDeathDate_c],        
  DST.[TravelerDefaulter_c] = SRC.[TravelerDefaulter_c],        
  DST.[TravelerEmail_c] = SRC.[TravelerEmail_c],        
  DST.[TravelerFirstName_c] = SRC.[TravelerFirstName_c],        
  DST.[TravelerFlag_c] = SRC.[TravelerFlag_c],        
  DST.[TravelerGender_c] = SRC.[TravelerGender_c],        
  DST.[TravelerLanguage_c] = SRC.[TravelerLanguage_c],        
  DST.[TravelerName1_c] = SRC.[TravelerName1_c],        
  DST.[TravelerName_c] = SRC.[TravelerName_c],        
  DST.[TravelerPhone_c] = SRC.[TravelerPhone_c],        
  DST.[TravelerPotentialIssue_c] = SRC.[TravelerPotentialIssue_c],        
  DST.[TravellerDateofBirth_c] = SRC.[TravellerDateofBirth_c],        
  DST.[TravellerName_c] = SRC.[TravellerName_c],        
  DST.[TreatingTeamApproval_c] = SRC.[TreatingTeamApproval_c],        
  DST.[TripPurchaseDate_c] = SRC.[TripPurchaseDate_c],        
  DST.[Trip_End_Date_c] = SRC.[Trip_End_Date_c],        
  DST.[Trip_Length_c] = SRC.[Trip_Length_c],        
  DST.[Trip_Start_Date_c] = SRC.[Trip_Start_Date_c],        
  DST.[UnderwriterPortalLink_c] = SRC.[UnderwriterPortalLink_c],        
  DST.[UnderwriterThresholdReached_c] = SRC.[UnderwriterThresholdReached_c],        
  DST.[UnreadEmail_c] = SRC.[UnreadEmail_c],        
  DST.[Unread_c] = SRC.[Unread_c],        
  DST.[UpdatedCostToDates_c] = SRC.[UpdatedCostToDates_c],        
  DST.[UrgentAssistance_c] = SRC.[UrgentAssistance_c],        
  DST.[UWApprovalDetails_c] = SRC.[UWApprovalDetails_c],        
  DST.[UWApprovalRequiredFields_c] = SRC.[UWApprovalRequiredFields_c],        
  DST.[UWContact_c] = SRC.[UWContact_c],          DST.[VulnerableCustomer_c] = SRC.[VulnerableCustomer_c],        
  DST.[WhatKindofvehicle_c] = SRC.[WhatKindofvehicle_c],        
  DST.[WhoInitialTreatmentWasSoughtFrom_c] = SRC.[WhoInitialTreatmentWasSoughtFrom_c],        
  DST.[WorkersComp_c] = SRC.[WorkersComp_c],        
  DST.[ZurichUKChannel_c] = SRC.[ZurichUKChannel_c],        
  DST.[HandoverSummary_c] = SRC.[HandoverSummary_c],        
  DST.[CreatedDateQLD] = SRC.[CreatedDateQLD],        
  DST.[ClosedDateQLD] = SRC.[ClosedDateQLD],        
  DST.[CaseFeeTypeOverride_c] =SRC.[CaseFeeTypeOverride_c],      
  DST.[First_Closed_Date_c] =SRC.[First_Closed_Date_c];        
        
END; 
GO
