USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt_test12345P]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---sp_helptext 'rptsp_rpt_test12345P'
  
  
CREATE procedure [dbo].[rptsp_rpt_test12345P]  
  
as  
begin  
  
  
set nocount on  
  
 truncate table dbo.customerData_db_2019_1
 truncate table dbo.CustomerData_policyNo_2019_1  
 truncate table dbo.CustomerData_policyNo_2019_allTrans_1
 truncate table dbo.CustomerData_policyNo_prevPurchase_1 
 truncate table dbo.DirectCustomersFrom_1

  
  insert into dbo.customerData_db_2019_1
SELECT   
 -- Create an artificial customer key based on:  
 -- 1. DOB, 2. Last Name, 3. First Name.  
    lower(LastName) + lower(FirstName) + convert(nvarchar,year(DOB)) + convert(nvarchar,month(DOB)) + convert(nvarchar,day(DOB)) as custKey0  
   ,[PolicyTravellerKey]      ,[PolicyKey]      ,[FirstName]      ,[LastName]      ,[Age]      ,[DOB]      ,[isPrimary]      ,[isAdult]      ,[AdultCharge]  
      ,[AddressLine1]      ,[AddressLine2]      ,[Suburb]      ,[Postcode]      ,[State]      ,[Country]      ,[HomePhone]      ,[MobilePhone]      ,[EmailAddress]  
      ,[OptFurtherContact]      ,[MarketingConsent]      ,[StateOfArrival]      ,[LoadDate]      ,[UpdateDate]  
  ---into dbo.customerData_db_2019_1  
  FROM [db-au-actuary].[dataout].[CustomerDataSet]  
  where left(policykey,2) = 'AU'  
  order by lower(LastName) + lower(FirstName) + convert(nvarchar,year(DOB)) + convert(nvarchar,month(DOB)) + convert(nvarchar,day(DOB))  
  
  
    
  
  
/************************************* Join the Issue Date and [Base Policy No] to the CustomerData **************************/  
  
  
 --  Get the CM-AU direct websales book of 2019 business --  

 insert into dbo.CustomerData_policyNo_2019_1  
 select a.custKey0, b.[Base Policy No], b.[Issue Date], b.[PolicyKey], b.issueMonth  
 --INTO dbo.CustomerData_policyNo_2019_1  
 FROM dbo.customerData_db_2019_1 a   
 inner join   
  (select distinct [base policy no], [policykey], [Issue Date], year([issue date])*100+month([issue date]) as issueMonth  
   from [db-au-actuary].[dbo].[DWHDataSetSummary]  
   where [Product Type] = 'Insurance' and [Product group] = 'Travel' and [Domain Country] = 'AU' and [Policy Type] = 'Leisure' and [Policy Status] <> 'Cancelled'  
   and [Plan Type] in('International','Domestic') /** we include the AMT and single-trip together, but we exclude the inbound **/   
   /*******************************************************************************************************/   
   /**** issue date ****  year([issue date]) = 2019  **** Issue Date ****/  
   and year([issue date]) > 2018  
   /*******************************************************************************************************/  
   and left([outlet channel],1) = 'W' and [Product Code] in('CMH','CBI','CPC') and [JV Description] = 'Websales'  
   /*******************************************************************/  
   /******************   TO - direct in 2019 and after  ***************/  
   /*******************************************************************/  
   ) b  
 on a.policykey = b.policykey and a.custKey0 is not null 
 order by a.custKey0, b.[Base Policy No], b.[Issue Date], b.[PolicyKey]  
-- (262883 row(s) affected) -- all years 2019 and later  

  
  insert into dbo.CustomerData_policyNo_2019_allTrans_1
 select a.custKey0, b.[Base Policy No], b.[Issue Date], b.[PolicyKey], b.[JV description]  
 --INTO dbo.CustomerData_policyNo_2019_allTrans_1  
 FROM (select * from dbo.customerData_db_2019_1 where custkey0 is not null and custkey0 in(select distinct custkey0 from dbo.CustomerData_policyNo_2019_1 )) a   
 inner join   
  (select distinct [base policy no], [policykey], [Issue Date], [jv description]  
   from [db-au-actuary].[dbo].[DWHDataSetSummary]  
   where [Product Type] = 'Insurance' and [Product group] = 'Travel' and [Domain Country] = 'AU' and [Policy Type] = 'Leisure' and [Policy Status] <> 'Cancelled'  
   and [Plan Type] in('Domestic','International') and [issue date] >= '01-JAN-2016'  
   /***************************************************************/  
   /******************    FROM - any - last tran    ***************/  
   /***************************************************************/  
   ) b  
 on a.policykey = b.policykey and a.custKey0 is not null  
 order by a.custKey0, b.[Base Policy No], b.[Issue Date], b.[PolicyKey]  
-- (526821 row(s) affected) -- all travel insurance since beginning of 2016  
  
  insert into dbo.CustomerData_policyNo_prevPurchase_1 
 select a.custKey0 as key2019, a.[base policy no] as policy2019, T.[base policy no] as policyPrevious, T.[JV Description] as fromPartner,   
  T.[custKey0] as keyPrevious, a.[issue date] as date2019, T.[issue date] as datePrevious, a.issueMonth  
 ---into dbo.CustomerData_policyNo_prevPurchase_1  
 from dbo.CustomerData_policyNo_2019_1   a  
 inner join dbo.CustomerData_policyNo_2019_allTrans_1 T  
  on a.custKey0 = T.custKey0 and a.[issue date] > T.[issue date]  
 order by policy2019  
 --(363552 row(s) affected)  
  
 /**********************************************************************************************************************/  
 /*  do the merge showing for each 2019 policy purchase, the latest previous purchase relating to anyone on the policy */  
 /**********************************************************************************************************************/  
 
 insert into dbo.DirectCustomersFrom_1 
 select a.*  
 --into dbo.DirectCustomersFrom_1  
 from dbo.CustomerData_policyNo_prevPurchase_1  a  
 inner join (select policy2019, max(datePrevious) as PrevIssueDate  
     from dbo.CustomerData_policyNo_prevPurchase_1   
     group by policy2019) as prev  
  on a.policy2019 = prev.policy2019 and a.datePrevious = prev.PrevIssueDate  
 order by policy2019   
 -- 131533 rows (note that if the row drops off then it is a one-off purchase)  
  
 

 select issueMonth, case when fromPartner in('Websales','Phone Sales') then 'CM-direct ph+web'  
          else 'Non-Direct CMGroup' end as from_Partner   
    ,count(distinct policy2019) as num_policies  
 from dbo.DirectCustomersFrom_1  
 group by issueMonth, case when fromPartner in('Websales','Phone Sales') then 'CM-direct ph+web'  
          else 'Non-Direct CMGroup' end  


  
 /*** now get the count of direct web policies ***/  
 /***  NOTE:- this removes ALL cancelled policies ***/  
 /***    the other report leaves them in   ***/  
  
   
 truncate table dbo.customerData_db_2019_1
 truncate table dbo.CustomerData_policyNo_2019_1  
 truncate table dbo.CustomerData_policyNo_2019_allTrans_1
 truncate table dbo.CustomerData_policyNo_prevPurchase_1 
 truncate table dbo.DirectCustomersFrom_1
   
 END  
  
  
       
GO
