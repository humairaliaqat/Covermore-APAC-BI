USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cdg_factTraveler_AU_AG]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE procedure [dbo].[etlsp_cdg_factTraveler_AU_AG]          
    
as        
begin       
      
 set nocount on      
      
begin transaction        
        
    begin try        
      
  merge into [db-au-cmdwh]..cdg_factTraveler_AU_AG as DST        
        using [db-au-stage]..cdg_factTraveler_AU_AG as SRC        
        on (SRC.SessionID = DST.SessionID AND SRC.FactTravelerID = DST.FactTravelerID)        
        -- inserting new records        
        when not matched by target then        
        insert        
        (        
             [FactTravelerID]
            ,[SessionID]
            ,[BirthDateDimDateID]	
            ,[IsAdult]	
            ,[IsChild]	
            ,[IsInfant]	
            ,[IsPrimary]	
            ,[TreatAsAdultIndicator]	
            ,[AcceptedOfferIndicator]	
            ,[EMCAccepted]	
            ,[Age]	
            ,[FirstName]	
            ,[LastName]	
            ,[Gender]       
       )        
        values        
        (        
             [SRC].[FactTravelerID]
            ,[SRC].[SessionID]
            ,[SRC].[BirthDateDimDateID]	
            ,[SRC].[IsAdult]	
            ,[SRC].[IsChild]	
            ,[SRC].[IsInfant]	
            ,[SRC].[IsPrimary]	
            ,[SRC].[TreatAsAdultIndicator]	
            ,[SRC].[AcceptedOfferIndicator]	
            ,[SRC].[EMCAccepted]	
            ,[SRC].[Age]	
            ,[SRC].[FirstName]	
            ,[SRC].[LastName]	            
            ,[SRC].[Gender]                     
        )        
                
        -- update existing records        
        when matched  then        
        update        
        SET        
             [DST].[FactTravelerID]           =   [SRC].[FactTravelerID]           
            ,[DST].[SessionID]                =   [SRC].[SessionID]                
            ,[DST].[BirthDateDimDateID]	      =   [SRC].[BirthDateDimDateID]	      
            ,[DST].[IsAdult]	              =   [SRC].[IsAdult]	              
            ,[DST].[IsChild]	              =   [SRC].[IsChild]	              
            ,[DST].[IsInfant]	              =   [SRC].[IsInfant]	              
            ,[DST].[IsPrimary]	              =   [SRC].[IsPrimary]	              
            ,[DST].[TreatAsAdultIndicator]	  =   [SRC].[TreatAsAdultIndicator]	  
            ,[DST].[AcceptedOfferIndicator]	  =   [SRC].[AcceptedOfferIndicator]	  
            ,[DST].[EMCAccepted]	          =   [SRC].[EMCAccepted]	          
            ,[DST].[Age]	                  =   [SRC].[Age]	                  
            ,[DST].[FirstName]	              =   [SRC].[FirstName]	              
            ,[DST].[LastName]	              =   [SRC].[LastName]	              
            ,[DST].[Gender]                   =   [SRC].[Gender];                       
                    
        
    end try        
        
    begin catch        
        
        if @@trancount > 0        
            rollback transaction        
        
            
        
    end catch        
        
    if @@trancount > 0        
        commit transaction        
        
end 
GO
