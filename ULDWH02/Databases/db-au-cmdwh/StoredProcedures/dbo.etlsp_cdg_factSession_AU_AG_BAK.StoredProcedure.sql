USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cdg_factSession_AU_AG_BAK]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE procedure [dbo].[etlsp_cdg_factSession_AU_AG_BAK]        
          
as      
begin     
    
 set nocount on    
    
begin transaction      
      
    begin try      
    
  merge into [db-au-cmdwh]..cdg_factSession_AU_AG as DST      
        using [db-au-stage]..cdg_factSession_AU_AG as SRC      
        on (SRC.FactSessionID = DST.FactSessionID and SRC.SessionCreateDateID=DST.sessioncreatedateID and SRC.sessionclosedateid=DST.sessionclosedateid)      
        -- inserting new records      
        when not matched by target then      
        insert      
        (      
            [FactSessionID] ,    
   [BusinessUnitID] ,    
   [CampaignID] ,    
   [SessionCreateDateID] ,    
   [SessionCreateTimeID] ,    
   [SessionCloseDateID] ,    
   [SessionCloseTimeID] ,    
   [ParentFactSessionID] ,    
   [AffiliateCodeID] ,    
   [IsClosed] ,    
   [IsPolicyPurchased] ,    
   [Domain] ,    
   [SessionToken] ,    
   [GigyaID] ,    
   [TotalPoliciesSold]       
        )      
        values      
        (      
            SRC.[FactSessionID] ,    
   SRC.[BusinessUnitID] ,    
   SRC.[CampaignID] ,    
   SRC.[SessionCreateDateID] ,    
   SRC.[SessionCreateTimeID] ,    
   SRC.[SessionCloseDateID] ,    
   SRC.[SessionCloseTimeID] ,    
   SRC.[ParentFactSessionID] ,    
   SRC.[AffiliateCodeID] ,    
   SRC.[IsClosed] ,    
   SRC.[IsPolicyPurchased] ,    
   SRC.[Domain] ,    
   SRC.[SessionToken] ,    
   SRC.[GigyaID] ,    
   SRC.[TotalPoliciesSold]     
        )      
              
        -- update existing records      
        when matched  then      
        update      
        SET      
            DST.[FactSessionID]=SRC.[FactSessionID] ,    
   DST.[BusinessUnitID]=SRC.[BusinessUnitID] ,    
   DST.[CampaignID]=SRC.[CampaignID] ,    
   DST.[SessionCreateDateID]=SRC.[SessionCreateDateID] ,    
   DST.[SessionCreateTimeID]=SRC.[SessionCreateTimeID] ,    
   DST.[SessionCloseDateID]=SRC.[SessionCloseDateID] ,    
   DST.[SessionCloseTimeID]=SRC.[SessionCloseTimeID] ,    
   DST.[ParentFactSessionID]=SRC.[ParentFactSessionID] ,    
   DST.[AffiliateCodeID]=SRC.[AffiliateCodeID] ,    
   DST.[IsClosed]=SRC.[IsClosed] ,    
   DST.[IsPolicyPurchased]=SRC.[IsPolicyPurchased] ,    
   DST.[Domain]=SRC.[Domain] ,    
   DST.[SessionToken]=SRC.[SessionToken] ,    
   DST.[GigyaID]=SRC.[GigyaID] ,    
   DST.[TotalPoliciesSold]=SRC.[TotalPoliciesSold];    
                  
      
    end try      
      
    begin catch      
      
        if @@trancount > 0      
            rollback transaction      
      
          
      
    end catch      
      
    if @@trancount > 0      
        commit transaction      
      
end 
GO
