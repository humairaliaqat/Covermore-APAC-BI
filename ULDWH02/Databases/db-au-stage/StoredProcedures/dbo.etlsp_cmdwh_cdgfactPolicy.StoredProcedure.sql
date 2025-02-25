USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_cdgfactPolicy]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_cdgfactPolicy]
as

SET NOCOUNT ON


/************************************************************************************************************************************
Author:         Linus Tor
Date:           20180227
Prerequisite:   Requires ETL043_CDGQuote agent job successfully run
Description:    Innate Impulse2 version 2 fact policy table denormalisation, and load data to [db-au-cmdwh].dbo.cdgfactPolicy
Change History:
                20180227 - LT - Procedure created
						
*************************************************************************************************************************************/


if object_id('[db-au-stage].dbo.etl_cdgfactPolicy') is not null drop table [db-au-stage].dbo.etl_cdgfactPolicy

select
	q.factPolicyID,
	q.PolicyNumber,
	q.SessionID,
	q.RegionID,
	q.CampaignID,
	q.ImpulseOfferID,
	qDate.PolicyIssueDate,
	qTime.PolicyIssueTime,
	convert(datetime, qDate.PolicyIssueDate + ' ' + qTime.PolicyIssueTime) as PolicyIssueDateTime,
	r.AreaCode,
	r.AreaType,
	r.RiskRank,
	r.RegionName,
	q.ProductID,
	pr.ProductCode,
	pr.PlanCode,
	pr.ProductName,
	pr.TripType,
	pr.SingleFamilyDuo,
	promo.PromoCode,
	promo.PromoType,
	cam.CampaignName,
	q.BusinessUnitID,
	bu.Domain,
	bu.BusinessUnitName,
	bu.[Partner],
	alpha.AffiliateCode,
	bu.CurrencyCode,
	destcm.Destination,
	multidest.MultiDestination,
	tripSD.TripStart,
	tripED.TripEnd,
	q.Excess,
	q.MemberPointsAwarded,
	q.hasCANX,
	q.HasWNTS,
	q.HasCRS,
	q.HasLUGG,
	q.HasRTCR,
	q.HasEMC,
	q.isDiscounted,
	q.TotalGrossPremium,
	q.TotalDiscountedGrossPremium,
	q.CANXCoverageAmount,
	q.RTCRCoverageAmount,
	q.ActualPaymentType,
	q.PaymentReferenceNumber,
	q.TripDuration,
	q.HasMTCL,
	departCountry.DepartureCountry,
	departAirport.AirportName,
	const.ConstructName,
	const.MinAdults,
	const.MaxAdults,
	const.MinChildren,
	const.MaxChildren,
	const.DestinationType,
	const.[Priority],
	const.CarRental,
	const.CheckedBags,
	const.BookedHotel,
	const.AdvancedPurchase,
	const.MemberLevel,
	const.PaidWithPoints,
	const.TravelClass
into [db-au-stage].dbo.etl_cdgfactPolicy
from
	cdg_factPolicy_AU q
	outer apply
	(
		select top 1 af.AffiliateCode
		from 
			cdg_factSession_AU se
			outer apply
			(
				select top 1 AffiliateCode
				from cdg_dimAffiliateCode_AU 
				where DimAffiliateCodeID = se.AffiliateCodeID
			) af
		where 
			se.factSessionID = q.SessionID and
			se.BusinessUnitID = q.BusinessUnitID
	) alpha
	outer apply
	(
		select top 1
			ConstructName,
			TripType,
			MinAdults,
			MaxAdults,
			MinChildren,
			MaxChildren,
			DestinationType,
			[Priority],
			CarRental,
			CheckedBags,
			BookedHotel,
			AdvancedPurchase,
			MemberLevel,
			PaidWithPoints,
			TravelClass
		from cdg_DimConstruct_AU
		where dimConstructID = q.ConstructID
	) const
	outer apply
	(
		select top 1 AirportName
		from cdg_dimAirport_AU
		where DimAirportID = q.DepartureAirportID
	) departAirport

	outer apply
	(
		select top 1 CovermoreCountryName as DepartureCountry
		from cdg_dimCovermoreCountry_AU
		where DimCovermoreCountryID = q.DepartureCountryID
	) departCountry
	outer apply
	(
		select top 1 [Date] as PolicyIssueDate
		from dbo.cdg_dimDate_AU 
		where DimDateID = q.PolicyIssuedDateID
	) qdate
	outer apply
	(
		select top 1 [Time] as PolicyIssueTime
		from dbo.cdg_dimTime_AU 
		where dimTimeID = q.PolicyIssuedTimeID
	) qtime
	outer apply
	(
		select top 1 [Date] as TripStart
		from dbo.cdg_dimDate_AU
		where DimDateID = q.TripStartDateID
	) tripSD
	outer apply
	(
		select top 1 [Date] as TripEnd
		from dbo.cdg_dimDate_AU
		where DimDateID = q.TripEndDateID
	) tripED
	outer apply
	(
		select top 1 MultiDestination
		from [db-au-cmdwh].dbo.cdgdimMultiDestination
		where dimCovermoreCountryListID = q.DestCovermoreCountryListID
	) multidest
	outer apply
	(
		select top 1 PromoCode, PromoType
		from [db-au-cmdwh].dbo.cdgdimPromotion
		where dimPromoCodeListID = q.PromoCodeListID
	) promo
	outer apply
	(
		select top 1
			case when DestinationType = 'I' then 'International'
				 when DestinationType = 'D' then 'Domestic'
				 when DestinationType = 'D' then 'Domestic Inbound'
				 else 'NOT SET'
			end as AreaType,
			AreaCode,
			RiskRank,
			RegionName
		from
			cdg_dimRegion_AU
		where
			dimRegionID = q.RegionID
	) r
	outer apply
	(
		select top 1
			ProductCode,
			PlanCode,
			ProductName,
			case when TripFrequency = 'S' then 'Single Trip'
			     when TripFrequency = 'M' then 'Annual Multi Trip'
				 else 'NOT SET'
			end as TripType,
			case when GroupType = 'S' then 'Single'
			     when GroupType = 'F' then 'Family'
				 when GroupType = 'D' then 'Duo'
				 else 'NOT SET'
			end as SingleFamilyDuo
		from
			cdg_DimProduct_AU
		where
			dimProductID = q.ProductID
	) pr
	outer apply
	(
		select top 1 CampaignName
		from cdg_DimCampaign_AU
		where DimCampaignID = q.CampaignID
	) cam
	outer apply
	(
		select top 1 
			Domain,
			BusinessUnitName,
			[Partner],
			Currency as CurrencyCode
		from cdg_dimBusinessUnit_AU
		where dimBusinessUnitID = q.BusinessUnitID
	) bu
	outer apply
	(
		select top 1 ca.CovermoreCountryName as Destination
		from
			cdg_dimCovermoreCountryList_AU cl
			inner join cdg_dimCovermoreCountry_AU ca on 
				cl.CMCountryID1 = ca.dimCovermoreCountryID
		where 
			cl.[DimCovermoreCountryListID] = q.DestCovermoreCountryListID
	) destcm



if object_id('[db-au-cmdwh].dbo.cdgfactPolicy') is null
begin
	create table [db-au-cmdwh].[dbo].[cdgfactPolicy]
	(
		[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
		[factPolicyID] [int] NOT NULL,
		[PolicyNumber] [nvarchar](40) NOT NULL,
		[SessionID] [int] NOT NULL,
		[RegionID] [int] NOT NULL,
		[CampaignID] [int] NOT NULL,
		[ImpulseOfferID] [int] NULL,
		[PolicyIssueDate] [datetime] NULL,
		[PolicyIssueTime] [char](8) NULL,
		[PolicyIssueDateTime] [datetime] NULL,
		[AreaCode] [nvarchar](20) NULL,
		[AreaType] [varchar](16) NULL,
		[RiskRank] [int] NULL,
		[RegionName] [nvarchar](100) NULL,
		[ProductID] [int] NULL,
		[ProductCode] [nvarchar](10) NULL,
		[PlanCode] [nvarchar](10) NULL,
		[ProductName] [nvarchar](100) NULL,
		[TripType] [varchar](17) NULL,
		[SingleFamilyDuo] [varchar](7) NULL,
		[PromoCode] [varchar](8000) NULL,
		[PromoType] [varchar](100) NULL,
		[CampaignName] [varchar](255) NULL,
		[BusinessUnitID] [int] NOT NULL,
		[Domain] [char](2) NULL,
		[BusinessUnitName] [varchar](100) NULL,
		[Partner] [varchar](50) NULL,
		[AffiliateCode] [varchar](50) NULL,
		[CurrencyCode] [char](3) NULL,
		[Destination] [varchar](50) NULL,
		[MultiDestination] [varchar](8000) NULL,
		[TripStart] [datetime] NULL,
		[TripEnd] [datetime] NULL,
		[Excess] [int] NOT NULL,
		[MemberPointsAwarded] [int] NOT NULL,
		[hasCANX] [int] NOT NULL,
		[HasWNTS] [int] NOT NULL,
		[HasCRS] [int] NOT NULL,
		[HasLUGG] [int] NOT NULL,
		[HasRTCR] [int] NOT NULL,
		[HasEMC] [int] NOT NULL,
		[isDiscounted] [int] NOT NULL,
		[TotalGrossPremium] [numeric](18, 2) NULL,
		[TotalDiscountedGrossPremium] [numeric](18, 2) NULL,
		[CANXCoverageAmount] [numeric](18, 2) NULL,
		[RTCRCoverageAmount] [numeric](18, 2) NULL,
		[ActualPaymentType] [nvarchar](10) NULL,
		[PaymentReferenceNumber] [nvarchar](50) NULL,
		[TripDuration] [int] NOT NULL,
		[HasMTCL] [int] NOT NULL,
		[DepartureCountry] [varchar](50) NULL,
		[AirportName] [nvarchar](50) NULL,
		[ConstructName] [varchar](255) NULL,
		[MinAdults] [int] NULL,
		[MaxAdults] [int] NULL,
		[MinChildren] [int] NULL,
		[MaxChildren] [int] NULL,
		[DestinationType] [varchar](2) NULL,
		[Priority] [tinyint] NULL,
		[CarRental] [int] NULL,
		[CheckedBags] [int] NULL,
		[BookedHotel] [int] NULL,
		[AdvancedPurchase] [int] NULL,
		[MemberLevel] [nvarchar](20) NULL,
		[PaidWithPoints] [int] NULL,
		[TravelClass] [nvarchar](20) NULL
	)
	create clustered index idx_cdgfactPolicy_BIRowID on [db-au-cmdwh].dbo.cdgfactPolicy(BIRowID)
	create nonclustered index idx_cdgfactPolicy_factPolicyID on [db-au-cmdwh].dbo.cdgfactPolicy(factPolicyID)
	create nonclustered index idx_cdgfactPolicy_PolicyIssueDate on [db-au-cmdwh].dbo.cdgfactPolicy(PolicyIssueDate) include
	(
		[factPolicyID],
		[SessionID],
		[RegionID],
		[CampaignID],
		[PolicyIssueDateTime],
		[BusinessUnitID],
		[BusinessUnitName],
		[Destination],
		[TripStart],
		[TripEnd],
		[TotalGrossPremium],
		[ProductID]
	)
end
else
	delete a
	from
		[db-au-cmdwh].dbo.cdgfactPolicy a
		inner join etl_cdgfactPolicy b on 
			a.factPolicyID = b.FactPolicyID 

insert [db-au-cmdwh].dbo.cdgfactPolicy with(tablock)
(
	[factPolicyID],
	[PolicyNumber],
	[SessionID],
	[RegionID],
	[CampaignID],
	[ImpulseOfferID],
	[PolicyIssueDate],
	[PolicyIssueTime],
	[PolicyIssueDateTime],
	[AreaCode],
	[AreaType],
	[RiskRank],
	[RegionName],
	[ProductID],
	[ProductCode],
	[PlanCode],
	[ProductName],
	[TripType],
	[SingleFamilyDuo],
	[PromoCode],
	[PromoType],
	[CampaignName],
	[BusinessUnitID],
	[Domain],
	[BusinessUnitName],
	[Partner],
	[AffiliateCode],
	[CurrencyCode],
	[Destination],
	[MultiDestination],
	[TripStart],
	[TripEnd],
	[Excess],
	[MemberPointsAwarded],
	[hasCANX],
	[HasWNTS],
	[HasCRS],
	[HasLUGG],
	[HasRTCR],
	[HasEMC],
	[isDiscounted],
	[TotalGrossPremium],
	[TotalDiscountedGrossPremium],
	[CANXCoverageAmount],
	[RTCRCoverageAmount],
	[ActualPaymentType],
	[PaymentReferenceNumber],
	[TripDuration],
	[HasMTCL],
	[DepartureCountry],
	[AirportName],
	[ConstructName],
	[MinAdults],
	[MaxAdults],
	[MinChildren],
	[MaxChildren],
	[DestinationType],
	[Priority],
	[CarRental],
	[CheckedBags],
	[BookedHotel],
	[AdvancedPurchase],
	[MemberLevel],
	[PaidWithPoints],
	[TravelClass]
)
select
	[factPolicyID],
	[PolicyNumber],
	[SessionID],
	[RegionID],
	[CampaignID],
	[ImpulseOfferID],
	[PolicyIssueDate],
	[PolicyIssueTime],
	[PolicyIssueDateTime],
	[AreaCode],
	[AreaType],
	[RiskRank],
	[RegionName],
	[ProductID],
	[ProductCode],
	[PlanCode],
	[ProductName],
	[TripType],
	[SingleFamilyDuo],
	[PromoCode],
	[PromoType],
	[CampaignName],
	[BusinessUnitID],
	[Domain],
	[BusinessUnitName],
	[Partner],
	[AffiliateCode],
	[CurrencyCode],
	[Destination],
	[MultiDestination],
	[TripStart],
	[TripEnd],
	[Excess],
	[MemberPointsAwarded],
	[hasCANX],
	[HasWNTS],
	[HasCRS],
	[HasLUGG],
	[HasRTCR],
	[HasEMC],
	[isDiscounted],
	[TotalGrossPremium],
	[TotalDiscountedGrossPremium],
	[CANXCoverageAmount],
	[RTCRCoverageAmount],
	[ActualPaymentType],
	[PaymentReferenceNumber],
	[TripDuration],
	[HasMTCL],
	[DepartureCountry],
	[AirportName],
	[ConstructName],
	[MinAdults],
	[MaxAdults],
	[MinChildren],
	[MaxChildren],
	[DestinationType],
	[Priority],
	[CarRental],
	[CheckedBags],
	[BookedHotel],
	[AdvancedPurchase],
	[MemberLevel],
	[PaidWithPoints],
	[TravelClass]
from
	etl_cdgfactPolicy



	





GO
