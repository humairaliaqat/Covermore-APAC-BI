USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[Policy_Data_at_Policy_Level_Proc_Test1]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
          
          
          
          
          
          
          
          
          
-- CHANGE HISTORY          
   --2023-DEV-07 - CR-CHG0038288 - Replace comma with blank space for name fields                               
   --2024-APRIL-27- CR-CHG0039016-Added Quote_Reference_ID,Quote_Transaction_ID CTM  Columns                                            
                                              
                                              
CREATE Procedure [dbo].[Policy_Data_at_Policy_Level_Proc_Test1]  --'2024-09-24 22:53:30.887'                                                                         
@StartDate datetime                                                                                  
as                                                                                  
begin         
SELECT * FROM (        
        
 SELECT                                                                                                                                               
    DISTINCT                                                                                                                                               
    ISNULL(CONVERT(varchar(100),b.TransactionDateTime,120),'') AS Posting_Date,          
      ISNULL(Quote_Reference_ID,'') AS Quote_Reference_ID,                  
 ISNULL(Quote_Transaction_ID,'') AS Quote_Transaction_ID,                                                                                                                     
 ISNULL(d.PolicyNumber,'') AS Policy_Number,                                                                                                                                      
    --ISNULL(m.PolicyTransactionKey,'') AS PolicyTransactionKey,                                                                                                                                      
    case when b.TransactionType = 'Upgrade AMT Max Trip Duration' then 'UpgradeAMTMaxTripDuration' else ISNULL(b.TransactionType,'') end AS   Transaction_Type,                                                                              
    ISNULL(b.PolicyTransactionKey,'') as Transaction_Sequence_Number,                                                                                       ISNULL(b.TransactionStatus,'') as  Transaction_Status,                                             
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                                                                                     
    ISNULL(CONVERT(varchar(100),b.TransactionDateTime,120),'') as Transaction_Date,                                                                                                                                                  
    ISNULL(d.IssueDate,'') as Sold_Date,                                                                                                                                              
    ISNULL(d.MultiDestination,'') as Travel_Countries_List,                                                                                                                                         
    len(d.MultiDestination) - len(replace(d.MultiDestination, ';', '')) +1as Number_of_Countries,                                                                                                                      
    '' as Primary_Country ,                                                                                                                                              
 ----d.Destination as Primary_Country,                                                                                                                                                 
    ISNULL(replace(d.AreaName,',',';'),'')  as Region_List,     
    ISNULL(replace(d.Area,',',';'),'') as Primary_Region,                                                                                                    
    ISNULL(d.AreaNumber,'') as Area_No,                                                                                                                                         
    ISNULL(d.AreaType,'') as Area_Type,                                                                                                                                                 
    ISNULL(d.TripStart,'') as Departure_Date,               
    ISNULL([Days_To_Departure],'') as [Days_To_Departure],                                                  
    ISNULL(d.TripEnd,'') as Return_Date,                            
    ISNULL([Trip_Duration],'') as [Trip_Duration],                                                              
    ISNULL(d.TripType,'') as [Trip_Type],                                       
    ISNULL(d.PlanCode,'') as Plan_Code,                                           
    ISNULL(d.PlanName,'') as [Plan],                                                    
 --   ISNULL(                                            
 --case when m.SingleFamilyFlag='3' Then 'Single'                                                                
 --when m.SingleFamilyFlag='2' Then 'Family' end,'') as [Single_Family],                                                                      
                                                                       
 --ISNULL( case when x.Family_Count=1 Then 'Single' ELSE 'Family' END,'')                                                            
 --as [Single_Family],                                                                      
                                                                      
 CASE WHEN m3.AdultsCount>=2 AND  m3.ChildrenCount>=0                                                               
 THEN 'Family' ELSE 'Single' END AS [Single_Family],                                                                      
    ISNULL(m3.AdultsCount,'') as [Number_of_Adults],                                                                                                      
    ISNULL(m3.ChildrenCount,'') as [Number_of_Children],                                                                                                                                                  
    ISNULL(m3.TravellersCount,'') as [Total_Number_of_Insured],                                                                                                                 
    cast(ISNULL(d.Excess,'')as decimal(10,4)) as [Excess_Amount],                                                                                                                                           
    --d.TripCost as ,                                                                                                                                                
    replace(replace(CancellationCover,',',''),'$','') as [Cancellation_Sum_Insured],                                                                                              
    ISNULL(Cruise_Flag,'No') as Cruise_Flag,                                                                                                                       
 ----Cancellation_Flag,                                                                                                                    
    ISNULL(Covid_Flag,'No') as Covid_Flag,                                                                                                               
    ISNULL(Luggage_Flag,'No') as Luggage_Flag,                                                                                                                         
    ISNULL(SnowSports_Flag,'No') as Snow_Sports_Flag,                                                                                                                                       
    ISNULL([AdventureActivities_Flag],'No') as  [Adventure_Activities_Flag] ,                 
    ISNULL([Motorbike_Flag] ,'No') as    [Motorbike_Flag],                                                                                                                           
 --   --'' as [Snowsports_Flag],           
 --   --CASE WHEN s.AddOnGroup in ('Luggage') then 'yes' else 'No' End as [Luggage_Flag],                                                                                                                                              
 --   --'' as [covid_Flag],                                                                                                                                              
ISNULL(PEMC_Flag,'No') AS PEMC_Flag,                                       
cast(ISNULL(z.GrossPremium,'')as decimal(10,4)) as Base_Premium,                       
 ----o.DisplayName,o.GrossPremium,                                            
   -- cast(ISNULL(q.Total_Premium,  '')-( ISNULL(q.GST_on_Total_Premium, '')+ISNULL(q.Stamp_Duty_on_Total_Premium,''))as decimal(10,4)) as Total_Gross_Premium,                                           
   cast(ISNULL(q3.Total_Gross_Premium,'')as decimal(10,4)) as Total_Gross_Premium,                                          
                                            
                                        
    cast(ISNULL(Cruise_Premium,'')as decimal(10,4)) AS Cruise_Premium,                                                                       
    cast(ISNULL([AdventureActivities_Premium],'')as decimal(10,4)) AS [Adventure_Activities_Premium],                                            
    cast(ISNULL(Motorcycle_Premium,  '')as decimal(10,4)) AS Motorcycle_Premium,                                                                                                                                      
    cast(ISNULL(Cancellation_Premium,'')as decimal(10,4)) AS Cancellation_Premium,                                                                                             
 cast(ISNULL(Covid_Premium,  '')as decimal(10,4)) AS Covid_Premium,                                                                                                               
    cast(ISNULL(Luggage_Premium, '')as decimal(10,4)) AS Luggage_Premium,                                                                                                                                       
    cast(ISNULL(SnowSports_Premium,  '')as decimal(10,4)) AS Snow_Sports_Premium,                                                       
    cast(ISNULL(PEMC_Premium,  '')as decimal(10,4)) AS PEMC_Premium,                                                                   
    cast(ISNULL(q3.GrossPremium,  '')as decimal(10,4)) AS Total_Premium,                                                                                          
    cast(ISNULL(q3.TaxAmountGST, '')as decimal(10,4)) AS GST_on_Total_Premium,                                                                                       
    cast(ISNULL(q3.TaxAmountSD,'')as decimal(10,4)) AS Stamp_Duty_on_Total_Premium,                                                                                                                        
    cast(ISNULL(q.NAP,'')as decimal(10,4)) AS  NAP ,                                                                                                                                      
    convert(varchar(500),ISNULL(replace(a.Title,',',' '),'')) as Policy_Holder_Title,                                                                                                                                
    convert(varchar(500),replace(a.FirstName,',',' '))as [Policy_Holder_First_Name],                                                                                                                                                  
    convert(varchar(500),ISNULL(replace(a.LastName,',',' '),'')) as [Policy_Holder_Surname],                    
  ISNULL(a.EmailAddress,'') as [Policy_Holder_Email],                                     
    ISNULL(a.MobilePhone,'') as [Policy_Holder_Mobile_Phone],                        
    ISNULL(a.State,'') as [Policy_Holder_State],                                                                                                                        
    ISNULL(a.DOB,'') as Policy_Holder_DOB,                                                                                                                                        
    ISNULL(a.age,'') as Policy_Holder_Age,                                                                                                                              
  ISNULL(a.PostCode,'') as Policy_Holder_PostCode,                                                           
    ISNULL(replace(A.PolicyHolder_Address,',',''),'') AS Policy_Holder_Address,                     
     ISNULL(GAID,'') as Policy_Holder_GNAF,                                                                          
    ISNULL(a.OldestTraveller_DOB,'') AS  Oldest_Traveller_DOB,                                                                                                                                       
    ISNULL(a.OldestTraveller_Age,'') AS Oldest_Traveller_Age,                                                                  
    ISNULL(y.AlphaCode,'') as [Agency_Code],                                 
    [Agency_Name],                                                                                   
case                                          
when y.AlphaCode='BGD0001' Then 'Direct Online'          
when y.AlphaCode='AGN0001' Then 'Direct Online'                                                               
when y.AlphaCode='BGD0002' Then 'Call Centre'                                                               
when y.AlphaCode='BGD0003' Then 'Call Centre'          
when y.AlphaCode='AGN0002' Then 'Call Centre'                                                               
End as Channel_Type,                                                              
                                    
    Brand,                                                                                         
    --'' as [PartnerLoading_Factor],                                                                                                                                              
ISNULL(                                                  
case when t.PromoCode is  null then r.Promotional_Code else t.PromoCode end,'') as [Promotional_Code],                                                                                                                                           
ISNULL(convert(varchar(50),                                                  
case when t.Discount is  null then r.Promotional_Factor else  t.Discount end),'') as [Promotional_Factor],                                           
 cast(ISNULL(m.Commission,'')as decimal(10,4)) [Commission_Amount],                                                                                 
 ISNULL(m.NewPolicyCount,'') [New_Policy_Count]                                                                          
    --'' as [Group_State]                                                                                                                                                       
 from                                                          
(select distinct CompanyKey,countrykey,PolicyNumber,PolicyID,PolicyKey,OutletAlphaKey,OutletSKey,IssueDate,PrimaryCountry as Destination,   Area,Excess,TripCost,PlanName,AreaCode,AreaName,AreaNumber,AreaType,TripStart,TripEnd,                            
  
    
      
datediff(day,TripStart, TripEnd)+1 as Trip_Duration,TripType,PlanCode,                                                                                                                         
datediff(day,IssueDate,TripStart)  as [Days_To_Departure] ,replace(MultiDestination,',','') AS MultiDestination,                                                    
CASE WHEN CancellationCover='1000000' THEN 'Unlimited' else CancellationCover end as CancellationCover,                     
'Budget Direct' as [Agency_Name],'Budget Direct' as Brand,          
ExternalReference1,          
ExternalReference2 AS Quote_Transaction_ID,                  
ExternalReference3 AS   Quote_Reference_ID           
                                                            
  from [db-au-cmdwh].[dbo].penPolicy  with (nolock)                                                                                                                    
  where PolicyNumber in (                                                                                                           
  select distinct a.PolicyNumber from [db-au-cmdwh].[dbo].penPolicy  as a with (nolock) inner join [db-au-cmdwh].[dbo].penPolicyTransaction                                                                                                        
  as b with (nolock) on a.PolicyKey=b.PolicyKey  where AlphaCode in ('BGD0001','BGD0002','BGD0003','AGN0001','AGN0002') and                                                                                   
  convert(date,b.IssueDate,103)=Convert(date,@StartDate,103)      
  union      
  select distinct a.PolicyNumber from [db-au-cmdwh].[dbo].penPolicy  as a with (nolock) inner join [db-au-cmdwh].[dbo].penPolicyTransSummary                                                                                                        
  as b with (nolock) on a.PolicyKey=b.PolicyKey  where AlphaCode in ('BGD0001','BGD0002','BGD0003','AGN0001','AGN0002') and                                                                                   
  convert(date,b.PostingDate,103)=Convert(date,@StartDate,103)      
      
        
  )                                                                                                     
  --AlphaCode in ('BGD0001','BGD0002','BGD0003','AGN0001','AGN0002') and convert(date,IssueDate,103)=convert(date,getdate()-1,103)                                                                                                          
    and AlphaCode in ('BGD0001','BGD0002','BGD0003','AGN0001','AGN0002')                                                                                              
                                                                                               
 )d                          
                       
                      
   outer apply (                                                                                  
    select distinct b1.PolicyTransactionID ,b1.TransactionType,b1.PolicyTransactionKey,b1.TransactionStatus,b1.TransactionDateTime,                                                                      
 b1.PolicyKey   from [db-au-cmdwh].[dbo].penPolicyTransaction b1  with (nolock)                                                   
                                                                         
                                                       
  where d.PolicyKey=b1.PolicyKey                             
  --and m.PolicyTransactionKey=b1.PolicyTransactionKey                             
  and                                                                                   
  convert(date,b1.IssueDate,103)=Convert(date,@StartDate,103) )b                       
                                                                                                                                       
                                                                                                                                       
     outer apply (                         
    select distinct m1.commission,m1.newpolicycount,m1.BasePremium 'BasePremium',PostingDate,PolicyTransactionKey,GrossPremium,m1.PolicyKey from                                                
 [db-au-cmdwh].[dbo].penPolicyTransSummary                                                                  
                                                      
 m1  with (nolock)  where m1.PolicyKey= d.PolicyKey and convert(DATE,m1.IssueDate,103)=Convert(date,@StartDate,103)                      
 and m1.PolicyTransactionKey=b.PolicyTransactionKey  )m                                               
                                               
 outer apply                                              
 (                                              
                              
 select  PolicyKey,AdultsCount,ChildrenCount,TravellersCount,SingleFamilyFlag                                              
 from  [db-au-cmdwh].[dbo].penPolicyTransSummary as m2 with (nolock)                                              
  where m2.PolicyKey=d.PolicyKey and TransactionType='Base'  and TransactionStatus='Active'                                            
 ) m3                                              
                                                                       
 outer apply                                                                      
 (                                                
 select count(*) as Family_Count from [db-au-cmdwh].[dbo].penPolicyTraveller as x1 with (nolock) where x1.PolicyKey=d.PolicyKey and CountryKey='AU' and CompanyKey='TIP' group by PolicyKey              
 ) x                                                     
                                                                                                                                                      
outer apply (                                                                           
  select distinct a1.policytravellerkey,a1.Title,a1.FirstName,a1.LastName,a1.EmailAddress,a1.MobilePhone,a1.State,a1.DOB,a1.Age,PostCode,a1.PolicyKey,                                                                                     
  a1.AddressLine1+' '+a1.AddressLine2+' '+a1.Suburb AS PolicyHolder_Address,                                                                                                                         
(select min(DOB) as OldestTraveller_DOB from [db-au-cmdwh].[dbo].penPolicyTraveller as c with (nolock) where c.PolicyKey=a1.PolicyKey and CountryKey='AU'                                                                                                      
  
   
      
        
           
           
              
  and CompanyKey='TIP' group by PolicyID)                                                                  
  as OldestTraveller_DOB ,                                                                                                   
  (select max(AGE) as OldestTraveller_AGE from [db-au-cmdwh].[dbo].penPolicyTraveller as c with (nolock) where c.PolicyKey=a1.PolicyKey and CountryKey='AU'                                                                                                    
  
    
      
                  
                    
                      
                        
                          
                            
                               
                               
                                  
                                    
                                      
                                        
  and CompanyKey='TIP' group by PolicyID)                                                                                                                          
  as OldestTraveller_Age,                              
  CASE WHEN PIDValue LIKE '%^%' then substring(PIDValue,1,charindex('^',pidvalue)-1) end                               
  as  GAID                                                                                                                                         
  from [db-au-cmdwh].[dbo].penPolicyTraveller a1  with (nolock)                       
  where d.PolicyKey=a1.PolicyKey and isPrimary='1' )a                                                                                                                                                  
                                                  
                                                                                                                                                 
                                    
  outer apply (                                                                                
   select distinct y1.AlphaCode,y1.OutletName,y1.Channel, y1.subgroupname         from  [db-au-cmdwh].[dbo].penOutlet y1  with (nolock)              
        
         
             
             
                 
                  
                   
                       
                        
                          
                            
                                                                                                                                          
  where d.CountryKey=y1.CountryKey and d.CompanyKey=y1.CompanyKey and d.OutletAlphaKey=y1.OutletAlphaKey and d.OutletSKey=y1.OutletSKey)y                                                      
                                                                                                                                                    
  outer apply (                                                                                  
    select distinct t1.PromoCode,convert(varchar(30),convert(decimal(10,4),t1.Discount*100))+' % Discount' as Discount,t1.PromoName,t1.PromoType,t1.PolicyTransactionKey                                                                                       
 
     
       
        
          
            
              
                                                          
    from [db-au-cmdwh].[dbo].penPolicyTransactionPromo t1  with (nolock)                                                                                                                      
  where t1.PolicyNumber=d.PolicyNumber and t1.CountryKey = 'AU' AND t1.CompanyKey = 'TIP')t                                                        
                                                          
  outer apply                                                        
  (                                                        
                                                        
  select policytransactionkey,GrossPremium,BasePremium from(                                                        
  select tptx.policytransactionkey,sum(tpp.GrossPremium) as GrossPremium,sum(BasePremium) as BasePremium  FROM   [db-au-cmdwh].[dbo].penPolicyPrice   tpp  with (nolock)                                                        
      INNER JOIN [db-au-cmdwh].[dbo].penPolicyTravellerTransaction  tptt with (nolock) ON   tptt.PolicyTravellerTransactionID = tpp.ComponentID                                                        
   and tpp.CountryKey=tptt.CountryKey and tpp.CompanyKey=tptt.CompanyKey                                                        
       INNER JOIN [db-au-cmdwh].[dbo].penPolicyTraveller tpt with (nolock) ON   tpt.PolicyTravellerkey = tptt.PolicyTravellerkey                                                        
    and tptt.CountryKey=tpt.CountryKey and tptt.CompanyKey=tpt.CompanyKey                                                        
       INNER JOIN [db-au-cmdwh].[dbo].penPolicyTransaction tptx with (nolock) ON   tptx.policytransactionkey = tptt.policytransactionkey                                                        
    and tpt.CountryKey=tptx.CountryKey and tpt.CompanyKey=tptx.CompanyKey                                                        
       WHERE     tpp.groupid=2 and isPOSDiscount=1 and tpp.CompanyKey='TIP'                                                        
    group by tptx.policytransactionkey) as z1 where z1.policytransactionkey=m.PolicyTransactionKey                                            
  ) z                                                        
                                                        
                               
  outer apply ( select sum(ppp.GrossPremium) 'AdventureActivities_Premium',pao.AddonValueDesc,                        
  CASE WHEN pao.AddOnCode='ADVACT' then pao.AddonValueDesc else 'No' End as AdventureActivities_Flag                                                                 
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyAddOn pao with (nolock) on ppp.ComponentID = pao.PolicyAddOnID                                          
                      
                            
                             
                            
                                  
                                    
 join [db-au-cmdwh].[dbo].penPolicyTransaction ppt with (nolock) on pao.PolicyTransactionKey = ppt.PolicyTransactionKey                                                                                                      
 where ppt.PolicyTransactionKey = m.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in ('ADVACT','ADVACT2','ADVACT3','ADVACT4')                                      
  
    
      
        
          
            
              
               
                  
                     
                                                                                
 group by pao.AddonValueDesc,pao.AddOnCode)s                                                                                        
                                                                                                                                         
 outer apply ( select sum(ppp.GrossPremium) 'Motorcycle_Premium',pao.AddonName,                                                                      
   CASE WHEN pao.AddOnCode in ('MTCLTWO','MTCL') then pao.AddonName else 'No' End as Motorbike_Flag                                                                                
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyAddOn pao with (nolock) on ppp.ComponentID = pao.PolicyAddOnID                                                                                                    
  
    
      
        
         
                                    
 join [db-au-cmdwh].[dbo].penPolicyTransaction ppt with (nolock) on pao.PolicyTransactionKey = ppt.PolicyTransactionKey                                                                                           
 where ppt.PolicyTransactionKey = m.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in( 'MTCLTWO' ,'MTCL')                                                           
  
    
      
        
          
            
              
                
                  
                    
                                                    
                                                                           
 group by pao.AddonName,pao.AddOnCode)s1                                                                                                                                          
                                               
  outer apply ( select sum(ppp.GrossPremium) 'Cruise_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='CRS' then 'Yes' else 'No' End as Cruise_Flag                                                                                                            
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                                
  
    
      
        
          
            
              
                
        
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                                      
                                        
                         
                                            
                                              
                                                
                                                
                                                    
                                                      
                                                        
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                               
 where pptt.PolicyTransactionKey = m.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in( 'CRS','CRS','CRS2' )                                                        
  
   
       
        
          
            
              
               
                   
                    
                      
                        
                          
                            
                             
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
                  
 outer apply ( select sum(ppp.GrossPremium) 'Luggage_Premium',pao.AddonName,CASE WHEN pao.AddOnCode='LUGG' then 'Yes' else 'No' End as Luggage_Flag                                                                      
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                      
                            
                              
                                
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                                                
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                       
 where pptt.PolicyTransactionKey = m.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'LUGG'                                                                        
  
    
      
        
          
            
              
                
                  
                   
                      
                        
                          
                             
                              
                                
                  
                                    
                                      
                                        
                                                       
               
 group by pao.AddonName,pao.AddOnCode) o3                                                                                                                              
                                                                
 outer apply (                                               
 select sum(ppp.GrossPremium) 'SnowSports_Premium',pao.AddonName,CASE WHEN pao.AddOnCode in ('SNSPRTS','SNSPRTS2','SNSPRTS3','WNTS') then pao.AddonName else 'No' End as SnowSports_Flag                                            
        
          
            
              
                
                  
                    
                                  
                          
                            
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                                
  
   
       
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                  
                                    
                                      
                                  
                                          
                                            
                                              
                                                 
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                                                                                        
  
    
     
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                 
          
            
              
                
                  
                    
                      
 where pptt.PolicyTransactionKey = m.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode  in ('SNSPRTS','SNSPRTS2','SNSPRTS3','WNTS')                           
                    
                      
                        
                          
                            
                              
                               
                                   
                                    
                                      
                                        
                                         
 group by pao.AddonName,pao.AddOnCode) o4                                                           
                                
 outer apply ( select sum(ppp.GrossPremium) 'PEMC_Premium',CASE WHEN pptt.HasEMC = 1 then 'Yes' else 'No' End as 'PEMC_Flag'                                                                                                                                   
  
    
     
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyEMC ppe with (nolock) on ppp.ComponentID = ppe.PolicyEMCID and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and ppp.GroupID = 5 and ppp.isPOSDiscount = 1     
  
    
     
        
           
            
              
               
                   
                    
                      
                        
                          
                            
                              
                                
                          
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on ppe.PolicyTravellerTransactionKey = pptt.PolicyTravellerTransactionKey and pptt.HasEMC = 1                                                                                      
      
        
          
            
              
                
                  
                    
                      
                        
                          
                            
                              
                                
                                                
                                   
 where --pptt.PolicyTravellerKey = a.PolicyTravellerKey   and                                             
 pptt.PolicyTransactionKey=m.PolicyTransactionKey                                                                                                                                     
 group by pptt.HasEMC) o5                                                                                                   
                                                  
 outer apply( select sum([Sell Price]) 'Total_Premium',sum([GST on Sell Price]) 'GST_on_Total_Premium',sum([Stamp Duty on Sell Price]) 'Stamp_Duty_on_Total_Premium',sum(NAP) 'NAP'                                                                            
 
     
      
        
         
             
              
                
                  
                    
                      
                       
                           
                            
                              
                                
                                  
                                    
                                      
                                        
                                          
                                     
                                            
 from [db-au-cmdwh].[dbo].vPenguinPolicyPremiums ppp with (nolock)                                                                                                                                  
  where ppp.PolicyTransactionKey=m.PolicyTransactionKey                                                                                                                                            
 ) q                                            
                                          
 outer apply                                          
 (                                          
                                           
 select isnull(GrossPremium-TaxAmountGST-TaxAmountSD,'') as Total_Gross_Premium ,GrossPremium,TaxAmountGST,TaxAmountSD,PolicyTransactionKey from                                   
 [db-au-cmdwh].[dbo].penPolicyTransSummary                                          
 as q2 with (nolock) where  q2.PolicyTransactionKey=m.PolicyTransactionKey                                          
 ) as q3                                          
                                          
                                          
 outer apply                                                  
 (                                                  
 SELECT PolicyNumber,a.SessionID,Code as Promotional_Code,                                                  
case when A.PromoCodeListID!='-1' then                                             
 convert(varchar(50),convert(decimal(10,4),isnull(convert(varchar(30),case when A.PromoCodeListID!='-1'                                                         
then (a.TotalGrossPremium-a.TotalAdjustedGrossPremium)/a.TotalGrossPremium*100 end),'')))+' % Discount' end                   
AS Promotional_Factor                                                   
                                                   
 from [db-au-stage].dbo.cdg_factQuote_AU AS a with (nolock) inner join [db-au-stage].dbo.cdg_factPolicy_AU                   
 as b with (nolock)  on a.SessionID=b.SessionID inner join [db-au-stage].dbo.cdg_dimPromoCodeList_AU as c with (nolock)                                                  
 on a.PromoCodeListID=c.DimPromoCodeListID inner join [db-au-stage].dbo.cdg_dimPromoCode_AU as  d1 with (nolock)                                                 
 on c.PromoCodeID1=d1.DimPromoCodeID                                                   
 WHERE c.PromoCodeID1!='-1' and  a.BusinessUnitID=142 AND a.CampaignID=335 and d.PolicyNumber=b.PolicyNumber collate SQL_Latin1_General_CP1_CI_AS                                                  
 )                                                  
 r             
             
 --Missing Data                   
             
 union            
            
 SELECT                                                                                                                                     
    DISTINCT                                                                                                                                                       
    ISNULL(CONVERT(varchar(100),b.TransactionDateTime,120),'') AS Posting_Date,          
      ISNULL(Quote_Reference_ID,'') AS Quote_Reference_ID,                  
 ISNULL(Quote_Transaction_ID,'') AS Quote_Transaction_ID,                                                                                                                             
 ISNULL(d.PolicyNumber,'') AS Policy_Number,                                                                                                                                              
    --ISNULL(m.PolicyTransactionKey,'') AS PolicyTransactionKey,                                     
    case when b.TransactionType = 'Upgrade AMT Max Trip Duration' then 'UpgradeAMTMaxTripDuration' else ISNULL(b.TransactionType,'') end AS   Transaction_Type,                                                                                      
    ISNULL(b.PolicyTransactionKey,'') as Transaction_Sequence_Number,                                                ISNULL(b.TransactionStatus,'') as  Transaction_Status,                                                                   
                       
                           
                            
                              
                                
                                  
                                    
                                      
                                        
                                                                                                             
    ISNULL(CONVERT(varchar(100),b.TransactionDateTime,120),'') as Transaction_Date,                                                                                                                                                          
    ISNULL(d.IssueDate,'') as Sold_Date,                                                                                      
    ISNULL(d.MultiDestination,'') as Travel_Countries_List,                      
    len(d.MultiDestination) - len(replace(d.MultiDestination, ';', '')) +1as Number_of_Countries,                                                                                                                              
    '' as Primary_Country ,                                                                                                                       
 ----d.Destination as Primary_Country,                                                                                                                                                         
    ISNULL(replace(d.AreaName,',',';'),'')  as Region_List,                                                                                                      
    ISNULL(replace(d.Area,',',';'),'') as Primary_Region,                   
    ISNULL(d.AreaNumber,'') as Area_No,                                                                                  
    ISNULL(d.AreaType,'') as Area_Type,                                                                                                                                                         
    ISNULL(d.TripStart,'') as Departure_Date,                                                                                                                                                      
    ISNULL([Days_To_Departure],'') as [Days_To_Departure],                             
    ISNULL(d.TripEnd,'')  as Return_Date,                                    
    ISNULL([Trip_Duration],'') as [Trip_Duration],                                                                      
    ISNULL(d.TripType,'') as [Trip_Type],                                               
    ISNULL(d.PlanCode,'') as Plan_Code,                                                   
    ISNULL(d.PlanName,'') as [Plan],                             
 --   ISNULL(                                                    
 --case when m.SingleFamilyFlag='3' Then 'Single'                                                                        
 --when m.SingleFamilyFlag='2' Then 'Family' end,'') as [Single_Family],                                                                              
                                                                               
 --ISNULL( case when x.Family_Count=1 Then 'Single' ELSE 'Family' END,'')                                                                 --as [Single_Family],                                                                              
                                                                              
 CASE WHEN m3.AdultsCount>=2 AND  m3.ChildrenCount>=0                                                                       
 THEN 'Family' ELSE 'Single' END AS [Single_Family],                                                                              
    ISNULL(m3.AdultsCount,'') as [Number_of_Adults],                                                                                                  
    ISNULL(m3.ChildrenCount,'') as [Number_of_Children],                                                                                                                                                          
    ISNULL(m3.TravellersCount,'') as [Total_Number_of_Insured],                                                                                                                         
    cast(ISNULL(d.Excess,'')as decimal(10,4)) as [Excess_Amount],                                                                                                                                                   
    --d.TripCost as ,                                                                                                                                                        
    replace(replace(CancellationCover,',',''),'$','') as [Cancellation_Sum_Insured],                                                                                                      
    ISNULL(Cruise_Flag,'No') as Cruise_Flag,                            
 ----Cancellation_Flag,                                                                                                                            
    ISNULL(Covid_Flag,'No') as Covid_Flag,                                                             
    ISNULL(Luggage_Flag,'No') as Luggage_Flag,                                                                                                                                 
    ISNULL(SnowSports_Flag,'No') as Snow_Sports_Flag,                                                                                                                                               
    ISNULL([AdventureActivities_Flag],'No') as  [Adventure_Activities_Flag] ,                                                                                                                      
    ISNULL([Motorbike_Flag] ,'No') as    [Motorbike_Flag],                                                                                                                                                   
 --   --'' as [Snowsports_Flag],                                                                                                                               
 --   --CASE WHEN s.AddOnGroup in ('Luggage') then 'yes' else 'No' End as [Luggage_Flag],                                                             
 --   --'' as [covid_Flag],                                                                                                                                                      
ISNULL(PEMC_Flag,'No') AS PEMC_Flag,                                                                                                                                      
cast(ISNULL(z.GrossPremium,'')as decimal(10,4)) as Base_Premium,                                                                                                                      
 ----o.DisplayName,o.GrossPremium,                                                      
   -- cast(ISNULL(q.Total_Premium,  '')-( ISNULL(q.GST_on_Total_Premium, '')+ISNULL(q.Stamp_Duty_on_Total_Premium,''))as decimal(10,4)) as Total_Gross_Premium,                                                   
   cast(ISNULL(q3.Total_Gross_Premium,'')as decimal(10,4)) as Total_Gross_Premium,                                                  
        
                                                
    cast(ISNULL(Cruise_Premium,'')as decimal(10,4)) AS Cruise_Premium,                                                                               
    cast(ISNULL([AdventureActivities_Premium],'')as decimal(10,4)) AS [Adventure_Activities_Premium],                                                    
    cast(ISNULL(Motorcycle_Premium,  '')as decimal(10,4)) AS Motorcycle_Premium,                                                                                                      
    cast(ISNULL(Cancellation_Premium,'')as decimal(10,4)) AS Cancellation_Premium,                         
 cast(ISNULL(Covid_Premium,  '')as decimal(10,4)) AS Covid_Premium,                                                                                                                       
    cast(ISNULL(Luggage_Premium, '')as decimal(10,4)) AS Luggage_Premium,                                                                                                                                               
    cast(ISNULL(SnowSports_Premium,  '')as decimal(10,4)) AS Snow_Sports_Premium,                                                               
    cast(ISNULL(PEMC_Premium,  '')as decimal(10,4)) AS PEMC_Premium,                                                                           
    cast(ISNULL(q3.GrossPremium,  '')as decimal(10,4)) AS Total_Premium,                                                                                                  
    cast(ISNULL(q3.TaxAmountGST, '')as decimal(10,4)) AS GST_on_Total_Premium,                               
    cast(ISNULL(q3.TaxAmountSD,'')as decimal(10,4)) AS Stamp_Duty_on_Total_Premium,                                                                                        
    cast(ISNULL(q.NAP,'')as decimal(10,4)) AS  NAP ,                                                                                
    convert(varchar(500),ISNULL(replace(a.Title,',',' '),'')) as Policy_Holder_Title,                                                                                                                                        
    convert(varchar(500),replace(a.FirstName,',',' '))as [Policy_Holder_First_Name],                                                                                                                                                          
    convert(varchar(500),ISNULL(replace(a.LastName,',',' '),'')) as [Policy_Holder_Surname],                           
    ISNULL(a.EmailAddress,'') as [Policy_Holder_Email],                                                                                    
    ISNULL(a.MobilePhone,'') as [Policy_Holder_Mobile_Phone],                                                                                                                                                          
    ISNULL(a.State,'') as [Policy_Holder_State],                                                        
    ISNULL(a.DOB,'') as Policy_Holder_DOB,                                                                                                                                                
    ISNULL(a.age,'') as Policy_Holder_Age,                                                                                                                                      
  ISNULL(a.PostCode,'') as Policy_Holder_PostCode,                                                                                                                                    
    ISNULL(replace(A.PolicyHolder_Address,',',''),'') AS Policy_Holder_Address,                                                                                  
     ISNULL(GAID,'') as Policy_Holder_GNAF,                                                                                  
    ISNULL(a.OldestTraveller_DOB,'') AS  Oldest_Traveller_DOB,                        
    ISNULL(a.OldestTraveller_Age,'') AS Oldest_Traveller_Age,                                                                          
    ISNULL(y.AlphaCode,'') as [Agency_Code],                                         
    [Agency_Name],                                                                                           
case                                                  
when y.AlphaCode='BGD0001' Then 'Direct Online'          
when y.AlphaCode='AGN0001' Then 'Direct Online'                                                               
when y.AlphaCode='BGD0002' Then 'Call Centre'                                                               
when y.AlphaCode='BGD0003' Then 'Call Centre'          
when y.AlphaCode='AGN0002' Then 'Call Centre'                                                                      
End as Channel_Type,                                                                      
                                         
    Brand,                                                                                                 
    --'' as [PartnerLoading_Factor],                                                                                                                                                      
ISNULL(                                                          
case when t.PromoCode is  null then r.Promotional_Code end,'') as [Promotional_Code],                                                                                                                                                   
ISNULL(convert(varchar(50),                                                          
case when t.Discount is  null then r.Promotional_Factor end),'') as [Promotional_Factor],                                                   
 cast(ISNULL(m.Commission,'')as decimal(10,4)) [Commission_Amount],                                                                                         
 ISNULL(m.NewPolicyCount,'') [New_Policy_Count]                                                                                  
    --'' as [Group_State]                                
 from                                                                  
(select distinct CompanyKey,countrykey,PolicyNumber,PolicyID,PolicyKey,OutletAlphaKey,OutletSKey,IssueDate,PrimaryCountry as Destination,   Area,Excess,TripCost,PlanName,AreaCode,AreaName,AreaNumber,AreaType,TripStart,TripEnd,                            
  
    
      
        
          
            
                
datediff(day,TripStart, TripEnd)+1 as Trip_Duration,TripType,PlanCode,                                                                                                                                 
datediff(day,IssueDate,TripStart)  as [Days_To_Departure] ,replace(MultiDestination,',','') AS MultiDestination,                                                            
CASE WHEN CancellationCover='1000000' THEN 'Unlimited' else CancellationCover end as CancellationCover,                                                                    
'Budget Direct' as [Agency_Name],'Budget Direct' as Brand,     
ExternalReference1,          
ExternalReference2 AS Quote_Transaction_ID,                  
ExternalReference3 AS   Quote_Reference_ID           
                                                                    
  from [db-au-cmdwh].[dbo].penPolicy  with (nolock)                                                                                
  where PolicyNumber in (                          
                            
  select A.PolicyNumber from  [db-au-cmdwh].[dbo].penPolicy  as a with (nolock) inner join [db-au-cmdwh].[dbo].penPolicyTransaction as b with (nolock) on a.PolicyKey=b.PolicyKey  where AlphaCode in ('BGD0001','BGD0002','BGD0003','AGN0001','AGN0002')      
 
     
      
        
                    
  and b.PolicyTransactionKey in (                          
                          
  select distinct PolicyTransactionKey from [db-au-cmdwh].[dbo].penPolicy  as a with (nolock) inner join                       
  [db-au-cmdwh].[dbo].penPolicyTransaction as b with (nolock) on a.PolicyKey=                        
b.PolicyKey  where AlphaCode in ('BGD0001','BGD0002','BGD0003','AGN0001','AGN0002') and                                                                                           
  convert(date,b.IssueDate,103) between Convert(date,@StartDate-7,103) and       Convert(date,@StartDate-1,103)                    
  Except                          
  select distinct Transaction_Sequence_Number from [db-au-cmdwh].[dbo].Policy_Tbl                  
  )                          
                            
  )                                                                                               
  --AlphaCode in ('BGD0001','BGD0002','BGD0003','AGN0001','AGN0002') and convert(date,IssueDate,103)=convert(date,getdate()-1,103)                                  
    and AlphaCode in ('BGD0001','BGD0002','BGD0003','AGN0001','AGN0002')                                                                                                            
                                                                                                                
 )d                                  
                               
                              
   outer apply (                                                                                          
    select distinct b1.PolicyTransactionID ,b1.TransactionType,b1.PolicyTransactionKey,b1.TransactionStatus,                          
 b1.TransactionDateTime,convert(date,b1.IssueDate,103) as IssueDate_Tran,                                                                              
 b1.PolicyKey   from [db-au-cmdwh].[dbo].penPolicyTransaction b1  with (nolock)                                                           
                                                                                 
                                             
  where d.PolicyKey=b1.PolicyKey                    
  --and m.PolicyTransactionKey=b1.PolicyTransactionKey                                     
  and    PolicyTransactionKey in (                                                                                       
  select distinct PolicyTransactionKey from [db-au-cmdwh].[dbo].penPolicy  as a with (nolock) inner join                       
  [db-au-cmdwh].[dbo].penPolicyTransaction as b with (nolock) on a.PolicyKey=                        
b.PolicyKey  where AlphaCode in ('BGD0001','BGD0002','BGD0003','AGN0001','AGN0002') and                                                                                     
  convert(date,b.IssueDate,103) BETWEEN  Convert(date,@StartDate-7,103) and Convert(date,@StartDate-1,103)                          
  Except                          
  select Transaction_Sequence_Number from [db-au-cmdwh].[dbo].Policy_Tbl                  
                    
  )                          
                            
  )b                               
                                               
                                                                                                                                               
     outer apply (                            
    select distinct m1.commission,m1.newpolicycount,m1.BasePremium 'BasePremium',PostingDate,PolicyTransactionKey,GrossPremium,m1.PolicyKey from                                                        
 [db-au-cmdwh].[dbo].penPolicyTransSummary                                                                          
                                                                            
 m1  with (nolock)  where m1.PolicyKey= d.PolicyKey                            
 --and convert(DATE,m1.IssueDate,103)=Convert(date,@StartDate,103)                              
 and m1.PolicyTransactionKey=b.PolicyTransactionKey  )m                                            
                                                       
 outer apply                                                      
 (                                                      
                                      
 select  PolicyKey,AdultsCount,ChildrenCount,TravellersCount,SingleFamilyFlag                                                      
 from  [db-au-cmdwh].[dbo].penPolicyTransSummary as m2 with (nolock)                                                      
  where m2.PolicyKey=d.PolicyKey and TransactionType='Base'  and TransactionStatus='Active'                                                    
 ) m3                                                      
                                                                               
 outer apply                                                                              
 (                                                        
 select count(*) as Family_Count from [db-au-cmdwh].[dbo].penPolicyTraveller as x1 with (nolock) where x1.PolicyKey=d.PolicyKey and CountryKey='AU' and CompanyKey='TIP' group by PolicyKey                                                                   
  
     
      
       
           
 ) x                                                             
                                                                                                                                                              
outer apply (                                                                                   
  select distinct a1.policytravellerkey,a1.Title,a1.FirstName,a1.LastName,a1.EmailAddress,a1.MobilePhone,a1.State,a1.DOB,a1.Age,PostCode,a1.PolicyKey,                                                                                             
  a1.AddressLine1+' '+a1.AddressLine2+' '+a1.Suburb AS PolicyHolder_Address,                                                                                                                                 
(select min(DOB) as OldestTraveller_DOB from [db-au-cmdwh].[dbo].penPolicyTraveller as c with (nolock) where c.PolicyKey=a1.PolicyKey and CountryKey='AU'                                                                                        
    
      
        
          
           
                  
                      
                      
  and CompanyKey='TIP' group by PolicyID)                                                                                                            
  as OldestTraveller_DOB ,                                                                                                           
  (select max(AGE) as OldestTraveller_AGE from [db-au-cmdwh].[dbo].penPolicyTraveller as c with (nolock) where c.PolicyKey=a1.PolicyKey and CountryKey='AU'                                                                                                   
   
    
     
         
          
           
             
                 
                 
                      
                      
                       
                          
                            
                              
                                
                                  
                                    
                                       
                                       
                                          
                                            
                     
                                                
  and CompanyKey='TIP' group by PolicyID)                                                                                                                
  as OldestTraveller_Age,                                      
  CASE WHEN PIDValue LIKE '%^%' then substring(PIDValue,1,charindex('^',pidvalue)-1) end                           
  as  GAID                                                                                                                                                 
  from [db-au-cmdwh].[dbo].penPolicyTraveller a1  with (nolock)                               
  where d.PolicyKey=a1.PolicyKey and isPrimary='1' )a                                                                                                                                                          
                                                                                                      
                                                                                                                                                         
                                            
  outer apply (                                                                                                                
   select distinct y1.AlphaCode,y1.OutletName,y1.Channel, y1.subgroupname                                                                                                            from  [db-au-cmdwh].[dbo].penOutlet y1  with (nolock)              
       
           
            
                  
                      
                      
                        
                          
                           
                               
                                
                                  
                                    
                                                                                                                                                  
  where d.CountryKey=y1.CountryKey and d.CompanyKey=y1.CompanyKey and d.OutletAlphaKey=y1.OutletAlphaKey and d.OutletSKey=y1.OutletSKey)y                                                              
                                                                                                                                                            
  outer apply (                                                                                          
    select distinct t1.PromoCode,t1.Discount,t1.PromoName,t1.PromoType,t1.PolicyTransactionKey                                                                                                                                                          
    from [db-au-cmdwh].[dbo].penPolicyTransactionPromo t1  with (nolock)                                                                                                                   
  where t1.PolicyNumber=d.PolicyNumber and t1.CountryKey = 'AU' AND t1.CompanyKey = 'TIP')t                                                                
                                                                  
  outer apply                                                                
  (                                                                
                                      
  select policytransactionkey,GrossPremium,BasePremium from(                                                                
  select tptx.policytransactionkey,sum(tpp.GrossPremium) as GrossPremium,sum(BasePremium) as BasePremium  FROM   [db-au-cmdwh].[dbo].penPolicyPrice   tpp  with (nolock)                                                                
      INNER JOIN [db-au-cmdwh].[dbo].penPolicyTravellerTransaction  tptt with (nolock) ON   tptt.PolicyTravellerTransactionID = tpp.ComponentID                                                                
   and tpp.CountryKey=tptt.CountryKey and tpp.CompanyKey=tptt.CompanyKey                                                                
       INNER JOIN [db-au-cmdwh].[dbo].penPolicyTraveller tpt with (nolock) ON   tpt.PolicyTravellerkey = tptt.PolicyTravellerkey                                                                
    and tptt.CountryKey=tpt.CountryKey and tptt.CompanyKey=tpt.CompanyKey                                                                
       INNER JOIN [db-au-cmdwh].[dbo].penPolicyTransaction tptx with (nolock) ON   tptx.policytransactionkey = tptt.policytransactionkey                                                                
    and tpt.CountryKey=tptx.CountryKey and tpt.CompanyKey=tptx.CompanyKey                                                                
 WHERE     tpp.groupid=2 and isPOSDiscount=1 and tpp.CompanyKey='TIP'                                                                
    group by tptx.policytransactionkey) as z1 where z1.policytransactionkey=m.PolicyTransactionKey                                                                
  ) z                                                                
                                                                
                                                                                                                                                        
  outer apply ( select sum(ppp.GrossPremium) 'AdventureActivities_Premium',pao.AddonValueDesc,                                  
  CASE WHEN pao.AddOnCode='ADVACT' then pao.AddonValueDesc else 'No' End as AdventureActivities_Flag                      
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyAddOn pao with (nolock) on ppp.ComponentID = pao.PolicyAddOnID                                                  
                              
                                    
                            
                                         
                                          
                                            
 join [db-au-cmdwh].[dbo].penPolicyTransaction ppt with (nolock) on pao.PolicyTransactionKey = ppt.PolicyTransactionKey                                                                                                              
 where ppt.PolicyTransactionKey = m.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in ('ADVACT','ADVACT2','ADVACT3','ADVACT4')                                     
  
    
       
        
          
            
                 
                       
                      
                        
                         
                             
                                                                                        
 group by pao.AddonValueDesc,pao.AddOnCode)s                                 
                                                                                                                                                 
   outer apply ( select sum(ppp.GrossPremium) 'Motorcycle_Premium',pao.AddonValueDesc,                                                                              
   CASE WHEN pao.AddOnCode in ('MTCLTWO','MTCL') then pao.AddonValueDesc else 'No' End as Motorbike_Flag                                                                                        
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyAddOn pao with (nolock) on ppp.ComponentID = pao.PolicyAddOnID                                                       
          
            
                  
                   
                                 
 join [db-au-cmdwh].[dbo].penPolicyTransaction ppt with (nolock) on pao.PolicyTransactionKey = ppt.PolicyTransactionKey                                                                                   
 where ppt.PolicyTransactionKey = m.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in( 'MTCLTWO' ,'MTCL')                                                          
   
    
     
         
          
            
                  
                      
                     
                         
                          
                            
     
                                                                                   
 group by pao.AddonValueDesc,pao.AddOnCode)s1                                                                                                                                                  
                                                       
  outer apply ( select sum(ppp.GrossPremium) 'Cruise_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='CRS' then 'Yes' else 'No' End as Cruise_Flag                                                                                                            
  
    
      
        
          
            
                  
                      
                      
                        
                          
                            
                 
                                
                                  
                                    
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                                
  
    
      
        
          
            
                  
                      
                     
                        
                          
                            
                              
                                          
                                    
                                      
                                  
                                          
                                            
                                              
                                                
                                                  
                                                    
                                                      
                                                        
                                                          
                                                            
                                                              
                                                                
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                                                                                        
  
    
      
        
          
            
                  
                      
                      
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                                       
 where pptt.PolicyTransactionKey = m.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in( 'CRS','CRS','CRS2' )                                                        
  
    
      
        
          
            
                  
                      
                      
                        
                          
                            
                              
                                
                                  
                                    
                                     
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
                                                                                         
 outer apply ( select sum(ppp.GrossPremium) 'Luggage_Premium',pao.AddonName,CASE WHEN pao.AddOnCode='LUGG' then 'Yes' else 'No' End as Luggage_Flag                                                                              
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                                
  
    
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                                                        
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                               
 where pptt.PolicyTransactionKey = m.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'LUGG'                                                                        
  
    
      
        
         
             
                  
                      
                      
                        
                          
    
 group by pao.AddonName,pao.AddOnCode) o3                                                                                                                                      
                                                                        
 outer apply (                                                       
 select sum(ppp.GrossPremium) 'SnowSports_Premium',pao.AddonName,CASE WHEN pao.AddOnCode in ('SNSPRTS','SNSPRTS2','SNSPRTS3','WNTS') then pao.AddonName else 'No' End as SnowSports_Flag                              
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                                
  
    
      
        
          
            
                  
                      
                     
                       
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID and pao.CountryKey = 'AU' AND pao.CompanyKey = 'TIP'                                                                                                                        
  
    
      
        
          
            
               
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                                                          
  
    
      
        
          
            
                  
                      
                      
                        
                          
                            
                              
 where pptt.PolicyTransactionKey = m.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode  in ('SNSPRTS','SNSPRTS2','SNSPRTS3','WNTS')                                    
  
    
      
                
 group by pao.AddonName,pao.AddOnCode) o4                                                      
                                                                                                                                                
 outer apply ( select sum(ppp.GrossPremium) 'PEMC_Premium',CASE WHEN pptt.HasEMC = 1 then 'Yes' else 'No' End as 'PEMC_Flag'                                                                                                                                   
  
    
     
         
          
            
               
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyEMC ppe with (nolock) on ppp.ComponentID = ppe.PolicyEMCID and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and ppp.GroupID = 5 and ppp.isPOSDiscount = 1     
  
    
      
        
          
            
                  
                      
                      
                        
                          
                              
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on ppe.PolicyTravellerTransactionKey = pptt.PolicyTravellerTransactionKey and pptt.HasEMC = 1                                                                                       
  
    
      
        
          
            
 where --pptt.PolicyTravellerKey = a.PolicyTravellerKey   and                                                     
 pptt.PolicyTransactionKey=m.PolicyTransactionKey                                                                                                                                             
 group by pptt.HasEMC) o5                                                                                                                                               
                                                                                                           
 outer apply( select sum([Sell Price]) 'Total_Premium',sum([GST on Sell Price]) 'GST_on_Total_Premium',sum([Stamp Duty on Sell Price]) 'Stamp_Duty_on_Total_Premium',sum(NAP) 'NAP'                                                                            
  
    
      
        
          
            
                  
                      
                      
                        
                          
                                          
                                                                
 from [db-au-cmdwh].[dbo].vPenguinPolicyPremiums ppp with (nolock)                                                                                                                                          
  where ppp.PolicyTransactionKey=m.PolicyTransactionKey                                                                                                                     
 ) q                                                    
                                                  
 outer apply                                                  
 (                                                  
                                                   
 select isnull(GrossPremium-TaxAmountGST-TaxAmountSD,'') as Total_Gross_Premium ,GrossPremium,TaxAmountGST,TaxAmountSD,PolicyTransactionKey from                                           
 [db-au-cmdwh].[dbo].penPolicyTransSummary               
 as q2 with (nolock) where  q2.PolicyTransactionKey=m.PolicyTransactionKey                                                  
 ) as q3                                                  
                                                  
                                                  
 outer apply                                                          
 (                                                          
 SELECT PolicyNumber,a.SessionID,Code as Promotional_Code,                                         
 isnull(convert(varchar(30),case when A.PromoCodeListID!='-1'                                                                 
then ceiling((convert(float,a.TotalGrossPremium)-convert(float,a.TotalAdjustedGrossPremium))/convert(float,a.TotalGrossPremium)*100) end)+' % Discount' ,'')   AS Promotional_Factor                                   
                                                           
 from [db-au-stage].dbo.cdg_factQuote_AU AS a with (nolock) inner join [db-au-stage].dbo.cdg_factPolicy_AU                                                          
 as b with (nolock)  on a.SessionID=b.SessionID inner join [db-au-stage].dbo.cdg_dimPromoCodeList_AU as c with (nolock)                                                          
 on a.PromoCodeListID=c.DimPromoCodeListID inner join [db-au-stage].dbo.cdg_dimPromoCode_AU as  d1 with (nolock)                                                         
 on c.PromoCodeID1=d1.DimPromoCodeID                                                           
 WHERE c.PromoCodeID1!='-1' and  a.BusinessUnitID=142 AND a.CampaignID=335 and d.PolicyNumber=b.PolicyNumber collate SQL_Latin1_General_CP1_CI_AS                                                          
 )                                                          
 r                
             
  ) AS A         
          
 where Policy_Number          
 in          
 (          
 select distinct PolicyNumber from [db-au-cmdwh].[dbo].penQuote p1 with(nolock) inner join           
 penPolicy as p2 with(nolock)  on p2.PolicyKey=p1.PolicyKey where AlphaCode           
 in('BGD0001','BGD0002','BGD0003','AGN0001','AGN0002')          
 UNION                                                      
SELECT PolicyNumber COLLATE  DATABASE_DEFAULT FROM [db-au-cmdwh].[dbo].cdg_factPolicy_AU_AG AS P2 WHERE BusinessUnitID=142  
) 
                                   
                                                    
  END           
          
          
          
          
          
GO
