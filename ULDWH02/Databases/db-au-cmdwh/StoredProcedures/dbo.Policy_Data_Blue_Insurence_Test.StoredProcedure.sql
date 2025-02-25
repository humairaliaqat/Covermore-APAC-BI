USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[Policy_Data_Blue_Insurence_Test]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
        
                    
                                            
CREATE Procedure [dbo].[Policy_Data_Blue_Insurence_Test] -- '2024-09-01 22:53:30.887' ,'2024-09-13 22:53:30.887'                                                                      
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
 cast(ISNULL(q3.Total_Gross_Premium,'')as decimal(10,4))  as [Total_Premium],    
 cast(ISNULL(q5.Base_Premium,'') as decimal(10,4)) as [Base_Premium],    
 cast(ISNULL(q7.AddOn_Premium,'')as decimal(10,4)) as [AddOn_Premium],    
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
'724100061358',  
'724100060109',  
'724100059378',  
'724100058553',  
'724100058550',  
'724100058246',  
'724100058233'  
      
      
      
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
 select PolicyTransactionKey,sum(GrossPremiumAfterDiscount)-(sum(GSTAfterDiscount)+sum(StampDutyAfterDiscount)) as [Base_Premium] from [db-au-cmdwh]..vpenPolicyPriceComponentOptimise as q4  with (nolock) where  q4.PolicyTransactionKey=m.PolicyTransactionKey    
 and PriceCategory='Base Rate'    
 group by PolicyTransactionKey    
    
    
 )as q5    
    
    
  outer apply    
 (    
 select PolicyTransactionKey,sum(GrossPremiumAfterDiscount) AS [AddOn_Premium] from [db-au-cmdwh]..vpenPolicyPriceComponentOptimise as q6  with (nolock) where  q6.PolicyTransactionKey=m.PolicyTransactionKey    
 and PriceCategory<>'Base Rate'    
 group by PolicyTransactionKey    
    
    
 )as q7    
    
    
                                                  
  END         
        
        
        
        
        
        
GO
