USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_Impulse_CMDWH_Load_AU_AG]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[etlsp_Impulse_CMDWH_Load_AU_AG]        
  
as      
begin     
    
 set nocount on    
    
begin transaction      
      
    begin try   
   
  if object_id('[db-au-cmdwh]..[cdg_dimPromoCodeList_AU_AG]') is not null    
        drop table [db-au-cmdwh]..[cdg_dimPromoCodeList_AU_AG]   
  
 select * into [db-au-cmdwh]..cdg_dimPromoCodeList_AU_AG from [db-au-stage]..cdg_dimPromoCodeList_AU_AG    
  
  if object_id('[db-au-cmdwh]..[cdg_dimGroupType_AU_AG]') is not null    
        drop table [db-au-cmdwh]..cdg_dimGroupType_AU_AG   
  
 select * into [db-au-cmdwh]..cdg_dimGroupType_AU_AG from [db-au-stage]..cdg_dimGroupType_AU_AG    
  
  if object_id('[db-au-cmdwh]..[cdg_DimProduct_AU_AG]') is not null    
        drop table [db-au-cmdwh]..cdg_DimProduct_AU_AG   
  
 select * into [db-au-cmdwh]..cdg_DimProduct_AU_AG from [db-au-stage]..cdg_DimProduct_AU_AG  
  
  if object_id('[db-au-cmdwh]..[cdg_DimRegion_AU_AG]') is not null    
        drop table [db-au-cmdwh]..cdg_DimRegion_AU_AG   
  
 select * into [db-au-cmdwh]..cdg_DimRegion_AU_AG from [db-au-stage]..cdg_DimRegion_AU_AG  
   
  if object_id('[db-au-cmdwh]..[cdg_dimCovermoreCountry_AU_AG]') is not null    
        drop table [db-au-cmdwh]..cdg_dimCovermoreCountry_AU_AG   
  
 select * into [db-au-cmdwh]..cdg_dimCovermoreCountry_AU_AG from [db-au-stage]..cdg_dimCovermoreCountry_AU_AG  
  
  if object_id('[db-au-cmdwh]..[cdg_dimCovermoreCountryList_AU_AG]') is not null    
        drop table [db-au-cmdwh]..cdg_dimCovermoreCountryList_AU_AG   
  
 select * into [db-au-cmdwh]..cdg_dimCovermoreCountryList_AU_AG from [db-au-stage]..cdg_dimCovermoreCountryList_AU_AG   
  
  if object_id('[db-au-cmdwh]..[cdg_dimDate_AU_AG]') is not null    
        drop table [db-au-cmdwh]..cdg_dimDate_AU_AG   
  
 select * into [db-au-cmdwh]..cdg_dimDate_AU_AG from [db-au-stage]..cdg_dimDate_AU_AG   
  
  if object_id('[db-au-cmdwh]..[cdg_dimPromocode_AU_AG]') is not null    
        drop table [db-au-cmdwh]..cdg_dimPromocode_AU_AG   
  
 select * into [db-au-cmdwh]..cdg_dimPromocode_AU_AG from [db-au-stage]..cdg_dimPromocode_AU_AG   

  if object_id('[db-au-cmdwh]..[cdg_DimCampaign_AU_AG]') is not null    
        drop table [db-au-cmdwh]..cdg_DimCampaign_AU_AG   
  
 select * into [db-au-cmdwh]..cdg_DimCampaign_AU_AG from [db-au-stage]..cdg_DimCampaign_AU_AG   
  
    end try      
      
    begin catch      
      
        if @@trancount > 0      
            rollback transaction      
      
          
      
    end catch      
      
    if @@trancount > 0      
        commit transaction      
      
end 
GO
