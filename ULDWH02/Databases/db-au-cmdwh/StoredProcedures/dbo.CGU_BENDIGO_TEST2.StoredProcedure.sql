USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[CGU_BENDIGO_TEST2]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
          
CREATE PROCEDURE  [dbo].[CGU_BENDIGO_TEST2]                          
 @Startdate date                          
          
AS                          
          
/************************************************************************************************************************************            
Author:         Abhilash Yelmelwar          
Date:           20231213            
Prerequisite:   Requires ETL021 Penguin Data Model and ETL043_CDG_Quote_A&G successfully run.            
Description:    This proc being developed for fullfill the Bendigo Option 3 reporting          
Change History:  CHG0038312          
                          
*************************************************************************************************************************************/            
            
    set nocount on            
--Debug          
--exec [CGU_BENDIGO] '2023-10-31'            
          
BEGIN                          
select                           
 [Reference number]                          
,[Quote reference number]                          
,[Quote saved date]                          
,c.PolicyNumber as [Policy number]                          
,r.[User id] as [User id]                          
,r.[User name] as [User name]                          
,N.AlphaCode as [Branch id]                          
,N.OutletName as [Branch name]                          
,case when o.PromoCode is null then  s.Promocode else o.PromoCode end  as [Scheme/ Promotion]                          
,f.TransactionType as [Transaction type]                          
,CALLREASON as [Call type]                          
,[Customer given name 1]                          
,[Customer surname 1]                          
,[Customer DOB 1]                          
,[Member number 1]                          
,[Customer given name 2]                          
,[Customer surname 2]                          
,[Customer DOB 2]                          
,[Member number 2]                          
,[Customer given name 3]                          
,[Customer surname 3]                          
,[Customer DOB 3]                          
,[Member number 3]                          
,[Customer given name 4]                          
,[Customer surname 4]                          
,[Customer DOB 4]                          
,[Member number 4]                          
,[Customer given name 5]                          
,[Customer surname 5]                          
,[Customer DOB 5]                          
,[Member number 5]                          
,[Risk suburb]                          
,[Risk postcode]                          
,'Travel' as [Risk type]                          
,[Plan type]   as [Cover type]                          
,[Quote 1 product name]                          
,[Quote 1 premium]                          
,[Quote 1 excess]                          
,[Quote 2 product name]                          
,[Quote 2 premium]                          
,[Quote 2 excess]                          
,[Quote 3 product name]                          
,[Quote 3 premium]                          
,[Quote 3 excess]                          
,[Policy excess]               
,null as [Building premium]              
,null as [Contents premium]               
,null as [Liability premium]               
,null as [Specified contents premium]               
,null as [Unspecified valuables premium]              
,null as [Specified valuables premium]                        
,Motorbike_Flag as [Motor vehicle cover]              
,null as[Protected no claim bonus cover]              
,null as [Windscreen option selected]                        
,Motorcycle_Premium as [Motor premium]              
,null as [Interested party]                         
,[Destination]                          
,[Plan type]                          
,[Payment type]                       
,null as [Payment frequency]                 
,Total_Gross_Premium as [Policy Premium GWP]                          
,q.GrossPremium as   [Policy Premium Total]                         
,Cruise_Flag as [Cruise_cover]                          
,SnowSports_Flag as [Ski_cover]                          
,L.Luggage_Flag as [Specific_luggage_cover]                          
,L.Luggage_Premium as [Specific_luggage_cover_sum_insured]                          
,[Customer_Age_1] as [Insured_age_1]                          
,[Customer_Age_2] as [Insured_age_2]                          
--,[Customer_Age_3] as [Insured_age_3]                          
--,[Customer_Age_4] as [Insured_age_4]                          
--,[Customer_Age_5] as [Insured_age_5]                          
,[Annual_multi_trip_duration]                          
,CancellationCover as [Cancellation_only_sum_insured]                          
from (                     
                          
select PolicyKey,TripStart,TripEnd,datediff(day,TripStart,TripEnd)  as [Annual_multi_trip_duration],MultiDestination                          
as [Destination],PlanName as [Plan type],Excess as [Policy excess],PolicyNumber,OutletAlphaKey,CancellationCover from                           
[db-au-cmdwh]..penpolicy  with (nolock) where  policykey in                          
(                          
select PolicyKey from [db-au-cmdwh]..penpolicy  with (nolock) where convert(date,issuedate,103)=convert(date,@Startdate,103)                          
and AlphaCode  in (select distinct AlphaCode from penOutlet nolock where GroupName='Bendigo Bank'    
and OutletStatus='Current')                          
union                          
select a.PolicyKey from [db-au-cmdwh]..penpolicytransaction                          
as a  with (nolock) inner join [db-au-cmdwh]..penpolicy as b  with (nolock) on a.PolicyKey=b.PolicyKey                     
where convert(date,a.issuedate,103)=convert(date,@Startdate,103)                          
and AlphaCode in (select distinct AlphaCode from penOutlet nolock where GroupName='Bendigo Bank'    
and OutletStatus='Current')                     
                  
)                          
) as c                           
outer apply                          
(                          
select * from (                          
select a.SessionID as  [Quote reference number]                          
,convert(varchar(50),SessionToken) as [Reference number]                          
,Date as [Quote saved date]                          
,e.PolicyNumber                          
,PolicyKey                          
,convert(varchar(50),a.SessionID) as QuoteCountryKey  from [db-au-stage]..cdg_factQuote_AU_AG                           
as a with(nolock) INNER  join [db-au-stage]..cdg_factSession_AU_AG as b with(nolock) on a.SessionID=b.FactSessionID                          
INNER join [db-au-stage]..cdg_dimDate_AU_AG as c with(nolock) on a.QuoteTransactionDateID=c.DimDateID                   
LEFT JOIN  [db-au-stage]..cdg_factPolicy_AU_AG as d with(nolock) on a.sessionid=d.sessionid                          
inner join [db-au-cmdwh]..penpolicy as e on d.PolicyNumber=e.PolicyNumber collate SQL_Latin1_General_CP1_CI_AS                          
union                          
select QuoteID as [Quote reference number]                          
,convert(varchar(100),SessionID) as [Reference number]                          
,CreateDate as [Quote saved date]                          
,PolicyNo collate SQL_Latin1_General_CP1_CI_AS as   PolicyNo                          
,PolicyKey                          
,QuoteCountryKey  from [db-au-cmdwh]..penQuote with(nolock)                          
) as a1 where (c.PolicyKey=a1.PolicyKey)                          
                          
) as a                          
--outer apply                          
--(                          
--select PolicyNumber,SessionID from [db-au-stage]..cdg_factPolicy_AU as b1 where b1.SessionID=a.[Quote reference number]                          
--) as b                           
                          
outer apply    (                          
select PolicyKey,     
MAX(CASE WHEN rno=1 THEN FirstName END) AS [Customer given name 1],                          
MAX(CASE WHEN rno=1 THEN LastName END) AS [Customer surname 1],                          
MAX(CASE WHEN rno=1 THEN DOB END) AS [Customer DOB 1],                          
MAX(CASE WHEN rno=1 THEN EmailAddress END) AS Customer_EmailAddress_1,                          
MAX(CASE WHEN rno=1 THEN Age END) AS Customer_Age_1,                          
MAX(CASE WHEN rno=1 THEN PolicyTravellerID END) AS [Member number 1],                          
                          
MAX(CASE WHEN rno=2 THEN FirstName END) AS [Customer given name 2],                          
MAX(CASE WHEN rno=2 THEN LastName END) AS [Customer surname 2],                          
MAX(CASE WHEN rno=2 THEN DOB END) AS [Customer DOB 2],                          
MAX(CASE WHEN rno=2 THEN EmailAddress END) AS Customer_EmailAddress_2,                          
MAX(CASE WHEN rno=2 THEN Age END) AS Customer_Age_2,                          
MAX(CASE WHEN rno=2 THEN PolicyTravellerID END) AS [Member number 2],                          
                          
MAX(CASE WHEN rno=3 THEN FirstName END) AS [Customer given name 3],                          
MAX(CASE WHEN rno=3 THEN LastName END) AS [Customer surname 3],                          
MAX(CASE WHEN rno=3 THEN DOB END) AS [Customer DOB 3],                          
MAX(CASE WHEN rno=3 THEN EmailAddress END) AS Customer_EmailAddress_3,                          
MAX(CASE WHEN rno=3 THEN Age END) AS Customer_Age_3,                          
MAX(CASE WHEN rno=3 THEN PolicyTravellerID END) AS [Member number 3],                          
                          
MAX(CASE WHEN rno=4 THEN FirstName END) AS [Customer given name 4],                          
MAX(CASE WHEN rno=4 THEN LastName END) AS [Customer surname 4],                          
MAX(CASE WHEN rno=4 THEN DOB END) AS [Customer DOB 4],                          
MAX(CASE WHEN rno=4 THEN EmailAddress END) AS Customer_EmailAddress_4,                          
MAX(CASE WHEN rno=4 THEN Age END) AS Customer_Age_4,                          
MAX(CASE WHEN rno=4 THEN PolicyTravellerID END) AS [Member number 4],                          
                          
MAX(CASE WHEN rno=5 THEN FirstName END) AS [Customer given name 5],                          
MAX(CASE WHEN rno=5 THEN LastName END) AS [Customer surname 5],                          
MAX(CASE WHEN rno=5 THEN DOB END) AS [Customer DOB 5],                          
MAX(CASE WHEN rno=5 THEN EmailAddress END) AS Customer_EmailAddress_5,                          
MAX(CASE WHEN rno=5 THEN Age END) AS Customer_Age_5,                          
MAX(CASE WHEN rno=5 THEN PolicyTravellerID END) AS [Member number 5]                          
                          
 from (                          
select PolicyKey,Title,FirstName,LastName,DOB,isAdult,EmailAddress,isPrimary,PolicyTravellerID,age,                          
                          
ROW_NUMBER()over(partition by PolicyKey order by PolicyTravellerID) as rno from [db-au-cmdwh].[dbo].penPolicyTraveller as d1  with (nolock) where d1.PolicyKey=c.PolicyKey)                          
as a group by PolicyKey                          
) as d                           
outer apply                          
(                          
select                            
policykey,pidvalue,                          
case when pidvalue like '%^%' then substring(pidvalue,1,charindex('^',pidvalue)-1) end                                             
as  [Risk postcode],                          
replace(case when pidvalue like '%^%' then substring(pidvalue,charindex('^',pidvalue)+1,len(pidvalue)) end,',','')                                             
  as  [Risk suburb]                          
from    [db-au-cmdwh].[dbo].penpolicytraveller as e1  with (nolock) where e1.PolicyKey=c.PolicyKey                          
  and isprimary=1                          
) as e                          
outer apply            
(                          
select PolicyTransactionKey,TransactionStatus,TransactionType,TransactionDateTime,UserKey from [db-au-cmdwh].[dbo].penPolicyTransaction as f1  with (nolock) where f1.PolicyKey=c.PolicyKey and convert(date,IssueDate,103)=convert(date,   @Startdate,103)   
   
    
      
       
           
            
             
                 
                  
                    
               
) as f                          
outer apply                          
(                          
select CardType as [Payment type] from [db-au-cmdwh].[dbo].penPayment as g1  with (nolock) where g1.PolicyTransactionKey=f.PolicyTransactionKey                          
) as g                          
                          
outer apply (                                       
    select distinct h1.commission,h1.newpolicycount,h1.BasePremium 'BasePremium',PostingDate,PolicyTransactionKey,GrossPremium,h1.PolicyKey from                                                              
 [db-au-cmdwh].[dbo].penPolicyTransSummary                                                                                
                                                                                  
 h1  with (nolock)  where h1.PolicyKey= c.PolicyKey and                                     
 h1.PolicyTransactionKey=f.PolicyTransactionKey                            
 ) h                          
 outer apply                           
 ( select sum(ppp.GrossPremium) 'Motorcycle_Premium',pao.AddonName,                                                                              
   CASE WHEN pao.AddOnCode in ('MTCLTWO','MTCL') then pao.AddonName else 'No' End as Motorbike_Flag                                                                                              
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyAddOn pao with (nolock) on ppp.ComponentID = pao.PolicyAddOnID                                                                                             
            
              
                
                  
                    
                     
                        
                               
 join [db-au-cmdwh].[dbo].penPolicyTransaction ppt with (nolock) on pao.PolicyTransactionKey = ppt.PolicyTransactionKey                                                                                                         
 where ppt.PolicyTransactionKey = f.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and pao.AddOnCode in( 'MTCLTWO' ,'MTCL')                                                                                     
                                                                                         
 group by pao.AddonName,pao.AddOnCode)I                          
                           
                           
                           
 outer apply (                           
                           
 select sum(ppp.GrossPremium) 'Cruise_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='CRS' then 'Yes' else 'No' End as Cruise_Flag    from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta        
  
    
     
        
           
            
              
               
 with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                                                                   
                                                        
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID               
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                                             
 where pptt.PolicyTransactionKey = f.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in( 'CRS','CRS','CRS2' )                                                        
  
    
      
        
          
           
               
                
                  
                    
                      
                        
                            
 group by pao.DisplayName,pao.AddOnCode) J                          
                           
 outer apply (                                                             
 select sum(ppp.GrossPremium) 'SnowSports_Premium',pao.AddonName,CASE WHEN pao.AddOnCode in ('SNSPRTS','SNSPRTS2','SNSPRTS3','WNTS') then pao.AddonName else 'No' End as SnowSports_Flag                                                                       
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                                       
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                         
                    
                      
                        
                                             
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID                                                                                                        
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                                                          
  
   
       
        
          
           
 where pptt.PolicyTransactionKey = F.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and   pao.AddOnCode  in ('SNSPRTS','SNSPRTS2','SNSPRTS3','WNTS')         
                                                   
 group by pao.AddonName,pao.AddOnCode) K                          
                           
                           
 outer apply                           
 (                           
 select sum(ppp.GrossPremium) 'Luggage_Premium',pao.AddonName,CASE WHEN pao.AddOnCode='LUGG' then 'Yes' else 'No' End as Luggage_Flag                                                                                    
 from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                                
  
    
                                    
 join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID                                   
 join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                     
 where pptt.PolicyTransactionKey = f.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and pao.AddOnCode = 'LUGG'                                                                                                                             
  
    
     
         
          
           
 group by pao.AddonName,pao.AddOnCode) L                                 
                          
                          
 outer apply                          
 (                          
                          
select QuoteCountryKey,                          
max(case when rno=1 then GrossPremium end) as [Quote 1 premium],                          
max(case when rno=1 then ProductName end) as [Quote 1 product name],                          
max(case when rno=1 then Excess end) as [Quote 1 excess],                          
                          
max(case when rno=2 then GrossPremium end) as [Quote 2 premium],                          
max(case when rno=2 then ProductName end) as [Quote 2 product name],                          
max(case when rno=2 then Excess end) as [Quote 2 excess],                          
                          
                          
max(case when rno=3 then GrossPremium end) as [Quote 3 premium],                          
max(case when rno=3 then ProductName end) as [Quote 3 product name],                          
max(case when rno=3 then Excess end) as [Quote 3 excess],                          
                          
                          
max(case when rno=4 then GrossPremium end) as [Quote 4 premium],                          
max(case when rno=4 then ProductName end) as [Quote 4 product name],                          
max(case when rno=4 then Excess end) as [Quote 4 excess],                          
                          
                          
                          
max(case when rno=5 then GrossPremium end) as [Quote 5 premium],                          
max(case when rno=5 then ProductName end) as [Quote 5 product name],                          
max(case when rno=5 then Excess end) as [Quote 5 excess]                          
                          
from (                          
select a.QuoteCountryKey                          
, b.GrossPremium                          
,b.PlanDisplayName as  ProductName                         
,b.Excess                          
,ROW_NUMBER()over(partition by a.QuoteCountryKey order by b.planid) as rno                          
                          
from [db-au-cmdwh].[dbo].penQuote as a with (nolock) inner join  [db-au-cmdwh].[dbo].penQuoteSelectedPlan                                  
as b with (nolock) on a.QuoteCountryKey=b.QuoteCountryKey  and b.GrossPremium!='0.00' and AgencyCode in (    
    
select distinct AlphaCode from penOutlet nolock where GroupName='Bendigo Bank'    
and OutletStatus='Current') --and b.QuoteCountryKey='AU-TIP7-7504876'                         
UNION ALL                          
                          
select                           
convert(varchar(100),SESSIONID)                          
,TotalGrossPremium                          
,ProductName collate SQL_Latin1_General_CP1_CI_AS                          
,Excess                          
,1 as rno                          
                          
from                           
[db-au-stage]..cdg_factquote_AU_AG AS A  with (nolock) INNER JOIN [db-au-stage]..cdg_DimProduct_AU             
as b  with (nolock) on a.productid=b.dimproductid                          
                          
                          
 ) as M1 where (M1.QuoteCountryKey=a.QuoteCountryKey)                          
 group by QuoteCountryKey                          
                          
 ) M                          
                          
 outer apply                          
 (                          
  select  AlphaCode,OutletName,OutletAlphaKey from [db-au-cmdwh].[dbo].penoutlet as N1  with (nolock) WHERE c.OutletAlphaKey=n1.OutletAlphaKey                          
  and outletstatus='Current'                           
 ) AS N                          
                          
  outer apply                          
 (                          
  select  PromoCode,Discount from [db-au-cmdwh].[dbo].penPolicyTransactionPromo as o1  with (nolock) where   c.PolicyNumber=o1.PolicyNumber                          
                          
 ) AS o                          
  outer apply                          
  (                          
  select CALLREASON from [db-au-cmdwh].[dbo].penPolicyAdminCallComment as p1  with (nolock) where p1.PolicyKey=c.policykey                          
  and convert(date,calldate,103)=convert(date,@startdate,103)                          
  )                          
AS P                          
outer apply                          
(                          
 select isnull(GrossPremium-TaxAmountGST-TaxAmountSD,'') as Total_Gross_Premium ,GrossPremium,TaxAmountGST,TaxAmountSD,PolicyTransactionKey from                             
 [db-au-cmdwh].[dbo].penPolicyTransSummary                                            
 as q1  with (nolock) where  q1.PolicyTransactionKey=f.PolicyTransactionKey                            
)                          
q                          
outer apply                        
(                        
select UserID as [User id],FirstName+'' + LastName as [User name] from [db-au-cmdwh].[dbo].penUser as r1  with (nolock) where r1.UserKey=f.UserKey        
AND R1.OutletAlphaKey=N.OutletAlphaKey        
 and userstatus='Current'                        
)                        
r                        
outer apply                        
(                        
select case when PromoCodeListID='-1' then '' else code end as Promocode from [db-au-stage].[dbo].cdg_factQuote_AU_AG as d  with (nolock) inner join   [db-au-stage].[dbo].cdg_dimPromoCodeList_AU_AG                      
as b on d.PromoCodeListID=b.DimPromoCodeListID inner join  [db-au-stage].[dbo].cdg_dimPromocode_AU_AG as c on b.PromoCodeID1=c.DimPromoCodeID                      
where a.[Quote reference number]=d.SessionID                      
                      
)                        
s                      
                      
                      
end 
GO
