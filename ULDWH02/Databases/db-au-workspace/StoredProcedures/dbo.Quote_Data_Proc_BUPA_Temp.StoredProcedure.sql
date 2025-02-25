USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[Quote_Data_Proc_BUPA_Temp]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




                                                           
                                                                                                           
CREATE PROCEDURE [dbo].[Quote_Data_Proc_BUPA_Temp]  --'2024-02-12'  

                                                                               
@StartDate datetime                                                                                  
as                                                                                                
select distinct                                               
m.PolicyNumber as [Policy_Number],                                              
Quote_Date,                                                                                                                                        
a.SESSIONID as Lead_Number,                                                                                                                                      
ISNULL(gclid,'') as GCLID,                                                                                                                                      
ISNULL(gaClientID,'') as GA_Client_ID,                                                                                                                                      
 CONVERT(varchar(500),Yz.LinkID collate SQL_Latin1_General_CP1_CI_AS)   as Link_ID,                                                                                                                                      
'' as [Marketing_Opt_Out],                                                                                                                                        
                                                                                                                                                                          
replace(Country_list,',',';') as [Travel_Countries_List],                                                                                                    
'' as [Primary_Country],                                                                                                                                     
len(Country_list) - len(replace(Country_list, ',', '')) +1 as Number_of_Countries,                                                                                                                 
replace(Region_List,',','') as  Region_List,                                                                                                                                       
Departure_Date,                                                                                                                                        
Return_Date,                                                                                                                                                                             
datediff(DAY,Departure_Date,Return_Date)+1 AS Trip_Duration,                                                                                                                                                    
cast(ISNULL(m.Excess,'') as decimal(10,4))   AS Excess_Amount,    
I.ProductName AS [Plan_Type_Name],                                                                                                                                      
CASE                                                                                                                   
WHEN ProductName='Comprehensive' AND convert(VARCHAR(300),CANXCoverageAmount)='1.00' THEN '10000'                                                                                                                   
WHEN ProductName='Essential' AND convert(VARCHAR(300),CANXCoverageAmount)='1.00' THEN '5000'                                                                                                                  
WHEN  convert(VARCHAR(300),CANXCoverageAmount)='-1.00' THEN 'Unlimited' else  convert(varchar(50),CANXCoverageAmount)  end                                         
AS  Cancellation_Sum_Insured,                               
case when HasCRS=1 then 'Yes' else 'No' END as Cruise_Flag,                                  
                             
--case                            
--when HasADVACT=1 then 'Adventure Activities'                                                                      
--when HasADVACT2=1 then 'Adventure Activities +'                                  
--when HasADVACT=0 and HasADVACT2=0 then 'No'                                                         
--end as Adventure_Activities_Flag,                                              
                                                  
case when m.PolicyNumber is not null then ISNULL([AdventureActivities_Flag],'No') else                                                   
case                                                                      
when HasADVACT=1 then 'Adventure'                                                                      
when HasADVACT2=1 then 'Adventure+'                                                                      
when HasADVACT=0 and HasADVACT2=0 then 'No'                                            
end end as Adventure_Activities_Flag,                                                  
case                                                    
when HasMTCL=1 then 'Motorcycle / Moped Riding'                                               
when HasMTCLTWO=1 then 'Motorcycle / Moped Riding +'                                                                      
when HasMTCL=0 and HasMTCLTWO=0 then 'No' end                                                                      
as Motorbike_Flag,                                                                              
case                                                                       
when HasSNSPRTS=1 then 'Snow Sports'                                                                      
when HasSNSPRTS2=1 then 'Snow Sports +'                                                                      
when HasSNSPRTS=0 and HasSNSPRTS2=0 then 'No' end as Snow_Sports_Flag,                                                                                                                                        
case                                                                       
when HasLUGG=1 then 'Yes'                                                                      
when HasLUGG=0 then 'No' end                                                                      
as Luggage_Flag,                                                                       
case when                                                                       
HasEMC=1 then 'Yes' else 'No' ENd as PEMC_Flag,                                                                                             
case when m.PolicyNumber is not null then isnull(O2.Covid_Flag,'No') else 'No' end as Covid_Flag,                                                                   
cast(ISNULL(z22.GrossPremium,'') as decimal(10,4)) AS Quoted_Base_Premium,                                                                                            
cast(ISNULL(Cancellation_Premium,'') as decimal(10,4)) AS Quoted_Cancellation_Premium,                                                                                                    
cast(ISNULL(o4.SnowSports_Premium,'') as decimal(10,4)) AS Quoted_Snow_Sports_Premium,                                                                                                                                 
cast(ISNULL(s.AdventureActivities_Premium,'')as decimal(10,4)) AS Quoted_Adventure_Activities_Premium,                            
cast(ISNULL(s1.Motorcycle_Premium,'')as decimal(10,4)) AS Quoted_Motorcycle_Premium,                                                
cast(ISNULL(o3.Luggage_Premium,'')as decimal(10,4)) AS Quoted_Luggage_Premium,       
cast(ISNULL(PEMC_Premium,'')as decimal(10,4)) AS Quoted_PEMC_Premium,                                                                                                                
cast(ISNULL(Covid_Premium,'')as decimal(10,4))  AS Quoted_Covid_Premium,                    
cast(ISNULL(u.Cruise_Premium,'')as decimal(10,4)) AS Quoted_Cruise_Premium,                                                                                     
cast(ISNULL(q.Total_Premium,'')as decimal(10,4)) AS Total_Quoted_Premium,                                  
CASE WHEN m.PolicyNumber IS NULL THEN A.TotalGrossPremium ELSE                                                                                                
cast(ISNULL(n.Total_Gross_Premium,'')as decimal(10,4)) END AS Total_Quoted_Gross_Premium,                                                                                                                          
q.NAP AS NAP,                                                                                                     
convert(varchar(500),replace(o.Title,',',' ')) AS Policy_Holder_Title,                                                                                                                             
convert(varchar(500),replace(o.FirstName,',',' ')) AS Policy_Holder_First_Name,                                                                                                                                      
convert(varchar(500),replace(o.LastName,',',' ')) AS  Policy_Holder_Surname,                                                                                                                                      
o.EmailAddress AS  Policy_Holder_Email,                                                                                                                                      
o.MobilePhone AS  Policy_Holder_Mobile_Phone,                                                                                                                                      
replace(o.PolicyHolder_Address,',','') AS   Policy_Holder_Address,                                                            
o.DOB as Policy_Holder_DOB,                                                                                                               
o.Age as Policy_Holder_Age,                                                                                                                                      
o.State AS Policy_Holder_State,                                                                                                                                
OldestTraveller_DOB AS Oldest_Traveller_DOB,                                                                     
OldestTraveller_Age AS Oldest_Traveller_Age,                                                                                                          
DefaultAffiliateCode AS Agency_Code,                                                                                        
'Bupa'  AS Agency_Name,                                                                                                                                      
'Bupa' AS Brand,                                                                                                                                      
case                                                                   
when DefaultAffiliateCode='BPN0001' Then 'Call Centre'                                                                   
when DefaultAffiliateCode='BPN0002' Then 'Online'                                                                                                                                     
End                                                                  
as Channel_Type,                                                      
                                                                  
                                                                  
isnull(Prmocode_list,'') AS Promotional_Code,                                     
    
    
isnull(case when A.PromoCodeListID!='-1' then                                   
 convert(varchar(50),convert(decimal(5,2),isnull(convert(varchar(30),case when A.PromoCodeListID!='-1'                                               
then (TotalGrossPremium-TotalAdjustedGrossPremium)/TotalGrossPremium*100 end),'')))+' % Discount' end,'')         
AS Promotional_Factor ,      
    
    
    
    
convert(varchar(150),E.SessionToken) AS [Session_Token]                                                                                                        
                  
                                                                                                  
FROM(                                                                                                                                
SELECT convert(date,dbo.xfn_ConvertUTCtoLocal(b.Date+''+c.StandardTime,'E. Australia Standard TIme'),103) as Quote_Date,* from [db-au-stage].dbo.cdg_factQuote_AU_AG AS A1 WITH (NOLOCK)
inner join [db-au-stage].dbo.cdg_dimdate_au_AG                      
as b WITH (NOLOCK) on A1.QuoteTransactionDateID=b.DimDateID inner join  [db-au-stage].dbo.cdg_dimTime_AU as c WITH (NOLOCK) on a1.QuoteTransactionTimeID=c.DimTimeID                          
WHERE BusinessUnitID=146 AND CampaignID=362 and convert(date,dbo.xfn_ConvertUTCtoLocal(b.Date+''+c.StandardTime,'E. Australia Standard TIme'),103)=convert(date,@StartDate,103)                                                            
--and quotetransactiondateid in (                            
--select dimdateid  from  [db-au-stage].dbo.cdg_dimdate_au_AG                             
--where convert(date,date,103)=convert(date,@StartDate,103))                           
                        
                            
                            
) AS A                                                                                                                                   
OUTER APPLY                                                                                  
(SELECT B1.Date AS Departure_Date FROM  [db-au-stage].dbo.cdg_dimdate_au_AG AS B1  WITH (NOLOCK)                                
WHERE  A.TripStartDateID=B1.DimDateID ) AS B                                                                                                                                       
OUTER APPLY (SELECT C1.Date as Return_Date FROM  [db-au-stage].dbo.cdg_dimdate_au_AG AS C1   WITH (NOLOCK)                                                                                                                                    
WHERE  A.TripEndDateID=C1.DimDateID ) AS C                                                                        
OUTER APPLY                                                                                                                                      
(SELECT D1.Date AS QuotedDate FROM  [db-au-stage].dbo.cdg_dimDate_AU_AG AS D1  WITH (NOLOCK)                                                                                                                                    
WHERE  A.QuoteTransactionDateID=D1.DimDateID) AS D                                                                                                                                
OUTER APPLY                                                                                                        
(SELECT SessionID,SessionToken FROM [db-au-stage].dbo.cdg_factSession_AU_AG AS E1    WITH (NOLOCK)                                                                                                                   
WHERE SessionID=FactSessionID ) AS E                                                                                                                                  
OUTER APPLY(SELECT DimCampaignID,CampaignName,DefaultAffiliateCode,DefaultCultureCode FROM [db-au-stage].dbo.cdg_DimCampaign_AU_AG as F1    WITH (NOLOCK)                                                                                                                  
  
    
       
       
          
            
              
               
where CampaignID=f1.DimCampaignID ) as F                  
OUTER APPLY                                                                                                                                      
(select  RegionName as Region_List from  [db-au-stage].dbo.cdg_DimRegion_AU_AG as G1    WITH (NOLOCK)                                                                                                                                   
where RegionID =g1.DimRegionID) as G                                                                                                                          
OUTER APPLY                                                                                                    
(                                                      
SELECT * FROM (                                                          
SELECT B.DimCovermoreCountryListID,b.SessionID,b.FactQuoteID,              
STUFF((select ','+CONVERT(VARCHAR(30),CovermoreCountryName) from (                                                                        
SELECT SessionID,FactQuoteID,DimCovermoreCountryListID,COUNTRYID,CovermoreCountryName FROM (                                                
SELECT  SessionID,FactQuoteID,DimCovermoreCountryListID,CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,CMCountryID7,                                                      
CMCountryID8,CMCountryID9,CMCountryID10 FROM  [db-au-stage].dbo.cdg_factQuote_AU_AG                                                                                                
AS A WITH (NOLOCK) INNER JOIN [db-au-stage].dbo.cdg_dimCovermoreCountryList_AU_AG AS B WITH (NOLOCK) ON A.DestCovermoreCountryListID=B.DimCovermoreCountryListID) AS A                                                                                                                     
 
     
     
         
         
            
              
                
                  
UNPIVOT                        
(                                                                                        
COUNTRYID FOR                                                                                                                                      
COUNTRY IN (CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,CMCountryID7,CMCountryID8,CMCountryID9,CMCountryID10)                                  
) AS A INNER JOIN [db-au-stage].dbo.cdg_dimCovermoreCountry_AU_AG AS B WITH (NOLOCK) ON COUNTRYID=B.DimCovermoreCountryID                                                                
WHERE COUNTRYID<>'-1') AS A WHERE A.DimCovermoreCountryListID=B.DimCovermoreCountryListID                                                
and  a.SessionID=b.SessionID and a.FactQuoteID=b.FactQuoteID  FOR XML PATH('')),1,1,'') AS Country_list                                                                                                                  
FROM                                                                   
(                                                                                                
SELECT SessionID,FactQuoteID,DimCovermoreCountryListID,COUNTRYID,CovermoreCountryName FROM (                                                                                                                                      
SELECT  SessionID,FactQuoteID,DimCovermoreCountryListID,CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,                                                                                                                        
CMCountryID7,                                                                                                                                      
CMCountryID8,CMCountryID9,CMCountryID10 FROM  [db-au-stage].dbo.cdg_factQuote_AU_AG                                                           
AS A WITH (NOLOCK) INNER JOIN [db-au-stage].dbo.cdg_dimCovermoreCountryList_AU_AG AS B WITH (NOLOCK) ON A.DestCovermoreCountryListID=B.DimCovermoreCountryListID) AS A                                  
                 
UNPIVOT                                                                 
(                                                                                                                                 
COUNTRYID FOR                                                                           
COUNTRY IN (CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,CMCountryID7,CMCountryID8,CMCountryID9,                                                                                                                
CMCountryID10)                                                                                                                  
) AS A INNER JOIN [db-au-stage].dbo.cdg_dimCovermoreCountry_AU_AG AS B WITH (NOLOCK) ON COUNTRYID=B.DimCovermoreCountryID                                              
WHERE COUNTRYID<>'-1'                                                                                                                                      
) AS B GROUP BY B.DimCovermoreCountryListID,b.SessionID,b.FactQuoteID) AS H1                                                                                                                                      
WHERE H1.SessionID=A.SessionID AND H1.FactQuoteID=A.FactQuoteID ) AS H                                                   
OUTER APPLY                                                                                                                                      
(                                                               
SELECT DimProductID,ProductCode,PlanCode,ProductName,TripFrequency FROM [db-au-stage].dbo.cdg_DimProduct_AU_AG AS I1 WITH (NOLOCK)                            
WHERE A.ProductID=I1.DimProductID                                                                                                                                      
) I                                                                                                                                      
OUTER APPLY                                                                                          
                                                                                               
(                                                                                                                                      
SELECT * FROM (                                                                                           
SELECT B.PromoCodeListID,b.SessionID,b.FactQuoteID,STUFF((select ','+CONVERT(VARCHAR(30),Code) from (                                                                                                
SELECT SessionID,FactQuoteID,PromoCodeListID,PromoCodeID,PromoCode,Code,Type,CampaignID FROM (                                                                                                                                  
SELECT  SessionID,FactQuoteID,PromoCodeListID,PromoCodeID1,PromoCodeID2,PromoCodeID3,PromoCodeID4 FROM                                                  
[db-au-stage].dbo.cdg_factQuote_AU_AG                                                                                                             
AS A WITH (NOLOCK) INNER JOIN [db-au-stage].dbo.cdg_dimPromoCodeList_AU_AG AS B WITH (NOLOCK) ON A.PromoCodeListID=B.DimPromoCodeListID) AS A                                                                                                        
UNPIVOT                                                                                
(                                                                                                                                      
PromoCodeID FOR                                                                                                         
PromoCode IN (PromoCodeID1,PromoCodeID2,PromoCodeID3,PromoCodeID4)                                                          
) AS A INNER JOIN [db-au-stage].dbo.cdg_dimPromocode_AU_AG AS B WITH (NOLOCK) ON PromoCodeID=B.DimPromoCodeID                                                                                                 
WHERE PromoCodeID<>'-1') AS A WHERE A.PromoCodeListID=B.PromoCodeListID                                                                  
and  a.SessionID=b.SessionID and a.FactQuoteID=b.FactQuoteID  FOR XML PATH('')),1,1,'') AS Prmocode_list                                                                                                                               
FROM                                                                                          
(                                                                         
SELECT SessionID,FactQuoteID,PromoCodeListID,PromoCodeID,PromoCode,Code,Type,CampaignID FROM (                                                                                                                                      
SELECT  SessionID,FactQuoteID,PromoCodeListID,PromoCodeID1,PromoCodeID2,PromoCodeID3,PromoCodeID4 FROM                                                                         
[db-au-stage].dbo.cdg_factQuote_AU_AG                                                                                                                                  
AS A WITH (NOLOCK) INNER JOIN [db-au-stage].dbo.cdg_dimPromoCodeList_AU_AG AS B WITH (NOLOCK) ON A.PromoCodeListID=B.DimPromoCodeListID ) AS A                                                                                            
UNPIVOT                                                                                                                                
(                                                                                                      
PromoCodeID FOR                                                                                                                                      
PromoCode IN (PromoCodeID1,PromoCodeID2,PromoCodeID3,PromoCodeID4)                                                                                                                                   
) AS A INNER JOIN [db-au-stage].dbo.cdg_dimPromocode_AU_AG AS B WITH (NOLOCK) ON PromoCodeID=B.DimPromoCodeID                                                                                                                                     
WHERE PromoCodeID<>'-1'                                                                                                                 
) AS B GROUP BY B.PromoCodeListID,b.SessionID,b.FactQuoteID) AS J1                                                                                                                                      
WHERE J1.SessionID=A.SessionID AND J1.FactQuoteID=A.FactQuoteID                                                        
)J                                                                                                                                    
                                                                                            
OUTER APPLY                                                                                                                                     
(                                                  
select k1.factpolicyid,k1.policynumber,k1.sessionid,k1.contactid,HasEMC from [db-au-stage].dbo.cdg_factPolicy_AU_AG as k1 WITH (NOLOCK)                                                                            
where a.sessionid=k1.sessionid                                  
) k                                                                                                           
                                                                                                                            
OUTER APPLY                                                                      
(                                                                                                      
SELECT DimGroupTypeID,GroupTypeName,GroupTypeNameShort FROM [db-au-stage].dbo.cdg_dimGroupType_AU_AG AS Y1X   WITH (NOLOCK)                                                                                                                    
WHERE Y1X.DimGroupTypeID=A.GroupTypeID                                                                                              
)  AS YX                                  
                                
OUTER APPLY                                
(            
select  DISTINCT  
json_value([PartnerMetaData],'$.LinkID') as LinkID,
json_value([PartnerMetaData],'$.gclid') as gclid,  
json_value([PartnerMetaData],'$.gaClientID') as gaClientID  
  
,Sessiontoken from [db-au-stage].dbo.cdg_SessionPartnerMetaData_AU_AG                                 
as Y2X  WITH (NOLOCK) WHERE y2x.Sessiontoken=e.SessionToken AND  
SessionToken IN (

SELECT SessionToken from [db-au-stage].dbo.cdg_factQuote_AU_AG AS A1  WITH (NOLOCK) inner join [db-au-stage].dbo.cdg_dimdate_au_AG                      
as b  WITH (NOLOCK) on A1.QuoteTransactionDateID=b.DimDateID inner join  [db-au-stage].dbo.cdg_dimTime_AU as c  WITH (NOLOCK)  on a1.QuoteTransactionTimeID=c.DimTimeID 
inner join  [db-au-stage].dbo.cdg_factsession_AU_AG AS D  WITH (NOLOCK) ON A1.SESSIONID=D.FACTSESSIONID                   
WHERE A1.BusinessUnitID=146 AND A1.CampaignID=362 and convert(date,dbo.xfn_ConvertUTCtoLocal(b.Date+''+c.StandardTime,'E. Australia Standard TIme'),103)=convert(date,@StartDate,103)) AND
 PartnerMetaData like '%LinkID%gclid%gaClientID%'                                
) AS YZ                                
                                                                                                                           
OUTER APPLY                                                                                                       
(select distinct CompanyKey,countrykey,PolicyNumber,PolicyID,PolicyKey,OutletAlphaKey,OutletSKey,IssueDate,PrimaryCountry as Destination,        Area,Excess,TripCost,PlanName,AreaCode,AreaName,AreaNumber,AreaType,TripStart,TripEnd,                               
                                  
datediff(day,TripStart,TripEnd)+1 as Trip_Duration,TripType,PlanCode,datediff(day,IssueDate,TripStart)  as [Days_To_Departure] ,MultiDestination,CancellationCover,ExternalReference1  
from [db-au-cmdwh].[dbo].penPolicy as M1  with (nolock)                 
  
    
      
        
          
            
              
                
                                                     
where  AlphaCode in ('BPN0001','BPN0002') and                                                                                                                                 
  k.PolicyNumber collate SQL_Latin1_General_CP1_CI_AS =m1.PolicyNumber                  
  and convert(date,IssueDate,103)=convert(date,@StartDate,103)              
  --PolicyNumber in (                                                                              
  --select PolicyNumber from [db-au-cmdwh].[dbo].penPolicy where AlphaCode in ('BPN0001','BPN0002')                                                                                                          
  --and convert(date,IssueDate,103)=convert(date,getdate()-1,103)                                                                             
  --union                                                                                                                                  
  --select distinct a.PolicyNumber from [db-au-cmdwh].[dbo].penPolicy as a inner join [db-au-cmdwh].[dbo].penPolicyTransaction                                                            
  --as b on a.PolicyKey=b.PolicyKey  where AlphaCode in ('BPN0001','BPN0002') and convert(date,b.IssueDate,103)=convert(date,getdate()-1,103))                                                                                                       
  
    
      
        
          
            
             
                
                   
                    
                      
                        
                          
                           
 --AlphaCode in ('BPN0001','BPN0002') and convert(date,IssueDate,103)=convert(date,getdate()-1,103)                                                                                                                                    
 )m                                                                                                   
                                                                                                
                           
outer apply (                                          
    select distinct n1.commission,n1.newpolicycount,n1.BasePremium,n1.SingleFamilyFlag,n1.AdultsCount,n1.ChildrenCount,           n1.TravellersCount,PostingDate,PolicyTransactionKey,n1.PolicyKey,                                  
 isnull(GrossPremium-TaxAmountGST-TaxAmountSD,'') as Total_Gross_Premium ,GrossPremium,TaxAmountGST,TaxAmountSD                                  
                                   
                                   
 from [db-au-cmdwh].[dbo].penPolicyTransSummary                                   
                                    
                                      
                                                           
  n1  with (nolock)                                                                                 
 where m.PolicyKey=n1.PolicyKey and TransactionType='Base' and  TransactionStatus='Active')n                                                                
                                                               
 outer apply                                                              
 (                                                              
 select PolicyKey,GrossPremium,BasePremium from(                                                                  
  select tptx.PolicyKey,sum(tpp.GrossPremium) as GrossPremium,sum(BasePremium) as BasePremium  FROM   [db-au-cmdwh].[dbo].penPolicyPrice   tpp  with (nolock)                                                                  
      INNER JOIN [db-au-cmdwh].[dbo].penPolicyTravellerTransaction  tptt with (nolock) ON   tptt.PolicyTravellerTransactionID = tpp.ComponentID                                                                  
   and tpp.CountryKey=tptt.CountryKey and tpp.CompanyKey=tptt.CompanyKey                       
       INNER JOIN [db-au-cmdwh].[dbo].penPolicyTraveller tpt with (nolock) ON   tpt.PolicyTravellerkey = tptt.PolicyTravellerkey              
    and tptt.CountryKey=tpt.CountryKey and tptt.CompanyKey=tpt.CompanyKey                                                                  
       INNER JOIN [db-au-cmdwh].[dbo].penPolicyTransaction tptx with (nolock) ON   tptx.policytransactionkey = tptt.policytransactionkey                                                                  
    and tpt.CountryKey=tptx.CountryKey and tpt.CompanyKey=tptx.CompanyKey                                                                  
       WHERE     tpp.groupid=2 and isPOSDiscount=1 and tpp.CompanyKey='TIP'                                                             
    group by tptx.PolicyKey) as z11 where z11.PolicyKey=m.PolicyKey                                           
  ) z22                                                               
                                                            
                                                                                                           
outer apply (                                                                                                                                                                            
  select distinct o1.policytravellerkey,o1.Title,o1.FirstName,o1.LastName,o1.EmailAddress,o1.MobilePhone,o1.State,o1.DOB,o1.Age,PostCode,o1.PolicyKey,   o1.AddressLine1+' '+o1.AddressLine2+' '+o1.Suburb AS PolicyHolder_Address,                           
   
   
       
       
          
             
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                                         
                                                                                                                                       
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
   select distinct y1.AlphaCode,y1.OutletName,y1.Channel, y1.subgroupname     from  [db-au-cmdwh].[dbo].penOutlet y1  with (nolock)                                                                                                                            
  
    
     
        
           
            
              
                
                  
                    
                     
                         
                         
                    
                                                                                           
  where m.CountryKey=y1.CountryKey and m.CompanyKey=y1.CompanyKey and m.OutletAlphaKey=y1.OutletAlphaKey and m.OutletSKey=y1.OutletSKey and OutletStatus='Current')y                 outer apply (                                
                    
                      
                        
                          
                           
                               
                           
                                  
                                    
                                      
                                        
                                             
                                                       
    select distinct t1.PromoCode,t1.Discount,t1.PromoName,t1.PromoType,t1.PolicyTransactionKey                                                                                                                                           
    from [db-au-cmdwh].[dbo].penPolicyTransactionPromo t1  with (nolock)                                                                                                          
  where t1.PolicyNumber=m.PolicyNumber and t1.CountryKey = 'AU' AND t1.CompanyKey = 'TIP')t                                                                                                                                       
    
     
                                                                                   
  outer apply ( select sum(ppp.GrossPremium) 'AdventureActivities_Premium',pao.AddonValueDesc,                                                                          
  CASE WHEN pao.AddOnCode='ADVACT' then pao.AddonValueDesc else 'No' End as AdventureActivities_Flag                                                                                                                                            
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyAddOn pao with (nolock) on ppp.ComponentID = pao.PolicyAddOnID                                                                                                   
   
    
      
        
          
            
              
               
                   
                    
                      
                        
                          
                            
                              
                           
                                  
 join [db-au-cmdwh].[dbo].penPolicyTransaction ppt with (nolock) on pao.PolicyTransactionKey = ppt.PolicyTransactionKey                                            
 where ppt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in ('ADVACT','ADVACT2','ADVACT3','ADVACT4')                                      
  
    
      
        
          
            
              
                
                  
                    
                     
                         
          
                            
                              
                                                                                     
 group by pao.AddonValueDesc,pao.AddOnCode)s                                                                                                        
                                                                                                                                                   
   outer apply ( select sum(ppp.GrossPremium) 'Motorcycle_Premium',pao.DisplayName,                                                        
   CASE WHEN pao.AddOnCode in ('MTCLTWO','MTCL') then pao.DisplayName else 'No' End as Motorbike_Flag                                                                       
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyAddOn pao with (nolock) on ppp.ComponentID = pao.PolicyAddOnID                  
 join [db-au-cmdwh].[dbo].penPolicyTransaction ppt with (nolock) on pao.PolicyTransactionKey = ppt.PolicyTransactionKey                                                                   
 where ppt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in( 'MTCLTWO' ,'MTCL')                                                           
  
    
      
       
          
             
              
                
                  
                    
                      
                        
                         
                            
                               
                                
                                  
                                    
                 
                                                    
                                                                      
                                                                        
                                                                               
 group by pao.DisplayName,pao.AddOnCode)s1                                                                                                                                             
                                                     
  outer apply ( select sum(ppp.GrossPremium) 'Cruise_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='CRS' then 'Yes' else 'No' End as Cruise_Flag                                                                                                            
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                                
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                             
                                      
                                        
                                          
                                            
                                              
                                               
      
                                                    
                                                                          
                                                          
                                                            
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                                                                                        
  
    
      
        
          
            
              
                
                  
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                  
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                 
 where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in( 'CRS','CRS','CRS2' )                                                        
  
    
     
         
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                 
 group by pao.DisplayName,pao.AddOnCode) u           
                        
 outer apply (  select sum(ppp.GrossPremium) 'Cancellation_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='CANX' then 'Yes' else 'No' End as Cancellation_Flag                                                                                               
  
    
      
       
           
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                                        
                                    
                                      
                                        
                                          
                                            
                                             
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
                                                                                    
 outer apply (  select sum(ppp.GrossPremium) 'Luggage_Premium',pao.AddonName,CASE WHEN pao.AddOnCode='LUGG' then 'Yes' else 'No' End as Luggage_Flag                                                                                             
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                               
   
    
      
       
           
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                                                                   
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                                           
 where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'LUGG'                                                                        
  
    
      
        
          
            
              
                
                  
                    
                     
                         
                          
                            
                              
                                
                                  
                                    
                                      
                                       
                                           
                                            
        
                                               
                                                   
                                                    
                                                      
                                                        
                                                          
                                                            
                                                             
                                                                 
                                                                  
                                            
 group by pao.AddonName,pao.AddOnCode) o3                                                                                                  
                                                                                                                                    
 outer apply ( select sum(ppp.GrossPremium) 'SnowSports_Premium',pao.AddonName,CASE WHEN pao.AddOnCode in ('SNSPRTS','SNSPRTS2','SNSPRTS3','WNTS') then pao.AddonName else 'No' End as SnowSports_Flag                                                         
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                         
                             
                              
                                
                                  
                                    
                                      
                                        
                                          
                                            
                                              
                                                
                                                  
                                                    
                                                      
                    
                                                          
                                                    
                                                           
                                                                
                                                                 
                                                                   
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                
                                                
                                                  
                                                    
                                                      
                                                        
                                                          
                                                            
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                                                               
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                                                          
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
 where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode  in ('SNSPRTS','SNSPRTS2','SNSPRTS3','WNTS')                                    
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                                      
                          
                                          
                                           
                                              
 group by pao.AddonName,pao.AddOnCode) o4                                                                                                                     
                                                                                                                           
 outer apply ( select sum(ppp.GrossPremium) 'PEMC_Premium',CASE WHEN pptt.HasEMC = 1 then 'Yes' else 'No' End as 'PEMC_Flag'                                                                                                          
from [db-au-cmdwh].[dbo].penPolicyPrice ppp join [db-au-cmdwh].[dbo].penPolicyEMC ppe on ppp.ComponentID = ppe.PolicyEMCID and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and ppp.GroupID = 5 and ppp.isPOSDiscount = 1                                  
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                   
                                       
                       
                                          
                                            
                                              
                                                
                                                 
                
                                     
                                                        
                                                         
                                                            
                                                               
                                                               
                                                                                                  
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt on ppe.PolicyTravellerTransactionKey = pptt.PolicyTravellerTransactionKey and pptt.HasEMC = 1                                                       
 where pptt.PolicyTravellerKey = o.PolicyTravellerKey                                                                                                                                            
 group by pptt.HasEMC) o5                                                                                                       
                                
 outer apply( select sum([Sell Price]) 'Total_Premium',sum([GST on Sell Price]) 'GST_on_Total_Premium',sum([Stamp Duty on Sell Price]) 'Stamp_Duty_on_Total_Premium',sum(NAP) 'NAP'                
      
        
          
            
              
               
                   
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                                     
                                         
                                          
                                            
                                              
                                                
                                                 
                                                   
                                                      
                                              
 from [db-au-cmdwh].[dbo].vPenguinPolicyPremiums ppp with (nolock)                                                                                                                                          
  where ppp.PolicyTransactionKey=n.PolicyTransactionKey                                                                                              
 ) q                                                                                                 
 union -- Pengion Quotes                                                                                          
 select                                                
 PolicyNumber as [Policy_Number],                    
CreateDate as Quote_Date,                                                                             
QuoteID as Lead_Number,                                                                                                  
'' as GCLID,                                                                                          
'' as GA_Client_ID,                                                                           
isnull(ExternalReference1,'') as LinkID,                                                                                                                                      
'' as [Marketing Opt-Out],                                                                            
                                                                                           
replace(a2.MultiDestination,',',';') as [TravelCountries_List],                                                                                         
'' as [Primary_Country],                                                                                                                                     
len(a2.MultiDestination) - len(replace(a2.MultiDestination, ',', '')) +1 as Number_of_Countries,                                                                                                                        
replace(a2.Area,',','') COLLATE Latin1_General_CI_AS as Region_List ,                                                                               
DepartureDate as Departure_Date,                                                                                                                                        
ReturnDate as Return_Date,                                                                                                      
datediff(DAY,DepartureDate,ReturnDate)+1 AS Trip_Duration,                                                                                                                                         
cast(ISNULL(a2.Excess,'')as decimal(10,4))  AS Excess_Amount,    
a2.PlanName as [Plan_Type_Name],                                                                                    
ISNULL(CASE                                                                                                                   
WHEN A2.PlanName='Comprehensive' AND convert(VARCHAR(300),r3.AddOnItem)='1' THEN '10000'                                             
WHEN A2.PlanName='Essential' AND convert(VARCHAR(300),r3.AddOnItem)='1' THEN '5000'                                                                            
WHEN  convert(VARCHAR(300),r3.AddOnItem)='-1' THEN 'Unlimited'                                      
else convert(VARCHAR(300),r3.AddOnItem) end ,0)                                                                                                                
AS  CancellationSumInsured,                                                                                                                                     
isnull(r14.Cruise_Flag,'No') as Cruise_Flag,                                                                                                                  
isnull(r22.AdventureActivities_Flag,'No') as  AdventureActivities_Flag ,                                                                                                   
isnull(case when m.PolicyNumber is not null then s1.Motorbike_Flag else  r18.Motorbike_Flag end,'No') as Motorbike_Flag ,                                                                                                                    
isnull(r20.SnowSports_Flag,'No') as SnowSports_Flag ,                                                                                                         
isnull(r16.Luggage_Flag,'No') as Luggage_Flag ,                                                 
isnull(HasEMC,'No') as PEMC_Flag,                                                                                                                                        
isnull(r12.Covid_Flag, 'No') as Covid_Flag,                                                                                                                                         
cast(ISNULL(z23.GrossPremium,'')as decimal(10,4)) AS Quoted_Base_Premium,                                                                                                                                      
cast(ISNULL(Cancellation_Premium,'')as decimal(10,4)) AS Quoted_Cancellation_Premium,                                            
cast(ISNULL(o4.SnowSports_Premium,'')as decimal(10,4)) AS Quoted_SnowSports_Premium,                                                                                                                                      
cast(ISNULL(s.AdventureActivities_Premium,'')as decimal(10,4)) AS Quoted_AdventureActivities_Premium,                                                 
cast(ISNULL(s1.Motorcycle_Premium,'')as decimal(10,4)) AS Quoted_Motorcycle_Premium,                                                
cast(ISNULL(o3.Luggage_Premium,'')as decimal(10,4)) AS Quoted_Luggage_Premium,                                                             
cast(ISNULL(PEMC_Premium,'')as decimal(10,4)) AS Quoted_PEMC_Premium,                                                                                                                                      
cast(ISNULL(Covid_Premium,'')as decimal(10,4)) AS Quoted_Covid_Premium,                                                                                                                                      
cast(ISNULL(u.Cruise_Premium,'')as decimal(10,4)) AS Quoted_Cruise_Premium,                                                                                                             
cast(ISNULL(q.Total_Premium,'')as decimal(10,4)) AS Total_Quoted_Premium,                                                                                                                                                            
CASE WHEN m.PolicyNumber IS NULL THEN a2.GrossPremium ELSE                                
cast(ISNULL(n.Total_Gross_Premium,'')as decimal(10,4)) END AS Total_Quoted_Gross_Premium,                        
q.NAP AS NAP,                                                                                                                                      
replace(o.Title,',',' ') AS Policyholder_Title,                                                                            
replace(o.FirstName,',',' ') AS Policyholder_First_Name,                                                                                                                                      
replace(o.LastName,',',' ') AS  Policyholder_Surname,                                                                       
o.EmailAddress AS  Policyholder_Email,                                                            
o.MobilePhone AS  Policyholder_Mobile_Phone,                                                                       
replace(o.PolicyHolder_Address,',','') AS   Policyholder_Address,                                                                                          
o.DOB as PolicyHolder_DOB,                                                                                                                                      
o.Age as PolicyHolder_Age,                                                                                                                                      
o.State AS Policyholder_State,                                                                                                                                      
OldestTraveller_DOB,                                                                                                                                      
OldestTraveller_Age,                                                                           
y1.AlphaCode collate Latin1_General_CI_AS AS Agency_Code ,                                           
'Bupa' collate  Latin1_General_CI_AS AS Agency_Name,                                                                                                                   
'Bupa' collate   Latin1_General_CI_AS AS Brand,                   
case                                                                   
when y1.AlphaCode collate Latin1_General_CI_AS='BPN0001' Then 'Call Centre'                                                                   
when y1.AlphaCode collate Latin1_General_CI_AS='BPN0002' Then 'Online'                                                                   
                                                         
End                                                                  
as Channel_Type,                                                                                                                            
isnull(r.PromoCode,'') AS Promotional_Code,                                                                                                    
isnull(convert(varchar(100),r.Discount)+'% Discount','') AS Promotional_Factor,                                                                                                    
SessionID AS [Session Token]                                                                                     
                                                                                                  
                                                                                                
FROM (                                                                                                  
SELECT CreateDate,A.QuoteID,PolicyKey,DepartureDate,ReturnDate,MultiDestination,a.Area,OutletAlphaKey,a.QuoteCountryKey,SessionID,                                                                                                             
b.GrossPremium,b.Excess,b.PlanDisplayName as PlanName                                                                              
from [db-au-cmdwh].[dbo].penQuote as a with (nolock) inner join  [db-au-cmdwh].[dbo].penQuoteSelectedPlan              
as b on a.QuoteCountryKey=b.QuoteCountryKey  and b.GrossPremium!='0.00'              
              
              
 where AgencyCode in ('BPN0001','BPN0002')                                                                                                            
and convert(date,CreateDate,103)=convert(date,@StartDate,103)    
    
    
    
)                                                         
as a2                                                             
                                                                            
outer apply                      
(                                                                                  
select distinct y2.AlphaCode,y2.OutletName,y2.Channel from   [db-au-cmdwh].[dbo].penOutlet y2 with (nolock)                                                                                                          
where y2.OutletAlphaKey=a2.OutletAlphaKey and  OutletStatus='Current'                                                                                                           
 )y1                                
outer apply                                        
(                                                                                                          
select r1.PromoCode,r1.Discount from  [db-au-cmdwh].[dbo].penQuotePromo r1 with (nolock)                                                                                                          
where r1.QuoteCountryKey = a2.QuoteCountryKey                                            
)r                                                                                                   
outer apply                                                                 
(                                                                                                          
                                                      
select QuoteCountryKey,case when convert(varchar(30),AddOnItem) like '%-%' then 'Unlimited' else convert(varchar(30),AddOnItem)                                                      
 end as AddOnItem  from (                                                      
select R2.QuoteCountryKey,                                                      
sum(convert(int,case when  AddOnItem='$Unlimited' then '-100' else REPLACE(REPLACE(AddOnItem,'$',''),',','') end))                                                   
as AddOnItem from  [db-au-cmdwh].[dbo].penQuoteAddOn r2                                        
 INNER JOIN  [db-au-cmdwh].[dbo].penQuote AS R3 with (nolock)    ON R2.QuoteCountryKey=r3.QuoteCountryKey                                                       
 where                                                       
 AddOnGroup='Cancellation' and r2.QuoteCountryKey = R3.QuoteCountryKey                                                          
 and AgencyCode in ('BPN0001','BPN0002')                                                      
                                                      
group by r2.QuoteCountryKey  ) as a  where  a.QuoteCountryKey=a2.QuoteCountryKey                                                    
                                                      
                                                      
)r3         
                                                                                                  
outer apply                                                                        
 (                                                                        
select distinct                 QuoteCountryKey,                                                                        
case when AddOnGroup='COVID-19 Cover' then 'Yes' end  'Covid_Flag'                                                               
from [db-au-cmdwh].[dbo].penQuoteAddOn as r11 where r11.QuoteCountryKey=a2.QuoteCountryKey                                                                        
and AddOnGroup='COVID-19 Cover') as r12                                              
outer apply                                                                        
(                                                                        
select distinct                                                                         
QuoteCountryKey,                                                                        
case when AddOnGroup in ('Cruise','Cruise Cover2') then 'Yes' end  'Cruise_Flag'                                                                        
from [db-au-cmdwh].[dbo].penQuoteAddOn as r13 where r13.QuoteCountryKey=a2.QuoteCountryKey                                                                        
and AddOnGroup in ('Cruise','Cruise Cover2')                                                                        
) as r14                                                                        
outer apply                                                                        
(                               
select distinct                                                                         
QuoteCountryKey,                                                                        
case when AddOnGroup in ('Luggage') then 'Yes' end  'Luggage_Flag'                                                                        
from [db-au-cmdwh].[dbo].penQuoteAddOn as r15 where r15.QuoteCountryKey=a2.QuoteCountryKey                                                                        
and AddOnGroup in ('Luggage')                                                                        
) as r16                                                                        
outer apply                                                           
(                              
select distinct                                                                         
QuoteCountryKey,                                                                        
case when AddOnGroup in ('Motorcycle') then AddOnName end  'Motorbike_Flag'                                              
from [db-au-cmdwh].[dbo].penQuoteAddOn as r17 where r17.QuoteCountryKey=a2.QuoteCountryKey                                                                        
and AddOnGroup in ('Motorcycle')                                                                        
) as r18                                                                        
outer apply                                                                        
(      select distinct                         
QuoteCountryKey,                                                                 
case when AddOnGroup in ('Snow Sports','Snow Sports +','Snow Sports3','Winter Sport') then AddOnName end  'SnowSports_Flag'                                                                        
from [db-au-cmdwh].[dbo].penQuoteAddOn as r19 where r19.QuoteCountryKey=a2.QuoteCountryKey                                                                        
and AddOnGroup in ('Snow Sports','Snow Sports +','Snow Sports3','Winter Sport')                        
) as r20                                                                        
outer apply                                                                        
(                         
select distinct                                                                     
QuoteCountryKey,                                                                        
case when AddOnGroup in ('Adventure Activities 2','Adventure Activities3') then AddOnName end  'AdventureActivities_Flag'                                                                        
from [db-au-cmdwh].[dbo].penQuoteAddOn as r21 where r21.QuoteCountryKey=a2.QuoteCountryKey                                                                        
and AddOnGroup in ('Adventure Activities 2','Adventure Activities3')                                                                        
) as r22                                                                        
                                                                                   
                    
outer apply                                                                                    
(                                                                                    
                  
select QuoteCountryKey,case when Total=No_Count then 'No' else 'Yes' end as HasEMC from (                  
 select QuoteCountryKey,count(*) as Total,                  
 count(case when HasEMC=1 then QuoteCountryKey end) as Yes_Count,                  
 count(case when HasEMC=0 then QuoteCountryKey end) as No_Count                  
 from [db-au-cmdwh].[dbo].penQuoteCustomer                    
 group by QuoteCountryKey) as a where a2.QuoteCountryKey=a.QuoteCountryKey                  
                  
) as z                                                                                    
                                                                                                  
outer apply                                                                                                  
(select distinct CompanyKey,countrykey,PolicyNumber,PolicyID,PolicyKey,OutletAlphaKey,OutletSKey,IssueDate,PrimaryCountry as Destination,        Area,Excess,TripCost,PlanName,AreaCode,AreaName,AreaNumber,AreaType,TripStart,TripEnd,                       
  
    
                                 
                                                 
datediff(day,TripStart,TripEnd)+1 as Trip_Duration,TripType,PlanCode,datediff(day,IssueDate,TripStart)  as [Days_To_Departure] ,MultiDestination,CancellationCover,ExternalReference1  from [db-au-cmdwh].[dbo].penPolicy as M1  with (nolock)                 
  
    
                                            
where  AlphaCode in ('BPN0001','BPN0002') and                                                                                                                                 
  a2.PolicyKey collate SQL_Latin1_General_CP1_CI_AS =m1.PolicyKey  and m1.PlanName=a2.PlanName               
  and  convert(date,IssueDate,103)=convert(date,@StartDate,103)                 
  --PolicyNumber in (                                                      
  --select PolicyNumber from [db-au-cmdwh].[dbo].penPolicy where AlphaCode in ('BPN0001','BPN0002')                                                                                                                                     
  --and convert(date,IssueDate,103)=convert(date,getdate()-1,103)                                                                                                                                  
  --union                                                                                  
  --select distinct a.PolicyNumber from [db-au-cmdwh].[dbo].penPolicy as a inner join [db-au-cmdwh].[dbo].penPolicyTransaction                                                                                                                       
  --as b on a.PolicyKey=b.PolicyKey  where AlphaCode in ('BPN0001','BPN0002') and convert(date,b.IssueDate,103)=convert(date,getdate-1,103)                                                                     
 )m          
                                                                                 
outer apply (                                                                                                          
    select distinct n1.commission,n1.newpolicycount,n1.BasePremium,n1.SingleFamilyFlag,n1.AdultsCount,n1.ChildrenCount,     n1.TravellersCount,PostingDate,PolicyTransactionKey,GrossPremium,n1.PolicyKey,                                  
 isnull(GrossPremium-TaxAmountGST-TaxAmountSD,'') as Total_Gross_Premium ,TaxAmountGST,TaxAmountSD                                  
                                   
 from [db-au-cmdwh].[dbo].penPolicyTransSummary                                                  
                                                                                                   
n1  with (nolock)                                                         
 where m.PolicyKey=n1.PolicyKey and TransactionType='Base' and TransactionStatus='Active' )n                                                               
                                                               
 outer apply                                                              
 (                                                              
 select PolicyKey,GrossPremium,BasePremium from(                                                                  
  select tptx.PolicyKey,sum(tpp.GrossPremium) as GrossPremium,sum(BasePremium) as BasePremium  FROM   [db-au-cmdwh].[dbo].penPolicyPrice   tpp  with (nolock)                                                                  
      INNER JOIN [db-au-cmdwh].[dbo].penPolicyTravellerTransaction  tptt with (nolock) ON   tptt.PolicyTravellerTransactionID = tpp.ComponentID                                                              
   and tpp.CountryKey=tptt.CountryKey and tpp.CompanyKey=tptt.CompanyKey             
       INNER JOIN [db-au-cmdwh].[dbo].penPolicyTraveller tpt with (nolock) ON   tpt.PolicyTravellerkey = tptt.PolicyTravellerkey                          
    and tptt.CountryKey=tpt.CountryKey and tptt.CompanyKey=tpt.CompanyKey                                                                  
       INNER JOIN [db-au-cmdwh].[dbo].penPolicyTransaction tptx with (nolock) ON   tptx.policytransactionkey = tptt.policytransactionkey                                                                  
    and tpt.CountryKey=tptx.CountryKey and tpt.CompanyKey=tptx.CompanyKey                                                                  
       WHERE     tpp.groupid=2 and isPOSDiscount=0 and tpp.CompanyKey='TIP'                                                                  
    group by tptx.PolicyKey) as z13 where z13.PolicyKey=m.PolicyKey                                                                 
  ) z23                                                               
                       
                                                                 
outer apply (                                                                                                                                                            
  select distinct o1.policytravellerkey,o1.Title,o1.FirstName,o1.LastName,o1.EmailAddress,o1.MobilePhone,o1.State,o1.DOB,o1.Age,PostCode,o1.PolicyKey,     o1.AddressLine1+' '+o1.AddressLine2+' '+o1.Suburb AS PolicyHolder_Address,                         
   
   
       
       
           
           
              
                 
                 
                    
                      
                         
                          
                            
                             
                                
                                   
                                   
                                       
                                        
                                          
                                           
                                               
                                                                                              
                                                                                                                                        
(select min(DOB) as OldestTraveller_DOB from [db-au-cmdwh].[dbo].penPolicyTraveller as c with (nolock) where c.PolicyKey=o1.PolicyKey and CountryKey='AU'     and CompanyKey='TIP' group by PolicyID)                                   as OldestTraveller_DOB 
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                    
                                        
                                          
                                            
                                              
                                               
                          
                                                     
                                                      
                                                        
                                                          
                                                    
                                                              
                                                                
                                   
                                                                                           
,                                                                         
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
   select distinct y1.AlphaCode,y1.OutletName,y1.Channel, y1.subgroupname    from  [db-au-cmdwh].[dbo].penOutlet y1  with (nolock)                                                                                            
  where m.CountryKey=y1.CountryKey and m.CompanyKey=y1.CompanyKey and m.OutletAlphaKey=y1.OutletAlphaKey and m.OutletSKey=y1.OutletSKey and OutletStatus='Current')y   outer apply (                                                      
                                                                    
                                             
                                              
                                                
                                                  
                                                    
                                                      
                                                       
                                                          
                                                            
                                                                                    
    select distinct t1.PromoCode,t1.Discount,t1.PromoName,t1.PromoType,t1.PolicyTransactionKey                                                                                      
    from [db-au-cmdwh].[dbo].penPolicyTransactionPromo t1  with (nolock)                                                                                                                                                          
  where t1.PolicyNumber=m.PolicyNumber and t1.CountryKey = 'AU' AND t1.CompanyKey = 'TIP')t                                                                                       
                                              
  outer apply ( select sum(ppp.GrossPremium) 'AdventureActivities_Premium',pao.AddonValueDesc,                                                                          
  CASE WHEN pao.AddOnCode='ADVACT' then pao.AddonValueDesc else 'No' End as AdventureActivities_Flag                                                                                                                                            
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyAddOn pao with (nolock) on ppp.ComponentID = pao.PolicyAddOnID                                                       
                                     
                                         
 join [db-au-cmdwh].[dbo].penPolicyTransaction ppt with (nolock) on pao.PolicyTransactionKey = ppt.PolicyTransactionKey                                                                           
 where ppt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in ('ADVACT','ADVACT2','ADVACT3','ADVACT4')                                      
  
    
     
         
         
            
               
                
                  
                    
                      
                        
                         
                            
                               
                                
                                 
                                     
                                      
                                        
                                          
          
                               
                                                 
                                                  
                                                    
                                                     
                                                       
                                                          
                                                            
                                                              
                                                               
                                                                   
                                                                   
                       
                                                                       
                                                                                                       
 group by pao.AddonValueDesc,pao.AddOnCode)s                                            
                                                                                                                            
   outer apply ( select sum(ppp.GrossPremium) 'Motorcycle_Premium',pao.DisplayName,                                                                          
   CASE WHEN pao.AddOnCode in ('MTCLTWO','MTCL') then pao.DisplayName else 'No' End as Motorbike_Flag                                     
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyAddOn pao with (nolock) on ppp.ComponentID = pao.PolicyAddOnID                                
                                
                                  
                                    
                                      
                                        
 join [db-au-cmdwh].[dbo].penPolicyTransaction ppt with (nolock) on pao.PolicyTransactionKey = ppt.PolicyTransactionKey                                                                                                   
 where ppt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in( 'MTCLTWO' ,'MTCL')                                                           
 
     
     
         
          
            
              
               
                   
                    
                     
                         
                          
                           
                               
                                
                                  
                                    
                                      
                                        
                                          
                                            
                   
                                                
                                                  
                                                    
                                                                      
                                                                        
                                 
 group by pao.DisplayName,pao.AddOnCode)s1                                                                                                                                                   
                                                              
  outer apply (  select sum(ppp.GrossPremium) 'Cruise_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='CRS' then 'Yes' else 'No' End as Cruise_Flag                                                                                                           
  
    
      
        
          
            
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                                
  
    
      
        
          
            
              
                
                  
                    
      
                        
                          
                            
                              
                                
                                  
                                    
                                     
                                         
                                      
                                           
                                               
                                                
                                                  
                                                    
                                                      
                
                                                          
                                                            
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                                                                                        
  
    
      
        
          
            
              
                
                  
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                            
 where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in( 'CRS','CRS','CRS2' )                                                        
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
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
                                                                                                 
 outer apply ( select sum(ppp.GrossPremium) 'Luggage_Premium',pao.AddonName,CASE WHEN pao.AddOnCode='LUGG' then 'Yes' else 'No' End as Luggage_Flag       
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                                
  
   
       
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
              
                                  
                                    
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                               
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                              
 where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'LUGG'                                                                        
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                 
                                     
                                      
                                        
                                                                
                                                          
                                                                     
 group by pao.AddonName,pao.AddOnCode) o3                                                
                                                                                                                                                                  
 outer apply ( select sum(ppp.GrossPremium) 'SnowSports_Premium',pao.AddonName,CASE WHEN pao.AddOnCode in ('SNSPRTS','SNSPRTS2','SNSPRTS3','WNTS') then pao.AddonName else 'No' End as SnowSports_Flag                                                         
  
    
      
        
          
            
              
                
                 
                     
                      
                        
                          
                            
                              
                                
                                  
                                    
          
                                        
                                          
                                            
                                             
                         
                                                 
                           
                                                       
                                                        
                                                         
                                                            
                                                               
                                                               
                                                                   
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                                
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                 
                                  
                                    
                                      
                                        
                                          
                                            
                                              
                                                
                                                  
                                                    
                          
                                                        
                                                          
                          
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                                                                                        
  
    
     
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                                                          
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                      
                             
                                
                                  
 where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode  in ('SNSPRTS','SNSPRTS2','SNSPRTS3','WNTS')                                    
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                          
                                
                                  
                                    
                                      
                                        
                                         
                                             
                                             
 group by pao.AddonName,pao.AddOnCode) o4                                                                                                                    
                                                                                                                                                                  
 outer apply ( select sum(ppp.GrossPremium) 'PEMC_Premium',CASE WHEN pptt.HasEMC = 1 then 'Yes' else 'No' End as 'PEMC_Flag'                                                                                                                                   
  
    
      
        
         
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp join [db-au-cmdwh].[dbo].penPolicyEMC ppe on ppp.ComponentID = ppe.PolicyEMCID and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and ppp.GroupID = 5 and ppp.isPOSDiscount = 1                                 
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                             
                                 
          
                                    
                                      
                                        
                                          
                                            
                                              
                                                
                                                  
                                                    
                                                      
                                                   
                                                     
                                                            
                       
                                                               
                                                                                                  
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt on ppe.PolicyTravellerTransactionKey = pptt.PolicyTravellerTransactionKey and pptt.HasEMC = 1                                                                                                     
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                                      
                                       
 where pptt.PolicyTravellerKey = o.PolicyTravellerKey                                                                                
 group by pptt.HasEMC) o5                                                                                                                                                                   
                                                                                                                                                                   
 outer apply( select sum([Sell Price]) 'Total_Premium',sum([GST on Sell Price]) 'GST_on_Total_Premium',sum([Stamp Duty on Sell Price]) 'Stamp_Duty_on_Total_Premium',sum(NAP) 'NAP'                                                                            
  
    
      
        
          
            
              
                
                  
                    
                      
                                                 
                                                                                     
 from [db-au-cmdwh].[dbo].vPenguinPolicyPremiums ppp with (nolock)            
  where ppp.PolicyTransactionKey=n.PolicyTransactionKey                                                                                               
 ) q     

 -- Missing Data Impulse Quotes

 union

 select distinct                                               
m.PolicyNumber as [Policy_Number],                                              
Quote_Date,                                                                                                                                        
a.SESSIONID as Lead_Number,                                                                                                                                      
ISNULL(gclid,'') as GCLID,                                                                                                                                      
ISNULL(gaClientID,'') as GA_Client_ID,                                                                                                                                      
case when m.policynumber is not null then  isnull(ExternalReference1,'')                                
else CONVERT(varchar(500),Yz.LinkID collate SQL_Latin1_General_CP1_CI_AS) end  as Link_ID,                                                                                                                                      
'' as [Marketing_Opt_Out],                                                                                                                                        
                                                                                                                                                                          
replace(Country_list,',',';') as [Travel_Countries_List],                                                                                                    
'' as [Primary_Country],                                                                                                                                     
len(Country_list) - len(replace(Country_list, ',', '')) +1 as Number_of_Countries,                                                                                                                 
replace(Region_List,',','') as  Region_List,                                                                                                                                       
Departure_Date,                                                                                                                                        
Return_Date,                                                                                                                                                                             
datediff(DAY,Departure_Date,Return_Date)+1 AS Trip_Duration,                                                                                                                                                    
cast(ISNULL(m.Excess,'') as decimal(10,4))   AS Excess_Amount,    
I.ProductName AS [Plan_Type_Name],                                                                                                                                      
CASE                                                                                                                   
WHEN ProductName='Comprehensive' AND convert(VARCHAR(300),CANXCoverageAmount)='1.00' THEN '10000'                                                                                                                   
WHEN ProductName='Essential' AND convert(VARCHAR(300),CANXCoverageAmount)='1.00' THEN '5000'                                                                                                                  
WHEN  convert(VARCHAR(300),CANXCoverageAmount)='-1.00' THEN 'Unlimited' else  convert(varchar(50),CANXCoverageAmount)  end                                         
AS  Cancellation_Sum_Insured,                               
case when HasCRS=1 then 'Yes' else 'No' END as Cruise_Flag,                                  
                             
--case                            
--when HasADVACT=1 then 'Adventure Activities'                                                                      
--when HasADVACT2=1 then 'Adventure Activities +'                                  
--when HasADVACT=0 and HasADVACT2=0 then 'No'                                                         
--end as Adventure_Activities_Flag,                                              
                                                  
case when m.PolicyNumber is not null then ISNULL([AdventureActivities_Flag],'No') else                                                   
case                                                                      
when HasADVACT=1 then 'Adventure'                                                                      
when HasADVACT2=1 then 'Adventure+'                                                                      
when HasADVACT=0 and HasADVACT2=0 then 'No'                                            
end end as Adventure_Activities_Flag,                                                  
case                                                    
when HasMTCL=1 then 'Motorcycle / Moped Riding'                                               
when HasMTCLTWO=1 then 'Motorcycle / Moped Riding +'                                                                      
when HasMTCL=0 and HasMTCLTWO=0 then 'No' end                                                                      
as Motorbike_Flag,                                                                              
case                                                                       
when HasSNSPRTS=1 then 'Snow Sports'                                                                      
when HasSNSPRTS2=1 then 'Snow Sports +'                                                                      
when HasSNSPRTS=0 and HasSNSPRTS2=0 then 'No' end as Snow_Sports_Flag,                                                                                                                                        
case                                                                       
when HasLUGG=1 then 'Yes'                                                                      
when HasLUGG=0 then 'No' end                                                                      
as Luggage_Flag,                                                                       
case when                                                                       
HasEMC=1 then 'Yes' else 'No' ENd as PEMC_Flag,                                                                                             
case when m.PolicyNumber is not null then isnull(O2.Covid_Flag,'No') else 'No' end as Covid_Flag,                                                                   
cast(ISNULL(z22.GrossPremium,'') as decimal(10,4)) AS Quoted_Base_Premium,                                                                                            
cast(ISNULL(Cancellation_Premium,'') as decimal(10,4)) AS Quoted_Cancellation_Premium,                                                                                                    
cast(ISNULL(o4.SnowSports_Premium,'') as decimal(10,4)) AS Quoted_Snow_Sports_Premium,                                                                                                                                 
cast(ISNULL(s.AdventureActivities_Premium,'')as decimal(10,4)) AS Quoted_Adventure_Activities_Premium,                            
cast(ISNULL(s1.Motorcycle_Premium,'')as decimal(10,4)) AS Quoted_Motorcycle_Premium,                                                
cast(ISNULL(o3.Luggage_Premium,'')as decimal(10,4)) AS Quoted_Luggage_Premium,       
cast(ISNULL(PEMC_Premium,'')as decimal(10,4)) AS Quoted_PEMC_Premium,                                                                                                                
cast(ISNULL(Covid_Premium,'')as decimal(10,4))  AS Quoted_Covid_Premium,                    
cast(ISNULL(u.Cruise_Premium,'')as decimal(10,4)) AS Quoted_Cruise_Premium,                                                                                     
cast(ISNULL(q.Total_Premium,'')as decimal(10,4)) AS Total_Quoted_Premium,                                  
CASE WHEN m.PolicyNumber IS NULL THEN A.TotalGrossPremium ELSE                                                                                                
cast(ISNULL(n.Total_Gross_Premium,'')as decimal(10,4)) END AS Total_Quoted_Gross_Premium,                                                                                                                          
q.NAP AS NAP,                                                                                                     
convert(varchar(500),replace(o.Title,',',' ')) AS Policy_Holder_Title,                                                                                                                             
convert(varchar(500),replace(o.FirstName,',',' ')) AS Policy_Holder_First_Name,                                                                                                                                      
convert(varchar(500),replace(o.LastName,',',' ')) AS  Policy_Holder_Surname,                                                                                                                                      
o.EmailAddress AS  Policy_Holder_Email,                                                                                                                                      
o.MobilePhone AS  Policy_Holder_Mobile_Phone,                                                                                                                                      
replace(o.PolicyHolder_Address,',','') AS   Policy_Holder_Address,                                                            
o.DOB as Policy_Holder_DOB,                                                                                                               
o.Age as Policy_Holder_Age,                                                                                                                                      
o.State AS Policy_Holder_State,                                                                                                                                
OldestTraveller_DOB AS Oldest_Traveller_DOB,                                                                     
OldestTraveller_Age AS Oldest_Traveller_Age,                                                                                                          
DefaultAffiliateCode AS Agency_Code,                                                                                        
'Bupa'  AS Agency_Name,                                                                                                                                      
'Bupa' AS Brand,                                                                                                                                      
case                                                                   
when DefaultAffiliateCode='BPN0001' Then 'Call Centre'                                                                   
when DefaultAffiliateCode='BPN0002' Then 'Online'                                                                                                                                      
End                                                                  
as Channel_Type,                                                      
                                                                  
                                                                  
isnull(Prmocode_list,'') AS Promotional_Code,                                     
    
    
isnull(case when A.PromoCodeListID!='-1' then                                   
 convert(varchar(50),convert(decimal(5,2),isnull(convert(varchar(30),case when A.PromoCodeListID!='-1'                                               
then (TotalGrossPremium-TotalAdjustedGrossPremium)/TotalGrossPremium*100 end),'')))+' % Discount' end,'')         
AS Promotional_Factor ,      
    
    
    
    
convert(varchar(150),E.SessionToken) AS [Session_Token]                                                                                                        
                  
                                                                                                  
FROM(                                                                                                                                
SELECT convert(date,dbo.xfn_ConvertUTCtoLocal(b.Date+''+c.StandardTime,'E. Australia Standard TIme'),103) as Quote_Date,* from [db-au-stage].dbo.cdg_factQuote_AU_AG AS A1  WITH (NOLOCK) inner join [db-au-stage].dbo.cdg_dimdate_au_AG                      
as b  WITH (NOLOCK) on A1.QuoteTransactionDateID=b.DimDateID inner join  [db-au-stage].dbo.cdg_dimTime_AU as c  WITH (NOLOCK) on a1.QuoteTransactionTimeID=c.DimTimeID                          
WHERE BusinessUnitID=146 AND CampaignID=362 and 

SessionID in 
(
SELECT sessionid from [db-au-stage].dbo.cdg_factQuote_AU_AG AS A1  WITH (NOLOCK) inner join [db-au-stage].dbo.cdg_dimdate_au_AG     as b  WITH (NOLOCK) on A1.QuoteTransactionDateID=b.DimDateID inner join  [db-au-stage].dbo.cdg_dimTime_AU as c  on a1.QuoteTransactionTimeID=c.DimTimeID
     
     
                              
WHERE BusinessUnitID=146 AND CampaignID=362 and         
convert(date,dbo.xfn_ConvertUTCtoLocal(b.Date+''+c.StandardTime,'E. Australia Standard TIme'),103) between     
convert(date,@StartDate-7,103) and convert(date,@StartDate-1,103)        
Except        
select Lead_Number from [db-au-cmdwh]..Quote_Tbl_BUPA  WITH (NOLOCK)
)
                                                           
--and quotetransactiondateid in (                            
--select dimdateid  from  [db-au-stage].dbo.cdg_dimdate_au_AG                             
--where convert(date,date,103)=convert(date,@StartDate,103))                           
                        
                            
                            
) AS A                                                                                                                                   
OUTER APPLY                                                                                  
(SELECT B1.Date AS Departure_Date FROM  [db-au-stage].dbo.cdg_dimdate_au_AG AS B1  WITH (NOLOCK)                                 
WHERE  A.TripStartDateID=B1.DimDateID ) AS B                                                                                                                                       
OUTER APPLY (SELECT C1.Date as Return_Date FROM  [db-au-stage].dbo.cdg_dimdate_au_AG AS C1    WITH (NOLOCK)                                                                                                                                   
WHERE  A.TripEndDateID=C1.DimDateID ) AS C                                                                        
OUTER APPLY                                                                                                                                      
(SELECT D1.Date AS QuotedDate FROM  [db-au-stage].dbo.cdg_dimDate_AU_AG AS D1  WITH (NOLOCK)                                                                                                                                     
WHERE  A.QuoteTransactionDateID=D1.DimDateID) AS D                                                                                                                                
OUTER APPLY                                                                                                        
(SELECT SessionID,SessionToken FROM [db-au-stage].dbo.cdg_factSession_AU_AG AS E1   WITH (NOLOCK)                                                                                                                     
WHERE SessionID=FactSessionID ) AS E                                                                                                                                  
OUTER APPLY(SELECT DimCampaignID,CampaignName,DefaultAffiliateCode,DefaultCultureCode FROM [db-au-stage].dbo.cdg_DimCampaign_AU_AG as F1   WITH (NOLOCK)                                                                                                                    
  
    
       
       
          
            
              
               
where CampaignID=f1.DimCampaignID ) as F                  
OUTER APPLY                                                                                                                                      
(select  RegionName as Region_List from  [db-au-stage].dbo.cdg_DimRegion_AU_AG as G1   WITH (NOLOCK)                                                                                                                                     
where RegionID =g1.DimRegionID) as G                                                                                                                          
OUTER APPLY                                                                                                    
(                                                      
SELECT * FROM (                                                          
SELECT B.DimCovermoreCountryListID,b.SessionID,b.FactQuoteID,              
STUFF((select ','+CONVERT(VARCHAR(30),CovermoreCountryName) from (                                                                        
SELECT SessionID,FactQuoteID,DimCovermoreCountryListID,COUNTRYID,CovermoreCountryName FROM (                                                
SELECT  SessionID,FactQuoteID,DimCovermoreCountryListID,CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,CMCountryID7,                                                      
CMCountryID8,CMCountryID9,CMCountryID10 FROM  [db-au-stage].dbo.cdg_factQuote_AU_AG                                                                                                
AS A  WITH (NOLOCK) INNER JOIN [db-au-stage].dbo.cdg_dimCovermoreCountryList_AU_AG AS B  WITH (NOLOCK) ON A.DestCovermoreCountryListID=B.DimCovermoreCountryListID) AS A                                                                                                                     
 
     
     
         
         
            
              
                
                  
UNPIVOT                        
(                                                                                        
COUNTRYID FOR                                                                                                                                      
COUNTRY IN (CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,CMCountryID7,CMCountryID8,CMCountryID9,CMCountryID10)                                  
) AS A INNER JOIN [db-au-stage].dbo.cdg_dimCovermoreCountry_AU_AG AS B  WITH (NOLOCK) ON COUNTRYID=B.DimCovermoreCountryID                                                                
WHERE COUNTRYID<>'-1') AS A WHERE A.DimCovermoreCountryListID=B.DimCovermoreCountryListID                                                
and  a.SessionID=b.SessionID and a.FactQuoteID=b.FactQuoteID  FOR XML PATH('')),1,1,'') AS Country_list                                                                                                                  
FROM                                                                   
(                                                                                                
SELECT SessionID,FactQuoteID,DimCovermoreCountryListID,COUNTRYID,CovermoreCountryName FROM (                                                                                                                                      
SELECT  SessionID,FactQuoteID,DimCovermoreCountryListID,CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,                                                                                                                        
CMCountryID7,                                                                                                                                      
CMCountryID8,CMCountryID9,CMCountryID10 FROM  [db-au-stage].dbo.cdg_factQuote_AU_AG                                                           
AS A  WITH (NOLOCK) INNER JOIN [db-au-stage].dbo.cdg_dimCovermoreCountryList_AU_AG AS B  WITH (NOLOCK) ON A.DestCovermoreCountryListID=B.DimCovermoreCountryListID) AS A                                  
                 
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
AS A  WITH (NOLOCK) INNER JOIN [db-au-stage].dbo.cdg_dimPromoCodeList_AU_AG AS B  WITH (NOLOCK) ON A.PromoCodeListID=B.DimPromoCodeListID) AS A                                                                                                        
UNPIVOT                                                                                
(                                                                                                                                      
PromoCodeID FOR                                                                                                         
PromoCode IN (PromoCodeID1,PromoCodeID2,PromoCodeID3,PromoCodeID4)                                                          
) AS A INNER JOIN [db-au-stage].dbo.cdg_dimPromocode_AU_AG AS B  WITH (NOLOCK) ON PromoCodeID=B.DimPromoCodeID                                                                                                 
WHERE PromoCodeID<>'-1') AS A WHERE A.PromoCodeListID=B.PromoCodeListID                                                                  
and  a.SessionID=b.SessionID and a.FactQuoteID=b.FactQuoteID  FOR XML PATH('')),1,1,'') AS Prmocode_list                                                                                                                               
FROM                                                                                          
(                                                                         
SELECT SessionID,FactQuoteID,PromoCodeListID,PromoCodeID,PromoCode,Code,Type,CampaignID FROM (                                                                                                                                      
SELECT  SessionID,FactQuoteID,PromoCodeListID,PromoCodeID1,PromoCodeID2,PromoCodeID3,PromoCodeID4 FROM                                                                         
[db-au-stage].dbo.cdg_factQuote_AU_AG                                                                                                                                  
AS A  WITH (NOLOCK) INNER JOIN [db-au-stage].dbo.cdg_dimPromoCodeList_AU_AG AS B  WITH (NOLOCK) ON A.PromoCodeListID=B.DimPromoCodeListID ) AS A                                                                                            
UNPIVOT                                                                                                                                
(                                                                                                      
PromoCodeID FOR                                                                                                                                      
PromoCode IN (PromoCodeID1,PromoCodeID2,PromoCodeID3,PromoCodeID4)                                                                                                                                   
) AS A INNER JOIN [db-au-stage].dbo.cdg_dimPromocode_AU_AG AS B  WITH (NOLOCK) ON PromoCodeID=B.DimPromoCodeID                                                                                                                                     
WHERE PromoCodeID<>'-1'                                                                                                                 
) AS B GROUP BY B.PromoCodeListID,b.SessionID,b.FactQuoteID) AS J1                                                                                                                                      
WHERE J1.SessionID=A.SessionID AND J1.FactQuoteID=A.FactQuoteID                                                        
)J                                                                                                                                    
                                                                                            
OUTER APPLY                                                                                                                                     
(                                                  
select k1.factpolicyid,k1.policynumber,k1.sessionid,k1.contactid,HasEMC from [db-au-stage].dbo.cdg_factPolicy_AU_AG as k1  WITH (NOLOCK)                                                                           
where a.sessionid=k1.sessionid                                  
) k                                                                                                           
                                                                                                                            
OUTER APPLY                                                                      
(                                                                                                      
SELECT DimGroupTypeID,GroupTypeName,GroupTypeNameShort FROM [db-au-stage].dbo.cdg_dimGroupType_AU_AG AS Y1X  WITH (NOLOCK)                                                                                                                       
WHERE Y1X.DimGroupTypeID=A.GroupTypeID                                                                                              
)  AS YX                                  
                                
OUTER APPLY                                
(            
select   
json_value([PartnerMetaData],'$.LinkID') as LinkID,  
json_value([PartnerMetaData],'$.gclid') as gclid,  
json_value([PartnerMetaData],'$.gaClientID') as gaClientID  
  
,Sessiontoken from [db-au-stage].dbo.cdg_SessionPartnerMetaData_AU_AG                                 
as Y2X  WITH (NOLOCK) WHERE y2x.Sessiontoken=e.SessionToken AND  

SessionToken IN (

SELECT SessionToken from [db-au-stage].dbo.cdg_factQuote_AU_AG AS A1 inner join [db-au-stage].dbo.cdg_dimdate_au_AG                      
as b  WITH (NOLOCK) on A1.QuoteTransactionDateID=b.DimDateID inner join  [db-au-stage].dbo.cdg_dimTime_AU as c  WITH (NOLOCK)  on a1.QuoteTransactionTimeID=c.DimTimeID 
inner join  [db-au-stage].dbo.cdg_factsession_AU_AG AS D ON A1.SESSIONID=D.FACTSESSIONID                   
WHERE A1.BusinessUnitID=146 AND A1.CampaignID=362 
and convert(date,dbo.xfn_ConvertUTCtoLocal(b.Date+''+c.StandardTime,'E. Australia Standard TIme'),103) BETWEEN convert(date,@StartDate-7,103) and convert(date,@StartDate-1,103))


AND
 PartnerMetaData like '%LinkID%gclid%gaClientID%')                              AS YZ                                
                                                                                                                           
OUTER APPLY                                                                                                       
(select distinct CompanyKey,countrykey,PolicyNumber,PolicyID,PolicyKey,OutletAlphaKey,OutletSKey,IssueDate,PrimaryCountry as Destination,        Area,Excess,TripCost,PlanName,AreaCode,AreaName,AreaNumber,AreaType,TripStart,TripEnd,                       
                                
datediff(day,TripStart,TripEnd)+1 as Trip_Duration,TripType,PlanCode,datediff(day,IssueDate,TripStart)  as [Days_To_Departure] ,MultiDestination,CancellationCover,ExternalReference1  
from [db-au-cmdwh].[dbo].penPolicy as M1  with (nolock)                 
    
  
      
        
          
            
              
                
                                                     
where  AlphaCode in ('BPN0001','BPN0002') and                                                                                                                                 
  k.PolicyNumber collate SQL_Latin1_General_CP1_CI_AS =m1.PolicyNumber                  
  and convert(date,IssueDate,103)=convert(date,a.Quote_Date,103)              
  --PolicyNumber in (                                                                              
  --select PolicyNumber from [db-au-cmdwh].[dbo].penPolicy where AlphaCode in ('BPN0001','BPN0002')                                                                                                          
  --and convert(date,IssueDate,103)=convert(date,getdate()-1,103)                                                                             
  --union                                                                                                                                  
  --select distinct a.PolicyNumber from [db-au-cmdwh].[dbo].penPolicy as a inner join [db-au-cmdwh].[dbo].penPolicyTransaction                                                            
  --as b on a.PolicyKey=b.PolicyKey  where AlphaCode in ('BPN0001','BPN0002') and convert(date,b.IssueDate,103)=convert(date,getdate()-1,103))                                                                                                       
  
    
      
        
          
            
             
                
                   
                    
                      
                        
                          
                           
 --AlphaCode in ('BPN0001','BPN0002') and convert(date,IssueDate,103)=convert(date,getdate()-1,103)                                                                                                                                    
 )m                                                                                                   
                                                                                                
                           
outer apply (                                          
    select distinct n1.commission,n1.newpolicycount,n1.BasePremium,n1.SingleFamilyFlag,n1.AdultsCount,n1.ChildrenCount,           n1.TravellersCount,PostingDate,PolicyTransactionKey,n1.PolicyKey,                                  
 isnull(GrossPremium-TaxAmountGST-TaxAmountSD,'') as Total_Gross_Premium ,GrossPremium,TaxAmountGST,TaxAmountSD                                  
                                   
                                   
 from [db-au-cmdwh].[dbo].penPolicyTransSummary                                   
                                    
                                      
                                                           
  n1  with (nolock)                                                                                 
 where m.PolicyKey=n1.PolicyKey and TransactionType='Base' and  TransactionStatus='Active')n                                                                
                                                               
 outer apply                                                              
 (                                                              
 select PolicyKey,GrossPremium,BasePremium from(                                                                  
  select tptx.PolicyKey,sum(tpp.GrossPremium) as GrossPremium,sum(BasePremium) as BasePremium  FROM   [db-au-cmdwh].[dbo].penPolicyPrice   tpp  with (nolock)                                                                  
      INNER JOIN [db-au-cmdwh].[dbo].penPolicyTravellerTransaction  tptt with (nolock) ON   tptt.PolicyTravellerTransactionID = tpp.ComponentID                                                                  
   and tpp.CountryKey=tptt.CountryKey and tpp.CompanyKey=tptt.CompanyKey                       
       INNER JOIN [db-au-cmdwh].[dbo].penPolicyTraveller tpt with (nolock) ON   tpt.PolicyTravellerkey = tptt.PolicyTravellerkey              
    and tptt.CountryKey=tpt.CountryKey and tptt.CompanyKey=tpt.CompanyKey                                                                  
       INNER JOIN [db-au-cmdwh].[dbo].penPolicyTransaction tptx with (nolock) ON   tptx.policytransactionkey = tptt.policytransactionkey                                                                  
    and tpt.CountryKey=tptx.CountryKey and tpt.CompanyKey=tptx.CompanyKey                                                                  
       WHERE     tpp.groupid=2 and isPOSDiscount=1 and tpp.CompanyKey='TIP'                                                             
    group by tptx.PolicyKey) as z11 where z11.PolicyKey=m.PolicyKey                                           
  ) z22                                                               
                                                            
                                                                                                           
outer apply (                                                                                                                                                                            
  select distinct o1.policytravellerkey,o1.Title,o1.FirstName,o1.LastName,o1.EmailAddress,o1.MobilePhone,o1.State,o1.DOB,o1.Age,PostCode,o1.PolicyKey,   o1.AddressLine1+' '+o1.AddressLine2+' '+o1.Suburb AS PolicyHolder_Address,                           
   
   
       
       
          
             
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                                         
                                                                                                                                       
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
   select distinct y1.AlphaCode,y1.OutletName,y1.Channel, y1.subgroupname     from  [db-au-cmdwh].[dbo].penOutlet y1  with (nolock)                                                                                                                            
  
    
     
        
           
            
              
                
                  
                    
                     
                         
                         
                    
                                                                                           
  where m.CountryKey=y1.CountryKey and m.CompanyKey=y1.CompanyKey and m.OutletAlphaKey=y1.OutletAlphaKey and m.OutletSKey=y1.OutletSKey and OutletStatus='Current')y                 outer apply (                                
                    
                      
                        
                          
                           
                               
                           
                                  
                                    
                                      
                                        
                                             
                                                       
    select distinct t1.PromoCode,t1.Discount,t1.PromoName,t1.PromoType,t1.PolicyTransactionKey                                                                                                                                           
    from [db-au-cmdwh].[dbo].penPolicyTransactionPromo t1  with (nolock)                                                                                                          
  where t1.PolicyNumber=m.PolicyNumber and t1.CountryKey = 'AU' AND t1.CompanyKey = 'TIP')t                                                                                                                                       
    
     
                                                                                   
  outer apply ( select sum(ppp.GrossPremium) 'AdventureActivities_Premium',pao.AddonValueDesc,                                                                          
  CASE WHEN pao.AddOnCode='ADVACT' then pao.AddonValueDesc else 'No' End as AdventureActivities_Flag                                                                                                                                            
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyAddOn pao with (nolock) on ppp.ComponentID = pao.PolicyAddOnID                                                                                                   
   
    
      
        
          
            
              
               
                   
                    
                      
                        
                          
                            
                              
                           
                                  
 join [db-au-cmdwh].[dbo].penPolicyTransaction ppt with (nolock) on pao.PolicyTransactionKey = ppt.PolicyTransactionKey                                            
 where ppt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in ('ADVACT','ADVACT2','ADVACT3','ADVACT4')                                      
  
    
      
        
          
            
              
                
                  
                    
                     
                         
          
                            
                              
                                                                                     
 group by pao.AddonValueDesc,pao.AddOnCode)s                                                                                                        
                                                                                                                                                   
   outer apply ( select sum(ppp.GrossPremium) 'Motorcycle_Premium',pao.DisplayName,                                                        
   CASE WHEN pao.AddOnCode in ('MTCLTWO','MTCL') then pao.DisplayName else 'No' End as Motorbike_Flag                                                                       
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyAddOn pao with (nolock) on ppp.ComponentID = pao.PolicyAddOnID                  
 join [db-au-cmdwh].[dbo].penPolicyTransaction ppt with (nolock) on pao.PolicyTransactionKey = ppt.PolicyTransactionKey                                                                   
 where ppt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in( 'MTCLTWO' ,'MTCL')                                                           
  
    
      
       
          
             
              
                
                  
                    
                      
                        
                         
                            
                               
                                
                                  
                                    
                 
                                                    
                                                                      
                                                                        
                                                                               
 group by pao.DisplayName,pao.AddOnCode)s1                                                                                                                                             
                                                     
  outer apply ( select sum(ppp.GrossPremium) 'Cruise_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='CRS' then 'Yes' else 'No' End as Cruise_Flag                                                                                                            
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                                
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                             
                                      
                                        
                                          
                                            
                                              
                                               
      
                                                    
                                                                          
                                                          
                                                            
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                                                                                        
  
    
      
        
          
            
              
                
                  
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                  
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                 
 where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in( 'CRS','CRS','CRS2' )                                                        
  
    
     
         
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                 
 group by pao.DisplayName,pao.AddOnCode) u           
                        
 outer apply (  select sum(ppp.GrossPremium) 'Cancellation_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='CANX' then 'Yes' else 'No' End as Cancellation_Flag                                                                                               
  
    
      
       
           
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                                        
                                    
                                      
                                        
                                          
                                            
                                             
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
                                                                                    
 outer apply (  select sum(ppp.GrossPremium) 'Luggage_Premium',pao.AddonName,CASE WHEN pao.AddOnCode='LUGG' then 'Yes' else 'No' End as Luggage_Flag                                                                                             
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                               
   
    
      
       
           
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                                                                   
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                                           
 where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'LUGG'                                                                        
  
    
      
        
          
            
              
                
                  
                    
                     
                         
                          
                            
                              
                                
                                  
                                    
                                      
                                       
                                           
                                            
        
                                               
                                                   
                                                    
                                                      
                                                        
                                                          
                                                            
                                                             
                                                                 
                                                                  
                                            
 group by pao.AddonName,pao.AddOnCode) o3                                                                                                  
                                                                                                                                    
 outer apply ( select sum(ppp.GrossPremium) 'SnowSports_Premium',pao.AddonName,CASE WHEN pao.AddOnCode in ('SNSPRTS','SNSPRTS2','SNSPRTS3','WNTS') then pao.AddonName else 'No' End as SnowSports_Flag                                                         
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                         
                             
                              
                                
                                  
                                    
                                      
                                        
                                          
                                            
                                              
                                                
                                                  
                                                    
                                                      
                    
                                                          
                                                    
                                                           
                                                                
                                                                 
                                                                   
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                
                                                
                                                  
                                                    
                                                      
                                                        
                                                          
                                                            
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                                                               
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                                                          
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
 where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode  in ('SNSPRTS','SNSPRTS2','SNSPRTS3','WNTS')                                    
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                                      
                          
                                          
                                           
                                              
 group by pao.AddonName,pao.AddOnCode) o4                                                                                                                     
                                                                                                                           
 outer apply ( select sum(ppp.GrossPremium) 'PEMC_Premium',CASE WHEN pptt.HasEMC = 1 then 'Yes' else 'No' End as 'PEMC_Flag'                                                                                                          
from [db-au-cmdwh].[dbo].penPolicyPrice ppp join [db-au-cmdwh].[dbo].penPolicyEMC ppe on ppp.ComponentID = ppe.PolicyEMCID and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and ppp.GroupID = 5 and ppp.isPOSDiscount = 1                                  
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                   
                                       
                       
                                          
                                            
                                              
                                                
                                                 
                
                                     
                                                        
                                                         
                                                            
                                                               
                                                               
                                                                                                  
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt on ppe.PolicyTravellerTransactionKey = pptt.PolicyTravellerTransactionKey and pptt.HasEMC = 1                                                       
 where pptt.PolicyTravellerKey = o.PolicyTravellerKey                                                                                                                                            
 group by pptt.HasEMC) o5                                                                                                       
                                
 outer apply( select sum([Sell Price]) 'Total_Premium',sum([GST on Sell Price]) 'GST_on_Total_Premium',sum([Stamp Duty on Sell Price]) 'Stamp_Duty_on_Total_Premium',sum(NAP) 'NAP'                
      
        
          
            
              
               
                   
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                                     
                                         
                                          
                                            
                                              
                                                
                                                 
                                                   
                                                      
                                              
 from [db-au-cmdwh].[dbo].vPenguinPolicyPremiums ppp with (nolock)                                                                                                                                          
  where ppp.PolicyTransactionKey=n.PolicyTransactionKey                                                                                              
 ) q 

 union -- Missing Penguin Quotes


 select                                                
 PolicyNumber as [Policy_Number],                    
CreateDate as Quote_Date,                                                                             
QuoteID as Lead_Number,                                                                                                  
'' as GCLID,                                                                                          
'' as GA_Client_ID,                                                                           
isnull(ExternalReference1,'') as LinkID,                                                                                                                                      
'' as [Marketing Opt-Out],                                                                            
                                                                                           
replace(a2.MultiDestination,',',';') as [TravelCountries_List],                                                                                         
'' as [Primary_Country],                                                                                                                                     
len(a2.MultiDestination) - len(replace(a2.MultiDestination, ',', '')) +1 as Number_of_Countries,                                                                                                                        
replace(a2.Area,',','') COLLATE Latin1_General_CI_AS as Region_List ,                                                                               
DepartureDate as Departure_Date,                                                                                                                                        
ReturnDate as Return_Date,                                                                                                      
datediff(DAY,DepartureDate,ReturnDate)+1 AS Trip_Duration,                                                                                                                                         
cast(ISNULL(a2.Excess,'')as decimal(10,4))  AS Excess_Amount,    
a2.PlanName as [Plan_Type_Name],                                                                                    
ISNULL(CASE                                                                                                                   
WHEN A2.PlanName='Comprehensive' AND convert(VARCHAR(300),r3.AddOnItem)='1' THEN '10000'                                             
WHEN A2.PlanName='Essential' AND convert(VARCHAR(300),r3.AddOnItem)='1' THEN '5000'                                                                            
WHEN  convert(VARCHAR(300),r3.AddOnItem)='-1' THEN 'Unlimited'                                      
else convert(VARCHAR(300),r3.AddOnItem) end ,0)                                                                                                                
AS  CancellationSumInsured,                                                                                                                                     
isnull(r14.Cruise_Flag,'No') as Cruise_Flag,                                                                                                                  
isnull(r22.AdventureActivities_Flag,'No') as  AdventureActivities_Flag ,                                                                                                   
isnull(case when m.PolicyNumber is not null then s1.Motorbike_Flag else  r18.Motorbike_Flag end,'No') as Motorbike_Flag ,                                                                                                                    
isnull(r20.SnowSports_Flag,'No') as SnowSports_Flag ,                                                                                                         
isnull(r16.Luggage_Flag,'No') as Luggage_Flag ,                                                 
isnull(HasEMC,'No') as PEMC_Flag,                                                                                                                                        
isnull(r12.Covid_Flag, 'No') as Covid_Flag,                                                                                                                                         
cast(ISNULL(z23.GrossPremium,'')as decimal(10,4)) AS Quoted_Base_Premium,                                                                                                                                      
cast(ISNULL(Cancellation_Premium,'')as decimal(10,4)) AS Quoted_Cancellation_Premium,                                            
cast(ISNULL(o4.SnowSports_Premium,'')as decimal(10,4)) AS Quoted_SnowSports_Premium,                                                                                                                                      
cast(ISNULL(s.AdventureActivities_Premium,'')as decimal(10,4)) AS Quoted_AdventureActivities_Premium,                                                 
cast(ISNULL(s1.Motorcycle_Premium,'')as decimal(10,4)) AS Quoted_Motorcycle_Premium,                                                
cast(ISNULL(o3.Luggage_Premium,'')as decimal(10,4)) AS Quoted_Luggage_Premium,                                                             
cast(ISNULL(PEMC_Premium,'')as decimal(10,4)) AS Quoted_PEMC_Premium,                                                                                                                                      
cast(ISNULL(Covid_Premium,'')as decimal(10,4)) AS Quoted_Covid_Premium,                                                                                                                                      
cast(ISNULL(u.Cruise_Premium,'')as decimal(10,4)) AS Quoted_Cruise_Premium,                                                                                                             
cast(ISNULL(q.Total_Premium,'')as decimal(10,4)) AS Total_Quoted_Premium,                                                                                                                                                            
CASE WHEN m.PolicyNumber IS NULL THEN a2.GrossPremium ELSE                                
cast(ISNULL(n.Total_Gross_Premium,'')as decimal(10,4)) END AS Total_Quoted_Gross_Premium,                        
q.NAP AS NAP,                                                                                                                                      
replace(o.Title,',',' ') AS Policyholder_Title,                                                                            
replace(o.FirstName,',',' ') AS Policyholder_First_Name,                                                                                                                                      
replace(o.LastName,',',' ') AS  Policyholder_Surname,                                                                       
o.EmailAddress AS  Policyholder_Email,                                                            
o.MobilePhone AS  Policyholder_Mobile_Phone,                                                                       
replace(o.PolicyHolder_Address,',','') AS   Policyholder_Address,                                                                                          
o.DOB as PolicyHolder_DOB,                                                                                                                                      
o.Age as PolicyHolder_Age,                                                                                                                                      
o.State AS Policyholder_State,                                                                                                                                      
OldestTraveller_DOB,                                                                                                                                      
OldestTraveller_Age,                                                                           
y1.AlphaCode collate Latin1_General_CI_AS AS Agency_Code ,                                           
'Bupa' collate  Latin1_General_CI_AS AS Agency_Name,                                                                                                                   
'Bupa' collate   Latin1_General_CI_AS AS Brand,                   
case                                                                   
when y1.AlphaCode collate Latin1_General_CI_AS='BPN0001' Then 'Call Centre'                                                                   
when y1.AlphaCode collate Latin1_General_CI_AS='BPN0002' Then 'Online'                                                                   
                                                         
End                                                                  
as Channel_Type,                                                                                                                            
isnull(r.PromoCode,'') AS Promotional_Code,                                                                                                    
isnull(convert(varchar(100),r.Discount)+'% Discount','') AS Promotional_Factor,                                                                                                    
SessionID AS [Session Token]                                                                                     
                                                                                                  
                                                                                                
FROM (                                                                                                  
SELECT CreateDate,A.QuoteID,PolicyKey,DepartureDate,ReturnDate,MultiDestination,a.Area,OutletAlphaKey,a.QuoteCountryKey,SessionID,                                                                                                             
b.GrossPremium,b.Excess,b.PlanDisplayName as PlanName                                                                              
from [db-au-cmdwh].[dbo].penQuote as a with (nolock) inner join  [db-au-cmdwh].[dbo].penQuoteSelectedPlan              
as b on a.QuoteCountryKey=b.QuoteCountryKey  and b.GrossPremium!='0.00'              
 where AgencyCode in ('BPN0001','BPN0002')                                                                                                            
and A.QuoteID in ( 


SELECT a.QuoteID                                                                             
from [db-au-cmdwh].[dbo].penQuote as a with (nolock) inner join  [db-au-cmdwh].[dbo].penQuoteSelectedPlan              
as b on a.QuoteCountryKey=b.QuoteCountryKey  and b.GrossPremium!='0.00'              
 where AgencyCode in ('BPN0001','BPN0002')                                                                                                            
and convert(date,CreateDate,103) between convert(date,@StartDate-7,103)  and convert(date,@StartDate-1,103)
except
select Lead_Number from [db-au-cmdwh]..Quote_Tbl_BUPA where substring(convert(varchar(60),Lead_Number),1,1)='7'

 
    
    
    
))                                                         
as a2                                                             
                                                                            
outer apply                      
(                                                                                  
select distinct y2.AlphaCode,y2.OutletName,y2.Channel from   [db-au-cmdwh].[dbo].penOutlet y2 with (nolock)                                                                                                          
where y2.OutletAlphaKey=a2.OutletAlphaKey and  OutletStatus='Current'                                                                                                           
 )y1                                
outer apply                                        
(                                                                                                          
select r1.PromoCode,r1.Discount from  [db-au-cmdwh].[dbo].penQuotePromo r1 with (nolock)                                                                                                          
where r1.QuoteCountryKey = a2.QuoteCountryKey                                            
)r                                                                                                   
outer apply                                                                 
(                                                                                                          
                                                      
select QuoteCountryKey,case when convert(varchar(30),AddOnItem) like '%-%' then 'Unlimited' else convert(varchar(30),AddOnItem)                                                      
 end as AddOnItem  from (                                                      
select R2.QuoteCountryKey,                                                      
sum(convert(int,case when  AddOnItem='$Unlimited' then '-100' else REPLACE(REPLACE(AddOnItem,'$',''),',','') end))                                                   
as AddOnItem from  [db-au-cmdwh].[dbo].penQuoteAddOn r2                                        
 INNER JOIN  [db-au-cmdwh].[dbo].penQuote AS R3 with (nolock)    ON R2.QuoteCountryKey=r3.QuoteCountryKey                                                       
 where                                                       
 AddOnGroup='Cancellation' and r2.QuoteCountryKey = R3.QuoteCountryKey                                                          
 and AgencyCode in ('BPN0001','BPN0002')                                                      
                                                      
group by r2.QuoteCountryKey  ) as a  where  a.QuoteCountryKey=a2.QuoteCountryKey                                                    
                                                      
                                                      
)r3         
                                                                                                  
outer apply                                                                        
 (                                                                        
select distinct                 QuoteCountryKey,                                                                        
case when AddOnGroup='COVID-19 Cover' then 'Yes' end  'Covid_Flag'                                                               
from [db-au-cmdwh].[dbo].penQuoteAddOn as r11 where r11.QuoteCountryKey=a2.QuoteCountryKey                                                                        
and AddOnGroup='COVID-19 Cover') as r12                                              
outer apply                                                                        
(                                                                        
select distinct                                                                         
QuoteCountryKey,                                                                        
case when AddOnGroup in ('Cruise','Cruise Cover2') then 'Yes' end  'Cruise_Flag'                                                                        
from [db-au-cmdwh].[dbo].penQuoteAddOn as r13 where r13.QuoteCountryKey=a2.QuoteCountryKey                                                                        
and AddOnGroup in ('Cruise','Cruise Cover2')                                                                        
) as r14                                                                        
outer apply                                                                        
(                               
select distinct                                                                         
QuoteCountryKey,                                                                        
case when AddOnGroup in ('Luggage') then 'Yes' end  'Luggage_Flag'                                                                        
from [db-au-cmdwh].[dbo].penQuoteAddOn as r15 where r15.QuoteCountryKey=a2.QuoteCountryKey                                                                        
and AddOnGroup in ('Luggage')                                                                        
) as r16                                                                        
outer apply                                                           
(                              
select distinct                                                                         
QuoteCountryKey,                                                                        
case when AddOnGroup in ('Motorcycle') then AddOnName end  'Motorbike_Flag'                                              
from [db-au-cmdwh].[dbo].penQuoteAddOn as r17 where r17.QuoteCountryKey=a2.QuoteCountryKey                                                                        
and AddOnGroup in ('Motorcycle')                                                                        
) as r18                                                                        
outer apply                                                                        
(      select distinct                         
QuoteCountryKey,                                                                 
case when AddOnGroup in ('Snow Sports','Snow Sports +','Snow Sports3','Winter Sport') then AddOnName end  'SnowSports_Flag'                                                                        
from [db-au-cmdwh].[dbo].penQuoteAddOn as r19 where r19.QuoteCountryKey=a2.QuoteCountryKey                                                                        
and AddOnGroup in ('Snow Sports','Snow Sports +','Snow Sports3','Winter Sport')                        
) as r20                                                                        
outer apply                                                                        
(                         
select distinct                                                                     
QuoteCountryKey,                                                                        
case when AddOnGroup in ('Adventure Activities 2','Adventure Activities3') then AddOnName end  'AdventureActivities_Flag'                                                                        
from [db-au-cmdwh].[dbo].penQuoteAddOn as r21 where r21.QuoteCountryKey=a2.QuoteCountryKey                                                                        
and AddOnGroup in ('Adventure Activities 2','Adventure Activities3')                                                                        
) as r22                                                                        
                                                                                   
                    
outer apply                                                                                    
(                                                                                    
                  
select QuoteCountryKey,case when Total=No_Count then 'No' else 'Yes' end as HasEMC from (                  
 select QuoteCountryKey,count(*) as Total,                  
 count(case when HasEMC=1 then QuoteCountryKey end) as Yes_Count,                  
 count(case when HasEMC=0 then QuoteCountryKey end) as No_Count                  
 from [db-au-cmdwh].[dbo].penQuoteCustomer                    
 group by QuoteCountryKey) as a where a2.QuoteCountryKey=a.QuoteCountryKey                  
                  
) as z                                                                                    
                                                                                                  
outer apply                                                                                                  
(select distinct CompanyKey,countrykey,PolicyNumber,PolicyID,PolicyKey,OutletAlphaKey,OutletSKey,IssueDate,PrimaryCountry as Destination,        Area,Excess,TripCost,PlanName,AreaCode,AreaName,AreaNumber,AreaType,TripStart,TripEnd,                       
  
    
                                 
                                                 
datediff(day,TripStart,TripEnd)+1 as Trip_Duration,TripType,PlanCode,datediff(day,IssueDate,TripStart)  as [Days_To_Departure] ,MultiDestination,CancellationCover,ExternalReference1  from [db-au-cmdwh].[dbo].penPolicy as M1  with (nolock)                 
  
    
                                            
where  AlphaCode in ('BPN0001','BPN0002') and                                                                                                                                 
  a2.PolicyKey collate SQL_Latin1_General_CP1_CI_AS =m1.PolicyKey  and m1.PlanName=a2.PlanName               
  and  convert(date,IssueDate,103)=convert(date,a2.CreateDate,103)                 
  --PolicyNumber in (                                                      
  --select PolicyNumber from [db-au-cmdwh].[dbo].penPolicy where AlphaCode in ('BPN0001','BPN0002')                                                                                                                                     
  --and convert(date,IssueDate,103)=convert(date,getdate()-1,103)                                                                                                                                  
  --union                                                                                  
  --select distinct a.PolicyNumber from [db-au-cmdwh].[dbo].penPolicy as a inner join [db-au-cmdwh].[dbo].penPolicyTransaction                                                                                                                       
  --as b on a.PolicyKey=b.PolicyKey  where AlphaCode in ('BPN0001','BPN0002') and convert(date,b.IssueDate,103)=convert(date,getdate-1,103)                                                                     
 )m          
                                                                                 
outer apply (                                                                                                          
    select distinct n1.commission,n1.newpolicycount,n1.BasePremium,n1.SingleFamilyFlag,n1.AdultsCount,n1.ChildrenCount,     n1.TravellersCount,PostingDate,PolicyTransactionKey,GrossPremium,n1.PolicyKey,                                  
 isnull(GrossPremium-TaxAmountGST-TaxAmountSD,'') as Total_Gross_Premium ,TaxAmountGST,TaxAmountSD                                  
                                   
 from [db-au-cmdwh].[dbo].penPolicyTransSummary                                                  
                                                                                                   
n1  with (nolock)                                                         
 where m.PolicyKey=n1.PolicyKey and TransactionType='Base' and TransactionStatus='Active' )n                                                               
                                                               
 outer apply                                                              
 (                                                              
 select PolicyKey,GrossPremium,BasePremium from(                                                                  
  select tptx.PolicyKey,sum(tpp.GrossPremium) as GrossPremium,sum(BasePremium) as BasePremium  FROM   [db-au-cmdwh].[dbo].penPolicyPrice   tpp  with (nolock)                                                                  
      INNER JOIN [db-au-cmdwh].[dbo].penPolicyTravellerTransaction  tptt with (nolock) ON   tptt.PolicyTravellerTransactionID = tpp.ComponentID                                                              
   and tpp.CountryKey=tptt.CountryKey and tpp.CompanyKey=tptt.CompanyKey             
       INNER JOIN [db-au-cmdwh].[dbo].penPolicyTraveller tpt with (nolock) ON   tpt.PolicyTravellerkey = tptt.PolicyTravellerkey                          
    and tptt.CountryKey=tpt.CountryKey and tptt.CompanyKey=tpt.CompanyKey                                                                  
       INNER JOIN [db-au-cmdwh].[dbo].penPolicyTransaction tptx with (nolock) ON   tptx.policytransactionkey = tptt.policytransactionkey                                                                  
    and tpt.CountryKey=tptx.CountryKey and tpt.CompanyKey=tptx.CompanyKey                                                                  
       WHERE     tpp.groupid=2 and isPOSDiscount=0 and tpp.CompanyKey='TIP'                                                                  
    group by tptx.PolicyKey) as z13 where z13.PolicyKey=m.PolicyKey                                                                 
  ) z23                                                               
                       
                                                                 
outer apply (                                                                                                                                                            
  select distinct o1.policytravellerkey,o1.Title,o1.FirstName,o1.LastName,o1.EmailAddress,o1.MobilePhone,o1.State,o1.DOB,o1.Age,PostCode,o1.PolicyKey,     o1.AddressLine1+' '+o1.AddressLine2+' '+o1.Suburb AS PolicyHolder_Address,                         
   
   
       
       
           
           
              
                 
                 
                    
                      
                         
                          
                            
                             
                                
                                   
                                   
                                       
                                        
                                          
                                           
                                               
                                                                                              
                                                                                                                                        
(select min(DOB) as OldestTraveller_DOB from [db-au-cmdwh].[dbo].penPolicyTraveller as c with (nolock) where c.PolicyKey=o1.PolicyKey and CountryKey='AU'     and CompanyKey='TIP' group by PolicyID)                                   as OldestTraveller_DOB 
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                    
                                        
                                          
                                            
                                              
                                               
                          
                                                     
                                                      
                                                        
                                                          
                                                    
                                                              
                                                                
                                   
                                                                                           
,                                                                         
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
   select distinct y1.AlphaCode,y1.OutletName,y1.Channel, y1.subgroupname    from  [db-au-cmdwh].[dbo].penOutlet y1  with (nolock)                                                                                            
  where m.CountryKey=y1.CountryKey and m.CompanyKey=y1.CompanyKey and m.OutletAlphaKey=y1.OutletAlphaKey and m.OutletSKey=y1.OutletSKey and OutletStatus='Current')y   outer apply (                                                      
                                                                    
                                             
                                              
                                                
                                                  
                                                    
                                                      
                                                       
                                                          
                                                            
                                                                                    
    select distinct t1.PromoCode,t1.Discount,t1.PromoName,t1.PromoType,t1.PolicyTransactionKey                                                                                      
    from [db-au-cmdwh].[dbo].penPolicyTransactionPromo t1  with (nolock)                                                                                                                                                          
  where t1.PolicyNumber=m.PolicyNumber and t1.CountryKey = 'AU' AND t1.CompanyKey = 'TIP')t                                                                                       
                                              
  outer apply ( select sum(ppp.GrossPremium) 'AdventureActivities_Premium',pao.AddonValueDesc,                                                                          
  CASE WHEN pao.AddOnCode='ADVACT' then pao.AddonValueDesc else 'No' End as AdventureActivities_Flag                                                                                                                                            
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyAddOn pao with (nolock) on ppp.ComponentID = pao.PolicyAddOnID                                                       
                                     
                                         
 join [db-au-cmdwh].[dbo].penPolicyTransaction ppt with (nolock) on pao.PolicyTransactionKey = ppt.PolicyTransactionKey                                                                           
 where ppt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in ('ADVACT','ADVACT2','ADVACT3','ADVACT4')                                      
  
    
     
         
         
            
               
                
                  
                    
                      
                        
                         
                            
                               
                                
                                 
                                     
                                      
                                        
                                          
          
                               
                                                 
                                                  
                                                    
                                                     
                                                       
                                                          
                                                            
                                                              
                                                               
                                                                   
                                                                   
                       
                                                                       
                                                                                                       
 group by pao.AddonValueDesc,pao.AddOnCode)s                                            
                                                                                                                            
   outer apply ( select sum(ppp.GrossPremium) 'Motorcycle_Premium',pao.DisplayName,                                                                          
   CASE WHEN pao.AddOnCode in ('MTCLTWO','MTCL') then pao.DisplayName else 'No' End as Motorbike_Flag                                     
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyAddOn pao with (nolock) on ppp.ComponentID = pao.PolicyAddOnID                                
                                
                                  
                                    
                                      
                                        
 join [db-au-cmdwh].[dbo].penPolicyTransaction ppt with (nolock) on pao.PolicyTransactionKey = ppt.PolicyTransactionKey                                                                                                   
 where ppt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in( 'MTCLTWO' ,'MTCL')                                                           
 
     
     
         
          
            
              
               
                   
                    
                     
                         
                          
                           
                               
                                
                                  
                                    
                                      
                                        
                                          
                                            
                   
                                                
                                                  
                                                    
                                                                      
                                                                        
                                 
 group by pao.DisplayName,pao.AddOnCode)s1                                                                                                                                                   
                                                              
  outer apply (  select sum(ppp.GrossPremium) 'Cruise_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='CRS' then 'Yes' else 'No' End as Cruise_Flag                                                                                                           
  
    
      
        
          
            
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                                
  
    
      
        
          
            
              
                
                  
                    
      
                        
                          
                            
                              
                                
                                  
                                    
                                     
                                         
                                      
                                           
                                               
                                                
                                                  
                                                    
                                                      
                
                                                          
                                                            
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                                                                                        
  
    
      
        
          
            
              
                
                  
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                            
 where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in( 'CRS','CRS','CRS2' )                                                        
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
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
                                                                                                 
 outer apply ( select sum(ppp.GrossPremium) 'Luggage_Premium',pao.AddonName,CASE WHEN pao.AddOnCode='LUGG' then 'Yes' else 'No' End as Luggage_Flag       
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                                
  
   
       
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
              
                                  
                                    
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                               
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                              
 where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'LUGG'                                                                        
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                 
                                     
                                      
                                        
                                                                
                                                          
                                                                     
 group by pao.AddonName,pao.AddOnCode) o3                                                
                                                                                                                                                                  
 outer apply ( select sum(ppp.GrossPremium) 'SnowSports_Premium',pao.AddonName,CASE WHEN pao.AddOnCode in ('SNSPRTS','SNSPRTS2','SNSPRTS3','WNTS') then pao.AddonName else 'No' End as SnowSports_Flag                                                         
  
    
      
        
          
            
              
                
                 
                     
                      
                        
                          
                            
                              
                                
                                  
                                    
          
                                        
                                          
                                            
                                             
                         
                                                 
                           
                                                       
                                                        
                                                         
                                                            
                                                               
                                                               
                                                                   
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                                
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                 
                                  
                                    
                                      
                                        
                                          
                                            
                                              
                                                
                                                  
                                                    
                          
                                                        
                                                          
                          
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                                                                                        
  
    
     
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                                                          
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                      
                             
                                
                                  
 where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode  in ('SNSPRTS','SNSPRTS2','SNSPRTS3','WNTS')                                    
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                          
                                
                                  
                                    
                                      
                                        
                                         
                                             
                                             
 group by pao.AddonName,pao.AddOnCode) o4                                                                                                                    
                                                                                                                                                                  
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
