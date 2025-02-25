USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[POlicy_Data_Feed_Layout_Proc_BUPA_backup20241224]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

                                                           
CREATE Procedure [dbo].[POlicy_Data_Feed_Layout_Proc_BUPA_backup20241224]  --'2024-06-05 22:53:30.887'                                                                                       
@StartDate datetime                                                                                                
as                                                                                                
begin    
select * from (  
  
 SELECT                                                                                                                                                             
 DISTINCT                          
 ISNULL(b.PolicyTransactionKey,'') as Id                        
 ,ISNULL(CONVERT(varchar(100),b.TransactionDateTime,120),'') AS Trans_Date                        
 ,ISNULL(REPLACE(b.PolicyTransactionKey,'AU-TIP7-',''),'') as Phase_Id                        
 ,'BUPA' as partner                        
 ,'Cover-More' as underwriter                        
 ,      
 case       
 when b.TransactionStatus='Cancelled' and c.StatusDescription='Cancelled' then  'CA'  
 when b.TransactionStatus='CancelledWithOverride' and c.StatusDescription='Cancelled' then  'CA'   
 when b.TransactionStatus='Active' and b.TransactionType='Base'  then  'NB'      
 when b.TransactionStatus='Active' and b.TransactionType!='Base'  then  'EN'      
END  AS Record_Type                        
 ,ISNULL(d.PolicyNumber,'') AS Policy_Num                        
 ,ISNULL(d.PolicyNumber,'') as policy_slug                        
 ,ISNULL(d.PolicyNumber,'') as policy_Id                        
 ,p.QuoteID as  Quote_id                        
 ,ISNULL(d.IssueDate,'') as  Created_Datetime                        
 ,'Travel' as Product_Class                        
 ,d.productcode AS Product_slug                        
 ,d.PlanName AS Product_type                        
 ,'U' AS Payment_Freq                        
 ,cast(ISNULL(q3.TaxAmountGST+q3.TaxAmountSD, '')as decimal(10,4)) AS [Premium.retail_premium_taxes]                        
 ,cast(ISNULL(q3.GrossPremium,  '')as decimal(10,4))  AS [Premium.retail_premium_incl_taxes]                        
 ,cast(ISNULL(z.GrossPremium,'')as decimal(10,4)) AS [Premium.premium_breakdown.base_premium]                        
 ,cast(ISNULL(Cruise_Premium,'')as decimal(10,4)) AS [Premium.premium_breakdown.cruise_premium]                        
 ,cast(ISNULL([AdventureActivities_Premium],'')as decimal(10,4)) AS [Premium.premium_breakdown.adventure_activities_premium]                        
 ,cast(ISNULL(Motorcycle_Premium,  '')as decimal(10,4)) AS [Premium.premium_breakdown.motorcycle_premium]                        
 ,cast(ISNULL(Cancellation_Premium,'')as decimal(10,4)) AS [Premium.premium_breakdown.cancellation_premium]                        
 ,cast(ISNULL(Covid_Premium,  '')as decimal(10,4)) AS [Premium.premium_breakdown.covid_premium]                        
 ,cast(ISNULL(Luggage_Premium, '')as decimal(10,4)) AS [Premium.premium_breakdown.luggage_premium]                        
 ,cast(ISNULL(SnowSports_Premium,  '')as decimal(10,4)) AS [Premium.premium_breakdown.snow_sports_premium]                        
 ,cast(ISNULL(PEMC_Premium,  '')as decimal(10,4)) AS [Premium.premium_breakdown.pemc_premium]                        
 ,cast(ISNULL(q3.TaxAmountGST, '')as decimal(10,4)) AS [Premium.premium_breakdown.gst_on_total_premium]                        
 ,cast(ISNULL(q3.TaxAmountSD,'')as decimal(10,4)) AS [premium.premium_breakdown.sd_on_total_premium]                        
 ,0 AS [premium.premium_breakdown.nap]                        
 ,ISNULL(d.IssueDate,'') as [policy_purchased_date]                        
 ,ISNULL(d.TripStart,'') AS [Orig_inception_date]                        
 ,ISNULL(d.TripStart,'') AS [Commencement_date]                        
 ,ISNULL(d.TripEnd,'')  AS [Expiry_date]                        
 ,ISNULL(d.TripStart,'') AS Eff_Start_Date                        
 ,ISNULL(d.TripEnd,'')  AS Eff_End_Date                        
 ,ISNULL(a.DOB,'') as [Policy_holder.dob]                        
 ,ISNULL(a.EmailAddress,'') as [policy_holder.email]                        
 ,ISNULL(a.MobilePhone,'') as [policy_holder.mobile]                        
 ,convert(varchar(500),ISNULL(replace(a.LastName,',',' '),'')) as  [policy_holder.last_name]                        
 ,convert(varchar(500),replace(a.FirstName,',',' ')) AS [policy_holder.first_name]              
 ,ISNULL(GAID,'') as  [risk_address.gnaf]                 
 ,ISNULL(a.State,'') as [risk_address.state]                        
 ,'' as [risk_address.suburb]                        
 ,ISNULL(replace(A.PolicyHolder_Address,',',''),'') as  [risk_address.full]                        
 ,'AU' as [risk_address.country]                        
 , ISNULL(a.PostCode,'') as [risk_address.postcode]                        
 ,'' as [risk_address.street_name]                        
 ,'' as [risk_address.street_type]                        
 ,'' as [risk_address.unit_number]                        
 ,'' as [risk_address.street_number]                        
 ,ISNULL(replace(A.PolicyHolder_Address,',',''),'') as [postal_address]                        
 ,PolicyTravellerID as open_customer_ref                        
 ,'' as [bupa_customer_ref_ref]                        
 ,CASE                 
 WHEN AlphaCode='BPN0001' Then 'Call Centre'                 
 WHEN AlphaCode='BPN0002' Then 'Online' END                
                 
 as [channel]                        
 ,CancellationCover  as [sum_insured.travel]                        
 ,cast(ISNULL(d.Excess,'')as decimal(10,4))  as [excess.travel]                        
 ,ISNULL(case when t.PromoCode is  null then r.Promotional_Code collate SQL_Latin1_General_CP1_CI_AS  else t.PromoCode end,'')  as [promo_code]                        
 ,'' as [campaign_code]                        
 ,'' as [additional_info.bupa_id]                        
 ,'' as [additional_info.agent_id]                        
 ,'' as [additional_info.agent_name]                        
 ,'' as [additional_info.HI_product]                        
 ,'' as [additional_info.employee_num]                        
 ,'' as [additional_info.cgu_policy_no]                        
 ,'' as [additional_info.HI_member_type]                        
 ,'' as [additional_info.employee_group]                        
 ,CASE WHEN MemberNumber LIKE '%-%'            
 THEN CASE WHEN MemberNumber!='' THEN  substring(MemberNumber,1,CHARINDEX('-',MemberNumber)-1) ELSE MemberNumber END ELSE MemberNumber END as [additional_info.HI_membership_num]                       
 ,ISNULL(convert(varchar(50),                                                                
case when t.Discount is  null then r.Promotional_Factor else  t.Discount end),'') as [additional_info.HI_member_discount]                        
,'' as [additional_info.employee_validated]                        
,'' as [additional_info.HI_member_validated]                        
,CASE WHEN  MemberNumber LIKE '%-%' THEN substring(MemberNumber,CHARINDEX('-',MemberNumber)+1,len(MemberNumber)) ELSE '' END as [additional_info.HI_member_num_suffix]                        
,ISNULL(d.TripStart,'')  as [additional_info.cgu_policy_inception_date]                        
,'' as [replacement_policy_details.pre_policy_id]                        
,'' as [replacement_policy_details.has_replacement_policy]                        
,CancellationReason as [cancel_reason]                        
,ISNULL(d.IssueDate,'')  as [first_payment_date]                        
,Q6.CardType as [payment_method]                        
,ISNULL(m3.AdultsCount,'') as [risk_info.traveller.insurred_number_of_adults]                        
,ISNULL(m3.ChildrenCount,'') as [risk_info.traveller.Insured_num_of_childs]                        
,ISNULL(m3.TravellersCount,'') as [risk_info.traveller.total_number_of_insured]                        
 ,convert(varchar(500),replace(a.FirstName,',',' '))  as [risk_info.traveller.first_name]                        
 ,convert(varchar(500),ISNULL(replace(a.LastName,',',' '),''))  as [risk_info.traveller.last_name]                        
 ,ISNULL(a.DOB,'')  as [risk_info.traveller.dob]      
 ,ISNULL(a.Age,'')  as [risk_info.traveller.age]      
 ,ISNULL(PEMC_Flag,'No') as [risk_info.traveller.pemc_flag]                        
 ,isnull(CONVERT(VARCHAR(30),q8.MedicalRisk),'') as [risk_info.traveller.medical_risk_score]                        
 ,isnull(CONVERT(VARCHAR(30),q8.ApprovalStatus),'') as [risk_info.traveller.pemc_assessment_outcome]                        
 ,ISNULL(d.MultiDestination,'')  as [risk_info.travel_destinations]                        
 ,ISNULL(d.TripStart,'') as [risk_info.travel_destinations_details.departure_date]                        
 ,ISNULL(d.TripEnd,'') as [risk_info.travel_destinations_details.return_date]                        
 ,ISNULL([Trip_Duration],'') as [risk_info.travel_destinations_details.trip_duration]                        
 ,ISNULL(d.TripType,'') as [risk_info.travel_destinations_details..trip_type]                        
 ,ISNULL(Cruise_Flag,'No') as  [risk_info.additional_cover.cruise_Flag]                        
 ,ISNULL(Covid_Flag,'No') as [risk_info.additional_cover.covid_flag]                        
 ,ISNULL(Luggage_Flag,'No') as  [risk_info.additional_cover.luggage_flag]                        
 ,ISNULL(SnowSports_Flag,'No') as [risk_info.additional_cover.snow_sports_flag]                        
 ,ISNULL([AdventureActivities_Flag],'No')  as [risk_info.additional_cover.adventure_activities_flag]                        
 ,ISNULL([Motorbike_Flag] ,'No') as [risk_info.additional_cover.motorbike_flag]                        
 ,ISNULL(PEMC_Flag,'No') as [risk_info.additional_cover.pemc_flag]                                                                                                                                                                                                              
                  
 from                                                                        
(select distinct CompanyKey,countrykey,PolicyNumber,PolicyID,PolicyKey,OutletAlphaKey,OutletSKey,IssueDate,PrimaryCountry as Destination,   Area,Excess,TripCost,PlanName,AreaCode,AreaName,AreaNumber,AreaType,TripStart,TripEnd,                             
  
    
               
datediff(day,TripStart, TripEnd)+1 as Trip_Duration,TripType,PlanCode,                                                         
datediff(day,IssueDate,TripStart)  as [Days_To_Departure] ,MultiDestination,                                                                  
CASE WHEN CancellationCover='1000000' THEN 'Unlimited' else CancellationCover end as CancellationCover,                                                                          
'BUPA' as [Agency_Name],'BUPA' as Brand,                        
productcode,      
StatusDescription      
  from [db-au-cmdwh].[dbo].penPolicy  with (nolock)                                                                                                                                  
where PolicyNumber in (                                                                                                                         
 '724001153603',    
'724001153963',    
'724100426533',    
'724100669607',    
'724001153963',    
'724001152841')                                                                                                                   
  --AlphaCode in ('BPN0001','BPN0002') and convert(date,IssueDate,103)=convert(date,getdate()-1,103)                                                                                                                        
    and AlphaCode in ('BPN0001','BPN0002')                                                                                                            
                                                
 )d     
   
  
 outer apply   
 (   
 select PolicyNumber,PolicyKey,StatusDescription from [db-au-cmdwh].[dbo].penPolicy as c1 with (nolock) where d.PolicyKey=c1.PolicyKey and   
 convert(date,CancelledDate,103)=Convert(date,@StartDate,103)  
 ) c  
                                     
                                    
   outer apply (                                                                    
    select distinct b1.PolicyTransactionID ,b1.TransactionType,b1.PolicyTransactionKey,b1.TransactionStatus,b1.TransactionDateTime,                                                                                    
 b1.PolicyKey, CancellationReason   from [db-au-cmdwh].[dbo].penPolicyTransaction b1  with (nolock)                                                                 
                                                                                       
                                                                     
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
  a1.AddressLine1+' '+a1.AddressLine2+' '+a1.Suburb AS PolicyHolder_Address, PolicyTravellerID,  MemberNumber,                                                                                                                                    
(select min(DOB) as OldestTraveller_DOB from [db-au-cmdwh].[dbo].penPolicyTraveller as c with (nolock) where c.PolicyKey=a1.PolicyKey and CountryKey='AU'                                                                         
  and CompanyKey='TIP' group by PolicyID)                                                                                
  as OldestTraveller_DOB ,                                                                                                                 
  (select max(AGE) as OldestTraveller_AGE from [db-au-cmdwh].[dbo].penPolicyTraveller as c with (nolock) where c.PolicyKey=a1.PolicyKey and CountryKey='AU'                                                                                                    
 
     
      
        
          
                   
  and CompanyKey='TIP' group by PolicyID)                      
  as OldestTraveller_Age,                                            
  CASE WHEN PIDValue LIKE '%^%' then substring(PIDValue,1,charindex('^',pidvalue)-1) end                                   
  as  GAID                   
  from [db-au-cmdwh].[dbo].penPolicyTraveller a1  with (nolock)                                     
  where d.PolicyKey=a1.PolicyKey             
  --and isPrimary='1'            
   )a                                                                                                                                                                
                                                                
                                                                                                                                                               
                                                  
  outer apply (                                                                                                                      
   select distinct y1.AlphaCode,y1.OutletName,y1.Channel, y1.subgroupname                                                                                                                         from  [db-au-cmdwh].[dbo].penOutlet y1  with (nolock)        
  
    
      
       
          
            
               
                
                  
                    
                      
                       
                           
                           
                               
                                
                                 
                                     
                                      
                                        
                                  
                                                                                                                                                        
  where d.CountryKey=y1.CountryKey and d.CompanyKey=y1.CompanyKey and d.OutletAlphaKey=y1.OutletAlphaKey and d.OutletSKey=y1.OutletSKey)y                                   
                                                                                                                                                                  
  outer apply (                                                                                                
    select distinct t1.PromoCode,convert(varchar(30),convert(decimal(5,2),t1.Discount*100))+' % Discount' as Discount,t1.PromoName,t1.PromoType,t1.PolicyTransactionKey                                                                                        
  
    
      
        
          
            
              
                
                  
                   
                       
                        
                          
                     
                                                                        
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
                                   
 outer apply (           
           
           
 select sum(ppp.GrossPremium) 'PEMC_Premium',CASE WHEN pptt.HasEMC = 1 then 'Yes' else 'No' End as 'PEMC_Flag'                                         
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp join [db-au-cmdwh].[dbo].penPolicyEMC ppe on ppp.ComponentID = ppe.PolicyEMCID                   
 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and ppp.GroupID = 5 and ppp.isPOSDiscount = 1                   
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt on ppe.PolicyTravellerTransactionKey = pptt.PolicyTravellerTransactionKey                                                                                    
 where pptt.PolicyTravellerKey = a.PolicyTravellerKey                
 --and b.PolicyTransactionKey=pptt.PolicyTransactionKey                                           
 group by pptt.HasEMC          
 ) o5                                                                                                                 
                                                                                                                 
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
 convert(varchar(50),convert(decimal(5,2),isnull(convert(varchar(30),case when A.PromoCodeListID!='-1'                                                                       
then (a.TotalGrossPremium-a.TotalAdjustedGrossPremium)/a.TotalGrossPremium*100 end),'')))+' % Discount' end                                 
AS Promotional_Factor                                                                 
                                                                 
 from [db-au-stage].dbo.cdg_factQuote_AU AS a with (nolock) inner join [db-au-stage].dbo.cdg_factPolicy_AU                                 
 as b with (nolock)  on a.SessionID=b.SessionID inner join [db-au-stage].dbo.cdg_dimPromoCodeList_AU as c with (nolock)                                                    
 on a.PromoCodeListID=c.DimPromoCodeListID inner join [db-au-stage].dbo.cdg_dimPromoCode_AU as  d1 with (nolock)                                                               
 on c.PromoCodeID1=d1.DimPromoCodeID                                                                 
 WHERE c.PromoCodeID1!='-1' and  a.BusinessUnitID=146 AND a.CampaignID=362 and d.PolicyNumber=b.PolicyNumber collate SQL_Latin1_General_CP1_CI_AS                                                                
 )                                                                
 r                           
                      
  outer apply (                                                                 
  select distinct p1.QuoteID from [db-au-cmdwh].[dbo].penQuote p1 with(nolock)                                                                                                  
 where d.CountryKey=p1.CountryKey and d.CompanyKey=p1.CompanyKey and d.PolicyKey=p1.PolicyKey --and d.PolicyID=p1.PolicyID                                                      
 UNION                                                      
SELECT distinct sessionid AS QuoteID FROM [db-au-cmdwh].dbo.cdg_factPolicy_AU_AG AS P2 WHERE P2.PolicyNumber=D.PolicyNumber                   
 COLLATE SQL_Latin1_General_CP1_CI_AS                                                      
                                                      
 )p                         
                      
 outer apply                      
 (                      
                      
 select PolicyTransactionKey,CardType from [db-au-cmdwh].[dbo].Penpayment as Q5 with(nolock)  where b.PolicyTransactionKey=Q5.PolicyTransactionKey                      
 ) Q6                      
                      
                      
 --outer apply (                                                                        
 --select sum(ppp.GrossPremium) 'PEMC_Premium',CASE WHEN pptt.HasEMC = 1 then 'Yes' else 'No' End as 'PEMC_Flag'                                                       
 --from [db-au-cmdwh].[dbo].penPolicyPrice ppp join [db-au-cmdwh].[dbo].penPolicyEMC ppe on ppp.ComponentID = ppe.PolicyEMCID                                 
 --and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and ppp.GroupID = 5 and ppp.isPOSDiscount = 1                                 
 --join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt on ppe.PolicyTravellerTransactionKey = pptt.PolicyTravellerTransactionKey                                                                                                  
 --where pptt.PolicyTravellerKey = a.PolicyTravellerKey                              
 ----and b.PolicyTransactionKey=pptt.PolicyTransactionKey                                                                                  
 --group by pptt.HasEMC)Q7                                   
 outer apply                                
 (                                
  select EMCApplicationKey  from  [db-au-cmdwh].[dbo].penPolicyEMC ppe  inner join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt on ppe.PolicyTravellerTransactionKey = pptt.PolicyTravellerTransactionKey                                            
 
    
      
         
         
            
               
               
                   
                   
                                                         
 where pptt.PolicyTravellerKey = a.PolicyTravellerKey                                                     
                                
) q9                                
outer apply                                
(                                
select MedicalRisk,ApprovalStatus from [db-au-cmdwh].[dbo].emcApplications as q2 where q2.ApplicationKey=q9.EMCApplicationKey                                
) q8                      
                           
 --Missing Data                   
                
union              
                
SELECT                     
    DISTINCT                          
 ISNULL(b.PolicyTransactionKey,'') as Id                        
 ,ISNULL(CONVERT(varchar(100),b.TransactionDateTime,120),'') AS Trans_Date                        
 ,ISNULL(REPLACE(b.PolicyTransactionKey,'AU-TIP7-',''),'') as Phase_Id                        
 ,'BUPA' as Partner                        
 ,'Cover-More' as UnderWriter                        
 , case       
 when b.TransactionStatus='Cancelled' and c.StatusDescription='Cancelled' then  'CA'  
 when b.TransactionStatus='CancelledWithOverride' and c.StatusDescription='Cancelled' then  'CA'   
 when b.TransactionStatus='Active' and b.TransactionType='Base'  then  'NB'      
 when b.TransactionStatus='Active' and b.TransactionType!='Base'  then  'EN'      
END  AS Record_Type                           
 ,ISNULL(d.PolicyNumber,'') AS Policy_Num                        
 ,ISNULL(d.PolicyNumber,'') as policy_slug                        
 ,ISNULL(d.PolicyNumber,'') as policy_Id                        
 ,p.QuoteID as  Quote_id                        
 ,ISNULL(d.IssueDate,'') as  Created_Datetime                        
 ,'Travel' as Product_Class                        
 ,d.productcode AS Product_slug                        
 ,d.PlanName AS Product_type                        
 ,'U' AS Payment_Freq                        
 ,cast(ISNULL(q3.TaxAmountGST+q3.TaxAmountSD, '')as decimal(10,4)) AS [Premium.retail_premium_taxes]                        
 ,cast(ISNULL(q3.GrossPremium,  '')as decimal(10,4))  AS [Premium.retail_premium_incl_taxes]                        
 ,cast(ISNULL(z.GrossPremium,'')as decimal(10,4)) AS [Premium.premium_breakdown.base_premium]                        
 ,cast(ISNULL(Cruise_Premium,'')as decimal(10,4)) AS [Premium.premium_breakdown.cruise_premium]                        
 ,cast(ISNULL([AdventureActivities_Premium],'')as decimal(10,4)) AS [Premium.premium_breakdown.adventure_activities_premium]                        
 ,cast(ISNULL(Motorcycle_Premium,  '')as decimal(10,4)) AS [Premium.premium_breakdown.motorcycle_premium]                        
 ,cast(ISNULL(Cancellation_Premium,'')as decimal(10,4)) AS [Premium.premium_breakdown.cancellation_premium]                       
 ,cast(ISNULL(Covid_Premium,  '')as decimal(10,4)) AS [Premium.premium_breakdown.covid_premium]                        
 ,cast(ISNULL(Luggage_Premium, '')as decimal(10,4)) AS [Premium.premium_breakdown.luggage_premium]                        
 ,cast(ISNULL(SnowSports_Premium,  '')as decimal(10,4)) AS [Premium.premium_breakdown.snow_sports_premium]                        
 ,cast(ISNULL(PEMC_Premium,  '')as decimal(10,4)) AS [Premium.premium_breakdown.pemc_premium]                        
 ,cast(ISNULL(q3.TaxAmountGST, '')as decimal(10,4)) AS [Premium.premium_breakdown.gst_on_total_premium]                        
 ,cast(ISNULL(q3.TaxAmountSD,'')as decimal(10,4)) AS [premium.premium_breakdown.sd_on_total_premium]                        
 ,cast(ISNULL(q.NAP,'')as decimal(10,4)) AS [premium.premium_breakdown.nap]                        
 ,ISNULL(d.IssueDate,'') as [policy_purchased_date]                        
 ,ISNULL(d.TripStart,'') AS [Orig_inception_date]                        
 ,ISNULL(d.TripStart,'') AS [Commencement_date]                        
 ,ISNULL(d.TripEnd,'')  AS [Expiry_date]                        
 ,ISNULL(d.TripStart,'') AS Eff_Start_Date                        
 ,ISNULL(d.TripEnd,'')  AS Eff_End_Date                        
 ,ISNULL(a.DOB,'') as [Policy_holder.dob] 
 ,ISNULL(a.EmailAddress,'') as [policy_holder.email]                        
 ,ISNULL(a.MobilePhone,'') as [policy_holder.mobile]                        
 ,convert(varchar(500),ISNULL(replace(a.LastName,',',' '),'')) as  [policy_holder.last_name]                        
 ,convert(varchar(500),replace(a.FirstName,',',' ')) AS [policy_holder.first_name]                        
 ,ISNULL(GAID,'') as  [risk_address.gnaf]                        
 ,ISNULL(a.State,'') as [risk_address.state]                        
 ,'' as [risk_address.suburb]                        
 ,ISNULL(replace(A.PolicyHolder_Address,',',''),'') as  [risk_address.full]                        
 ,'AU' as [risk_address.country]                        
 , ISNULL(a.PostCode,'') as [risk_address.postcode]                       
 ,'' as [risk_address.street_name]                        
 ,'' as [risk_address.street_type]                        
 ,'' as [risk_address.unit_number]                        
 ,'' as [risk_address.street_number]                        
 ,ISNULL(replace(A.PolicyHolder_Address,',',''),'') as [postal_address]                        
 ,PolicyTravellerID as open_customer_ref                        
 ,'' as [bupa_customer_ref_ref]                        
 ,CASE                 
 WHEN AlphaCode='BPN0001' Then 'Call Centre'                 
 WHEN AlphaCode='BPN0002' Then 'Online' END                
                 
 as [channel]                        
 ,CancellationCover  as [sum_insured.travel]                        
 ,cast(ISNULL(d.Excess,'')as decimal(10,4))  as [excess.travel]                        
 ,ISNULL(case when t.PromoCode is  null then r.Promotional_Code collate SQL_Latin1_General_CP1_CI_AS else t.PromoCode end,'')  as [promo_code]                        
 ,'' as [campaign_code]                        
 ,'' as [additional_info.bupa_id]                        
 ,'' as [additional_info.agent_id]                        
 ,'' as [additional_info.agent_name]                        
 ,'' as [additional_info.HI_product]                        
 ,'' as [additional_info.employee_num]                        
 ,'' as [additional_info.cgu_policy_no]                        
 ,'' as [additional_info.HI_member_type]                        
 ,'' as [additional_info.employee_group]                        
 ,CASE WHEN MemberNumber LIKE '%-%'            
 THEN CASE WHEN MemberNumber!='' THEN  substring(MemberNumber,1,CHARINDEX('-',MemberNumber)-1) ELSE MemberNumber END ELSE MemberNumber END as [additional_info.HI_membership_num]                        
 ,ISNULL(convert(varchar(50),                                                                
case when t.Discount is  null then r.Promotional_Factor else  t.Discount end),'') as [additional_info.HI_member_discount]                        
,'' as [additional_info.employee_validated]                        
,'' as [additional_info.HI_member_validated]                        
,CASE WHEN MemberNumber LIKE '%-%' THEN  substring(MemberNumber,CHARINDEX('-',MemberNumber)+1,len(MemberNumber)) ELSE '' END as [additional_info.HI_member_num_suffix]                        
,ISNULL(d.TripStart,'')  as [additional_info.cgu_policy_inception_date]                        
,'' as [replacement_policy_details.pre_policy_id]                        
,'' as [replacement_policy_details.has_replacement_policy]                        
,CancellationReason as [cancel_reason]                        
,ISNULL(d.IssueDate,'')  as [first_payment_date]                        
,Q6.CardType as [payment_method]                        
,ISNULL(m3.AdultsCount,'') as [risk_info.traveller.insurred_number_of_adults]                        
,ISNULL(m3.ChildrenCount,'') as [risk_info.traveller.Insured_num_of_childs]                        
,ISNULL(m3.TravellersCount,'') as [risk_info.traveller.total_number_of_insured]                        
 ,convert(varchar(500),replace(a.FirstName,',',' '))  as [risk_info.traveller.first_name]                        
 ,convert(varchar(500),ISNULL(replace(a.LastName,',',' '),''))  as [risk_info.traveller.last_name]                        
 ,ISNULL(a.DOB,'')  as [risk_info.traveller.dob] 
 ,ISNULL(a.Age,'')  as [risk_info.traveller.age]
 ,ISNULL(PEMC_Flag,'No') as [risk_info.traveller.pemc_flag]                        
 ,isnull(CONVERT(VARCHAR(30),q8.MedicalRisk),'') as [risk_info.traveller.medical_risk_score]                        
 ,isnull(CONVERT(VARCHAR(30),q8.ApprovalStatus),'') as [risk_info.traveller.pemc_assessment_outcome]                        
 ,ISNULL(d.MultiDestination,'')  as [risk_info.travel_destinations]                        
 ,ISNULL(d.TripStart,'') as [risk_info.travel_destinations_details.departure_date]                        
 ,ISNULL(d.TripEnd,'') as [risk_info.travel_destinations_details.return_date]                        
 ,ISNULL([Trip_Duration],'') as [risk_info.travel_destinations_details.trip_duration]                        
 ,ISNULL(d.TripType,'') as [risk_info.travel_destinations_details..trip_type]                        
 ,ISNULL(Cruise_Flag,'No') as  [risk_info.additional_cover.cruise_Flag]                        
 ,ISNULL(Covid_Flag,'No') as [risk_info.additional_cover.covid_flag]                        
 ,ISNULL(Luggage_Flag,'No') as  [risk_info.additional_cover.luggage_flag]                        
 ,ISNULL(SnowSports_Flag,'No') as [risk_info.additional_cover.snow_sports_flag]                        
 ,ISNULL([AdventureActivities_Flag],'No')  as [risk_info.additional_cover.adventure_activities_flag]                        
 ,ISNULL([Motorbike_Flag] ,'No') as [risk_info.additional_cover.motorbike_flag]                        
 ,ISNULL(PEMC_Flag,'No') as [risk_info.additional_cover.pemc_flag]                                                                                                                                                                                          
  
     
      
          
          
            
             
                 
                  
                   
                  
 from                                                                        
(select distinct CompanyKey,countrykey,PolicyNumber,PolicyID,PolicyKey,OutletAlphaKey,OutletSKey,IssueDate,PrimaryCountry as Destination,   Area,Excess,TripCost,PlanName,AreaCode,AreaName,AreaNumber,AreaType,TripStart,TripEnd,                                             
datediff(day,TripStart, TripEnd)+1 as Trip_Duration,TripType,PlanCode,                                                         
datediff(day,IssueDate,TripStart)  as [Days_To_Departure] ,MultiDestination,                                                         
CASE WHEN CancellationCover='1000000' THEN 'Unlimited' else CancellationCover end as CancellationCover,                                                                          
'BUPA' as [Agency_Name],'BUPA' as Brand,                        
productcode                        
  from [db-au-cmdwh].[dbo].penPolicy  with (nolock)                                                                                                                                  
  where PolicyNumber in (                                                                                                                         
                  
    select A.PolicyNumber from  [db-au-cmdwh].[dbo].penPolicy  as a with (nolock) inner join [db-au-cmdwh].[dbo].penPolicyTransaction as b with (nolock) on a.PolicyKey=b.PolicyKey  where AlphaCode in ('BPN0001','BPN0002')                                
  and b.PolicyTransactionKey in (                                
                                
  select distinct PolicyTransactionKey from [db-au-cmdwh].[dbo].penPolicy  as a with (nolock) inner join                             
  [db-au-cmdwh].[dbo].penPolicyTransaction as b with (nolock) on a.PolicyKey=                              
b.PolicyKey  where AlphaCode in ('BPN0001','BPN0002') and                                                                                                 
  convert(date,b.IssueDate,103) between Convert(date,@StartDate-7,103) and       Convert(date,@StartDate-1,103)                          
  Except                                
  select distinct Id from [db-au-cmdwh]..Policy_Feed_Tbl ))                
   and AlphaCode in ('BPN0001','BPN0002')                
                         
                         
                
                                                                                                           
                  
 )d                                        
                                     
                                    
   outer apply (                                                                                                
    select distinct b1.PolicyTransactionID ,b1.TransactionType,b1.PolicyTransactionKey,b1.TransactionStatus,b1.TransactionDateTime,                                                                                    
 b1.PolicyKey, CancellationReason   from [db-au-cmdwh].[dbo].penPolicyTransaction b1  with (nolock)                                                                 
                                  
                                                                     
  where d.PolicyKey=b1.PolicyKey                                           
  --and m.PolicyTransactionKey=b1.PolicyTransactionKey                                           
  and                                                                                                 
  PolicyTransactionKey in (                                                                                             
  select distinct PolicyTransactionKey from [db-au-cmdwh].[dbo].penPolicy  as a with (nolock) inner join                             
  [db-au-cmdwh].[dbo].penPolicyTransaction as b with (nolock) on a.PolicyKey=                              
b.PolicyKey  where AlphaCode in ('BPN0001','BPN0002') and                                                                                           
  convert(date,b.IssueDate,103) BETWEEN  Convert(date,@StartDate-7,103) and Convert(date,@StartDate-1,103)                                
  Except                                
  select Id from [db-au-cmdwh]..Policy_Feed_Tbl                        
                          
  )                  
                
 )b     
 
  outer apply   
 (   
 select PolicyNumber,PolicyKey,StatusDescription from [db-au-cmdwh].[dbo].penPolicy as c1 with (nolock) where d.PolicyKey=c1.PolicyKey and   
 convert(date,CancelledDate,103)=Convert(date,@StartDate,103)  
 ) c  
                                                                                                                                                     
                                             
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
  a1.AddressLine1+' '+a1.AddressLine2+' '+a1.Suburb AS PolicyHolder_Address, PolicyTravellerID,  MemberNumber,                                                                                                                                    
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
   select distinct y1.AlphaCode,y1.OutletName,y1.Channel, y1.subgroupname                                                                                                                         from  [db-au-cmdwh].[dbo].penOutlet y1  with (nolock)      
  
    
      
         
           
            
              
                
                  
                    
                      
                       
                     
                           
                               
                                
                                 
                                     
              
                                        
                                  
                                                                                                                                                        
  where d.CountryKey=y1.CountryKey and d.CompanyKey=y1.CompanyKey and d.OutletAlphaKey=y1.OutletAlphaKey and d.OutletSKey=y1.OutletSKey)y                                   
                                                                                                                                                                  
  outer apply (                                                                                                
    select distinct t1.PromoCode,convert(varchar(30),convert(decimal(5,2),t1.Discount*100))+' % Discount' as Discount,t1.PromoName,t1.PromoType,t1.PolicyTransactionKey                                                                                      
  
    
      
          
          
            
              
                
                  
                   
                       
                        
                          
                            
                                                                        
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
                                                                                                                                                      
 outer apply (           
 select sum(ppp.GrossPremium) 'PEMC_Premium',CASE WHEN pptt.HasEMC = 1 then 'Yes' else 'No' End as 'PEMC_Flag'                                         
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp join [db-au-cmdwh].[dbo].penPolicyEMC ppe on ppp.ComponentID = ppe.PolicyEMCID                   
 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and ppp.GroupID = 5 and ppp.isPOSDiscount = 1                   
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt on ppe.PolicyTravellerTransactionKey = pptt.PolicyTravellerTransactionKey                                                                                    
 where pptt.PolicyTravellerKey = a.PolicyTravellerKey                
 --and b.PolicyTransactionKey=pptt.PolicyTransactionKey                                                                                   
 group by pptt.HasEMC          
           
 ) o5                                                                                                                 
                                                                                                                 
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
 convert(varchar(50),convert(decimal(5,2),isnull(convert(varchar(30),case when A.PromoCodeListID!='-1'                                                                       
then (a.TotalGrossPremium-a.TotalAdjustedGrossPremium)/a.TotalGrossPremium*100 end),'')))+' % Discount' end                                 
AS Promotional_Factor                                                                 
                                                                 
 from [db-au-stage].dbo.cdg_factQuote_AU AS a with (nolock) inner join [db-au-stage].dbo.cdg_factPolicy_AU                                 
 as b with (nolock)  on a.SessionID=b.SessionID inner join [db-au-stage].dbo.cdg_dimPromoCodeList_AU as c with (nolock)                                                                
 on a.PromoCodeListID=c.DimPromoCodeListID inner join [db-au-stage].dbo.cdg_dimPromoCode_AU as  d1 with (nolock)                                                               
 on c.PromoCodeID1=d1.DimPromoCodeID                                                                 
 WHERE c.PromoCodeID1!='-1' and  a.BusinessUnitID=146 AND a.CampaignID=362 and d.PolicyNumber=b.PolicyNumber collate SQL_Latin1_General_CP1_CI_AS                                                                
 )                                                                
 r                           
                      
  outer apply (                                                                 
  select distinct p1.QuoteID from [db-au-cmdwh].[dbo].penQuote p1 with(nolock)                                                                                                  
 where d.CountryKey=p1.CountryKey and d.CompanyKey=p1.CompanyKey and d.PolicyKey=p1.PolicyKey --and d.PolicyID=p1.PolicyID                                                      
 UNION                                                      
SELECT distinct sessionid AS QuoteID FROM [db-au-cmdwh].dbo.cdg_factPolicy_AU_AG AS P2 WHERE P2.PolicyNumber=D.PolicyNumber                                                       
 COLLATE SQL_Latin1_General_CP1_CI_AS                                                      
                                                      
 )p                         
                      
 outer apply                      
 (                      
                      
 select PolicyTransactionKey,CardType from [db-au-cmdwh].[dbo].Penpayment as Q5 with(nolock)  where b.PolicyTransactionKey=Q5.PolicyTransactionKey                      
 ) Q6              
                      
                      
 --outer apply (                                                                        
 --select sum(ppp.GrossPremium) 'PEMC_Premium',CASE WHEN pptt.HasEMC = 1 then 'Yes' else 'No' End as 'PEMC_Flag'                                                       
 --from [db-au-cmdwh].[dbo].penPolicyPrice ppp join [db-au-cmdwh].[dbo].penPolicyEMC ppe on ppp.ComponentID = ppe.PolicyEMCID                                 
--and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and ppp.GroupID = 5 and ppp.isPOSDiscount = 1                                 
 --join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt on ppe.PolicyTravellerTransactionKey = pptt.PolicyTravellerTransactionKey                  
 --where pptt.PolicyTravellerKey = a.PolicyTravellerKey                              
 ----and b.PolicyTransactionKey=pptt.PolicyTransactionKey                                                                                                 
 --group by pptt.HasEMC)Q7                                   
 outer apply                                
 (                                
  select EMCApplicationKey  from  [db-au-cmdwh].[dbo].penPolicyEMC ppe  inner join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt on ppe.PolicyTravellerTransactionKey = pptt.PolicyTravellerTransactionKey                                         
  
     
      
          
                
              
               
                   
                   
                                                         
 where pptt.PolicyTravellerKey = a.PolicyTravellerKey                                                     
                                
) q9                                
outer apply                                
(                                
select MedicalRisk,ApprovalStatus from [db-au-cmdwh].[dbo].emcApplications as q2 where q2.ApplicationKey=q9.EMCApplicationKey                                
) q8                 
        
) as a  
                
order by   Policy_Num,   
case   
when Record_Type='NB'  THEN 1                  
when Record_Type='EN'  THEN 2                         
when Record_Type='CA'  THEN 3   END                      
                                                 
                                                                  
  END                         
                
                
                
                
                
GO
