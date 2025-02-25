USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_ImpuslePromocode]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



    
CREATE PROCEDURE [dbo].[etlsp_cmdwh_ImpuslePromocode]    
AS    
    
    
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
,IsMember  
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
    
    
  merge into [db-au-workspace]..ImpPromocode  as DST              
        using   [db-au-workspace]..ETL_PROMO as   SRC           
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
   ,Getdate()    
  )    
  -- update existing data    
          when matched  then            
        update            
        SET      
    
                 [DST].[SessionID]               =[SRC].[SessionID]     
                ,[DST].[PromoCodeID]             =[SRC].[PromoCodeID]     
                ,[DST].[PROMOCODE]               =[SRC].[PROMOCODE]     
                ,[DST].[PromoType]               =[SRC].[PromoType]     
                ,[DST].[DiscountPercent]         =[SRC].[DiscountPercent]     
                ,[DST].[DollarDiscount]          =[SRC].[DollarDiscount]    
                ,[DST].[StartDate]               =[SRC].[StartDate]    
                ,[DST].[EndDate]                 =[SRC].[EndDate]     
                ,[DST].[PointsAwarded]           =[SRC].[PointsAwarded]     
                ,[DST].[AccrualRate]             =[SRC].[AccrualRate]     
                ,[DST].[ActivityDescriptionKey]  =[SRC].[ActivityDescriptionKey]     
                ,[DST].[BonusPoints]             =[SRC].[BonusPoints]     
                ,[DST].[IsPointsAwardPromo]      =[SRC].[IsPointsAwardPromo]    
                ,[DST].[PolicyNumber]            =[SRC].[PolicyNumber];    
          --,[DST].[updatedate]               = GETDATE();    
       
    
    
    
    
    
    
-- Copy the data into penPolicyTransactionPromo table    
    
    
merge into [db-au-workspace]..penPolicyTransactionPromo_Imp  as DST              
        using   [db-au-workspace]..VW_ImpPromo as   SRC           
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
  )    
  -- update existing data    
          when matched  then            
        update            
        SET      
    
                 [DST].[ImpPromoID]               =[SRC].[ImpPromoID]     
                ,[DST].[ImpPromoCode]             =[SRC].[ImpPromoCode]     
                ,[DST].[ImpPromoType]             =[SRC].[ImpPromoType]     
                ,[DST].[ImpDiscount]              =[SRC].[ImpDiscount];     
              
       
    
    
    
    
END
GO
