USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1055_RecordCount]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt1055_RecordCount]   
	@DateRange varchar(30),
	@StartDate varchar(10),
	@EndDate varchar(10)
as

SET NOCOUNT ON

/****************************************************************************************************/
--  Name:           rptsp_rpt1055_recordCount
--  Author:         Saurabh Date
--  Date Created:   20190304
--  Description:    This stored procedure returns Medibank traveller Quote record count for CRM Integration
--  Parameters:     @DateRange: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2016-01-01
--					@EndDate  : if_User Defined. Format: YYYY-MM-DD eg. 2016-01-01
--   
--  Change History: 20190304 - SD - Created
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

	(Select
		count(*)
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
		--and a.[Quote value] > 0
	)
	+
	(
	select 
		count(*)
	from 
		[bhdwh03].[db-au-cmdwh].dbo.vMedibankQuotes
	where
		QuoteDate between @rptStartDate and dateadd(day, 1, @rptEndDate)
	)

	[Total records]
GO
