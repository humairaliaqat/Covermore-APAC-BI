USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1055]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt1055]   
	@DateRange varchar(30),
	@StartDate varchar(10),
	@EndDate varchar(10)
as

SET NOCOUNT ON

/****************************************************************************************************/
--  Name:           rptsp_rpt1055
--  Author:         Saurabh Date
--  Date Created:   20190304
--  Description:    This stored procedure returns Medibank travel Quote details for CRM Integration
--  Parameters:     @DateRange: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2016-01-01
--					@EndDate  : if_User Defined. Format: YYYY-MM-DD eg. 2016-01-01
--   
--  Change History: 20190304 - SD - Created
--					20190429 - SD - Changed CountryCOdePhone field from '+61' to 'AU'
/****************************************************************************************************/

--DECLARE
--	@DateRange varchar(30),
--	@StartDate varchar(10),
--	@EndDate varchar(10)
--SET @DateRange = 'Yesterday'

declare @rptStartDate date
declare @rptEndDate date


--get reporting dates
if @DateRange = '_User Defined'
	select @rptStartDate = @StartDate,
		   @rptEndDate = @EndDate
else
	select @rptStartDate = StartDate, 
		   @rptEndDate = EndDate
	from vDateRange
	where DateRange = @DateRange



Select
	convert(varchar, a.QuoteNumber) PolicyNumber, -- This will be called as PolicyNumber, as Medibank team requested it and they will update it as Policy or Quote Number in their CRM
	'' BPID, --Keeping the field blank as requested by Medibank
	a.Title,
	a.FirstName,
	'' MiddleName, --Keeping the field blank as requested by Medibank
	a.LastName,
	convert(varchar, a.DOB, 104) DOB,
	isNull(a.AddressLine1,'') Street1, 
	isNull(a.AddressLine2,'') Street2, 
	isNull(a.Town,'') City,
	isNull(a.State,'') State,
	isNull(a.PostCode, '') PostCode, 
	'AU' Country, --Default to 'AU', as requested by Medibank
	a.EmailAddress,
	'AU' CountryCodePhone, -- Default to 'AU', as requested by Medibank
	isnull(a.HomePhone, '') HomePhone,
	isnull(a.WorkPhone, '') WorkPhone,
	isnull(a.MobilePhone, '') MobilePhone,
	a.TripType,
	a.Destination,
	convert(varchar, a.DepartureDate, 104) DepartureDate,
	convert(varchar, a.ReturnDate, 104) ReturnDate,
	a.NumberofAdults,
	a.NumberOfChildren,
	'Quote' PolicyStatus, -- Default to 'Quote', as requested by Medibank
	a.[Quote value] [Premium],
	a.Excess,
	convert(varchar, a.QuoteDate, 104) [StartDate],
	a.StartDate [ReportingStartDate],
	a.EndDate [ReportingEndDate]
From
(
	select
		distinct
		pc.MemberNumber,
		pc.Title,
		pc.FirstName,
		pc.LastName,
		pc.DOB,
		pqc.Age,
		pc.HomePhone,
		pc.WorkPhone,
		pc.MobilePhone,
		pc.EmailAddress,
		--pc.OptFurtherContact,
		pc.State,
		--po.AlphaCode,
		--po.OutletName,
		pq.QuoteID [QuoteNumber],
		pq.Destination,
		pq.DepartureDate,
		pq.ReturnDate,
		pq.CreateDate [QuoteDate],
		pq.GrossPremium [Quote value],
		@rptStartDate [StartDate],
		@rptEndDate [EndDate],
		pq.PlanType TripType,
		pq.NumberofAdults,
		pq.NumberOfChildren,
		pq.Excess,
		pc.AddressLine1,
		pc.AddressLine2,
		pc.PostCode,
		pc.Town
	from 
		penQuote pq
		inner join penQuoteCustomer pqc
						on pq.QuoteCountryKey = pqc.QuoteCountryKey
		inner join penCustomer pc
						on pc.CustomerKey = pqc.CustomerKey
		inner join penOutlet po
						on po.OutletAlphaKey = pq.OutletAlphaKey
		--Check QuoteCustomerID from penPolicyTraveller, as checking policykey in penQuote is not fully accurate method to check whether policy is purchased against a quote
		outer apply
		(
			select
				pt1.QuoteCustomerID
			From
				penPolicyTraveller pt1
			Where
				pt1.QuoteCustomerid = pqc.QuoteCustomerID
				and pt1.CountryKey = 'AU'
				and pt1.CompanyKey = 'TIP'
		) pt1
	where 
		pq.CreateDate >= @rptStartDate 
		and pq.CreateDate < dateadd(day, 1, @rptEndDate)
		and po.OutletStatus = 'Current' 
		and po.GroupName = 'Medibank'
		and pqc.isPrimary = 1
		and pq.PolicyKey is null
		and pc.FirstName is not null
		and	pc.LastName is not null
		and pc.FirstName <> ''
		and pc.LastName <> ''
		and pt1.QuoteCustomerID is null
) a
outer apply
(
	select
		Top 1
		pq.QuoteID [QuoteNumber]
	from 
		penQuote pq
		inner join penQuoteCustomer pqc
						on pq.QuoteCountryKey = pqc.QuoteCountryKey
		inner join penCustomer pc
						on pc.CustomerKey = pqc.CustomerKey
		inner join penOutlet po
						on po.OutletAlphaKey = pq.OutletAlphaKey
	where 
		pq.CreateDate >= @rptStartDate 
		and pq.CreateDate < dateadd(day, 1, @rptEndDate)
		and po.OutletStatus = 'Current' 
		and po.GroupName = 'Medibank'
		and pqc.isPrimary = 1
		and pq.PolicyKey is null
		and pc.FirstName is not null
		and	pc.LastName is not null
		and pc.FirstName <> ''
		and pc.LastName <> ''
		and pc.MemberNumber = a.MemberNumber
		and upper(pc.FirstName) = upper(a.FirstName)
		and upper(pc.LastName) = upper(a.LastName)
		and pq.CreateDate = a.QuoteDate
	Order By
		pq.QuoteID Desc
) b
Where
	a.QuoteNumber = b.QuoteNumber

Union


select 
	QuoteNumber  PolicyNumber, -- This will be called as PolicyNumber, as Medibank team requested it and they will update it as Policy or Quote Number in their CRM
	'' BPID, --Keeping the field blank as requested by Medibank
	Title,
	FirstName,
	'' MiddleName, --Keeping the field blank as requested by Medibank
	Lastname,
	convert(varchar, DOB, 104) DOB,
	Street1,
	Street2,
	City,
	State,
	PostCode,
	'AU' Country, --Default to 'AU', as requested by Medibank
	EmailAddress,
	'AU' CountryCodePhone, --Default to 'AU', as requested by Medibank
	isnull(HomePhone, '') HomePhone,
	isnull(WorkPhone, '') WorkPhone,
	isnull(MobilePhone, '') MobilePhone,
	TripType,
	Destination,
	convert(varchar, DepartureDate, 104) DepartureDate,
	convert(varchar, ReturnDate, 104) ReturnDate,
	NumberofAdults,
	NumberofChildren,
	'Quote' PolicyStatus, -- Default to 'Quote', as requested by Medibank
	[Quote value] Premium,
	Excess,
	convert(varchar, QuoteDate, 104) [StartDate],
	@rptStartDate [ReportingStartDate],
	@rptEndDate [ReportingEndDate]
from 
	[bhdwh03].[db-au-cmdwh].dbo.vMedibankQuotes
where
	QuoteDate between @rptStartDate and dateadd(day, 1, @rptEndDate)
GO
