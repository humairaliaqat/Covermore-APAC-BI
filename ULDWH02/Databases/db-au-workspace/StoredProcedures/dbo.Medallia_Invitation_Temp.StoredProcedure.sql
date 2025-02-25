USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[Medallia_Invitation_Temp]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  

CREATE procedure [dbo].[Medallia_Invitation_Temp] --'2023-08-03'                                             
 @StartDate datetime                                                
 as                                                
 begin                                                
select                                                     
Journey_name,                                                    
Survey_channel,                                                    
Account_Manager_EMPId as Unit_Id,                                                    
Product_Type,                                                    
Sales_Channel,                                                    
Unique_ID as Unique_ID,                                                    
Intermediary_Type,                                                    
Purchase_Outcome,                                                    
Premium_Amount,                                                    
Premium_Currency,                                                    
Insurance_Type,                                                    
--Customer_Type,                                                    
case when Customer_Title='' then  Customer_Salutation else Customer_Title end Customer_Salutation,                                                    
case when FirstName='' then                                                     
dbo.[Camelcase](Customer_FirstName) else FirstName end as Customer_FirstName,                                                    
case when LastName='' then                                                     
dbo.[Camelcase](Customer_LastName) else LastName end as Customer_LastName,                                                    
--b.CustomerEmail as  Customer_Email, -- Chnage in Production      
case when Email='' then                                                   
dbo.[Camelcase](Customer_Email) else Email end as Customer_Email,      
      
case when Phone is null then Customer_Phone else Phone end as Customer_Phone,                                                                        
[Policy_Renewal/Expiration_Date],                                                    
Claim_Outcome,                                                    
Customer_JoinDate,                                                    
--Renewal_Outcome,                                                    
convert(date,@StartDate,103) as Touchpoint_Date,                                                    
QuoteID,                                                    
PolicyNo,                                                    
ClaimNo,                                                    
Country,                                                    
Brand_Outlet,                                                                        
a.GroupName,                                                    
a.Sub_Group,                                                    
Super_Group,                                                     
Survey_Brand  as    Survey_Brand_Logo                                                                  
                                                                    
--end as TouchPoint                                                                        
from (                                                                        
select *,ROW_NUMBER()OVER(partition by Unique_ID order by ClaimNo) as rno from (                                                                        
SELECT  distinct                                                                                                  
JOURNEY as  Journey_name,                                                                                                  
'Email' Survey_channel,                                                                                         
--isnull(Unit_Name,'') as Unit_Id,                                                                                          
'Travel' AS Product_Type,                                  
'Online' as Sales_Channel,                                                    
 [UNIQUEKEY] as Unique_ID ,                                                                                                  
isnull(Channel,'') as Intermediary_Type,                     
case when  a.PolicyKey is not null then 'Purchase' else 'Non-Purchase' END as Purchase_Outcome,                         
isnull(GrossPremium,'') AS [Premium_Amount],                                                 
isnull(CurrencyCode,'') AS [Premium_Currency],                                                                       
'Travel' AS [Insurance_Type],                                                                         
'Individual' AS [Customer_Type],                                                                          
isnull(c.Title,'') as [Customer_Salutation],                                    
isnull(D.Title,'') as [Customer_Title],                                                    
isnull(C.FirstName,'') as [Customer_FirstName],                                                    
isnull(D.FirstName,'') as [FirstName],                                                   
isnull(C.LastName,'') as [Customer_LastName],                                                     
isnull(D.LastName,'') as [LastName],                                                    
isnull(c.EmailAddress,'') as [Customer_Email],                                                    
isnull(D.EmailAddress,'') as [Email],                                                    
isnull(MOBILEPHONE,'') as [Customer_Phone],                                                    
isnull(D.Phone,'') as [Phone],                                                    
isnull (replace(convert(varchar(50),PolicyEnd,102),'.','-'),'') as [Policy_Renewal/Expiration_Date],                                                                            
isnull(AssessmentOutcomeDescription,'') as [Claim_Outcome],                                                                        
isnull(replace(convert(varchar(50),X.CreateDate,102),'.','-'),'') as [Customer_JoinDate],                                                             
case when d.PreviousPolicyNumber is not null then 'Renewal' else ' ' end  as [Renewal_Outcome],                                                                                                  
--isnull(case                                                                                       
--when FinalisedDate is not null then ''                                                                                      
--when g.RecoveryPaymentMovement='0.00' then 'Surrender Maturity'                                                                                          
--when g.RecoveryPaymentMovement!='0.00' then 'Surrender Partial'                                                                                                 
--END,'') as [Payout_Type],                                                                                           
getdate() as  [Touchpoint_Date],                                                                                                  
isnull(convert(varchar(60),QuoteID),'') as QuoteID,                                              
isnull(d.PolicyNumber,'')  as PolicyNo,                                               
isnull(convert(varchar(60),ClaimNo),'') as ClaimNo ,                                                                                     
A.CountryKey as Country,                                                                                    
J.outletName as Brand_Outlet,-- Penoutlet ?                                                                                     
J.GroupName AS GroupName,                                                                              
j.SubGroupName as Sub_Group,                                                                                    
isnull(J.SuperGroupName,'') as Super_Group                                                                      --Survey_Brand_Logo as Survey_Brand_Logo                                                                        
                                                               
 from (                                                                                          
                              
select                              
case when a.countrykey is null then b.countrykey else a.countrykey end as countrykey,                              
case when convert(varchar(30),a.Quoteid) is null then convert(varchar(30),b.Quoteid) else                 
convert(varchar(30),a.Quoteid) end as Quoteid,                              
case when a.PolicyKey is null then b.PolicyKey else a.PolicyKey end as PolicyKey,                              
case when a.OutletAlphaKey is null then b.OutletAlphaKey else  a.OutletAlphaKey end as OutletAlphaKey,                              
case when a.OutletSKey is null then b.OutletSKey else a.OutletSKey  end as OutletSKey,                              
QuoteCountryKey,                              
case when a.CompanyKey is null then b.CompanyKey else a.CompanyKey end as CompanyKey                              
                              
from (                              
SELECT QuoteID,SessionID,CountryKey ,CompanyKey,PolicyKey,CreateDate AS QuoteDate,QuoteCountryKey,OutletSKey,AgencyCode,PolicyNo,OutletAlphaKey                                                                                         
FROM [db-au-cmdwh]..penQuote with(nolock)                              
                              
where QuoteCountryKey in                            
(                                                                                                
SELECT QuoteCountryKey FROM [db-au-cmdwh]..penQuote as a  with(nolock) inner join                                  
[db-au-cmdwh]..penOutlet                                               
as b with(nolock) on a.outletskey=b.outletskey                                              
 WHERE convert(date,CreateDate,103)=Convert(date,@StartDate-7,103) AND a.CountryKey in ('AU','NZ') and                                                            
GroupName in (Select GroupName from SurveyBrand_Info)                                              
)         
and QuoteCountryKey not in         
(        

select A.QuoteCountryKey FROM [db-au-cmdwh]..penQuote as a  with(nolock) inner join                          [db-au-cmdwh]..penOutlet                                               
as b with(nolock) on a.outletskey=b.outletskey inner join  [db-au-cmdwh]..penQuoteCustomer        
as c  with(nolock) on a.QuoteCountryKey=c.QuoteCountryKey inner join  [db-au-cmdwh]..penCustomer        
as d  with(nolock) on c.CustomerKey=d.CustomerKey           
 WHERE a.CountryKey in ('AU','NZ') and  marketingconsent=1 and                                             GroupName in (Select GroupName from SurveyBrand_Info) )                    
) as a                               
full outer join                              
                              
(                              
select a.PolicyKey,case when QuoteID is  null then d.SessionID else QuoteID end QuoteID,                              
a.PolicyNumber,issuedate,a.AlphaCode,a.OutletAlphaKey,a.OutletSKey,                              
a.CountryKey,a.CompanyKey  from [db-au-cmdwh]..penpolicy as a  with(nolock) inner join                                  
[db-au-cmdwh]..penOutlet                                               
as b with(nolock) on a.outletskey=b.outletskey left join [db-au-cmdwh]..penQuote                              
as c on a.PolicyKey=c.PolicyKey                              
left join [db-au-stage]..cdg_factPolicy_AU   as d   on a.PolicyNumber=d.PolicyNumber                              
collate Latin1_General_CI_AS                              
                              
where                               
                              
a.PolicyKey in                               
(                              
                               
SELECT b.PolicyKey FROM                                                    
[db-au-cmdwh]..penPolicy                                                                              
AS B  inner join   [db-au-cmdwh]..penOutlet                                               
as c with(nolock) on B.outletskey=c.outletskey                              
where  convert(date,IssueDate,103)=Convert(date,@StartDate,103) and b.CountryKey IN ('AU','NZ')                                                              
and  c.GroupName in (Select GroupName from SurveyBrand_Info)                                              
                                              
UNION                                                                                          
                                            
                                          
                                            
select b.policykey   from [db-au-cmdwh]..penpolicy                                                                              
as b with(nolock)    inner join                                                             
[db-au-cmdwh]..clmclaim as c with(nolock) on b.policynumber=c.policyno                   
inner join [db-au-cmdwh]..penoutlet                                               
as d with(nolock) on b.outletskey=d.outletskey                                             
where ClaimKey in (                                            
select ClaimKey from [db-au-cmdwh].[dbo].clmClaimIncurredMovement with(nolock) where  ClaimKey in (                                            
 select ClaimKey from (                                                                                                          
 select  r1.AssessmentOutcomeDescription,ClaimKey,ClaimNumber,PolicyNumber, p.PrimaryDenialReason, p.[ClaimWithdrawalReason]                                            
 ,r1.CompletionDate,row_number()over(partition by ClaimKey order by r1.CompletionDate desc) as rno                                                                                                          
 from [db-au-cmdwh].[dbo].e5WorkActivity_v3 r1 with (nolock)                                                                                                                                                                   
 inner join [db-au-cmdwh].[dbo].e5Work_v3  b with (nolock) on r1.Work_ID=b.Work_ID and r1.AssessmentOutcome is not null                                                                                             
 inner join [db-au-cmdwh].[dbo].[ve5WorkProperties] p with(nolock) on p.Work_Id = b.Work_id and p.Work_Id = r1.Work_id                                                             
 where  convert(date,r1.CompletionDate,103)=Convert(date,@StartDate-5,103)                                                                                          
                        
                                              
 ) as x1 where rno=1    and                                            
 --and F.ClaimKey=x1.ClaimKey                                             
 AssessmentOutcomeDescription in ('Approve','Deny','Claim under excess','Claim withdrawn','Partial Approval and Denial'))                           
 group by ClaimKey having sum(EstimateMovement)=0)    
 AND c.CountryKey IN ('AU','NZ')                                       
 and d.GroupName in (Select GroupName from SurveyBrand_Info)                                        
    
       
       
--and QuoteCountryKey in (select QuoteCountryKey from  [db-au-cmdwh]..Med_Data_New)                                               
                                            
                                  
UNION                                                    
SELECT a.PolicyKey FROM [db-au-cmdwh]..penPolicy AS A with(nolock)                                                           
INNER JOIN                                                             
[db-au-cmdwh]..penPolicyTransaction                                                                 
AS B with(nolock) ON A.PolicyKey=B.PolicyKey                                                  
inner join [db-au-cmdwh]..penOutlet as c with(nolock) on a.outletskey=c.outletskey                                              
where  convert(date,b.IssueDate,103)=Convert(date,@StartDate,103) AND a.countrykey in ('au','nz') and                                                              
c.GroupName in (Select GroupName from SurveyBrand_Info)                                              
--and QuoteCountryKey in (select QuoteCountryKey from  [db-au-cmdwh]..Med_Data_New)                                       
UNION                                                    
select a.PolicyKey  from [db-au-cmdwh]..penPolicyAdminCallComment AS A with(nolock)  INNER JOIN [db-au-cmdwh]..penPolicy AS B with(nolock)                                                    
ON A.PolicyKey=B.PolicyKey inner join  [db-au-cmdwh]..penOutlet as c with(nolock) on b.outletskey=c.outletskey  where  B.CountryKey IN ('AU','NZ') and convert(date,calldate,103)=convert(date,@StartDate,103)                                              
and  CallReason in (                                              
 'Breach',                        
 'Claims',                        
 'Complaint',                        
 'Corporate',                        
 'Finance Admin Enquiries',                        
 'Login Enquiries',                  
 'Long Call Wait Times - Complaint' ,                        
 'Policy Issuing Follow Ups',                        
 'Price Beats Follow Ups',                        
 'Questions about Policy Wording',                        
 'System Errors','Vulnerable Customer',                         
 'Has my Fax been received?' ,                        
 'EMC – Follow up',                          
 'EMC- Aged Policies','Other') and                                              
c.GroupName in (Select GroupName from SurveyBrand_Info)                                              
                                            
--UNION                                                    
--select a.PolicyKey from [db-au-cmdwh]..penPolicy as a with(nolock) INNER JOIN [db-au-atlas].[atlas].[Case] as b with(nolock) on a.PolicyNumber=b.PolicyNumber__c collate Latin1_General_CI_AS inner JOIN                       
--[db-au-cmdwh]..penPolicy                               
--AS C with(nolock)                                      
--         ON A.PolicyKey=C.PolicyKey  inner join [db-au-cmdwh]..penOutlet as d with(nolock) on c.outletskey=d.outletskey                                                  
--WHERE  convert(date,B.First_Closed_Date_c,103)=convert(date,@StartDate-5,103) and                
--C.CountryKey IN ('AU','NZ')                
--and d.GroupName in (Select GroupName from SurveyBrand_Info)                                                
                                   
                                                    
                                                           
) 
--and                               
--a.PolicyKey not in                                               
--(                                           
----select  a.PolicyKey from [db-au-cmdwh]..penPolicyTraveller as a with(nolock) inner join [db-au-cmdwh]..penpolicy                                                
----as b with(nolock) on a.PolicyKey=b.PolicyKey inner join  [db-au-cmdwh]..penQuote as c with(nolock) on b.PolicyKey=c.PolicyKey                             
----inner join [db-au-cmdwh]..penOutlet as d with(nolock) on c.outletskey=d.outletskey                                            
----where MarketingConsent=1 and b.CountryKey IN ('AU','NZ')  and  d.GroupName in (Select GroupName from SurveyBrand_Info)                                            
------convert(date,IssueDate,103)=convert(date,@StartDate,103)                                                
----union                                                
--select  a.PolicyKey from [db-au-cmdwh]..penpolicy as a with(nolock) inner join [db-au-cmdwh]..penQuote as b with(nolock) on a.PolicyKey=b.PolicyKey  inner join  [db-au-cmdwh]..penOutlet as c with(nolock) on b.outletskey=c.outletskey                       
            
--where  c.GroupName in (Select GroupName from SurveyBrand_Info) and a.CountryKey IN ('AU','NZ') and                                    
--(a.PurchasePath like '%Group%' or    a.PurchasePath like '%Business%')                                              
----union                                                
----select b.PolicyKey from [db-au-cmdwh]..penPolicyTraveller                                                
----as a with(nolock) inner join [db-au-cmdwh]..penPolicy as b with(nolock) on a.PolicyKey=b.PolicyKey                                                 
----inner join  [db-au-cmdwh]..penQuote as c with(nolock) on b.PolicyKey=c.PolicyKey inner join [db-au-cmdwh]..penOutlet as d with(nolock) on c.OutletAlphaKey=d.OutletAlphaKey                                               
----where d.GroupName in (Select GroupName from SurveyBrand_Info) and (                                            
----EmailAddress  like '%CoverMore.com%' or EmailAddress  like '%Zurich.com%' or                                                
----EmailAddress  like '%wtp.com%' or  EmailAddress  like '%worldTravelprotection.com%')                        
--)                                           
                                                          
) as b     on a.PolicyKey=b.PolicyKey  )                              
as a                              
                                                                                               
                                                                                                
                              
                              
                       
OUTER APPLY                                                                                                  
(                                                                                                  
select distinct OutletSKey,Channel,SuperGroupName,SubGroupName,OutletAlphaKey,OutletName,GroupName                                 
from [db-au-cmdwh]..penOutlet as J1                                                      
with(nolock)  WHERE J1.outletskey=a.outletskey   and CountryKey IN ('AU','NZ')                                                                              
)                                                                      
AS J                                                                          
OUTER APPLY                                                                                                  
(                                     
                                                                          
                                                                          
select  QuoteCountryKey,CustomerID,CustomerKey,CountryKey,CompanyKey from                               
[db-au-cmdwh]..penQuoteCustomer AS B1 with(nolock)                                                           
WHERE B1.QuoteCountryKey=A.QuoteCountryKey and IsPrimary=1 and CountryKey IN ('AU','NZ')                                                                                   
) AS B                                                                     
INNER JOIN                                                                                                   
( 
SELECT * FROM (
select countrykey,companykey,customerid,customerkey,title,firstname,lastname,emailaddress,mobilephone from                  
[db-au-cmdwh]..pencustomer as c1  with(nolock)                                      
where  --c1.customerkey=b.customerkey and                
 countrykey in ('au','nz')       
union      
select distinct '' as countrykey,'' as companykey,'' as customerid,convert(varchar(30),sessionid) as customerkey, title collate sql_latin1_general_cp1_ci_as,firstname collate sql_latin1_general_cp1_ci_as,    
lastname collate sql_latin1_general_cp1_ci_as,emailaddress collate sql_latin1_general_cp1_ci_as ,'' as mobilephone from 
[db-au-stage].dbo.medallia_inv_quote_email      
) as a1 where  EmailAddress  not like '%CoverMore.com%' and EmailAddress  not like '%Zurich.com%' and                                                
EmailAddress  not like '%wtp.com%' and  EmailAddress  not like '%worldTravelprotection.com%'
and    dbo.ChkValidEmail(EmailAddress)=0
      
) AS C  ON  (C.customerkey=b.customerkey or convert(varchar(30),C.customerkey)=a.quotecountrykey) 
                                                                                            
INNER JOIN                                                                                                  
(                                     
SELECT D1.CompanyKey,D1.countrykey,D1.PolicyKey,PolicyNumber,IssueDate,PolicyEnd,PreviousPolicyNumber,D1.PolicyID,
Title,FirstName,LastName,dob,EmailAddress,                                                    
case when WorkPhone is null then MobilePhone else WorkPhone end as Phone,                                   IssueDate as PolicyDate,MarketingConsent                                          
FROM [db-au-cmdwh]..penPolicy AS D1  with(nolock)    inner join    [db-au-cmdwh]..penPolicyTraveller AS D2                                                      
with(nolock) on D1.PolicyKey=D2.PolicyKey                                                  
                                                                                               
WHERE  --convert(date,IssueDate,103)=convert(date,@StartDate,103) and                                               
 D1.CountryKey IN ('AU','NZ')   AND isPrimary=1
and EmailAddress  not like '%CoverMore.com%' and EmailAddress  not like '%Zurich.com%' and                                                
EmailAddress  not like '%wtp.com%' and  EmailAddress  not like '%worldTravelprotection.com%'
and     dbo.ChkValidEmail(EmailAddress)=1
and  (MarketingConsent=0 or MarketingConsent is null)
AND PurchasePath not like '%Group%' AND     PurchasePath not like '%Business%'
--AND  convert(date,IssueDate,103)=Convert(date,@StartDate,103)                                                                                                
) AS D ON    A.PolicyKey=D.PolicyKey                                    
                                                    
--OUTER APPLY                                                                                                  
--(                                                                        
--SELECT PolicyKey,Title,FirstName,LastName,dob,EmailAddress,                                                    
--case when WorkPhone is null then MobilePhone else WorkPhone end as Phone                                                    
--FROM [db-au-cmdwh]..penPolicyTraveller AS D2                                                      
--with(nolock)                                                               
--WHERE A.PolicyKey=D2.PolicyKey  and isPrimary=1  and CountryKey IN ('AU','NZ')                                   
----AND  convert(date,IssueDate,103)=Convert(date,@StartDate,103)                                                                                        
--) AS D3                                        
                                        
OUTER APPLY                                                                                                  
(                                                                                                  
select * from (                                                    
SELECT CompanyKey,CountryKey,PolicyKey,PolicyNumber,GrossPremium,CurrencyCode,UserKey,UserSKey,                  
ROW_NUMBER()over(partition by PolicyKey order by IssueDate desc)                                                    
as rno                                                    
FROM [db-au-cmdwh]..penPolicyTransSummary AS E1                                                                                                 
with(nolock)                                        
WHERE D.PolicyKey=E1.PolicyKey and CountryKey IN ('AU','NZ')  and   convert(date,IssueDate,103)=Convert(date,@StartDate,103))                                                    
as a where rno=1                                                    
) AS E                                          
                                        
outer apply (                                             
                                            
 select ClaimNo,AssessmentOutcomeDescription,b.CreateDate,CompletionDate AS ClaimDate from (                                                                                                          
 select  r1.AssessmentOutcomeDescription,ClaimKey,ClaimNumber,PolicyNumber, p.PrimaryDenialReason, p.[ClaimWithdrawalReason]                                            
 ,r1.CompletionDate,row_number()over(partition by ClaimKey order by r1.CompletionDate desc) as rno                                                                                                          
 from [db-au-cmdwh].[dbo].e5WorkActivity_v3 r1 with (nolock)                                                                                                                                                                 
 inner join [db-au-cmdwh].[dbo].e5Work_v3  b with (nolock) on r1.Work_ID=b.Work_ID and r1.AssessmentOutcome                                         
 is not null                                                                                             
 inner join [db-au-cmdwh].[dbo].[ve5WorkProperties] p with (nolock) on p.Work_Id = b.Work_id and p.Work_Id = r1.Work_id                                                                                              
                                         
                                                
 ) as x1 inner join [db-au-cmdwh].[dbo].clmClaim as b with (nolock) on x1.ClaimKey=b.ClaimKey where rno=1 and CountryKey IN ('AU','NZ')  and   datepart(year,CompletionDate)=2023 and                              
 convert(date,CompletionDate,103)=CONVERT(DATE,@StartDate,103) and                              
 AssessmentOutcomeDescription in ('Approve','Deny','Claim under excess','Claim withdrawn','Partial Approval and Denial')                              
                                     
 and d.PolicyNumber=b.PolicyNo and d.CountryKey=b.CountryKey                                             
                                             
)   X                                         
                                 
INNER JOIN (                                        
                                        
                                        
select policykey,issuedate as transaction_date,uniquekey,journey from (                
                
                
select policykey,issuedate,uniquekey,journey from (                
select 'quote'+quotecountrykey as policykey,createdate as issuedate,quotecountrykey as uniquekey,'quote' as journey from                                         
[db-au-cmdwh]..penquote with(nolock) where convert(date,createdate,103)=convert(date,@startdate-7,103) and policykey is null and countrykey in ('au','nz')                
               
union                
                
select 'quote'+convert(varchar(300),SessionID) as POLICYKEY,D.Date AS QuoteDate,'CM-'+convert(varchar(30),SessionID) as QuoteCountryKey,'Quote' AS JOURNEY                
from [db-au-stage].dbo.cdg_factQuote_AU                
as a with(nolock) inner join [db-au-stage].dbo.cdg_DimCampaign_AU as b with(nolock) on a.CampaignID=b.DimCampaignID                
inner join [db-au-stage].dbo.cdg_dimDate_AU as d with(nolock) on a.QuoteTransactionDateID=d.Date                
inner join [db-au-cmdwh]..penOutlet as c with(nolock) on b.DefaultAffiliateCode collate SQL_Latin1_General_CP1_CI_AS=c.AlphaCode                
inner join [db-au-stage].dbo.cdg_factSession_AU as e with(nolock) on a.SessionID=e.FactSessionID                
where OutletStatus='Current' and convert(date,D.Date,103)=Convert(date,@StartDate-7,103)                
and e.Domain=c.CountryKey collate SQL_Latin1_General_CP1_CI_AS and CountryKey IN ('AU','NZ')) as a                
                
                
union                                        
select a.policykey,a.issuedate,b.policytransactionkey as uniquekey,'policy' as journey from                                          
[db-au-cmdwh]..penpolicy as a with (nolock) inner join [db-au-cmdwh]..penpolicytransaction                                        
as b with (nolock) on a.policykey=b.policykey where  transactiontype='base' and transactionstatus='active'        and a.CountryKey IN ('AU','NZ')                               
and convert(date,a.issuedate,103)=convert(date,@startdate,103)                                        
UNION                                        
select policykey,policytransactiondate,policytransactionkey as uniquekey,'change' as journey from (                                        
select transactiontype,policykey,policynumber,issuedate as policytransactiondate,policytransactionkey,                                                                              
case                                                                         
when transactiontype='change country'  then 'change'            
when transactiontype='edit traveller detail' then 'change'                                                                                         
when transactiontype='extend' then 'change'                                                                              
when transactiontype='partial refund' then 'change'                                                                              
when transactiontype='price beat' then 'change'                                                                              
when transactiontype='upgrade' then 'change'                                                                              
when transactiontype='remove variation' then 'change'                                                                 
when transactiontype='upgrade amt max trip duration' then 'change'                                                                              
when transactiontype='variation' then 'change'                                            
when transactiontype='base' and transactiontype<>'active' then 'change'                                            
end transactiontype_status,row_number()over(partition by policykey order by issuedate desc) as rno                                     
from [db-au-cmdwh]..penpolicytransaction as  l1 with (nolock)                                                                                  
where  (transactiontype <>'base' or  transactionstatus<>'active') and CountryKey IN ('AU','NZ') and convert(date,issuedate,103)=convert(date,@startdate,103) )                             
as b where rno=1                                        
union                                        
select policykey,policytransactiondate,uniquekey,journey from (                                        
select distinct a.policykey,convert(date,calldate,103) as   policytransactiondate,a.policykey as  uniquekey,                                        
case when b.policykey is null then 'enquiry' else null end as journey                                          
from  [db-au-cmdwh]..penpolicyadmincallcomment                                        
 as a with (nolock) left join                          
                           
 (select policykey from [db-au-cmdwh]..penpolicytransaction with (nolock) where                           
 convert(date,issuedate,103)=convert(date,@startdate,103) and                          
 transactiontype<>'base' ) as b  on a.policykey=b.policykey  where  convert(date,calldate,103)=convert(date,@startdate,103) and CountryKey IN ('AU','NZ') and callreason in                           
 (                        
 'Breach',                        
'Claims',                     
 'Complaint',                        
 'Corporate',                        
 'Finance Admin Enquiries',                        
 'Login Enquiries',                        
 'Long Call Wait Times - Complaint' ,                        
 'Policy Issuing Follow Ups',                        
 'Price Beats Follow Ups',                        
 'Questions about Policy Wording',                        
 'System Errors','Vulnerable Customer',                         
 'Has my Fax been received?' ,                        
 'EMC – Follow up',                          
 'EMC- Aged Policies','Other')                                         
 )                                        
 AS A WHERE JOURNEY IS NOT NULL                                        
UNION                                        
                                        
select c.PolicyKey,CompletionDate as ClaimDate,x1.ClaimKey as UNIQUEKEY,'Claim' as JOURNEY from (                                                                                            
select  r1.AssessmentOutcomeDescription,ClaimKey,ClaimNumber,PolicyNumber, p.PrimaryDenialReason, p.[ClaimWithdrawalReason]                                            
 ,r1.CompletionDate,row_number()over(partition by ClaimKey order by r1.CompletionDate desc) as rno                            
 from [db-au-cmdwh].[dbo].e5WorkActivity_v3 r1 with (nolock)                                      
 inner join [db-au-cmdwh].[dbo].e5Work_v3  b with (nolock) on r1.Work_ID=b.Work_ID and r1.AssessmentOutcome is not null                                              
 inner join [db-au-cmdwh].[dbo].[ve5WorkProperties] p with(nolock) on p.Work_Id = b.Work_id and p.Work_Id = r1.Work_id                                          
 where  convert(date,r1.CompletionDate,103)=CONVERT(DATE,@StartDate-5,103)                                                                                            
                                                
 ) as x1 inner join [db-au-cmdwh].[dbo].clmClaim   as b with (nolock) on x1.ClaimKey=b.ClaimKey                                         
 inner join [db-au-cmdwh].[dbo].penPolicy                                        
 as c with (nolock) on b.PolicyNo=c.PolicyNumber   where rno=1 and b.CountryKey IN ('AU','NZ')  and                                             
 AssessmentOutcomeDescription in                                         
 ('Approve','Deny','Claim under excess','Claim withdrawn','Partial Approval and Denial')                      
                       
 --UNION                      
                      
--select c.PolicyKey,First_Closed_Date_c as ClaimDate,a.PolicyKey+'99' as UNIQUEKEY,'Overseas Assistance' as JOURNEY from [db-au-cmdwh]..penPolicy as a   with(nolock) inner join [db-au-atlas].[atlas].[Case] as b                        
--with(nolock) on a.PolicyNumber=b.PolicyNumber__c collate Latin1_General_CI_AS                                              
--inner join [db-au-cmdwh]..penPolicyTraveller as c  with(nolock) on a.PolicyKey=c.PolicyKey                       
--and isPrimary=1 left join [db-au-atlas].[atlas].[WTP_Customer_Feedback_c] as d             
--on b.id=d.Case_C            
--where datediff(year,dob,getdate())>18 and a.CountryKey IN ('AU','NZ') and                                               
-- CONVERT(DATE,B.First_Closed_Date_c,103)=convert(date,@StartDate-5,103) and PolicyNumber__c                                           
-- in (select PolicyNumber_c from [db-au-atlas].[atlas].[Policy] with(nolock) where  Integration_c='1')                         
-- and b.Status='Closed' and not (            
-- (            
--    LTRIM(RTRIM(SubType_c))   like   '%Death Case%'              
--or  LTRIM(RTRIM(SubType_c))   like '%Accidental death and dismemberment%'             
--or  LTRIM(RTRIM(SubType_c))   like '%Security or safety concern%'             
--or  LTRIM(RTRIM(SubType_c))   like '%Security/safety concern%'             
--or  LTRIM(RTRIM(SubType_c))   like '%Robbery/theft%'             
--or  LTRIM(RTRIM(SubType_c))   like '%Assault%'             
--or  LTRIM(RTRIM(SubType_c))   like '%Sexual violence%'             
--or  LTRIM(RTRIM(SubType_c))   like '%Threats of harm%'             
--or  LTRIM(RTRIM(SubType_c))   like '%Civil unrest%'             
--or  LTRIM(RTRIM(SubType_c))   like '%Terrorism%'             
--or  LTRIM(RTRIM(SubType_c))   like '%War/conflict%'             
--or  LTRIM(RTRIM(SubType_c))   like '%Kidnap/Ransom%'             
--or  LTRIM(RTRIM(SubType_c))   like 'ongoing violence%'             
--or  LTRIM(RTRIM(SubType_c))   like '%complex situation%' ))                                                         
-- and  (RiskReason_c not in ('Death Cases','Vulnerable Customer') or RiskReason_c is null)              
-- and  b.Status='Closed' and (CaseDecision_c not in ('Cover Declined') or CaseDecision_c is null)             
-- and (d.Feedback_type_c not in ('Complaint') or d.Feedback_type_c is null)   
-- and Feedback_Category_C='Customer Feedback' and  Feedback_Outcome_C not in ('Resolved')  
-- or ClaimNumber_c is null                      
--or FeedbackAbout_c not in ('Complaint')                      
) AS B2) AS B3  ON (B3.PolicyKey=D.PolicyKey or 'Quote'+a.QuoteCountryKey=b3.PolicyKey)                                        
                                                                                                         
                                                                                                                              
 ) as a  ) as a inner  join SurveyBrand_Info as b on                                                                         
 case when a.groupname='Flight Centre' and a.Sub_Group='Travel Associates'              
 then 'Travel Associates' else               
 a.GroupName end=b.GroupName and a.Sub_Group=b.SubGroup                                                                        
 and a.Journey_name=b.Journey  where Active=1                                                     
 ORDER  BY GroupName,PolicyNo                                                                                              
 end 
GO
