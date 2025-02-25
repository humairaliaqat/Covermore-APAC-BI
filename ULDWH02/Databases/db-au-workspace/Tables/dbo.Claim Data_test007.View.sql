USE [db-au-workspace]
GO
/****** Object:  View [dbo].[Claim Data_test007]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Claim Data_test007]    
AS     
select distinct o.policyno as basepolicyno,    
                o.Claimno,    
    o.ClaimKey,  
    o.ReceivedDate as  ReceiptDate,    
    o.StatusDesc as Status,  
 o.AgencyCode,  
   -- e.SectionID,    
    e.SectionCode,    
    e.FinalisedDate as [First Finalised Date],    
    e.BenefitCategory,    
    --e.Benefit,    
    e.EventCountryName,  
 e.RecoveredPayment,  
    t.EventDateTime as lossdate,    
    t.PerilCode,    
    t.PerilDescription,    
    a.CostDescription,    
    n.LuggageFlag,    
    n.WinterSportFlag,    
    n.CruiseFlag,    
    n.MopedFlag,    
    j.EstimateMovement,    
    ----j.RecoveryEstimateMovement as RecoveryMovement,    
    k.PaymentMovement,    
    --i.isPrimary --,   
   l.MedicalSummary_c ,    
   e.Catastrophe,   
   o5.PEMC_Flag,  
   s.AdventureActivities_Flag,  
   r.AssessmentOutcomeDescription,  
   r.PrimaryDenialReason,  
   r.ClaimWithdrawalReason  
     
---select COUNT(1)    
 from    
(select distinct o.policyno,o.Claimno,o.ReceivedDate,o.StatusDesc,o.ClaimKey,o.CountryKey,o.PolicyKey,o.PolicyID,o.AgencyCode   
            
   from [db-au-cmdwh].[dbo].clmClaim o  with(nolock)    
  where AgencyCode='BGD0001'  --and o.PolicyNo = '723000411185'  
 ---where IssueDate between DATEADD(mm,-3,getdate()) and GETDATE()     
 )o    
  outer apply (select distinct CompanyKey,countrykey,PolicyNumber,PolicyID,PolicyKey,OutletAlphaKey,OutletSKey,IssueDate,PrimaryCountry as Destination,            
Area,Excess,TripCost,PlanName,AreaCode,AreaName,AreaNumber,AreaType,TripStart,TripEnd,MaxDuration,TripType,PlanCode,        
datediff(day,IssueDate,TripStart)  as [Days_To_Departure] ,MultiDestination       
  from [db-au-cmdwh].[dbo].penPolicy p  with (nolock)            
   where AlphaCode='BGD0001' and o.PolicyNo = p.PolicyNumber   
 )d     
     outer apply (    
    select distinct e1.SectionID,e1.SectionCode,e1.FinalisedDate,e1.BenefitCategory, e1.RecoveredPayment,   
    e1.Benefit,e1.EventCountryName,e1.ClaimKey,e1.ClaimNo,e1.PolicyNo,e1.CountryKey,e1.PolicyKey, e1.Catastrophe     
        from  [db-au-cmdwh].[dbo].clmClaimSummary e1  with (nolock)    
    where o.CountryKey=e1.CountryKey and o.ClaimKey=e1.ClaimKey and o.ClaimNo=e1.ClaimNo and o.PolicyNo=e1.PolicyNo and catastrophe is not null )e    
       
    
 outer apply (    
    select distinct t1.EventDateTime,t1.PerilCode,t1.PerilDescription,t1.CountryKey,t1.ClaimKey,t1.ClaimNo,t1.OnlineClaimID,t1.OnlineClaimKey    
        from   [db-au-cmdwh].[dbo].ClmOnlineClaimEvent t1  with (nolock)    
    where o.CountryKey=t1.CountryKey and o.ClaimKey=t1.ClaimKey and o.ClaimNo=t1.ClaimNo)t    
        
    
    outer apply (    
    select distinct a1.CountryKey,a1.ClaimKey,a1.ClaimNo,a1.CostDescription,a1.OnlineClaimID,a1.OnlineClaimKey    
        from   [db-au-cmdwh].[dbo].[clmOnlineClaimCosts]  a1  with (nolock)    
    where o.CountryKey=a1.CountryKey and o.ClaimKey=a1.ClaimKey and o.ClaimNo=a1.ClaimNo and  t.OnlineClaimID=a1.OnlineClaimID   
 and t.OnlineClaimKey=a1.OnlineClaimKey)a    
        
    
 outer apply (    
    select distinct n1.LuggageFlag,n1.WinterSportFlag,n1.CruiseFlag,n1.MopedFlag,n1.ClaimKey    
        from   [db-au-cmdwh].[dbo].[clmClaimFlags] n1  with (nolock)    
    where  o.ClaimKey=n1.ClaimKey )n    
        
 outer apply (    
    select distinct j1.EstimateMovement,j1.RecoveryEstimateMovement     
        from   [db-au-cmdwh].[dbo].clmClaimEstimateMovement j1  with (nolock)    
    where  o.ClaimKey=j1.ClaimKey )j    
    
   outer apply (    
    select distinct k1.PaymentMovement    
        from   [db-au-cmdwh].[dbo].clmClaimIncurredMovement k1  with (nolock)    
    where  o.ClaimKey=k1.ClaimKey )k    
    
 outer apply (    
    select distinct i1.isPrimary,i1.PolicyKey    
        from   [db-au-cmdwh].[dbo].[penPolicyTraveller] i1  with (nolock)    
    where   o.CountryKey=i1.CountryKey and e.PolicyKey=i1.PolicyKey )i    
    
  outer apply  
 (select distinct MedicalSummary_c,PolicyNumber__c  from [db-au-atlas].[atlas].[Case] as L1 with (nolock)  
 where o.PolicyNo collate Latin1_General_CI_AS=L1.PolicyNumber__c  
 ) L  
  
   outer apply (            
    select distinct m1.commission,m1.newpolicycount,m1.BasePremium,m1.SingleFamilyFlag,m1.AdultsCount,m1.ChildrenCount,            
       m1.TravellersCount,PostingDate,PolicyTransactionKey,GrossPremium,m1.PolicyKey from [db-au-cmdwh].[dbo].penPolicyTransSummary m1  with (nolock)            
    where d.PolicyKey=m1.PolicyKey )m      
  
 outer apply ( select sum(ppp.GrossPremium) 'AdventureActivities_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='ADVACT' then 'Yes' else 'No' End as AdventureActivities_Flag  
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp join [db-au-cmdwh].[dbo].penPolicyAddOn pao on ppp.ComponentID = pao.PolicyAddOnID  
 join [db-au-cmdwh].[dbo].penPolicyTransaction ppt on pao.PolicyTransactionKey = ppt.PolicyTransactionKey  
 where ppt.PolicyTransactionKey = m.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode = 'ADVACT'  
 group by pao.DisplayName,pao.AddOnCode)s   
  
  outer apply (            
  select distinct a1.policytravellerkey,a1.Title,a1.FirstName,a1.LastName,a1.EmailAddress,a1.MobilePhone,a1.State,a1.DOB,a1.Age,PostCode,a1.PolicyKey,    
(select min(DOB) as OldestTraveller_DOB from [db-au-cmdwh].[dbo].penPolicyTraveller as c where c.PolicyKey=a1.PolicyKey and CountryKey='AU'     
  and CompanyKey='TIP' group by PolicyID)    
  as OldestTraveller_DOB ,  
  (select max(AGE) as OldestTraveller_AGE from [db-au-cmdwh].[dbo].penPolicyTraveller as c where c.PolicyKey=a1.PolicyKey and CountryKey='AU'     
  and CompanyKey='TIP' group by PolicyID)    
  as OldestTraveller_Age   
  from [db-au-cmdwh].[dbo].penPolicyTraveller a1  with (nolock)            
  where d.PolicyKey=a1.PolicyKey  )a1       
  
 outer apply ( select sum(ppp.GrossPremium) 'PEMC_Premium',CASE WHEN pptt.HasEMC = 1 then 'Yes' else 'No' End as 'PEMC_Flag'  
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp join [db-au-cmdwh].[dbo].penPolicyEMC ppe on ppp.ComponentID = ppe.PolicyEMCID and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and ppp.GroupID = 5 and ppp.isPOSDiscount = 1  
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt on ppe.PolicyTravellerTransactionKey = pptt.PolicyTravellerTransactionKey and pptt.HasEMC = 1  
 where pptt.PolicyTravellerKey = a1.PolicyTravellerKey  
 group by pptt.HasEMC) o5   
    
  outer apply (    
select distinct r1.AssessmentOutcomeDescription,ClaimKey,ClaimNumber,PolicyNumber, p.PrimaryDenialReason, p.[ClaimWithdrawalReason]   
 from [db-au-cmdwh].[dbo].e5WorkActivity_v3 r1 with (nolock)   
 inner join [db-au-cmdwh].[dbo].e5Work_v3  b with (nolock) on r1.Work_ID=b.Work_ID and r1.AssessmentOutcome is not null  
 inner join [db-au-cmdwh].[dbo].[ve5WorkProperties] p on p.Work_Id = b.Work_id and p.Work_Id = r1.Work_id  
  )r  where o.ClaimKey=r.ClaimKey and o.ClaimNo=r.ClaimNumber   
  
   
GO
