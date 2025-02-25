USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[scrmAccount]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[scrmAccount]	@CountryCode varchar(30)
as	

SET NOCOUNT ON

/****************************************************************************************************/
--  Name:           dbo.scrmAccount
--  Author:         Linus Tor
--  Date Created:   20180515
--  Description:    This stored procedure returns outlet list by Country. The list is for uploading to
--					SugarCRM.
--  Parameters:     @Country: Valid country code (AU, NZ, MY, SG, US, UK etc...)
--  
--  Change History: 20180515 - LT - Created
--                  
/****************************************************************************************************/


--uncomment to debug
/*
declare @CountryCode varchar(3)
select @CountryCode = 'AU'
*/

declare @Country varchar(50)
declare @SQL varchar(8000)

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

if object_id('[db-au-workspace].dbo.SugarCRM_Account') is not null drop table [db-au-workspace].dbo.SugarCRM_Account

select @SQL = 'select * into [db-au-workspace].dbo.SugarCRM_Account from openquery(ULSQLAGR03, 
''select convert(varchar(50),null) as RecordType, 
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
		trvsF.[Value] as FCArea,
		trvsN.[Value] as FCNation,
		trvsE.[Value] as EGMNation,
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
		td.CountryCode + ''''.'''' + tc.Code + ''''.'''' +  to1.PreviousAlpha as PreviousUniqueIdentifier,
		''''Customer'''' as AccountType
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
		left join [AU_PenguinSharp_Active].dbo.tblReferenceValue trvsF ON trvsF.ID = tosi.FCAreaID
		left join [AU_PenguinSharp_Active].dbo.tblReferenceValue trvsE ON trvsE.ID = tosi.EGMNationID
		left join [AU_PenguinSharp_Active].dbo.tblReferenceValue trvsN ON trvsN.ID = tosi.FCNationID
		left join [AU_PenguinSharp_Active].dbo.tblReferenceValue trvag ON trvag.ID = tosi.AgencyGradingId
		left join [AU_PenguinSharp_Active].dbo.tblOutletContactInfo OI ON to1.OutletId = OI.OutletID	
		left join [AU_PenguinSharp_Active].dbo.tblOutletFinancialInfo TF ON TF.OutletID = to1.OutletId
		left join [AU_PenguinSharp_Active].dbo.tblReferenceValue trvsS ON trvsS.ID = TF.CCSaleOnly 
		left join [AU_PenguinSharp_Active].dbo.tblReferenceValue trvsP ON trvsP.ID = TF.PaymentTypeID 	
	where	
		TD.COUNTRYCODE = ''''' + @CountryCode + ''''' and
		TC.CompanyName = ''''Covermore''''
'') a' 

execute(@SQL)

if @CountryCode = 'AU'
begin
		select @SQL = 'insert [db-au-workspace].dbo.SugarCRM_Account
		select * from openquery(ULSQLAGR03, 
		''select convert(varchar(50),null) as RecordType, 
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
			trvsF.[Value] as FCArea,
			trvsN.[Value] as FCNation,
			trvsE.[Value] as EGMNation,
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
			td.CountryCode + ''''.'''' + tc.Code + ''''.'''' +  to1.PreviousAlpha as PreviousUniqueIdentifier,
			''''Customer'''' as AccountType
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
			left join [AU_TIP_PenguinSharp_Active].dbo.tblReferenceValue trvsF ON trvsF.ID = tosi.FCAreaID
			left join [AU_TIP_PenguinSharp_Active].dbo.tblReferenceValue trvsE ON trvsE.ID = tosi.EGMNationID
			left join [AU_TIP_PenguinSharp_Active].dbo.tblReferenceValue trvsN ON trvsN.ID = tosi.FCNationID
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


--update record type 
update [db-au-workspace].dbo.SugarCRM_Account
set RecordType = case when convert(varchar(10),CommencementDate,120) = convert(varchar(10),getdate(),120) then 'New'  else 'Amendment' end


select * 
from [db-au-workspace].dbo.SugarCRM_Account
order by 2

drop table [db-au-workspace].dbo.SugarCRM_Account
GO
