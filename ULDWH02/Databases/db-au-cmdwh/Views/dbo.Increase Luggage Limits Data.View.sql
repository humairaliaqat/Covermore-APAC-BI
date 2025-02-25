USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[Increase Luggage Limits Data]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

      
      
      
CREATE view [dbo].[Increase Luggage Limits Data]                                     
as                                    
                                    
                                    
select                           
     distinct                            
  isnull(d.PolicyNumber,'') AS [Policy Number],                                    
     isnull(b.TransactionType,'') AS [Transaction Type],                                    
     isnull(b.PolicyTransactionKey,'') AS [Transaction_Sequence_Number],                                    
     isnull(b.TransactionStatus,'') AS [Transaction_Status],                                    
     isnull(b.TransactionDateTime,'') AS [Transaction_Date],                                    
     isnull(d.IssueDate,'') AS Sold_Date,                             
     isnull(d.IssueDate,'') AS RateEffective_Date,              
  isnull(Traveller_Sequence_No,'') AS Traveller_Sequence_No,                         
  '' AS Item_Sequence_No,                            
     isnull(g.AddOnText,'') AS Item_Description,                                    
     isnull(g.CoverIncrease,'') AS Item_Limit_Increase_Amount                             
--select top 100 *--COUNT(PolicyNumber)                                    
from                                  
    (select distinct PolicyNumber,CountryKey,CompanyKey,PolicyID,PolicyKey,IssueDate                                  
 from [db-au-cmdwh].[dbo].penPolicy  with(nolock)  --WHERE AlphaCode IN ('BGD0001','BGD0002','BGD0003')  AND               
 --convert(date,IssueDate,103)=convert(date,getdate()-1,103)        
       
 where PolicyNumber in (          
  select PolicyNumber from [db-au-cmdwh].[dbo].penPolicy where AlphaCode in ('BGD0001','BGD0002','BGD0003')     and convert(date,IssueDate,103)>=convert(date,getdate()-1,103)        
  union        
  select distinct a.PolicyNumber from [db-au-cmdwh].[dbo].penPolicy as a inner join [db-au-cmdwh].[dbo].penPolicyTransaction        
  as b on a.PolicyKey=b.PolicyKey  where AlphaCode in ('BGD0001','BGD0002','BGD0003') and convert(date,b.IssueDate,103)=convert(date,getdate()-1,103))       
   and AlphaCode in ('BGD0001','BGD0002','BGD0003')           
 )d                                  
 ---440124                                  
                        
                                   
     outer apply (                                  
  select distinct  b1.TransactionType,b1.PolicyTransactionKey,b1.TransactionStatus,b1.TransactionDateTime,b1.PolicyTransactionID                                 
  from [db-au-cmdwh].[dbo].penPolicyTransaction b1 with(nolock)                                  
  where  d.CountryKey=b1.CountryKey and d.CompanyKey=b1.CompanyKey and d.PolicyID=b1.PolicyID and d.PolicyNumber=b1.PolicyNumber )b                                  
  ---440206                                  
                                      
                                  
    outer apply (                                  
 select distinct a1.PolicyTravellerKey,ROW_NUMBER()OVER(PARTITION BY a1.PolicyKey order by a1.PolicyTravellerKey)            
as  Traveller_Sequence_No                               
 from [db-au-cmdwh].[dbo].penPolicyTraveller a1 with(nolock)                                  
 where d.CountryKey=a1.CountryKey and d.CompanyKey=a1.CompanyKey and d.PolicyKey=a1.PolicyKey                                   
 and d.PolicyID=a1.PolicyID --and isPrimary=1                            
 )a                                   
 ---440159                                  
                                   
                                  
   outer apply (                                  
  select b1.PolicyTransactionKey,b1.PolicyTransactionID from [db-au-cmdwh].[dbo].PenpolicyTravellerTransaction as b1 with(nolock)                                
  where d.CountryKey=b1.CountryKey and  d.CompanyKey=b1.CompanyKey and b.PolicyTransactionID=b1.PolicyTransactionID  and                                   b1.PolicyTransactionKey=b.PolicyTransactionKey and b1.PolicyTravellerKey=a.PolicyTravellerKey )c    
                 
                                  
                                
 outer apply (             
 select distinct  g1.AddOnText ,g1.CoverIncrease --- distinct convert(nvarchar(2000),  g1.AddOnText) as AddOnText                                  
 from [db-au-cmdwh].[dbo].penPolicyTravellerAddOn g1 with(nolock)                                  
 where d.CountryKey=g1.CountryKey and d.CompanyKey=g1.CompanyKey and g1.PolicyTravellerTransactionKey=c.PolicyTransactionKey)g 
GO
