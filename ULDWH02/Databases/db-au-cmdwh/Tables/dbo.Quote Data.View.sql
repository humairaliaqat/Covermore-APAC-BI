USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[Quote Data]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                
             
            
CREATE view [dbo].[Quote Data] as                     
select                     
QuotedDate,                            
a.SESSIONID as Lead_Number,                          
'' as GCLID,                          
'' as GA_Client_ID,                          
'' as LinkID,                          
'' as [Marketing Opt-Out],                            
m.PolicyNumber as [Policy_Number],                            
'Quote' as Transaction_Type,                          
1 as Transaction_Sequence_Number,                          
QuotedDate as Transaction_Date,                          
QuotedDate as RateEffective_Date,                          
replace(Country_list,',',';') as [TravelCountries_List],                            
'' as [Primary_Region],                          
'' as Area_No,                          
'' as Area_Type,                          
len(Country_list) - len(replace(Country_list, ',', '')) +1 as Number_of_Countries,                            
Region_List,                            
Departure_Date,                            
Return_Date,                            
datediff(DAY,QuotedDate,Departure_Date) AS Days_to_Departure,                            
datediff(DAY,Departure_Date,Return_Date)+1 AS Trip_Duration,                          
TripFrequency AS Trip_Type,                          
i.PlanCode AS Plan_Code,                            
ProductName as [Plan],                           
GroupTypeName AS [Single/Family],                          
NumAdults AS Number_of_Adults,                            
NumChildren AS Number_of_Children,                            
m.Excess  AS Excess_Amount,     
CASE             
WHEN ProductName='Comprehensive' AND convert(VARCHAR(300),CANXCoverageAmount)='1' THEN '10000.00'             
WHEN ProductName='Essential' AND convert(VARCHAR(300),CANXCoverageAmount)='1' THEN '5000.00'            
WHEN  convert(VARCHAR(300),CANXCoverageAmount)='-1' THEN 'Unlimited' else convert(VARCHAR(300),CANXCoverageAmount) end            
AS  CancellationSumInsured,    
--CANXCoverageAmount AS  CancellationSumInsured,                          
HasCRS as Cruise_Flag,                            
HasADVACT as AdventureActivities_Flag,                            
HasMTCLTWO as Motorbike_Flag,                            
HasSNSPRTS as SnowSports_Flag,                            
HasLUGG as Luggage_Flag,                            
'' as PEMC_Flag,                            
'' as Covid_Flag,                            
n.BasePremium AS Quoted_Base_Premium,                          
Cancellation_Premium AS Quoted_Cancellation_Premium,                          
o4.SnowSports_Premium AS Quoted_SnowSports_Premium,                          
s.AdventureActivities_Premium AS Quoted_AdventureActivities_Premium,                          
o3.Luggage_Premium AS Quoted_Luggage_Premium,                          
PEMC_Premium AS Quoted_PEMC_Premium,                          
Covid_Premium AS Quoted_Covid_Premium,                          
u.Cruise_Premium AS Quoted_Cruise_Premium,                          
q.Total_Premium AS Total_Quoted_Premium,                          
q.GST_on_Total_Premium AS GST_on_Quoted_Premium,                          
q.Stamp_Duty_on_Total_Premium AS Stamp_Duty_on_Quoted_Premium,              
CASE WHEN m.PolicyNumber IS NULL THEN A.TotalGrossPremium ELSE               
ISNULL(q.Total_Premium,  '')-( ISNULL(q.GST_on_Total_Premium, '')+ISNULL(q.Stamp_Duty_on_Total_Premium,'')) END AS Total_Quoted_Gross_Premium,              
'' AS NAP,                          
o.Title AS Policyholder_Title,                          
o.FirstName AS Policyholder_First_Name,                          
o.LastName AS  Policyholder_Surname,                          
o.EmailAddress AS  Policyholder_Email,                          
o.MobilePhone AS  Policyholder_Mobile_Phone,                          
o.PolicyHolder_Address AS   Policyholder_Address,                          
o.DOB as PolicyHolder_DOB,                    
o.Age as PolicyHolder_Age,                          
o.State AS Policyholder_State,                          
OldestTraveller_DOB,                          
OldestTraveller_Age,                          
DefaultAffiliateCode AS Agency_Code,                          
CampaignName AS Agency_Name,                          
CampaignName AS Brand,                          
'Online' as Channel_Type,                            
Prmocode_list AS Promotional_Code,                            
SessionToken AS [Session Token]                       
FROM(                    
SELECT * from [db-au-cmdwh].dbo.cdg_factQuote_AU_AG AS A1 WHERE BusinessUnitID=142 AND CampaignID=335       
and quotetransactiondateid in (          
select dimdateid  from  [db-au-cmdwh].dbo.cdg_dimDate_AU_AG where convert(date,date,103)=convert(date,getdate()-6,103))         
) AS A                       
OUTER APPLY                          
(SELECT B1.Date AS Departure_Date FROM  [db-au-cmdwh].dbo.cdg_dimDate_AU_AG AS B1                          
WHERE  A.TripStartDateID=B1.DimDateID ) AS B                           
OUTER APPLY (SELECT C1.Date as Return_Date FROM  [db-au-cmdwh].dbo.cdg_dimDate_AU_AG AS C1                          
WHERE  A.TripEndDateID=C1.DimDateID ) AS C                          
OUTER APPLY                          
(SELECT D1.Date AS QuotedDate FROM  [db-au-cmdwh].dbo.cdg_dimDate_AU_AG AS D1                          
WHERE  A.QuoteTransactionDateID=D1.DimDateID) AS D                          
OUTER APPLY                          
(SELECT SessionID,SessionToken FROM [db-au-cmdwh].dbo.cdg_factSession_AU_AG AS E1                          
WHERE SessionID=FactSessionID ) AS E                          
OUTER APPLY(SELECT DimCampaignID,CampaignName,DefaultAffiliateCode,DefaultCultureCode FROM       
[db-au-cmdwh].dbo.cdg_DimCampaign_AU_AG as F1                         
where CampaignID=f1.DimCampaignID ) as F                          
OUTER APPLY                          
(select  RegionName as Region_List from  [db-au-cmdwh].dbo.cdg_DimRegion_AU_AG as G1                           
where RegionID =g1.DimRegionID) as G                          
OUTER APPLY                          
(                          
SELECT * FROM (                          
SELECT B.DimCovermoreCountryListID,b.SessionID,b.FactQuoteID,STUFF((select ','+CONVERT(VARCHAR(30),CovermoreCountryName) from (                
SELECT SessionID,FactQuoteID,DimCovermoreCountryListID,COUNTRYID,CovermoreCountryName FROM (                          
SELECT  SessionID,FactQuoteID,DimCovermoreCountryListID,CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,CMCountryID7,                          
CMCountryID8,CMCountryID9,CMCountryID10 FROM  [db-au-cmdwh].dbo.cdg_factQuote_AU_AG                          
AS A INNER JOIN [db-au-cmdwh].dbo.cdg_dimCovermoreCountryList_AU_AG AS B ON A.DestCovermoreCountryListID=B.DimCovermoreCountryListID) AS A                          
UNPIVOT                          
(                          
COUNTRYID FOR                          
COUNTRY IN (CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,CMCountryID7,CMCountryID8,CMCountryID9,CMCountryID10)                          
) AS A INNER JOIN [db-au-cmdwh].dbo.cdg_dimCovermoreCountry_AU_AG AS B ON COUNTRYID=B.DimCovermoreCountryID       
WHERE COUNTRYID<>'-1') AS A WHERE A.DimCovermoreCountryListID=B.DimCovermoreCountryListID                          
and  a.SessionID=b.SessionID and a.FactQuoteID=b.FactQuoteID  FOR XML PATH('')),1,1,'') AS Country_list                          
FROM                           
(                          
SELECT SessionID,FactQuoteID,DimCovermoreCountryListID,COUNTRYID,CovermoreCountryName FROM (                          
SELECT  SessionID,FactQuoteID,DimCovermoreCountryListID,CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,            
CMCountryID7,                          
CMCountryID8,CMCountryID9,CMCountryID10 FROM  [db-au-cmdwh].dbo.cdg_factQuote_AU_AG                          
AS A INNER JOIN [db-au-cmdwh].dbo.cdg_dimCovermoreCountryList_AU_AG AS B ON A.DestCovermoreCountryListID=B.DimCovermoreCountryListID) AS A                          
UNPIVOT                          
(                          
COUNTRYID FOR                          
COUNTRY IN (CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,CMCountryID7,CMCountryID8,CMCountryID9,            
CMCountryID10)                          
) AS A INNER JOIN [db-au-cmdwh].dbo.cdg_dimCovermoreCountry_AU_AG AS B ON COUNTRYID=B.DimCovermoreCountryID                          
WHERE COUNTRYID<>'-1'                          
) AS B GROUP BY B.DimCovermoreCountryListID,b.SessionID,b.FactQuoteID) AS H1                          
WHERE H1.SessionID=A.SessionID AND H1.FactQuoteID=A.FactQuoteID ) AS H                          
OUTER APPLY                          
(                          
SELECT DimProductID,ProductCode,PlanCode,ProductName,TripFrequency FROM [db-au-cmdwh].dbo.cdg_DimProduct_AU_AG AS I1                          
WHERE A.ProductID=I1.DimProductID                          
) I                          
OUTER APPLY             
                          
(                          
SELECT * FROM (                          
SELECT B.PromoCodeListID,b.SessionID,b.FactQuoteID,STUFF((select ','+CONVERT(VARCHAR(30),Code) from (                          
SELECT SessionID,FactQuoteID,PromoCodeListID,PromoCodeID,PromoCode,Code,Type,CampaignID FROM (                          
SELECT  SessionID,FactQuoteID,PromoCodeListID,PromoCodeID1,PromoCodeID2,PromoCodeID3,PromoCodeID4 FROM              
[db-au-cmdwh].dbo.cdg_factQuote_AU_AG                          
AS A INNER JOIN [db-au-cmdwh].dbo.cdg_dimPromoCodeList_AU_AG AS B ON A.PromoCodeListID=B.DimPromoCodeListID) AS A                          
UNPIVOT                          
(                          
PromoCodeID FOR                          
PromoCode IN (PromoCodeID1,PromoCodeID2,PromoCodeID3,PromoCodeID4)                          
) AS A INNER JOIN [db-au-cmdwh].dbo.cdg_dimPromocode_AU_AG AS B ON PromoCodeID=B.DimPromoCodeID                    
WHERE PromoCodeID<>'-1') AS A WHERE A.PromoCodeListID=B.PromoCodeListID                          
and  a.SessionID=b.SessionID and a.FactQuoteID=b.FactQuoteID  FOR XML PATH('')),1,1,'') AS Prmocode_list                          
FROM                           
(                          
SELECT SessionID,FactQuoteID,PromoCodeListID,PromoCodeID,PromoCode,Code,Type,CampaignID FROM (                          
SELECT  SessionID,FactQuoteID,PromoCodeListID,PromoCodeID1,PromoCodeID2,PromoCodeID3,PromoCodeID4 FROM              
[db-au-cmdwh].dbo.cdg_factQuote_AU_AG                          
AS A INNER JOIN [db-au-cmdwh].dbo.cdg_dimPromoCodeList_AU_AG AS B ON A.PromoCodeListID=B.DimPromoCodeListID ) AS A                          
UNPIVOT                          
(                          
PromoCodeID FOR                          
PromoCode IN (PromoCodeID1,PromoCodeID2,PromoCodeID3,PromoCodeID4)                          
) AS A INNER JOIN [db-au-cmdwh].dbo.cdg_dimPromocode_AU_AG AS B ON PromoCodeID=B.DimPromoCodeID                          
WHERE PromoCodeID<>'-1'                          
) AS B GROUP BY B.PromoCodeListID,b.SessionID,b.FactQuoteID) AS J1                          
WHERE J1.SessionID=A.SessionID AND J1.FactQuoteID=A.FactQuoteID                          
)J                        
                        
OUTER APPLY                         
(                        
select k1.factpolicyid,k1.policynumber,k1.sessionid,k1.contactid from [db-au-cmdwh].dbo.cdg_factPolicy_AU_AG as k1                        
where a.sessionid=k1.sessionid                        
) k                  
                
OUTER APPLY                
(                
SELECT DimGroupTypeID,GroupTypeName,GroupTypeNameShort FROM [db-au-cmdwh].dbo.cdg_dimGroupType_AU_AG AS Y1X                
WHERE Y1X.DimGroupTypeID=A.GroupTypeID                
)  AS YX                
                
OUTER APPLY                       
(select distinct CompanyKey,countrykey,PolicyNumber,PolicyID,PolicyKey,OutletAlphaKey,OutletSKey,IssueDate,PrimaryCountry as Destination,        Area,Excess,TripCost,PlanName,AreaCode,AreaName,AreaNumber,AreaType,TripStart,TripEnd,             
datediff(day,TripStart,TripEnd)+1 as Trip_Duration,TripType,PlanCode,datediff(day,IssueDate,TripStart)  as [Days_To_Departure] ,MultiDestination,CancellationCover  from [db-au-cmdwh].[dbo].penPolicy as M1  with (nolock)                                   
   
   
      
         
          
                            
  where  AlphaCode in ('BGD0001','BGD0002','BGD0003') and                     
  k.PolicyNumber collate SQL_Latin1_General_CP1_CI_AS =m1.PolicyNumber                    
  --PolicyNumber in (                        
  --select PolicyNumber from [db-au-cmdwh].[dbo].penPolicy where AlphaCode in ('BGD0001','BGD0002','BGD0003')                         
  --and convert(date,IssueDate,103)=convert(date,getdate()-1,103)                      
  --union                      
  --select distinct a.PolicyNumber from [db-au-cmdwh].[dbo].penPolicy as a inner join [db-au-cmdwh].[dbo].penPolicyTransaction                      
  --as b on a.PolicyKey=b.PolicyKey  where AlphaCode in ('BGD0001','BGD0002','BGD0003') and convert(date,b.IssueDate,103)=convert(date,getdate()-1,103))                      
  --AlphaCode in ('BGD0001','BGD0002','BGD0003') and convert(date,IssueDate,103)=convert(date,getdate()-1,103)                        
 )m                                           
                                                     
outer apply (                                                           
    select distinct n1.commission,n1.newpolicycount,n1.BasePremium,n1.SingleFamilyFlag,n1.AdultsCount,n1.ChildrenCount,           n1.TravellersCount,PostingDate,PolicyTransactionKey,GrossPremium,n1.PolicyKey from [db-au-cmdwh].[dbo].penPolicyTransSummary 
  
    
     
         
          
            
              
                
                  
n1  with (nolock)                     
 where m.PolicyKey=n1.PolicyKey )n                                                          
                                                                    
outer apply (                                                                
  select distinct o1.policytravellerkey,o1.Title,o1.FirstName,o1.LastName,o1.EmailAddress,o1.MobilePhone,o1.State,o1.DOB,o1.Age,PostCode,o1.PolicyKey,     o1.AddressLine1+' '+o1.AddressLine2+' '+o1.Suburb AS PolicyHolder_Address,                      
              
                
                  
                              
(select min(DOB) as OldestTraveller_DOB from [db-au-cmdwh].[dbo].penPolicyTraveller as c with (nolock) where c.PolicyKey=o1.PolicyKey and CountryKey='AU'     and CompanyKey='TIP' group by PolicyID)                                                        
  as OldestTraveller_DOB ,                                                      
  (select max(AGE) as OldestTraveller_AGE from [db-au-cmdwh].[dbo].penPolicyTraveller as c with (nolock) where c.PolicyKey=o1.PolicyKey and CountryKey='AU'                                                         
  and CompanyKey='TIP' group by PolicyID)                                                        
  as OldestTraveller_Age                                                       
  from [db-au-cmdwh].[dbo].penPolicyTraveller o1  with (nolock)                                                                
  where m.PolicyKey=o1.PolicyKey and isPrimary='1' )o                                                                
                                                                
  outer apply (                                                                
    select distinct p1.PolicyTransactionID ,p1.TransactionType,p1.PolicyTransactionKey,p1.TransactionStatus,p1.TransactionDateTime,p1.PolicyKey                          
 from [db-au-cmdwh].[dbo].penPolicyTransaction p1  with (nolock)                                                                
  where m.PolicyKey=p1.PolicyKey and n.PolicyTransactionKey=p1.PolicyTransactionKey)p                                                                
                                                                
  outer apply (                                                                
   select distinct y1.AlphaCode,y1.OutletName,y1.Channel, y1.subgroupname                                                from  [db-au-cmdwh].[dbo].penOutlet y1  with (nolock)                                                                
  where m.CountryKey=y1.CountryKey and m.CompanyKey=y1.CompanyKey and m.OutletAlphaKey=y1.OutletAlphaKey and m.OutletSKey=y1.OutletSKey)y                 outer apply (                                                                
    select distinct t1.PromoCode,t1.Discount,t1.PromoName,t1.PromoType,t1.PolicyTransactionKey                                                                
    from [db-au-cmdwh].[dbo].penPolicyTransactionPromo t1  with (nolock)                                                                
  where t1.PolicyNumber=m.PolicyNumber and t1.CountryKey = 'AU' AND t1.CompanyKey = 'TIP')t                                                             
                              
  outer apply ( select sum(ppp.GrossPremium) 'AdventureActivities_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='ADVACT' then 'Yes' else 'No' End as AdventureActivities_Flag                                                      
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyAddOn pao with (nolock) on ppp.ComponentID = pao.PolicyAddOnID                                                      
 join [db-au-cmdwh].[dbo].penPolicyTransaction ppt with (nolock) on pao.PolicyTransactionKey = ppt.PolicyTransactionKey                                                      
 where ppt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'ADVACT'                                                      
 group by pao.DisplayName,pao.AddOnCode)s           
                                                       
   outer apply ( select sum(ppp.GrossPremium) 'Motorcycle_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='MTCLTWO' then 'Yes' else 'No' End as Motorbike_Flag                                                      
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyAddOn pao with (nolock) on ppp.ComponentID = pao.PolicyAddOnID                                                      
 join [db-au-cmdwh].[dbo].penPolicyTransaction ppt with (nolock) on pao.PolicyTransactionKey = ppt.PolicyTransactionKey                                                  
 where ppt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'MTCLTWO'                                                      
 group by pao.DisplayName,pao.AddOnCode)s1                                                        
                                                            
  outer apply ( select sum(ppp.GrossPremium) 'Cruise_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='CRS' then 'Yes' else 'No' End as Cruise_Flag                                                      
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                      
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                    
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                      
 where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'CRS'                                                      
 group by pao.DisplayName,pao.AddOnCode) u                                                      
                                                      
 outer apply ( select sum(ppp.GrossPremium) 'Cancellation_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='CANX' then 'Yes' else 'No' End as Cancellation_Flag            
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                      
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                      
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                      
 where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'CANX'                                                      
 group by pao.DisplayName,pao.AddOnCode) o1                                                      
                                                      
 outer apply ( select sum(ppp.GrossPremium) 'Covid_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='COVCANX' then 'Yes' else 'No' End as Covid_Flag                                                      
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                      
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                      
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                      
 where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'COVCANX'                         
 group by pao.DisplayName,pao.AddOnCode) o2                                                      
                                                      
 outer apply ( select sum(ppp.GrossPremium) 'Luggage_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='LUGG' then 'Yes' else 'No' End as Luggage_Flag             
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                      
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                      
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                      
 where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'LUGG'                                                      
 group by pao.DisplayName,pao.AddOnCode) o3                            
                                                      
 outer apply ( select sum(ppp.GrossPremium) 'SnowSports_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='SNSPRTS' then 'Yes' else 'No' End as SnowSports_Flag                                     
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                      
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                      
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                      
 where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'SNSPRTS'                                                      
 group by pao.DisplayName,pao.AddOnCode) o4                                                      
                                                      
 outer apply ( select sum(ppp.GrossPremium) 'PEMC_Premium',CASE WHEN pptt.HasEMC = 1 then 'Yes' else 'No' End as 'PEMC_Flag'                                                      
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp join [db-au-cmdwh].[dbo].penPolicyEMC ppe on ppp.ComponentID = ppe.PolicyEMCID and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and ppp.GroupID = 5 and ppp.isPOSDiscount = 1                      
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt on ppe.PolicyTravellerTransactionKey = pptt.PolicyTravellerTransactionKey and pptt.HasEMC = 1                                                      
 where pptt.PolicyTravellerKey = o.PolicyTravellerKey                             
 group by pptt.HasEMC) o5                                                       
                                                       
 outer apply( select sum([Sell Price]) 'Total_Premium',sum([GST on Sell Price]) 'GST_on_Total_Premium',sum([Stamp Duty on Sell Price]) 'Stamp_Duty_on_Total_Premium',sum(NAP) 'NAP'                                                      
 from [db-au-cmdwh].[dbo].vPenguinPolicyPremiums ppp with (nolock)                                                                
  where ppp.PolicyTransactionKey=n.PolicyTransactionKey                                                          
 ) q 
GO
