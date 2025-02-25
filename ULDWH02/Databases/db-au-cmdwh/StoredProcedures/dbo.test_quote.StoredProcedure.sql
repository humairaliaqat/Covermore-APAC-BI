USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[test_quote]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[test_quote]
as

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
ISNULL(CASE                                                                                                                 
WHEN A2.PlanName='Comprehensive' AND convert(VARCHAR(300),r3.AddOnItem)='1' THEN '10000'                                           
WHEN A2.PlanName='Essential' AND convert(VARCHAR(300),r3.AddOnItem)='1' THEN '5000'                                                                          
WHEN  convert(VARCHAR(300),r3.AddOnItem)='-1' THEN 'Unlimited'                                                             
else convert(VARCHAR(300),r3.AddOnItem) end ,0)                                                                                                              
AS  CancellationSumInsured,                                                                                                                                   
isnull(r14.Cruise_Flag,'No') as Cruise_Flag,                                                                                                                
isnull(r22.AdventureActivities_Flag,'No') as  AdventureActivities_Flag ,                                                                                                 
isnull(r18.Motorbike_Flag,'No') as Motorbike_Flag ,                                                                                                                  
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
o.Title AS Policyholder_Title,                                                                          
o.FirstName AS Policyholder_First_Name,                                                                                                                                    
o.LastName AS  Policyholder_Surname,                                                                                                                                    
o.EmailAddress AS  Policyholder_Email,                       
o.MobilePhone AS  Policyholder_Mobile_Phone,                                                                     
replace(o.PolicyHolder_Address,',','') AS   Policyholder_Address,                                                                                        
o.DOB as PolicyHolder_DOB,                                                                                                                                    
o.Age as PolicyHolder_Age,                                                                                                                                    
o.State AS Policyholder_State,                                                                                                                                    
OldestTraveller_DOB,                                                                                                                                    
OldestTraveller_Age,                                                                         
y1.AlphaCode collate Latin1_General_CI_AS AS Agency_Code ,                                         
'Budget Direct' collate  Latin1_General_CI_AS AS Agency_Name,                                                                                                                 
'Budget Direct' collate   Latin1_General_CI_AS AS Brand,                 
case                                                                 
when y1.AlphaCode collate Latin1_General_CI_AS='BGD0001' Then 'Direct Online'                                                                 
when y1.AlphaCode collate Latin1_General_CI_AS='BGD0002' Then 'Call Centre'                                                                 
when y1.AlphaCode collate Latin1_General_CI_AS='BGD0003' Then 'Aggregation'                                                         
End                                                                
as Channel_Type,                                                                                                                          
isnull(r.PromoCode,'') AS Promotional_Code,                                                                                                  
isnull(convert(varchar(100),r.Discount)+'% Discount','') AS Promotional_Factor,                                                                                                  
SessionID AS [Session Token]                                                                                   
                                                                                                
                                                                                                
FROM (                                                                                                
SELECT CreateDate,A.QuoteID,PolicyKey,DepartureDate,ReturnDate,MultiDestination,a.Area,OutletAlphaKey,a.QuoteCountryKey,SessionID,                                                                                               
A.PlanName,b.GrossPremium,b.Excess                                                                
from [db-au-cmdwh].[dbo].penQuote as a with (nolock) inner join  [db-au-cmdwh].[dbo].penQuoteSelectedPlan
as b on a.QuoteCountryKey=b.QuoteCountryKey  and b.GrossPremium!='0.00'
and a.QuoteCountryKey in (select QuoteCountryKey from penQuote where AgencyCode in ('BGD0001','BGD0002','BGD0003')
--AND convert(date,CreateDate,103) in ('2023-10-16','2023-10-15','2023-10-14')
)


 where AgencyCode in ('BGD0001','BGD0002','BGD0003')                                                                                          
--and convert(date,CreateDate,103)=convert(date,@StartDate,103)
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
 and AgencyCode in ('BGD0001','BGD0002','BGD0003')                                                    
                                                    
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
                                           
where  AlphaCode in ('BGD0001','BGD0002','BGD0003') and                                                                                                                               
  a2.PolicyKey collate SQL_Latin1_General_CP1_CI_AS =m1.PolicyKey               
  --and  convert(date,IssueDate,103)=convert(date,@StartDate,103)               
  --PolicyNumber in (                                                    
  --select PolicyNumber from [db-au-cmdwh].[dbo].penPolicy where AlphaCode in ('BGD0001','BGD0002','BGD0003')                                                                                                                                   
  --and convert(date,IssueDate,103)=convert(date,getdate()-1,103)                                                                                                                                
  --union                                                                                
  --select distinct a.PolicyNumber from [db-au-cmdwh].[dbo].penPolicy as a inner join [db-au-cmdwh].[dbo].penPolicyTransaction                                                                                                                     
  --as b on a.PolicyKey=b.PolicyKey  where AlphaCode in ('BGD0001','BGD0002','BGD0003') and convert(date,b.IssueDate,103)=convert(date,getdate-1,103)                                                                   
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
(select min(DOB) as OldestTraveller_DOB from [db-au-cmdwh].[dbo].penPolicyTraveller as c with (nolock) where c.PolicyKey=o1.PolicyKey and CountryKey='AU'     and CompanyKey='TIP' group by PolicyID) as OldestTraveller_DOB ,                                                                       
  (select max(AGE) as OldestTraveller_AGE from [db-au-cmdwh].[dbo].penPolicyTraveller as c with (nolock) where c.PolicyKey=o1.PolicyKey and CountryKey='AU'                                                                                                                                 and CompanyKey='TIP' group by PolicyID)                       
  as OldestTraveller_Age                                                                                 
  from [db-au-cmdwh].[dbo].penPolicyTraveller o1  with (nolock)                                                                                        
  where m.PolicyKey=o1.PolicyKey and isPrimary='1' )o                                                                                                                                          
  outer apply (                                                                                                                             
    select distinct p1.PolicyTransactionID ,p1.TransactionType,p1.PolicyTransactionKey,p1.TransactionStatus,p1.TransactionDateTime,p1.PolicyKey      from [db-au-cmdwh].[dbo].penPolicyTransaction p1  with (nolock)                                         
  where m.PolicyKey=p1.PolicyKey and n.PolicyTransactionKey=p1.PolicyTransactionKey)p                                                                
                                                                                                                                                                          
  outer apply (                                                                                                                          
   select distinct y1.AlphaCode,y1.OutletName,y1.Channel, y1.subgroupname    from  [db-au-cmdwh].[dbo].penOutlet y1  with (nolock)                                                                                          
  where m.CountryKey=y1.CountryKey and m.CompanyKey=y1.CompanyKey and m.OutletAlphaKey=y1.OutletAlphaKey and m.OutletSKey=y1.OutletSKey and OutletStatus='Current')y   outer apply (  select distinct t1.PromoCode,t1.Discount,t1.PromoName,t1.PromoType,t1.PolicyTransactionKey                                                                                    
    from [db-au-cmdwh].[dbo].penPolicyTransactionPromo t1  with (nolock)                                                                                                                                                        
  where t1.PolicyNumber=m.PolicyNumber and t1.CountryKey = 'AU' AND t1.CompanyKey = 'TIP')t                                                                                                 
  outer apply ( select sum(ppp.GrossPremium) 'AdventureActivities_Premium',pao.AddonValueDesc,                                                                        
  CASE WHEN pao.AddOnCode='ADVACT' then pao.AddonValueDesc else 'No' End as AdventureActivities_Flag                                                                                                                                          
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyAddOn pao with (nolock) on ppp.ComponentID = pao.PolicyAddOnID                                                     
                                   
                                       
 join [db-au-cmdwh].[dbo].penPolicyTransaction ppt with (nolock) on pao.PolicyTransactionKey = ppt.PolicyTransactionKey                                                                         
 where ppt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in ('ADVACT','ADVACT2','ADVACT3','ADVACT4')                                                                                                                                         
 group by pao.AddonValueDesc,pao.AddOnCode)s                                          
                                                                                                                          
   outer apply ( select sum(ppp.GrossPremium) 'Motorcycle_Premium',pao.AddonValueDesc,                                                                        
   CASE WHEN pao.AddOnCode in ('MTCLTWO','MTCL') then pao.AddonValueDesc else 'No' End as Motorbike_Flag                                   
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyAddOn pao with (nolock) on ppp.ComponentID = pao.PolicyAddOnID                              
                                  
 join [db-au-cmdwh].[dbo].penPolicyTransaction ppt with (nolock) on pao.PolicyTransactionKey = ppt.PolicyTransactionKey                                                                                                        
 where ppt.PolicyTransactionKey = n.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in( 'MTCLTWO' ,'MTCL')                                                                                         
 group by pao.AddonValueDesc,pao.AddOnCode)s1                                                                                                                                                               
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
 ) q order by  QuoteID
GO
