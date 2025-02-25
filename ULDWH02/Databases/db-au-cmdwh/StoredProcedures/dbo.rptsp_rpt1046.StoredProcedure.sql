USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1046]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt1046]   
	@DateRange varchar(30),
	@StartDate varchar(10),
	@EndDate varchar(10)
as

SET NOCOUNT ON

/****************************************************************************************************/
--  Name:           rptsp_rpt1046
--  Author:         Mercede
--  Date Created:   20180307
--  Description:    This stored procedure returns ETI Customer details who got a quote, but didn't purchase a policy
--  Parameters:     @DateRange: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2016-01-01
--					@EndDate  : if_User Defined. Format: YYYY-MM-DD eg. 2016-01-01
--   
--  Change History: 20180307 - SD - Created
--					20180309 - SD - Removed MBN0011 agency, as requested by Kristin Browning
--					20180312 - SD - Included Non-members in the report as well, as requested by Kristin Browning
--					20180319 - SD - Included new columns QuoteNumber, DOB, Destination, DepartureDate and ReturnDate
--					20180321 - SD - Included AddOnFlag columns for EMC, Winter Sports, Cancellation, Cruise, Motorcycle and Luggage
--					20180416 - SD - Additonal filtered on duplicate entries on same day, also removed records with no full names
--					20180717 - SD - Included new field 'State', and also combined penguin and impulse quotes   
--					20180803 - SD - Changed the high premium quotes from $500 to $200    
--					20180808 - SD - Include Age value in web quotes   
--					20180828 - SD - Additional check on QuoteCustomerID from penPolicyTraveller, as checking policykey in penQuote is not fully accurate method to check whether policy is purchased against a quote      
--					20181009 - SD - SP will now fetch impulse quotes from GCP, instead of archived seesions in BHDWH03

--					20190130 - ME - Created: Duplicated for Easy Travel Insurance
--					20190204 - ME - Added full address and gross from impuls 
/****************************************************************************************************/

--DECLARE
--	@DateRange varchar(30),
--	@StartDate varchar(10),
--	@EndDate varchar(10)
--SET @DateRange = 'Month-To-Date'

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
	--a.MemberNumber,
	a.Title,
	a.FirstName,
	a.LastName,
	a.DOB,
	a.Age,
	a.HomePhone,
	a.WorkPhone,
	a.MobilePhone,
	a.EmailAddress,
	--change the optincontact to always 1, as it is a mandatory field now
	1 OptFurtherContact,
	--a.OptFurtherContact,
	a.AddressLine1,
	a.AddressLine2,
	NULL AS Suburb,
	a.State,
	a.Postcode,
	a.AlphaCode,
	a.OutletName,
	convert(varchar, a.QuoteNumber) QuoteNumber,
	a.Destination,
	a.DepartureDate,
	a.ReturnDate,
	a.QuoteDate,	
	a.GrossPremium	AS [Quote Value],
	a.EMCAddOnFlag,
	a.CancellationAddOnFlag,
	a.WinterSportAddOnFlag,
	a.CruiseAddOnFlag,
	a.LuggageAddOnFlag,
	a.MotorcycleAddOnFlag,
	a.RentalCarAddOnFlag,
	a.StartDate,
	a.EndDate
From
(
	select
		distinct
		--pc.MemberNumber,
		pc.Title,
		pc.FirstName,
		pc.LastName,
		pc.DOB,
		pqc.Age,
		pc.HomePhone,
		pc.WorkPhone,
		pc.MobilePhone,
		pc.EmailAddress,
		pc.OptFurtherContact,
		pc.AddressLine1,
		pc.AddressLine2,		 
		pc.State,
		pc.PostCode,
		po.AlphaCode,
		po.OutletName,
		pq.QuoteID [QuoteNumber],
		pq.Destination,
		pq.DepartureDate,
		pq.ReturnDate,
		pq.CreateDate [QuoteDate],		
		pq.GrossPremium, 
		Case 
			When EMCID is not null then 'Yes'
			Else 'No'
		End EMCAddOnFlag,
		Case
			When CancellationAddOnCount >= 1 then 'Yes'
			Else 'No'
		End CancellationAddOnFlag,
		Case
			When WinterSportAddOnCount >= 1 then 'Yes'
			Else 'No'
		End WinterSportAddOnFlag,
		Case
			When CruiseAddOnCount >= 1 then 'Yes'
			Else 'No'
		End CruiseAddOnFlag,
		Case
			When LuggageAddOnCount >= 1 then 'Yes'
			Else 'No'
		End LuggageAddOnFlag,
		Case
			When MotorcycleAddOnCount >= 1 then 'Yes'
			Else 'No'
		End MotorcycleAddOnFlag,
		'No' RentalCarAddOnFlag,
		@rptStartDate [StartDate],
		@rptEndDate [EndDate]
	from 
		penQuote pq
		inner join penQuoteCustomer pqc
						on pq.QuoteCountryKey = pqc.QuoteCountryKey
		inner join penCustomer pc
						on pc.CustomerKey = pqc.CustomerKey
		inner join penOutlet po
						on po.OutletAlphaKey = pq.OutletAlphaKey
		Outer Apply
		(
			Select
				Count(*) CancellationAddOnCount
			From
				penQuoteAddOn pqa
			Where
				pqa.QuoteCountryKey = pq.QuoteCountryKey
				and pqa.CustomerKey = pc.CustomerKey
				and pqa.AddOnGroup = 'Cancellation'
		) AddOnCancellation
		Outer Apply
		(
			Select
				Count(*) WinterSportAddOnCount
			From
				penQuoteAddOn pqa
			Where
				pqa.QuoteCountryKey = pq.QuoteCountryKey
				and pqa.CustomerKey = pc.CustomerKey
				and pqa.AddOnGroup = 'Winter Sport'
		) AddOnWinterSport
		Outer Apply
		(
			Select
				Count(*) CruiseAddOnCount
			From
				penQuoteAddOn pqa
			Where
				pqa.QuoteCountryKey = pq.QuoteCountryKey
				and pqa.CustomerKey = pc.CustomerKey
				and pqa.AddOnGroup = 'Cruise'
		) AddOnCruise
		Outer Apply
		(
			Select
				Count(*) LuggageAddOnCount
			From
				penQuoteAddOn pqa
			Where
				pqa.QuoteCountryKey = pq.QuoteCountryKey
				and pqa.CustomerKey = pc.CustomerKey
				and pqa.AddOnGroup = 'Luggage'
		) AddOnLuggage
		Outer Apply
		(
			Select
				Count(*) MotorcycleAddOnCount
			From
				penQuoteAddOn pqa
			Where
				pqa.QuoteCountryKey = pq.QuoteCountryKey
				and pqa.CustomerKey = pc.CustomerKey
				and pqa.AddOnGroup = 'Motorcycle'
		) AddOnMotorcycle
		Outer Apply
		(
			select
				Top 1
				pqe.EMCID
			From
				penQuoteEMC pqe
			Where
				pqe.QuoteCountryKey = pq.QuoteCountryKey
				and pqe.EMCID is not null
				and pqe.EMCID <> ''
		) EMC
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
				and pt1.CompanyKey = 'CM'
		) pt1
	where 
		pq.CreateDate >= @rptStartDate 
		and pq.CreateDate < dateadd(day, 1, @rptEndDate)
		and po.OutletStatus = 'Current' 
		and po.GroupName = 'Easy Travel Insurance'
		--and pq.GrossPremium >= 200
		and pqc.isPrimary = 1
		and pq.PolicyKey is null
		--and po.AlphaCode <> 'MBN0011'
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
		Outer Apply
		(
			Select
				Count(*) CancellationAddOnCount
			From
				penQuoteAddOn pqa
			Where
				pqa.QuoteCountryKey = pq.QuoteCountryKey
				and pqa.CustomerKey = pc.CustomerKey
				and pqa.AddOnGroup = 'Cancellation'
		) AddOnCancellation
		Outer Apply
		(
			Select
				Count(*) WinterSportAddOnCount
			From
				penQuoteAddOn pqa
			Where
				pqa.QuoteCountryKey = pq.QuoteCountryKey
				and pqa.CustomerKey = pc.CustomerKey
				and pqa.AddOnGroup = 'Winter Sport'
		) AddOnWinterSport
		Outer Apply
		(
			Select
				Count(*) CruiseAddOnCount
			From
				penQuoteAddOn pqa
			Where
				pqa.QuoteCountryKey = pq.QuoteCountryKey
				and pqa.CustomerKey = pc.CustomerKey
				and pqa.AddOnGroup = 'Cruise'
		) AddOnCruise
		Outer Apply
		(
			Select
				Count(*) LuggageAddOnCount
			From
				penQuoteAddOn pqa
			Where
				pqa.QuoteCountryKey = pq.QuoteCountryKey
				and pqa.CustomerKey = pc.CustomerKey
				and pqa.AddOnGroup = 'Luggage'
		) AddOnLuggage
		Outer Apply
		(
			Select
				Count(*) MotorcycleAddOnCount
			From
				penQuoteAddOn pqa
			Where
				pqa.QuoteCountryKey = pq.QuoteCountryKey
				and pqa.CustomerKey = pc.CustomerKey
				and pqa.AddOnGroup = 'Motorcycle'
		) AddOnMotorcycle
		Outer Apply
		(
			select
				Top 1
				pqe.EMCID
			From
				penQuoteEMC pqe
			Where
				pqe.QuoteCountryKey = pq.QuoteCountryKey
				and pqe.EMCID is not null
				and pqe.EMCID <> ''
		) EMC
	where 
		pq.CreateDate >= @rptStartDate 
		and pq.CreateDate < dateadd(day, 1, @rptEndDate)
		and po.OutletStatus = 'Current' 
		and po.GroupName = 'Easy Travel Insurance'
		--and pq.GrossPremium >= 200
		and pqc.isPrimary = 1
		and pq.PolicyKey is null
		--and po.AlphaCode <> 'MBN0011'
		and pc.FirstName is not null
		and	pc.LastName is not null
		and pc.FirstName <> ''
		and pc.LastName <> ''
		--and pc.MemberNumber = a.MemberNumber
		and pc.FirstName = a.FirstName
		and pc.LastName = a.LastName
		and pc.DOB = a.DOB
		and pq.CreateDate = a.QuoteDate
	Order By
		pq.QuoteID Desc
) b
Where
	a.QuoteNumber = b.QuoteNumber

Union


select 
	--MemberNumber,
	Title,
	FirstName,
	Lastname,
	DOB,
	Age,
	HomePhone,
	WorkPhone,
	MobilePhone,
	EmailAddress,
	OptFurtherContact,
	Street1,
	Street2,
	Suburb,
	State,
	Postcode,
	AlphaCode,
	OutletName,
	QuoteNumber,
	Destination,
	DepartureDate,
	ReturnDate,
	QuoteDate,
	Gross,
	EMCAddOnFlag,
	CancellationAddOnFlag,
	WinterSportAddOnFlag,
	CruiseAddOnFlag,
	LuggageAddonFlag,
	MotorcycleAddonFlag,
	RentalCarAddOnFlag,
	@rptStartDate [StartDate],
	@rptEndDate [EndDate]
from 
	[bhdwh03].[db-au-cmdwh].dbo.vETIQuotes
where
	QuoteDate between @rptStartDate and dateadd(day, 1, @rptEndDate)
GO
