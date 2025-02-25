USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[Policy Data at Policy Level]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

    
    
    
                             
CREATE view [dbo].[Policy Data at Policy Level]                                                   
AS                                                  
                                              
    SELECT                                               
    DISTINCT                                               
    ISNULL(m.PostingDate,'') AS PostingDate,                                                  
    ISNULL(d.PolicyNumber,'') AS PolicyNumber,                                      
    ISNULL(m.PolicyTransactionKey,'') AS PolicyTransactionKey,                                               
    ISNULL(b.TransactionType,'') AS   TransactionType,                                                
    ISNULL(b.PolicyTransactionKey,'') as Transaction_Sequence_Number,                                                  
    ISNULL(b.TransactionStatus,'') as  Transaction_Status,                                                  
    ISNULL(b.TransactionDateTime,'') as Transaction_Date,                                                  
    ISNULL(d.IssueDate,'') as Sold_Date,                                              
    ISNULL(d.MultiDestination,'') as TravelCountries_List,                                         
    len(d.MultiDestination) - len(replace(d.MultiDestination, ';', '')) +1as Number_of_Countries,                                        
    '' as Primary_Country ,                                              
 ----d.Destination as Primary_Country,                                                 
    ISNULL(d.AreaName,'')  as Region_List,                                              
    ISNULL(d.Area,'') as Primary_Region,                                              
    ISNULL(d.AreaNumber,'') as Area_No,                                                  
    ISNULL(d.AreaType,'') as Area_Type,                                                 
    ISNULL(d.TripStart,'') as Departure_Date,                                              
    ISNULL([Days_To_Departure],'') as [Days_To_Departure],                                              
    ISNULL(d.TripEnd,'')  as Return_date,                                                  
    ISNULL([Trip_Duration],'') as [Trip_Duration],                                                  
    ISNULL(d.TripType,'') as [Trip_Type],                                                  
    ISNULL(d.PlanCode,'') as Plan_Code,                                                  
    ISNULL(d.PlanName,'') as [Plan],                                                  
    ISNULL(m.SingleFamilyFlag,'') as [Single/Family],                                                  
    ISNULL(m.AdultsCount,'') as [Number_of_Adults],                                                  
    ISNULL(m.ChildrenCount,'') as [Number_of_Children],                                                  
    ISNULL(m.TravellersCount,'') as [Total_Number_of_Insured],                                                
    ISNULL(d.Excess,'') as [Excess_Amount],                                                  
    --d.TripCost as ,                                                
    CancellationCover as [CancellationSumInsured],                                        
    ISNULL(Cruise_Flag,'') as Cruise_Flag,                                             
 ----Cancellation_Flag,                                        
    ISNULL(Covid_Flag,'') as Covid_Flag,                                        
    ISNULL(Luggage_Flag,'') as Luggage_Flag,                                        
    ISNULL(SnowSports_Flag,'') as SnowSports_Flag,                                       
    ISNULL([AdventureActivities_Flag],'') as  [AdventureActivities_Flag] ,                                            
    ISNULL([Motorbike_Flag] ,'') as    [Motorbike_Flag],                                           
 --   --'' as [Snowsports_Flag],                                              
 --   --CASE WHEN s.AddOnGroup in ('Luggage') then 'yes' else 'No' End as [Luggage_Flag],                                              
 --   --'' as [covid_Flag],                                              
ISNULL(PEMC_Flag,'') AS PEMC_Flag,                              
ISNULL(m.BasePremium,'') as Base_Premium,              
 ----o.DisplayName,o.GrossPremium,                                        
    ISNULL(q.Total_Premium,  '')-( ISNULL(q.GST_on_Total_Premium, '')+ISNULL(q.Stamp_Duty_on_Total_Premium,'')) as GrossPremium,                                              
    ISNULL(Cruise_Premium,'') AS Cruise_Premium,                                
    ISNULL([AdventureActivities_Premium],'') AS [AdventureActivities_Premium],                                   
    ISNULL(Motorcycle_Premium,  '') AS Motorcycle_Premium,                                      
    ISNULL(Cancellation_Premium,'') AS Cancellation_Premium,                                                                          
    ISNULL(Covid_Premium,  '') AS Covid_Premium,                                      
    ISNULL(Luggage_Premium, '') AS Luggage_Premium,                                       
    ISNULL(SnowSports_Premium,  '') AS SnowSports_Premium,                                      
    ISNULL(PEMC_Premium,  '') AS PEMC_Premium,                                      
    ISNULL(q.Total_Premium,  '') AS Total_Premium,                                      
    ISNULL(q.GST_on_Total_Premium, '') AS GST_on_Total_Premium,                                       
    ISNULL(q.Stamp_Duty_on_Total_Premium,'') AS Stamp_Duty_on_Total_Premium,                                       
    ISNULL(q.NAP,'') AS  NAP ,                                      
    ISNULL(a.Title,'') as Policyholder_Title,                                                
    convert(nvarchar(100),a.FirstName)as [Policyholder_First_Name],                                                  
    ISNULL(a.LastName,'') as [Policyholder_Surname],                                                  
    ISNULL(a.EmailAddress,'') as [Policyholder_Email],                                             
    ISNULL(a.MobilePhone,'') as [Policyholder_Mobile_Phone],                                                  
    ISNULL(a.State,'') as [Policyholder_State],                                           
    ISNULL(a.DOB,'') as PolicyHolder_DOB,                                        
    ISNULL(a.age,'') as PolicyHolder_Age,                              
    ISNULL(a.PostCode,'') as PolicyHolder_Postcode,                            
    ISNULL(A.PolicyHolder_Address,'') AS PolicyHolder_Address,                            
    ISNULL(a.OldestTraveller_DOB,'') AS  OldestTraveller_DOB,                                       
    ISNULL(a.OldestTraveller_Age,'') AS OldestTraveller_Age,                                                
    ISNULL(y.AlphaCode,'') as [Agency_Code],                                                  
    ISNULL(y.OutletName,'') as [Agency_Name],                                                  
    ISNULL(y.Channel,'') as Channel_Type,                                        
    ISNULL(y.subgroupname,'') as Brand,                                        
    '' as [PartnerLoading_Factor],                                              
    ISNULL(t.PromoCode,'') as [Promotional_Code],                                                
    ISNULL(convert(varchar(50),t.Discount),'') as [Promotional_Factor],                                                  
    ISNULL(m.Commission,'') [Commission_Amount],                                                  
    ISNULL(m.NewPolicyCount,'') [New_Policy_Count],                                              
    '' as [Group_State]                                                       
 from                                                  
(select distinct CompanyKey,countrykey,PolicyNumber,PolicyID,PolicyKey,OutletAlphaKey,OutletSKey,IssueDate,PrimaryCountry as Destination,        Area,Excess,TripCost,PlanName,AreaCode,AreaName,AreaNumber,AreaType,TripStart,TripEnd, datediff(day,TripStart
   
   
      
,TripEnd)+1 as Trip_Duration,TripType,PlanCode,                                              
datediff(day,IssueDate,TripStart)  as [Days_To_Departure] ,MultiDestination,CancellationCover                                             
  from [db-au-cmdwh].[dbo].penPolicy  with (nolock)                    
  where PolicyNumber in (           
  select distinct a.PolicyNumber from [db-au-cmdwh].[dbo].penPolicy as a inner join [db-au-cmdwh].[dbo].penPolicyTransaction        
  as b on a.PolicyKey=b.PolicyKey  where AlphaCode in ('BGD0001','BGD0002','BGD0003') and convert(date,b.IssueDate,103)=convert(date,getdate()-1,103))        
  --AlphaCode in ('BGD0001','BGD0002','BGD0003') and convert(date,IssueDate,103)=convert(date,getdate()-1,103)          
    and AlphaCode in ('BGD0001','BGD0002','BGD0003')    
        
 )d                                            
                                       
                                       
     outer apply (                                             
    select distinct m1.commission,m1.newpolicycount,m1.BasePremium,m1.SingleFamilyFlag,m1.AdultsCount,m1.ChildrenCount,           m1.TravellersCount,PostingDate,PolicyTransactionKey,GrossPremium,m1.PolicyKey from [db-au-cmdwh].[dbo].penPolicyTransSummary 
  
   
       
m1  with (nolock)  where m1.PolicyKey= d.PolicyKey and convert(date,m1.IssueDate,103)=convert(date,getdate()-1,103) )m                                            
                                                      
outer apply (                                                  
  select distinct a1.policytravellerkey,a1.Title,a1.FirstName,a1.LastName,a1.EmailAddress,a1.MobilePhone,a1.State,a1.DOB,a1.Age,PostCode,a1.PolicyKey,                            
  a1.AddressLine1+' '+a1.AddressLine2+' '+a1.Suburb AS PolicyHolder_Address,                                          
(select min(DOB) as OldestTraveller_DOB from [db-au-cmdwh].[dbo].penPolicyTraveller as c with (nolock) where c.PolicyKey=a1.PolicyKey and CountryKey='AU'                                           
  and CompanyKey='TIP' group by PolicyID)                                          
  as OldestTraveller_DOB ,                                        
  (select max(AGE) as OldestTraveller_AGE from [db-au-cmdwh].[dbo].penPolicyTraveller as c with (nolock) where c.PolicyKey=a1.PolicyKey and CountryKey='AU'                                           
  and CompanyKey='TIP' group by PolicyID)                                          
  as OldestTraveller_Age                                         
  from [db-au-cmdwh].[dbo].penPolicyTraveller a1  with (nolock)                                                  
  where d.PolicyKey=a1.PolicyKey and isPrimary='1' )a                                                  
                                                  
  outer apply (                                                  
    select distinct b1.PolicyTransactionID ,b1.TransactionType,b1.PolicyTransactionKey,b1.TransactionStatus,b1.TransactionDateTime,b1.PolicyKey   from [db-au-cmdwh].[dbo].penPolicyTransaction b1  with (nolock)                                              
  
    
  where d.PolicyKey=b1.PolicyKey and m.PolicyTransactionKey=b1.PolicyTransactionKey and convert(date,b1.IssueDate,103)=convert(date,getdate()-1,103) )b                                                  
                                                  
  outer apply (                                                  
   select distinct y1.AlphaCode,y1.OutletName,y1.Channel, y1.subgroupname                                                  
   from  [db-au-cmdwh].[dbo].penOutlet y1  with (nolock)                                                  
  where d.CountryKey=y1.CountryKey and d.CompanyKey=y1.CompanyKey and d.OutletAlphaKey=y1.OutletAlphaKey and d.OutletSKey=y1.OutletSKey)y                                                  
                                                    
  outer apply (                     
    select distinct t1.PromoCode,t1.Discount,t1.PromoName,t1.PromoType,t1.PolicyTransactionKey                                                  
    from [db-au-cmdwh].[dbo].penPolicyTransactionPromo t1  with (nolock)                      
  where t1.PolicyNumber=d.PolicyNumber and t1.CountryKey = 'AU' AND t1.CompanyKey = 'TIP')t                                               
                                                
  outer apply ( select sum(ppp.GrossPremium) 'AdventureActivities_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='ADVACT' then 'Yes' else 'No' End as AdventureActivities_Flag                                        
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyAddOn pao with (nolock) on ppp.ComponentID = pao.PolicyAddOnID                                        
 join [db-au-cmdwh].[dbo].penPolicyTransaction ppt with (nolock) on pao.PolicyTransactionKey = ppt.PolicyTransactionKey                                        
 where ppt.PolicyTransactionKey = m.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'ADVACT'                                        
 group by pao.DisplayName,pao.AddOnCode)s                                          
                                         
   outer apply ( select sum(ppp.GrossPremium) 'Motorcycle_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='MTCLTWO' then 'Yes' else 'No' End as Motorbike_Flag                                        
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyAddOn pao with (nolock) on ppp.ComponentID = pao.PolicyAddOnID                                        
 join [db-au-cmdwh].[dbo].penPolicyTransaction ppt with (nolock) on pao.PolicyTransactionKey = ppt.PolicyTransactionKey                                        
 where ppt.PolicyTransactionKey = m.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'MTCLTWO'                                        
 group by pao.DisplayName,pao.AddOnCode)s1                                          
                                              
  outer apply ( select sum(ppp.GrossPremium) 'Cruise_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='CRS' then 'Yes' else 'No' End as Cruise_Flag                                        
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                        
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                      
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                        
 where pptt.PolicyTransactionKey = m.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'CRS'                                        
 group by pao.DisplayName,pao.AddOnCode) o                                        
                                        
 outer apply ( select sum(ppp.GrossPremium) 'Cancellation_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='CANX' then 'Yes' else 'No' End as Cancellation_Flag                                        
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                        
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                        
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                        
 where pptt.PolicyTransactionKey = m.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'CANX'                                        
 group by pao.DisplayName,pao.AddOnCode) o1                                        
                                        
 outer apply ( select sum(ppp.GrossPremium) 'Covid_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='COVCANX' then 'Yes' else 'No' End as Covid_Flag                                        
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                        
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                        
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                        
 where pptt.PolicyTransactionKey = m.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'COVCANX'           
 group by pao.DisplayName,pao.AddOnCode) o2                                        
                                        
 outer apply ( select sum(ppp.GrossPremium) 'Luggage_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='LUGG' then 'Yes' else 'No' End as Luggage_Flag                                        
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                        
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                        
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                        
 where pptt.PolicyTransactionKey = m.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'LUGG'                                        
 group by pao.DisplayName,pao.AddOnCode) o3                                        
                                        
 outer apply ( select sum(ppp.GrossPremium) 'SnowSports_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='SNSPRTS' then 'Yes' else 'No' End as SnowSports_Flag                       
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                        
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                        
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                        
 where pptt.PolicyTransactionKey = m.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'SNSPRTS'                                        
 group by pao.DisplayName,pao.AddOnCode) o4                                        
                                        
 outer apply ( select sum(ppp.GrossPremium) 'PEMC_Premium',CASE WHEN pptt.HasEMC = 1 then 'Yes' else 'No' End as 'PEMC_Flag'                                        
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp join [db-au-cmdwh].[dbo].penPolicyEMC ppe on ppp.ComponentID = ppe.PolicyEMCID and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and ppp.GroupID = 5 and ppp.isPOSDiscount = 1                                
  
    
       
       
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt on ppe.PolicyTravellerTransactionKey = pptt.PolicyTravellerTransactionKey and pptt.HasEMC = 1                                        
 where pptt.PolicyTravellerKey = a.PolicyTravellerKey                                        
 group by pptt.HasEMC) o5                                         
                                         
 outer apply( select sum([Sell Price]) 'Total_Premium',sum([GST on Sell Price]) 'GST_on_Total_Premium',sum([Stamp Duty on Sell Price]) 'Stamp_Duty_on_Total_Premium',sum(NAP) 'NAP'                                        
 from [db-au-cmdwh].[dbo].vPenguinPolicyPremiums ppp with (nolock)                                                  
  where ppp.PolicyTransactionKey=m.PolicyTransactionKey                                            
 ) q 
GO
