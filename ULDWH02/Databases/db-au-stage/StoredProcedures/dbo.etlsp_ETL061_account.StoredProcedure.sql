USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL061_account]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[etlsp_ETL061_account]
as

SET NOCOUNT ON


/************************************************************************************************************************************
Author:         Linus Tor
Date:           20160209
Prerequisite:   N/A
Description:    transform salesforce account dimension
Parameters:		
				
Change History:
                20160209 - LT - Procedure created

*************************************************************************************************************************************/


if object_id('[db-au-stage].dbo.etl_sfAccount') is not null drop table [db-au-stage].dbo.etl_sfAccount
select
	a.ID as AccountID,
	a.Name as AccountName,
	a.Group_Code__c as GroupCode,
	a.GroupName__c as GroupName,
	a.Sub_Group_Code__c as SubGroupCode,
	a.SubGroupName__c as SubGroupName,
	a.AgencyCode__c as AlphaCode,
	a.Name as OutletName,
	a.AgencyID__c as AgencyID,
	a.OutletType__c as OutletType,
	a.[Type] as TradingStatus,
	a.Agency_Manager__c as AgencyManager,
	a.Primary_Title__c as ContactTitle,
	a.Primary_First_Name__c as ContactFirstName,
	a.Primary_Last_Name__c as ContactLastName,
	a.BillingStreet as ContactAddress,
	a.BillingCity as ContactCity,
	a.BillingState as ContactState,
	a.BillingPostalCode as ContactPostcode,
	a.BillingCountry as ContactCountry,
	a.ManagerEmail__c as ContactEmail,
	a.AccountsEmail__c as AccountsEmail,
	a.CompanyCode__c as CompanyCode,
	a.DomainCode__c as DomainCode,
	a.BDM__c as BDMName,
	a.BDMCallFrequency__c as BDMCallFrequency,
	a.AccountManager__c as AccountManager,
	a.AMCallFrequency__c as AMCallFrequency,
	a.Email__c as Email,
	a.Phone,
	a.Fax,
	a.FCNation__c as FCNation,
	a.FCArea__c as FCArea,
	a.Industry,
	a.IsDeleted,
	a.Last_Visited__c as LastVisited,
	a.LastActivityDate,
	a.LastModifiedDate,
	lm.LastModifiedBy,
	a.LastReferencedDate,
	a.LastViewedDate,
	a.Old_Alpha__c as PreviousAlpha,
	o.[Owner],
	a.PaymentType__c as PaymentType,
	a.Quadrant__c as Quadrant,
	a.Quadrant_Potential__c as QuadrantPotential,
	r.RecordType,
	a.Sales_Quadrant__c as SalesQuadrant,
	a.SalesSegment__c as SalesSegement,
	a.SalesTier__c as SalesTier,
	a.Visit_Due__c as VisitDueDate,
	a.Visit_Status__c as VisitStatus,
	la.LastAccountActivityDate,
	la.LastAccountActivityUser
into [db-au-stage].dbo.etl_sfAccount
from
	sforce_account a
	outer apply
	(
		select top 1 Name as [Owner]
		from [db-au-stage].dbo.sforce_user
		where ID = a.OwnerId
	) o
	outer apply
	(
		select top 1 Name as LastModifiedBy
		from [db-au-stage].dbo.sforce_user
		where ID = a.LastModifiedById
	) lm
	outer apply
	(
		select top 1 Name as RecordType
		from [db-au-stage].dbo.sforce_RecordType
		where ID = a.RecordTypeID
	) r
	outer apply
	(
		select top 1
			ah.CreatedDate as LastAccountActivityDate,
			u.FirstName + ' ' + u.LastName as LastAccountActivityUser
		from
			[db-au-stage].dbo.sforce_AccountHistory ah
			join [db-au-stage].dbo.sforce_user u on ah.CreatedByID = u.ID
		where
			ah.AccountID = a.ID
		order by
			ah.CreatedDate desc
	) la

if object_id('[db-au-cmdwh].dbo.sfAccount') is null
begin
	create table [db-au-cmdwh].[dbo].[sfAccount]
	(
		[AccountID] [nvarchar](18) NULL,
		[AccountName] [nvarchar](255) NULL,
		[GroupCode] [nvarchar](10) NULL,
		[GroupName] [nvarchar](255) NULL,
		[SubGroupCode] [nvarchar](10) NULL,
		[SubGroupName] [nvarchar](255) NULL,
		[AlphaCode] [nvarchar](10) NULL,
		[OutletName] [nvarchar](255) NULL,
		[AgencyID] [nvarchar](30) NULL,
		[OutletType] [nvarchar](255) NULL,
		[TradingStatus] [nvarchar](40) NULL,
		[AgencyManager] [nvarchar](1300) NULL,
		[ContactTitle] [nvarchar](20) NULL,
		[ContactFirstName] [nvarchar](80) NULL,
		[ContactLastName] [nvarchar](80) NULL,
		[ContactAddress] [nvarchar](255) NULL,
		[ContactCity] [nvarchar](40) NULL,
		[ContactState] [nvarchar](80) NULL,
		[ContactPostcode] [nvarchar](20) NULL,
		[ContactCountry] [nvarchar](80) NULL,
		[ContactEmail] [nvarchar](80) NULL,
		[AccountsEmail] [nvarchar](80) NULL,
		[CompanyCode] [nvarchar](255) NULL,
		[DomainCode] [nvarchar](255) NULL,
		[BDMName] [nvarchar](255) NULL,
		[BDMCallFrequency] [nvarchar](3) NULL,
		[AccountManager] [nvarchar](255) NULL,
		[AMCallFrequency] [nvarchar](3) NULL,
		[Email] [nvarchar](80) NULL,
		[Phone] [nvarchar](40) NULL,
		[Fax] [nvarchar](40) NULL,
		[FCNation] [nvarchar](255) NULL,
		[FCArea] [nvarchar](255) NULL,
		[Industry] [nvarchar](40) NULL,
		[IsDeleted] [bit] NULL,
		[LastVisited] [datetime] NULL,
		[LastActivityDate] [date] NULL,
		[LastModifiedDate] [datetime] NULL,
		[LastModifiedBy] [nvarchar](121) NULL,
		[LastReferencedDate] [datetime] NULL,
		[LastViewedDate] [datetime] NULL,
		[PreviousAlpha] [bit] NULL,
		[Owner] [nvarchar](121) NULL,
		[PaymentType] [nvarchar](255) NULL,
		[Quadrant] [nvarchar](255) NULL,
		[QuadrantPotential] [nvarchar](255) NULL,
		[RecordType] [nvarchar](80) NULL,
		[SalesQuadrant] [nvarchar](255) NULL,
		[SalesSegement] [nvarchar](255) NULL,
		[SalesTier] [nvarchar](255) NULL,
		[VisitDueDate] [date] NULL,
		[VisitStatus] [nvarchar](1300) NULL,
		LastAccountActivityDate [datetime] NULL,
		LastAccountActivityUser [nvarchar](121) NULL
	) 
       create clustered index idx_sfAccount_AccountID on [db-au-cmdwh].dbo.sfAccount(AccountID)
	   create nonclustered index idx_sfAccount_DomainCode on [db-au-cmdwh].dbo.sfAccount(DomainCode)
	   create nonclustered index idx_sfAccount_CompanyCode on [db-au-cmdwh].dbo.sfAccount(CompanyCode)
       create nonclustered index idx_sfAccount_AccountName on [db-au-cmdwh].dbo.sfAccount(AccountName)
       create nonclustered index idx_sfAccount_GroupName on [db-au-cmdwh].dbo.sfAccount(GroupName)
       create nonclustered index idx_sfAccount_SubGroupName on [db-au-cmdwh].dbo.sfAccount(SubGroupName)
       create nonclustered index idx_sfAccount_BDMName on [db-au-cmdwh].dbo.sfAccount(BDMName)
       create nonclustered index idx_sfAccount_OutletType on [db-au-cmdwh].dbo.sfAccount(OutletType)
       create nonclustered index idx_sfAccount_AlphaCode on [db-au-cmdwh].dbo.sfAccount(AlphaCode)
       create nonclustered index idx_sfAccount_RecordType on [db-au-cmdwh].dbo.sfAccount(RecordType)
       create nonclustered index idx_sfAccount_Owner on [db-au-cmdwh].dbo.sfAccount([Owner])
end
else
	delete a
	from [db-au-cmdwh].dbo.sfAccount a
		inner join [db-au-stage].dbo.etl_sfAccount b on
			a.AccountID = b.AccountID


insert [db-au-cmdwh].dbo.sfAccount with (tablockx)
(
	[AccountID],
	[AccountName],
	[GroupCode],
	[GroupName],
	[SubGroupCode],
	[SubGroupName],
	[AlphaCode],
	[OutletName],
	[AgencyID],
	[OutletType],
	[TradingStatus],
	[AgencyManager],
	[ContactTitle],
	[ContactFirstName],
	[ContactLastName],
	[ContactAddress],
	[ContactCity],
	[ContactState],
	[ContactPostcode],
	[ContactCountry],
	[ContactEmail],
	[AccountsEmail],
	[CompanyCode],
	[DomainCode],
	[BDMName],
	[BDMCallFrequency],
	[AccountManager],
	[AMCallFrequency],
	[Email],
	[Phone],
	[Fax],
	[FCNation],
	[FCArea],
	[Industry],
	[IsDeleted],
	[LastVisited],
	[LastActivityDate],
	[LastModifiedDate],
	[LastModifiedBy],
	[LastReferencedDate],
	[LastViewedDate],
	[PreviousAlpha],
	[Owner],
	[PaymentType],
	[Quadrant],
	[QuadrantPotential],
	[RecordType],
	[SalesQuadrant],
	[SalesSegement],
	[SalesTier],
	[VisitDueDate],
	[VisitStatus],
	LastAccountActivityDate,
	LastAccountActivityUser
)
select
	[AccountID],
	[AccountName],
	[GroupCode],
	[GroupName],
	[SubGroupCode],
	[SubGroupName],
	[AlphaCode],
	[OutletName],
	[AgencyID],
	[OutletType],
	[TradingStatus],
	[AgencyManager],
	[ContactTitle],
	[ContactFirstName],
	[ContactLastName],
	[ContactAddress],
	[ContactCity],
	[ContactState],
	[ContactPostcode],
	[ContactCountry],
	[ContactEmail],
	[AccountsEmail],
	[CompanyCode],
	[DomainCode],
	[BDMName],
	[BDMCallFrequency],
	[AccountManager],
	[AMCallFrequency],
	[Email],
	[Phone],
	[Fax],
	[FCNation],
	[FCArea],
	[Industry],
	[IsDeleted],
	[LastVisited],
	[LastActivityDate],
	[LastModifiedDate],
	[LastModifiedBy],
	[LastReferencedDate],
	[LastViewedDate],
	[PreviousAlpha],
	[Owner],
	[PaymentType],
	[Quadrant],
	[QuadrantPotential],
	[RecordType],
	[SalesQuadrant],
	[SalesSegement],
	[SalesTier],
	[VisitDueDate],
	[VisitStatus],
	LastAccountActivityDate,
	LastAccountActivityUser
from
	[db-au-stage].dbo.etl_sfAccount


GO
