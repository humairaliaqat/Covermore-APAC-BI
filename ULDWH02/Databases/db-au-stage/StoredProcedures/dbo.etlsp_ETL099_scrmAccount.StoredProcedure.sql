USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL099_scrmAccount]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[etlsp_ETL099_scrmAccount] @CountryCode varchar(30)
as	

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           etlsp_ETL099_scrmAccount
--  Author:         Linus Tor
--  Date Created:   20180515
--  Description:    This stored procedure returns outlet list by Country. The list is for uploading to
--					SugarCRM.
--  Parameters:     @Country: Valid country code (AU, NZ, MY, SG, US, UK etc...)
--  
--  Change History: 20180515 - LT - Created
--					20180607 - LT - Fixed FCNation and EGMNation mapping.
--                  20180621 - LT - Added isSynced and SyncedDateTime columns
--					20181016 - LT - Excludes CBA and Bankwest outlets
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @CountryCode varchar(3)
select @CountryCode = 'AU'
*/

declare @Country varchar(50)
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



--get country
select @Country = case when @CountryCode = 'SG' then 'Singapore'
						when @CountryCode = 'NZ' then 'New Zealand'
						when @CountryCode = 'MY' then 'Malaysia'
						when @CountryCode = 'UK' then 'United Kingdom'
						when @CountryCode = 'AU' then 'Australia'
						when @CountryCode = 'US' then 'United States'
						when @CountryCode = 'ID' then 'Indonesia'
						when @CountryCode = 'IN' then 'India'
						else ''
					end


if object_id('[db-au-stage].dbo.tmp_scrmAccount') is not null drop table [db-au-stage].dbo.tmp_scrmAccount
create table tmp_scrmAccount
(
	[UniqueIdentifier] varchar(50)  NULL,
	[DomainCode] [varchar](2)  NULL,
	[CompanyCode] [varchar](3)  NULL,
	[GroupCode] [nvarchar](50)  NULL,
	[SubGroupCode] [nvarchar](50)  NULL,
	[GroupName] [nvarchar](200)  NULL,
	[SubGroupName] [nvarchar](200)  NULL,
	[AgentName] [nvarchar](200)  NULL,
	[AgencyCode] [nvarchar](20)  NULL,
	[Status] [nvarchar](50)  NULL,
	[Branch] [nvarchar](100) NULL,
	[ShippingStreet] [nvarchar](100) NULL,
	[ShippingSuburb] [nvarchar](100) NULL,
	[ShippingState] [nvarchar](100) NULL,
	[ShippingPostCode] [nvarchar](50) NULL,
	[ShippingCountry] [varchar](50) NOT NULL,
	[OfficePhone] [nvarchar](50) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[BillingStreet] [nvarchar](100) NULL,
	[BillingSuburb] [nvarchar](100) NULL,
	[BillingState] [nvarchar](100) NULL,
	[BillingPostCode] [nvarchar](50) NULL,
	[BillingCountry] [varchar](50) NOT NULL,
	[BDM] [nvarchar](100) NULL,
	[AccountManager] [nvarchar](100) NULL,
	[BDMCallFrequency] [nvarchar](50) NULL,
	[AccountCallFrequency] [nvarchar](50) NULL,
	[SalesTier] [nvarchar](100) NULL,
	[OutletType] [varchar](3) NOT NULL,
	[FCArea] [nvarchar](100) NULL,
	[FCNation] [nvarchar](100) NULL,
	[EGMNation] [nvarchar](100) NULL,
	[AgencyGrading] [nvarchar](100) NULL,
	[Title] [nvarchar](100) NULL,
	[FirstName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[ManagerEmail] [nvarchar](255) NULL,
	[CCSaleOnly] [nvarchar](50) NULL,
	[PaymentType] [nvarchar](50) NULL,
	[AccountEmail] [nvarchar](255) NULL,
	[SalesSegment] [nvarchar](50) NULL,
	[CommencementDate] [datetime] NULL,
	[CloseDate] [datetime] NULL,
	[PreviousUniqueIdentifier] [nvarchar](50) NULL,
	[AccountType] [varchar](50) NULL,
	HashKey [binary](30) NULL,
	LoadDate [datetime] NULL,
	UpdateDate [datetime] NULL,
	isSynced [nvarchar](1) NULL,
	SyncedDateTime [datetime] NULL
)
create clustered index idx_tmp_scrmAccount_UniqueIdentifier on tmp_scrmAccount([UniqueIdentifier])
create index idx_tmp_scrmAccount_AccountHashKey on tmp_scrmAccount(HashKey)

select @SQL = 'insert [db-au-stage].dbo.tmp_scrmAccount select * from openquery([db-au-penguinsharp.aust.covermore.com.au], 
''select 
		td.CountryCode + ''''.'''' + tc.Code + ''''.'''' +  to1.AlphaCode as [UniqueIdentifier],
		td.CountryCode as DomainCode,
		tc.Code as CompanyCode,
		tg.Code as GroupCode,
		tsg.Code as SubGroupCode,
		tg.[Name] AS GroupName,
		tsg.[Name] AS SubGroupName,		
		to1.OutletName AS AgentName, 	
		to1.AlphaCode AS AgencyCode, 
		trvs.[Value] AS Status, 
		tosi.Branch, 
		toci.Street as [ShippingStreet],
		toci.Suburb as [ShippingSuburb], 
		toci.State as [ShippingState], 
		toci.PostCode as [ShippingPostCode], 
		''''' + @Country + ''''' as [ShippingCountry],
		toci.Phone as OfficePhone,  
		toci.Email as EmailAddress,	
		toci.POBox as [BillingStreet],
		toci.MailSuburb as [BillingSuburb],
		toci.MailState as [BillingState],
		toci.MailPostCode as [BillingPostCode],	
		''''' + @Country + ''''' as [BillingCountry],		
		tcm.UserName AS BDM, 
		tca.UserName AS AccountManager, 
		trvb.[Value] as BDMCallFrequency, 
		trva.[Value] as AccountCallFrequency, 
		trvst.[Value] as SalesTier, 
		CASE to1.OutletTypeID WHEN 2 THEN ''''B2C'''' ELSE ''''B2B'''' End AS OutletType, 		
		fc.FCArea,
		fc.FCNation,
		fc.EGMNation,
		trvag.[Value] as [AgencyGrading],
		OI.Title AS Title,
		OI.FirstName AS FirstName,
		OI.LastName as LastName,
		OI.ManagerEmail AS ManagerEmail,
		trvsS.[Value] as CCSaleOnly,
		trvsP.[Value] as PaymentType,
		TF.AccountsEmail AS AccountEmail,
		tbmi.SalesSegment,
		[AU_PenguinSharp_Active].[dbo].[UtcToLocalTimeZone](to1.CommencementDate,td.TimeZoneCode) as CommencementDate,
		[AU_PenguinSharp_Active].[dbo].[UtcToLocalTimeZone](to1.CloseDate,td.TimeZoneCode) as CloseDate,
		case when isnull(to1.PreviousAlpha,'''''''') > '''''''' then td.CountryCode + ''''.'''' + tc.Code + ''''.'''' +  to1.PreviousAlpha else null end as PreviousUniqueIdentifier,
		''''Customer'''' as AccountType,
		convert(binary(30),null) as HashKey,
		convert(datetime,null) LoadDate,
		convert(datetime,null) UpdateDate,
		convert(nvarchar(1),null) as isSynced,
		convert(datetime,null) as SyncedDateTime
	from
		[AU_PenguinSharp_Active].dbo.tblOutlet to1
		inner join [AU_PenguinSharp_Active].dbo.tblOutletManagerInfo tbmi ON to1.OutletId = tbmi.OutletID
		inner join [AU_PenguinSharp_Active].dbo.tblReferenceValue trvs ON trvs.ID = to1.StatusValue
		inner join [AU_PenguinSharp_Active].dbo.tblOutletShopInfo tosi ON to1.OutletId = tosi.OutletID
		inner join [AU_PenguinSharp_Active].dbo.tblDomain td ON td.DomainId = to1.DomainId 
		inner join [AU_PenguinSharp_Active].dbo.tblCompany tc ON td.DomainId = tc.DomainId
		inner join [AU_PenguinSharp_Active].dbo.tblSubGroup tsg ON tsg.ID = to1.SubGroupID
		inner join [AU_PenguinSharp_Active].dbo.tblGroup tg ON tsg.GroupID = tg.ID
		left join [AU_PenguinSharp_Active].dbo.tblReferenceValue trvb ON trvb.ID = tbmi.BDMCallFreqID	
		left join [AU_PenguinSharp_Active].dbo.tblReferenceValue trva ON trva.ID = tbmi.AcctMgrCallFreqID
		inner join [AU_PenguinSharp_Active].dbo.tblCRMUser tcm ON tcm.ID = tbmi.BDMID
		inner join [AU_PenguinSharp_Active].dbo.tblCRMUser tca ON tca.ID = tbmi.AcctManagerID
		left join [AU_PenguinSharp_Active].dbo.tblReferenceValue trvst ON trvst.ID = tbmi.SalesTierID
		inner join [AU_PenguinSharp_Active].dbo.tblOutletContactInfo toci ON to1.OutletId = toci.OutletID
        outer apply 
        (
            select
                a.id FCAreaID,
                a.Code  FCAreaCode,
                a.Value FCArea,
                n.Value FCNation,
                e.Value EGMNation
            from
               [AU_PenguinSharp_Active].dbo.tblReferenceValue a
                left join [AU_PenguinSharp_Active].dbo.tblReferenceValue n on
                    n.ID = a.ParentID
                left join [AU_PenguinSharp_Active].dbo.tblReferenceValue e on
                    e.ID = n.ParentID
            where
                a.id = tosi.FCAreaID and
                a.GroupID Not in (Select ID from [AU_PenguinSharp_Active].dbo.tblReferenceValueGroup where [Name] = ''''AM_Areas'''')
        ) fc
		left join [AU_PenguinSharp_Active].dbo.tblReferenceValue trvag ON trvag.ID = tosi.AgencyGradingId
		left join [AU_PenguinSharp_Active].dbo.tblOutletContactInfo OI ON to1.OutletId = OI.OutletID	
		left join [AU_PenguinSharp_Active].dbo.tblOutletFinancialInfo TF ON TF.OutletID = to1.OutletId
		left join [AU_PenguinSharp_Active].dbo.tblReferenceValue trvsS ON trvsS.ID = TF.CCSaleOnly 
		left join [AU_PenguinSharp_Active].dbo.tblReferenceValue trvsP ON trvsP.ID = TF.PaymentTypeID 	
	where	
		TD.COUNTRYCODE = ''''' + @CountryCode + ''''' and
		TC.CompanyName = ''''Covermore'''' and
		not 
		(
			td.CountryCode = ''''AU'''' and
			tg.Code in (''''CB'''',''''BW'''')
		)
'') a' 


execute(@SQL)

if @CountryCode = 'AU'
begin
		select @SQL = 'insert [db-au-stage].dbo.tmp_scrmAccount
		select * from openquery([db-au-penguinsharp.aust.covermore.com.au], 
		''select
			td.CountryCode + ''''.'''' + tc.Code + ''''.'''' +  to1.AlphaCode as [UniqueIdentifier],
			td.CountryCode as DomainCode,
			tc.Code as CompanyCode,
			tg.Code as GroupCode,
			tsg.Code as SubGroupCode,
			tg.[Name] AS GroupName,
			tsg.[Name] AS SubGroupName,		
			to1.OutletName AS AgentName, 	
			to1.AlphaCode AS AgencyCode, 
			trvs.[Value] AS Status, 
			tosi.Branch, 
			toci.Street as [ShippingStreet],
			toci.Suburb as [ShippingSuburb], 
			toci.State as [ShippingState], 
			toci.PostCode as [ShippingPostCode], 
			''''' + @Country + ''''' as [ShippingCountry],
			toci.Phone as OfficePhone,  
			toci.Email as EmailAddress,	
			toci.POBox as [BillingStreet],
			toci.MailSuburb as [BillingSuburb],
			toci.MailState as [BillingState],
			toci.MailPostCode as [BillingPostCode],	
			''''' + @Country + ''''' as [BillingCountry],		
			tcm.UserName AS BDM, 
			tca.UserName AS AccountManager, 
			trvb.[Value] as BDMCallFrequency, 
			trva.[Value] as AccountCallFrequency, 
			trvst.[Value] as SalesTier, 
			CASE to1.OutletTypeID WHEN 2 THEN ''''B2C'''' ELSE ''''B2B'''' End AS OutletType, 		
			fc.FCArea,
			fc.FCNation,
			fc.EGMNation,
			trvag.[Value] as [AgencyGrading],
			OI.Title AS Title,
			OI.FirstName AS FirstName,
			OI.LastName as LastName,
			OI.ManagerEmail AS ManagerEmail,
			trvsS.[Value] as CCSaleOnly,
			trvsP.[Value] as PaymentType,
			TF.AccountsEmail AS AccountEmail,
			tbmi.SalesSegment,
			[AU_TIP_PenguinSharp_Active].[dbo].[UtcToLocalTimeZone](to1.CommencementDate,td.TimeZoneCode) as CommencementDate,
			[AU_TIP_PenguinSharp_Active].[dbo].[UtcToLocalTimeZone](to1.CloseDate,td.TimeZoneCode) as CloseDate,			
			case when isnull(to1.PreviousAlpha,'''''''') > '''''''' then td.CountryCode + ''''.'''' + tc.Code + ''''.'''' +  to1.PreviousAlpha else null end as PreviousUniqueIdentifier,
			''''Customer'''' as AccountType,
			convert(binary(30),null) as HashKey,
			convert(datetime,null) LoadDate,
			convert(datetime,null) UpdateDate,
			convert(nvarchar(1),null) as isSynced,
			convert(datetime,null) as SyncedDateTime
		from
			[AU_TIP_PenguinSharp_Active].dbo.tblOutlet to1
			inner join [AU_TIP_PenguinSharp_Active].dbo.tblOutletManagerInfo tbmi ON to1.OutletId = tbmi.OutletID
			inner join [AU_TIP_PenguinSharp_Active].dbo.tblReferenceValue trvs ON trvs.ID = to1.StatusValue
			inner join [AU_TIP_PenguinSharp_Active].dbo.tblOutletShopInfo tosi ON to1.OutletId = tosi.OutletID
			inner join [AU_TIP_PenguinSharp_Active].dbo.tblDomain td ON td.DomainId = to1.DomainId 
			inner join [AU_TIP_PenguinSharp_Active].dbo.tblCompany tc ON td.DomainId = tc.DomainId
			inner join [AU_TIP_PenguinSharp_Active].dbo.tblSubGroup tsg ON tsg.ID = to1.SubGroupID
			inner join [AU_TIP_PenguinSharp_Active].dbo.tblGroup tg ON tsg.GroupID = tg.ID
			left join [AU_TIP_PenguinSharp_Active].dbo.tblReferenceValue trvb ON trvb.ID = tbmi.BDMCallFreqID	
			left join [AU_TIP_PenguinSharp_Active].dbo.tblReferenceValue trva ON trva.ID = tbmi.AcctMgrCallFreqID
			inner join [AU_TIP_PenguinSharp_Active].dbo.tblCRMUser tcm ON tcm.ID = tbmi.BDMID
			inner join [AU_TIP_PenguinSharp_Active].dbo.tblCRMUser tca ON tca.ID = tbmi.AcctManagerID
			left join [AU_TIP_PenguinSharp_Active].dbo.tblReferenceValue trvst ON trvst.ID = tbmi.SalesTierID
			inner join [AU_TIP_PenguinSharp_Active].dbo.tblOutletContactInfo toci ON to1.OutletId = toci.OutletID
			outer apply 
			(
				select
					a.id FCAreaID,
					a.Code  FCAreaCode,
					a.Value FCArea,
					n.Value FCNation,
					e.Value EGMNation
				from
				   [AU_PenguinSharp_Active].dbo.tblReferenceValue a
					left join [AU_PenguinSharp_Active].dbo.tblReferenceValue n on
						n.ID = a.ParentID
					left join [AU_PenguinSharp_Active].dbo.tblReferenceValue e on
						e.ID = n.ParentID
				where
					a.id = tosi.FCAreaID and
					a.GroupID Not in (Select ID from [AU_PenguinSharp_Active].dbo.tblReferenceValueGroup where [Name] = ''''AM_Areas'''')
			) fc
			left join [AU_TIP_PenguinSharp_Active].dbo.tblReferenceValue trvag ON trvag.ID = tosi.AgencyGradingId
			left join [AU_TIP_PenguinSharp_Active].dbo.tblOutletContactInfo OI ON to1.OutletId = OI.OutletID	
			left join [AU_TIP_PenguinSharp_Active].dbo.tblOutletFinancialInfo TF ON TF.OutletID = to1.OutletId
			left join [AU_TIP_PenguinSharp_Active].dbo.tblReferenceValue trvsS ON trvsS.ID = TF.CCSaleOnly 
			left join [AU_TIP_PenguinSharp_Active].dbo.tblReferenceValue trvsP ON trvsP.ID = TF.PaymentTypeID 	
		where	
			TD.COUNTRYCODE = ''''' + @CountryCode + ''''' and
			TC.CompanyName = ''''TIP'''' and
			tg.[Name] not in (''''AANT'''',''''Adventure World'''',''''NRMA'''',''''RAA'''',''''RAC'''',''''RACQ'''',''''RACT'''',''''RACV'''')
	'') a' 
	execute(@SQL)
end




update tmp_scrmAccount
set HashKey = binary_checksum
			  (
				DomainCode,
				CompanyCode,
				GroupCode,
				SubGroupCode,
				GroupName,
				SubGroupName,		
				AgentName, 	
				AgencyCode, 
				[Status],
				Branch, 
				[ShippingStreet],
				[ShippingSuburb], 
				[ShippingState], 
				[ShippingPostCode], 
				[ShippingCountry],
				OfficePhone,  
				EmailAddress,	
				[BillingStreet],
				[BillingSuburb],
				[BillingState],
				[BillingPostCode],	
				[BillingCountry],		
				BDM, 
				AccountManager, 
				BDMCallFrequency, 
				AccountCallFrequency, 
				SalesTier, 
				OutletType, 		
				FCArea,
				FCNation,
				EGMNation,
				[AgencyGrading],
				Title,
				FirstName,
				LastName,
				ManagerEmail,
				CCSaleOnly,
				PaymentType,
				AccountEmail,
				SalesSegment,
				CommencementDate,
				CloseDate,
				PreviousUniqueIdentifier,
				AccountType
			  )	
										

if object_id('[db-au-ods].dbo.scrmAccount') is null
begin
	create table [db-au-ods].dbo.scrmAccount
	(
		[UniqueIdentifier] varchar(50) NOT NULL,
		[DomainCode] [varchar](2) NOT NULL,
		[CompanyCode] [varchar](3) NOT NULL,
		[GroupCode] [nvarchar](50) NOT NULL,
		[SubGroupCode] [nvarchar](50) NOT NULL,
		[GroupName] [nvarchar](200) NOT NULL,
		[SubGroupName] [nvarchar](200) NOT NULL,
		[AgentName] [nvarchar](200) NOT NULL,
		[AgencyCode] [nvarchar](20) NOT NULL,
		[Status] [nvarchar](50) NOT NULL,
		[Branch] [nvarchar](100) NULL,
		[ShippingStreet] [nvarchar](100) NULL,
		[ShippingSuburb] [nvarchar](100) NULL,
		[ShippingState] [nvarchar](100) NULL,
		[ShippingPostCode] [nvarchar](50) NULL,
		[ShippingCountry] [varchar](50) NOT NULL,
		[OfficePhone] [nvarchar](50) NULL,
		[EmailAddress] [nvarchar](255) NULL,
		[BillingStreet] [nvarchar](100) NULL,
		[BillingSuburb] [nvarchar](100) NULL,
		[BillingState] [nvarchar](100) NULL,
		[BillingPostCode] [nvarchar](50) NULL,
		[BillingCountry] [varchar](50) NOT NULL,
		[BDM] [nvarchar](100) NULL,
		[AccountManager] [nvarchar](100) NULL,
		[BDMCallFrequency] [nvarchar](50) NULL,
		[AccountCallFrequency] [nvarchar](50) NULL,
		[SalesTier] [nvarchar](100) NULL,
		[OutletType] [varchar](3) NOT NULL,
		[FCArea] [nvarchar](100) NULL,
		[FCNation] [nvarchar](100) NULL,
		[EGMNation] [nvarchar](100) NULL,
		[AgencyGrading] [nvarchar](100) NULL,
		[Title] [nvarchar](100) NULL,
		[FirstName] [nvarchar](50) NULL,
		[LastName] [nvarchar](50) NULL,
		[ManagerEmail] [nvarchar](255) NULL,
		[CCSaleOnly] [nvarchar](50) NULL,
		[PaymentType] [nvarchar](50) NULL,
		[AccountEmail] [nvarchar](255) NULL,
		[SalesSegment] [nvarchar](50) NULL,
		[CommencementDate] [datetime] NULL,
		[CloseDate] [datetime] NULL,
		[PreviousUniqueIdentifier] [nvarchar](50) NULL,
		[AccountType] [varchar](50) NOT NULL,
		HashKey [binary](30) NULL,
		LoadDate [datetime] NOT NULL,
		UpdateDate [datetime] NULL,
		isSynced [nvarchar](1) NULL,
		SyncedDateTime [datetime] NULL
	)
	
	create clustered index idx_scrmAccount_UniqueIdentifier on [db-au-ods].dbo.scrmAccount([UniqueIdentifier])
	create nonclustered index idx_scrmAccount_AlphaCode on [db-au-ods].dbo.scrmAccount(AgencyCode)
end


begin transaction
begin try

	--merge statement
	merge into [db-au-ods].dbo.scrmAccount as DST
	using [db-au-stage].dbo.tmp_scrmAccount as SRC
	on
	(
		SRC.[UniqueIdentifier] = DST.[UniqueIdentifier] collate database_default
	)

	--insert new records
	when not matched by target then
	insert
	(
		[UniqueIdentifier],
		[DomainCode],
		[CompanyCode],
		[GroupCode],
		[SubGroupCode],
		[GroupName],
		[SubGroupName],
		[AgentName],
		[AgencyCode],
		[Status],
		[Branch],
		[ShippingStreet],
		[ShippingSuburb],
		[ShippingState],
		[ShippingPostCode],
		[ShippingCountry],
		[OfficePhone],
		[EmailAddress],
		[BillingStreet],
		[BillingSuburb],
		[BillingState],
		[BillingPostCode],
		[BillingCountry],
		[BDM],
		[AccountManager],
		[BDMCallFrequency],
		[AccountCallFrequency],
		[SalesTier],
		[OutletType],
		[FCArea],
		[FCNation],
		[EGMNation],
		[AgencyGrading],
		[Title],
		[FirstName],
		[LastName],
		[ManagerEmail],
		[CCSaleOnly],
		[PaymentType],
		[AccountEmail],
		[SalesSegment],
		[CommencementDate],
		[CloseDate],
		[PreviousUniqueIdentifier],
		[AccountType],
		HashKey,
		LoadDate,
		UpdateDate,
		isSynced,
		SyncedDateTime
	)
	values
	(
		SRC.[UniqueIdentifier],
		SRC.[DomainCode],
		SRC.[CompanyCode],
		SRC.[GroupCode],
		SRC.[SubGroupCode],
		SRC.[GroupName],
		SRC.[SubGroupName],
		SRC.[AgentName],
		SRC.[AgencyCode],
		SRC.[Status],
		SRC.[Branch],
		SRC.[ShippingStreet],
		SRC.[ShippingSuburb],
		SRC.[ShippingState],
		SRC.[ShippingPostCode],
		SRC.[ShippingCountry],
		SRC.[OfficePhone],
		SRC.[EmailAddress],
		SRC.[BillingStreet],
		SRC.[BillingSuburb],
		SRC.[BillingState],
		SRC.[BillingPostCode],
		SRC.[BillingCountry],
		SRC.[BDM],
		SRC.[AccountManager],
		SRC.[BDMCallFrequency],
		SRC.[AccountCallFrequency],
		SRC.[SalesTier],
		SRC.[OutletType],
		SRC.[FCArea],
		SRC.[FCNation],
		SRC.[EGMNation],
		SRC.[AgencyGrading],
		SRC.[Title],
		SRC.[FirstName],
		SRC.[LastName],
		SRC.[ManagerEmail],
		SRC.[CCSaleOnly],
		SRC.[PaymentType],
		SRC.[AccountEmail],
		SRC.[SalesSegment],
		SRC.[CommencementDate],
		SRC.[CloseDate],
		SRC.[PreviousUniqueIdentifier],
		SRC.[AccountType],
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
		DST.[GroupCode] = SRC.[GroupCode],
		DST.[SubGroupCode] = SRC.[SubGroupCode],
		DST.[GroupName] = SRC.[GroupName],
		DST.[SubGroupName] = SRC.[SubGroupName],
		DST.[AgentName] = SRC.[AgentName],
		DST.[AgencyCode] = SRC.[AgencyCode],
		DST.[Status] = SRC.[Status],
		DST.[Branch] = SRC.[Branch],
		DST.[ShippingStreet] = SRC.[ShippingStreet],
		DST.[ShippingSuburb] = SRC.[ShippingSuburb],
		DST.[ShippingState] = SRC.[ShippingState],
		DST.[ShippingPostCode] = SRC.[ShippingPostCode],
		DST.[ShippingCountry] = SRC.[ShippingCountry],
		DST.[OfficePhone] = SRC.[OfficePhone],
		DST.[EmailAddress] = SRC.[EmailAddress],
		DST.[BillingStreet] = SRC.[BillingStreet],
		DST.[BillingSuburb] = SRC.[BillingSuburb],
		DST.[BillingState] = SRC.[BillingState],
		DST.[BillingPostCode] = SRC.[BillingPostCode],
		DST.[BillingCountry] = SRC.[BillingCountry],
		DST.[BDM] = SRC.[BDM],
		DST.[AccountManager] = SRC.[AccountManager],
		DST.[BDMCallFrequency] = SRC.[BDMCallFrequency],
		DST.[AccountCallFrequency] = SRC.[AccountCallFrequency],
		DST.[SalesTier] = SRC.[SalesTier],
		DST.[OutletType] = SRC.[OutletType],
		DST.[FCArea] = SRC.[FCArea],
		DST.[FCNation] = SRC.[FCNation],
		DST.[EGMNation] = SRC.[EGMNation],
		DST.[AgencyGrading] = SRC.[AgencyGrading],
		DST.[Title] = SRC.[Title],
		DST.[FirstName] = SRC.[FirstName],
		DST.[LastName] = SRC.[LastName],
		DST.[ManagerEmail] = SRC.[ManagerEmail],
		DST.[CCSaleOnly] = SRC.[CCSaleOnly],
		DST.[PaymentType] = SRC.[PaymentType],
		DST.[AccountEmail] = SRC.[AccountEmail],
		DST.[SalesSegment] = SRC.[SalesSegment],
		DST.[CommencementDate] = SRC.[CommencementDate],
		DST.[CloseDate] = SRC.[CloseDate],
		DST.[PreviousUniqueIdentifier] = SRC.[PreviousUniqueIdentifier],
		DST.[AccountType] = SRC.[AccountType],
		DST.[HashKey] = SRC.HashKey,
		DST.[isSynced]=null,
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

--drop temp tables
drop table [db-au-stage].dbo.tmp_scrmAccount



GO
