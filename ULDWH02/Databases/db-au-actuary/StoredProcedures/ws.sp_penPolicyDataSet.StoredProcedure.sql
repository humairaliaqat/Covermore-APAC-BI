USE [db-au-actuary]
GO
/****** Object:  StoredProcedure [ws].[sp_penPolicyDataSet]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [ws].[sp_penPolicyDataSet] @DateRange varchar(30),
										@StartDate varchar(10),
										@EndDate varchar(10)
as

SET NOCOUNT ON

/****************************************************************************************************/
--  Name:           ws.sp_penPolicyDataSet
--  Author:         Linus Tor
--  Date Created:   20171023
--  Description:    This stored procedure inserts [db-au-cmdwh].dbo.penPolicy data into [db-au-actuary].[ws].[penPolicy]
--
--  Parameters:     @DateRange: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--					@EndDate: if_User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--   
--  Change History: 20171023 - LT - Created
--                  
/****************************************************************************************************/

--uncomment to debug
/*
declare @DateRange varchar(30), @StartDate varchar(10), @EndDate varchar(10)
select @DateRange = '_User Defined', @StartDate = '2015-07-01', @EndDate = '2015-07-01'
*/

declare @rptStartDate date
declare @rptEndDate date

--get reporting dates
if @DateRange = '_User Defined'
	select @rptStartDate = @StartDate,
		   @rptEndDate = @EndDate
else
	select @rptStartDate = StartDate, 
		   @rptEndDate = EndDate
	from [db-au-cmdwh].dbo.vDateRange
	where DateRange = @DateRange

	
--create penPolicy table and populate with data from 01/07/2015 to 30/06/2017
if object_id('[db-au-actuary].ws.penPolicy') is null
begin
	create table ws.penPolicy
	(
		[CountryKey] [varchar](2) NOT NULL,
		[CompanyKey] [varchar](5) NOT NULL,
		[OutletAlphaKey] [nvarchar](50) NULL,
		[OutletSKey] [bigint] NULL,
		[PolicyKey] [varchar](41) NULL,
		[PolicyNoKey] [varchar](100) NULL,
		[PolicyID] [int] NOT NULL,
		[PolicyNumber] [varchar](50) NULL,
		[AlphaCode] [nvarchar](60) NULL,
		[IssueDate] [datetime] NOT NULL,
		[IssueDateNoTime] [datetime] NOT NULL,
		[CancelledDate] [datetime] NULL,
		[StatusCode] [int] NULL,
		[StatusDescription] [nvarchar](50) NULL,
		[Area] [nvarchar](100) NULL,
		[PrimaryCountry] [nvarchar](max) NULL,
		[TripStart] [datetime] NULL,
		[TripEnd] [datetime] NULL,
		[AffiliateReference] [nvarchar](200) NULL,
		[HowDidYouHear] [nvarchar](200) NULL,
		[AffiliateComments] [varchar](500) NULL,
		[GroupName] [nvarchar](100) NULL,
		[CompanyName] [nvarchar](100) NULL,
		[PolicyType] [nvarchar](50) NULL,
		[isCancellation] [bit] NOT NULL,
		[ProductID] [int] NOT NULL,
		[ProductCode] [nvarchar](50) NULL,
		[ProductName] [nvarchar](50) NULL,
		[ProductDisplayName] [nvarchar](50) NULL,
		[UniquePlanID] [int] NOT NULL,
		[Excess] [money] NOT NULL,
		[AreaName] [nvarchar](100) NULL,
		[PolicyStart] [datetime] NOT NULL,
		[PolicyEnd] [datetime] NOT NULL,
		[DaysCovered] [int] NULL,
		[MaxDuration] [int] NULL,
		[PlanName] [nvarchar](50) NULL,
		[TripType] [nvarchar](50) NULL,
		[PlanID] [int] NULL,
		[PlanDisplayName] [nvarchar](100) NULL,
		[CancellationCover] [nvarchar](50) NULL,
		[TripCost] [nvarchar](50) NULL,
		[TripDuration] [int] NULL,
		[EmailConsent] [bit] NULL,
		[AreaType] [varchar](25) NULL,
		[PurchasePath] [nvarchar](50) NULL,
		[IsShowDiscount] [bit] NULL,
		[ExternalReference] [nvarchar](100) NULL,
		[DomainKey] [varchar](41) NULL,
		[DomainID] [int] NULL,
		[IssueDateUTC] [datetime] NULL,
		[IssueDateNoTimeUTC] [datetime] NULL,
		[AreaNumber] [varchar](20) NULL,
		[isTripsPolicy] [int] NULL,
		[ImportDate] [datetime] NULL,
		[PreviousPolicyNumber] [varchar](50) NULL,
		[CurrencyCode] [varchar](3) NULL,
		[CultureCode] [nvarchar](20) NULL,
		[AreaCode] [nvarchar](3) NULL,
		[TaxInvoiceNumber] [nvarchar](50) NULL,
		[MultiDestination] [nvarchar](max) NULL,
		[FinanceProductID] [int] NULL,
		[FinanceProductCode] [nvarchar](10) NULL,
		[FinanceProductName] [nvarchar](125) NULL,
		[InitialDepositDate] [date] NULL,
		[PlanCode] [nvarchar](50) NULL
	) 
    create clustered index idx_penPolicy_PolicyKey on [db-au-actuary].ws.penPolicy(PolicyKey)
    create nonclustered index idx_penPolicy_AlphaCode on [db-au-actuary].ws.penPolicy(AlphaCode)
    create nonclustered index idx_penPolicy_ExternalReference on [db-au-actuary].ws.penPolicy(ExternalReference)
    create nonclustered index idx_penPolicy_ImportDate on [db-au-actuary].ws.penPolicy(ImportDate)
    create nonclustered index idx_penPolicy_IssueDate on [db-au-actuary].ws.penPolicy(IssueDate,StatusDescription) include (OutletAlphaKey,PolicyKey)
    create nonclustered index idx_penPolicy_OutletAlphaKey on [db-au-actuary].ws.penPolicy(OutletAlphaKey) include (PolicyKey,PolicyNumber,AffiliateReference,ProductCode,ProductName)
    create nonclustered index idx_penPolicy_OutletSKey on [db-au-actuary].ws.penPolicy(OutletSKey)
    create nonclustered index idx_penPolicy_PolicyID on [db-au-actuary].ws.penPolicy(PolicyID)
    create nonclustered index idx_penPolicy_PolicyNoKey on [db-au-actuary].ws.penPolicy(PolicyNoKey)
    create nonclustered index idx_penPolicy_PolicyNumber on [db-au-actuary].ws.penPolicy(PolicyNumber,AlphaCode,CountryKey)
    create nonclustered index idx_penPolicy_TravelDates on [db-au-actuary].ws.penPolicy(TripStart,TripEnd)
end


--populate policy data
insert into [db-au-actuary].ws.penPolicy with (tablockx)
(
	[CountryKey],
	[CompanyKey],
	[OutletAlphaKey],
	[OutletSKey],
	[PolicyKey],
	[PolicyNoKey],
	[PolicyID],
	[PolicyNumber],
	[AlphaCode],
	[IssueDate],
	[IssueDateNoTime],
	[CancelledDate],
	[StatusCode],
	[StatusDescription],
	[Area],
	[PrimaryCountry],
	[TripStart],
	[TripEnd],
	[AffiliateReference],
	[HowDidYouHear],
	[AffiliateComments],
	[GroupName],
	[CompanyName],
	[PolicyType],
	[isCancellation],
	[ProductID],
	[ProductCode],
	[ProductName],
	[ProductDisplayName],
	[UniquePlanID],
	[Excess],
	[AreaName],
	[PolicyStart],
	[PolicyEnd],
	[DaysCovered],
	[MaxDuration],
	[PlanName],
	[TripType],
	[PlanID],
	[PlanDisplayName],
	[CancellationCover],
	[TripCost],
	[TripDuration],
	[EmailConsent],
	[AreaType],
	[PurchasePath],
	[IsShowDiscount],
	[ExternalReference],
	[DomainKey],
	[DomainID],
	[IssueDateUTC],
	[IssueDateNoTimeUTC],
	[AreaNumber],
	[isTripsPolicy],
	[ImportDate],
	[PreviousPolicyNumber],
	[CurrencyCode],
	[CultureCode],
	[AreaCode],
	[TaxInvoiceNumber],
	[MultiDestination],
	[FinanceProductID],
	[FinanceProductCode],
	[FinanceProductName],
	[InitialDepositDate],
	[PlanCode]
)
select
	[CountryKey],
	[CompanyKey],
	[OutletAlphaKey],
	[OutletSKey],
	[PolicyKey],
	[PolicyNoKey],
	[PolicyID],
	[PolicyNumber],
	[AlphaCode],
	[IssueDate],
	[IssueDateNoTime],
	[CancelledDate],
	[StatusCode],
	[StatusDescription],
	[Area],
	[PrimaryCountry],
	[TripStart],
	[TripEnd],
	[AffiliateReference],
	[HowDidYouHear],
	[AffiliateComments],
	[GroupName],
	[CompanyName],
	[PolicyType],
	[isCancellation],
	[ProductID],
	[ProductCode],
	[ProductName],
	[ProductDisplayName],
	[UniquePlanID],
	[Excess],
	[AreaName],
	[PolicyStart],
	[PolicyEnd],
	[DaysCovered],
	[MaxDuration],
	[PlanName],
	[TripType],
	[PlanID],
	[PlanDisplayName],
	[CancellationCover],
	[TripCost],
	[TripDuration],
	[EmailConsent],
	[AreaType],
	[PurchasePath],
	[IsShowDiscount],
	[ExternalReference],
	[DomainKey],
	[DomainID],
	[IssueDateUTC],
	[IssueDateNoTimeUTC],
	[AreaNumber],
	[isTripsPolicy],
	[ImportDate],
	[PreviousPolicyNumber],
	[CurrencyCode],
	[CultureCode],
	[AreaCode],
	[TaxInvoiceNumber],
	[MultiDestination],
	[FinanceProductID],
	[FinanceProductCode],
	[FinanceProductName],
	[InitialDepositDate],
	[PlanCode]
from
    [db-au-cmdwh].dbo.penPolicy
where
	CountryKey = 'AU' and
	IssueDate >= @rptStartDate and
	IssueDate < dateadd(d,1,@rptEndDate)

GO
