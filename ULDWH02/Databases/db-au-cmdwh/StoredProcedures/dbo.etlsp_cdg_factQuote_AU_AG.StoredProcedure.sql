USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cdg_factQuote_AU_AG]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE procedure [dbo].[etlsp_cdg_factQuote_AU_AG]        
          
as      
begin     
    
 set nocount on    
    
begin transaction      
      
    begin try      
    
  merge into [db-au-cmdwh]..cdg_factQuote_AU_AG as DST      
        using [db-au-stage]..cdg_factQuote_AU_AG as SRC      
        on (SRC.[SessionID] = DST.[SessionID])      
        -- inserting new records      
        when not matched by target then      
        insert      
        (      
            [FactQuoteID] ,    
   [SessionID] ,    
   [RegionID] ,    
   [ProductID] ,    
   [CampaignID] ,    
   [BusinessUnitID] ,    
   [DestCovermoreCountryListID] ,    
   [DestISOCountryListID] ,    
   [DestAirportsListID] ,    
   [PromoCodeListID] ,    
   [ChargedCountryID] ,    
   [QuoteTransactionDateID] ,    
   [QuoteTransactionTimeID] ,    
   [TripStartDateID] ,    
   [TripStartTimeID] ,    
   [TripEndDateID] ,    
   [TripEndTimeID] ,    
   [TotalGrossPremium] ,    
   [TotalAdjustedGrossPremium] ,    
   [TotalTravelers] ,    
   [Excess] ,    
   [IsMultiDestination] ,    
   [IsMostRecent] ,    
   [NumAdults] ,    
   [NumChildren] ,    
   [NumInfants] ,    
   [HasCANX] ,    
   [HasWNTS] ,    
   [HasCRS] ,    
   [HasLUGG] ,    
   [HasRTCR] ,    
   [CANXCoverageAmount] ,    
   [RTCRCoverageAmount] ,    
   [MaxPolicies] ,    
   [ActualPoliciesSold] ,    
   [DepartureCountryID] ,    
   [DepartureAirportID] ,    
   [GroupTypeID] ,    
   [CurrencyID] ,    
   [QuoteSourceID] ,    
   [HasMTCL] ,    
   [HasADVACT] ,    
   [HasCANXANY] ,    
   [HasFPCAP] ,    
   [HasLUGGDOC] ,    
   [HasMTCLTWO] ,    
   [HasNEWFOROLD] ,    
   [HasSNSPRTS] ,    
   [HasSNSPRTS2] ,    
   [HasSSB] ,    
   [HasINDCOMP] ,    
   [HasINDMUGG] ,    
   [HasINDTRVINC] ,    
   [HasINDCRS] ,    
   [HasINDGOLF] ,    
   [HasINDPET] ,    
   [HasINDCCFRD] ,    
   [HasINDLAPTOP] ,    
   [HasINDTRVLN] ,    
   [HasINDMEDSUB] ,    
   [HasINDCANX] ,    
   [HasINDADSPRT] ,    
   [HasDUTY] ,    
   [PrimaryTravellerAge] ,    
   [HasADVACT2] ,    
   [HasADVACT3] ,    
   [HasSNSPRTS3] ,    
   [HasCRS2] ,    
   [HasAGECBA] ,    
   [HasELEC]     
        )      
        values      
        (      
            SRC.[FactQuoteID] ,    
   SRC.[SessionID] ,    
   SRC.[RegionID] ,    
   SRC.[ProductID] ,    
   SRC.[CampaignID] ,    
   SRC.[BusinessUnitID] ,    
   SRC.[DestCovermoreCountryListID] ,    
   SRC.[DestISOCountryListID] ,    
   SRC.[DestAirportsListID] ,    
   SRC.[PromoCodeListID] ,    
   SRC.[ChargedCountryID] ,    
   SRC.[QuoteTransactionDateID] ,    
   SRC.[QuoteTransactionTimeID] ,    
   SRC.[TripStartDateID] ,    
   SRC.[TripStartTimeID] ,    
   SRC.[TripEndDateID] ,    
   SRC.[TripEndTimeID] ,    
   SRC.[TotalGrossPremium] ,    
   SRC.[TotalAdjustedGrossPremium] ,    
   SRC.[TotalTravelers] ,    
   SRC.[Excess] ,    
   SRC.[IsMultiDestination] ,    
   SRC.[IsMostRecent] ,    
   SRC.[NumAdults] ,    
   SRC.[NumChildren] ,    
   SRC.[NumInfants] ,    
   SRC.[HasCANX] ,    
   SRC.[HasWNTS] ,    
   SRC.[HasCRS] ,    
   SRC.[HasLUGG] ,    
   SRC.[HasRTCR] ,    
   SRC.[CANXCoverageAmount] ,    
   SRC.[RTCRCoverageAmount] ,    
   SRC.[MaxPolicies] ,    
   SRC.[ActualPoliciesSold] ,    
   SRC.[DepartureCountryID] ,    
   SRC.[DepartureAirportID] ,    
   SRC.[GroupTypeID] ,    
   SRC.[CurrencyID] ,    
   SRC.[QuoteSourceID] ,    
   SRC.[HasMTCL] ,    
   SRC.[HasADVACT] ,    
   SRC.[HasCANXANY] ,    
   SRC.[HasFPCAP] ,    
   SRC.[HasLUGGDOC] ,    
   SRC.[HasMTCLTWO] ,    
   SRC.[HasNEWFOROLD] ,    
   SRC.[HasSNSPRTS] ,    
   SRC.[HasSNSPRTS2] ,    
   SRC.[HasSSB] ,    
   SRC.[HasINDCOMP] ,    
   SRC.[HasINDMUGG] ,    
   SRC.[HasINDTRVINC] ,    
   SRC.[HasINDCRS] ,    
   SRC.[HasINDGOLF] ,    
   SRC.[HasINDPET] ,    
   SRC.[HasINDCCFRD] ,    
   SRC.[HasINDLAPTOP] ,    
   SRC.[HasINDTRVLN] ,    
   SRC.[HasINDMEDSUB] ,    
   SRC.[HasINDCANX] ,    
   SRC.[HasINDADSPRT] ,    
   SRC.[HasDUTY] ,    
   SRC.[PrimaryTravellerAge] ,    
   SRC.[HasADVACT2] ,    
   SRC.[HasADVACT3] ,    
   SRC.[HasSNSPRTS3] ,    
   SRC.[HasCRS2] ,    
   SRC.[HasAGECBA] ,    
   SRC.[HasELEC]     
        )      
              
        -- update existing records      
        when matched  then      
        update      
        SET      
            DST.[FactQuoteID]=SRC.[FactQuoteID] ,    
   DST.[SessionID]=SRC.[SessionID] ,    
   DST.[RegionID]=SRC.[RegionID] ,    
   DST.[ProductID]=SRC.[ProductID] ,    
   DST.[CampaignID]=SRC.[CampaignID] ,    
   DST.[BusinessUnitID]=SRC.[BusinessUnitID] ,    
   DST.[DestCovermoreCountryListID]=SRC.[DestCovermoreCountryListID] ,    
   DST.[DestISOCountryListID]=SRC.[DestISOCountryListID] ,    
   DST.[DestAirportsListID]=SRC.[DestAirportsListID] ,    
   DST.[PromoCodeListID]=SRC.[PromoCodeListID] ,    
   DST.[ChargedCountryID]=SRC.[ChargedCountryID] ,    
   DST.[QuoteTransactionDateID]=SRC.[QuoteTransactionDateID] ,    
   DST.[QuoteTransactionTimeID]=SRC.[QuoteTransactionTimeID] ,    
   DST.[TripStartDateID]=SRC.[TripStartDateID] ,    
   DST.[TripStartTimeID]=SRC.[TripStartTimeID] ,    
   DST.[TripEndDateID]=SRC.[TripEndDateID] ,    
   DST.[TripEndTimeID]=SRC.[TripEndTimeID] ,    
   DST.[TotalGrossPremium]=SRC.[TotalGrossPremium] ,    
   DST.[TotalAdjustedGrossPremium]=SRC.[TotalAdjustedGrossPremium] ,    
   DST.[TotalTravelers]=SRC.[TotalTravelers] ,    
   DST.[Excess]=SRC.[Excess] ,    
   DST.[IsMultiDestination]=SRC.[IsMultiDestination] ,    
   DST.[IsMostRecent]=SRC.[IsMostRecent] ,    
   DST.[NumAdults]=SRC.[NumAdults] ,    
   DST.[NumChildren]=SRC.[NumChildren] ,    
   DST.[NumInfants]=SRC.[NumInfants] ,    
   DST.[HasCANX]=SRC.[HasCANX] ,    
   DST.[HasWNTS]=SRC.[HasWNTS] ,    
   DST.[HasCRS]=SRC.[HasCRS] ,    
   DST.[HasLUGG]=SRC.[HasLUGG] ,    
   DST.[HasRTCR]=SRC.[HasRTCR] ,    
   DST.[CANXCoverageAmount]=SRC.[CANXCoverageAmount] ,    
   DST.[RTCRCoverageAmount]=SRC.[RTCRCoverageAmount] ,    
   DST.[MaxPolicies]=SRC.[MaxPolicies] ,    
   DST.[ActualPoliciesSold]=SRC.[ActualPoliciesSold] ,    
   DST.[DepartureCountryID]=SRC.[DepartureCountryID] ,    
   DST.[DepartureAirportID]=SRC.[DepartureAirportID] ,    
   DST.[GroupTypeID]=SRC.[GroupTypeID] ,    
   DST.[CurrencyID]=SRC.[CurrencyID] ,    
   DST.[QuoteSourceID]=SRC.[QuoteSourceID] ,    
   DST.[HasMTCL]=SRC.[HasMTCL] ,    
   DST.[HasADVACT]=SRC.[HasADVACT] ,    
   DST.[HasCANXANY]=SRC.[HasCANXANY] ,    
   DST.[HasFPCAP]=SRC.[HasFPCAP] ,    
   DST.[HasLUGGDOC]=SRC.[HasLUGGDOC] ,    
   DST.[HasMTCLTWO]=SRC.[HasMTCLTWO] ,    
   DST.[HasNEWFOROLD]=SRC.[HasNEWFOROLD] ,    
   DST.[HasSNSPRTS]=SRC.[HasSNSPRTS] ,    
   DST.[HasSNSPRTS2]=SRC.[HasSNSPRTS2] ,    
   DST.[HasSSB]=SRC.[HasSSB] ,    
   DST.[HasINDCOMP]=SRC.[HasINDCOMP] ,    
   DST.[HasINDMUGG]=SRC.[HasINDMUGG] ,    
   DST.[HasINDTRVINC]=SRC.[HasINDTRVINC] ,    
   DST.[HasINDCRS]=SRC.[HasINDCRS] ,    
   DST.[HasINDGOLF]=SRC.[HasINDGOLF] ,    
   DST.[HasINDPET]=SRC.[HasINDPET] ,    
   DST.[HasINDCCFRD]=SRC.[HasINDCCFRD] ,    
   DST.[HasINDLAPTOP]=SRC.[HasINDLAPTOP] ,    
   DST.[HasINDTRVLN]=SRC.[HasINDTRVLN] ,    
   DST.[HasINDMEDSUB]=SRC.[HasINDMEDSUB] ,    
   DST.[HasINDCANX]=SRC.[HasINDCANX] ,    
   DST.[HasINDADSPRT]=SRC.[HasINDADSPRT] ,    
   DST.[HasDUTY]=SRC.[HasDUTY] ,    
   DST.[PrimaryTravellerAge]=SRC.[PrimaryTravellerAge] ,    
   DST.[HasADVACT2]=SRC.[HasADVACT2] ,    
   DST.[HasADVACT3]=SRC.[HasADVACT3] ,    
   DST.[HasSNSPRTS3]=SRC.[HasSNSPRTS3] ,    
   DST.[HasCRS2]=SRC.[HasCRS2] ,    
   DST.[HasAGECBA]=SRC.[HasAGECBA] ,    
   DST.[HasELEC]=SRC.[HasELEC] ;    
                  
      
    end try      
      
    begin catch      
      
        if @@trancount > 0      
            rollback transaction      
      
          
      
    end catch      
      
    if @@trancount > 0      
        commit transaction      
      
end 
GO
