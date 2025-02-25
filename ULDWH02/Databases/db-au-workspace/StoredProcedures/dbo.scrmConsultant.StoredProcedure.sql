USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[scrmConsultant]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[scrmConsultant]	@CountryCode varchar(30)
as	

SET NOCOUNT ON

/****************************************************************************************************/
--  Name:           dbo.scrmConsultant
--  Author:         Linus Tor
--  Date Created:   20180518
--  Description:    This stored procedure returns consultant list by Country. The list is for uploading to
--					SugarCRM.
--  Parameters:     @Country: Valid country code (AU, NZ, MY, SG, US, UK etc...)
--  
--  Change History: 20180518 - LT - Created
--                  
/****************************************************************************************************/


--uncomment to debug
/*
declare @CountryCode varchar(3)
select @CountryCode = 'AU'
*/

declare @Country varchar(50)
declare @SQL varchar(8000)



if object_id('[db-au-workspace].dbo.SugarCRM_Consultants') is not null drop table [db-au-workspace].dbo.SugarCRM_Consultants

select @SQL = 'select * into [db-au-workspace].dbo.SugarCRM_Consultants
			   from openquery(ULSQLAGR03,''
			   select convert(varchar(50),null) as RecordType,
					[UniqueIdentifier],
					ltrim(rtrim(FirstName)) + '''' '''' + ltrim(rtrim(LastName)) as [Name],
					ltrim(rtrim(FirstName)) as FirstName,
					ltrim(rtrim(LastName)) as LastName,
					UserName,
					UserType,
					[OutletUniqueIdentifier],
					[Status],		
					[InactiveStatusDate],
					Email,
					DateOfBirth,
					UpdateDateTime
				from
				(	
					select 
						td.CountryCode + ''''.'''' + tc.Code + ''''.'''' + to1.AlphaCode + ''''.'''' + tu.[Login] AS [UniqueIdentifier], 
						ltrim(rtrim(tu.FirstName)) + '''' '''' + ltrim(rtrim(tu.LastName)) as [Name],
						tu.FirstName, 
						tu.LastName 	,
						tu.[Login] as UserName,
						trvs.[Value] as UserType,
						td.CountryCode + ''''.'''' + tc.Code + ''''.'''' + to1.AlphaCode AS [OutletUniqueIdentifier],
						case isnull(tu.[Status], 0) when 0 then ''''ACTIVE'''' else ''''INACTIVE'''' end as [Status],
						convert(date, [AU_PenguinSharp_Active].dbo.UtcToLocalTimeZone(tu.[Status],td.TimeZoneCode)) as InactiveStatusDate,
						tu.Email,
						Convert(Date, [AU_PenguinSharp_Active].dbo.UtcToLocalTimeZone(tu.DateOfBirth, td.TimeZoneCode)) AS DateOfBirth,
						 convert(date,[AU_PenguinSharp_Active].dbo.UtcToLocalTimeZone(tu.UpdateDateTime, td.TimeZoneCode)) as UpdateDateTime
					from 
						[AU_PenguinSharp_Active].dbo.tblUser tu 
						LEFT JOIN [AU_PenguinSharp_Active].dbo.tblReferenceValue trvs ON trvs.ID = tu.AccessLevel
						INNER JOIN [AU_PenguinSharp_Active].dbo.tblOutlet to1 ON to1.OutletId = tu.OutletId
						INNER JOIN [AU_PenguinSharp_Active].dbo.tblSubGroup tsg ON tsg.ID = to1.SubGroupID
						INNER JOIN [AU_PenguinSharp_Active].dbo.tblGroup tg ON tg.ID= tsg.GroupId
						INNER JOIN [AU_PenguinSharp_Active].dbo.tblDomain td ON td.DomainId = to1.DomainId 
						INNER JOIN [AU_PenguinSharp_Active].dbo.tblCompany tc ON td.DomainId = tc.DomainId
					where
						td.COUNTRYCODE = ''''' + @CountryCode + ''''' and
						tc.CompanyName = ''''Covermore''''
			) a	'') a
			where
			(
				FirstName not in (''Tramada'',''Sysuser'',''Webuser'',''Initial'',''Webuser'',''Covermore'',''Webuser (DO NOT DELETE)'',''uat'',''test'',''training'',''trainingNSW'',''trainingNT'',''trainingQLD'',''trainingSA'',''trainingVIC'',''trainingWA'',''Admin'',''QLDFC'',''Cover'') and
				Email not like ''%covermore.com%''
			)
'
execute(@SQL)


if @CountryCode = 'AU'
begin
		select @SQL = 'insert [db-au-workspace].dbo.SugarCRM_Consultants
		select * 
			   from openquery(ULSQLAGR03,''
			   select convert(varchar(50),null) as RecordType,
					[UniqueIdentifier],
					ltrim(rtrim(FirstName)) + '''' '''' + ltrim(rtrim(LastName)) as [Name],
					ltrim(rtrim(FirstName)) as FirstName,
					ltrim(rtrim(LastName)) as LastName,
					UserName,
					UserType,
					[OutletUniqueIdentifier],
					[Status],		
					[InactiveStatusDate],
					Email,
					DateOfBirth,
					UpdateDateTime
				from
				(	
					select 
						td.CountryCode + ''''.'''' + tc.Code + ''''.'''' + to1.AlphaCode + ''''.'''' + tu.[Login] AS [UniqueIdentifier], 
						ltrim(rtrim(tu.FirstName)) + '''' '''' + ltrim(rtrim(tu.LastName)) as [Name],
						tu.FirstName, 
						tu.LastName 	,
						tu.[Login] as UserName,
						trvs.[Value] as UserType,
						td.CountryCode + ''''.'''' + tc.Code + ''''.'''' + to1.AlphaCode AS [OutletUniqueIdentifier],
						case isnull(tu.[Status], 0) when 0 then ''''ACTIVE'''' else ''''INACTIVE'''' end as [Status],
						convert(date, [AU_TIP_PenguinSharp_Active].dbo.UtcToLocalTimeZone(tu.[Status],td.TimeZoneCode)) as InactiveStatusDate,
						tu.Email,
						Convert(Date, [AU_TIP_PenguinSharp_Active].dbo.UtcToLocalTimeZone(tu.DateOfBirth, td.TimeZoneCode)) AS DateOfBirth,
						 convert(date,[AU_TIP_PenguinSharp_Active].dbo.UtcToLocalTimeZone(tu.UpdateDateTime, td.TimeZoneCode)) as UpdateDateTime
					from 
						[AU_TIP_PenguinSharp_Active].dbo.tblUser tu 
						LEFT JOIN [AU_TIP_PenguinSharp_Active].dbo.tblReferenceValue trvs ON trvs.ID = tu.AccessLevel
						INNER JOIN [AU_TIP_PenguinSharp_Active].dbo.tblOutlet to1 ON to1.OutletId = tu.OutletId
						INNER JOIN [AU_TIP_PenguinSharp_Active].dbo.tblSubGroup tsg ON tsg.ID = to1.SubGroupID
						INNER JOIN [AU_TIP_PenguinSharp_Active].dbo.tblGroup tg ON tg.ID= tsg.GroupId
						INNER JOIN [AU_TIP_PenguinSharp_Active].dbo.tblDomain td ON td.DomainId = to1.DomainId 
						INNER JOIN [AU_TIP_PenguinSharp_Active].dbo.tblCompany tc ON td.DomainId = tc.DomainId
					where
						td.COUNTRYCODE = ''''' + @CountryCode + ''''' and
						tc.CompanyName = ''''TIP'''' and
						tg.[Name] not in (''''AANT'''',''''Adventure World'''',''''NRMA'''',''''RAA'''',''''RAC'''',''''RACQ'''',''''RACT'''',''''RACV'''')
			) a	'') a
			where
			(
				FirstName not in (''Tramada'',''Sysuser'',''Webuser'',''Initial'',''Webuser'',''Covermore'',''Webuser (DO NOT DELETE)'',''uat'',''test'',''training'',''trainingNSW'',''trainingNT'',''trainingQLD'',''trainingSA'',''trainingVIC'',''trainingWA'',''Admin'',''QLDFC'',''Cover'') and
				Email not like ''%covermore.com%''
			)'
	execute(@SQL)
end


--update record type 
update [db-au-workspace].dbo.SugarCRM_Consultants
set RecordType = case when convert(varchar(10),UpdateDateTime,120) = convert(varchar(10),getdate(),120) then 'New'  else 'Amendment' end


select
    RecordType,
    [UniqueIdentifier],
    [Name],
    FirstName,
    LastName,
    UserName,
    UserType,
    [OutletUniqueIdentifier],
    [Status],		
    [InactiveStatusDate],
    Email,
    DateOfBirth
from 
    [db-au-workspace].dbo.SugarCRM_Consultants
order by 2,3

drop table [db-au-workspace].dbo.SugarCRM_Consultants
GO
