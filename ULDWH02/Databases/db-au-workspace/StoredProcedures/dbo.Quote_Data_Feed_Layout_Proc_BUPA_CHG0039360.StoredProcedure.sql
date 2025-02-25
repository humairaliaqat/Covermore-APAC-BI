USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[Quote_Data_Feed_Layout_Proc_BUPA_CHG0039360]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
  
  
  
  
  
  
  
  
        
                                                                                                                                                                                          
CREATE PROCEDURE [dbo].[Quote_Data_Feed_Layout_Proc_BUPA_CHG0039360]  --'2024-02-29'                  
             
                                                                                               
@StartDate datetime                                                                                                  
as   
  
BEGIN  
  
if OBJECT_ID('Temp3') is not null  
drop table Temp3  
  
  
  
if OBJECT_ID('Temp4') is not null  
drop table Temp4  
  
  
SELECT * INTO Temp3 from (  
select distinct             
Quote_Date as [Extract date],          
a.SESSIONID as [quote_id],          
Quote_Date AS [created_datetime],          
m.PolicyNumber as [policy_number],           
Departure_Date as [eff_start_date],          
Return_Date as [eff_end_date],          
convert(varchar(150),E.SessionToken) AS  [slug],          
          
replace(Country_list,',',';') as [travel_country_list],          
replace(Region_List,',','') as [region_list],          
I.PlanCode as [Plan_Code],          
I.ProductName AS [Plan],          
'BUPA' as [Partner],          
case when DefaultAffiliateCode='BPN0002' Then 'Online'                                                                                   
when DefaultAffiliateCode='BPN0001' Then 'Call Centre'                                                                                   
End as [Channe],          
case when m.PolicyNumber is not null then n.AdultsCount else [Insured_num_of_adults] end  [Insured_num_of_adults],          
case when m.PolicyNumber is not null then n.ChildrenCount else [Insured_num_of_childs] end   [Insured_num_of_childs],          
case when m.PolicyNumber is not null then n.TravellersCount else   [Total_number_of_insured] end [Total_number_of_insured],          
datediff(DAY,Departure_Date,Return_Date)+1 AS [trip_duration],          
case when HasCRS=1 then 'Yes' else 'No' END as [Additional cover.Cruise_Flag],          
case when m.PolicyNumber is not null then isnull(O2.Covid_Flag,'No') else 'No' end as [Additional cover.Covid_Flag],          
case                                                                                       
when HasLUGG=1 then 'Yes'                                                                                      
when HasLUGG=0 then 'No' end                                                                                      
as [Additional cover.Luggage_Flag], case                                                                                       
when HasSNSPRTS=1 then 'Snow Sports'                                                                                      
when HasSNSPRTS2=1 then 'Snow Sports +'                                                                                      
when HasSNSPRTS=0 and HasSNSPRTS2=0 then 'No' end as [Additional cover.Snow_Sports_Flag],          
case when m.PolicyNumber is not null then ISNULL([AdventureActivities_Flag],'No') else                                                                   
case                                                                                      
when HasADVACT=1 then 'Adventure'                                                                                      
when HasADVACT2=1 then 'Adventure+'                                                                                      
when HasADVACT=0 and HasADVACT2=0 then 'No'                                                            
end end as [Additional cover.Adventure_Activities_Flag],          
case                                                                    
when HasMTCL=1 then 'Motorcycle / Moped Riding'                                                               
when HasMTCLTWO=1 then 'Motorcycle / Moped Riding +'                                                                                      
when HasMTCL=0 and HasMTCLTWO=0 then 'No' end                                                                                      
as [Additional cover.Motorbike_Flag],          
case when                                                                                       
HasEMC=1 then 'Yes' else 'No' ENd as [Additional cover.PEMC_Flag],          
[Total_premium],          
case when m.PolicyNumber is not null then cast(ISNULL(z22.GrossPremium,'') as decimal(10,4)) else          
cast(ISNULL(BASE.BASE_Premium,0) as decimal(10,4)) end AS [Premium breakdown.Base_Premium],          
case when m.PolicyNumber is not null then cast(ISNULL(q.Total_Premium,'')as decimal(10,4)) else          
cast(ISNULL(A.TotalGrossPremium,0) as decimal(10,4)) END  as [Premium breakdown.Total_Gross_Premium],          
case when m.PolicyNumber is not null then cast(ISNULL(u.Cruise_Premium,'')as decimal(10,4)) else          
cast(ISNULL(CRS.Cruise_Premium,0) as decimal(10,4)) END  AS [Premium breakdown.Cruise_Premium],          
case when m.PolicyNumber is not null then cast(ISNULL(s.AdventureActivities_Premium,'')as decimal(10,4)) else          
cast(ISNULL(ADVC.Adventure_Premium,0) as decimal(10,4)) END  AS  [Premium breakdown.Adventure_Activities_Premium],          
case when m.PolicyNumber is not null then cast(ISNULL(s1.Motorcycle_Premium,'')as decimal(10,4)) else          
cast(ISNULL(MTCL.MotorCYcle_Premium,0) as decimal(10,4)) END AS [Premium breakdown.Motorcycle_Premium],          
case when m.PolicyNumber is not null then cast(ISNULL(O1.Cancellation_Premium,'') as decimal(10,4)) else          
cast(ISNULL(CANX.Cancellation_Premium,0) as decimal(10,4)) END AS [Premium breakdown.Cancellation_Premium],          
case when m.PolicyNumber is not null then cast(ISNULL(O2.Covid_Premium,'')as decimal(10,4)) else          
cast(ISNULL(COVCANX.Covid_Premium,0) as decimal(10,4)) END   AS  [Premium breakdown.Covid_Premium],          
case when m.PolicyNumber is not null then  cast(ISNULL(o3.Luggage_Premium,'')as decimal(10,4)) else          
cast(ISNULL(LUGG.Luggage_Premium,0) as decimal(10,4)) END AS  [Premium breakdown.Luggage_Premium],          
case when m.PolicyNumber is not null then cast(ISNULL(o4.SnowSports_Premium,'') as decimal(10,4)) else          
cast(ISNULL(SNSPRTS.Snow_Sports_Premium,0) as decimal(10,4)) END  AS  [Premium breakdown.Snow_Sports_Premium],          
case when m.PolicyNumber is not null then cast(ISNULL(O5.PEMC_Premium,'')as decimal(10,4)) else          
cast(ISNULL(EMC.PEMC_Premium,0) as decimal(10,4)) END [Premium breakdown.PEMC_Premium],          
cast(ISNULL(n.TaxAmountGST, '')as decimal(10,4)) as [Premium breakdown.GST_on_Total_Premium],          
cast(ISNULL(n.TaxAmountSD, '')as decimal(10,4)) as  [Premium breakdown.Stamp_Duty_on_Total_Premium],          
cast(ISNULL(q.NAP, '')as decimal(10,4)) as [NAP],          
cast(ISNULL(m.Excess,'') as decimal(10,4))   AS [Excess],          
CASE                                                                                                                                   
WHEN ProductName='Comprehensive' AND convert(VARCHAR(300),CANXCoverageAmount)='1.00' THEN '10000'                                                                            
WHEN ProductName='Essential' AND convert(VARCHAR(300),CANXCoverageAmount)='1.00' THEN '5000'                                                                                                                                  
WHEN  convert(VARCHAR(300),CANXCoverageAmount)='-1.00' THEN 'Unlimited' else  convert(varchar(50),CANXCoverageAmount)  end                                                         
AS [Cancellation_sum_insured],          
convert(varchar(500),replace(o.Title,',',' ')) AS [policy_holder.title],          
convert(varchar(500),replace(o.FirstName,',',' ')) AS [policy_holder.first_name],          
convert(varchar(500),replace(o.LastName,',',' ')) AS [policy_holder.last_name],          
o.EmailAddress AS [policy_holder.email],          
o.MobilePhone AS [policy_holder.mobile],          
o.DOB as [policy_holder.dob],          
o.Age as [policy_holder.age],          
replace(o.PolicyHolder_Address,',','') AS  [policy_holder.address],          
o.State AS [policy_holder.state],          
case when m.PolicyNumber is not null then PostCode else '' END as [policy_holder.postcode],          
case when m.PolicyNumber is not null then GAID else '' end as [policy_holder.GNAF]                                                                                                              
FROM(                                                                                                                                                
SELECT convert(date,dbo.xfn_ConvertUTCtoLocal(b.Date+''+c.StandardTime,'E. Australia Standard TIme'),103) as Quote_Date,* from [db-au-stage].dbo.cdg_factQuote_AU_AG AS A1 WITH (NOLOCK) inner join   
[db-au-stage].dbo.cdg_dimdate_au_AG                                      
as b WITH (NOLOCK) on A1.QuoteTransactionDateID=b.DimDateID inner join  [db-au-stage].dbo.cdg_dimTime_AU as c WITH (NOLOCK) on a1.QuoteTransactionTimeID=c.DimTimeID                                          
WHERE BusinessUnitID=146 AND CampaignID=362 and convert(date,dbo.xfn_ConvertUTCtoLocal(b.Date+''+c.StandardTime,'E. Australia Standard TIme'),103)=convert(date,@StartDate,103)                                                                            
--and quotetransactiondateid in (                                            
--select dimdateid  from  [db-au-stage].dbo.cdg_dimdate_au_AG                                             
--where convert(date,date,103)=convert(date,@StartDate,103))                                           
                                        
                                            
                                            
) AS A                                                                                                                                           
OUTER APPLY                                                                                                  
(SELECT B1.Date AS Departure_Date FROM  [db-au-stage].dbo.cdg_dimdate_au_AG AS B1  WITH (NOLOCK)                                                
WHERE  A.TripStartDateID=B1.DimDateID ) AS B                                                                                                                                                       
OUTER APPLY (SELECT C1.Date as Return_Date FROM  [db-au-stage].dbo.cdg_dimdate_au_AG AS C1      WITH (NOLOCK)                          
WHERE  A.TripEndDateID=C1.DimDateID ) AS C                                                                                        
OUTER APPLY                                                                                                                                                      
(SELECT D1.Date AS QuotedDate FROM  [db-au-stage].dbo.cdg_dimDate_AU_AG AS D1    WITH (NOLOCK)                                                                                                                                                  
WHERE  A.QuoteTransactionDateID=D1.DimDateID) AS D                                                                                                                                                
OUTER APPLY                                                                                                                        
(SELECT SessionID,SessionToken FROM [db-au-stage].dbo.cdg_factSession_AU_AG AS E1   WITH (NOLOCK)                                                                                                                                    
WHERE SessionID=FactSessionID ) AS E                                                                                                                                                  
OUTER APPLY(SELECT DimCampaignID,CampaignName,DefaultAffiliateCode,DefaultCultureCode FROM [db-au-stage].dbo.cdg_DimCampaign_AU_AG as F1                                    
                               
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
AS A WITH (NOLOCK) INNER JOIN [db-au-stage].dbo.cdg_dimPromoCodeList_AU_AG AS B ON A.PromoCodeListID=B.DimPromoCodeListID) AS A       
UNPIVOT                                                                                                
(                                                                
PromoCodeID FOR                                                                                                                         
PromoCode IN (PromoCodeID1,PromoCodeID2,PromoCodeID3,PromoCodeID4)                                                                          
) AS A INNER JOIN [db-au-stage].dbo.cdg_dimPromocode_AU_AG AS B WITH (NOLOCK) ON  PromoCodeID=B.DimPromoCodeID                                                                                                                 
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
) AS A INNER JOIN [db-au-stage].dbo.cdg_dimPromocode_AU_AG AS B ON PromoCodeID=B.DimPromoCodeID                                                                                              
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
SELECT DimGroupTypeID,GroupTypeName,GroupTypeNameShort FROM [db-au-stage].dbo.cdg_dimGroupType_AU_AG AS Y1X WITH (NOLOCK)                                                                                                                                     
 
WHERE Y1X.DimGroupTypeID=A.GroupTypeID                                                                                                              
)  AS YX                                                  
                                                
--OUTER APPLY                                                
--(                            
--select                   
--json_value([PartnerMetaData],'$.LinkID') as LinkID,                  
--json_value([PartnerMetaData],'$.gclid') as gclid,                  
--json_value([PartnerMetaData],'$.gaClientID') as gaClientID                  
                  
--,Sessiontoken from [db-au-stage].dbo.cdg_SessionPartnerMetaData_AU                                                 
--as Y2X WHERE y2x.Sessiontoken=e.SessionToken AND                   
--PartnerMetaData like '%LinkID%gclid%gaClientID%'                                                
--) AS YZ          
        
OUTER APPLY        
(        
SELECT         
SessionID,         
count(*) as [Total_number_of_insured],        
count(case when IsAdult=1 then SessionID end) as [Insured_num_of_adults],        
count(case when IsChild=1 then SessionID end) as [Insured_num_of_childs]          
        
FROM [db-au-stage].dbo.cdg_factTraveler_AU AS ZZX WITH (NOLOCK) WHERE  ZZX.SessionID=a.SessionID        
group by SessionID        
        
        
)  as zz     
  
OUTER APPLY          
(          
select SessionID,LineTitle,LineCategoryCode,LineGrossPrice AS Adventure_Premium from [db-au-stage].[dbo].[CDG_Quote_Addon_Premium_AU_AG] AS ABC  where ABC.SESSIONID=A.SessionID AND linecategorycode like '%advact%'          
) ADVC          
          
OUTER APPLY          
(          
select SessionID,LineTitle,LineCategoryCode,LineGrossPrice AS BASE_Premium from [db-au-stage].[dbo].[CDG_Quote_Addon_Premium_AU_AG] AS DEF  where DEF.SESSIONID=A.SessionID AND linecategorycode like '%BASE%'          
) BASE          
          
          
OUTER APPLY          
(          
select SessionID,LineTitle,LineCategoryCode,LineGrossPrice AS Cancellation_Premium from [db-au-stage].[dbo].[CDG_Quote_Addon_Premium_AU_AG] AS ABC    
where ABC.SESSIONID=A.SessionID AND linecategorycode='CANX'         
) CANX          
          
OUTER APPLY          
(          
select SessionID,LineTitle,LineCategoryCode,LineGrossPrice AS Cruise_Premium from [db-au-stage].[dbo].[CDG_Quote_Addon_Premium_AU_AG] AS ABC  where ABC.SESSIONID=A.SessionID AND linecategorycode like '%CRS%'          
) CRS          
          
OUTER APPLY          
(          
select SessionID,LineTitle,LineCategoryCode,LineGrossPrice AS PEMC_Premium from [db-au-stage].[dbo].[CDG_Quote_Addon_Premium_AU_AG] AS ABC  where ABC.SESSIONID=A.SessionID AND linecategorycode like '%EMC%'          
) EMC          
          
OUTER APPLY          
(          
select SessionID,LineTitle,LineCategoryCode,LineGrossPrice AS Luggage_Premium from [db-au-stage].[dbo].[CDG_Quote_Addon_Premium_AU_AG] AS ABC  where ABC.SESSIONID=A.SessionID       
AND linecategorycode like '%LUGG%'          
) LUGG          
          
          
          
OUTER APPLY          
(          
select SessionID,LineTitle,LineCategoryCode,LineGrossPrice AS MotorCYcle_Premium from [db-au-stage].[dbo].[CDG_Quote_Addon_Premium_AU_AG] AS ABC  where ABC.SESSIONID=A.SessionID AND linecategorycode like '%MTCL%'          
) MTCL          
          
          
OUTER APPLY          
(          
select SessionID,LineTitle,LineCategoryCode,LineGrossPrice AS Snow_Sports_Premium from [db-au-stage].[dbo].[CDG_Quote_Addon_Premium_AU_AG] AS ABC  where ABC.SESSIONID=A.SessionID AND linecategorycode like '%SNSPRTS%'          
) SNSPRTS          
          
          
OUTER APPLY          
(          
select SessionID,LineTitle,LineCategoryCode,LineGrossPrice AS Covid_Premium from [db-au-stage].[dbo].[CDG_Quote_Addon_Premium_AU_AG] AS ABC    
where ABC.SESSIONID=A.SessionID AND linecategorycode='COVCANX'          
) COVCANX    
  
  
  
                              
OUTER APPLY                                                                                                                       
(select distinct CompanyKey,countrykey,PolicyNumber,PolicyID,PolicyKey,OutletAlphaKey,OutletSKey,IssueDate,PrimaryCountry as Destination,        Area,Excess,TripCost,PlanName,AreaCode,AreaName,AreaNumber,AreaType,TripStart,TripEnd,                        
 
    
                         
                                                  
datediff(day,TripStart,TripEnd)+1 as Trip_Duration,TripType,PlanCode,datediff(day,IssueDate,TripStart)  as [Days_To_Departure] ,MultiDestination,CancellationCover,ExternalReference1  from [db-au-cmdwh].[dbo].penPolicy as M1  with (nolock)                 
  
    
      
        
          
            
              
                            
                    
                      
                        
                          
                            
                              
                                
                                                                     
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
  as OldestTraveller_Age,  
  CASE WHEN PIDValue LIKE '%^%' then substring(PIDValue,1,charindex('^',pidvalue)-1) end                               
  as  GAID        
  
  
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
           
CreateDate as [Extract date]          
,QuoteID as  [quote_id]          
,CreateDate as [created_datetime]          
,PolicyNumber as [policy_number]          
,DepartureDate as [eff_start_date]          
,ReturnDate as [eff_end_date]          
,SessionID AS [slug]          
,replace(a2.MultiDestination,',',';') as [travel_country_list]          
,replace(a2.Area,',','') COLLATE Latin1_General_CI_AS as [region_list]          
,CASE WHEN M.PolicyNumber IS NOT NULL THEN M.PlanCode ELSE a2.ProductCode COLLATE DATABASE_DEFAULT END AS [Plan_Code]          
,case   when m.PolicyNumber is not null then m.PlanName else a2.PlanName COLLATE DATABASE_DEFAULT END as [Plan]          
,'Bupa' as [Partner]          
,case                                                                                   
                                                                                 
when y1.AlphaCode collate Latin1_General_CI_AS='BPN0002' Then 'Online'                                                                                   
when y1.AlphaCode collate Latin1_General_CI_AS='BPN0001' Then 'Call Centre'                                                                           
End                                                                                  
as  [Channel]          
,z33.Total as [Insured_num_of_adults]          
,z33.Child_Count as [Insured_num_of_childs]          
,z33.Adult_Count as [Total_number_of_insured]          
,datediff(DAY,DepartureDate,ReturnDate)+1 AS [trip_duration]          
,isnull(r14.Cruise_Flag,'No') as [Additional cover.Cruise_Flag]          
,isnull(r12.Covid_Flag, 'No') as [Additional cover.Covid_Flag]          
,isnull(r16.Luggage_Flag,'No') as[Additional cover.Luggage_Flag] ,isnull(r20.SnowSports_Flag,'No') as [Additional cover.Snow_Sports_Flag]          
,isnull(r22.AdventureActivities_Flag,'No') as [Additional cover.Adventure_Activities_Flag]          
,isnull(case when m.PolicyNumber is not null then s1.Motorbike_Flag else  r18.Motorbike_Flag end,'No') as [Additional cover.Motorbike_Flag]          
,isnull(HasEMC,'No') as [Additional cover.PEMC_Flag]          
,[Total_premium]          
,cast(ISNULL(z23.GrossPremium,'')as decimal(10,4)) AS [Premium breakdown.Base_Premium]          
,CASE WHEN m.PolicyNumber IS NULL THEN a2.GrossPremium ELSE      
cast(ISNULL(n.Total_Gross_Premium,'')as decimal(10,4)) END AS [Premium breakdown.Total_Gross_Premium]          
,cast(ISNULL(u.Cruise_Premium,'')as decimal(10,4)) AS [Premium breakdown.Cruise_Premium]          
,cast(ISNULL(s.AdventureActivities_Premium,'')as decimal(10,4)) AS [Premium breakdown.Adventure_Activities_Premium]          
,cast(ISNULL(s1.Motorcycle_Premium,'')as decimal(10,4)) AS  [Premium breakdown.Motorcycle_Premium]          
,cast(ISNULL(Cancellation_Premium,'')as decimal(10,4)) AS [Premium breakdown.Cancellation_Premium]          
,cast(ISNULL(Covid_Premium,'')as decimal(10,4)) AS [Premium breakdown.Covid_Premium]          
,cast(ISNULL(o3.Luggage_Premium,'')as decimal(10,4)) AS [Premium breakdown.Luggage_Premium]          
,cast(ISNULL(o4.SnowSports_Premium,'')as decimal(10,4)) AS [Premium breakdown.Snow_Sports_Premium]          
,cast(ISNULL(PEMC_Premium,'')as decimal(10,4)) AS [Premium breakdown.PEMC_Premium]    
,cast(ISNULL(n.TaxAmountGST, '')as decimal(10,4)) as [Premium breakdown.GST_on_Total_Premium]          
,cast(ISNULL(n.TaxAmountSD, '')as decimal(10,4)) as  [Premium breakdown.Stamp_Duty_on_Total_Premium]          
,q.NAP AS [NAP]          
,cast(ISNULL(a2.Excess,'')as decimal(10,4))  AS [Excess]          
,ISNULL(CASE                                                                                                                                   
WHEN A2.PlanName='Comprehensive' AND convert(VARCHAR(300),r3.AddOnItem)='1' THEN '10000'                                                             
WHEN A2.PlanName='Essential' AND convert(VARCHAR(300),r3.AddOnItem)='1' THEN '5000'                                                                                            
WHEN  convert(VARCHAR(300),r3.AddOnItem)='-1' THEN 'Unlimited'                                                      
else convert(VARCHAR(300),r3.AddOnItem) end ,0)                                                         
AS  [Cancellation_sum_insured]          
,replace(o.Title,',',' ') AS [policy_holder.title]          
,replace(o.FirstName,',',' ') AS [policy_holder.first_name]          
,replace(o.LastName,',',' ') AS  [policy_holder.last_name]          
,o.EmailAddress AS  [policy_holder.email]          
,o.MobilePhone AS [policy_holder.mobile]          
,o.DOB as [policy_holder.dob]          
,o.Age as [policy_holder.age]          
,replace(o.PolicyHolder_Address,',','') AS  [policy_holder.address]          
,o.State AS [policy_holder.state]          
,case when m.PolicyNumber is not null then PostCode end as [policy_holder.postcode]          
,case when m.PolicyNumber is not null then GAID end as [policy_holder.GNAF]          
                                                                                                               
                                                                                                                
FROM (                                                                                                                  
SELECT CreateDate,A.QuoteID,PolicyKey,DepartureDate,ReturnDate,MultiDestination,a.Area,OutletAlphaKey,a.QuoteCountryKey,SessionID,                                                                                                                             
b.GrossPremium,b.Excess,b.PlanDisplayName as PlanName,B.ProductCode                                                                                              
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
(                                                                                                    
                           
select QuoteCountryKey,                                
 count(*) as Total,                                  
 count(case when PersonIsAdult=1 then QuoteCountryKey end) as Adult_Count,                                  
 count(case when PersonIsAdult=0 then QuoteCountryKey end) as Child_Count                                  
 from [db-au-cmdwh].[dbo].penQuoteCustomer as a    where a2.QuoteCountryKey=a.QuoteCountryKey                                    
 group by QuoteCountryKey                                 
                                  
) as z33     
                                                                                                                  
outer apply                                                                                                                  
(select distinct CompanyKey,countrykey,PolicyNumber,PolicyID,PolicyKey,OutletAlphaKey,OutletSKey,IssueDate,PrimaryCountry as Destination,        Area,Excess,TripCost,PlanName,AreaCode,AreaName,AreaNumber,AreaType,TripStart,TripEnd,                       
  
    
      
        
          
            
              
                
                  
                    
                                                 
           
datediff(day,TripStart,TripEnd)+1 as Trip_Duration,TripType,PlanCode,datediff(day,IssueDate,TripStart)  as [Days_To_Departure] ,MultiDestination,CancellationCover,ExternalReference1  from [db-au-cmdwh].[dbo].penPolicy as M1  with (nolock)                 
  
    
      
        
          
            
              
                
                  
                    
                                                            
where  AlphaCode in ('BPN0001','BPN0002') and                                                                                             
  a2.PolicyKey collate SQL_Latin1_General_CP1_CI_AS =m1.PolicyKey  --and m1.PlanName=a2.PlanName                               
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
  as OldestTraveller_Age,  
    
   CASE WHEN PIDValue LIKE '%^%' then substring(PIDValue,1,charindex('^',pidvalue)-1) end                               
  as  GAID  
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
) as a  
--union  
  
-- Impulse Missing Quotes  
  
  
--SELECT * INTO TEMP4 from (  
--select distinct             
--Quote_Date as [Extract date],          
--a.SESSIONID as [quote_id],          
--Quote_Date AS [created_datetime],          
--m.PolicyNumber as [policy_number],           
--Departure_Date as [eff_start_date],          
--Return_Date as [eff_end_date],          
--convert(varchar(150),E.SessionToken) AS  [slug],          
          
--replace(Country_list,',',';') as [travel_country_list],          
--replace(Region_List,',','') as [region_list],          
--I.PlanCode as [Plan_Code],          
--I.ProductName AS [Plan],          
--'BUPA' as [Partner],          
--case when DefaultAffiliateCode='BPN0002' Then 'Online'                                                                                   
--when DefaultAffiliateCode='BPN0001' Then 'Call Centre'                                                                                   
--End as [Channe],          
--case when m.PolicyNumber is not null then n.AdultsCount else [Insured_num_of_adults] end  [Insured_num_of_adults],          
--case when m.PolicyNumber is not null then n.ChildrenCount else [Insured_num_of_childs] end   [Insured_num_of_childs],          
--case when m.PolicyNumber is not null then n.TravellersCount else   [Total_number_of_insured] end [Total_number_of_insured],          
--datediff(DAY,Departure_Date,Return_Date)+1 AS [trip_duration],          
--case when HasCRS=1 then 'Yes' else 'No' END as [Additional cover.Cruise_Flag],          
--case when m.PolicyNumber is not null then isnull(O2.Covid_Flag,'No') else 'No' end as [Additional cover.Covid_Flag],          
--case                                                                                       
--when HasLUGG=1 then 'Yes'                                                                                      
--when HasLUGG=0 then 'No' end                                                                                      
--as [Additional cover.Luggage_Flag], case                                                                                       
--when HasSNSPRTS=1 then 'Snow Sports'                                                                                      
--when HasSNSPRTS2=1 then 'Snow Sports +'                                                                                      
--when HasSNSPRTS=0 and HasSNSPRTS2=0 then 'No' end as [Additional cover.Snow_Sports_Flag],          
--case when m.PolicyNumber is not null then ISNULL([AdventureActivities_Flag],'No') else                                                                   
--case                                                                                      
--when HasADVACT=1 then 'Adventure'                                                                                      
--when HasADVACT2=1 then 'Adventure+'                                                                                      
--when HasADVACT=0 and HasADVACT2=0 then 'No'                                                            
--end end as [Additional cover.Adventure_Activities_Flag],          
--case                                                                    
--when HasMTCL=1 then 'Motorcycle / Moped Riding'                                                               
--when HasMTCLTWO=1 then 'Motorcycle / Moped Riding +'                                                                                      
--when HasMTCL=0 and HasMTCLTWO=0 then 'No' end                                                                                      
--as [Additional cover.Motorbike_Flag],          
--case when                                                                                       
--HasEMC=1 then 'Yes' else 'No' ENd as [Additional cover.PEMC_Flag],          
--[Total_premium],          
--cast(ISNULL(z22.GrossPremium,'') as decimal(10,4)) AS [Premium breakdown.Base_Premium],        CASE WHEN m.PolicyNumber IS NULL THEN A.TotalGrossPremium ELSE                                                                                               
     
        
--cast(ISNULL(n.Total_Gross_Premium,'')as decimal(10,4)) END  as [Premium breakdown.Total_Gross_Premium],          
--cast(ISNULL(u.Cruise_Premium,'')as decimal(10,4)) AS [Premium breakdown.Cruise_Premium],          
--cast(ISNULL(s.AdventureActivities_Premium,'')as decimal(10,4)) AS  [Premium breakdown.Adventure_Activities_Premium],          
--cast(ISNULL(s1.Motorcycle_Premium,'')as decimal(10,4)) AS [Premium breakdown.Motorcycle_Premium],          
--cast(ISNULL(Cancellation_Premium,'') as decimal(10,4)) AS [Premium breakdown.Cancellation_Premium],          
--cast(ISNULL(Covid_Premium,'')as decimal(10,4))  AS  [Premium breakdown.Covid_Premium],          
--cast(ISNULL(o3.Luggage_Premium,'')as decimal(10,4)) AS [Premium breakdown.Luggage_Premium],          
--cast(ISNULL(o4.SnowSports_Premium,'') as decimal(10,4)) AS  [Premium breakdown.Snow_Sports_Premium],          
--cast(ISNULL(PEMC_Premium,'')as decimal(10,4)) AS [Premium breakdown.PEMC_Premium],          
--cast(ISNULL(n.TaxAmountGST, '')as decimal(10,4)) as [Premium breakdown.GST_on_Total_Premium],          
--cast(ISNULL(n.TaxAmountSD, '')as decimal(10,4)) as  [Premium breakdown.Stamp_Duty_on_Total_Premium],          
--cast(ISNULL(q.NAP, '')as decimal(10,4)) as [NAP],          
--cast(ISNULL(m.Excess,'') as decimal(10,4))   AS [Excess],          
--CASE                                                                                                                                   
--WHEN ProductName='Comprehensive' AND convert(VARCHAR(300),CANXCoverageAmount)='1.00' THEN '10000'                                                                            
--WHEN ProductName='Essential' AND convert(VARCHAR(300),CANXCoverageAmount)='1.00' THEN '5000'                                                                                                                                  
--WHEN  convert(VARCHAR(300),CANXCoverageAmount)='-1.00' THEN 'Unlimited' else  convert(varchar(50),CANXCoverageAmount)  end                                                         
--AS [Cancellation_sum_insured],          
--convert(varchar(500),replace(o.Title,',',' ')) AS [policy_holder.title],          
--convert(varchar(500),replace(o.FirstName,',',' ')) AS [policy_holder.first_name],          
--convert(varchar(500),replace(o.LastName,',',' ')) AS [policy_holder.last_name],          
--o.EmailAddress AS [policy_holder.email],          
--o.MobilePhone AS [policy_holder.mobile],          
--o.DOB as [policy_holder.dob],          
--o.Age as [policy_holder.age],          
--replace(o.PolicyHolder_Address,',','') AS  [policy_holder.address],          
--o.State AS [policy_holder.state],          
--case when m.PolicyNumber is not null then PostCode else '' END as [policy_holder.postcode],          
--case when m.PolicyNumber is not null then GAID else '' end as [policy_holder.GNAF]                                                                                                              
--FROM(                                                                                                                                                
--SELECT convert(date,dbo.xfn_ConvertUTCtoLocal(b.Date+''+c.StandardTime,'E. Australia Standard TIme'),103) as Quote_Date,* from [db-au-stage].dbo.cdg_factQuote_AU_AG AS A1 inner join [db-au-stage].dbo.cdg_dimdate_au_AG                                    
  
--as b on A1.QuoteTransactionDateID=b.DimDateID inner join  [db-au-stage].dbo.cdg_dimTime_AU as c  on a1.QuoteTransactionTimeID=c.DimTimeID                                          
--WHERE BusinessUnitID=146 AND CampaignID=362   
--and  A1.SessionID in   
--(  
--SELECT sessionid from [db-au-stage].dbo.cdg_factQuote_AU_AG AS A1 inner join [db-au-stage].dbo.cdg_dimdate_au_AG     as b on A1.QuoteTransactionDateID=b.DimDateID inner join  [db-au-stage].dbo.cdg_dimTime_AU as c  on a1.QuoteTransactionTimeID=c.DimTimeID  
       
       
                                
--WHERE BusinessUnitID=146 AND CampaignID=362 and           
--convert(date,dbo.xfn_ConvertUTCtoLocal(b.Date+''+c.StandardTime,'E. Australia Standard TIme'),103) between       
--convert(date,@StartDate-7,103) and convert(date,@StartDate-1,103)          
--Except          
--select quote_id from [db-au-cmdwh]..QuoteFeed_TBL  
--)  
  
                                        
                                        
                                            
                                            
--) AS A                                                                                                                                           
--OUTER APPLY                                                                                                  
--(SELECT B1.Date AS Departure_Date FROM  [db-au-stage].dbo.cdg_dimdate_au_AG AS B1                                                  
--WHERE  A.TripStartDateID=B1.DimDateID ) AS B                                                                                                                                                       
--OUTER APPLY (SELECT C1.Date as Return_Date FROM  [db-au-stage].dbo.cdg_dimdate_au_AG AS C1                               
--WHERE  A.TripEndDateID=C1.DimDateID ) AS C                                                                                        
--OUTER APPLY                                                                                                                                                      
--(SELECT D1.Date AS QuotedDate FROM  [db-au-stage].dbo.cdg_dimDate_AU_AG AS D1                                                                                                                                                      
--WHERE  A.QuoteTransactionDateID=D1.DimDateID) AS D                                                                                                                                                
--OUTER APPLY                                                                                                                        
--(SELECT SessionID,SessionToken FROM [db-au-stage].dbo.cdg_factSession_AU_AG AS E1                                                                                                                                       
--WHERE SessionID=FactSessionID ) AS E                                                                                                                                                  
--OUTER APPLY(SELECT DimCampaignID,CampaignName,DefaultAffiliateCode,DefaultCultureCode FROM [db-au-stage].dbo.cdg_DimCampaign_AU_AG as F1                                                                                                                
                               
--where CampaignID=f1.DimCampaignID ) as F                                  
--OUTER APPLY                                                                                                                                                      
--(select  RegionName as Region_List from  [db-au-stage].dbo.cdg_DimRegion_AU_AG as G1                                                                                                                                                       
--where RegionID =g1.DimRegionID) as G                                                                                                                                          
--OUTER APPLY                                                                                                                    
--(                                                                      
--SELECT * FROM (                                                                          
--SELECT B.DimCovermoreCountryListID,b.SessionID,b.FactQuoteID,                              
--STUFF((select ','+CONVERT(VARCHAR(30),CovermoreCountryName) from (                                                                                        
--SELECT SessionID,FactQuoteID,DimCovermoreCountryListID,COUNTRYID,CovermoreCountryName FROM (                                                                
--SELECT  SessionID,FactQuoteID,DimCovermoreCountryListID,CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,CMCountryID7,                                                                      
--CMCountryID8,CMCountryID9,CMCountryID10 FROM  [db-au-stage].dbo.cdg_factQuote_AU_AG                                                                                                                
--AS A INNER JOIN [db-au-stage].dbo.cdg_dimCovermoreCountryList_AU_AG AS B ON A.DestCovermoreCountryListID=B.DimCovermoreCountryListID) AS A                                                                                                                  
    
     
      
                               
                                  
--UNPIVOT                                        
--(                                                                                                        
--COUNTRYID FOR                                                                       
--COUNTRY IN (CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,CMCountryID7,CMCountryID8,CMCountryID9,CMCountryID10)              
--) AS A INNER JOIN [db-au-stage].dbo.cdg_dimCovermoreCountry_AU_AG AS B ON COUNTRYID=B.DimCovermoreCountryID                                                                                
--WHERE COUNTRYID<>'-1') AS A WHERE A.DimCovermoreCountryListID=B.DimCovermoreCountryListID                                                                
--and  a.SessionID=b.SessionID and a.FactQuoteID=b.FactQuoteID  FOR XML PATH('')),1,1,'') AS Country_list                                                                                                                                  
--FROM                                                                                   
--(                                                                                                                
--SELECT SessionID,FactQuoteID,DimCovermoreCountryListID,COUNTRYID,CovermoreCountryName FROM (                                                                                                                                                      
--SELECT  SessionID,FactQuoteID,DimCovermoreCountryListID,CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,                                                                                                                       
    
   
      
         
          
            
              
               
--CMCountryID7,                                                                                          
--CMCountryID8,CMCountryID9,CMCountryID10 FROM  [db-au-stage].dbo.cdg_factQuote_AU_AG                                                       
--AS A INNER JOIN [db-au-stage].dbo.cdg_dimCovermoreCountryList_AU_AG AS B ON A.DestCovermoreCountryListID=B.DimCovermoreCountryListID) AS A                                                  
                                 
--UNPIVOT                                                                                 
--(                                                                                                                                                 
--COUNTRYID FOR                                                                                           
--COUNTRY IN (CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,CMCountryID7,CMCountryID8,CMCountryID9,                                                                                                                            
    
--CMCountryID10)                                                                                                                                  
--) AS A INNER JOIN [db-au-stage].dbo.cdg_dimCovermoreCountry_AU_AG AS B ON COUNTRYID=B.DimCovermoreCountryID                                                              
--WHERE COUNTRYID<>'-1'                                                                                                                                                      
--) AS B GROUP BY B.DimCovermoreCountryListID,b.SessionID,b.FactQuoteID) AS H1                                                                                                                                                      
--WHERE H1.SessionID=A.SessionID AND H1.FactQuoteID=A.FactQuoteID ) AS H                                                                   
--OUTER APPLY                                                                                                                                                      
--(                                            
--SELECT DimProductID,ProductCode,PlanCode,ProductName,TripFrequency FROM [db-au-stage].dbo.cdg_DimProduct_AU_AG AS I1                                             
--WHERE A.ProductID=I1.DimProductID                                                                                                                                                      
--) I                                                                                 
--OUTER APPLY                                                                                                          
                                                                                     
--(                                                                                                                                                  
--SELECT * FROM (                                                                                                           
--SELECT B.PromoCodeListID,b.SessionID,b.FactQuoteID,STUFF((select ','+CONVERT(VARCHAR(30),Code) from (                                                                                                                
--SELECT SessionID,FactQuoteID,PromoCodeListID,PromoCodeID,PromoCode,Code,Type,CampaignID FROM (                                                                                                                                                  
--SELECT  SessionID,FactQuoteID,PromoCodeListID,PromoCodeID1,PromoCodeID2,PromoCodeID3,PromoCodeID4 FROM                                                                  
--[db-au-stage].dbo.cdg_factQuote_AU_AG                                                                                                                             
--AS A INNER JOIN [db-au-stage].dbo.cdg_dimPromoCodeList_AU_AG AS B ON A.PromoCodeListID=B.DimPromoCodeListID) AS A                                                                                                    
--UNPIVOT                                                                                                
--(                                                                
--PromoCodeID FOR                                                                                                                         
--PromoCode IN (PromoCodeID1,PromoCodeID2,PromoCodeID3,PromoCodeID4)                                                                          
--) AS A INNER JOIN [db-au-stage].dbo.cdg_dimPromocode_AU_AG AS B ON PromoCodeID=B.DimPromoCodeID                                                                                                                 
--WHERE PromoCodeID<>'-1') AS A WHERE A.PromoCodeListID=B.PromoCodeListID                                                                                  
--and  a.SessionID=b.SessionID and a.FactQuoteID=b.FactQuoteID  FOR XML PATH('')),1,1,'') AS Prmocode_list                                                                                                                                               
--FROM                                                                                                          
--(                                                                               
--SELECT SessionID,FactQuoteID,PromoCodeListID,PromoCodeID,PromoCode,Code,Type,CampaignID FROM (                                                                                                                                                      
--SELECT  SessionID,FactQuoteID,PromoCodeListID,PromoCodeID1,PromoCodeID2,PromoCodeID3,PromoCodeID4 FROM                                                                                         
--[db-au-stage].dbo.cdg_factQuote_AU_AG                                                                                                                                                  
--AS A INNER JOIN [db-au-stage].dbo.cdg_dimPromoCodeList_AU_AG AS B ON A.PromoCodeListID=B.DimPromoCodeListID ) AS A                                                                                                            
--UNPIVOT                                                                                                                                  
--(                                                                                                                      
--PromoCodeID FOR                                                                                                                                                      
--PromoCode IN (PromoCodeID1,PromoCodeID2,PromoCodeID3,PromoCodeID4)                                                                                                                                                   
--) AS A INNER JOIN [db-au-stage].dbo.cdg_dimPromocode_AU_AG AS B ON PromoCodeID=B.DimPromoCodeID                                                                                              
--WHERE PromoCodeID<>'-1'                                                                                                                                 
--) AS B GROUP BY B.PromoCodeListID,b.SessionID,b.FactQuoteID) AS J1                                                                                                                                                      
--WHERE J1.SessionID=A.SessionID AND J1.FactQuoteID=A.FactQuoteID                                                                        
--)J                                                                                                                                                    
                                                                                                            
--OUTER APPLY                                                                                                                                                     
--(                                                                  
--select k1.factpolicyid,k1.policynumber,k1.sessionid,k1.contactid,HasEMC from [db-au-stage].dbo.cdg_factPolicy_AU_AG as k1                         
--where a.sessionid=k1.sessionid                                                  
--) k                                                                                                                           
                                                                                                      
--OUTER APPLY                                                                                      
--(                      
--SELECT DimGroupTypeID,GroupTypeName,GroupTypeNameShort FROM [db-au-stage].dbo.cdg_dimGroupType_AU_AG AS Y1X                                                                                                                                       
--WHERE Y1X.DimGroupTypeID=A.GroupTypeID                                                                                                              
--)  AS YX                                                  
                                                
--OUTER APPLY                                                
--(                            
--select                   
--json_value([PartnerMetaData],'$.LinkID') as LinkID,                  
--json_value([PartnerMetaData],'$.gclid') as gclid,                  
--json_value([PartnerMetaData],'$.gaClientID') as gaClientID                  
                  
--,Sessiontoken from [db-au-stage].dbo.cdg_SessionPartnerMetaData_AU                                                 
--as Y2X WHERE y2x.Sessiontoken=e.SessionToken AND                   
--PartnerMetaData like '%LinkID%gclid%gaClientID%'                                                
--) AS YZ          
        
--OUTER APPLY        
--(        
--SELECT         
--SessionID,         
--count(*) as [Total_number_of_insured],        
--count(case when IsAdult=1 then SessionID end) as [Insured_num_of_adults],        
--count(case when IsChild=1 then SessionID end) as [Insured_num_of_childs]          
        
--FROM [db-au-stage].dbo.cdg_factTraveler_AU AS ZZX WHERE  ZZX.SessionID=a.SessionID        
--group by SessionID        
        
        
--)  as zz                                            
                              
--OUTER APPLY                                                                                                                       
--(select distinct CompanyKey,countrykey,PolicyNumber,PolicyID,PolicyKey,OutletAlphaKey,OutletSKey,IssueDate,PrimaryCountry as Destination,        Area,Excess,TripCost,PlanName,AreaCode,AreaName,AreaNumber,AreaType,TripStart,TripEnd,                     
    
    
      
        
          
            
              
                
                  
                    
                      
                         
                 
                             
                             
                                                  
--datediff(day,TripStart,TripEnd)+1 as Trip_Duration,TripType,PlanCode,datediff(day,IssueDate,TripStart)  as [Days_To_Departure] ,MultiDestination,CancellationCover,ExternalReference1  from [db-au-cmdwh].[dbo].penPolicy as M1  with (nolock)               
    
    
      
        
          
            
              
                            
                    
                      
                        
                          
                            
                              
                                
                                                                     
--where  AlphaCode in ('BPN0001','BPN0002') and                                                                                                                                                 
--  k.PolicyNumber collate SQL_Latin1_General_CP1_CI_AS =m1.PolicyNumber                                  
--  and convert(date,IssueDate,103)=convert(date,a.Quote_Date,103)                              
--  --PolicyNumber in (                                                                                              
--  --select PolicyNumber from [db-au-cmdwh].[dbo].penPolicy where AlphaCode in ('BPN0001','BPN0002')                                                                                                                          
--  --and convert(date,IssueDate,103)=convert(date,getdate()-1,103)                                                                                             
--  --union                                                                                                                                                  
--  --select distinct a.PolicyNumber from [db-au-cmdwh].[dbo].penPolicy as a inner join [db-au-cmdwh].[dbo].penPolicyTransaction                                                                            
--  --as b on a.PolicyKey=b.PolicyKey  where AlphaCode in ('BPN0001','BPN0002') and convert(date,b.IssueDate,103)=convert(date,getdate()-1,103))                                                                                                               
    
    
      
                  
                    
                      
                        
                          
                            
                            
        
                                   
                                    
                                      
                                        
                                          
                                           
-- --AlphaCode in ('BPN0001','BPN0002') and convert(date,IssueDate,103)=convert(date,getdate()-1,103)                                                                                                                                  
-- )m                                                                                                                   
                              
                                           
--outer apply (                                                          
--    select distinct n1.commission,n1.newpolicycount,n1.BasePremium,n1.SingleFamilyFlag,n1.AdultsCount,n1.ChildrenCount,           n1.TravellersCount,PostingDate,PolicyTransactionKey,n1.PolicyKey,                                                  
-- isnull(GrossPremium-TaxAmountGST-TaxAmountSD,'') as Total_Gross_Premium ,GrossPremium,TaxAmountGST,TaxAmountSD                                                  
                                      
                                                   
-- from [db-au-cmdwh].[dbo].penPolicyTransSummary                                                   
                                                    
                                                      
                                                                           
--  n1  with (nolock)                                                                                                 
-- where m.PolicyKey=n1.PolicyKey and TransactionType='Base' and  TransactionStatus='Active')n                                                                                
                                                            
-- outer apply                                                                              
-- (                                                                              
-- select PolicyKey,GrossPremium,BasePremium from(                                                                                  
--  select tptx.PolicyKey,sum(tpp.GrossPremium) as GrossPremium,sum(BasePremium) as BasePremium  FROM   [db-au-cmdwh].[dbo].penPolicyPrice   tpp  with (nolock)                                                                               
--      INNER JOIN [db-au-cmdwh].[dbo].penPolicyTravellerTransaction  tptt with (nolock) ON   tptt.PolicyTravellerTransactionID = tpp.ComponentID                                                                                  
--   and tpp.CountryKey=tptt.CountryKey and tpp.CompanyKey=tptt.CompanyKey                                       
--       INNER JOIN [db-au-cmdwh].[dbo].penPolicyTraveller tpt with (nolock) ON   tpt.PolicyTravellerkey = tptt.PolicyTravellerkey                              
--    and tptt.CountryKey=tpt.CountryKey and tptt.CompanyKey=tpt.CompanyKey                                                                                  
--       INNER JOIN [db-au-cmdwh].[dbo].penPolicyTransaction tptx with (nolock) ON   tptx.policytransactionkey = tptt.policytransactionkey                                                                                  
--    and tpt.CountryKey=tptx.CountryKey and tpt.CompanyKey=tptx.CompanyKey                                                                                  
--       WHERE     tpp.groupid=2 and isPOSDiscount=1 and tpp.CompanyKey='TIP'                                                                             
--    group by tptx.PolicyKey) as z11 where z11.PolicyKey=m.PolicyKey                                                           
--  ) z22                                                                               
                                                                            
                  
--outer apply (                                                                                                                                                                                            
--  select distinct o1.policytravellerkey,o1.Title,o1.FirstName,o1.LastName,o1.EmailAddress,o1.MobilePhone,o1.State,o1.DOB,o1.Age,PostCode,o1.PolicyKey,   o1.AddressLine1+' '+o1.AddressLine2+' '+o1.Suburb AS PolicyHolder_Address,                          
    
    
     
        
           
           
               
               
                   
                   
                       
                       
                          
                             
                              
                                
                                  
                                    
                                      
                                        
                                          
                         
                                              
                                                
                                                                         
                                                                                                                                                       
--(select min(DOB) as OldestTraveller_DOB from [db-au-cmdwh].[dbo].penPolicyTraveller as c with (nolock) where c.PolicyKey=o1.PolicyKey and CountryKey='AU'     and CompanyKey='TIP' group by PolicyID)                                                        
    
    
      
        
          
            
              
                
                  
                    
                      
                                                                                                     
--  as OldestTraveller_DOB ,                                                                                                                                                                                  
--  (select max(AGE) as OldestTraveller_AGE from [db-au-cmdwh].[dbo].penPolicyTraveller as c with (nolock) where c.PolicyKey=o1.PolicyKey and CountryKey='AU'                                                                                         
--  and CompanyKey='TIP' group by PolicyID)                                                                                                                           
--  as OldestTraveller_Age,  
--  CASE WHEN PIDValue LIKE '%^%' then substring(PIDValue,1,charindex('^',pidvalue)-1) end                               
--  as  GAID        
  
  
--  from [db-au-cmdwh].[dbo].penPolicyTraveller o1  with (nolock)                                                                                        
--  where m.PolicyKey=o1.PolicyKey and isPrimary='1' )o                                                                                                                                                                       
                                                                                               
--  outer apply (                                    
--    select distinct p1.PolicyTransactionID ,p1.TransactionType,p1.PolicyTransactionKey,p1.TransactionStatus,p1.TransactionDateTime,p1.PolicyKey                                                                                 
-- from [db-au-cmdwh].[dbo].penPolicyTransaction p1  with (nolock)                                                                                                                                                               
--  where m.PolicyKey=p1.PolicyKey and n.PolicyTransactionKey=p1.PolicyTransactionKey)p                                                                                                                                                     
                                                                                               
--  outer apply (               
--   select distinct y1.AlphaCode,y1.OutletName,y1.Channel, y1.subgroupname     from  [db-au-cmdwh].[dbo].penOutlet y1  with (nolock)                                                                                                                         
     
   
      
        
           
            
              
                
                  
                    
                     
                        
                           
                            
                              
                                
                                  
                                    
                                     
                                         
                                         
                                    
                                                                                                           
--  where m.CountryKey=y1.CountryKey and m.CompanyKey=y1.CompanyKey and m.OutletAlphaKey=y1.OutletAlphaKey and m.OutletSKey=y1.OutletSKey and OutletStatus='Current')y                 outer apply (                                                
                                    
                                      
                                        
                                          
                                           
                                               
                                           
                                                  
                                       
                                                      
                                          
                                                             
                                                                       
--    select distinct t1.PromoCode,t1.Discount,t1.PromoName,t1.PromoType,t1.PolicyTransactionKey                                                                                                                                                           
--    from [db-au-cmdwh].[dbo].penPolicyTransactionPromo t1  with (nolock)                                                                                                                          
--  where t1.PolicyNumber=m.PolicyNumber and t1.CountryKey = 'AU' AND t1.CompanyKey = 'TIP')t                                                                                           
                    
                     
                                                                                                   
--  outer apply ( select sum(ppp.GrossPremium) 'AdventureActivities_Premium',pao.AddonValueDesc,                                                                                          
--  CASE WHEN pao.AddOnCode='ADVACT' then pao.AddonValueDesc else 'No' End as AdventureActivities_Flag                                             
-- from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyAddOn pao with (nolock) on ppp.ComponentID = pao.PolicyAddOnID                                                                                                  
    
   
      
         
          
            
              
               
                   
                    
                      
                        
                          
                            
                              
                               
                                   
                                    
                                      
                                        
                                          
                                            
              
                                           
                                                  
-- join [db-au-cmdwh].[dbo].penPolicyTransaction ppt with (nolock) on pao.PolicyTransactionKey = ppt.PolicyTransactionKey                                                            
-- where ppt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in ('ADVACT','ADVACT2','ADVACT3','ADVACT4')                                    
    
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                                     
                                         
                          
                                            
                                              
                                                                                                     
-- group by pao.AddonValueDesc,pao.AddOnCode)s                                                                                                                        
                                                                                                                                                                   
--   outer apply ( select sum(ppp.GrossPremium) 'Motorcycle_Premium',pao.DisplayName,                                                                        
--   CASE WHEN pao.AddOnCode in ('MTCLTWO','MTCL') then pao.DisplayName else 'No' End as Motorbike_Flag                                                                                       
-- from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyAddOn pao with (nolock) on ppp.ComponentID = pao.PolicyAddOnID                          
-- join [db-au-cmdwh].[dbo].penPolicyTransaction ppt with (nolock) on pao.PolicyTransactionKey = ppt.PolicyTransactionKey                                                                                   
-- where ppt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in( 'MTCLTWO' ,'MTCL')                                                         
   
     
      
        
         
             
              
                
                  
              
                      
                       
                          
                             
                              
                                
                                  
                                    
                                      
                                        
                                         
                                            
                              
                                                
                                                  
                                                    
                                 
                                                                    
                                                                                      
                                                                    
                                                                                               
-- group by pao.DisplayName,pao.AddOnCode)s1                                   
                                                                     
--  outer apply ( select sum(ppp.GrossPremium) 'Cruise_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='CRS' then 'Yes' else 'No' End as Cruise_Flag                                                                                                          
    
    
     
         
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                                      
                                        
                                          
                                  
                                              
                                                
-- from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                              
    
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                                      
                                        
                                          
                                            
                                              
                                                
                                                  
                                             
                                                      
                                                        
                                                          
                                                            
                                                              
                                                               
                      
                                                                    
                                                                                          
                                                                          
                                                                            
-- join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                                                                                      
    
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
-- join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                                  
                          
                            
                              
                                
                                  
                                    
                                      
                                        
                                          
                                            
                                              
                                                
                                               
-- where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in( 'CRS','CRS','CRS2' )                                                      
    
    
      
        
          
            
              
                
                  
                    
                     
                         
                  
                            
                              
                                
                                  
                                    
                                      
                                        
                                          
                                            
                                              
                                             
                                                 
-- group by pao.DisplayName,pao.AddOnCode) u                 
                                        
-- outer apply (  select sum(ppp.GrossPremium) 'Cancellation_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='CANX' then 'Yes' else 'No' End as Cancellation_Flag                                                                                            
     
    
      
        
          
            
              
                
                  
                    
                      
                       
                           
                            
                              
                      
                                  
                                    
                                      
                                        
                                          
                                            
                                              
                                                                        
                                                    
                                                      
                                                        
                                                       
                                                            
                                                             
-- from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                   
                                                                            
-- join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                                                                                      
    
    
      
        
          
            
              
               
                   
                    
                      
                        
                          
      
                              
                                
                                  
                                    
-- join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                      
                      
                        
-- where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'CANX'                                                                      
    
    
      
        
          
            
              
                
                 
                     
                      
                        
                          
                            
                              
                                
                                  
                                    
                                      
                                       
                                           
                                            
                                              
                                                
                                                  
                                                                                                             
-- group by pao.DisplayName,pao.AddOnCode) o1                                           
                                                                                                     
-- outer apply ( select sum(ppp.GrossPremium) 'Covid_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='COVCANX' then 'Yes' else 'No' End as Covid_Flag                                                                                                         
    
    
      
        
         
             
              
                
                  
                    
                      
                        
         
                            
                             
                                
-- from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                              
    
   
-- join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'               
-- join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                                                        
    
   
                          
                            
                              
                                
                                  
                                    
                                      
                                        
                                          
                                           
                                               
                                               
                                                   
-- where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'COVCANX'                                                                   
    
    
      
        
          
           
               
                
                  
                    
                     
                         
                          
                            
                              
                          
                                  
                                    
                        
                                        
                                          
                                            
                                              
                                                
                                                  
                                                    
                                             
                                                        
                                                          
-- group by pao.DisplayName,pao.AddOnCode) o2                                                                                                                                                                      
                                                                                                    
-- outer apply (  select sum(ppp.GrossPremium) 'Luggage_Premium',pao.AddonName,CASE WHEN pao.AddOnCode='LUGG' then 'Yes' else 'No' End as Luggage_Flag                                                                                                         
    
-- from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                              
    
    
      
        
          
            
              
               
                   
                    
                      
                       
                           
                            
                              
                                
                                  
                                    
                                      
                                        
                                          
                                            
                                              
               
                                                  
                                                    
-- join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                                                                                   
-- join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                                                       
    
-- where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'LUGG'                                                                      
    
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                      
                                     
                                         
                                          
                                            
                                              
                                                
                                                  
                                                    
                                                      
                                                       
                                                           
                                                            
                        
                                                               
                                                           
                                                                    
                                                                      
                                                                        
                                                                          
                                                                            
                                                                             
                                                                                 
                                                                                  
                                                            
-- group by pao.AddonName,pao.AddOnCode) o3                                          
                                                                                                                                                    
-- outer apply ( select sum(ppp.GrossPremium) 'SnowSports_Premium',pao.AddonName,CASE WHEN pao.AddOnCode in ('SNSPRTS','SNSPRTS2','SNSPRTS3','WNTS') then pao.AddonName else 'No' End as SnowSports_Flag                                                       
    
    
      
       
         
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                                      
                                        
                                         
                                             
                                              
                                                
                                                  
                                                    
                                                      
                                                        
                                                          
                                                            
                                                              
                                                                
                                                                  
                                                                    
                                                         
                  
                                                                          
                                                                    
                                                                           
                                                                                
                                                                                 
                                                                                   
-- from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                
                                                                
                                                                  
                                                                    
                                    
                                                                        
                                                                          
                                                                            
-- join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                                                                               
-- join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                                                        
    
    
     
         
          
            
             
                 
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                                      
                                        
                                          
                                            
                                              
                                                
                                                  
-- where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode  in ('SNSPRTS','SNSPRTS2','SNSPRTS3','WNTS')                                  
    
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                                      
                                        
                                          
                                
                                              
                                                
                                                  
                                                    
                                                      
                                          
                                                          
                                                           
                                                              
-- group by pao.AddonName,pao.AddOnCode) o4                                                                                                                                     
                                                                                                                                           
-- outer apply ( select sum(ppp.GrossPremium) 'PEMC_Premium',CASE WHEN pptt.HasEMC = 1 then 'Yes' else 'No' End as 'PEMC_Flag'                                                                             
--from [db-au-cmdwh].[dbo].penPolicyPrice ppp join [db-au-cmdwh].[dbo].penPolicyEMC ppe on ppp.ComponentID = ppe.PolicyEMCID and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and ppp.GroupID = 5 and ppp.isPOSDiscount = 1                         
        
          
            
             
                 
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                                      
                                        
                                          
                                            
                                              
                                                
                                                  
                                                   
                                                       
                                       
                                                          
                                                            
                                                              
                                                                
                                                                 
                                
                                                     
                                                                        
                                                                         
                                                                            
                                                                               
                                                                               
                                                                                                              
-- join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt on ppe.PolicyTravellerTransactionKey = pptt.PolicyTravellerTransactionKey and pptt.HasEMC = 1                                                                       
-- where pptt.PolicyTravellerKey = o.PolicyTravellerKey                                                                                                                                                            
-- group by pptt.HasEMC) o5                                                                                                                       
                                                
-- outer apply( select sum([Sell Price]) 'Total_Premium',sum([GST on Sell Price]) 'GST_on_Total_Premium',sum([Stamp Duty on Sell Price]) 'Stamp_Duty_on_Total_Premium',sum(NAP) 'NAP'                                
                      
                        
                          
                            
                              
                               
                                   
                                    
                                      
                                        
                                          
                                            
                                              
                                                
                                                  
                                                    
                                                     
                          
                                                          
                                                            
                    
                                                                
                                                                 
                                                                   
                                                                      
                        
-- from [db-au-cmdwh].[dbo].vPenguinPolicyPremiums ppp with (nolock)                                                                                                                                                          
--  where ppp.PolicyTransactionKey=n.PolicyTransactionKey                                                                                                              
-- ) q                                                                                                                 
  
-- union  
-- -- Missing Penguin Quotes  
  
-- select            
           
--CreateDate as [Extract date]          
--,QuoteID as  [quote_id]          
--,CreateDate as [created_datetime]          
--,PolicyNumber as [policy_number]          
--,DepartureDate as [eff_start_date]          
--,ReturnDate as [eff_end_date]          
--,SessionID AS [slug]          
--,replace(a2.MultiDestination,',',';') as [travel_country_list]          
--,replace(a2.Area,',','') COLLATE Latin1_General_CI_AS as [region_list]          
--,CASE WHEN M.PolicyNumber IS NOT NULL THEN M.PlanCode ELSE a2.ProductCode COLLATE DATABASE_DEFAULT END AS [Plan_Code]          
--,case   when m.PolicyNumber is not null then m.PlanName else a2.PlanName COLLATE DATABASE_DEFAULT END as [Plan]          
--,'Bupa' as [Partner]          
--,case                                                                                   
                                                                                 
--when y1.AlphaCode collate Latin1_General_CI_AS='BPN0002' Then 'Online'                                                                                   
--when y1.AlphaCode collate Latin1_General_CI_AS='BPN0001' Then 'Call Centre'                                                                           
--End                                                                                  
--as  [Channel]          
--,z33.Total as [Insured_num_of_adults]          
--,z33.Child_Count as [Insured_num_of_childs]          
--,z33.Adult_Count as [Total_number_of_insured]          
--,datediff(DAY,DepartureDate,ReturnDate)+1 AS [trip_duration]          
--,isnull(r14.Cruise_Flag,'No') as [Additional cover.Cruise_Flag]          
--,isnull(r12.Covid_Flag, 'No') as [Additional cover.Covid_Flag]          
--,isnull(r16.Luggage_Flag,'No') as[Additional cover.Luggage_Flag] ,isnull(r20.SnowSports_Flag,'No') as [Additional cover.Snow_Sports_Flag]          
--,isnull(r22.AdventureActivities_Flag,'No') as [Additional cover.Adventure_Activities_Flag]          
--,isnull(case when m.PolicyNumber is not null then s1.Motorbike_Flag else  r18.Motorbike_Flag end,'No') as [Additional cover.Motorbike_Flag]          
--,isnull(HasEMC,'No') as [Additional cover.PEMC_Flag]          
--,[Total_premium]          
--,cast(ISNULL(z23.GrossPremium,'')as decimal(10,4)) AS [Premium breakdown.Base_Premium]          
--,CASE WHEN m.PolicyNumber IS NULL THEN a2.GrossPremium ELSE      
--cast(ISNULL(n.Total_Gross_Premium,'')as decimal(10,4)) END AS [Premium breakdown.Total_Gross_Premium]          
--,cast(ISNULL(u.Cruise_Premium,'')as decimal(10,4)) AS [Premium breakdown.Cruise_Premium]          
--,cast(ISNULL(s.AdventureActivities_Premium,'')as decimal(10,4)) AS [Premium breakdown.Adventure_Activities_Premium]          
--,cast(ISNULL(s1.Motorcycle_Premium,'')as decimal(10,4)) AS  [Premium breakdown.Motorcycle_Premium]          
--,cast(ISNULL(Cancellation_Premium,'')as decimal(10,4)) AS [Premium breakdown.Cancellation_Premium]          
--,cast(ISNULL(Covid_Premium,'')as decimal(10,4)) AS [Premium breakdown.Covid_Premium]          
--,cast(ISNULL(o3.Luggage_Premium,'')as decimal(10,4)) AS [Premium breakdown.Luggage_Premium]          
--,cast(ISNULL(o4.SnowSports_Premium,'')as decimal(10,4)) AS [Premium breakdown.Snow_Sports_Premium]          
--,cast(ISNULL(PEMC_Premium,'')as decimal(10,4)) AS [Premium breakdown.PEMC_Premium]    
--,cast(ISNULL(n.TaxAmountGST, '')as decimal(10,4)) as [Premium breakdown.GST_on_Total_Premium]          
--,cast(ISNULL(n.TaxAmountSD, '')as decimal(10,4)) as  [Premium breakdown.Stamp_Duty_on_Total_Premium]          
--,q.NAP AS [NAP]          
--,cast(ISNULL(a2.Excess,'')as decimal(10,4))  AS [Excess]          
--,ISNULL(CASE                                                                                                                                   
--WHEN A2.PlanName='Comprehensive' AND convert(VARCHAR(300),r3.AddOnItem)='1' THEN '10000'                                                             
--WHEN A2.PlanName='Essential' AND convert(VARCHAR(300),r3.AddOnItem)='1' THEN '5000'                                                                                            
--WHEN  convert(VARCHAR(300),r3.AddOnItem)='-1' THEN 'Unlimited'                                                      
--else convert(VARCHAR(300),r3.AddOnItem) end ,0)                                                         
--AS  [Cancellation_sum_insured]          
--,replace(o.Title,',',' ') AS [policy_holder.title]          
--,replace(o.FirstName,',',' ') AS [policy_holder.first_name]          
--,replace(o.LastName,',',' ') AS  [policy_holder.last_name]          
--,o.EmailAddress AS  [policy_holder.email]          
--,o.MobilePhone AS [policy_holder.mobile]          
--,o.DOB as [policy_holder.dob]          
--,o.Age as [policy_holder.age]          
--,replace(o.PolicyHolder_Address,',','') AS  [policy_holder.address]          
--,o.State AS [policy_holder.state]          
--,case when m.PolicyNumber is not null then PostCode end as [policy_holder.postcode]          
--,case when m.PolicyNumber is not null then GAID end as [policy_holder.GNAF]          
                                                                                                               
                                                                                                                
--FROM (                                                                                                                  
--SELECT CreateDate,A.QuoteID,PolicyKey,DepartureDate,ReturnDate,MultiDestination,a.Area,OutletAlphaKey,a.QuoteCountryKey,SessionID,                                                                                                                           
  
--b.GrossPremium,b.Excess,b.PlanDisplayName as PlanName,B.ProductCode                                                                                              
--from [db-au-cmdwh].[dbo].penQuote as a with (nolock) inner join  [db-au-cmdwh].[dbo].penQuoteSelectedPlan                              
--as b on a.QuoteCountryKey=b.QuoteCountryKey  and b.GrossPremium!='0.00'                              
                              
                              
-- where AgencyCode in ('BPN0001','BPN0002')                                                                                                                            
--and A.QuoteID  
--in  
--(  
--SELECT a.QuoteID                                                                               
--from [db-au-cmdwh].[dbo].penQuote as a with (nolock) inner join  [db-au-cmdwh].[dbo].penQuoteSelectedPlan                
--as b on a.QuoteCountryKey=b.QuoteCountryKey  and b.GrossPremium!='0.00'                
-- where AgencyCode in ('BPN0001','BPN0002')                                                                                                              
--and convert(date,CreateDate,103) between convert(date,@StartDate-7,103)  and convert(date,@StartDate-1,103)  
--except  
--select quote_id from [db-au-cmdwh]..QuoteFeed_TBL where substring(convert(varchar(60),quote_id),1,1)='7'  
  
  
--)                    
                    
           
                    
--)                                                                         
--as a2                                                                             
                             
--outer apply                                      
--(                                     
--select distinct y2.AlphaCode,y2.OutletName,y2.Channel from   [db-au-cmdwh].[dbo].penOutlet y2 with (nolock)                                                                                                                          
--where y2.OutletAlphaKey=a2.OutletAlphaKey and  OutletStatus='Current'                                                                                                                           
-- )y1                                                
--outer apply                                                        
--(                                                                                                                          
--select r1.PromoCode,r1.Discount from  [db-au-cmdwh].[dbo].penQuotePromo r1 with (nolock)                                                                                                                          
--where r1.QuoteCountryKey = a2.QuoteCountryKey                                                            
--)r                                                                                                                   
--outer apply                                                                                 
--(                                                                                                                          
                                                                      
--select QuoteCountryKey,case when convert(varchar(30),AddOnItem) like '%-%' then 'Unlimited' else convert(varchar(30),AddOnItem)                                                
-- end as AddOnItem  from (                                                                      
--select R2.QuoteCountryKey,                                                                      
--sum(convert(int,case when  AddOnItem='$Unlimited' then '-100' else REPLACE(REPLACE(AddOnItem,'$',''),',','') end))                                                                   
--as AddOnItem from  [db-au-cmdwh].[dbo].penQuoteAddOn r2                                                        
-- INNER JOIN  [db-au-cmdwh].[dbo].penQuote AS R3 with (nolock)    ON R2.QuoteCountryKey=r3.QuoteCountryKey                                                                       
-- where                                                                       
-- AddOnGroup='Cancellation' and r2.QuoteCountryKey = R3.QuoteCountryKey                                                                          
-- and AgencyCode in ('BPN0001','BPN0002')                                                                      
                                                                      
--group by r2.QuoteCountryKey  ) as a  where  a.QuoteCountryKey=a2.QuoteCountryKey                                                                    
                                                                      
                                                                      
--)r3                         
                                                                                                                  
--outer apply                                                                                        
-- (                                                                                        
--select distinct                 QuoteCountryKey,                                                                                        
--case when AddOnGroup='COVID-19 Cover' then 'Yes' end  'Covid_Flag'                                                                               
--from [db-au-cmdwh].[dbo].penQuoteAddOn as r11 where r11.QuoteCountryKey=a2.QuoteCountryKey                                                                                        
--and AddOnGroup='COVID-19 Cover') as r12                                                              
--outer apply                        
--(                                                                                        
--select distinct                                                            
--QuoteCountryKey,                                                                                        
--case when AddOnGroup in ('Cruise','Cruise Cover2') then 'Yes' end  'Cruise_Flag'                                                                                        
--from [db-au-cmdwh].[dbo].penQuoteAddOn as r13 where r13.QuoteCountryKey=a2.QuoteCountryKey                                                                                        
--and AddOnGroup in ('Cruise','Cruise Cover2')                                                                                        
--) as r14                                                                                        
--outer apply                                                                                        
--(                                               
--select distinct                                                                                         
--QuoteCountryKey,                                                                                        
--case when AddOnGroup in ('Luggage') then 'Yes' end  'Luggage_Flag'                                                                                        
--from [db-au-cmdwh].[dbo].penQuoteAddOn as r15 where r15.QuoteCountryKey=a2.QuoteCountryKey                                                                                        
--and AddOnGroup in ('Luggage')                                                                                        
--) as r16                                                                                        
--outer apply                                                                           
--(                                              
--select distinct                                                                                  
--QuoteCountryKey,                                                                                        
--case when AddOnGroup in ('Motorcycle') then AddOnName end  'Motorbike_Flag'                                                              
--from [db-au-cmdwh].[dbo].penQuoteAddOn as r17 where r17.QuoteCountryKey=a2.QuoteCountryKey               
--and AddOnGroup in ('Motorcycle')                                                                                        
--) as r18                                                                                        
--outer apply                                                                                        
--(      select distinct                                         
--QuoteCountryKey,                                                                                 
--case when AddOnGroup in ('Snow Sports','Snow Sports +','Snow Sports3','Winter Sport') then AddOnName end  'SnowSports_Flag'                                                                                        
--from [db-au-cmdwh].[dbo].penQuoteAddOn as r19 where r19.QuoteCountryKey=a2.QuoteCountryKey                                                                                        
--and AddOnGroup in ('Snow Sports','Snow Sports +','Snow Sports3','Winter Sport')                                        
--) as r20                                                                                        
--outer apply                                                                                        
--(                                         
--select distinct                                                                                     
--QuoteCountryKey,                                                                                        
--case when AddOnGroup in ('Adventure Activities 2','Adventure Activities3') then AddOnName end  'AdventureActivities_Flag'                                                                                        
--from [db-au-cmdwh].[dbo].penQuoteAddOn as r21 where r21.QuoteCountryKey=a2.QuoteCountryKey                                       
--and AddOnGroup in ('Adventure Activities 2','Adventure Activities3')                                                                                        
--) as r22                                                                                     
                                                                                                   
                                    
--outer apply                                                                                                    
--(                                                                                                    
                           
--select QuoteCountryKey,case when Total=No_Count then 'No' else 'Yes' end as HasEMC from (                                  
-- select QuoteCountryKey,count(*) as Total,                                  
-- count(case when HasEMC=1 then QuoteCountryKey end) as Yes_Count,                                  
-- count(case when HasEMC=0 then QuoteCountryKey end) as No_Count                                  
-- from [db-au-cmdwh].[dbo].penQuoteCustomer                                    
-- group by QuoteCountryKey) as a where a2.QuoteCountryKey=a.QuoteCountryKey                                  
                                  
--) as z       
  
--outer apply                                                                                                    
--(                                                                                                    
                           
--select QuoteCountryKey,                                 
-- count(*) as Total,                                  
-- count(case when PersonIsAdult=1 then QuoteCountryKey end) as Adult_Count,                                  
-- count(case when PersonIsAdult=0 then QuoteCountryKey end) as Child_Count                                  
-- from [db-au-cmdwh].[dbo].penQuoteCustomer as a    where a2.QuoteCountryKey=a.QuoteCountryKey                                    
-- group by QuoteCountryKey                                 
                                  
--) as z33     
                                                                                                                  
--outer apply                                                                                                                  
--(select distinct CompanyKey,countrykey,PolicyNumber,PolicyID,PolicyKey,OutletAlphaKey,OutletSKey,IssueDate,PrimaryCountry as Destination,        Area,Excess,TripCost,PlanName,AreaCode,AreaName,AreaNumber,AreaType,TripStart,TripEnd,                     
    
    
      
        
          
            
              
                
                  
                    
                                                 
           
--datediff(day,TripStart,TripEnd)+1 as Trip_Duration,TripType,PlanCode,datediff(day,IssueDate,TripStart)  as [Days_To_Departure] ,MultiDestination,CancellationCover,ExternalReference1  from [db-au-cmdwh].[dbo].penPolicy as M1  with (nolock)               
    
    
      
        
          
            
              
                
                  
                    
                                                            
--where  AlphaCode in ('BPN0001','BPN0002') and                                                                                             
--  a2.PolicyKey collate SQL_Latin1_General_CP1_CI_AS =m1.PolicyKey  --and m1.PlanName=a2.PlanName                               
--  and  convert(date,IssueDate,103)=convert(date,a2.CreateDate,103)                                 
--  --PolicyNumber in (                                                                      
--  --select PolicyNumber from [db-au-cmdwh].[dbo].penPolicy where AlphaCode in ('BPN0001','BPN0002')                                                                                                                                                     
--  --and convert(date,IssueDate,103)=convert(date,getdate()-1,103)                                                                                                                                                  
--  --union                                                                                                  
--  --select distinct a.PolicyNumber from [db-au-cmdwh].[dbo].penPolicy as a inner join [db-au-cmdwh].[dbo].penPolicyTransaction                                                                                                                               
    
    
      
--  --as b on a.PolicyKey=b.PolicyKey  where AlphaCode in ('BPN0001','BPN0002') and convert(date,b.IssueDate,103)=convert(date,getdate-1,103)                                                                                     
-- )m                          
                                                                                                 
--outer apply (                                                                                                                          
--    select distinct n1.commission,n1.newpolicycount,n1.BasePremium,n1.SingleFamilyFlag,n1.AdultsCount,n1.ChildrenCount,     n1.TravellersCount,PostingDate,PolicyTransactionKey,GrossPremium,n1.PolicyKey,                                                  
-- isnull(GrossPremium-TaxAmountGST-TaxAmountSD,'') as Total_Gross_Premium ,TaxAmountGST,TaxAmountSD                                                  
                                                   
-- from [db-au-cmdwh].[dbo].penPolicyTransSummary                                                                  
                                                                                                                   
--n1  with (nolock)                                                                         
-- where m.PolicyKey=n1.PolicyKey and TransactionType='Base' and TransactionStatus='Active' )n                               
                                                                               
-- outer apply                                                                              
-- (                                                                              
-- select PolicyKey,GrossPremium,BasePremium from(                                                                                  
--  select tptx.PolicyKey,sum(tpp.GrossPremium) as GrossPremium,sum(BasePremium) as BasePremium  FROM   [db-au-cmdwh].[dbo].penPolicyPrice   tpp  with (nolock)                                                                                  
--      INNER JOIN [db-au-cmdwh].[dbo].penPolicyTravellerTransaction  tptt with (nolock) ON   tptt.PolicyTravellerTransactionID = tpp.ComponentID                                                                              
--   and tpp.CountryKey=tptt.CountryKey and tpp.CompanyKey=tptt.CompanyKey                             
--       INNER JOIN [db-au-cmdwh].[dbo].penPolicyTraveller tpt with (nolock) ON   tpt.PolicyTravellerkey = tptt.PolicyTravellerkey                                          
--    and tptt.CountryKey=tpt.CountryKey and tptt.CompanyKey=tpt.CompanyKey                                                          
--       INNER JOIN [db-au-cmdwh].[dbo].penPolicyTransaction tptx with (nolock) ON   tptx.policytransactionkey = tptt.policytransactionkey                                                                                  
--    and tpt.CountryKey=tptx.CountryKey and tpt.CompanyKey=tptx.CompanyKey                                                                                  
--       WHERE     tpp.groupid=2 and isPOSDiscount=0 and tpp.CompanyKey='TIP'                                
--    group by tptx.PolicyKey) as z13 where z13.PolicyKey=m.PolicyKey                                                                                 
--  ) z23                                                                               
                                       
                         
--outer apply (                                                                                                                                                                            
--  select distinct o1.policytravellerkey,o1.Title,o1.FirstName,o1.LastName,o1.EmailAddress,o1.MobilePhone,o1.State,o1.DOB,o1.Age,PostCode,o1.PolicyKey,     o1.AddressLine1+' '+o1.AddressLine2+' '+o1.Suburb AS PolicyHolder_Address,                        
    
    
      
       
          
            
              
                
                   
             
                       
                       
                           
                           
                              
                                 
                                 
                                    
                                      
                                         
                                          
                                            
                                             
                                                
                                                   
                                                   
                                                       
                                          
                                                          
                                                           
                                                               
                                                                                                              
                                                                                                                                                        
--(select min(DOB) as OldestTraveller_DOB from [db-au-cmdwh].[dbo].penPolicyTraveller as c with (nolock) where c.PolicyKey=o1.PolicyKey and CountryKey='AU'     and CompanyKey='TIP' group by PolicyID)                                   as OldestTraveller_DOB   
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                                      
                                        
                                          
                                            
                                              
                                                
                                                  
                                                    
                                    
                                                        
                                          
                                                            
                                                              
                                                               
                                          
                                                                     
                                                                      
                                                                        
                                                                          
                                                                    
                                                                              
                                                                                
                                                   
                                                                                                           
--,                                                
--  (select max(AGE) as OldestTraveller_AGE from [db-au-cmdwh].[dbo].penPolicyTraveller as c with (nolock) where c.PolicyKey=o1.PolicyKey and CountryKey='AU'   
   
       
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                                      
                                        
                                          
                                            
                                              
                                                
                                                 
                                                     
                                                      
                                                        
                                                          
                                                            
                                                              
                          
                                                                   
                                                                    
                                                  
                                                                        
                                                                          
                            
                                                                              
                                                     
                                                                                 
--  and CompanyKey='TIP' group by PolicyID)                                         
--  as OldestTraveller_Age,  
    
--   CASE WHEN PIDValue LIKE '%^%' then substring(PIDValue,1,charindex('^',pidvalue)-1) end                               
--  as  GAID  
--  from [db-au-cmdwh].[dbo].penPolicyTraveller o1  with (nolock)                                                                                          
--  where m.PolicyKey=o1.PolicyKey and isPrimary='1' )o                                                                                                                                                                                            
                                                                   
--  outer apply (                                                                                                                                               
--    select distinct p1.PolicyTransactionID ,p1.TransactionType,p1.PolicyTransactionKey,p1.TransactionStatus,p1.TransactionDateTime,p1.PolicyKey                                                                                                             
     
    
     
         
          
            
              
                
                  
                   
                       
                        
                          
                            
                       
                                 
                                  
                                    
                                      
-- from [db-au-cmdwh].[dbo].penPolicyTransaction p1  with (nolock)                                                           
--  where m.PolicyKey=p1.PolicyKey and n.PolicyTransactionKey=p1.PolicyTransactionKey)p                                                                                  
                                                                                                                                                                                            
--  outer apply (                                                                                                      
--   select distinct y1.AlphaCode,y1.OutletName,y1.Channel, y1.subgroupname    from  [db-au-cmdwh].[dbo].penOutlet y1  with (nolock)                                                                                                            
--  where m.CountryKey=y1.CountryKey and m.CompanyKey=y1.CompanyKey and m.OutletAlphaKey=y1.OutletAlphaKey and m.OutletSKey=y1.OutletSKey and OutletStatus='Current')y   outer apply (                                                                      
                                                                                    
                             
                                                              
                                                                
                                                                  
                                                                    
                                                                      
                                                                       
                                                                          
                                                                            
                                                                                                    
--    select distinct t1.PromoCode,t1.Discount,t1.PromoName,t1.PromoType,t1.PolicyTransactionKey                                                                                                      
--    from [db-au-cmdwh].[dbo].penPolicyTransactionPromo t1  with (nolock)                                                                                                                                                                          
--  where t1.PolicyNumber=m.PolicyNumber and t1.CountryKey = 'AU' AND t1.CompanyKey = 'TIP')t                                                                             
                        
--  outer apply ( select sum(ppp.GrossPremium) 'AdventureActivities_Premium',pao.AddonValueDesc,                                                                                          
--  CASE WHEN pao.AddOnCode='ADVACT' then pao.AddonValueDesc else 'No' End as AdventureActivities_Flag                                                                                                             
-- from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyAddOn pao with (nolock) on ppp.ComponentID = pao.PolicyAddOnID                                     
                                                     
                                                         
-- join [db-au-cmdwh].[dbo].penPolicyTransaction ppt with (nolock) on pao.PolicyTransactionKey = ppt.PolicyTransactionKey                                                                                           
-- where ppt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in ('ADVACT','ADVACT2','ADVACT3','ADVACT4')                                    
   
     
     
         
         
            
               
                
                  
                    
                     
                         
                         
                            
                               
                                
                                  
                                    
                                      
                                        
                                         
                                            
                                               
                                                
                                                 
                                                     
                                                      
                                                        
                                                          
                          
                                               
                                                                 
                                                                  
                                                                    
                                                                     
                                           
                                                                          
                                                                            
                                           
                                                                               
                                                                                   
                                                                                   
                                       
                                                                                       
                              
-- group by pao.AddonValueDesc,pao.AddOnCode)s                                                            
                                                                                                                                            
--   outer apply ( select sum(ppp.GrossPremium) 'Motorcycle_Premium',pao.DisplayName,                                                                                          
--   CASE WHEN pao.AddOnCode in ('MTCLTWO','MTCL') then pao.DisplayName else 'No' End as Motorbike_Flag                                                     
-- from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyAddOn pao with (nolock) on ppp.ComponentID = pao.PolicyAddOnID                                                
                                                
                                                  
                                                    
                                                      
                                              
-- join [db-au-cmdwh].[dbo].penPolicyTransaction ppt with (nolock) on pao.PolicyTransactionKey = ppt.PolicyTransactionKey                                                                                                                   
-- where ppt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in( 'MTCLTWO' ,'MTCL')                                                         
    
    
      
        
          
            
              
                
                 
                     
                     
                         
                          
                  
                              
                               
                                   
                        
                                     
                                         
                 
                                           
                                               
                                                
                                                  
                                                    
                                                      
                                                        
                                                          
                                                            
                                   
                                                                
                                                                  
                                                                    
                                                                                      
                                                                                        
                                                 
-- group by pao.DisplayName,pao.AddOnCode)s1                                                                                                                                                                   
                                                                              
--  outer apply (  select sum(ppp.GrossPremium) 'Cruise_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='CRS' then 'Yes' else 'No' End as Cruise_Flag                                              
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
-- from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                    
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                      
                                        
                                          
                                            
                                              
                
                                                  
                                                    
                                                     
                                                         
                              
                                                           
                                                               
                                                                
                                                                  
                                                                    
                                                                      
                                
                                                                          
       
-- join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                                                                                     
     
   
       
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
-- join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                                            
-- where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in( 'CRS','CRS','CRS2' )                                                      
    
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
             
                                
                                  
                                    
                                      
                                        
                                          
                                            
                                              
-- group by pao.DisplayName,pao.AddOnCode) u                           
                                                                                                                               
-- outer apply ( select sum(ppp.GrossPremium) 'Cancellation_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='CANX' then 'Yes' else 'No' End as Cancellation_Flag                                                                                              
    
    
      
        
          
            
              
                
                  
                    
                     
                         
                          
              
                              
                                
                                  
                                    
                                      
                                        
                                          
                                            
                                              
                                               
                                                  
                                                     
                                                      
                                                       
                                                           
                                                            
-- from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                              
    
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                                      
                                        
                                          
                                            
                                              
                                                
                                                  
                                                    
                                                      
                                                        
                                                          
                                                            
                   
                                       
                                                                  
                                                                    
               
                                                                        
                                                                          
                                        
-- join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                            
-- join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                                                        
    
    
      
        
         
                                                
                                                  
-- where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'CANX'                                                                      
    
    
      
        
          
            
              
                                     
                                         
                                                                                     
-- group by pao.DisplayName,pao.AddOnCode) o1                
                                                                                                                                                                                  
-- outer apply ( select sum(ppp.GrossPremium) 'Covid_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='COVCANX' then 'Yes' else 'No' End as Covid_Flag                                                                                                         
    
    
     
         
          
            
              
                
                  
                    
                      
      
                           
                            
                              
                           
-- from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                              
    
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                 
                                     
                                      
                                        
                                          
                                  
                                               
                                                
                                                  
                                                    
                                                      
           
                                                          
                                                            
                                                              
                        
                                                                  
                                                     
                                                                     
                                                          
                                                                          
                                                                            
-- join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                                                                                    
-- join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                         
-- where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'COVCANX'                                                                   
   
     
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                                      
                                        
                                         
                                            
                                              
                                                
                                                  
                                                    
                                                 
                                                         
                                                          
-- group by pao.DisplayName,pao.AddOnCode) o2                                                                                                         
                                                                                                                 
-- outer apply ( select sum(ppp.GrossPremium) 'Luggage_Premium',pao.AddonName,CASE WHEN pao.AddOnCode='LUGG' then 'Yes' else 'No' End as Luggage_Flag                       
-- from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                           
    
      
        
          
            
              
                
                  
                   
                       
                        
                          
                            
                              
                                
                                  
                                    
                                      
                                        
                                          
                                            
                                              
                              
                                                  
                                                    
-- join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                                               
-- join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                                              
-- where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'LUGG'                                                                     
     
    
      
        
         
             
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                                      
                                        
                                          
                                            
                                              
                                                
                                                 
                                                     
                                                      
                 
                                                                                
                                                        
                                                                                     
-- group by pao.AddonName,pao.AddOnCode) o3                                                                
                                                                                                                                                                                  
-- outer apply ( select sum(ppp.GrossPremium) 'SnowSports_Premium',pao.AddonName,CASE WHEN pao.AddOnCode in ('SNSPRTS','SNSPRTS2','SNSPRTS3','WNTS') then pao.AddonName else 'No' End as SnowSports_Flag                                                       
    
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                   
                                
                                 
                                     
                                      
                                        
                                          
                                            
                                              
                                                
                                                  
                                                    
                          
                                                        
                                                          
                                                            
                                                             
                                         
                    
                                           
                                                                       
                               
                                                                         
                                                                            
                                                                               
                                                                               
                                                                                 
-- from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                              
    
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                                      
                                        
                                          
                                            
                                              
                                 
                                                  
                                                    
                                                      
                                                        
                                                          
                                                            
                                                              
                     
                                                                  
                                                                    
                
                                                                        
                                                                          
                                          
-- join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                                                                                      
    
    
      
        
          
            
              
        
                  
                    
                     
-- join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                                                        
    
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                                      
                                        
                                          
                                      
                                             
                                                
                                                  
-- where pptt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode  in ('SNSPRTS','SNSPRTS2','SNSPRTS3','WNTS')                                  
    
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                         
                                
                                        
                                          
                                            
                                          
                                                
                                                  
                                                    
                                                      
                                                        
                                                         
                                                             
                                                             
-- group by pao.AddonName,pao.AddOnCode) o4                                                                                                                                    
                                                                                                                                                                                  
-- outer apply ( select sum(ppp.GrossPremium) 'PEMC_Premium',CASE WHEN pptt.HasEMC = 1 then 'Yes' else 'No' End as 'PEMC_Flag'                                                                                                                                 
    
    
      
        
          
            
              
                
                  
                    
                   
                        
                         
-- from [db-au-cmdwh].[dbo].penPolicyPrice ppp join [db-au-cmdwh].[dbo].penPolicyEMC ppe on ppp.ComponentID = ppe.PolicyEMCID and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and ppp.GroupID = 5 and ppp.isPOSDiscount = 1                               
    
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                                      
                                        
                                          
                                            
                                   
                                                 
                          
                                                    
                                                      
                                                        
                                                          
                                                            
                                                              
                                                  
                                                                  
                                                                    
                                                                      
                                                                   
                     
                                                                            
                                       
                                                                               
                                                                                                                  
-- join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt on ppe.PolicyTravellerTransactionKey = pptt.PolicyTravellerTransactionKey and pptt.HasEMC = 1                                                                                                   
    
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                                      
                                        
                                    
                                            
                                              
                                                
                                                  
                                                    
                                                      
                                                       
-- where pptt.PolicyTravellerKey = o.PolicyTravellerKey                                                                                                
-- group by pptt.HasEMC) o5                                                                                                                                                                                   
                                                                                                                                                        
-- outer apply( select sum([Sell Price]) 'Total_Premium',sum([GST on Sell Price]) 'GST_on_Total_Premium',sum([Stamp Duty on Sell Price]) 'Stamp_Duty_on_Total_Premium',sum(NAP) 'NAP'                                                                          
    
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                                      
                                                                 
                                                
-- from [db-au-cmdwh].[dbo].vPenguinPolicyPremiums ppp with (nolock)                            
--  where ppp.PolicyTransactionKey=n.PolicyTransactionKey                                                                                                               
-- ) q     
  
-- ) as a  
  
  
  
SELECT * from Temp3  
 --UNION  
 --SELECT * FROM TEMP4  
  
  
END  
  
GO
