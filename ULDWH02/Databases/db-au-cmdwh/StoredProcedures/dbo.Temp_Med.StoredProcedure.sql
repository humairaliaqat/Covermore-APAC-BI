USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[Temp_Med]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
         
                                
CREATE procedure [dbo].[Temp_Med]  
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
case when Customer_Title is null then  Customer_Salutation else Customer_Title end Customer_Salutation,      
case when FirstName is null then       
dbo.[Camelcase](Customer_FirstName) else FirstName end as Customer_FirstName,      
case when LastName is null then       
dbo.[Camelcase](Customer_LastName) else LastName end as Customer_LastName,      
b.CustomerEmail as  Customer_Email, -- Chnage in Production      
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
case       
when A.QuoteID IS NOT NULL AND A.PolicyNo IS NOT NULL and K.PolicyNumber IS NOT NULL THEN 'Overseas Assistance'      
when A.QuoteID IS NOT NULL AND A.PolicyNo IS NOT NULL AND ClaimNo IS NOT NULL THEN 'Claim'       
when y.PolicyKey IS NOT NULL  THEN 'Enquiry'         
when A.QuoteID IS NOT NULL AND A.PolicyNo IS NOT NULL AND L.TransactionType is not null and ClaimNo IS NULL THEN L.TransactionType_Status             
when A.QuoteID IS NOT NULL AND A.PolicyNo IS NOT NULL AND ClaimNo IS NULL THEN 'Policy'       
when A.QuoteID IS NOT NULL AND A.PolicyNo IS NULL THEN 'Quote'             
            
      
                             
END                                                    
AS Journey_name,                                                    
'Email' Survey_channel,                                           
isnull(Unit_Name,'') as Unit_Id,                                            
'Travel' AS Product_Type,                                                    
'Online' as Sales_Channel,                                                    
 [Unique ID] as Unique_ID ,                                                    
isnull(Channel,'') as Intermediary_Type,                                                    
case when a.QuoteID is not null and a.PolicyNo is not null then 'Purchase' else 'Non-Purchase' END as Purchase_Outcome,                                                   
isnull(GrossPremium,'') AS [Premium_Amount],                                                    
isnull(CurrencyCode,'') AS [Premium_Currency],                                                    
'Travel' AS [Insurance_Type],                                                    
'Individual' AS [Customer_Type],                                                    
isnull(c.Title,'') as [Customer_Salutation],      
isnull(d3.Title,'') as [Customer_Title],      
isnull(C.FirstName,'') as [Customer_FirstName],      
isnull(D3.FirstName,'') as [FirstName],      
isnull(C.LastName,'') as [Customer_LastName],       
isnull(D3.LastName,'') as [LastName],      
isnull(c.EmailAddress,'') as [Customer_Email],      
isnull(d3.EmailAddress,'') as [Email],      
isnull(MOBILEPHONE,'') as [Customer_Phone],      
isnull(d3.Phone,'') as [Phone],      
isnull (replace(convert(varchar(50),PolicyEnd,102),'.','-'),'') as [Policy_Renewal/Expiration_Date],                                                    
isnull(AssessmentOutcomeDescription,'') as [Claim_Outcome],                                                    
isnull(replace(convert(varchar(50),F.CreateDate,102),'.','-'),'') as [Customer_JoinDate],                     
case when d.PreviousPolicyNumber is not null then 'Renewal' else ' ' end  as [Renewal_Outcome],                                                    
--isnull(case                                         
--when FinalisedDate is not null then ''                                        
--when g.RecoveryPaymentMovement='0.00' then 'Surrender Maturity'                                            
--when g.RecoveryPaymentMovement!='0.00' then 'Surrender Partial'                                                   
--END,'') as [Payout_Type],                                             
getdate() as  [Touchpoint_Date],                                                    
QuoteID,isnull(PolicyNo,'')as PolicyNo, isnull(ClaimNo,'') as ClaimNo ,                                       
A.CountryKey as Country,                                      
J.outletName as Brand_Outlet,-- Penoutlet ?                                       
J.GroupName AS GroupName,                                
j.SubGroupName as Sub_Group,                                      
isnull(J.SuperGroupName,'') as Super_Group                          
--Survey_Brand_Logo as Survey_Brand_Logo                          
                                      
                                                
FROM (                                                    
SELECT QuoteID,SessionID,CountryKey ,CompanyKey,PolicyKey,PolicyNo,CreateDate,QuoteCountryKey,OutletSKey,AgencyCode,                                                    
AgencyCode+'-'+QuoteCountryKey as [Unique ID],OutletAlphaKey                                                    
FROM [db-au-cmdwh]..penQuote with(nolock)                                                  
where QuoteCountryKey in                                                   
(                                                  
SELECT QuoteCountryKey FROM [db-au-cmdwh]..penQuote as a  with(nolock)                
 WHERE convert(date,CreateDate,103)=Convert(date,@StartDate-7,103) and              
QuoteCountryKey in (Select QuoteCountryKey from [db-au-cmdwh]..Med_Data)            
         
UNION                                
SELECT QuoteCountryKey FROM [db-au-cmdwh]..penQuote AS A with(nolock)             
INNER JOIN               
[db-au-cmdwh]..penPolicy                                
AS B with(nolock) ON A.PolicyKey=B.PolicyKey                               
where  convert(date,IssueDate,103)=Convert(date,@StartDate,103)                 
and             
QuoteCountryKey in (Select QuoteCountryKey from [db-au-cmdwh]..Med_Data)            
               
UNION                                
SELECT QuoteCountryKey FROM [db-au-cmdwh]..penQuote AS A with(nolock) INNER JOIN [db-au-cmdwh]..penPolicy                                
AS B with(nolock) ON A.PolicyKey=B.PolicyKey   inner join               
[db-au-cmdwh]..clmClaim as c with(nolock) on b.PolicyNumber=c.PolicyNo                 
where StatusDesc='Finalised' and  convert(date,c.FinalisedDate,103)=Convert(date,@StartDate,103) and             
QuoteCountryKey in (Select QuoteCountryKey from [db-au-cmdwh]..Med_Data)            
      
UNION      
      
SELECT QuoteCountryKey FROM [db-au-cmdwh]..penQuote AS A with(nolock)             
INNER JOIN               
[db-au-cmdwh]..penPolicyTransaction                                
AS B with(nolock) ON A.PolicyKey=B.PolicyKey  and a.CountryKey=b.CountryKey and a.CompanyKey=b.CompanyKey                              
where  convert(date,IssueDate,103)=Convert(date,@StartDate,103)                 
and   QuoteCountryKey in (Select QuoteCountryKey from [db-au-cmdwh]..Med_Data)      
UNION      
select QuoteCountryKey  from [db-au-cmdwh]..penPolicyTransaction AS A  INNER JOIN [db-au-cmdwh]..penQuote AS B with(nolock)      
ON A.PolicyKey=B.PolicyKey  where A.PolicyKey in (      
select PolicyKey from [db-au-cmdwh]..penPolicyAdminCallComment where  convert(date,calldate,103)=convert(date,@StartDate-1,103))      
and TransactionType!='Base' and   convert(date,IssueDate,103)=convert(date,@StartDate,103)      
UNION      
select QuoteCountryKey from [db-au-cmdwh]..penPolicy as a INNER JOIN [db-au-atlas].[atlas].[Case] as b on a.PolicyNumber=b.PolicyNumber__c collate Latin1_General_CI_AS inner JOIN [db-au-cmdwh]..penQuote AS C with(nolock)      
ON A.PolicyKey=C.PolicyKey      
WHERE  convert(date,B.CreatedDate,103)=convert(date,@StartDate,103)      
      
             
)            
            
)                                                            
                                                 
                                                  
AS A                                                     
OUTER APPLY                                                    
(                                                    
select distinct OutletSKey,Channel,SuperGroupName,SubGroupName,OutletAlphaKey,OutletName,GroupName from [db-au-cmdwh]..penOutlet as J1        
with(nolock)  WHERE J1.OutletSKey=a.OutletSKey                                   
)                        
AS J                                             
OUTER APPLY                                                    
(                                   
                            
                            
select  QuoteCountryKey,CustomerID,CustomerKey,CountryKey,CompanyKey from [db-au-cmdwh]..penQuoteCustomer AS B1 with(nolock)             WHERE B1.QuoteCountryKey=A.QuoteCountryKey and IsPrimary=1                                               
) AS B                                                    
OUTER APPLY                                                    
(                                  
SELECT COUNTRYKEY,COMPANYKEY,CUSTOMERID,CUSTOMERKEY,TITLE,FIRSTNAME,LASTNAME,EMAILADDRESS,MOBILEPHONE FROM                                                   
[db-au-cmdwh]..pencustomer AS C1  with(nolock)                                                   
WHERE C1.COUNTRYKEY=A.COUNTRYKEY AND C1.CompanyKey=A.CompanyKey AND C1.CustomerKey=B.CustomerKey                                                    
) AS C                                                  
OUTER APPLY                                                    
(                                                    
SELECT CompanyKey,CountryKey,PolicyKey,PolicyNumber,IssueDate,PolicyEnd,PreviousPolicyNumber,PolicyID FROM [db-au-cmdwh]..penPolicy AS D1        
with(nolock)                                                    
WHERE A.PolicyKey=D1.PolicyKey    and D1.PolicyKey   
not in(  
  
select  PolicyKey from [db-au-cmdwh]..penPolicyTraveller as a with(nolock) inner join [db-au-cmdwh]..penpolicy  
as b with(nolock) on a.PolicyKey=b.PolicyKey   where MarketingConsent=1 and  convert(date,IssueDate,103)=convert(date,@StartDate,103)  
union  
select  PolicyKey from [db-au-cmdwh]..penpolicy nolock where (PurchasePath like '%Group%' or    PurchasePath like '%Business%')
and convert(date,IssueDate,103)=convert(date,@StartDate,103)  
union  
 -- Production Enable
select a.PolicyKey from penPolicyTraveller  
as a inner join penPolicy as b on a.PolicyKey=b.PolicyKey   
where (EmailAddress  like '%CoverMore.com%' or EmailAddress  like '%Zurich.com%' or  
EmailAddress  like '%wtp.com%' or  EmailAddress  like '%worldTravelprotection.com%')
and CONVERT(date,IssueDate,103)=convert(date,@StartDate,103)  
  
  
)                                                
--AND  convert(date,IssueDate,103)=Convert(date,@StartDate,103)                                                  
) AS D       
      
OUTER APPLY                                                    
(                                                    
SELECT PolicyKey,Title,FirstName,LastName,dob,EmailAddress,      
case when WorkPhone is null then MobilePhone else WorkPhone end as Phone      
FROM [db-au-cmdwh]..penPolicyTraveller AS D2        
with(nolock)                                                    
WHERE A.PolicyKey=D2.PolicyKey   and isPrimary=1                                                  
--AND  convert(date,IssueDate,103)=Convert(date,@StartDate,103)                                                  
) AS D3           
                                              
OUTER APPLY                                                    
(                                                    
select * from (      
SELECT CompanyKey,CountryKey,PolicyKey,PolicyNumber,GrossPremium,CurrencyCode,UserKey,UserSKey,ROW_NUMBER()over(partition by PolicyKey order by IssueDate desc)      
as rno      
FROM [db-au-cmdwh]..penPolicyTransSummary AS E1                                                   
with(nolock)                                                  
WHERE D.PolicyKey=E1.PolicyKey  and   convert(date,IssueDate,103)=Convert(date,@StartDate,103))      
as a where rno=1      
) AS E                                       
OUTER APPLY                                    
(                                    
SELECT TransactionType,PolicyKey,PolicyNumber,                                
case                           
when TransactionType='Change Country' and TransactionStatus='Active' then 'Change'                                          
when TransactionType='Edit Traveller Detail' and TransactionStatus='Active' then 'Change'                                           
when TransactionType='Extend' then 'Change'                                
when TransactionType='Partial Refund' then 'Change'                                
when TransactionType='Price Beat' then 'Change'                                
when TransactionType='Upgrade' then 'Change'                                
when TransactionType='Remove Variation' then 'Change'                                
when TransactionType='Upgrade AMT Max Trip Duration' then 'Change'                                
when TransactionType='Variation' then 'Change'                               
end TransactionType_Status FROM [db-au-cmdwh]..penPolicyTransaction as  L1                                    
WHERE  L1.PolicyKey=D.PolicyKey  and TransactionType!='Base'   and convert(date,IssueDate,103)=  convert(date,@StartDate,103)                                
) AS L                                            
OUTER APPLY                                              
(                                              
select UserKey,UserSKey,FirstName,LastName, Email as  Unit_Name from  [db-au-cmdwh]..penUser as H1 with(nolock)                                              
WHERE H1.UserSKey=E.UserSKey AND H1.UserKey=E.UserKey                                              
) AS H                                              
OUTER APPLY                                                    
(                                                    
SELECT distinct PolicyKey,CreateDate,ClaimKey,convert(varchar(50),ClaimNo) as ClaimNo,CountryKey,FinalisedDate                
FROM [db-au-cmdwh]..clmClaim AS F1                                                  
with(nolock)                                                  
WHERE A.PolicyNo=F1.PolicyNo and  convert(date,FinalisedDate,103)=  convert(date,@StartDate,103)                                                          
) AS F                
outer apply                                
(                                
select PolicyNumber,a.PolicyKey from [db-au-cmdwh]..penPolicy as a inner join [db-au-atlas].[atlas].[Case] as b on a.PolicyNumber=b.PolicyNumber__c collate Latin1_General_CI_AS
inner join [db-au-cmdwh]..penPolicyTraveller as c on a.PolicyKey=c.PolicyKey and isPrimary=1
 where datediff(year,dob,getdate())>18 and 
 
 CONVERT(DATE,B.CreatedDate,103)=convert(date,@StartDate-5,103) and PolicyNumber__c 
 in (select PolicyNumber_c from [db-au-atlas].[atlas].[Policy] where  Integration_c='1')             
and d.PolicyKey=a.PolicyKey and b.Status='Closed' and  (
SubType_c not in (            
 'Death Case'            
,'Accidental death and dismemberment'            
,'Security or safety concern'            
,'Security/safety concern'            
,'Robbery/theft'            
,'Assault'            
,'Sexual violence'            
,'Threats of harm'            
,'Civil unrest'            
,'Terrorism'            
,'War/conflict'            
,'Kidnap/Ransom'            
,'ongoing violence'            
,'complex situation')            
 or RiskReason_c not in ('Death Cases','Vulnerable Customer')  or b.Status='Closed'  or ClaimNumber_c is null
or FeedbackAbout_c not in ('Complaint'))


                                
) K                                
                                
outer apply (                                                  
 select * from (                                                            
 select  r1.AssessmentOutcomeDescription,ClaimKey,ClaimNumber,PolicyNumber, p.PrimaryDenialReason, p.[ClaimWithdrawalReason]                                                  
 ,r1.CompletionDate,row_number()over(partition by ClaimKey order by r1.CompletionDate desc) as rno                                                            
 from [db-au-cmdwh].[dbo].e5WorkActivity_v3 r1 with (nolock)                                                                                                                     
 inner join [db-au-cmdwh].[dbo].e5Work_v3  b with (nolock) on r1.Work_ID=b.Work_ID and r1.AssessmentOutcome is not null                                               
 inner join [db-au-cmdwh].[dbo].[ve5WorkProperties] p on p.Work_Id = b.Work_id and p.Work_Id = r1.Work_id                                                     
 --where  convert(date,r1.CompletionDate,103)='2022-04-25'                                                   
 ) as x1 where rno=1  and F.ClaimKey=x1.ClaimKey  )   X                           
                           
 outer apply                          
 (                          
 select PolicyKey,CallDate,CallComment from [db-au-cmdwh]..penPolicyAdminCallComment as y1 where y1.PolicyKey=d.PolicyKey          
 and  convert(date,CallDate,103)=Convert(date,@StartDate,103)          
 )  Y                          
                           
                           
 ) as a  ) as a inner  join SurveyBrand_Info as b on                           
 a.GroupName=b.GroupName and a.Sub_Group=b.SubGroup                          
 and a.Journey_name=b.Journey  where rno=1                                   
 ORDER  BY a.GroupName,Unique_ID                                                  
    
      
         end   
            
            
            
            
            
            
            
            
            
            
            
            
            
            
GO
