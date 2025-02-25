USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0994]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[rptsp_rpt0994] @CountryCode varchar(3),
									  @LoadType varchar(50),
									  @DateRange varchar(30),
									  @StartDate datetime,
									  @EndDate datetime,
									  @UniqueIdentifier varchar(50)
									
as	

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           rptsp_rpt0994
--  Author:         Linus Tor
--  Date Created:   20180515
--  Description:    This stored procedure returns outlet list by Country. The list is for uploading to
--					SugarCRM.
--  Parameters:     @CountryCode:	Required. Valid country code (AU, NZ, MY, SG, US, UK etc...)
--					@LoadType:		Required. Valid values (Full, Delta, Test Full, Test Delta)
--									If value is Full, the output is all accounts.
--									If value is Delta, the output is all new/amended accounts. 
--									If value is Test Full, the output is all 1000 test accounts.
--									If value is Test Delta, the output is the account that is passed in @UniqueIdentifier parameter.
--					@DateRange:		Required. Standard date range or _User Defined. Default value 'Last Hour'
--					@StartDate:		Optional. Only enter if DateRange = _User Defined. Format: yyyy-mm-dd hh:mm:ss (eg. 2018-01-01 10:59:00)
--					@EndDate:		Optional. Only enter if DateRange = _User Defined. Format: yyyy-mm-dd hh:mm:ss (eg. 2018-01-01 11:59:00)
--					@UniqueIdentifier: Optional. Valid UniqueIdentifier value. Eg. AU.CMA.AAN2400
--  
--  Change History: 20180515 - LT - Created
--					20180530 - RS - Delta load process window
--					20180621 - LT - added isSynced is null to all WHERE clauses
--                  
/****************************************************************************************************/

--uncomment to debug
/*
declare @CountryCode varchar(3), @LoadType varchar(50), @DateRange varchar(30), @StartDate datetime, @EndDate datetime, @UniqueIdentifier varchar(50)
select @CountryCode = 'AU', @LoadType = 'Test Delta', @DateRange = 'Last Hour', @StartDate = null, @EndDate = null, @UniqueIdentifier =  'AU.CMA.AAN2400'
*/

declare @rptStartDate datetime
declare @rptEndDate datetime

/* get reporting dates */
if @DateRange = '_User Defined'
    select 
        @rptStartDate = @StartDate, 
        @rptEndDate = @EndDate            
else
    select 
        @rptStartDate = StartDate, 
        @rptEndDate = EndDate
    from 
        vDateRange
    where 
        DateRange = @DateRange


if @LoadType = 'Full'
begin
	select
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
		[AccountType]
	from 
		[db-au-ods].dbo.scrmAccount a
	where
		isSynced is null
	order by 1
end
else if @LoadType = 'Delta'
begin
	select
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
		[AccountType]
	from 
		[db-au-workspace].dbo.scrmAccount_UAT a
	where 
		((
			a.LoadDate >= @rptStartDate and
			a.LoadDate <= @rptEndDate 
		) or
		(
			a.UpdateDate >= @rptStartDate and
			a.UpdateDate <= @rptEndDate 
		)) and
		a.isSynced is null
	order by 2
end
else if @LoadType = 'Test Full'
begin
	select
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
		[AccountType]
	from 
		[db-au-ods].dbo.scrmAccount a
	where
		[UniqueIdentifier] in (select [UniqueIdentifier] from dbo.scrmTestAccount) and
		isSynced is null
	order by 1
end
else if @LoadType = 'Test Delta'
begin
	select
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
		[AccountType]
	from 
		[db-au-ods].dbo.scrmAccount a
	where 
		[UniqueIdentifier] = @UniqueIdentifier and
		isSynced is null
end





GO
