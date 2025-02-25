USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[Policy_Data_Blue_Insurence_CTM]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


                        
                                                
CREATE Procedure [dbo].[Policy_Data_Blue_Insurence_CTM] -- '2024-09-01 22:53:30.887' ,'2024-09-13 22:53:30.887'

-- Change History                  
                  
--2024-NOV-27 - CR-CHG0040082 Created This procedure to Generate CTM Monthly Blue Insurence Sales Report                                                                            
@StartDate datetime,      
@EndDate datetime      
as                                                                                    
begin                                                                                    
 SELECT                                                                                                                                                 
    DISTINCT          
         
 'Blue' as Company,        
 'Compare the Market' as Scheme,        
 ISNULL(d.PolicyNumber,'') AS Policy_Number,        
 ISNULL(d.TripType,'') as [Cover_Type],        
 ISNULL(d.AreaType,'') as [Geographic_Type],        
 ISNULL(ProductName,'')  as [Product_Description],        
 ISNULL(ExternalReference2,'')  as [QuoteReferenceNumber],        
 'CTM'     as [Comparison Brand],        
 'Blue'                   as [Brand],        
 ISNULL(d.IssueDate,'')  as [Sold_Date],        
 ISNULL(d.TripStart,'')  as [Commencement_Date],        
 ISNULL(convert(varchar(120),d.CancelledDate,120),'')  as [Cancellation_Date],        
 ISNULL(b.CancellationReason,'')   as [Cancellation_Reason],        
 cast(ISNULL(Referral_Fee,'')as decimal(10,4))   as [Referral_Fee],        
 cast(ISNULL(m.TaxOnAgentCommissionGST,'')as decimal(10,4)) as [Referral_Fee_GST],        
 cast(ISNULL(m.Commission,'')as decimal(10,4))    as [Referral_Fee_Inc_GST],        
 'Percentage'    as [Commission_Type],        
 'Percentage'  as [Commission_Rate],        
 cast(ISNULL(z.GrossPremium,'')as decimal(10,4))  as [Total_Premium],        
 cast(ISNULL(z.BasePremium,'') as decimal(10,4)) as [Base_Premium],        
 cast(ISNULL(z.Addon_Premium,'')as decimal(10,4)) as [AddOn_Premium],        
  case                                                 
 when b.TransactionStatus='Cancelled' and d.StatusDescription='Cancelled' then  'Cancellation'                                            
 when b.TransactionStatus='CancelledWithOverride' and d.StatusDescription='Cancelled' then  'Cancellation'                                             
 when b.TransactionStatus='Active' and b.TransactionType='Base'  then  'Sale'                                                
 when b.TransactionStatus='Active' and b.TransactionType!='Base'  then  'Trail'   END  as [Record_Type],        
 replace(convert(varchar(7), @StartDate, 126),'-','')    as [InvPeriod]                                                                                                                                                                                        
  
    
                                                      
                            
                                                                                                                                                          
 from                                                            
(select distinct CompanyKey,countrykey,PolicyNumber,PolicyID,PolicyKey,OutletAlphaKey,OutletSKey,IssueDate,PrimaryCountry as Destination,   Area,Excess,TripCost,PlanName,AreaCode,AreaName,AreaNumber,AreaType,TripStart,TripEnd,                             
  
    
      
       
datediff(day,TripStart, TripEnd)+1 as Trip_Duration,TripType,PlanCode,                                                                                                                           
datediff(day,IssueDate,TripStart)  as [Days_To_Departure] ,replace(MultiDestination,',','') AS MultiDestination,                                                      
CASE WHEN CancellationCover='1000000' THEN 'Unlimited' else CancellationCover end as CancellationCover,                                                              
'Blue Insurence' as [Agency_Name],'Blue Insurence' as Brand,            
ExternalReference1,            
ExternalReference2,          
ExternalReference3 AS   Quote_Reference_ID,        
CancelledDate,        
ProductName,        
StatusDescription        
                                                              
  from [db-au-cmdwh].[dbo].penPolicy  with (nolock)                                                                                                                 
  where PolicyNumber in (                                                                                                             
 select distinct a.PolicyNumber from [db-au-cmdwh].[dbo].penPolicy  as a with (nolock) inner join [db-au-cmdwh].[dbo].penPolicyTransaction                                                                                                                
  as b with (nolock) on a.PolicyKey=b.PolicyKey  where AlphaCode in ('BIN0003') and                                                                                           
  convert(date,b.IssueDate,103) between Convert(date,@StartDate,103) and Convert(date,@EndDate,103)           
          
  )                                                                                                      
  --AlphaCode in ('BIN0003') and convert(date,IssueDate,103)=convert(date,getdate()-1,103)                                                                                                            
    and AlphaCode in ('BIN0003')                                                                                                
                                                                                                 
 )d                            
                         
                        
   outer apply (                                                                                    
    select distinct b1.PolicyTransactionID ,b1.TransactionType,b1.PolicyTransactionKey,b1.TransactionStatus,b1.TransactionDateTime,                                                                        
 b1.PolicyKey,CancellationReason   from [db-au-cmdwh].[dbo].penPolicyTransaction b1  with (nolock)                                                     
                                                                           
                                                         
  where d.PolicyKey=b1.PolicyKey                               
  --and m.PolicyTransactionKey=b1.PolicyTransactionKey                               
  and                                                                                     
  convert(date,b1.IssueDate,103) between Convert(date,@StartDate,103) and Convert(date,@EndDate,103) )b                         
                                                                                                                                         
                                                                                                                                         
     outer apply (                           
    select distinct m1.commission,m1.newpolicycount,m1.BasePremium 'BasePremium',PostingDate,PolicyTransactionKey,GrossPremium,m1.PolicyKey,m1.TaxOnAgentCommissionGST,m1.TaxOnAgentCommissionSD,        
 m1.Commission-m1.TaxOnAgentCommissionGST as   Referral_Fee        
 from                                                  
 [db-au-cmdwh].[dbo].penPolicyTransSummary                                                                    
                                                                      
 m1  with (nolock)  where m1.PolicyKey= d.PolicyKey and convert(DATE,m1.IssueDate,103) between Convert(date,@StartDate,103) and Convert(date,@EndDate,103)                        
 and m1.PolicyTransactionKey=b.PolicyTransactionKey  )m                                                 
                                                 
 outer apply                                                
 (                                                
                                
 select  PolicyKey,AdultsCount,ChildrenCount,TravellersCount,SingleFamilyFlag            
 from  [db-au-cmdwh].[dbo].penPolicyTransSummary as m2 with (nolock)                                                
  where m2.PolicyKey=d.PolicyKey and TransactionType='Base'  and TransactionStatus='Active'                                              
 ) m3                                                
  
 outer apply    
( select PolicyTransactionKey,    
GrossPremium-(TaxAmountGST+TaxAmountSD) as GrossPremium,    
BasePremium-(Base_GST+Base_SD) as BasePremium,    
Addon_Premium-(Addon_GST+Addon_SD) as Addon_Premium    
from (    
select a.PolicyTransactionKey,TaxAmountGST,TaxAmountSD,GrossPremium,BasePremium,Addon_Premium,    
case when TaxAmountGST<>'0.00' then TaxAmountGST/GrossPremium*BasePremium else TaxAmountGST end as Base_GST,    
case when TaxAmountSD<>'0.00' then TaxAmountSD/GrossPremium*BasePremium else TaxAmountGST end as Base_SD,    
case when TaxAmountGST<>'0.00' then TaxAmountGST/GrossPremium*Addon_Premium else TaxAmountGST end as Addon_GST,    
case when TaxAmountSD<>'0.00' then TaxAmountSD/GrossPremium*Addon_Premium else TaxAmountGST end as Addon_SD    
from (    
select PolicyTransactionKey,sum(GrossPremium) as GrossPremium,sum(TaxAmountGST) as TaxAmountGST,sum(TaxAmountSD) as TaxAmountSD     
from penPolicyTransSummary     
group by PolicyTransactionKey) as a    
  inner join (        
 select     
 PolicyTransactionKey,    
 sum(case when PriceCategory='Base Rate' then GrossPremiumAfterDiscount end)  as BasePremium,    
 sum(case when PriceCategory<>'Base Rate' then GrossPremiumAfterDiscount end) as Addon_Premium    
 from [db-au-cmdwh]..vpenPolicyPriceComponentOptimise as q4  with (nolock)             
 group by PolicyTransactionKey) as b  on a.PolicyTransactionKey=b.PolicyTransactionKey    
 ) as a where a.PolicyTransactionKey=m.PolicyTransactionKey    
 ) as z      
        
                                                      
  END             
            
            
            
            
GO
