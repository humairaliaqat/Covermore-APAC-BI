USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[CGU_BENDIGO_NEW]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                                
              
              
CREATE PROCEDURE  [dbo].[CGU_BENDIGO_NEW]  --'2024-09-16'                                            
 @Startdate datetime                                                
                                
AS                                                
                                
/************************************************************************************************************************************                                  
Author:         Abhilash Yelmelwar                                
Date:           20231213                                  
Prerequisite:   Requires ETL021 Penguin Data Model and ETL043_CDG_Quote_A&G successfully run.                                  
Description:    This proc being developed for fullfill the Bendigo Option 3 reporting                                
Change History:  CHG0038312    
NAME :           CHG0039782  Including Unconverted Quotes Data in the report from B2B and B2C     
                                                
*************************************************************************************************************************************/                                  
                                  
    set nocount on                                  
--Debug                                
--exec [CGU_BENDIGO] '2023-10-31'                                  
                                
BEGIN                                                
select   distinct                                              
 [Reference number]                                                
,[Quote reference number]                                                
,[Quote saved date]                                                
,c.PolicyNumber as [Policy number]                                                
,case when r.[User id] is null then h6.[User id] else r.[User id] end as [User id]                                                
,case when r.[User name] is null then h6.[User name] else r.[User name] end as [User name]                                                
,N.AlphaCode as [Branch id]                                                
,N.OutletName as [Branch name]                                                
,case when o.PromoCode is null then  s.Promocode else o.PromoCode end as [Scheme/ Promotion]                                                
,f.TransactionType as [Transaction type]                                                
,CALLREASON as [Call type]                                                
,case when d.[Customer given name 1] is null then h3.[Customer given name 1] else  d.[Customer given name 1] end as [Customer given name 1]                                                
,case when d.[Customer surname 1] is null then h3.[Customer surname 1]       else  d.[Customer surname 1] end as [Customer surname 1]                                                
,case when d.[Customer DOB 1] is null then h3.[Customer DOB 1]               else  d.[Customer DOB 1] end as [Customer DOB 1]                                                
,case when d.[Member number 1] is null then h3.[Member number 1]             else  d.[Member number 1] end as [Member number 1]               
                                               
,case when d.[Customer given name 2] is null then h3.[Customer given name 2] else  d.[Customer given name 2] end as [Customer given name 2]                                                
,case when d.[Customer surname 2] is null then h3.[Customer surname 2]       else  d.[Customer surname 2] end as [Customer surname 2]                                                
,case when d.[Customer DOB 2] is null then h3.[Customer DOB 2]               else  d.[Customer DOB 2] end as [Customer DOB 2]                                                
,case when d.[Member number 2] is null then h3.[Member number 2]             else  d.[Member number 2] end as [Member number 2]                      
           
,case when d.[Customer given name 3] is null then h3.[Customer given name 3] else  d.[Customer given name 3] end as [Customer given name 3]                                                
,case when d.[Customer surname 3] is null then h3.[Customer surname 3]       else  d.[Customer surname 3] end as [Customer surname 3]                                             
,case when d.[Customer DOB 3] is null then h3.[Customer DOB 3]               else  d.[Customer DOB 3] end as [Customer DOB 3]                                                
,case when d.[Member number 3] is null then h3.[Member number 3]             else  d.[Member number 3] end as [Member number 3]                      
                    
,case when d.[Customer given name 4] is null then h3.[Customer given name 4] else  d.[Customer given name 4] end as [Customer given name 4]                                                
,case when d.[Customer surname 4] is null then h3.[Customer surname 4]       else  d.[Customer surname 4] end as [Customer surname 4]                                                
,case when d.[Customer DOB 4] is null then h3.[Customer DOB 4]               else  d.[Customer DOB 4] end as [Customer DOB 4]                                                
,case when d.[Member number 4] is null then h3.[Member number 4]             else  d.[Member number 4] end as [Member number 4]                      
                    
                    
,case when d.[Customer given name 5] is null then h3.[Customer given name 5] else  d.[Customer given name 5] end as [Customer given name 5]                                                
,case when d.[Customer surname 5] is null then h3.[Customer surname 5]       else  d.[Customer surname 5] end as [Customer surname 5]                                                
,case when d.[Customer DOB 5] is null then h3.[Customer DOB 5]               else  d.[Customer DOB 5] end as [Customer DOB 5]                                                
,case when d.[Member number 5] is null then h3.[Member number 5]             else  d.[Member number 5] end as [Member number 5]                                               
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
,CASE WHEN [Destination]  IS  NULL THEN  H1.Country_list  ELSE    [Destination] END AS [Destination]                                           
,[Plan type]                                               
,[Payment type]                                        
,null as [Payment frequency]                                       
,Total_Gross_Premium as [Policy Premium GWP]                                                
,q.GrossPremium as   [Policy Premium Total]                                                
,Cruise_Flag as [Cruise_cover]                                                
,SnowSports_Flag as [Ski_cover]                                                
,L.Luggage_Flag as [Specific_luggage_cover]                                                
,L.Luggage_Premium as [Specific_luggage_cover_sum_insured]                                                
,case when d.[Customer_Age_1] is  null then h3.[Customer_Age_1] else   d.[Customer_Age_1] end as [Insured_age_1]                                                
,case when d.[Customer_Age_2] is  null then h3.[Customer_Age_2] else   d.[Customer_Age_2] end as [Insured_age_2]                                                                                
, case when [Annual_multi_trip_duration] is null then Tripdays else  [Annual_multi_trip_duration] end [Annual_multi_trip_duration]                                              
,case when CancellationCover is null then CANXCoverageAmount else CancellationCover end as [Cancellation_only_sum_insured]                                                
from (                                                   
select * from (                                                
select convert(varchar(50),a.SessionID) as  [Quote reference number]                                                
,convert(varchar(50),SessionToken) as [Reference number]                                                
,Date as [Quote saved date]                                                
,e.PolicyNumber                                                
,PolicyKey                                                
,convert(varchar(50),a.SessionID) as QuoteCountryKey                  
,AffiliateCode                
from [db-au-stage]..cdg_factQuote_AU_AG                                               
as a with(nolock) INNER  join [db-au-stage]..cdg_factSession_AU_AG as b with(nolock) on a.SessionID=b.FactSessionID                                                
INNER JOIN [db-au-stage]..cdg_dimDate_AU_AG as c with(nolock) on a.QuoteTransactionDateID=c.DimDateID                                         
LEFT JOIN  [db-au-stage]..cdg_factPolicy_AU_AG as d with(nolock) on a.sessionid=d.sessionid                                                
LEFT JOIN  [db-au-cmdwh]..penpolicy as e on d.PolicyNumber=e.PolicyNumber collate SQL_Latin1_General_CP1_CI_AS                      
INNER JOIN [db-au-stage]..cdg_factTraveler_AU_AG as f on b.FactSessionID=f.sessionid                 
INNER JOIN [db-au-stage]..cdg_dimAffiliateCode_AU as g on g.DimAffiliateCodeID=b.AffiliateCodeID                
INNER JOIN [db-au-stage]..cdg_DimProduct_AU_AG AS h on a.ProductID=h.DimProductID                
where a.BusinessUnitID=90 and a.CampaignID=346               
and d.SessionID              
in              
(              
SELECT SessionID from                         
[db-au-stage].dbo.cdg_factQuote_AU_AG AS A1 with(nolock) inner join [db-au-stage].dbo.cdg_dimdate_au_AG                                              
as b with(nolock) on A1.QuoteTransactionDateID=b.DimDateID inner join  [db-au-stage].dbo.cdg_dimTime_AU as c with(nolock) on a1.QuoteTransactionTimeID=c.DimTimeID                                                  
WHERE BusinessUnitID=90  and convert(date,dbo.xfn_ConvertUTCtoLocal(b.Date+''+c.StandardTime,'E. Australia Standard TIme'),103)=convert(date,@StartDate,103)              
union              
select SessionID from [db-au-cmdwh]..cdg_factPolicy_AU_AG where PolicyNumber in (              
              
select PolicyNumber from [db-au-cmdwh]..penpolicy  with (nolock) where convert(date,issuedate,103)=convert(date,@Startdate,103)                                                
and OutletAlphaKey  in (select distinct OutletAlphaKey from penOutlet nolock where GroupName='Bendigo Bank'                          
and OutletStatus='Current')                          
union                                                
select b.PolicyNumber from [db-au-cmdwh]..penPolicyTransSummary                                                
as a  with (nolock) inner join [db-au-cmdwh]..penpolicy as b  with (nolock) on a.PolicyKey=b.PolicyKey                                           
where convert(date,a.PostingDate,103)=convert(date,@Startdate,103)                                                
and b.OutletAlphaKey in (select distinct OutletAlphaKey from penOutlet nolock where GroupName='Bendigo Bank'                          
and OutletStatus='Current') )              
              
)              
              
              
                      
union                                                
select QuoteID as [Quote reference number]                                                
,convert(varchar(100),SessionID) as [Reference number]                                                
,CreateDate as [Quote saved date]                                                
,PolicyNo collate SQL_Latin1_General_CP1_CI_AS as   PolicyNo                                                
,PolicyKey                                                
,QuoteCountryKey                
,AgencyCode          
        
from [db-au-cmdwh].[dbo].penQuote where QuoteCountryKey in (         
select A.QuoteCountryKey        
from [db-au-cmdwh].[dbo].penQuote as a with (nolock) inner join  [db-au-cmdwh].[dbo].penQuoteSelectedPlan                                          
as b on a.QuoteCountryKey=b.QuoteCountryKey  and b.GrossPremium!='0.00'                     
                    
where OutletAlphaKey in (select distinct OutletAlphaKey from penOutlet nolock where GroupName='Bendigo Bank'                  
and OutletStatus='Current')                      
and convert(date,CreateDate,103)=convert(date,@Startdate,103)         
        
union        
        
select QuoteCountryKey from  [db-au-cmdwh].[dbo].penQuote as a with (nolock) where PolicyKey in         
(        
select PolicyKey from [db-au-cmdwh]..penpolicy  with (nolock) where convert(date,issuedate,103)=convert(date,@Startdate,103)                                                
and OutletAlphaKey  in (select distinct OutletAlphaKey from penOutlet nolock where GroupName='Bendigo Bank'                          
and OutletStatus='Current')                                                
union                                                
select a.PolicyKey from [db-au-cmdwh]..penPolicyTransSummary                                                
as a  with (nolock) inner join [db-au-cmdwh]..penpolicy as b  with (nolock) on a.PolicyKey=b.PolicyKey                                           
where convert(date,a.PostingDate,103)=convert(date,@Startdate,103)                                                
and b.OutletAlphaKey in (select distinct OutletAlphaKey from penOutlet nolock where GroupName='Bendigo Bank'                          
and OutletStatus='Current')         
)        
        
)        
        
        
        
) as a1                                                
                                                
) as a                        
                      
outer apply                      
(                      
                        
select * from (                      
select PolicyKey,TripStart,TripEnd,datediff(day,TripStart,TripEnd)  as [Annual_multi_trip_duration],replace(MultiDestination,',','')                                               
as [Destination],replace(PlanName,',','') as [Plan type],Excess as [Policy excess],PolicyNumber,OutletAlphaKey,CancellationCover from                                                 
[db-au-cmdwh]..penpolicy  with (nolock) where  policykey in                                                
(                                                
select PolicyKey from [db-au-cmdwh]..penpolicy  with (nolock) where convert(date,issuedate,103)=convert(date,@Startdate,103)                                                
and OutletAlphaKey  in (select distinct OutletAlphaKey from penOutlet nolock where GroupName='Bendigo Bank'                          
and OutletStatus='Current')                                     
union                                                
select a.PolicyKey from [db-au-cmdwh]..penpolicytransaction                                                
as a  with (nolock) inner join [db-au-cmdwh]..penpolicy as b  with (nolock) on a.PolicyKey=b.PolicyKey                                           
where convert(date,a.issuedate,103)=convert(date,@Startdate,103)                                                
and OutletAlphaKey in (select distinct OutletAlphaKey from penOutlet nolock where GroupName='Bendigo Bank'                          
and OutletStatus='Current')                         
)                    
                                        
)as c1 where c1.PolicyKey=a.PolicyKey                      
                      
) as c                        
                      
                                              
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
select PolicyKey,replace(Title,',','') as Title,replace(FirstName,',','') as FirstName,replace(LastName,',','') as LastName,DOB,isAdult,replace(EmailAddress,',','') as EmailAddress,isPrimary,PolicyTravellerID,age,                                          
      
                                                
ROW_NUMBER()over(partition by PolicyKey order by PolicyTravellerID) as rno from [db-au-cmdwh].[dbo].penPolicyTraveller as d1  with (nolock) where d1.PolicyKey=c.PolicyKey)                                                
as a group by PolicyKey                        
                    
) as d                                                 
outer apply                                                
(                                                
select                                                  
policykey,pidvalue,                          
case when pidvalue like '%^%' then substring(pidvalue,1,charindex('^',pidvalue)-1) end                                                                   
as  [Risk postcode],                                                
replace(case when replace(pidvalue,',','') like '%^%' then substring(replace(pidvalue,',',''),charindex('^',replace(pidvalue,',',''))+1,len(replace(pidvalue,',',''))) end,',','')                                                                   
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
select replace(CardType,',','') as [Payment type] from [db-au-cmdwh].[dbo].penPayment as g1  with (nolock) where g1.PolicyTransactionKey=f.PolicyTransactionKey                                                
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
,replace(b.PlanDisplayName,',','') as  ProductName                                               
,b.Excess                                                
,ROW_NUMBER()over(partition by a.QuoteCountryKey order by b.planid) as rno                                                
                                                
from [db-au-cmdwh].[dbo].penQuote as a with (nolock) inner join  [db-au-cmdwh].[dbo].penQuoteSelectedPlan                                                        
as b with (nolock) on a.QuoteCountryKey=b.QuoteCountryKey  and b.GrossPremium!='0.00' and OutletAlphaKey in (                                              
select distinct OutletAlphaKey from penOutlet nolock where GroupName='Bendigo Bank'                          
and OutletStatus='Current') --and b.QuoteCountryKey='AU-TIP7-7504876'                                               
UNION ALL                                                
                                                
select                                                 
convert(varchar(100),SESSIONID)                                                
,TotalGrossPremium                                                
,replace(ProductName,',','') collate SQL_Latin1_General_CP1_CI_AS                                                
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
  select  AlphaCode,replace(OutletName,',','') as OutletName,OutletAlphaKey from [db-au-cmdwh].[dbo].penoutlet as N1  with (nolock) WHERE a.AffiliateCode=n1.AlphaCode                                      
  and outletstatus='Current'                              
 ) AS N                                                
                                                
  outer apply                                       
 (               
  select  PromoCode,Discount from [db-au-cmdwh].[dbo].penPolicyTransactionPromo as o1  with (nolock) where   c.PolicyNumber=o1.PolicyNumber                                                
                                                
 ) AS o                                                
  outer apply                                                
  (                                                
  select replace(CALLREASON,',','') as CALLREASON from [db-au-cmdwh].[dbo].penPolicyAdminCallComment as p1  with (nolock) where p1.PolicyKey=c.policykey                                                
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
select replace(Login,',','') as [User id],replace(FirstName,',','')+'' + replace(LastName,',','') as [User name] from [db-au-cmdwh].[dbo].penUser as r1  with (nolock) where r1.UserKey=f.UserKey                              
AND R1.OutletAlphaKey=N.OutletAlphaKey                              
 and userstatus='Current'                                              
)                                              
r                                              
outer apply                                              
(                                              
select case when PromoCodeListID='-1' then '' else replace(code,'-1','') end as Promocode from [db-au-stage].[dbo].cdg_factQuote_AU_AG as d  with (nolock) inner join   [db-au-stage].[dbo].cdg_dimPromoCodeList_AU_AG                                        
    
as b on d.PromoCodeListID=b.DimPromoCodeListID inner join  [db-au-stage].[dbo].cdg_dimPromocode_AU_AG as c on b.PromoCodeID1=c.DimPromoCodeID                                            
where convert(varchar(50),a.[Quote reference number])=convert(varchar(50),d.SessionID )                                           
                                            
)                                              
s                      
                    
outer apply                    
(                    
 SELECT * FROM (                                                                                 
SELECT convert(varchar(500),SessionID) as SessionID,replace(Country_list,',','') as Country_list  FROM (                                                                                      
SELECT B.DimCovermoreCountryListID,b.SessionID,b.FactQuoteID,                                          
STUFF((select ','+CONVERT(VARCHAR(30),CovermoreCountryName) from (                                                                                                 
SELECT SessionID,FactQuoteID,DimCovermoreCountryListID,COUNTRYID,CovermoreCountryName FROM (                                                                            
SELECT  SessionID,FactQuoteID,DimCovermoreCountryListID,CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,CMCountryID7,                                                                                  
CMCountryID8,CMCountryID9,CMCountryID10 FROM  [db-au-stage].dbo.cdg_factQuote_AU_AG                                                              
AS A with(nolock) INNER JOIN [db-au-stage].dbo.cdg_dimCovermoreCountryList_AU_AG AS B with(nolock) ON A.DestCovermoreCountryListID=B.DimCovermoreCountryListID) AS A                                                     
                                              
UNPIVOT                                                    
(                                                                                                                    
COUNTRYID FOR                             
COUNTRY IN (CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,CMCountryID7,CMCountryID8,CMCountryID9,CMCountryID10)                                             
) AS A INNER JOIN [db-au-stage].dbo.cdg_dimCovermoreCountry_AU_AG AS B ON COUNTRYID=B.DimCovermoreCountryID                                                                                            
WHERE COUNTRYID<>'-1') AS A WHERE A.DimCovermoreCountryListID=B.DimCovermoreCountryListID                                                                            
and  a.SessionID=b.SessionID and a.FactQuoteID=b.FactQuoteID  FOR XML PATH('')),1,1,'') AS Country_list                                                                                                                                              
FROM                                                                                               
(                                                                                                                            
SELECT SessionID,FactQuoteID,DimCovermoreCountryListID,COUNTRYID,CovermoreCountryName FROM (           
SELECT  SessionID,FactQuoteID,DimCovermoreCountryListID,CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,                                                                                                                        
   
   
       
       
          
             
             
                       
CMCountryID7,                                                                                                                                                                  
CMCountryID8,CMCountryID9,CMCountryID10 FROM  [db-au-stage].dbo.cdg_factQuote_AU_AG                                                                                       
AS A INNER JOIN [db-au-stage].dbo.cdg_dimCovermoreCountryList_AU_AG AS B ON A.DestCovermoreCountryListID=B.DimCovermoreCountryListID) AS A                                                              
                                             
UNPIVOT                                  
(                                                                                                                                                             
COUNTRYID FOR                                                       
COUNTRY IN (CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,CMCountryID7,CMCountryID8,CMCountryID9,                                                                   
CMCountryID10)                                                                                                                                              
) AS A INNER JOIN [db-au-stage].dbo.cdg_dimCovermoreCountry_AU_AG AS B ON COUNTRYID=B.DimCovermoreCountryID                                                                          
WHERE COUNTRYID<>'-1'                                                                                                                                                      
) AS B GROUP BY B.DimCovermoreCountryListID,b.SessionID,b.FactQuoteID) AS H1                    
union                    
SELECT a.QuoteCountryKey,replace(MultiDestination,',','') as MultiDestination                                                                                                       
from [db-au-cmdwh].[dbo].penQuote as a with (nolock) inner join  [db-au-cmdwh].[dbo].penQuoteSelectedPlan                                          
as b on a.QuoteCountryKey=b.QuoteCountryKey  and b.GrossPremium!='0.00'                                          
where AgencyCode in (select distinct AlphaCode from [db-au-cmdwh].[dbo].[penOutlet] nolock where GroupName='Bendigo Bank' and OutletStatus='Current' )                    
) AS  A1 WHERE convert(varchar(50),A1.SessionID)=convert(varchar(50),A.QuoteCountryKey )                   
) AS H1                     
                    
outer apply                    
(                    
select convert(varchar(50),SessionID) AS SessionID,                                  
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
select convert(varchar(50),d1.SessionID) as SessionID,'' as Title,replace(FirstName,',','') as FirstName,replace(LastName,',','') as LastName,b.date as DOB,isAdult,'' as  EmailAddress,isPrimary,FactTravelerID as PolicyTravellerID,age,                    
                            
                                                
ROW_NUMBER()over(partition by d1.SessionID order by FactTravelerID) as rno from [db-au-stage].[dbo].cdg_factTraveler_AU_AG as d1  with (nolock)                    
inner join [db-au-stage].[dbo].cdg_dimDate_AU_AG as b with(nolock) on d1.BirthDateDimDateID=b.DimDateID               
inner join [db-au-stage].[dbo].cdg_factQuote_AU_AG as c on d1.SessionID=c.SessionID              
where BusinessUnitID=90              
union              
              
select d1.QuoteCountryKey,'' as Title,replace(FirstName,',','') as FirstName,replace(LastName,',','') as LastName, DOB,'' as isAdult,replace(EmailAddress,',','') as EmailAddress,isPrimary,c.CustomerID as PolicyTravellerID,age,             
                                                
ROW_NUMBER()over(partition by d1.QuoteCountryKey order by c.CustomerID) as rno from [db-au-cmdwh].[dbo].penQuote as d1  with (nolock)                    
inner join [db-au-cmdwh].[dbo].penQuoteCustomer as b with(nolock) on d1.QuoteCountryKey=b.QuoteCountryKey INNER JOIN    [db-au-cmdwh].[dbo].penCustomer                
AS C with(nolock) ON B.CustomerKey=C.CustomerKey   where OutletAlphaKey               
in              
(              
select distinct OutletAlphaKey from [db-au-cmdwh].[dbo].[penOutlet] nolock where GroupName='Bendigo Bank' and OutletStatus='Current'              
)              
)              
as a1              
                    
where convert(varchar(50),a1.SessionID)=convert(varchar(50),a.[QuoteCountryKey])                                             
 group by convert(varchar(50),SessionID)              
 )              
              
                   
 as h3                    
outer apply              
(          SELECT * FROM               
(              
select CONVERT(VARCHAR(50),a.SessionID) AS SessionID,DATEDIFF(DAY,b.Date,c.Date) AS Tripdays from [db-au-stage].[dbo].cdg_factQuote_AU_AG as a with(nolock) inner join [db-au-stage].[dbo].cdg_dimDate_AU_AG as b with(nolock) on a.TripStartDateID=b.DimDateID
            
              
inner join [db-au-stage].[dbo].cdg_dimDate_AU_AG as c with(nolock) on a.TripEndDateID=c.DimDateID              
union              
SELECT A.QuoteCountryKey,DATEDIFF(DAY,DepartureDate,ReturnDate)                                                                                                     
from [db-au-cmdwh].[dbo].penQuote as a with (nolock) inner join  [db-au-cmdwh].[dbo].penQuoteSelectedPlan                                      
as b with(nolock) on a.QuoteCountryKey=b.QuoteCountryKey  and b.GrossPremium!='0.00'               
) AS  A1 WHERE CONVERT(VARCHAR(50),SessionID)=CONVERT(VARCHAR(50),a.QuoteCountryKey)              
)              
as  h4               
outer apply              
(              
              
              
SELECT * from (              
select QuoteCountryKey,case when convert(varchar(30),AddOnItem) like '%-%' then 'Unlimited' else convert(varchar(30),AddOnItem)                                      
 end as CANXCoverageAmount  from (                                                                              
select R2.QuoteCountryKey,                                   
sum(convert(int,case when  AddOnItem='$Unlimited' then '1000000' else REPLACE(REPLACE(AddOnItem,'$',''),',','') end))                                                                           
as AddOnItem from  [db-au-cmdwh].[dbo].penQuoteAddOn r2                                                                
 INNER JOIN  [db-au-cmdwh].[dbo].penQuote AS R3 with (nolock)    ON R2.QuoteCountryKey=r3.QuoteCountryKey                                                                               
 where                                                                               
 AddOnGroup='Cancellation' and r2.QuoteCountryKey = R3.QuoteCountryKey                                                                                  
 and OutletAlphaKey in (select distinct OutletAlphaKey from [db-au-cmdwh].[dbo].[penOutlet] nolock where GroupName='Bendigo Bank' and OutletStatus='Current')               
 and convert(date,R3.CreateDate,103)>='2024-01-01'                                                                             
                                                                              
group by r2.QuoteCountryKey  ) as a              
union              
              
select convert(varchar(50),a.SessionID) as SessionID,CASE                                                                                                                                           
WHEN ProductName='Comprehensive' AND convert(VARCHAR(300),CANXCoverageAmount)='1.00' THEN '10000'                                                                                   
WHEN ProductName='Essential' AND convert(VARCHAR(300),CANXCoverageAmount)='1.00' THEN '5000'                                                                                                                                          
WHEN  convert(VARCHAR(300),CANXCoverageAmount)='-1.00' THEN 'Unlimited' else  convert(varchar(50),CANXCoverageAmount)  end CANXCoverageAmount from cdg_factQuote_AU_AG as a inner join cdg_DimProduct_AU_AG as b on a.ProductID=b.DimProductID              
where BusinessUnitID=90) as a1 where convert(varchar(100),a1.QuoteCountryKey)=a.QuoteCountryKey              
              
              
)                
as h5                 
outer apply              
(              
select b1.QuoteCountryKey,replace(Login,',','') as [User id],replace(FirstName,',','')+'' + replace(LastName,',','') as [User name] from [db-au-cmdwh].[dbo].penUser as a1  with(nolock)  inner join penQuote as b1  with(nolock) on a1.OutletAlphaKey=b1.OutletAlphaKey              
and a1.Login=b1.UserName  and UserStatus='Current'               
where convert(varchar(50),b1.QuoteCountryKey)=convert(varchar(50),a.QuoteCountryKey)         
and b1.OutletAlphaKey in (select distinct OutletAlphaKey from [db-au-cmdwh].[dbo].[penOutlet] nolock where GroupName='Bendigo Bank' and OutletStatus='Current')              
              
)               
 as h6            
             
-- union  -- Missing Data                                          
                   
    
    
--select   distinct                                              
-- [Reference number]                                                
--,[Quote reference number]                                                
--,[Quote saved date]                                                
--,c.PolicyNumber as [Policy number]                                                
--,case when r.[User id] is null then h6.[User id] else r.[User id] end as [User id]                                                
--,case when r.[User name] is null then h6.[User name] else r.[User name] end as [User name]                                                
--,N.AlphaCode as [Branch id]                                                
--,N.OutletName as [Branch name]                               
--,case when o.PromoCode is null then  s.Promocode else o.PromoCode end as [Scheme/ Promotion]                                                
--,f.TransactionType as [Transaction type]                                                
--,CALLREASON as [Call type]                                                
--,case when d.[Customer given name 1] is null then h3.[Customer given name 1] else  d.[Customer given name 1] end as [Customer given name 1]                                                
--,case when d.[Customer surname 1] is null then h3.[Customer surname 1]       else  d.[Customer surname 1] end as [Customer surname 1]                                                
--,case when d.[Customer DOB 1] is null then h3.[Customer DOB 1]               else  d.[Customer DOB 1] end as [Customer DOB 1]                                                
--,case when d.[Member number 1] is null then h3.[Member number 1]             else  d.[Member number 1] end as [Member number 1]               
                                               
--,case when d.[Customer given name 2] is null then h3.[Customer given name 2] else  d.[Customer given name 2] end as [Customer given name 2]                                                
--,case when d.[Customer surname 2] is null then h3.[Customer surname 2]       else  d.[Customer surname 2] end as [Customer surname 2]                                                
--,case when d.[Customer DOB 2] is null then h3.[Customer DOB 2]               else  d.[Customer DOB 2] end as [Customer DOB 2]                                                
--,case when d.[Member number 2] is null then h3.[Member number 2]             else  d.[Member number 2] end as [Member number 2]                      
                    
--,case when d.[Customer given name 3] is null then h3.[Customer given name 3] else  d.[Customer given name 3] end as [Customer given name 3]                                                
--,case when d.[Customer surname 3] is null then h3.[Customer surname 3]       else  d.[Customer surname 3] end as [Customer surname 3]                                             
--,case when d.[Customer DOB 3] is null then h3.[Customer DOB 3]               else  d.[Customer DOB 3] end as [Customer DOB 3]                                                
--,case when d.[Member number 3] is null then h3.[Member number 3]             else  d.[Member number 3] end as [Member number 3]                      
                    
--,case when d.[Customer given name 4] is null then h3.[Customer given name 4] else  d.[Customer given name 4] end as [Customer given name 4]                                                
--,case when d.[Customer surname 4] is null then h3.[Customer surname 4]       else  d.[Customer surname 4] end as [Customer surname 4]                                                
--,case when d.[Customer DOB 4] is null then h3.[Customer DOB 4]               else  d.[Customer DOB 4] end as [Customer DOB 4]                                                
--,case when d.[Member number 4] is null then h3.[Member number 4]             else  d.[Member number 4] end as [Member number 4]                      
                    
                    
--,case when d.[Customer given name 5] is null then h3.[Customer given name 5] else  d.[Customer given name 5] end as [Customer given name 5]                                                
--,case when d.[Customer surname 5] is null then h3.[Customer surname 5]       else  d.[Customer surname 5] end as [Customer surname 5]                                                
--,case when d.[Customer DOB 5] is null then h3.[Customer DOB 5]               else  d.[Customer DOB 5] end as [Customer DOB 5]                                                
--,case when d.[Member number 5] is null then h3.[Member number 5]             else  d.[Member number 5] end as [Member number 5]                                               
--,[Risk suburb]                                   
--,[Risk postcode]                                                
--,'Travel' as [Risk type]                                                
--,[Plan type]   as [Cover type]                                                
--,[Quote 1 product name]                                                
--,[Quote 1 premium]                                                
--,[Quote 1 excess]                                                
--,[Quote 2 product name]                                                
--,[Quote 2 premium]                                                
--,[Quote 2 excess]                                                
--,[Quote 3 product name]                                                
--,[Quote 3 premium]                                                
--,[Quote 3 excess]                                                
--,[Policy excess]                                     
--,null as [Building premium]                                    
--,null as [Contents premium]                                     
--,null as [Liability premium]                                     
--,null as [Specified contents premium]                                     
--,null as [Unspecified valuables premium]                                    
--,null as [Specified valuables premium]                                              
--,Motorbike_Flag as [Motor vehicle cover]                                    
--,null as[Protected no claim bonus cover]                                    
--,null as [Windscreen option selected]                                              
--,Motorcycle_Premium as [Motor premium]                                    
--,null as [Interested party]                                               
--,CASE WHEN H1.Country_list IS  NULL THEN [Destination]  ELSE    H1.Country_list END AS [Destination]                                           
--,[Plan type]                                               
--,[Payment type]                                        
--,null as [Payment frequency]                                       
--,Total_Gross_Premium as [Policy Premium GWP]                                                
--,q.GrossPremium as   [Policy Premium Total]                                                
--,Cruise_Flag as [Cruise_cover]                                                
--,SnowSports_Flag as [Ski_cover]                                                
--,L.Luggage_Flag as [Specific_luggage_cover]                                                
--,L.Luggage_Premium as [Specific_luggage_cover_sum_insured]                                                
--,case when d.[Customer_Age_1] is  null then h3.[Customer_Age_1] else   d.[Customer_Age_1] end as [Insured_age_1]                                                
--,case when d.[Customer_Age_2] is  null then h3.[Customer_Age_2] else   d.[Customer_Age_2] end as [Insured_age_2]                                                                                
--, case when [Annual_multi_trip_duration] is null then Tripdays else  [Annual_multi_trip_duration] end [Annual_multi_trip_duration]                                              
--,case when CancellationCover is null then CANXCoverageAmount else CancellationCover end as [Cancellation_only_sum_insured]                                                
--from (                                                   
--select * from (                                                
--select convert(varchar(50),a.SessionID) as  [Quote reference number]                                                
--,convert(varchar(50),SessionToken) as [Reference number]                                                
--,Date as [Quote saved date]                                                
--,e.PolicyNumber                                                
--,PolicyKey                                                
--,convert(varchar(50),a.SessionID) as QuoteCountryKey                  
--,AffiliateCode      
--from [db-au-stage]..cdg_factQuote_AU_AG                                               
--as a with(nolock) INNER  join [db-au-stage]..cdg_factSession_AU_AG as b with(nolock) on a.SessionID=b.FactSessionID                                                
--INNER JOIN [db-au-stage]..cdg_dimDate_AU_AG as c with(nolock) on a.QuoteTransactionDateID=c.DimDateID                                         
--LEFT JOIN  [db-au-stage]..cdg_factPolicy_AU_AG as d with(nolock) on a.sessionid=d.sessionid                                                
--LEFT JOIN  [db-au-cmdwh]..penpolicy as e on d.PolicyNumber=e.PolicyNumber collate SQL_Latin1_General_CP1_CI_AS                      
--INNER JOIN [db-au-stage]..cdg_factTraveler_AU_AG as f on b.FactSessionID=f.sessionid                 
--INNER JOIN [db-au-stage]..cdg_dimAffiliateCode_AU as g on g.DimAffiliateCodeID=b.AffiliateCodeID                
--INNER JOIN [db-au-stage]..cdg_DimProduct_AU_AG AS h on a.ProductID=h.DimProductID                
--where a.BusinessUnitID=90 and a.CampaignID=346               
--and d.SessionID              
--in              
--(              
--SELECT SessionID from                         
--[db-au-stage].dbo.cdg_factQuote_AU_AG AS A1 with(nolock) inner join [db-au-stage].dbo.cdg_dimdate_au_AG                                              
--as b with(nolock) on A1.QuoteTransactionDateID=b.DimDateID inner join  [db-au-stage].dbo.cdg_dimTime_AU as c with(nolock) on a1.QuoteTransactionTimeID=c.DimTimeID             WHERE BusinessUnitID=90  and convert(date,dbo.xfn_ConvertUTCtoLocal(b.Date+''+c.StandardTime,'E. Australia Standard TIme'),103)='2024-09-01'       
--except    
--select [Quote reference number]  from Bendigo_Tbl     
    
--union              
--select SessionID from [db-au-cmdwh]..cdg_factPolicy_AU_AG where PolicyNumber in (                                                             
--select b.PolicyNumber from [db-au-cmdwh]..penPolicyTransSummary                                                
--as a  with (nolock) inner join [db-au-cmdwh]..penpolicy as b  with (nolock) on a.PolicyKey=b.PolicyKey                                           
--where  b.OutletAlphaKey in (select distinct OutletAlphaKey from penOutlet nolock where GroupName='Bendigo Bank'                          
--and OutletStatus='Current')    
--and  policytransactionkey in (    
--select policytransactionkey from [db-au-cmdwh]..penPolicyTransSummary                                                
--as a  with (nolock) inner join [db-au-cmdwh]..penpolicy as b  with (nolock) on a.PolicyKey=b.PolicyKey                                           
--where b.OutletAlphaKey in (select distinct OutletAlphaKey from penOutlet nolock where GroupName='Bendigo Bank'                          
--and OutletStatus='Current')    
--except    
--select PolicyTransactionkey from Bendigo_Tbl)    
--)    
--)    
              
              
                      
--union                                                
--select QuoteID as [Quote reference number]                                                
--,convert(varchar(100),SessionID) as [Reference number]                                                
--,CreateDate as [Quote saved date]                                                
--,PolicyNo collate SQL_Latin1_General_CP1_CI_AS as   PolicyNo                                                
--,PolicyKey                                                
--,QuoteCountryKey                
--,AgencyCode          
        
--from [db-au-cmdwh].[dbo].penQuote where QuoteCountryKey in (         
--select A.QuoteCountryKey        
--from [db-au-cmdwh].[dbo].penQuote as a with (nolock) inner join  [db-au-cmdwh].[dbo].penQuoteSelectedPlan                                          
--as b on a.QuoteCountryKey=b.QuoteCountryKey  and b.GrossPremium!='0.00'                     
                    
--where OutletAlphaKey in (select distinct OutletAlphaKey from penOutlet nolock where GroupName='Bendigo Bank'                  
--and OutletStatus='Current')                      
--and a.QuoteID in     
--(    
--select a.QuoteID from [db-au-cmdwh].[dbo].penQuote as a with (nolock) inner join  [db-au-cmdwh].[dbo].penQuoteSelectedPlan                                          
--as b on a.QuoteCountryKey=b.QuoteCountryKey  and b.GrossPremium!='0.00'                                  
--where OutletAlphaKey in (select distinct OutletAlphaKey from penOutlet nolock where GroupName='Bendigo Bank'                  
--and OutletStatus='Current')                      
--and convert(date,CreateDate,103)>='2024-09-27'    
--except    
--select [Quote reference number]  from Bendigo_Tbl     
--)    
    
    
    
        
--union        
        
--select QuoteCountryKey from  [db-au-cmdwh].[dbo].penQuote as a with (nolock) where PolicyKey in         
--(        
    
    
--select a.PolicyKey from [db-au-cmdwh]..penPolicyTransSummary                                                
--as a  with (nolock) inner join [db-au-cmdwh]..penpolicy as b  with (nolock) on a.PolicyKey=b.PolicyKey                                           
--where  b.OutletAlphaKey in (select distinct OutletAlphaKey from penOutlet nolock where GroupName='Bendigo Bank'                          
--and OutletStatus='Current')  AND PolicyTransactionKey IN (     
--select a.PolicyTransactionKey from [db-au-cmdwh]..penPolicyTransSummary                                                
--as a  with (nolock) inner join [db-au-cmdwh]..penpolicy as b  with (nolock) on a.PolicyKey=b.PolicyKey                                           
--where convert(date,a.PostingDate,103)='2024-09-01'                                                
--and b.OutletAlphaKey in (select distinct OutletAlphaKey from penOutlet nolock where GroupName='Bendigo Bank'                          
--and OutletStatus='Current')      
--EXCEPT    
--select PolicyTransactionKey from  Bendigo_Tbl)    
    
--)        
        
--)        
        
        
        
--) as a1                                                
                                                
--) as a                        
                      
--outer apply                      
--(                      
                       
--select * from (                      
--select A.PolicyKey,TripStart,TripEnd,datediff(day,TripStart,TripEnd)  as [Annual_multi_trip_duration],MultiDestination                                                
--as [Destination],PlanName as [Plan type],Excess as [Policy excess],a.PolicyNumber,OutletAlphaKey,CancellationCover,b.IssueDate from                                                 
--[db-au-cmdwh]..penpolicy as a  with (nolock)  inner join    
--[db-au-cmdwh]..penPolicyTransaction as b on  a.PolicyKey=b.PolicyKey    
    
--where  policytransactionkey in (    
    
    
--select policytransactionkey from [db-au-cmdwh]..penpolicytransaction                                                
--as a  with (nolock) inner join [db-au-cmdwh]..penpolicy as b  with (nolock) on a.PolicyKey=b.PolicyKey                                           
--where convert(date,a.issuedate,103)='2024-09-01'                                                
--and OutletAlphaKey in (select distinct OutletAlphaKey from penOutlet nolock where GroupName='Bendigo Bank'                          
--and OutletStatus='Current')    
--EXCEPT    
--select policytransactionkey from Bendigo_Tbl    
--)                   
                                        
--)as c1 where c1.PolicyKey=a.PolicyKey                      
                      
--) as c                        
                      
                                              
----outer apply                            
----(                                                
----select PolicyNumber,SessionID from [db-au-stage]..cdg_factPolicy_AU as b1 where b1.SessionID=a.[Quote reference number]                                                
----) as b                                                 
                                                
--outer apply    (                        
--select PolicyKey,                                  
--MAX(CASE WHEN rno=1 THEN FirstName END) AS [Customer given name 1],                                                
--MAX(CASE WHEN rno=1 THEN LastName END) AS [Customer surname 1],                                                
--MAX(CASE WHEN rno=1 THEN DOB END) AS [Customer DOB 1],                                                
--MAX(CASE WHEN rno=1 THEN EmailAddress END) AS Customer_EmailAddress_1,                                                
--MAX(CASE WHEN rno=1 THEN Age END) AS Customer_Age_1,                                                
--MAX(CASE WHEN rno=1 THEN PolicyTravellerID END) AS [Member number 1],                                                
                                                
--MAX(CASE WHEN rno=2 THEN FirstName END) AS [Customer given name 2],                                                
--MAX(CASE WHEN rno=2 THEN LastName END) AS [Customer surname 2],                                                
--MAX(CASE WHEN rno=2 THEN DOB END) AS [Customer DOB 2],                                                
--MAX(CASE WHEN rno=2 THEN EmailAddress END) AS Customer_EmailAddress_2,                       
--MAX(CASE WHEN rno=2 THEN Age END) AS Customer_Age_2,                                                
--MAX(CASE WHEN rno=2 THEN PolicyTravellerID END) AS [Member number 2],                                                
                                                
--MAX(CASE WHEN rno=3 THEN FirstName END) AS [Customer given name 3],                                                
--MAX(CASE WHEN rno=3 THEN LastName END) AS [Customer surname 3],                                             
--MAX(CASE WHEN rno=3 THEN DOB END) AS [Customer DOB 3],                                                
--MAX(CASE WHEN rno=3 THEN EmailAddress END) AS Customer_EmailAddress_3,                                                
--MAX(CASE WHEN rno=3 THEN Age END) AS Customer_Age_3,                                                
--MAX(CASE WHEN rno=3 THEN PolicyTravellerID END) AS [Member number 3],                                  
                                                
--MAX(CASE WHEN rno=4 THEN FirstName END) AS [Customer given name 4],                                                
--MAX(CASE WHEN rno=4 THEN LastName END) AS [Customer surname 4],                                                
--MAX(CASE WHEN rno=4 THEN DOB END) AS [Customer DOB 4],                                                
--MAX(CASE WHEN rno=4 THEN EmailAddress END) AS Customer_EmailAddress_4,                                                
--MAX(CASE WHEN rno=4 THEN Age END) AS Customer_Age_4,                                                
--MAX(CASE WHEN rno=4 THEN PolicyTravellerID END) AS [Member number 4],                                                
                                                
--MAX(CASE WHEN rno=5 THEN FirstName END) AS [Customer given name 5],                                                
--MAX(CASE WHEN rno=5 THEN LastName END) AS [Customer surname 5],                                                
--MAX(CASE WHEN rno=5 THEN DOB END) AS [Customer DOB 5],                                                
--MAX(CASE WHEN rno=5 THEN EmailAddress END) AS Customer_EmailAddress_5,                                                
--MAX(CASE WHEN rno=5 THEN Age END) AS Customer_Age_5,                                               
--MAX(CASE WHEN rno=5 THEN PolicyTravellerID END) AS [Member number 5]                                                
                                                
-- from (                                                
--select PolicyKey,Title,FirstName,LastName,DOB,isAdult,EmailAddress,isPrimary,PolicyTravellerID,age,                                                
                                                
--ROW_NUMBER()over(partition by PolicyKey order by PolicyTravellerID) as rno from [db-au-cmdwh].[dbo].penPolicyTraveller as d1  with (nolock) where d1.PolicyKey=c.PolicyKey)                                                
--as a group by PolicyKey                        
                    
--) as d                                                 
--outer apply                                                
--(                                                
--select                                                  
--policykey,pidvalue,                          
--case when pidvalue like '%^%' then substring(pidvalue,1,charindex('^',pidvalue)-1) end                                                                   
--as  [Risk postcode],                                                
--replace(case when pidvalue like '%^%' then substring(pidvalue,charindex('^',pidvalue)+1,len(pidvalue)) end,',','')                                                                   
--  as  [Risk suburb]                                                
--from    [db-au-cmdwh].[dbo].penpolicytraveller as e1  with (nolock) where e1.PolicyKey=c.PolicyKey                                                
--  and isprimary=1                                                
--) as e                                                
--outer apply                                         
--(                                                
--select PolicyTransactionKey,TransactionStatus,TransactionType,TransactionDateTime,UserKey from [db-au-cmdwh].[dbo].penPolicyTransaction as f1  with (nolock) where f1.PolicyKey=c.PolicyKey and convert(date,IssueDate,103)=convert(date,c.IssueDate,103)   
   
    
                                     
--) as f                                                
--outer apply                                  
--(                                                
--select CardType as [Payment type] from [db-au-cmdwh].[dbo].penPayment as g1  with (nolock) where g1.PolicyTransactionKey=f.PolicyTransactionKey                                                
--) as g                                                
                                                
--outer apply (                                                             
--    select distinct h1.commission,h1.newpolicycount,h1.BasePremium 'BasePremium',PostingDate,PolicyTransactionKey,GrossPremium,h1.PolicyKey from                                  
-- [db-au-cmdwh].[dbo].penPolicyTransSummary                                                                                                      
                                                                                                        
-- h1  with (nolock)  where h1.PolicyKey= c.PolicyKey and                
-- h1.PolicyTransactionKey=f.PolicyTransactionKey                                                  
-- ) h                                                
-- outer apply                                                 
-- ( select sum(ppp.GrossPremium) 'Motorcycle_Premium',pao.AddonName,                                                                                                    
--   CASE WHEN pao.AddOnCode in ('MTCLTWO','MTCL') then pao.AddonName else 'No' End as Motorbike_Flag                                                                                                                    
-- from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyAddOn pao with (nolock) on ppp.ComponentID = pao.PolicyAddOnID                         
                                          
-- join [db-au-cmdwh].[dbo].penPolicyTransaction ppt with (nolock) on pao.PolicyTransactionKey = ppt.PolicyTransactionKey                                                                                                                               
-- where ppt.PolicyTransactionKey = f.PolicyTransactionKey and ppp.GroupID = 4 and ppp.isPOSDiscount = 1 and pao.AddOnCode in( 'MTCLTWO' ,'MTCL')                                                                                                           
                              
-- group by pao.AddonName,pao.AddOnCode)I                                                
                                                 
                                                 
                                                 
-- outer apply (                                                 
                                                 
-- select sum(ppp.GrossPremium) 'Cruise_Premium',pao.DisplayName,CASE WHEN pao.AddOnCode='CRS' then 'Yes' else 'No' End as Cruise_Flag    from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta      
 
             
--  with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                              
                                                                              
-- join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID                                     
-- join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                                               
-- where pptt.PolicyTransactionKey = f.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and ppp.CountryKey = 'AU' AND ppp.CompanyKey = 'TIP' and pao.AddOnCode in( 'CRS','CRS','CRS2' )                                                      
  
      
      
        
          
-- group by pao.DisplayName,pao.AddOnCode) J                                                
                                                 
-- outer apply (                                                                 
-- select sum(ppp.GrossPremium) 'SnowSports_Premium',pao.AddonName,CASE WHEN pao.AddOnCode in ('SNSPRTS','SNSPRTS2','SNSPRTS3','WNTS') then pao.AddonName else 'No' End as SnowSports_Flag                                                                     
  
      
                                                           
-- from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                                              
  
       
                                
-- join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID                                                                                                                              
-- join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                                         
-- where pptt.PolicyTransactionKey = F.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and   pao.AddOnCode  in ('SNSPRTS','SNSPRTS2','SNSPRTS3','WNTS')                               
                                                                         
-- group by pao.AddonName,pao.AddOnCode) K                                                
                                                 
                           
-- outer apply                                                 
-- (                                                 
-- select sum(ppp.GrossPremium) 'Luggage_Premium',pao.AddonName,CASE WHEN pao.AddOnCode='LUGG' then 'Yes' else 'No' End as Luggage_Flag                                                                                                          
-- from [db-au-cmdwh].[dbo].penPolicyPrice ppp with (nolock) join [db-au-cmdwh].[dbo].penPolicyTravellerAddOn ppta with (nolock) on ppp.ComponentID = ppta.PolicyTravellerAddOnID                                                   
-- join [db-au-cmdwh].[dbo].penAddOn pao with (nolock) on pao.AddOnID = ppta.AddOnID                                                         
-- join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction pptt with (nolock) on pptt.PolicyTravellerTransactionKey = ppta.PolicyTravellerTransactionKey                                                                                           
-- where pptt.PolicyTransactionKey = f.PolicyTransactionKey and ppp.GroupID = 3 and ppp.isPOSDiscount = 1 and pao.AddOnCode = 'LUGG'                                                                                                                           
  
                               
-- group by pao.AddonName,pao.AddOnCode) L                                                       
                             
                                                
-- outer apply                                                
-- (                                                
                                                
--select QuoteCountryKey,                                                
--max(case when rno=1 then GrossPremium end) as [Quote 1 premium],                                                
--max(case when rno=1 then ProductName end) as [Quote 1 product name],                                                
--max(case when rno=1 then Excess end) as [Quote 1 excess],                                                
                                                
--max(case when rno=2 then GrossPremium end) as [Quote 2 premium],                                              
--max(case when rno=2 then ProductName end) as [Quote 2 product name],                       
--max(case when rno=2 then Excess end) as [Quote 2 excess],                                                
                                                
                                                
--max(case when rno=3 then GrossPremium end) as [Quote 3 premium],                                                
--max(case when rno=3 then ProductName end) as [Quote 3 product name],                                                
--max(case when rno=3 then Excess end) as [Quote 3 excess],                                                
                                                
                                                
--max(case when rno=4 then GrossPremium end) as [Quote 4 premium],                                                
--max(case when rno=4 then ProductName end) as [Quote 4 product name],                                                
--max(case when rno=4 then Excess end) as [Quote 4 excess],                                                
                                                
                                                
                                                
--max(case when rno=5 then GrossPremium end) as [Quote 5 premium],                                                
--max(case when rno=5 then ProductName end) as [Quote 5 product name],                                                
--max(case when rno=5 then Excess end) as [Quote 5 excess]                                                
             
--from (                                                
--select a.QuoteCountryKey                                                
--, b.GrossPremium                                                
--,b.PlanDisplayName as  ProductName                                               
--,b.Excess                                                
--,ROW_NUMBER()over(partition by a.QuoteCountryKey order by b.planid) as rno                                                
                                                
--from [db-au-cmdwh].[dbo].penQuote as a with (nolock) inner join  [db-au-cmdwh].[dbo].penQuoteSelectedPlan                                                        
--as b with (nolock) on a.QuoteCountryKey=b.QuoteCountryKey  and b.GrossPremium!='0.00' and OutletAlphaKey in (                                              
--select distinct OutletAlphaKey from penOutlet nolock where GroupName='Bendigo Bank'                          
--and OutletStatus='Current') --and b.QuoteCountryKey='AU-TIP7-7504876'                                            
--UNION ALL                                                
                                                
--select                                                 
--convert(varchar(100),SESSIONID)                                                
--,TotalGrossPremium                                                
--,ProductName collate SQL_Latin1_General_CP1_CI_AS                                                
--,Excess                                                
--,1 as rno                                                
                                                
--from                                                 
--[db-au-stage]..cdg_factquote_AU_AG AS A  with (nolock) INNER JOIN [db-au-stage]..cdg_DimProduct_AU                                   
--as b  with (nolock) on a.productid=b.dimproductid                                                
                                                
                                                
-- ) as M1 where (M1.QuoteCountryKey=a.QuoteCountryKey)                                                
-- group by QuoteCountryKey                                                
                                                
-- ) M                                                
                                                
-- outer apply                                                
-- (                                                
--  select  AlphaCode,OutletName,OutletAlphaKey from [db-au-cmdwh].[dbo].penoutlet as N1  with (nolock) WHERE a.AffiliateCode=n1.AlphaCode                                      
--  and outletstatus='Current'                              
-- ) AS N                                                
                                                
--  outer apply                                       
-- (               
--  select  PromoCode,Discount from [db-au-cmdwh].[dbo].penPolicyTransactionPromo as o1  with (nolock) where   c.PolicyNumber=o1.PolicyNumber                                                
                                                
-- ) AS o                                                
--  outer apply                                                
--  (                                                
--  select CALLREASON from [db-au-cmdwh].[dbo].penPolicyAdminCallComment as p1  with (nolock) where p1.PolicyKey=c.policykey                                                
--  and convert(date,calldate,103)=convert(date,c.IssueDate,103)                                        
--  )                                                
--AS P                                                
--outer apply                            
--(                                                
-- select isnull(GrossPremium-TaxAmountGST-TaxAmountSD,'') as Total_Gross_Premium ,GrossPremium,TaxAmountGST,TaxAmountSD,PolicyTransactionKey from                                                   
-- [db-au-cmdwh].[dbo].penPolicyTransSummary                                                                         
-- as q1  with (nolock) where  q1.PolicyTransactionKey=f.PolicyTransactionKey                                                  
--)                                                
--q                   
--outer apply                                              
--(                                              
--select Login as [User id],FirstName+'' + LastName as [User name] from [db-au-cmdwh].[dbo].penUser as r1  with (nolock) where r1.UserKey=f.UserKey                              
--AND R1.OutletAlphaKey=N.OutletAlphaKey                              
-- and userstatus='Current'                                              
--)                                              
--r                                              
--outer apply                                              
--(                                              
--select case when PromoCodeListID='-1' then '' else code end as Promocode from [db-au-stage].[dbo].cdg_factQuote_AU_AG as d  with (nolock) inner join   [db-au-stage].[dbo].cdg_dimPromoCodeList_AU_AG                                            
--as b on d.PromoCodeListID=b.DimPromoCodeListID inner join  [db-au-stage].[dbo].cdg_dimPromocode_AU_AG as c on b.PromoCodeID1=c.DimPromoCodeID                                            
--where convert(varchar(50),a.[Quote reference number])=convert(varchar(50),d.SessionID )                                           
                                            
--)                                              
--s                      
                    
--outer apply                    
--(                    
-- SELECT * FROM (                                                                                 
--SELECT convert(varchar(500),SessionID) as SessionID,Country_list FROM (                                                                                      
--SELECT B.DimCovermoreCountryListID,b.SessionID,b.FactQuoteID,                                          
--STUFF((select ','+CONVERT(VARCHAR(30),CovermoreCountryName) from (                                                                                                    
--SELECT SessionID,FactQuoteID,DimCovermoreCountryListID,COUNTRYID,CovermoreCountryName FROM (                                                                            
--SELECT  SessionID,FactQuoteID,DimCovermoreCountryListID,CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,CMCountryID7,                                                                                  
--CMCountryID8,CMCountryID9,CMCountryID10 FROM  [db-au-stage].dbo.cdg_factQuote_AU_AG                                                              
--AS A with(nolock) INNER JOIN [db-au-stage].dbo.cdg_dimCovermoreCountryList_AU_AG AS B with(nolock) ON A.DestCovermoreCountryListID=B.DimCovermoreCountryListID) AS A                                                     
                                              
--UNPIVOT                                                    
--(                                                                                                                    
--COUNTRYID FOR                             
--COUNTRY IN (CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,CMCountryID7,CMCountryID8,CMCountryID9,CMCountryID10)                                             
--) AS A INNER JOIN [db-au-stage].dbo.cdg_dimCovermoreCountry_AU_AG AS B ON COUNTRYID=B.DimCovermoreCountryID                    
--WHERE COUNTRYID<>'-1') AS A WHERE A.DimCovermoreCountryListID=B.DimCovermoreCountryListID                                                                            
--and  a.SessionID=b.SessionID and a.FactQuoteID=b.FactQuoteID  FOR XML PATH('')),1,1,'') AS Country_list                                                                                                                                              
--FROM                                                                                               
--(                                                                                                                            
--SELECT SessionID,FactQuoteID,DimCovermoreCountryListID,COUNTRYID,CovermoreCountryName FROM (           
--SELECT  SessionID,FactQuoteID,DimCovermoreCountryListID,CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,                                                                                                                      
  
      
       
       
          
             
             
                       
--CMCountryID7,                                                                                                                                                                  
--CMCountryID8,CMCountryID9,CMCountryID10 FROM  [db-au-stage].dbo.cdg_factQuote_AU_AG                                                                                       
--AS A INNER JOIN [db-au-stage].dbo.cdg_dimCovermoreCountryList_AU_AG AS B ON A.DestCovermoreCountryListID=B.DimCovermoreCountryListID) AS A                                                              
                                             
--UNPIVOT                                  
--(                                                                                                                                                             
--COUNTRYID FOR                                                       
--COUNTRY IN (CMCountryID1,CMCountryID2,CMCountryID3,CMCountryID4,CMCountryID5,CMCountryID6,CMCountryID7,CMCountryID8,CMCountryID9,                                                                   
--CMCountryID10)                                                                                                                                              
--) AS A INNER JOIN [db-au-stage].dbo.cdg_dimCovermoreCountry_AU_AG AS B ON COUNTRYID=B.DimCovermoreCountryID                                                                          
--WHERE COUNTRYID<>'-1'                                                                                                                                                                  
--) AS B GROUP BY B.DimCovermoreCountryListID,b.SessionID,b.FactQuoteID) AS H1                    
--union                    
--SELECT a.QuoteCountryKey,replace(MultiDestination,',','') as MultiDestination                                                                                                       
--from [db-au-cmdwh].[dbo].penQuote as a with (nolock) inner join  [db-au-cmdwh].[dbo].penQuoteSelectedPlan                                          
--as b on a.QuoteCountryKey=b.QuoteCountryKey  and b.GrossPremium!='0.00'                                          
--where AgencyCode in (select distinct AlphaCode from [db-au-cmdwh].[dbo].[penOutlet] nolock where GroupName='Bendigo Bank' and OutletStatus='Current' )                    
--) AS  A1 WHERE convert(varchar(50),A1.SessionID)=convert(varchar(50),A.QuoteCountryKey )                   
--) AS H1                     
                    
--outer apply                    
--(                    
--select convert(varchar(50),SessionID) AS SessionID,                                  
--MAX(CASE WHEN rno=1 THEN FirstName END) AS [Customer given name 1],                                                
--MAX(CASE WHEN rno=1 THEN LastName END) AS [Customer surname 1],                                                
--MAX(CASE WHEN rno=1 THEN DOB END) AS [Customer DOB 1],                                                
--MAX(CASE WHEN rno=1 THEN EmailAddress END) AS Customer_EmailAddress_1,                                                
--MAX(CASE WHEN rno=1 THEN Age END) AS Customer_Age_1,                                                
--MAX(CASE WHEN rno=1 THEN PolicyTravellerID END) AS [Member number 1],                                                
                                                
--MAX(CASE WHEN rno=2 THEN FirstName END) AS [Customer given name 2],                                                
--MAX(CASE WHEN rno=2 THEN LastName END) AS [Customer surname 2],                                                
--MAX(CASE WHEN rno=2 THEN DOB END) AS [Customer DOB 2],                                                
--MAX(CASE WHEN rno=2 THEN EmailAddress END) AS Customer_EmailAddress_2,                                                
--MAX(CASE WHEN rno=2 THEN Age END) AS Customer_Age_2,                        
--MAX(CASE WHEN rno=2 THEN PolicyTravellerID END) AS [Member number 2],                                                
                                                
--MAX(CASE WHEN rno=3 THEN FirstName END) AS [Customer given name 3],                                                
--MAX(CASE WHEN rno=3 THEN LastName END) AS [Customer surname 3],                                                
--MAX(CASE WHEN rno=3 THEN DOB END) AS [Customer DOB 3],                         
--MAX(CASE WHEN rno=3 THEN EmailAddress END) AS Customer_EmailAddress_3,                                                
--MAX(CASE WHEN rno=3 THEN Age END) AS Customer_Age_3,                                                
--MAX(CASE WHEN rno=3 THEN PolicyTravellerID END) AS [Member number 3],                                                
                                                
--MAX(CASE WHEN rno=4 THEN FirstName END) AS [Customer given name 4],                                                
--MAX(CASE WHEN rno=4 THEN LastName END) AS [Customer surname 4],                                                
--MAX(CASE WHEN rno=4 THEN DOB END) AS [Customer DOB 4],                                                
--MAX(CASE WHEN rno=4 THEN EmailAddress END) AS Customer_EmailAddress_4,                                                
--MAX(CASE WHEN rno=4 THEN Age END) AS Customer_Age_4,                                                
--MAX(CASE WHEN rno=4 THEN PolicyTravellerID END) AS [Member number 4],                                                
                                                
--MAX(CASE WHEN rno=5 THEN FirstName END) AS [Customer given name 5],                                                
--MAX(CASE WHEN rno=5 THEN LastName END) AS [Customer surname 5],                                                
--MAX(CASE WHEN rno=5 THEN DOB END) AS [Customer DOB 5],                                                
--MAX(CASE WHEN rno=5 THEN EmailAddress END) AS Customer_EmailAddress_5,                                                
--MAX(CASE WHEN rno=5 THEN Age END) AS Customer_Age_5,                                                
--MAX(CASE WHEN rno=5 THEN PolicyTravellerID END) AS [Member number 5]                                                
                                                
-- from (                                                
--select convert(varchar(50),d1.SessionID) as SessionID,'' as Title,FirstName,LastName,b.date as DOB,isAdult,'' as EmailAddress,isPrimary,FactTravelerID as PolicyTravellerID,age,                                                
                                                
--ROW_NUMBER()over(partition by d1.SessionID order by FactTravelerID) as rno from [db-au-stage].[dbo].cdg_factTraveler_AU_AG as d1  with (nolock)                    
--inner join [db-au-stage].[dbo].cdg_dimDate_AU_AG as b with(nolock) on d1.BirthDateDimDateID=b.DimDateID               
--inner join [db-au-stage].[dbo].cdg_factQuote_AU_AG as c on d1.SessionID=c.SessionID              
--where BusinessUnitID=90              
--union              
              
--select d1.QuoteCountryKey,'' as Title,FirstName,LastName, DOB,'' as isAdult,EmailAddress,isPrimary,c.CustomerID as PolicyTravellerID,age,             
                                                
--ROW_NUMBER()over(partition by d1.QuoteCountryKey order by c.CustomerID) as rno from [db-au-cmdwh].[dbo].penQuote as d1  with (nolock)                    
--inner join [db-au-cmdwh].[dbo].penQuoteCustomer as b with(nolock) on d1.QuoteCountryKey=b.QuoteCountryKey INNER JOIN    [db-au-cmdwh].[dbo].penCustomer                
--AS C with(nolock) ON B.CustomerKey=C.CustomerKey   where OutletAlphaKey               
--in              
--(              
--select distinct OutletAlphaKey from [db-au-cmdwh].[dbo].[penOutlet] nolock where GroupName='Bendigo Bank' and OutletStatus='Current'              
--)              
--)              
--as a1              
                    
--where convert(varchar(50),a1.SessionID)=convert(varchar(50),a.[QuoteCountryKey])                                             
-- group by convert(varchar(50),SessionID)              
-- )              
              
                   
-- as h3                    
--outer apply              
--(          SELECT * FROM               
--(              
--select CONVERT(VARCHAR(50),a.SessionID) AS SessionID,DATEDIFF(DAY,b.Date,c.Date) AS Tripdays from [db-au-stage].[dbo].cdg_factQuote_AU_AG as a with(nolock) inner join [db-au-stage].[dbo].cdg_dimDate_AU_AG as b with(nolock) on a.TripStartDateID=b.DimDateID            
              
--inner join [db-au-stage].[dbo].cdg_dimDate_AU_AG as c with(nolock) on a.TripEndDateID=c.DimDateID              
--union              
--SELECT A.QuoteCountryKey,DATEDIFF(DAY,DepartureDate,ReturnDate)                                                                                                     
--from [db-au-cmdwh].[dbo].penQuote as a with (nolock) inner join  [db-au-cmdwh].[dbo].penQuoteSelectedPlan                                      
--as b with(nolock) on a.QuoteCountryKey=b.QuoteCountryKey  and b.GrossPremium!='0.00'               
--) AS  A1 WHERE CONVERT(VARCHAR(50),SessionID)=CONVERT(VARCHAR(50),a.QuoteCountryKey)              
--)              
--as  h4               
--outer apply              
--(              
              
              
--SELECT * from (              
--select QuoteCountryKey,case when convert(varchar(30),AddOnItem) like '%-%' then 'Unlimited' else convert(varchar(30),AddOnItem)                                                                              
-- end as CANXCoverageAmount  from (                                                                              
--select R2.QuoteCountryKey,                                   
--sum(convert(int,case when  AddOnItem='$Unlimited' then '1000000' else REPLACE(REPLACE(AddOnItem,'$',''),',','') end))                                                                           
--as AddOnItem from  [db-au-cmdwh].[dbo].penQuoteAddOn r2                                                                
-- INNER JOIN  [db-au-cmdwh].[dbo].penQuote AS R3 with (nolock)    ON R2.QuoteCountryKey=r3.QuoteCountryKey                                                                               
-- where                                                                               
-- AddOnGroup='Cancellation' and r2.QuoteCountryKey = R3.QuoteCountryKey                                                                                  
-- and OutletAlphaKey in (select distinct OutletAlphaKey from [db-au-cmdwh].[dbo].[penOutlet] nolock where GroupName='Bendigo Bank' and OutletStatus='Current')               
-- and convert(date,R3.CreateDate,103)>='2024-01-01'                                                                             
                                                                              
--group by r2.QuoteCountryKey  ) as a              
--union              
              
--select convert(varchar(50),a.SessionID) as SessionID,CASE                                                                                                                                           
--WHEN ProductName='Comprehensive' AND convert(VARCHAR(300),CANXCoverageAmount)='1.00' THEN '10000'                                                                                                                                           
--WHEN ProductName='Essential' AND convert(VARCHAR(300),CANXCoverageAmount)='1.00' THEN '5000'                                                                                                                                          
--WHEN  convert(VARCHAR(300),CANXCoverageAmount)='-1.00' THEN 'Unlimited' else  convert(varchar(50),CANXCoverageAmount)  end CANXCoverageAmount from cdg_factQuote_AU_AG as a inner join cdg_DimProduct_AU_AG as b on a.ProductID=b.DimProductID              
--where BusinessUnitID=90) as a1 where convert(varchar(100),a1.QuoteCountryKey)=a.QuoteCountryKey              
              
              
--)                
--as h5                 
--outer apply              
--(              
--select b1.QuoteCountryKey,Login as [User id],FirstName+'' + LastName as [User name] from [db-au-cmdwh].[dbo].penUser as a1  with(nolock)  inner join penQuote as b1  with(nolock) on a1.OutletAlphaKey=b1.OutletAlphaKey              
--and a1.Login=b1.UserName  and UserStatus='Current'               
--where convert(varchar(50),b1.QuoteCountryKey)=convert(varchar(50),a.QuoteCountryKey)         
--and b1.OutletAlphaKey in (select distinct OutletAlphaKey from [db-au-cmdwh].[dbo].[penOutlet] nolock where GroupName='Bendigo Bank' and OutletStatus='Current')              
              
--)               
-- as h6     
    
               
                
      
                   
                                            
end 
GO
