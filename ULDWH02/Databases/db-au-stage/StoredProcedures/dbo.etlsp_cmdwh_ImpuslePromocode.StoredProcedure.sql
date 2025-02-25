USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_ImpuslePromocode]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [dbo].[etlsp_cmdwh_ImpuslePromocode]      
AS     
  
  
/************************************************************************************************************************************                                                          
Author:         Abhilash Yelmelwar                                                        
Date:           20250131                                                                                                                                                                  
Change History:                                        
Date:31-01-2025     NAME :Abhilash Y CHG0040339  Created This Procedure to Import Impusle Promocode into BI DWH  
                              
    
         
                                                                        
*************************************************************************************************************************************/      
  
  
      
      
BEGIN       
IF OBJECT_ID('ETL_PROMO') IS NOT NULL      
drop table ETL_PROMO       
      
      
--Copy The Impulse Promocode Data from table SessionPartnerMetaData to temp table      
      
SELECT * INTO ETL_PROMO      
FROM (      
SELECT       
FactSessionID AS SessionID      
,DimPromoCodeID as PromoCodeID      
,PROMOCODE      
,F.Type AS PromoType      
,DiscountPercent      
,DollarDiscount      
,StartDate      
,EndDate      
,PointsAwarded      
,AccrualRate      
,ActivityDescriptionKey      
,BonusPoints      
,IsPointsAwardPromo      
,PolicyNumber    
,PROMOCODE_Additional    
,case when IsMember='true' then 'Yes' else   'No' end as   IsMember
FROM  (              
SELECT       
*  from           
(    
    
    
SELECT [PartnerMetaData],SessionToken,    
json_value([PartnerMetaData],'$.Promocode') as Promocode_Additional,    
json_value([PartnerMetaData],'$.isMember') as IsMember    
FROM (    
SELECT [PartnerMetaData],SessionToken FROM [db-au-stage].dbo.cdg_SessionPartnerMetaData_AU_AG with(nolock)     
WHERE  PartnerMetaData LIKE '%PromotionalFactor%'    
) AS A    
    
    
) as c             
CROSS APPLY OPENJSON (json_value([PartnerMetaData],'$.PromotionalFactor'))       
with(              
  PROMOCODE   nvarchar(255)  '$.PromoCode',       
  PromoType nvarchar(255) '$.PromoType',       
  DiscountPercent nvarchar(255) '$.DiscountPercent',      
  DollarDiscount  nvarchar(255) '$.DollarDiscount',      
  StartDate nvarchar(255)  '$.StartDate',      
  EndDate nvarchar(255)  '$.EndDate',      
  PointsAwarded nvarchar(255)  '$.PointsAwarded',      
  AccrualRate nvarchar(255)  '$.AccrualRate',      
  ActivityDescriptionKey   nvarchar(255)  '$.ActivityDescriptionKey',      
  BonusPoints   nvarchar(255)  '$.BonusPoints',       
  IsPointsAwardPromo  nvarchar(255)  '$.IsPointsAwardPromo'      
      
      
) AS A     
) AS A      
INNER JOIN [db-au-stage].dbo.cdg_factSession_AU_AG AS B with(nolock)     ON  A.SessionToken=B.SessionToken      
INNER JOIN [db-au-stage].dbo.cdg_factPolicy_AU_AG AS C with(nolock)      ON  B.FactSessionID=C.SessionID      
INNER JOIN [db-au-stage].dbo.cdg_factQuote_AU_AG AS D  with(nolock)       ON  B.FactSessionID=D.SessionID      
INNER JOIN [db-au-stage].dbo.cdg_dimPromoCodeList_AU_AG AS E with(nolock) ON  D.PromoCodeListID=E.DimPromoCodeListID      
INNER JOIN [db-au-stage].dbo.cdg_dimPromocode_AU_AG AS F  with(nolock)    ON  F.DimPromoCodeID=E.PromoCodeID1      
      
      
) AS A      
      
      
      
      
--Insert the data into ImpPromocode table from temptable      
      
      
  merge into [db-au-stage]..ImpPromocode  as DST                
        using   ETL_PROMO as   SRC             
        on (SRC.[SessionID] = DST.[SessionID] and SRC.[PolicyNumber] = DST.[PolicyNumber])              
        -- inserting new records              
        when not matched by target then              
        insert              
        (         
          [SessionID]       
         ,[PromoCodeID]       
         ,[PROMOCODE]                
         ,[PromoType]       
         ,[DiscountPercent]       
         ,[DollarDiscount]      
         ,[StartDate]      
         ,[EndDate]       
         ,[PointsAwarded]       
         ,[AccrualRate]       
         ,[ActivityDescriptionKey]       
         ,[BonusPoints]       
         ,[IsPointsAwardPromo]      
         ,[PolicyNumber]
         ,[PROMOCODE_Additional]
         ,[IsMember]      
         ,[CreateDate]      
  )      
  VALUES      
  (      
          [SRC].[SessionID]       
         ,[SRC].[PromoCodeID]       
         ,[SRC].[PROMOCODE]       
         ,[SRC].[PromoType]       
         ,[SRC].[DiscountPercent]       
         ,[SRC].[DollarDiscount]      
         ,[SRC].[StartDate]      
         ,[SRC].[EndDate]       
         ,[SRC].[PointsAwarded]       
         ,[SRC].[AccrualRate]       
         ,[SRC].[ActivityDescriptionKey]       
         ,[SRC].[BonusPoints]       
         ,[SRC].[IsPointsAwardPromo]      
         ,[SRC].[PolicyNumber]
         ,[SRC].[PROMOCODE_Additional]
         ,[SRC].[IsMember]      
         ,Getdate()      
  )      
  -- update existing data      
          when matched  then              
        update              
        SET        
      
                 [DST].[SessionID]                       =[SRC].[SessionID]       
                ,[DST].[PromoCodeID]                     =[SRC].[PromoCodeID]       
                ,[DST].[PROMOCODE]                       =[SRC].[PROMOCODE]       
                ,[DST].[PromoType]                       =[SRC].[PromoType]       
                ,[DST].[DiscountPercent]                 =[SRC].[DiscountPercent]       
                ,[DST].[DollarDiscount]                  =[SRC].[DollarDiscount]      
                ,[DST].[StartDate]                       =[SRC].[StartDate]      
                ,[DST].[EndDate]                         =[SRC].[EndDate]       
                ,[DST].[PointsAwarded]                   =[SRC].[PointsAwarded]       
                ,[DST].[AccrualRate]                     =[SRC].[AccrualRate]       
                ,[DST].[ActivityDescriptionKey]          =[SRC].[ActivityDescriptionKey]       
                ,[DST].[BonusPoints]                     =[SRC].[BonusPoints]       
                ,[DST].[IsPointsAwardPromo]              =[SRC].[IsPointsAwardPromo]      
                ,[DST].[PolicyNumber]                    =[SRC].[PolicyNumber]
                ,[DST].[PROMOCODE_Additional]            =[SRC].[PROMOCODE_Additional]
                ,[DST].[IsMember]                        =[SRC].[IsMember]
                
                
                ;      
          --,[DST].[updatedate]               = GETDATE();      
         
      
      
      
      
      
      
-- Copy the data into penPolicyTransactionPromo table      
      
      
merge into [db-au-cmdwh]..penPolicyTransactionPromo  as DST                
        using   VW_ImpPromo as   SRC             
        on (SRC.[PolicyTransactionKey] = DST.[PolicyTransactionKey] and SRC.[PolicyNumber] = DST.[PolicyNumber])              
        -- inserting new records              
        when not matched by target then              
        insert              
        (       
       
              [CountryKey]      
             ,[CompanyKey]      
             ,[PolicyTransactionKey]      
             ,[PolicyNumber]      
             ,[ImpPromoID]      
             ,[ImpPromoCode]       
             ,[ImpPromoType]       
             ,[ImpDiscount]
             ,[PROMOCODE_Additional]
             ,[IsMember]
                   
  )      
  VALUES      
  (      
      
      
         [SRC].[CountryKey]      
        ,[SRC].[CompanyKey]      
        ,[SRC].[PolicyTransactionKey]      
        ,[SRC].[PolicyNumber]      
        ,[SRC].[ImpPromoID]       
        ,[SRC].[ImpPromoCode]       
        ,[SRC].[ImpPromoType]       
        ,[SRC].[ImpDiscount]
        ,[SRC].[PROMOCODE_Additional]
        ,[SRC].[IsMember]        
  )      
  -- update existing data      
          when matched  then              
        update              
        SET        
      
                 [DST].[ImpPromoID]                        =[SRC].[ImpPromoID]       
                ,[DST].[ImpPromoCode]                      =[SRC].[ImpPromoCode]       
                ,[DST].[ImpPromoType]                      =[SRC].[ImpPromoType]       
                ,[DST].[ImpDiscount]                       =[SRC].[ImpDiscount]
                ,[DST].[PROMOCODE_Additional]              =[SRC].[PROMOCODE_Additional]
                ,[DST].[IsMember]                          =[SRC].[IsMember];
                
                
                       
                
         
      
      
      
      
END
GO
