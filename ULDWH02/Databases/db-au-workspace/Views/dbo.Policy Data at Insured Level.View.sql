USE [db-au-workspace]
GO
/****** Object:  View [dbo].[Policy Data at Insured Level]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

      
      
                            
      
      
CREATE view [dbo].[Policy Data at Insured Level]                                       
as                                      
                                      
                                      
select distinct                              
     isnull(p.QuoteID,'') AS [Lead_Number],                                      
     isnull(d.PolicyNumber,'') [Policy Number],                                      
     isnull(b.TransactionType,'') AS [Transaction Type],                                      
     isnull(b.PolicyTransactionKey,'') AS [Transaction_Sequence_Number],                                      
     isnull(b.TransactionStatus,'') AS [Transaction_Status] ,                                      
     isnull(b.TransactionDateTime,'') AS [Transaction_Date],                                
     isnull(d.IssueDate,'') AS Sold_Date,                                 
     isnull(d.IssueDate,'') AS  RateEffective_Date,                                
     isnull(Traveller_Sequence_No,'') AS Traveller_Sequence_No,                                     
     isnull(a.Title,'') AS [Traveller_Title],                                      
     isnull(a.FirstName,'') AS [Policyholder_First_Name],                                      
     isnull(a.LastName,'') AS [Policyholder_Surname],                                      
     isnull(a.DOB,'') AS [Traveller_DOB],                                      
     isnull(a.Age,'') AS [Traveller_Age],                                      
     isnull(CONVERT(VARCHAR(30),a.EMCScore),'') AS [Traveller_MedicalRiskScore],                                      
     isnull(CONVERT(VARCHAR(30),a.AssessmentType),'') AS [Traveller_PEMC_AssessmentOutcome],                                      
     isnull(CONVERT(VARCHAR(30),a.EmcCoverLimit),'') AS [Traveller_PEMC_AdditionalPremium],                                      
     isnull(PEMC_Flag,'') AS [Traveller_PEMC_Flag ],                                
     '' AS [Traveller_CancellationRiskScore]                                
                                      
                                       
--select COUNT (1)                                      
from                                      
(select distinct CountryKey,CompanyKey,OutletSKey,PolicyKey,PolicyID,IssueDate,PolicyNumber,PolicyNoKey                                      
  from  [db-au-cmdwh].[dbo].penPolicy with(nolock)    --AlphaCode IN ('BGD0001','BGD0002','BGD0003') AND       
 --convert(date,IssueDate,103)=convert(date,getdate()-1,103)       
       
 where PolicyNumber in (              
  select distinct a.PolicyNumber from [db-au-cmdwh].[dbo].penPolicy as a inner join [db-au-cmdwh].[dbo].penPolicyTransaction        
  as b on a.PolicyKey=b.PolicyKey  where AlphaCode in ('BGD0001','BGD0002','BGD0003') and convert(date,b.IssueDate,103)=convert(date,getdate()-1,103))       
  and AlphaCode in ('BGD0001','BGD0002','BGD0003')                             
 )d                                      
 ---440014                                      
                                      
    outer apply (                                      
  select distinct p1.QuoteID from [db-au-cmdwh].[dbo].penQuote p1 with(nolock)                                      
 where d.CountryKey=p1.CountryKey and d.CompanyKey=p1.CompanyKey and d.OutletSKey=p1.OutletSKey                                       
 and d.PolicyKey=p1.PolicyKey --and d.PolicyID=p1.PolicyID                                     
 )p                                      
  --440014                                      
                                      
                                      
 outer apply (                                      
   select distinct b1.PolicyTransactionKey,b1.TransactionStatus ,b1.TransactionDateTime,CompanyKey,CountryKey,PolicyTransactionID,                         TransactionType  from [db-au-cmdwh].[dbo].penPolicyTransaction b1 with(nolock)                      
  
  
                
   where d.CountryKey=b1.CountryKey and d.CompanyKey=b1.CompanyKey and d.PolicyKey=b1.PolicyKey                                       
 and d.PolicyNoKey=b1.PolicyNoKey and d.PolicyNumber=b1.PolicyNumber)b                                      
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
 select sum(ppp.GrossPremium) 'PEMC_Premium',CASE WHEN pptt.HasEMC = 1 then 'Yes' else 'No' End as 'PEMC_Flag'             from [db-au-cmdwh].[dbo].penPolicyPrice ppp join [db-au-cmdwh].[dbo].penPolicyEMC ppe on ppp.ComponentID = ppe.PolicyEMCID and ppp. 
  
    
      
        
         
CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and ppp.GroupID = 5 and ppp.isPOSDiscount = 1                                        
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt on ppe.PolicyTravellerTransactionKey = pptt.PolicyTravellerTransactionKey and pptt.HasEMC = 1                                        
 where pptt.PolicyTravellerKey = a.PolicyTravellerKey                                        
 group by pptt.HasEMC)q            
 ---463097 
GO
