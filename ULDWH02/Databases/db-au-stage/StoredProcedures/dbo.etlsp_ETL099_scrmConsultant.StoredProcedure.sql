USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL099_scrmConsultant]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[etlsp_ETL099_scrmConsultant]	@CountryCode varchar(30)
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
--					20180621 - LT - Added isSynced and SyncedDateTime columns
--					20181016 - LT - Excludes CBA and Bankwest outlets
--                  
/****************************************************************************************************/


--uncomment to debug
/*
declare @CountryCode varchar(3)
select @CountryCode = 'AU'
*/

declare @SQL varchar(8000)
declare
    @batchid int,
    @start datetime,
    @end datetime,
    @name varchar(50),
    @sourcecount int,
    @insertcount int,
    @updatecount int

declare @mergeoutput table (MergeAction varchar(20))

exec dbo.syssp_getrunningbatch
    @SubjectArea = 'SugarCRM Account and Consultant',
    @BatchID = @batchid out,
    @StartDate = @start out,
    @EndDate = @end out

select
    @name = object_name(@@procid)

exec dbo.syssp_genericerrorhandler
    @LogToTable = 1,
    @ErrorCode = '0',
    @BatchID = @batchid,
    @PackageID = @name,
    @LogStatus = 'Running'


if object_id('[db-au-stage].dbo.tmp_scrmConsultant') is not null drop table [db-au-stage].dbo.tmp_scrmConsultant
create table [db-au-stage].dbo.tmp_scrmConsultant
(
	[UniqueIdentifier] [nvarchar](200) NULL,
	[Name] [nvarchar](200) NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[UserName] [nvarchar](100) NULL,
	[UserType] [nvarchar](50) NULL,
	[OutletUniqueIdentifier] [nvarchar](50) NOT NULL,
	[Status] [varchar](10) NOT NULL,
	[InactiveStatusDate] [date] NULL,
	[Email] [nvarchar](250) NULL,
	[DateOfBirth] [date] NULL,
	HashKey [binary](30) NULL,
	LoadDate [datetime] NULL,
	UpdateDate [datetime] NULL,
	isSynced [nvarchar](1) NULL,
	SyncedDateTime [datetime] NULL
)


select @SQL = 'insert [db-au-stage].dbo.tmp_scrmConsultant
			   select *
			   from openquery([db-au-penguinsharp.aust.covermore.com.au],''
			   select 
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
					convert(binary(30),null) as HashKey,
					convert(datetime,null) as LoadDate,
					convert(datetime,null) as UpdateDate,
					convert(nvarchar(1),null) as isSynced,
					convert(datetime,null) as SyncedDateTime
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
						tc.CompanyName = ''''Covermore'''' and
						not 
						(
							td.CountryCode = ''''AU'''' and
							tg.Code in (''''CB'''',''''BW'''')
						)
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
		select @SQL = 'insert [db-au-stage].dbo.tmp_scrmConsultant
						select * 
				   from openquery([db-au-penguinsharp.aust.covermore.com.au],''
				   select 
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
						convert(binary(30),null) as HashKey,
						convert(datetime,null) as LoadDate,
						convert(datetime,null) as UpdateDate,
						convert(nvarchar(1),null) as isSynced,
						convert(datetime,null) as SyncedDateTime
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


update [db-au-stage].dbo.tmp_scrmConsultant
set HashKey = binary_checksum
			  (
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
			  )	


if object_id('[db-au-ods].dbo.scrmConsultant') is null
begin
	create table [db-au-ods].dbo.scrmConsultant
	(
		[UniqueIdentifier] [nvarchar](200) NULL,
		[Name] [nvarchar](200) NULL,
		[FirstName] [nvarchar](100) NULL,
		[LastName] [nvarchar](100) NULL,
		[UserName] [nvarchar](100) NULL,
		[UserType] [nvarchar](50) NULL,
		[OutletUniqueIdentifier] [nvarchar](50) NOT NULL,
		[Status] [varchar](10) NOT NULL,
		[InactiveStatusDate] [date] NULL,
		[Email] [nvarchar](250) NULL,
		[DateOfBirth] [date] NULL,
		HashKey [binary](30) NULL,
		LoadDate [datetime] NULL,
		UpdateDate [datetime] NULL,
		isSynced [nvarchar](1) NULL,
		SyncedDateTime [datetime] NULL
	)
	create clustered index idx_scrmConsultant_UniqueIdentifier on [db-au-ods].dbo.scrmConsultant([UniqueIdentifier])
	create nonclustered index idx_scrmConsultant_OutletUniqueIdentifier on [db-au-ods].dbo.scrmConsultant(OutletUniqueIdentifier)
end


begin transaction
begin try

	--merge statement
	merge into [db-au-ods].dbo.scrmConsultant as DST
	using [db-au-stage].dbo.tmp_scrmConsultant as SRC
	on
	(
		SRC.[UniqueIdentifier] = DST.[UniqueIdentifier] collate database_default
	)

	--insert new records
	when not matched by target then
	insert
	(
		[UniqueIdentifier],
		[Name],
		[FirstName],
		[LastName],
		[UserName],
		[UserType],
		[OutletUniqueIdentifier],
		[Status],
		[InactiveStatusDate],
		[Email],
		[DateOfBirth],
		HashKey,
		LoadDate,
		UpdateDate,
		isSynced,
		SyncedDateTime
	)
	values
	(
		SRC.[UniqueIdentifier],
		SRC.[Name],
		SRC.[FirstName],
		SRC.[LastName],
		SRC.[UserName],
		SRC.[UserType],
		SRC.[OutletUniqueIdentifier],
		SRC.[Status],
		SRC.[InactiveStatusDate],
		SRC.[Email],
		SRC.[DateOfBirth],
		SRC.HashKey,
		getdate(),
		null,
		null,
		null
	)

	--update existing records where data has changed via HashKey
	when matched and DST.HashKey <> SRC.HashKey then
	update
	set
		DST.[UniqueIdentifier] = SRC.[UniqueIdentifier],
		DST.[Name] = SRC.[Name],
		DST.[FirstName] = SRC.[FirstName],
		DST.[LastName] = SRC.[LastName],
		DST.[UserName] = SRC.[UserName],
		DST.[UserType] = SRC.[UserType],
		DST.[OutletUniqueIdentifier] = SRC.[OutletUniqueIdentifier],
		DST.[Status] = SRC.[Status],
		DST.[InactiveStatusDate] = SRC.[InactiveStatusDate],
		DST.[Email] = SRC.[Email],
		DST.[DateOfBirth] = SRC.[DateOfBirth],
		DST.[HashKey] = SRC.HashKey,
		DST.[isSynced] = null,
		DST.[UpdateDate] = getdate()

    output $action into @mergeoutput;

    select
        @insertcount = sum(case when MergeAction = 'insert' then 1 else 0 end),
        @updatecount = sum(case when MergeAction = 'update' then 1 else 0 end)
    from
        @mergeoutput


    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Finished',
        @LogSourceCount = @sourcecount,
        @LogInsertCount = @insertcount,
        @LogUpdateCount = @updatecount


end try

begin catch

    if @@trancount > 0
        rollback transaction

    exec syssp_genericerrorhandler
        @SourceInfo = 'data refresh failed',
        @LogToTable = 1,
        @ErrorCode = '-100',
        @BatchID = @batchid,
        @PackageID = @name

end catch

if @@trancount > 0
    commit transaction

drop table [db-au-stage].dbo.tmp_scrmConsultant



GO
