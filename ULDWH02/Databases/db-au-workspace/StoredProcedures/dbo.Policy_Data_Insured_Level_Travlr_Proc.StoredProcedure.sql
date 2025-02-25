USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[Policy_Data_Insured_Level_Travlr_Proc]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- CHANGE HISTORY
--  2023-DEC-07 -- REPLACED COMMA WITH BLANK SPACE FOR NAME FIELDS
    
 --exec [Policy_Data_Insured_Level_Proc_20230205] '2023-03-15'                   
                                       
CREATE procedure [dbo].[Policy_Data_Insured_Level_Travlr_Proc] --'2023-12-01'                     
@StartDate Datetime                      
as                                                                        
      BEGIN                                                                  
                                                                        
select distinct                                                                
     isnull(p.QuoteID,'') AS [Lead_Number],                                                                        
     isnull(d.PolicyNumber,'') [Policy_Number],                                                                        
     isnull(b.TransactionType,'') AS [Transaction_Type],                                                                        
     isnull(b.PolicyTransactionKey,'') AS [Transaction_Sequence_Number],                                                                        
     isnull(b.TransactionStatus,'') AS [Transaction_Status] ,                                                                        
     isnull(convert(varchar(50),b.TransactionDateTime,120),'') AS [Transaction_Date],                                                                  
     isnull(convert(varchar(50),d.IssueDate,120),'') AS Sold_Date,                                                                   
     isnull(convert(varchar(50),d.IssueDate,120),'') AS  Rate_Effective_Date,                                                                  
     isnull(Traveller_Sequence_No,'') AS Traveller_Sequence_No,                                                                       
     convert(varchar(500),isnull(replace(a.Title,',',' '),'')) AS [Traveller_Title],                                                                        
     convert(varchar(500),isnull(replace(a.FirstName,',',' '),'')) AS [Policy_Holder_First_Name],                                                                        
     convert(varchar(500),isnull(replace(a.LastName,',',' '),'')) AS [Policy_Holder_Surname],                                                                        
     isnull(convert(varchar(50),a.DOB,120),'') AS [Traveller_DOB],                                                                        
     isnull(a.Age,'') AS [Traveller_Age],                                
     isnull(q.PEMC_Flag,'No') AS [Traveller_PEMC_Flag],                                
     isnull(CONVERT(VARCHAR(30),q3.MedicalRisk),'') AS [Traveller_Medical_Risk_Score],                                                   
     isnull(CONVERT(VARCHAR(30),q3.ApprovalStatus),'') AS [Traveller_PEMC_Assessment_Outcome],                                        
     isnull(PEMC_Premium,'') AS [Traveller_PEMC_Additional_Premium]                                                                        
                                                                       
     --'' AS [Traveller_CancellationRiskScore]                                                                  
                                                                        
                                                                         
--select COUNT (1)                                                                        
from                                                                        
(select distinct CountryKey,CompanyKey,OutletSKey,PolicyKey,PolicyID,IssueDate,PolicyNumber,PolicyNoKey                                                                        
  from  [db-au-cmdwh].[dbo].penPolicy with(nolock)    --AlphaCode IN ('BGD0001','BGD0002','BGD0003') AND                                         
 --convert(date,IssueDate,103)=convert(date,getdate()-1,103)                                         
                                         
 where PolicyNumber in (                                                
  select distinct a.PolicyNumber from [db-au-cmdwh].[dbo].penPolicy as a inner join [db-au-cmdwh].[dbo].penPolicyTransaction                                          
  as b on a.PolicyKey=b.PolicyKey  where AlphaCode in ('NPN0001','NPN0002','NPN0003') and                       
  convert(date,b.IssueDate,103)=Convert(date,@StartDate,103))                      
                        
                   
  and AlphaCode in ('NPN0001','NPN0002','NPN0003')                                      
 )d                                           
 ---440014                           
                                                                        
    outer apply (                                                                        
  select distinct p1.QuoteID from [db-au-cmdwh].[dbo].penQuote p1 with(nolock)                                                                        
 where d.CountryKey=p1.CountryKey and d.CompanyKey=p1.CompanyKey and d.PolicyKey=p1.PolicyKey --and d.PolicyID=p1.PolicyID                            
 UNION                            
SELECT distinct sessionid AS QuoteID FROM [db-au-cmdwh].dbo.cdg_factPolicy_AU_AG AS P2 WHERE P2.PolicyNumber=D.PolicyNumber                             
 COLLATE SQL_Latin1_General_CP1_CI_AS                            
                            
 )p                                                                        
  --440014                                                                        
                                                                        
                                                                        
 outer apply (                                                          
   select distinct b1.PolicyTransactionKey,b1.TransactionStatus ,b1.TransactionDateTime,CompanyKey,CountryKey,PolicyTransactionID,                         TransactionType  from [db-au-cmdwh].[dbo].penPolicyTransaction b1 with(nolock)                      
  
    
      
       
          
                                      
   where   b1.PolicyKey = d.PolicyKey and  convert(date,b1.IssueDate,103)=Convert(date,@StartDate,103))b                                                                        
 ---440014                                                                        
                                                                        
                                                                        
 outer apply (                                                                        
 select distinct a1.Title,a1.FirstName,a1.LastName,a1.DOB,a1.Age,a1.EMCScore,a1.AssessmentType,a1.EmcCoverLimit,PolicyTravellerKey,                                                
 ROW_NUMBER()OVER(PARTITION BY a1.PolicyKey ORDER BY a1.PolicyTravellerKey) as Traveller_Sequence_No                                                
 from [db-au-cmdwh].[dbo].penPolicyTraveller a1 with(nolock)                                                                        
 where d.CountryKey=a1.CountryKey and d.CompanyKey=a1.CompanyKey and d.PolicyID=a1.PolicyID and d.PolicyKey=a1.PolicyKey)a                                                                        
 --439995                                                                        
                                                                
                                                                        
 --outer apply (                                                                        
 --select distinct  q1.HasEMC                                                                        
 -- from [db-au-cmdwh].[dbo].penPolicyTravellerTransaction q1 with(nolock)                                                                        
 --where b.CountryKey=q1.CountryKey and b.CompanyKey=q1.CompanyKey and b.PolicyTransactionKey=q1.PolicyTransactionKey                                                                        
 --and b.PolicyTransactionID=q1.PolicyTransactionID )q                                                 
                                               
                       
                                              
                                              
  outer apply (                                                
 select sum(ppp.GrossPremium) 'PEMC_Premium',CASE WHEN pptt.HasEMC = 1 then 'Yes' else 'No' End as 'PEMC_Flag'                               
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp join [db-au-cmdwh].[dbo].penPolicyEMC ppe on ppp.ComponentID = ppe.PolicyEMCID         
 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and ppp.GroupID = 5 and ppp.isPOSDiscount = 1         
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt on ppe.PolicyTravellerTransactionKey = pptt.PolicyTravellerTransactionKey                                                                          
 where pptt.PolicyTravellerKey = a.PolicyTravellerKey      
 --and b.PolicyTransactionKey=pptt.PolicyTransactionKey                                                                         
 group by pptt.HasEMC)q           
 outer apply        
 (        
  select EMCApplicationKey  from  [db-au-cmdwh].[dbo].penPolicyEMC ppe  inner                                                      join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt on ppe.PolicyTravellerTransactionKey = pptt.PolicyTravellerTransactionKey                                                                            
 where pptt.PolicyTravellerKey = a.PolicyTravellerKey                                                                        
        
) q1        
outer apply        
(        
select MedicalRisk,ApprovalStatus from [db-au-cmdwh].[dbo].emcApplications as q2 where q2.ApplicationKey=q1.EMCApplicationKey        
) q3        
--Missing

UNION

select distinct                                                                            
     isnull(p.QuoteID,'') AS [Lead_Number],                                                                                    
     isnull(d.PolicyNumber,'') [Policy_Number],                                                                                    
     isnull(b.TransactionType,'') AS [Transaction_Type],                                                                                    
     isnull(b.PolicyTransactionKey,'') AS [Transaction_Sequence_Number],                                                                                    
     isnull(b.TransactionStatus,'') AS [Transaction_Status] ,                                                                                    
     isnull(convert(varchar(50),b.TransactionDateTime,120),'') AS [Transaction_Date],                                                                              
     isnull(convert(varchar(50),d.IssueDate,120),'') AS Sold_Date,                                                                               
     isnull(convert(varchar(50),d.IssueDate,120),'') AS  Rate_Effective_Date,                                                                              
     isnull(Traveller_Sequence_No,'') AS Traveller_Sequence_No,                                                                                   
     convert(varchar(500),isnull(replace(a.Title,',',' '),'')) AS [Traveller_Title],                                                                                    
     convert(varchar(500),isnull(replace(a.FirstName,',',' '),'')) AS [Policy_Holder_First_Name],                                                            
     convert(varchar(500),isnull(replace(a.LastName,',',' '),'')) AS [Policy_Holder_Surname],                                                   
     isnull(convert(varchar(50),a.DOB,120),'') AS [Traveller_DOB],                                                                                    
     isnull(a.Age,'') AS [Traveller_Age],                        
     isnull(q.PEMC_Flag,'No') AS [Traveller_PEMC_Flag],                                            
     isnull(CONVERT(VARCHAR(30),q3.MedicalRisk),'') AS [Traveller_Medical_Risk_Score],                                      
     isnull(CONVERT(VARCHAR(30),q3.ApprovalStatus),'') AS [Traveller_PEMC_Assessment_Outcome],                                                    
     isnull(PEMC_Premium,'') AS [Traveller_PEMC_Additional_Premium]                                                                                    
                                                                                   
     --'' AS [Traveller_CancellationRiskScore]                                                                              
                                                                                    
                                                                                     
--select COUNT (1)                                                                                    
from                                                                                    
(select distinct CountryKey,CompanyKey,OutletSKey,PolicyKey,PolicyID,IssueDate,PolicyNumber,PolicyNoKey                                                                                    
  from  [db-au-cmdwh].[dbo].penPolicy with(nolock)    --AlphaCode IN ('BGD0001','BGD0002','BGD0003') AND                                                     
 --convert(date,IssueDate,103)=convert(date,getdate()-1,103)                                                     
                                                     
 where PolicyNumber in (                                                            
  select distinct a.PolicyNumber from [db-au-cmdwh].[dbo].penPolicy as a inner join             
  [db-au-cmdwh].[dbo].penPolicyTransaction                                                      
  as b on a.PolicyKey=b.PolicyKey  where AlphaCode in ('NPN0001','NPN0002','NPN0003') and                                   
  PolicyTransactionKey in (               
select distinct PolicyTransactionKey from [db-au-cmdwh].[dbo].penPolicy as a inner join [db-au-cmdwh].[dbo].penPolicyTransaction                                                      
  as b on a.PolicyKey=b.PolicyKey  where AlphaCode in ('NPN0001','NPN0002','NPN0003') and                                   
  convert(date,b.IssueDate,103) between Convert(date,@StartDate-7,103)  and Convert(date,@StartDate-1,103)          
 Except             
 select Transaction_Sequence_Number  from [dbo].[Insured_Tbl_Travlr Group])            
              
              
              
  )                                  
                                    
                               
  and AlphaCode in ('NPN0001','NPN0002','NPN0003')                                                  
 )d                                                       
 ---440014                                       
                                                                                    
    outer apply (                                                                                    
  select distinct p1.QuoteID from [db-au-cmdwh].[dbo].penQuote p1 with(nolock)                                                                                    
 where d.CountryKey=p1.CountryKey and d.CompanyKey=p1.CompanyKey and d.PolicyKey=p1.PolicyKey --and d.PolicyID=p1.PolicyID                                        
 UNION                                        
SELECT sessionid AS QuoteID FROM [db-au-cmdwh].dbo.cdg_factPolicy_AU_AG AS P2 WHERE P2.PolicyNumber=D.PolicyNumber                                         
 COLLATE SQL_Latin1_General_CP1_CI_AS                                        
                                        
 )p        
  --440014                                                                                    
                               
                                                                                    
 outer apply (                                                                      
   select distinct b1.PolicyTransactionKey,b1.TransactionStatus ,b1.TransactionDateTime,CompanyKey,CountryKey,PolicyTransactionID, TransactionType  from [db-au-cmdwh].[dbo].penPolicyTransaction b1 with(nolock)                                              
     
       
                     
   where   b1.PolicyKey = d.PolicyKey and              
            
   PolicyTransactionKey in (            
select distinct PolicyTransactionKey from [db-au-cmdwh].[dbo].penPolicy as a inner join [db-au-cmdwh].[dbo].penPolicyTransaction                             
  as b on a.PolicyKey=b.PolicyKey  where AlphaCode in ('NPN0001','NPN0002','NPN0003') and                                   
  convert(date,b.IssueDate,103) BETWEEN  Convert(date,@StartDate-7,103)  and Convert(date,@StartDate-1,103)          
 Except             
 select Transaction_Sequence_Number  from [dbo].[Insured_Tbl_Travlr Group])            
               
               
               
               
   )b                                                                                    
 ---440014                                                                                    
                                                                                    
                                                                                    
 outer apply (                                                                                    
 select distinct a1.Title,a1.FirstName,a1.LastName,a1.DOB,a1.Age,a1.EMCScore,a1.AssessmentType,a1.EmcCoverLimit,PolicyTravellerKey,                                                            
 ROW_NUMBER()OVER(PARTITION BY a1.PolicyKey ORDER BY a1.PolicyTravellerKey) as Traveller_Sequence_No                                                            
 from [db-au-cmdwh].[dbo].penPolicyTraveller a1 with(nolock)                                                                                    
 where d.CountryKey=a1.CountryKey and d.CompanyKey=a1.CompanyKey and d.PolicyID=a1.PolicyID and d.PolicyKey=a1.PolicyKey)a                                                                                    
 --439995                                                                                    
                                                                            
                                                                                    
 --outer apply (                                                                                    
 --select distinct  q1.HasEMC                                                                                    
 -- from [db-au-cmdwh].[dbo].penPolicyTravellerTransaction q1 with(nolock)                                                                                    
 --where b.CountryKey=q1.CountryKey and b.CompanyKey=q1.CompanyKey and b.PolicyTransactionKey=q1.PolicyTransactionKey                                                                                    
 --and b.PolicyTransactionID=q1.PolicyTransactionID )q                                                             
                                                           
                       
                                                          
                                                          
  outer apply (                                       
 select sum(ppp.GrossPremium) 'PEMC_Premium',CASE WHEN pptt.HasEMC = 1 then 'Yes' else 'No' End as 'PEMC_Flag'                                           
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp join [db-au-cmdwh].[dbo].penPolicyEMC ppe on ppp.ComponentID = ppe.PolicyEMCID                     
 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and ppp.GroupID = 5 and ppp.isPOSDiscount = 1                     
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt on ppe.PolicyTravellerTransactionKey = pptt.PolicyTravellerTransactionKey                                 
 where pptt.PolicyTravellerKey = a.PolicyTravellerKey                  
 --and b.PolicyTransactionKey=pptt.PolicyTransactionKey                                                                                     
 group by pptt.HasEMC)q                       
 outer apply                    
 (                    
  select EMCApplicationKey  from  [db-au-cmdwh].[dbo].penPolicyEMC ppe  inner                                                      join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt on ppe.PolicyTravellerTransactionKey =   
  pptt.PolicyTravellerTransactionKey                                                                                        
 where pptt.PolicyTravellerKey = a.PolicyTravellerKey                                                                                    
                    
) q1                    
outer apply                    
(                    
select MedicalRisk,ApprovalStatus from [db-au-cmdwh].[dbo].emcApplications as q2 where q2.ApplicationKey=q1.EMCApplicationKey                    
) q3             
      
        
-- ---463097                       
 END         
        
        
        
        
        
        
        
        









GO
