USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL111_QualtricsDataLoad]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
CREATE procedure [dbo].[etlsp_ETL111_QualtricsDataLoad]    
as    
    
SET NOCOUNT ON    
    
/************************************************************************************************************************************/    
-- Author:         Linus Tor    
-- Date:           20190201    
-- Prerequisite:   Requires Qualtrics data feed available at <\\aust.covermore.com.au\data\NorthSydney_data\Human Resources\PAYROLL\QUALTRIX FEED>    
-- Description:    Transform Preceda employee data and stores in [db-au-cmdwh].dbo.usrPrecedaEmployee table    
    
-- Change History:    
--                20190201 - LT - Procedure created    
--      20190617 - LT - Fixed bugs in insert and update statements    
--    
/************************************************************************************************************************************/    
    
if object_id('tempdb..#Employee') is not null drop table #Employee    
create table #Employee    
(    
 Domain varchar(2) null,    
 FirstName varchar(100) null,    
 LastName varchar(100) null,    
 Email varchar(255) null,    
 EmployeeID int null,    
 Company varchar(100) null,    
 Division varchar(100) null,    
 Department varchar(100) null,    
 ReportsToPositionTitle varchar(100) null,    
 Gender varchar(50) null,    
 PersonnelType varchar(100) null,     
 EmploymentType varchar(50) null,    
 [Location] varchar(100) null,    
 Country varchar(100) null,    
 HireDate datetime null,    
 SelectionDate datetime null,    
 HashKey binary(30) null    
)    
    
    
insert #Employee    
select    
 'AU' as Domain,    
 [First Name] as FirstName,    
 [Last Name] as LastName,    
 Email,    
 [ID Number] as EmployeeID,    
 Company,    
 Division,    
 Department,    
 [Reports To Position Title] as ReportsToPositionTitle,    
 Gender,    
 [Personnel Type Desc] as PersonnelType,    
 [Employment Type Desc] as EmploymentType,    
 [Location],    
 Country,  
 CASE WHEN PATINDEX('%[/-]%', [Hire Date])<=3 THEN   
				CONVERT(DATETIME,SUBSTRING([Hire Date], LEN([Hire Date])-3,LEN([Hire Date]))+'/'+ SUBSTRING([Hire Date], PATINDEX('%[/-]%', [Hire Date])+1,2) 
				+'/'+SUBSTRING([Hire Date], 1,PATINDEX('%[/-]%', [Hire Date])-1),121)  
			ELSE CONVERT(DATETIME, [Hire Date], 121) 
			END AS HireDate,
CASE WHEN PATINDEX('%[/-]%', [Selection Date])<=3 THEN   
				CONVERT(DATETIME,SUBSTRING([Selection Date], LEN([Selection Date])-3,LEN([Selection Date]))+'/'+ SUBSTRING([Selection Date], PATINDEX('%[/-]%', [Selection Date])+1,2) 
				+'/'+SUBSTRING([Selection Date], 1,PATINDEX('%[/-]%', [Selection Date])-1),121)  
			ELSE CONVERT(DATETIME, [Selection Date], 121) 
			END AS SelectionDate,
 /*
 convert(datetime,[Hire Date]) as HireDate,    
 convert(datetime,[Selection Date]) as SelectionDate,    
 */
 convert(binary(30),null) as HashKey    
from     
 etl_QualtricsFeedAU    
    
union all    
    
select    
 'NZ' as Domain,    
 [First Name] as FirstName,    
 [Last Name] as LastName,    
 Email,    
 [ID Number] as EmployeeID,    
 Company,    
 Division,    
 Department,    
 [Reports To Position Title] as ReportsToPositionTitle,    
 Gender,    
 [Personnel Type Desc] as PersonnelType,    
 [Employment Type Desc] as EmploymentType,    
 [Location],    
 Country,    
 CASE WHEN PATINDEX('%[/-]%', [Hire Date])<=3 THEN   
				CONVERT(DATETIME,SUBSTRING([Hire Date], LEN([Hire Date])-3,LEN([Hire Date]))+'/'+ SUBSTRING([Hire Date], PATINDEX('%[/-]%', [Hire Date])+1,2) 
				+'/'+SUBSTRING([Hire Date], 1,PATINDEX('%[/-]%', [Hire Date])-1),121)  
			ELSE CONVERT(DATETIME, [Hire Date], 121) 
			END AS HireDate,
CASE WHEN PATINDEX('%[/-]%', [Selection Date])<=3 THEN   
				CONVERT(DATETIME,SUBSTRING([Selection Date], LEN([Selection Date])-3,LEN([Selection Date]))+'/'+ SUBSTRING([Selection Date], PATINDEX('%[/-]%', [Selection Date])+1,2) 
				+'/'+SUBSTRING([Selection Date], 1,PATINDEX('%[/-]%', [Selection Date])-1),121)  
			ELSE CONVERT(DATETIME, [Selection Date], 121) 
			END AS SelectionDate,
 /*
 convert(datetime,[Hire Date],103) as HireDate,    
 convert(datetime,[Selection Date],103) as SelectionDate, 
 */
 convert(binary(30),null) as HashKey    
from     
 etl_QualtricsFeedNZ    
    
--update Hashkey    
update #Employee    
set HashKey = binary_checksum     
    (    
     Domain,    
     FirstName,    
     LastName,    
     Email,    
     Company,    
     Division,    
     Department,    
     ReportsToPositionTitle,    
     Gender,    
     PersonnelType,    
     EmploymentType,    
     [Location],    
     Country,    
     HireDate,    
     SelectionDate    
    )    
    
    
--get employees that are new or had hashkey changed since last ETL run    
if object_id('tempdb..#New') is not null drop table #New    
    
select    
    e.EmployeeID    
into #New    
from    
    #Employee e    
    left join [db-au-cmdwh].dbo.usrPrecedaEmployee r on    
        r.EmployeeID = e.EmployeeID    
where    
 r.EmployeeID is null    
    
    
    
if object_id('[db-au-cmdwh].dbo.usrPrecedaEmployee') is null    
begin    
 create table [db-au-cmdwh].dbo.usrPrecedaEmployee    
 (    
  BIRowID int identity(1,1) not null,    
  Domain varchar(2) null,    
  FirstName varchar(100) null,    
  LastName varchar(100) null,    
  Email varchar(255) null,    
  EmployeeID int null,    
  Company varchar(100) null,    
  Division varchar(100) null,    
  Department varchar(100) null,    
  ReportsToPositionTitle varchar(100) null,    
  Gender varchar(50) null,    
  PersonnelType varchar(100) null,     
  EmploymentType varchar(50) null,    
  [Location] varchar(100) null,    
  Country varchar(100) null,    
  HireDate datetime null,    
  SelectionDate datetime null,    
  HashKey binary(30) null,    
  LoadDate datetime not null,    
  UpdateDate datetime not null,    
  isSynced nvarchar(1) null,    
  SyncDateTime datetime null,    
  QualtricsContactID nvarchar(100) null    
 )    
    create clustered index idx_usrPrecedaEmployee_BIRowID on [db-au-cmdwh].dbo.usrPrecedaEmployee(BIRowID)    
    create nonclustered index idx_usrPrecedaEmployee_HireDate on [db-au-cmdwh].dbo.usrPrecedaEmployee(HireDate) include(Domain,SelectionDate)    
end    
    
    
--insert new employee records    
insert [db-au-cmdwh].dbo.usrPrecedaEmployee with(tablock)    
select    
  Domain,    
  FirstName,    
  LastName,    
  Email,    
  EmployeeID,    
  Company,    
  Division,    
  Department,    
  ReportsToPositionTitle,    
  Gender,    
  PersonnelType,    
  EmploymentType,    
  [Location],    
  Country,    
  HireDate,    
  SelectionDate,    
  HashKey,    
  getdate() as LoadDate,    
  getdate() as UpdateDate,    
  null as isSync,    
  null as SyncDateTime,    
  null as QualtricsContactID    
from    
 #Employee    
where    
 EmployeeID in (select EmployeeID from #New)    
    
    
--update employee attributes if they have been changed    
update e    
set    
 e.Domain = n.Domain,    
 e.FirstName = n.FirstName,    
 e.LastName = n.LastName,    
 e.Email = n.Email,    
 e.Company = n.Company,    
 e.Division = n.Division,    
 e.Department = e.Department,    
 e.ReportsToPositionTitle = n.ReportsToPositionTitle,    
 e.Gender = n.Gender,    
 e.PersonnelType = n.PersonnelType,    
 e.EmploymentType = n.EmploymentType,    
 e.[Location] = n.[Location],    
 e.Country = n.Country,    
 e.HireDate = n.HireDate,    
 e.SelectionDate = n.SelectionDate,    
 e.Hashkey = n.HashKey,    
 e.UpdateDate = getdate(),    
 e.isSynced = null,    
 e.SyncedDateTime = null    
from    
 [db-au-cmdwh].dbo.usrPrecedaEmployee e    
 inner join #Employee n on e.EmployeeID = n.EmployeeID    
where    
 e.EmployeeID not in (select EmployeeID from #New)
GO
