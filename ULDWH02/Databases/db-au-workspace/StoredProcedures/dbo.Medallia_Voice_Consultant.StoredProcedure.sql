USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[Medallia_Voice_Consultant]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
  
  
  
CREATE PROCEDURE [dbo].[Medallia_Voice_Consultant]  
  
AS  
BEGIN  
  
    if object_id('dbo.#temp') is not null  
    begin  
 drop table dbo.#temp  
 END  
  
  
SELECT distinct  
       
   dbo.[Camelcase](FirstName) as FirstName,  
   dbo.[Camelcase](LastName) as LastName,  
   a.OutletId ,  
   dbo.[Camelcase](outletname) as Brand_Outlet,  
   dbo.[Camelcase](Groupname) as GroupName,  
   dbo.[Camelcase](SubGroupName) as SubGroupName,  
   SuperGroupName,  
   Email,  
   a.Status,  
   a.CountryKey,  
   Cast(Createdatetime as date) as Createdatetime,  
   max(Cast([LastLoggedIn] as date)) as [LastLoggedIn]   
   into #temp  
  FROM [db-au-cmdwh].[dbo].[penUser] a   
  left outer join [db-au-cmdwh].[dbo].penoutlet p on a.OutletAlphaKey = p.OutletAlphaKey   
  where OutletStatus = 'Current' and Email is not null  --and Firstname = 'Abba'  
  and a.CreateDateTime >= '2022-01-01' and a.CountryKey in ('AU', 'NZ')  
  and p.SuperGroupName in ('Stella', 'Independents', 'IAL')  
  --and Email = 'mansi.patel@flightcentre.co.nz'  
   group by   
   FirstName,  
   LastName,  
   a.OutletId,  
   outletname,  
    Groupname,  
   SubGroupName,  
   SuperGroupName,  
   Email,  
  a.Status,  
  a.CountryKey,  
   Createdatetime  
   having     
   a.Status = 'Active' and  max([LastLoggedIn]) is not null  
  
  
 --insert into medallia_voice_of_consultant(firstname,lastname,outletid,brand_outlet,groupname,subgroupname,supergroupname,email,status,countrykey ,createdatetime,lastloggedin,createddate)  
 --select firstname,lastname,outletid,brand_outlet,groupname,subgroupname,supergroupname,email,status,countrykey ,createdatetime,lastloggedin,getdate() as createddate from (  
 -- select  firstname,  
 --  lastname,  
 --  outletid ,  
 --  brand_outlet,  
 --  groupname,  
 --  subgroupname,  
 --  supergroupname,  
 --  email,  
 --  status,  
 --  countrykey,  
 --  createdatetime,  
 --  [lastloggedin] ,row_number() over (partition by email  
 --                           order by  lastloggedin desc ) rn  
 -- from   #temp) as a where rn=1  
  
  
END  
GO
