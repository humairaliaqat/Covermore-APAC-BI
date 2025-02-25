USE [db-au-workspace]
GO
/****** Object:  View [dbo].[Invitiation_Medalia]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[Invitiation_Medalia]
AS
SELECT 
case 
when A.QuoteID IS NOT NULL AND A.PolicyNo IS NULL THEN 'Quote'
when A.QuoteID IS NOT NULL AND A.PolicyNo IS NOT NULL AND ClaimNo IS NULL THEN 'Policy'
when A.QuoteID IS NOT NULL AND A.PolicyNo IS NOT NULL AND ClaimNo IS NOT NULL THEN 'Claim'
END
AS Journey_name,
j.Channel Survey_channel, 
'Travel' AS Product_Type,
'Online' as Sales_Channel,
 [Unique ID],
'white label / integrated' as Intermediary_Type,
case when a.QuoteID is not null and a.PolicyNo is not null then 'Purchase' else 'Non-Purchase' END as Purchase_Outcome,
GrossPremium AS [Premium Amount],
CurrencyCode AS [Premium Currency],
'P&C or Life' AS [Insurance Type],
'Individual' AS [Customer Type],
''as [Customer Salutation],
FIRSTNAME as [Customer First Name],
LASTNAME as [Customer Last Name],
EMAILADDRESS as [Customer Email],
MOBILEPHONE as [Customer Phone],
'' as [Policy Renewal/Expiration Date],
'' as [Claim Outcome],
'' as [Customer Join Date],
'' as [Renewal Outcome],
'' as [Payout Type],
'' as [Touchpoint Date],
QuoteID,PolicyNo,ClaimNo,A.CountryKey as Unit_Name FROM (
SELECT QuoteID,SessionID,CountryKey ,CompanyKey,PolicyKey,PolicyNo,CreateDate,QuoteCountryKey,OutletSKey,AgencyCode,
AgencyCode+'-'+QuoteCountryKey as [Unique ID]
FROM [db-au-cmdwh]..penQuote)
AS A 
OUTER APPLY
(
select OutletSKey,Channel from [db-au-cmdwh]..penOutlet as J1
WHERE J1.OutletSKey=a.OutletSKey
) 
AS J
OUTER APPLY
(
select  QuoteCountryKey,CustomerID,CustomerKey,CountryKey,CompanyKey from [db-au-cmdwh]..penQuoteAddOn AS B1
WHERE B1.QuoteCountryKey=A.QuoteCountryKey and B1.CompanyKey=A.COMPANYKEY and B1.CountryKey=A.CountryKey
) AS B
OUTER APPLY
(
SELECT COUNTRYKEY,COMPANYKEY,CUSTOMERID,CUSTOMERKEY,TITLE,FIRSTNAME,LASTNAME,EMAILADDRESS,MOBILEPHONE FROM [db-au-cmdwh]..pencustomer AS C1
WHERE C1.COUNTRYKEY=A.COUNTRYKEY AND C1.CompanyKey=A.CompanyKey AND C1.CustomerKey=B.CustomerKey
) AS C
OUTER APPLY
(
SELECT CompanyKey,CountryKey,PolicyKey,PolicyNumber,IssueDate FROM [db-au-cmdwh]..penPolicy AS D1 
WHERE A.PolicyKey=D1.PolicyKey AND A.PolicyNo=D1.PolicyNumber
) AS D
OUTER APPLY
(
SELECT CompanyKey,CountryKey,PolicyKey,PolicyNumber,GrossPremium,CurrencyCode FROM [db-au-cmdwh]..penPolicyTransSummary AS E1 
WHERE D.PolicyKey=E1.PolicyKey AND D.PolicyNumber=E1.PolicyNumber AND D.CountryKey=E1.CountryKey AND D.CompanyKey=E1.CompanyKey
) AS E
OUTER APPLY
(
SELECT PolicyKey,CreateDate,ClaimKey,ClaimNo,CountryKey FROM [db-au-cmdwh]..clmClaim AS F1
WHERE D.PolicyKey=F1.PolicyKey AND D.CountryKey=F1.CountryKey  
) AS F 
GO
