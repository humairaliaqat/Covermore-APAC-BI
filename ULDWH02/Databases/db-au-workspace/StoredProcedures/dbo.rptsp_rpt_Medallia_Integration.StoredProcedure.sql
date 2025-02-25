USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt_Medallia_Integration]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[rptsp_rpt_Medallia_Integration]	
         --                          
as
begin

------OutFile----------

if object_id('tempdb..#temp_Medallia_Opt_OutFile') is not null    
  drop table #temp_Medallia_Opt_OutFile 

select emailid into #temp_Medallia_Opt_OutFile from Medallia_Opt_OutFile where 1=2

-- import the file
BULK INSERT #temp_Medallia_Opt_OutFile
FROM 'E:\ETL\Naveen\MedalliaIntegration\OutFile.csv'
WITH
(        
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        FIRSTROW=2
)
insert into Medallia_Opt_OutFile (EmailId,load_date)

select s.emailid,GETDATE() from #temp_Medallia_Opt_OutFile s
left join Medallia_Opt_OutFile t
on s.emailid = t.emailid
where t.emailid is null

-------ComplianceFile------

if object_id('tempdb..#temp_Medallia_ComplianceFile') is not null    
  drop table #temp_Medallia_ComplianceFile

select surveyID,Customer_FirstName,Customer_LastName,Customer_Email,Brand,Touchpoint,NPS_Score,[Free text],load_date into #temp_Medallia_ComplianceFile from Medallia_ComplianceFile where 1=2

-- import the file
BULK INSERT #temp_Medallia_ComplianceFile
FROM 'E:\ETL\Naveen\MedalliaIntegration\ComplianceFile.csv'
WITH
(        
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        FIRSTROW=2
)
insert into Medallia_ComplianceFile (surveyID,Customer_FirstName,Customer_LastName,Customer_Email,Brand,Touchpoint,NPS_Score,[Free text],load_date)

select s.surveyID,s.Customer_FirstName,s.Customer_LastName,s.Customer_Email,s.Brand,s.Touchpoint,s.NPS_Score,s.[Free text],GETDATE() 
from #temp_Medallia_ComplianceFile s
left join Medallia_ComplianceFile t
on s.surveyid = t.surveyid and 
   s.Customer_FirstName = t.Customer_FirstName and 
   s.Customer_LastName =t.Customer_LastName and 
   s.Customer_Email =t.Customer_Email and 
   s.Brand =t.Brand and 
   s.Touchpoint = t.Touchpoint and 
   s.NPS_Score =t.NPS_Score and 
   s.[Free text] =t.[Free text] 
where t.surveyid is null

 end
GO
