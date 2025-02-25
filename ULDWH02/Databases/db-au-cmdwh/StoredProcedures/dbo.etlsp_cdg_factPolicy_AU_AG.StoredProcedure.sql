USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cdg_factPolicy_AU_AG]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cdg_factPolicy_AU_AG]        
  
as      
begin     
    
 set nocount on    
    
begin transaction      
      
    begin try      
    
  merge into [db-au-cmdwh]..cdg_factPolicy_AU_AG as DST      
        using [db-au-stage]..cdg_factPolicy_AU_AG as SRC      
        on (src.FactPolicyID = DST.FactPolicyID and src.PolicyIssuedDateID = DST.PolicyIssuedDateID)      
        -- inserting new records      
        when not matched by target then      
        insert      
        (      
            [FactPolicyID],    
   [PolicyNumber],    
   [SessionID],    
   [RegionID],    
   [ProductID],    
   [ContactID],    
   [CampaignID],    
   [BusinessUnitID],    
   [PolicyIssuedDateID],    
   [PolicyIssuedTimeID],    
   [TripStartDateID],    
   [TripStartTimeID],    
   [TripEndDateID],    
   [TripEndTimeID],    
   [DestCovermoreCountryListID],    
   [DestISOCountryListID],    
   [DestAirportsListID],    
   [PaymentTypeID],    
   [TripTypeID],    
   [ConstructID],    
   [ImpulseOfferID],    
   [ChargedCountryID],    
   [PromoCodeListID],    
   [Excess],    
   [MemberPointsAwarded],    
   [HasCANX],    
   [HasWNTS],    
   [HasCRS],    
   [HasLUGG],    
   [HasRTCR],    
   [HasEMC],    
   [IsDiscounted],    
   [TotalGrossPremium],    
   [TotalDiscountedGrossPremium],    
   [CANXCoverageAmount],    
   [RTCRCoverageAmount],    
   [PartnerTransactionID],    
   [ActualPaymentType],    
   [PaymentReferenceNumber],    
   [TripDuration],    
   [DepartureCountryID],    
   [DepartureAirportID],    
   [CurrencyID],    
   [HasMTCL],    
   [HasADVACT],    
   [HasCANXANY],    
   [HasFPCAP],    
   [HasLUGGDOC],    
   [HasMTCLTWO],    
   [HasNEWFOROLD],    
   [HasSNSPRTS],    
   [HasSNSPRTS2],    
   [HasSSB],    
   [HasINDCOMP],    
   [HasINDMUGG],    
   [HasINDTRVINC],    
   [HasINDCRS],    
   [HasINDGOLF],    
   [HasINDPET],    
   [HasINDCCFRD],    
   [HasINDLAPTOP],    
   [HasINDTRVLN],    
   [HasINDMEDSUB],    
   [HasINDCANX],    
   [HasINDADSPRT],    
   [HasDUTY],    
   [HasADVACT2],    
   [HasADVACT3],    
   [HasSNSPRTS3],    
   [HasCRS2],    
   [HasAGECBA],    
   [HasELEC]      
        )      
        values      
        (      
            SRC.[FactPolicyID],    
   SRC.[PolicyNumber],    
   SRC.[SessionID],    
   SRC.[RegionID],    
   SRC.[ProductID],    
   SRC.[ContactID],    
   SRC.[CampaignID],    
   SRC.[BusinessUnitID],    
   SRC.[PolicyIssuedDateID],    
   SRC.[PolicyIssuedTimeID],    
   SRC.[TripStartDateID],    
   SRC.[TripStartTimeID],    
   SRC.[TripEndDateID],    
   SRC.[TripEndTimeID],    
   SRC.[DestCovermoreCountryListID],    
   SRC.[DestISOCountryListID],    
   SRC.[DestAirportsListID],    
   SRC.[PaymentTypeID],    
   SRC.[TripTypeID],    
   SRC.[ConstructID],    
   SRC.[ImpulseOfferID],    
   SRC.[ChargedCountryID],    
   SRC.[PromoCodeListID],    
   SRC.[Excess],    
   SRC.[MemberPointsAwarded],    
   SRC.[HasCANX],    
   SRC.[HasWNTS],    
   SRC.[HasCRS],    
   SRC.[HasLUGG],    
   SRC.[HasRTCR],    
   SRC.[HasEMC],    
   SRC.[IsDiscounted],    
   SRC.[TotalGrossPremium],    
   SRC.[TotalDiscountedGrossPremium],    
   SRC.[CANXCoverageAmount],    
   SRC.[RTCRCoverageAmount],    
   SRC.[PartnerTransactionID],    
   SRC.[ActualPaymentType],    
   SRC.[PaymentReferenceNumber],    
   SRC.[TripDuration],    
   SRC.[DepartureCountryID],    
   SRC.[DepartureAirportID],    
   SRC.[CurrencyID],    
   SRC.[HasMTCL],    
   SRC.[HasADVACT],    
   SRC.[HasCANXANY],    
   SRC.[HasFPCAP],    
   SRC.[HasLUGGDOC],    
   SRC.[HasMTCLTWO],    
   SRC.[HasNEWFOROLD],    
   SRC.[HasSNSPRTS],    
   SRC.[HasSNSPRTS2],    
   SRC.[HasSSB],    
   SRC.[HasINDCOMP],    
   SRC.[HasINDMUGG],    
   SRC.[HasINDTRVINC],    
   SRC.[HasINDCRS],    
   SRC.[HasINDGOLF],    
   SRC.[HasINDPET],    
   SRC.[HasINDCCFRD],    
   SRC.[HasINDLAPTOP],    
   SRC.[HasINDTRVLN],    
   SRC.[HasINDMEDSUB],    
   SRC.[HasINDCANX],    
   SRC.[HasINDADSPRT],    
   SRC.[HasDUTY],    
   SRC.[HasADVACT2],    
   SRC.[HasADVACT3],    
   SRC.[HasSNSPRTS3],    
   SRC.[HasCRS2],    
   SRC.[HasAGECBA],    
   SRC.[HasELEC]     
        )      
              
        -- update existing records      
        when matched  then      
        update      
        SET      
            DST.[FactPolicyID]=SRC.[FactPolicyID],    
   DST.[PolicyNumber]=SRC.[PolicyNumber],    
   DST.[SessionID]=SRC.[SessionID],    
   DST.[RegionID]=SRC.[RegionID],    
   DST.[ProductID]=SRC.[ProductID],    
   DST.[ContactID]=SRC.[ContactID],    
   DST.[CampaignID]=SRC.[CampaignID],    
   DST.[BusinessUnitID]=SRC.[BusinessUnitID],    
   DST.[PolicyIssuedDateID]=SRC.[PolicyIssuedDateID],    
   DST.[PolicyIssuedTimeID]=SRC.[PolicyIssuedTimeID],    
   DST.[TripStartDateID]=SRC.[TripStartDateID],    
   DST.[TripStartTimeID]=SRC.[TripStartTimeID],    
   DST.[TripEndDateID]=SRC.[TripEndDateID],    
   DST.[TripEndTimeID]=SRC.[TripEndTimeID],    
   DST.[DestCovermoreCountryListID]=SRC.[DestCovermoreCountryListID],    
   DST.[DestISOCountryListID]=SRC.[DestISOCountryListID],    
   DST.[DestAirportsListID]=SRC.[DestAirportsListID],    
   DST.[PaymentTypeID]=SRC.[PaymentTypeID],    
   DST.[TripTypeID]=SRC.[TripTypeID],    
   DST.[ConstructID]=SRC.[ConstructID],    
   DST.[ImpulseOfferID]=SRC.[ImpulseOfferID],    
   DST.[ChargedCountryID]=SRC.[ChargedCountryID],    
   DST.[PromoCodeListID]=SRC.[PromoCodeListID],    
   DST.[Excess]=SRC.[Excess],    
   DST.[MemberPointsAwarded]=SRC.[MemberPointsAwarded],    
   DST.[HasCANX]=SRC.[HasCANX],    
   DST.[HasWNTS]=SRC.[HasWNTS],    
   DST.[HasCRS]=SRC.[HasCRS],    
   DST.[HasLUGG]=SRC.[HasLUGG],    
   DST.[HasRTCR]=SRC.[HasRTCR],    
   DST.[HasEMC]=SRC.[HasEMC],    
   DST.[IsDiscounted]=SRC.[IsDiscounted],    
   DST.[TotalGrossPremium]=SRC.[TotalGrossPremium],    
   DST.[TotalDiscountedGrossPremium]=SRC.[TotalDiscountedGrossPremium],    
   DST.[CANXCoverageAmount]=SRC.[CANXCoverageAmount],    
   DST.[RTCRCoverageAmount]=SRC.[RTCRCoverageAmount],    
   DST.[PartnerTransactionID]=SRC.[PartnerTransactionID],    
   DST.[ActualPaymentType]=SRC.[ActualPaymentType],    
   DST.[PaymentReferenceNumber]=SRC.[PaymentReferenceNumber],    
   DST.[TripDuration]=SRC.[TripDuration],    
   DST.[DepartureCountryID]=SRC.[DepartureCountryID],    
   DST.[DepartureAirportID]=SRC.[DepartureAirportID],    
   DST.[CurrencyID]=SRC.[CurrencyID],    
   DST.[HasMTCL]=SRC.[HasMTCL],    
   DST.[HasADVACT]=SRC.[HasADVACT],    
   DST.[HasCANXANY]=SRC.[HasCANXANY],    
   DST.[HasFPCAP]=SRC.[HasFPCAP],    
   DST.[HasLUGGDOC]=SRC.[HasLUGGDOC],    
   DST.[HasMTCLTWO]=SRC.[HasMTCLTWO],    
   DST.[HasNEWFOROLD]=SRC.[HasNEWFOROLD],    
   DST.[HasSNSPRTS]=SRC.[HasSNSPRTS],    
   DST.[HasSNSPRTS2]=SRC.[HasSNSPRTS2],    
   DST.[HasSSB]=SRC.[HasSSB],    
   DST.[HasINDCOMP]=SRC.[HasINDCOMP],    
   DST.[HasINDMUGG]=SRC.[HasINDMUGG],    
   DST.[HasINDTRVINC]=SRC.[HasINDTRVINC],    
   DST.[HasINDCRS]=SRC.[HasINDCRS],    
   DST.[HasINDGOLF]=SRC.[HasINDGOLF],    
   DST.[HasINDPET]=SRC.[HasINDPET],    
   DST.[HasINDCCFRD]=SRC.[HasINDCCFRD],    
   DST.[HasINDLAPTOP]=SRC.[HasINDLAPTOP],    
   DST.[HasINDTRVLN]=SRC.[HasINDTRVLN],    
   DST.[HasINDMEDSUB]=SRC.[HasINDMEDSUB],    
   DST.[HasINDCANX]=SRC.[HasINDCANX],    
   DST.[HasINDADSPRT]=SRC.[HasINDADSPRT],    
   DST.[HasDUTY]=SRC.[HasDUTY],    
   DST.[HasADVACT2]=SRC.[HasADVACT2],    
   DST.[HasADVACT3]=SRC.[HasADVACT3],    
   DST.[HasSNSPRTS3]=SRC.[HasSNSPRTS3],    
   DST.[HasCRS2]=SRC.[HasCRS2],    
   DST.[HasAGECBA]=SRC.[HasAGECBA],    
   DST.[HasELEC]=SRC.[HasELEC];    
                  
      
    end try      
      
    begin catch      
      
        if @@trancount > 0      
            rollback transaction      
      
          
      
    end catch      
      
    if @@trancount > 0      
        commit transaction      
      
end 
GO
