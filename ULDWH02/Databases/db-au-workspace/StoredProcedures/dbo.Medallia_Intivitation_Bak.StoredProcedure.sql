USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[Medallia_Intivitation_Bak]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
            
            
            
                        
                                  
                                      
                                      
CREATE  PROCEDURE [dbo].[Medallia_Intivitation_Bak] --'2022-04-25 18:00:48.863'                                    
@StartDate datetime                                    
AS                    
BEGIN                  
                  
select Journey_name,Survey_channel,Account_Manager_EMPId as Unit_Id,Product_Type,Sales_Channel,Account_Manager_EMPId as Unique_ID,Intermediary_Type,Purchase_Outcome,Premium_Amount,Premium_Currency,Insurance_Type,Customer_Type,Customer_Salutation,        
Customer_FirstName,Customer_LastName,Customer_Email,Customer_Phone,          
[Policy_Renewal/Expiration_Date],Claim_Outcome,Customer_JoinDate,Renewal_Outcome,Touchpoint_Date,QuoteID,PolicyNo,ClaimNo,Country,Brand_Outlet,          
a.GroupName,a.Sub_Group,Super_Group,          
case           
when a.GroupName='Cover-More' and  Journey_name='Enquiry' then 'Cover-More'         
when a.GroupName='Cover-More' and  Journey_name='Quote'   then 'Cover-More'        
when a.GroupName='Cover-More' and  Journey_name='Policy'  then 'Cover-More'         
when a.GroupName='Cover-More' and  Journey_name='Change'  then 'Cover-More'         
when a.GroupName='Cover-More' and  Journey_name='Overseas Assistance' then 'Cover-More'         
when a.GroupName='Cover-More' and  Journey_name='Claim' then 'Cover-More'        
    
when a.GroupName='Independent Agents' and a.Sub_Group in ('Flight Centre Independent','Travel Partners')     
and  Journey_name='Enquiry' then 'Cover-More'         
when a.GroupName='Independent Agents' and a.Sub_Group in ('Flight Centre Independent','Travel Partners')     
and  Journey_name='Quote'   then 'Cover-More'        
when a.GroupName='Independent Agents' and a.Sub_Group in ('Flight Centre Independent','Travel Partners')     
and  Journey_name='Policy'  then 'Cover-More'         
when a.GroupName='Independent Agents' and a.Sub_Group in ('Flight Centre Independent','Travel Partners')     
and  Journey_name='Change'  then 'Cover-More'         
when a.GroupName='Independent Agents' and a.Sub_Group in ('Flight Centre Independent','Travel Partners')     
and  Journey_name='Overseas Assistance' then 'Cover-More'         
when a.GroupName='Independent Agents' and a.Sub_Group in ('Flight Centre Independent','Travel Partners')     
and  Journey_name='Claim' then 'Cover-More'      
    
    
when a.GroupName='Flight Centre' and a.Sub_Group='Travel Managers' and  Journey_name='Enquiry' then 'Cover-More'         
when a.GroupName='Flight Centre' and a.Sub_Group='Travel Managers' and  Journey_name='Quote'   then 'Cover-More'        
when a.GroupName='Flight Centre' and a.Sub_Group='Travel Managers' and  Journey_name='Policy'  then 'Cover-More'         
when a.GroupName='Flight Centre' and a.Sub_Group='Travel Managers' and  Journey_name='Change'  then 'Cover-More'         
when a.GroupName='Flight Centre' and a.Sub_Group='Travel Managers' and  Journey_name='Overseas Assistance' then 'Cover-More'         
when a.GroupName='Flight Centre' and a.Sub_Group='Travel Managers' and  Journey_name='Claim' then 'Cover-More'     
    
when a.GroupName in ('Helloworld Branded','Helloworld Associates','Helloworld','Helloworld cruise')     
and a.Sub_Group='Stella' and  Journey_name='Enquiry' then 'Cover-More'         
when a.GroupName in ('Helloworld Branded','Helloworld Associates','Helloworld','Helloworld cruise')     
and a.Sub_Group='Stella' and  Journey_name='Quote'   then 'Cover-More'        
when a.GroupName in ('Helloworld Branded','Helloworld Associates','Helloworld','Helloworld cruise')     
and a.Sub_Group='Stella' and  Journey_name='Policy'  then 'Cover-More'         
when a.GroupName in ('Helloworld Branded','Helloworld Associates','Helloworld','Helloworld cruise')     
and a.Sub_Group='Stella' and  Journey_name='Change'  then 'Cover-More'         
when a.GroupName in ('Helloworld Branded','Helloworld Associates','Helloworld','Helloworld cruise')     
and a.Sub_Group='Stella' and  Journey_name='Overseas Assistance' then 'Cover-More'    
when a.GroupName in ('Helloworld Branded','Helloworld Associates','Helloworld','Helloworld cruise')     
and a.Sub_Group='Stella' and  Journey_name='Claim' then 'Cover-More'     
    
when a.GroupName='Cruise' and  Journey_name='Enquiry' then 'Cover-More'         
when a.GroupName='Cruise' and  Journey_name='Quote'   then 'Cover-More'        
when a.GroupName='Cruise' and  Journey_name='Policy'  then 'Cover-More'         
when a.GroupName='Cruise' and  Journey_name='Change'  then 'Cover-More'         
when a.GroupName='Cruise' and  Journey_name='Overseas Assistance' then 'Cover-More'    
when a.GroupName='Cruise' and  Journey_name='Claim' then 'Cover-More'     
    
    
when a.GroupName='Independent' and  Journey_name='Enquiry' then 'Cover-More'         
when a.GroupName='Independent' and  Journey_name='Quote'   then 'Cover-More'        
when a.GroupName='Independent' and  Journey_name='Policy'  then 'Cover-More'         
when a.GroupName='Independent' and  Journey_name='Change'  then 'Cover-More'         
when a.GroupName='Independent' and  Journey_name='Overseas Assistance' then 'Cover-More'    
when a.GroupName='Independent' and  Journey_name='Claim' then 'Cover-More'           
    
    
     
        
when a.GroupName='NRMA' and a.Sub_Group in ('NRMA Insurance Contact Centre','NRMA Insurance Internet Site','NRMA Insurance Mobile')   
and Journey_name='Enquiry' then 'NRMA'        
when a.GroupName='NRMA' and a.Sub_Group in ('NRMA Insurance Contact Centre','NRMA Insurance Internet Site','NRMA Insurance Mobile')   
and Journey_name='Quote'   then 'NRMA'         
when a.GroupName='NRMA' and a.Sub_Group in ('NRMA Insurance Contact Centre','NRMA Insurance Internet Site','NRMA Insurance Mobile')   
and Journey_name='Policy'  then 'NRMA'        
when a.GroupName='NRMA' and a.Sub_Group in ('NRMA Insurance Contact Centre','NRMA Insurance Internet Site','NRMA Insurance Mobile')   
and Journey_name='Change'  then 'NRMA'        
when a.GroupName='NRMA' and a.Sub_Group in ('NRMA Insurance Contact Centre','NRMA Insurance Internet Site','NRMA Insurance Mobile')   
and Journey_name='Overseas Assistance' then 'NRMA'         
when a.GroupName='NRMA' and a.Sub_Group in ('NRMA Insurance Contact Centre','NRMA Insurance Internet Site','NRMA Insurance Mobile')   
and Journey_name='Claim' then 'NRMA'          
        
        
        
        
when a.GroupName='Australia Post' and a.Sub_Group in ('Websales','Staff','Phone Sales') and Journey_name='Enquiry' then 'Australia Post'          
when a.GroupName='Australia Post' and a.Sub_Group in ('Websales','Staff','Phone Sales') and Journey_name='Claim' then 'Australia Post'        
when a.GroupName='Australia Post' and a.Sub_Group in ('Websales','Staff','Phone Sales') and Journey_name='Quote' then 'Australia Post'        
when a.GroupName='Australia Post' and a.Sub_Group in ('Websales','Staff','Phone Sales') and Journey_name='Policy' then 'Australia Post'         
when a.GroupName='Australia Post' and a.Sub_Group in ('Websales','Staff','Phone Sales') and Journey_name='Change' then 'Australia Post'        
when a.GroupName='Australia Post' and a.Sub_Group in ('Websales','Staff','Phone Sales') and Journey_name='Overseas Assistance' then 'Australia Post'        
        
        
        
        
when a.GroupName='MEDIBANK'and a.Sub_Group  in ('Retail','SalesForce') and Journey_name='Enquiry' then 'TIP'         
when a.GroupName='MEDIBANK'and a.Sub_Group  in ('Retail','SalesForce') and Journey_name='Claim' then 'TIP'        
when a.GroupName='MEDIBANK'and a.Sub_Group  in ('Retail','SalesForce') and Journey_name='Quote' then 'MEDIBANK'        
when a.GroupName='MEDIBANK'and a.Sub_Group  in ('Retail','SalesForce') and Journey_name='Policy' then 'MEDIBANK'        
when a.GroupName='MEDIBANK'and a.Sub_Group  in ('Retail','SalesForce') and Journey_name='Change' then 'TIP'         
when a.GroupName='MEDIBANK'and a.Sub_Group  in ('Retail','SalesForce') and Journey_name='Overseas Assistance' then 'MEDIBANK'        
        
        
when a.GroupName='AHM' and a.Sub_Group in ('AHM CM Call Centre','AHM Whitelabel','AHM Warm Transfers') and Journey_name='Enquiry' then 'TIP'          
when a.GroupName='AHM' and a.Sub_Group in ('AHM CM Call Centre','AHM Whitelabel','AHM Warm Transfers') and Journey_name='Claim' then 'TIP'         
when a.GroupName='AHM' and a.Sub_Group in ('AHM CM Call Centre','AHM Whitelabel','AHM Warm Transfers') and Journey_name='Quote' then 'AHM'        
when a.GroupName='AHM' and a.Sub_Group in ('AHM CM Call Centre','AHM Whitelabel','AHM Warm Transfers') and Journey_name='Policy' then 'AHM'        
when a.GroupName='AHM' and a.Sub_Group in ('AHM CM Call Centre','AHM Whitelabel','AHM Warm Transfers') and Journey_name='Change' then 'TIP'        
when a.GroupName='AHM' and a.Sub_Group in ('AHM CM Call Centre','AHM Whitelabel','AHM Warm Transfers') and Journey_name='Overseas Assistance' then 'TIP'         
        
        
when a.GroupName='Auto & General'and a.Sub_Group in ('Budget Direct Whitelabel','Budget Direct Call Centre') and Journey_name='Enquiry' then 'TIP'          
when a.GroupName='Auto & General'and a.Sub_Group in ('Budget Direct Whitelabel','Budget Direct Call Centre') and Journey_name='Claim' then 'TIP'        
when a.GroupName='Auto & General'and a.Sub_Group in ('Budget Direct Whitelabel','Budget Direct Call Centre') and Journey_name='Quote' then 'BUDGET DIRECT'        
when a.GroupName='Auto & General'and a.Sub_Group in ('Budget Direct Whitelabel','Budget Direct Call Centre') and Journey_name='Policy' then 'BUDGET DIRECT'         
when a.GroupName='Auto & General'and a.Sub_Group in ('Budget Direct Whitelabel','Budget Direct Call Centre') and Journey_name='Change' then 'TIP'         
when a.GroupName='Auto & General'and a.Sub_Group in ('Budget Direct Whitelabel','Budget Direct Call Centre') and Journey_name='Overseas Assistance' then 'TIP'          
        
        
        
        
        
when a.GroupName='Virgin' and a.Sub_Group in ('White Label','Integrated','Staff','CM Call Centre','Virgin Mobile')   
and Journey_name='Enquiry' then 'Cover-More'         
when a.GroupName='Virgin' and a.Sub_Group in ('White Label','Integrated','Staff','CM Call Centre','Virgin Mobile')   
and Journey_name='Claim' then 'Cover-More'        
when a.GroupName='Virgin' and a.Sub_Group in ('White Label','Integrated','Staff','CM Call Centre','Virgin Mobile')   
and Journey_name='Quote' then 'Virgin'        
when a.GroupName='Virgin' and a.Sub_Group in ('White Label','Integrated','Staff','CM Call Centre','Virgin Mobile')   
and Journey_name='Policy' then 'Virgin'        
when a.GroupName='Virgin' and a.Sub_Group in ('White Label','Integrated','Staff','CM Call Centre','Virgin Mobile')   
and Journey_name='Change' then 'Cover-More'        
when a.GroupName='Virgin' and a.Sub_Group in ('White Label','Integrated','Staff','CM Call Centre','Virgin Mobile')   
and Journey_name='Overseas Assistance' then 'Cover-More'         
        
        
        
when a.GroupName='Webjet' and a.Sub_Group in ('Webjet Call Centre','Webjet Whitelabel') and Journey_name='Enquiry' then 'Cover-More'         
when a.GroupName='Webjet' and a.Sub_Group in ('Webjet Call Centre','Webjet Whitelabel') and Journey_name='Claim' then 'Cover-More'         
when a.GroupName='Webjet' and a.Sub_Group in ('Webjet Call Centre','Webjet Whitelabel') and Journey_name='Quote' then 'Webjet'         
when a.GroupName='Webjet' and a.Sub_Group in ('Webjet Call Centre','Webjet Whitelabel') and Journey_name='Policy' then 'Webjet'         
when a.GroupName='Webjet' and a.Sub_Group in ('Webjet Call Centre','Webjet Whitelabel') and Journey_name='Change' then 'Cover-More'        
when a.GroupName='Webjet' and a.Sub_Group in ('Webjet Call Centre','Webjet Whitelabel') and Journey_name='Overseas Assistance' then 'Cover-More'    
  
when a.GroupName='Flight Centre' and a.Sub_Group in ('Flight Centre','Travel Associates') and Journey_name='Enquiry' then 'Cover-More'         
when a.GroupName='Flight Centre' and a.Sub_Group in ('Flight Centre','Travel Associates') and Journey_name='Claim' then 'Cover-More'         
when a.GroupName='Flight Centre' and a.Sub_Group in ('Flight Centre','Travel Associates') and Journey_name='Quote' then 'Flight Centre'        
when a.GroupName='Flight Centre' and a.Sub_Group in ('Flight Centre','Travel Associates') and Journey_name='Policy' then 'Flight Centre'        
when a.GroupName='Flight Centre' and a.Sub_Group in ('Flight Centre','Travel Associates') and Journey_name='Change' then 'Cover-More'         
when a.GroupName='Flight Centre' and a.Sub_Group in ('Flight Centre','Travel Associates') and Journey_name='Overseas Assistance' then 'Cover-More'        
        
when a.GroupName='Air New Zealand' and   
a.Sub_Group in('White Label','Mobile ticketing offices','Contact Centre','Integrated','Holiday stores','Tandem Travel')  
 and Journey_name='Enquiry' then 'Cover-More'          
when a.GroupName='Air New Zealand' and   
a.Sub_Group in('White Label','Mobile ticketing offices','Contact Centre','Integrated','Holiday stores','Tandem Travel')  
 and Journey_name='Claim' then 'Cover-More'        
when a.GroupName='Air New Zealand' and   
a.Sub_Group in('White Label','Mobile ticketing offices','Contact Centre','Integrated','Holiday stores','Tandem Travel')  
 and Journey_name='Quote' then 'Air New Zealand'         
when a.GroupName='Air New Zealand' and   
a.Sub_Group in('White Label','Mobile ticketing offices','Contact Centre','Integrated','Holiday stores','Tandem Travel')  
 and Journey_name='Policy' then 'Air New Zealand'         
when a.GroupName='Air New Zealand' and   
a.Sub_Group in('White Label','Mobile ticketing offices','Contact Centre','Integrated','Holiday stores','Tandem Travel')  
 and Journey_name='Change' then 'Cover-More'         
when a.GroupName='Air New Zealand' and   
a.Sub_Group in('White Label','Mobile ticketing offices','Contact Centre','Integrated','Holiday stores','Tandem Travel')  
 and Journey_name='Overseas Assistance' then 'Cover-More'        
        
END as Survey_Brand_Logo        
        
        
        
        
          
          
--end as TouchPoint          
from (          
select *,ROW_NUMBER()OVER(partition by Unique_ID order by ClaimNo) as rno from (          
SELECT  distinct                                    
case            
when y.PolicyID IS NOT NULL  THEN 'Enquiry'          
when A.QuoteID IS NOT NULL AND A.PolicyNo IS NULL THEN 'Quote'                     
when A.QuoteID IS NOT NULL AND A.PolicyNo IS NOT NULL AND L.TransactionType is not null and ClaimNo IS NULL THEN L.TransactionType_Status                  
when A.QuoteID IS NOT NULL AND A.PolicyNo IS NOT NULL and K.PolicyNumber IS NOT NULL THEN 'Overseas Assistance'                
when A.QuoteID IS NOT NULL AND A.PolicyNo IS NOT NULL AND ClaimNo IS NULL THEN 'Policy'                    
when A.QuoteID IS NOT NULL AND A.PolicyNo IS NOT NULL AND ClaimNo IS NOT NULL THEN 'Claim'              
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
isnull(TITLE,'') as [Customer_Salutation],                                    
isnull(C.FirstName,'') as [Customer_FirstName],                                    
isnull(C.LastName,'') as [Customer_LastName],                                    
isnull(EMAILADDRESS,'') as [Customer_Email],                                    
isnull(MOBILEPHONE,'') as [Customer_Phone],                                    
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
isnull(J.SuperGroupName,'') as Super_Group,          
Survey_Brand_Logo as Survey_Brand_Logo          
                      
                                
FROM (                                    
SELECT QuoteID,SessionID,CountryKey ,CompanyKey,PolicyKey,PolicyNo,CreateDate,QuoteCountryKey,OutletSKey,AgencyCode,                                    
AgencyCode+'-'+QuoteCountryKey as [Unique ID],OutletAlphaKey                                    
FROM [db-au-cmdwh]..penQuote with(nolock)                                  
where QuoteCountryKey in                                   
(                                  
SELECT QuoteCountryKey FROM [db-au-cmdwh]..penQuote with(nolock)                                   
where QuoteCountryKey in (                                  
select QuoteCountrykey from Med_Data_New) ) )                                
--WHERE convert(date,CreateDate,103)=Convert(date,@StartDate,103)                                              
                                 
                                  
AS A                                     
OUTER APPLY                                    
(                                    
select distinct OutletSKey,Channel,SuperGroupName,SubGroupName,OutletAlphaKey,OutletName,GroupName,Survey_Brand_Logo from penOutlet_Medallia as J1  with(nolock)  WHERE J1.OutletSKey=a.OutletSKey                   
)        
AS J                             
OUTER APPLY                                    
(                   
            
            
select  QuoteCountryKey,CustomerID,CustomerKey,CountryKey,CompanyKey from [db-au-cmdwh]..penQuoteCustomer AS B1 with(nolock)                                   
WHERE B1.QuoteCountryKey=A.QuoteCountryKey and B1.CompanyKey=A.COMPANYKEY and B1.CountryKey=A.CountryKey  and IsPrimary=1                                  
) AS B                                    
OUTER APPLY                                    
(                  
SELECT COUNTRYKEY,COMPANYKEY,CUSTOMERID,CUSTOMERKEY,TITLE,FIRSTNAME,LASTNAME,EMAILADDRESS,MOBILEPHONE FROM                                   
[db-au-cmdwh]..pencustomer AS C1  with(nolock)                                   
WHERE C1.COUNTRYKEY=A.COUNTRYKEY AND C1.CompanyKey=A.CompanyKey AND C1.CustomerKey=B.CustomerKey                                    
) AS C                                  
OUTER APPLY                                    
(                                    
SELECT CompanyKey,CountryKey,PolicyKey,PolicyNumber,IssueDate,PolicyEnd,PreviousPolicyNumber,PolicyID FROM [db-au-cmdwh]..penPolicy AS D1  with(nolock)                                    
WHERE A.PolicyKey=D1.PolicyKey                                     
--AND  convert(date,IssueDate,103)=Convert(date,@StartDate,103)                                  
) AS D                                 
                              
OUTER APPLY                                    
(                                    
SELECT CompanyKey,CountryKey,PolicyKey,PolicyNumber,GrossPremium,CurrencyCode,UserKey,UserSKey                               
FROM [db-au-cmdwh]..penPolicyTransSummary AS E1                                   
with(nolock)                                  
WHERE D.PolicyKey=E1.PolicyKey AND D.PolicyNumber=E1.PolicyNumber AND D.CountryKey=E1.CountryKey AND D.CompanyKey=E1.CompanyKey                                    
) AS E                       
OUTER APPLY                    
(                    
SELECT TransactionType,PolicyKey,PolicyNumber,                
case                 
when TransactionType='Change Country' and TransactionStatus='Active' then 'Amendment'              
when TransactionType='Change Country' and TransactionStatus!='Active' then 'Change'               
when TransactionType='Edit Traveller Detail' and TransactionStatus='Active' then 'Amendment'              
when TransactionType='Edit Traveller Detail' and TransactionStatus!='Active' then 'Change'              
when TransactionType='Extend' then 'Amendment'                
when TransactionType='Partial Refund' then 'Amendment'                
when TransactionType='Price Beat' then 'Change'                
when TransactionType='Upgrade' then 'Change'                
when TransactionType='Remove Variation' then 'Change'                
              
--when TransactionType='Upgrade AMT Max Trip Duration' then 'Amendment'                
--when TransactionType='Variation' then 'Change'               
end TransactionType_Status FROM [db-au-cmdwh]..penPolicyTransaction as  L1                    
WHERE  L1.PolicyKey=D.PolicyKey  and TransactionType!='Base'                  
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
WHERE A.PolicyNo=F1.PolicyNo --AND A.CountryKey=F1.CountryKey                                            
) AS F                
outer apply                
(                
select PolicyNumber,PolicyKey from [db-au-cmdwh]..penPolicy as a inner join [db-au-atlas].[atlas].[Case] as b on a.PolicyNumber=b.PolicyNumber__c collate Latin1_General_CI_AS                
 where PolicyNumber__c in (                
select PolicyNumber_c from [db-au-atlas].[atlas].[Policy] where  Integration_c='1')                
and d.PolicyKey=a.PolicyKey               
                
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
 select PolicyID from [db-au-stage]..penguin_tblPolicyAdminCallComment_autp as y1 where y1.PolicyID=d.PolicyID          
 )  Y          
           
           
 ) as a  ) as a inner join SurveyBrand_Info as b on           
 a.GroupName=b.GroupName and a.Sub_Group=b.SubGroup          
 and a.Journey_name=b.Journey  where rno=1                   
 ORDER  BY a.GroupName,Unique_ID                                  
                                    
END 
GO
