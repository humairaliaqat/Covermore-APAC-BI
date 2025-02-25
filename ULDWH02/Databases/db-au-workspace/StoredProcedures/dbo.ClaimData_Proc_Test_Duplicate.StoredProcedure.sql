USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[ClaimData_Proc_Test_Duplicate]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
          
          
          
                      
                     
                                                
CREATE PROCEDURE  [dbo].[ClaimData_Proc_Test_Duplicate] --'2024-04-01'  ,   '2024-04-30'                                                                   
@StartDate Datetime ,  
@EndDate datetime  
as                                                                                       
select distinct                                                                                                                         
isnull(o.policyno,'') as Policy_Number,                                                                                                                                  
isnull(o.Claimno,'') as Claim_Number,                                                                                                                                  
isnull(o.ClaimKey,'') as Claim_Key,                                                    
--isnull(e.SectionID,'')  as Section_ID,                                                      
                                                    
                                                    
case                               
 when d5.SectionCode='MED' then 69                                                      
 when d5.SectionCode='EXP' then 70                                                      
 when d5.SectionCode='CANX' then 71                                                      
 when d5.SectionCode='LUGG' then 72                                                      
 when d5.SectionCode='MONEY' then 73                                                      
 when d5.SectionCode='REMP' then 74                                                      
 when d5.SectionCode='TDEL' then 75                                                      
 when d5.SectionCode='CDW' then 76                                                      
 when d5.SectionCode='HOSP' then 77                                                      
 when d5.SectionCode='HIJACK' then 78                                                      
 when d5.SectionCode='DEATH' then 79                                                      
 when d5.SectionCode='KIDNAP' then 80                                                      
 when d5.SectionCode='LIAB' then 81                                                      
 when d5.SectionCode='ETWC' then 82                                                      
 when d5.SectionCode='MED' then 340                                                      
 when d5.SectionCode='EXP' then 341                                                      
 when d5.SectionCode='CANX' then 342                                                      
 when d5.SectionCode='LUGG' then 343                                                      
 when d5.SectionCode='DELUG' then 344                                                      
 when d5.SectionCode='MONEY' then 345                                                      
 when d5.SectionCode='CAR' then 346                                                      
 when d5.SectionCode='TDEL' then 347                                                      
 when d5.SectionCode='REMP' then 348                                                      
 when d5.SectionCode='KIDNAP' then 349                                                      
 when d5.SectionCode='HOSP' then 350                                                      
 when d5.SectionCode='HIJACK' then 351                                                      
 when d5.SectionCode='LOI' then 352                                                      
 when d5.SectionCode='DISAB' then 353                                                      
 when d5.SectionCode='DEATH' then 354                                                      
 when d5.SectionCode='LIAB' then 355                                                      
 when d5.SectionCode='ETWC' then 356                                                      
 when d5.SectionCode='LEGAL' then 603           
 when d5.SectionCode='MCON' then 604  END as Section_ID,                                                    
                                                    
                                               
                                                    
isnull(d5.SectionCode,'')  as Section_Code,                
case when  a3.EventDate is  null then t.EventDateTime else a3.EventDate end as Incident_Date,                                                                                                                 
o.ReceivedDate  as  Reported_Date,                                                
a5.FinalisedDate  as Closed_Date,                                             
case when isnull(o33.StatusDesc,'')='' then o.StatusDesc else  isnull(o33.StatusDesc,'') end as Claim_Status,                                                                
isnull(replace(r.PrimaryDenialReason,',',';'),'')   as Claim_Denial_Reasons,                                                                                                             
isnull(replace(r.ClaimWithdrawalReason,',',';'),'')   as Claim_Withdrawal_Reasons,                                                
isnull(replace(e.BenefitCategory,',',';'),'')  as Claim_Benefit,                                          
isnull(a3.PerilCode,'')  as Peril_Code,                                                            
isnull(a3.PerilDesc,'')  as  Peril_Description,                                                                              
isnull(replace(a4.Catastrophe,',',';'),'')  as Event_Description,                                                                                                   
--isnull(a7.expensetype,'') as Cost_Type,      
isnull(replace(e.BenefitCategory,',',';'),'')  as Cost_Type,                                                                                                            
isnull(o34.Traveller_Sequence_No,'')  as Traveller_Sequence_No,                                                                                      
'No'  as Luggage_Flag,                                                                        
'No'  as Snow_Sports_Flag,                                                                                                             
'No'  as PEMC_Flag,                                                                                                                        
'No' as Covid_Flag,                                                                                                                          
'No' as Cruise_Flag,                                                                               
'No' as Motorbike_Flag,                                                                                                                        
'No' as Adventure_Activities_Flag,                                                                                                                        
isnull(case when a4.EventCountryName is null then a3.EventCountryName else a4.EventCountryName end ,'')  as Incident_Country,                                                                                     
isnull(EstimateMovement,0) as Reserve_Amount,                                                                                    
isnull(PaymentMovement,0)  as Paid_Amount,                                                                                    
isnull(RecoveryEstimateMovement,0) as Recovery_Amount,                                                                      
MovementSequence as Movement_Sequence,                                                                      
FirstMovementInDay as First_Movement_In_Day,                                                                      
isnull(r.AssessmentOutcomeDescription,'')  as Assessment_Outcome_Description,                                                                                     
D.Excess as Excess_Amount,                                                            
e.PaymentDate as Payment_Date,                                                                                    
'' as Is_Assistance_Case,                      
isnull(replace(a3.EventDesc,',',''),'') as Loss_Description,                                                                                    
 AgencyCode AS Agency_Code,         
 PlanName AS [Plan_Type_Name]            
             
             
                                                                                         
from                                                                        
(select distinct o.policyno,o.Claimno,o.ReceivedDate,o.StatusDesc,o.ClaimKey,o.CountryKey,o.PolicyKey,o.PolicyID,o.AgencyCode                                                                        
from [db-au-cmdwh].[dbo].clmClaim o  with(nolock)                                                                                                                                  
  where AgencyCode IN ('BGD0001','BGD0002','BGD0003','AGN0001','AGN0002')   and ClaimKey in 
  (
    select ClaimKey from [db-au-cmdwh].[dbo].clmClaim where AgencyCode IN ('BGD0001','BGD0002','BGD0003','AGN0001','AGN0002')                                                                          
  and convert(date,CreateDate,103)BETWEEN Convert(date,@StartDate,103) AND    Convert(date,@EndDate,103)              
  union                                                                
  select A.ClaimKey from [db-au-cmdwh].[dbo].clmClaim as a inner join [db-au-cmdwh].[dbo].clmClaimIncurredMovement                                                                
  as b on a.ClaimKey=b.ClaimKey and convert(date,IncurredDate,103) BETWEEN Convert(date,@StartDate,103) AND    Convert(date,@EndDate,103)                                                                
  union                                                                
 select  ClaimKey                                                                
from [db-au-cmdwh].[dbo].e5WorkActivity_v3 r1 with (nolock)                                                                                
 inner join [db-au-cmdwh].[dbo].e5Work_v3  b with (nolock) on r1.Work_ID=b.Work_ID and r1.AssessmentOutcome is not null                                                                 
 inner join [db-au-cmdwh].[dbo].[ve5WorkProperties] p on p.Work_Id = b.Work_id and p.Work_Id = r1.Work_id                                                                 
 where convert(date,r1.CompletionDate,103) BETWEEN Convert(date,@StartDate,103) AND    Convert(date,@EndDate,103)

  )
                                                                                  
                                                         
  )o                                                                                                                                  
  outer apply (                                                                              
                                                                          
select distinct CompanyKey,countrykey,PolicyNumber,PolicyID,PolicyKey,OutletAlphaKey,OutletSKey,IssueDate,PrimaryCountry as Destination, Area,Excess,TripCost,PlanName,AreaCode,AreaName,AreaNumber,AreaType,TripStart,TripEnd,MaxDuration,TripType,PlanCode, 
  
    
      
        
          
           
               
               
                  
                     
                                                                                
datediff(day,IssueDate,TripStart)  as [Days_To_Departure] ,MultiDestination                                                                                                                               
  from [db-au-cmdwh].[dbo].penPolicy p  with (nolock)                                                                                                         
   where AlphaCode IN ('BGD0001','BGD0002','BGD0003','AGN0001','AGN0002') and o.PolicyNo = p.PolicyNumber                                                                                                                            
 )d                                                 
                                                 
 outer apply                                                
 (                                                
 select ClaimKey,StatusDesc,date from (      
select distinct ClaimKey,StatusDesc,                                              
 convert(date,case when FinalisedDate is  null then ReceivedDate else FinalisedDate end,103)                                              
 as Date,      
 case when FinalisedDate is  null then ReceivedDate else FinalisedDate end                                               
 as New_Date,      
 ROW_NUMBER()over(partition by claimkey order by case when FinalisedDate is  null then ReceivedDate else FinalisedDate end desc) as rno      
                                                     
 from [db-au-cmdwh].[dbo].clmAuditClaim  as o2 where     
 convert(date,case when FinalisedDate is  null then ReceivedDate else FinalisedDate end,103) between Convert(date,@StartDate,103) and Convert(date,@EndDate,103) ) as a where rno=1 and a.ClaimKey=o.ClaimKey                                      
 ) o33                               
                             
 outer apply                             
 (                            
 select * from (                            
  select ClaimKey,Traveller_Sequence_No from [db-au-cmdwh].[dbo].vw_Traveller_Sequence_No as a  left join (                            
 select distinct PolicyKey,FirstName,Surname,DOB,ClaimKey from [db-au-cmdwh].[dbo].clmClaimSummary where ClaimKey in (select ClaimKey from [db-au-cmdwh].[dbo].clmClaim where AgencyCode in ('BGD0001','BGD0002','BGD0003','AGN0001','AGN0002') )              
  
    
      
        
              
) as b on a.PolicyKey=b.PolicyKey and a.FirstName=b.FirstName and a.LastName=b.Surname and a.DOB=b.DOB                            
where b.FirstName is not null) as a where  a.ClaimKey=o.ClaimKey                            
)o34                            
outer apply                     
(                  
select distinct ClaimKey,SectionKey,SectionCode from [db-au-cmdwh].[dbo].clmSection as d4                  
where d4.ClaimKey=o.ClaimKey                  
)                  
d5                  
                                                
                                                
                                                             
 outer apply                                                                   
                                                                                      
 (select * from (                                                                          
select a.SectionCode,BenefitCategory,b.EstimateMovement                           
as EstimateMovement,b.RecoveryEstimateMovement,EstimateDateTime,null as PaymentDate,null as PaymentMovement,                       null as PaymentDateTime,b.ClaimKey,MovementSequence,FirstMovementInDay,EstimateDateTime as Createddate from                 
  
    
      
        
         
           
 [db-au-cmdwh].[dbo].clmClaimEstimateMovement as a  inner join [db-au-cmdwh].[dbo].clmClaimIncurredMovement                      
as b on a.ClaimKey=b.ClaimKey and a.EstimateMovement=b.EstimateMovement  and a.EstimateDateTime=b.IncurredTime                      
and convert(date,a.EstimateDateTime,103) between Convert(date,@StartDate,103) and   Convert(date,@EndDate,103)                  
                      
union                      
select a.SectionCode,a.benefitcategory,null                                                                                        
as estimatemovement,null as recoveryestimatemovement,null as estimatedatetime, paymentdate, a.paymentmovement,                                              
paymentdatetime,a.claimkey,movementsequence,firstmovementinday,paymentdate as                                                                         
createddate                                                                        
from  [db-au-cmdwh].[dbo].clmclaimpaymentmovement                                                                          
as a                                                                        
inner join [db-au-cmdwh].[dbo].clmclaimincurredmovement as b on a.paymentdatetime=b.incurredtime and a.paymentmovement=b.paymentmovement  and a.ClaimKey=b.ClaimKey                     
and convert(date,a.paymentdatetime,103)between Convert(date,@StartDate,103) and    Convert(date,@EndDate,103)                
) as a                      
                       
 where a.ClaimKey=o.ClaimKey and a.SectionCode=d5.SectionCode) e                                                         
                                                        
                                                        
outer apply (                                                                                                                     
    select distinct t1.EventDateTime,t1.PerilCode,t1.PerilDescription,t1.CountryKey,t1.ClaimKey,t1.ClaimNo,t1.OnlineClaimID,t1.OnlineClaimKey       from   [db-au-cmdwh].[dbo].ClmOnlineClaimEvent t1  with (nolock)                                           
  
    
      
                    
    where o.CountryKey=t1.CountryKey and o.ClaimKey=t1.ClaimKey and o.ClaimNo=t1.ClaimNo                                     
    )t                               
         
    --outer apply                              
    --(                           
    --select ClaimKey,SectionKey,EventKey,SectionID,SectionCode from clmSection as t2 where      t2.ClaimKey=o.ClaimKey                          
                          
    --)  as t3             
                                                                                      
 --outer apply (                                                    
 --   select distinct a1.CountryKey,a1.ClaimKey,a1.ClaimNo,a1.CostDescription,a1.OnlineClaimID,a1.OnlineClaimKey               
 --from   [db-au-cmdwh].[dbo].[clmOnlineClaimCosts]  a1  with (nolock)                                                                                                                               
 --   where o.CountryKey=a1.CountryKey and o.ClaimKey=a1.ClaimKey and o.ClaimNo=a1.ClaimNo and t.OnlineClaimID=a1.OnlineClaimID                  and t.OnlineClaimKey=a1.OnlineClaimKey)a                                                          
 outer apply                                                        
 (                                 
 select distinct a2.EventDate,CatastropheShortDesc,replace(replace(replace(EventDesc,char(13),''),char(10),''),' ','') as EventDesc,EventCountryName,PerilCode,PerilDesc from [db-au-cmdwh].[dbo].clmEvent as a2 where a2.ClaimKey=o.ClaimKey                  
  
   
      
        
                                       
 --and DATEPART(year,a2.EventDate)=2023                                                        
 ) as a3                      
                      
 outer apply                                                        
 (                                                        
 select distinct ClaimKey,EventCountryName,                      
 case when Catastrophe is null then '' else Catastrophe end as  Catastrophe                      
 from [db-au-cmdwh].[dbo].clmClaimSummary as a4 where a4.ClaimKey=o.ClaimKey                                                                                        
 ) as a4                 
 outer apply                
 (                
 select FinalisedDate from [db-au-cmdwh].[dbo].clmclaim as a5 where a5.ClaimKey=o.ClaimKey                
 and StatusDesc='Finalised'                
 ) as a5                
                
                
                
 --outer apply                                                      
 --(                                                      
 --select distinct ClaimKey,expensetype from [db-au-cmdwh].[dbo].clmonlineclaimcosts as a6 where a6.ClaimKey=o.ClaimKey                                                       
                                                      
 --)  as a7                                                      
                                                         
                                                                                                                                      
                                                                                                                                  
 outer apply (                                                                                                                                  
    select distinct n1.LuggageFlag,n1.WinterSportFlag,n1.CruiseFlag,n1.MopedFlag,n1.ClaimKey                                                                                                
        from   [db-au-cmdwh].[dbo].[clmClaimFlags] n1  with (nolock)                                                                                                                                  
    where  o.ClaimKey=n1.ClaimKey )n                                                                                        
                                                                                      
 --outer apply (                                                                                                                                  
 --   select distinct i1.isPrimary,i1.PolicyKey                                                            
 --     from   [db-au-cmdwh].[dbo].[penPolicyTraveller] i1  with (nolock)                                              
 --   where   o.CountryKey=i1.CountryKey and e.PolicyKey=i1.PolicyKey and i1.isPrimary=1)i                                                                                                                                  
                                                                                                                                  
  outer apply               
 (select distinct MedicalSummary_c,PolicyNumber__c  from [db-au-atlas].[atlas].[Case] as L1 with (nolock) where o.PolicyNo collate Latin1_General_CI_AS=L1.PolicyNumber__c                                                                                    
   
                       
                                                   
                                                               
 ) L                                                                                       
                                                                   
  outer apply (                                                                           
  select distinct a1.policytravellerkey,a1.Title,a1.FirstName,a1.LastName,a1.EmailAddress,a1.MobilePhone,a1.State,a1.DOB,a1.Age,PostCode,                                                                                                       
  a1.PolicyKey,                                                                
  --PolicyTransactionKey,                                                                        
(select min(DOB) as OldestTraveller_DOB from [db-au-cmdwh].[dbo].penPolicyTraveller as c where c.PolicyKey=a1.PolicyKey and CountryKey='AU'                                                                                                                    
  
   
      
         
         
            
               
               
  and CompanyKey='TIP' group by PolicyID)                                                                                                                                  
  as OldestTraveller_DOB ,                                                                                                    
  (select max(AGE) as OldestTraveller_AGE from [db-au-cmdwh].[dbo].penPolicyTraveller as c where c.PolicyKey=a1.PolicyKey and CountryKey='AU'                                                      
and CompanyKey='TIP' group by PolicyID)                                                                                                                                  
  as OldestTraveller_Age                                                                        
  from [db-au-cmdwh].[dbo].penPolicyTraveller a1  with (nolock)                         
  where d.PolicyKey=a1.PolicyKey  )a1                                                                                                                              
                                                  
 outer apply (                                                                         
 select sum(ppp.GrossPremium) 'PEMC_Premium',CASE WHEN pptt.HasEMC = 1 then 'Yes' else 'No' End as 'PEMC_Flag'                                                                                                                                
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp join [db-au-cmdwh].[dbo].penPolicyEMC ppe on ppp.ComponentID = ppe.PolicyEMCID and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and ppp.GroupID = 5 and ppp.isPOSDiscount = 1                                 
  
    
      
        
          
            
              
                
                 
                    
                                                                    
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt on ppe.PolicyTravellerTransactionKey = pptt.PolicyTravellerTransactionKey and pptt.HasEMC = 1                                                      
 where pptt.PolicyTravellerKey = a1.PolicyTravellerKey                                                                                                                                
 group by pptt.HasEMC) o5                                                                                        
                   
 outer apply ( select * from (                                                                        
 select  r1.AssessmentOutcomeDescription,ClaimKey,ClaimNumber,PolicyNumber, p.PrimaryDenialReason, p.[ClaimWithdrawalReason]                                                                        
 ,r1.CompletionDate,row_number()over(partition by ClaimKey order by r1.CompletionDate desc) as rno                                                                        
 from [db-au-cmdwh].[dbo].e5WorkActivity_v3 r1 with (nolock)                                                                                                                                 
 inner join [db-au-cmdwh].[dbo].e5Work_v3  b with (nolock) on r1.Work_ID=b.Work_ID and r1.AssessmentOutcome is not null                                                                         
 inner join [db-au-cmdwh].[dbo].[ve5WorkProperties] p on p.Work_Id = b.Work_id and p.Work_Id = r1.Work_id                                                               
 where  convert(date,r1.CompletionDate,103) between Convert(date,@StartDate,103) and  Convert(date,@EndDate,103)) as x where rno=1                                                                         
 and  o.ClaimKey=x.ClaimKey           
  )r            
       
          
          
  order by isnull(o.ClaimKey,''),MovementSequence 
GO
