USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[Quote_Data_PlanDrop_Proc]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Quote_Data_PlanDrop_Proc]               
                                                                                           
--@StartDate datetime                                                                                              
as              
Begin            
            
            
if object_id('Temp_Plandrop') is not null            
        drop table Temp_Plandrop            
          
            
SELECT * INTO Temp_Plandrop FROM (                                                                                                      
select distinct            
a.SESSIONID as Lead_Number,                                                                                                                                                  
ISNULL(gclid,'') as GCLID,                                                                                                                                                  
ISNULL(gaClientID,'') as GA_Client_ID,                                                                                                                                                  
CONVERT(varchar(500),LinkID collate SQL_Latin1_General_CP1_CI_AS)   as Link_ID,                                                                                                  
a.SESSIONID as [Session ID],             
R.Age as [Age],          
replace(Country_list,',',';') as  [Destination],          
replace(Region_List,',','') as [Region_List],          
Quote_Date as [Quote Date],          
convert(date,Departure_Date,103) as [Trip Start],          
convert(date,Return_Date,103)    as [Trip end],          
isnull(DiscountPercent,'') AS[Promotional_Factor],          
cast(ISNULL(a.Excess,'') as decimal(10,4))   AS  [Excess],          
I.ProductName collate DATABASE_DEFAULT AS [Plan Type],          
'' as [Trip Type],          
cast(ISNULL(A.TotalAdjustedGrossPremium,0) as decimal(10,4)) as [Premium],          
AffiliateCode AS [Agency_Code],          
L.OutletName as [Agency_Name],          
L.GroupName as [Brand],          
'Online' as [Channel_Type],          
convert(varchar(150),E.SessionToken) AS [Session_Token]          
          
          
   from (                            
                                             
                                         
                                                          
                                                                              
                                         
                
                
--isnull(case when A.PromoCodeListID!='-1' then                                               
-- convert(varchar(50),convert(decimal(5,2),isnull(convert(varchar(30),case when A.PromoCodeListID!='-1'                                                           
--then (TotalGrossPremium-TotalAdjustedGrossPremium)/TotalGrossPremium*100 end),'')))+' % Discount' end,'')                     
--AS Promotional_Factor ,                  
                                                                                                                         
                              
                                                                                                              
SELECT convert(date,dbo.xfn_ConvertUTCtoLocal(b.Date+''+c.StandardTime,'E. Australia Standard TIme'),103) as Quote_Date,* from [db-au-stage].dbo.cdg_factQuote_AU_AG AS A1 inner join [db-au-stage].dbo.cdg_dimdate_au_AG                                  
as b on A1.QuoteTransactionDateID=b.DimDateID inner join  [db-au-stage].dbo.cdg_dimTime_AU as c  on a1.QuoteTransactionTimeID=c.DimTimeID                                      
WHERE  A1.SessionID IN (SELECT SessionID FROM  [db-au-stage].dbo.cdg_factQuote_AU_AG WHERE ProductID='-1')                                                                            
                                    
                                        
                                        
) AS A                                               
OUTER APPLY                                                                              
(SELECT B1.Date AS Departure_Date FROM  [db-au-stage].dbo.cdg_dimdate_au_AG AS B1                                              
WHERE  A.TripStartDateID=B1.DimDateID ) AS B                                                                                                                                                   
OUTER APPLY (SELECT C1.Date as Return_Date FROM  [db-au-stage].dbo.cdg_dimdate_au_AG AS C1                
WHERE  A.TripEndDateID=C1.DimDateID ) AS C                                                                                    
OUTER APPLY                                                                                                                                                  
(SELECT D1.Date AS QuotedDate FROM  [db-au-stage].dbo.cdg_dimDate_AU_AG AS D1                                                                                                                                                  
WHERE  A.QuoteTransactionDateID=D1.DimDateID) AS D                                                                                                                                            
OUTER APPLY                                                                                                                    
(SELECT SessionID,SessionToken,AffiliateCodeID FROM [db-au-stage].dbo.cdg_factSession_AU_AG AS E1                                                                                                                                   
WHERE SessionID=FactSessionID ) AS E                                                                                                                                              
OUTER APPLY(SELECT DimCampaignID,CampaignName,DefaultAffiliateCode,DefaultCultureCode FROM [db-au-stage].dbo.cdg_DimCampaign_AU_AG as F1                                                           
                           
where CampaignID=f1.DimCampaignID ) as F                              
OUTER APPLY                                                                                                                                                  
(select  RegionName as Region_List from  [db-au-stage].dbo.cdg_DimRegion_AU_AG as G1                                                                                                                                                   
where RegionID =g1.DimRegionID) as G                                                                                                                                      
OUTER APPLY                                                                                                                
(                                                                  
SELECT * FROM (                                                                      
SELECT B.DimCovermoreCountryListID,b.SessionID,b.FactQuoteID,                          
STUFF((select ','+CONVERT(VARCHAR(30),CovermoreCountryName) from (                                                                                    
SELECT SessionID,FactQuoteID,DimCovermoreCountryListID,COUNTRYID,CovermoreCountryName FROM (                                                            
SELECT  SessionID,FactQuoteID,DimCovermoreCountryListID,CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,CMCountryID7,                                                                  
CMCountryID8,CMCountryID9,CMCountryID10 FROM  [db-au-stage].dbo.cdg_factQuote_AU_AG                                                                                                            
AS A INNER JOIN [db-au-stage].dbo.cdg_dimCovermoreCountryList_AU_AG AS B ON A.DestCovermoreCountryListID=B.DimCovermoreCountryListID) AS A                                                                              
UNPIVOT                                    
(                                   
COUNTRYID FOR                                                        
COUNTRY IN (CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,CMCountryID7,CMCountryID8,CMCountryID9,CMCountryID10)                                              
) AS A INNER JOIN [db-au-stage].dbo.cdg_dimCovermoreCountry_AU_AG AS B ON COUNTRYID=B.DimCovermoreCountryID                                                                            
WHERE COUNTRYID<>'-1') AS A WHERE A.DimCovermoreCountryListID=B.DimCovermoreCountryListID                                                            
and  a.SessionID=b.SessionID and a.FactQuoteID=b.FactQuoteID  FOR XML PATH('')),1,1,'') AS Country_list                                                                                                                              
FROM                                                                               
(                                                                                                            
SELECT SessionID,FactQuoteID,DimCovermoreCountryListID,COUNTRYID,CovermoreCountryName FROM (                                                                                                                                                  
SELECT  SessionID,FactQuoteID,DimCovermoreCountryListID,CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,                                                                                                                        
  
    
      
         
          
           
CMCountryID7,                                                                                                                                                  
CMCountryID8,CMCountryID9,CMCountryID10 FROM  [db-au-stage].dbo.cdg_factQuote_AU_AG                                                                       
AS A INNER JOIN [db-au-stage].dbo.cdg_dimCovermoreCountryList_AU_AG AS B ON A.DestCovermoreCountryListID=B.DimCovermoreCountryListID) AS A                                              
                             
UNPIVOT                                                                             
(                                                                                                                                             
COUNTRYID FOR                                                                                       
COUNTRY IN (CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,CMCountryID7,CMCountryID8,CMCountryID9,                                                                                                                            
CMCountryID10)                                                                                                                              
) AS A INNER JOIN [db-au-stage].dbo.cdg_dimCovermoreCountry_AU_AG AS B ON COUNTRYID=B.DimCovermoreCountryID                                                          
WHERE COUNTRYID<>'-1'                                                                                                                                                  
) AS B GROUP BY B.DimCovermoreCountryListID,b.SessionID,b.FactQuoteID) AS H1                                                                                                                                                  
WHERE H1.SessionID=A.SessionID AND H1.FactQuoteID=A.FactQuoteID ) AS H                                                               
OUTER APPLY                                                                                                                                                  
(                                                                           
SELECT DimProductID,ProductCode,PlanCode,ProductName,TripFrequency FROM [db-au-stage].dbo.cdg_DimProduct_AU_AG AS I1                                         
WHERE A.ProductID=I1.DimProductID                                                    
) I                                                  
OUTER APPLY                                                          
                                                                                                           
(                                                                                                                                
SELECT * FROM (                                                                                                       
SELECT B.PromoCodeListID,b.SessionID,b.FactQuoteID,STUFF((select ','+CONVERT(VARCHAR(30),Code) from (                                                     
SELECT SessionID,FactQuoteID,PromoCodeListID,PromoCodeID,PromoCode,Code,Type,CampaignID FROM (                                                                                                                                              
SELECT  SessionID,FactQuoteID,PromoCodeListID,PromoCodeID1,PromoCodeID2,PromoCodeID3,PromoCodeID4 FROM                                                              
[db-au-stage].dbo.cdg_factQuote_AU_AG                                                                                                                         
AS A INNER JOIN [db-au-stage].dbo.cdg_dimPromoCodeList_AU_AG AS B ON A.PromoCodeListID=B.DimPromoCodeListID) AS A                                                                                                                    
UNPIVOT                                                                                            
(                                                                                                                                                  
PromoCodeID FOR                                                                                                                     
PromoCode IN (PromoCodeID1,PromoCodeID2,PromoCodeID3,PromoCodeID4)                                                                      
) AS A INNER JOIN [db-au-stage].dbo.cdg_dimPromocode_AU_AG AS B ON PromoCodeID=B.DimPromoCodeID                                                                                                             
WHERE PromoCodeID<>'-1') AS A WHERE A.PromoCodeListID=B.PromoCodeListID                                                                              
and  a.SessionID=b.SessionID and a.FactQuoteID=b.FactQuoteID  FOR XML PATH('')),1,1,'') AS Prmocode_list                                                                                                                                           
FROM                                                                                                      
(                                                                                     
SELECT SessionID,FactQuoteID,PromoCodeListID,PromoCodeID,PromoCode,Code,Type,CampaignID FROM (                                                                                                                                                  
SELECT  SessionID,FactQuoteID,PromoCodeListID,PromoCodeID1,PromoCodeID2,PromoCodeID3,PromoCodeID4 FROM                                                                                     
[db-au-stage].dbo.cdg_factQuote_AU_AG                                                                                                                                              
AS A INNER JOIN [db-au-stage].dbo.cdg_dimPromoCodeList_AU_AG AS B ON A.PromoCodeListID=B.DimPromoCodeListID ) AS A                                                                                                        
UNPIVOT                                                                                                                                            
(                                                                                                                  
PromoCodeID FOR                                                                                                                                                  
PromoCode IN (PromoCodeID1,PromoCodeID2,PromoCodeID3,PromoCodeID4)                                                                              
) AS A INNER JOIN [db-au-stage].dbo.cdg_dimPromocode_AU_AG AS B ON PromoCodeID=B.DimPromoCodeID                                                                                                                                                 
WHERE PromoCodeID<>'-1'                                                                                                                             
) AS B GROUP BY B.PromoCodeListID,b.SessionID,b.FactQuoteID) AS J1                                                                                                                                                  
WHERE J1.SessionID=A.SessionID AND J1.FactQuoteID=A.FactQuoteID                                                                    
)J                                                                                                                                                
                                                                                                        
OUTER APPLY                                                                                                                                                 
(                                                              
select k1.factpolicyid,k1.policynumber,k1.sessionid,k1.contactid,HasEMC from [db-au-stage].dbo.cdg_factPolicy_AU_AG as k1                                                                                        
where a.sessionid=k1.sessionid                                              
) k                                                                                                                       
                                                                                                                                        
OUTER APPLY                                                                                  
(                                                                                                                  
SELECT DimGroupTypeID,GroupTypeName,GroupTypeNameShort FROM [db-au-stage].dbo.cdg_dimGroupType_AU_AG AS Y1X                                                                                                                                   
WHERE Y1X.DimGroupTypeID=A.GroupTypeID                                                                                                          
)  AS YX                                              
                                            
--OUTER APPLY                                            
--(                        
--select  DISTINCT              
--json_value([PartnerMetaData],'$.LinkID') as LinkID,            
--json_value([PartnerMetaData],'$.gclid') as gclid,              
--json_value([PartnerMetaData],'$.gaClientID') as gaClientID,            
--replace(json_value([PartnerMetaData],'$.TravellerAges'),'"','') as Age,            
--Sessiontoken from [db-au-stage].dbo.cdg_SessionPartnerMetaData_AU_AG                                             
--as Y2X WHERE y2x.Sessiontoken=e.SessionToken AND              
--SessionToken IN (            
            
--SELECT SessionToken from [db-au-stage].dbo.cdg_factQuote_AU_AG AS A1 inner join [db-au-stage].dbo.cdg_dimdate_au_AG                                  
--as b on A1.QuoteTransactionDateID=b.DimDateID inner join  [db-au-stage].dbo.cdg_dimTime_AU as c  on a1.QuoteTransactionTimeID=c.DimTimeID             
--inner join  [db-au-stage].dbo.cdg_factsession_AU_AG AS D ON A1.SESSIONID=D.FACTSESSIONID                               
--WHERE   ProductID='-1') AND            
-- (            
-- PartnerMetaData like '%LinkID%' or            
-- PartnerMetaData like '%gclid%' or            
-- PartnerMetaData like '%gaClientID%' or         
-- PartnerMetaData like '%TravellerAges%'         
-- )                                           
--) AS YZ              
OUTER APPLY            
(            
SELECT DISTINCT AffiliateCode FROM [db-au-stage].[dbo].cdg_dimAffiliateCode_AU  AS Z1 WITH(NOLOCK) WHERE E.AffiliateCodeID=Z1.DimAffiliateCodeID             
) AS Z        
--OUTER apply       
--(        
        
        
--SELECT SessionToken,PROMOCODE,PromoType,DiscountPercent FROM  (        
--SELECT SessionToken,[PartnerMetaData],PROMOCODE, PromoType, DiscountPercent   from     
--(SELECT * FROM [db-au-stage].dbo.cdg_SessionPartnerMetaData_AU_AG WHERE  PartnerMetaData LIKE '%PromotionalFactor%' ) as c       
--CROSS APPLY OPENJSON (json_value([PartnerMetaData],'$.PromotionalFactor')) with(        
--  PROMOCODE   nvarchar(255)  '$.PromoCode', PromoType nvarchar(255) '$.PromoType', DiscountPercent nvarchar(255) '$.DiscountPercent'        
--) AS A        
--) AS A WHERE a.SessionToken=e.SessionToken        
        
            
--) as Z1 

OUTER APPLY
(
SELECT Sessiontoken,LinkID,gclid,gaClientID,Age,PROMOCODE,PromoType,DiscountPercent FROM Json_SessionPartnerMetaData_AU_AG AS R1
WHERE R1.Sessiontoken=E.SessionToken
)
  AS R     
OUTER apply        
(        
select GroupName,OutletName,SubGroupName,SuperGroupName from [db-au-cmdwh].dbo.penOutlet as L1 where L1.AlphaCode COLLATE SQL_Latin1_General_CP1_CI_AS=z.AffiliateCode and OutletStatus='Current'        
) as L        
        
        
) as a         
        
delete  from  [db-au-cmdwh].[dbo].[Quote_Data_BreakDown_PlanDrop] where Session_ID in       
(select [Session ID] from Temp_Plandrop)      
      
  
      
      
Insert into  [db-au-cmdwh].[dbo].[Quote_Data_BreakDown_PlanDrop]      
(      
Lead_Number ,      
GCLID ,      
GA_Client_ID ,      
Link_ID ,      
Session_ID  ,      
Age ,      
Destination ,      
Region_List ,      
Quote_Date ,      
Trip_Start ,      
Trip_end ,      
Promotional_Factor ,      
Excess ,      
Plan_Type ,      
Trip_Type ,      
Premium ,      
Agency_Code ,      
Agency_Name ,      
Brand ,      
Channel_Type ,      
Session_Token       
)      
      
      
      
      
SELECT  Lead_Number ,      
GCLID ,      
GA_Client_ID ,      
Link_ID ,      
[Session ID]  SessionID  ,      
Age ,      
Destination ,      
Region_List ,      
[Quote Date] as  Quote_Date ,      
[Trip Start] as  Trip_Start ,      
[Trip end] as  Trip_end ,      
Promotional_Factor ,      
Excess ,      
[Plan Type] as   Plan_Type ,      
[Trip Type] as   Trip_Type ,      
Premium ,      
Agency_Code ,      
Agency_Name ,      
Brand ,      
Channel_Type ,      
Session_Token  FROM Temp_Plandrop        
            
            
 END 
GO
