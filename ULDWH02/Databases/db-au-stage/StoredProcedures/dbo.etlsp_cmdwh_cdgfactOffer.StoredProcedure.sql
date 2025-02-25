USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_cdgfactOffer]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_cdgfactOffer]
as

SET NOCOUNT ON


/************************************************************************************************************************************
Author:         Linus Tor
Date:           20180227
Prerequisite:   Requires ETL043_CDGQuote agent job successfully run
Description:    Innate Impulse2 version 2 fact offer table denormalisation, and load data to [db-au-cmdwh].dbo.cdgfactOffer
Change History:
                20180227 - LT - Procedure created
						
*************************************************************************************************************************************/


if object_id('[db-au-stage].dbo.etl_cdgfactOffer') is not null drop table [db-au-stage].dbo.etl_cdgfactOffer

select
	q.factOfferID,
	q.SessionID,
	q.RegionID,
	q.CampaignID,
	q.ImpulseOfferID,
	qDate.OfferDate,
	qTime.OfferTime,
	convert(datetime, qDate.OfferDate + ' ' + qTime.OfferTime) as OfferDateTime,
	r.AreaCode,
	r.AreaType,
	r.RiskRank,
	r.RegionName,
	q.ProductID,
	pr.ProductCode,
	pr.PlanCode,
	pr.ProductName,
	pr.TripType,
	q.TripCost,
	pr.SingleFamilyDuo,
	promo.PromoCode,
	promo.PromoType,
	cam.CampaignName,
	q.BusinessUnitID,
	bu.Domain,
	bu.BusinessUnitName,
	bu.[Partner],
	bu.CurrencyCode,
	destcm.Destination,
	q.IsMultiDestination,
	multidest.MultiDestination,
	tripSD.TripStart,
	tripED.TripEnd,
	q.TotalGrossPremium,
	q.Excess,
	q.IsMostRecent,
	q.ConstructOfferDisplayPercent,
	q.NumAdults as AdultCount,
	q.NumChildren as ChildCount,
	q.NumInfants as InfantCount,
	q.MaxPolicies,
	q.ActualPoliciesSold,
	departCountry.DepartureCountry,
	departAirport.AirportName,
	grp.GroupType,
	cult.CultureCode,
	cult.CultureName,
	q.SelectedImpulseOfferID,
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
into [db-au-stage].dbo.etl_cdgfactOffer
from
	cdg_factOffer_AU q
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
		select top 1 CultureCode, CultureName
		from cdg_dimCulture_AU
		where dimCultureID = q.CultureID
	) cult
	outer apply
	(
		select top 1 GroupTypeName as GroupType
		from cdg_dimGroupType_AU
		where dimGroupTypeID = q.GroupTypeID
	) grp
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
		select top 1 [Date] as OfferDate
		from dbo.cdg_dimDate_AU 
		where DimDateID = q.OfferDateID
	) qdate
	outer apply
	(
		select top 1 [Time] as OfferTime
		from dbo.cdg_dimTime_AU 
		where dimTimeID = q.OfferTimeID
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
				 else 'Unknown'
			end as AreaType,
			case when AreaCode = '****' then 'Unknown'
			     else AreaCode
			end as AreaCode,
			RiskRank,
			case when RegionName = 'NOT SET' then 'Unknown'
			     else RegionName
			end as RegionName
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
				 else 'Unknown'
			end as TripType,
			case when GroupType = 'S' then 'Single'
			     when GroupType = 'F' then 'Family'
				 when GroupType = 'D' then 'Duo'
				 else 'Unknown'
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


if object_id('[db-au-cmdwh].dbo.cdgfactOffer') is null
begin
	create table [db-au-cmdwh].dbo.cdgfactOffer
	(
		[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
		[factOfferID] [int] NOT NULL,
		[SessionID] [int] NOT NULL,
		[RegionID] [int] NOT NULL,
		[CampaignID] [int] NOT NULL,
		[ImpulseOfferID] [int] NOT NULL,
		[OfferDate] [datetime] NULL,
		[OfferTime] [char](8) NULL,
		[OfferDateTime] [datetime] NULL,
		[AreaCode] [nvarchar](20) NULL,
		[AreaType] [varchar](16) NULL,
		[RiskRank] [int] NULL,
		[RegionName] [nvarchar](100) NULL,
		[ProductID] [int] NULL,
		[ProductCode] [nvarchar](10) NULL,
		[PlanCode] [nvarchar](10) NULL,
		[ProductName] [nvarchar](100) NULL,
		[TripType] [varchar](17) NULL,
		[TripCost] [numeric](18, 2) NULL,
		[SingleFamilyDuo] [varchar](7) NULL,
		[PromoCode] [varchar](8000) NULL,
		[PromoType] [varchar](100) NULL,
		[CampaignName] [varchar](255) NULL,
		[BusinessUnitID] [int] NOT NULL,
		[Domain] [char](2) NULL,
		[BusinessUnitName] [varchar](100) NULL,
		[Partner] [varchar](50) NULL,
		[CurrencyCode] [char](3) NULL,
		[Destination] [varchar](50) NULL,
		[IsMultiDestination] [int] NOT NULL,
		[MultiDestination] [varchar](8000) NULL,
		[TripStart] [datetime] NULL,
		[TripEnd] [datetime] NULL,
		[TotalGrossPremium] [numeric](9, 4) NULL,
		[Excess] [int] NOT NULL,
		[IsMostRecent] [int] NOT NULL,
		[ConstructOfferDisplayPercent] [numeric](9, 4) NULL,
		[AdultCount] [int] NULL,
		[ChildCount] [int] NULL,
		[InfantCount] [int] NULL,
		[MaxPolicies] [int] NOT NULL,
		[ActualPoliciesSold] [int] NOT NULL,
		[DepartureCountry] [varchar](50) NULL,
		[AirportName] [nvarchar](50) NULL,
		[GroupType] [nvarchar](7) NULL,
		[CultureCode] [nvarchar](20) NULL,
		[CultureName] [nvarchar](50) NULL,
		[SelectedImpulseOfferID] [int] NOT NULL,
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
	create clustered index idx_cdgfactOffer_BIRowID on [db-au-cmdwh].dbo.cdgfactOffer(BIRowID)
	create nonclustered index idx_cdgfactOffer_factOfferID on [db-au-cmdwh].dbo.cdgfactOffer(factOfferID)
	create nonclustered index idx_cdgfactOffer_OfferDate on [db-au-cmdwh].[dbo].[cdgfactOffer] ([OfferDate]) include
	(
		[factOfferID],
		[SessionID],
		[RegionID],
		[CampaignID],
		[OfferDateTime],
		[BusinessUnitID],
		[BusinessUnitName],
		[Destination],
		[TripStart],
		[TripEnd],
		[TotalGrossPremium],
		[AdultCount],
		[ChildCount],
		[InfantCount],
		[ProductID]
	)
end
else
	delete a
	from
		[db-au-cmdwh].dbo.cdgfactOffer a
		inner join etl_cdgfactOffer b on 
			a.factOfferID = b.FactOfferID and
			a.SessionID = b.SessionID

insert [db-au-cmdwh].dbo.cdgfactOffer with(tablock)
(	
	[factOfferID],
	[SessionID],
	[RegionID],
	[CampaignID],
	[ImpulseOfferID],
	[OfferDate],
	[OfferTime],
	[OfferDateTime],
	[AreaCode],
	[AreaType],
	[RiskRank],
	[RegionName],
	[ProductID],
	[ProductCode],
	[PlanCode],
	[ProductName],
	[TripType],
	[TripCost],
	[SingleFamilyDuo],
	[PromoCode],
	[PromoType],
	[CampaignName],
	[BusinessUnitID],
	[Domain],
	[BusinessUnitName],
	[Partner],
	[CurrencyCode],
	[Destination],
	[IsMultiDestination],
	[MultiDestination],
	[TripStart],
	[TripEnd],
	[TotalGrossPremium],
	[Excess],
	[IsMostRecent],
	[ConstructOfferDisplayPercent],
	[AdultCount],
	[ChildCount],
	[InfantCount],
	[MaxPolicies],
	[ActualPoliciesSold],
	[DepartureCountry],
	[AirportName],
	[GroupType],
	[CultureCode],
	[CultureName],
	[SelectedImpulseOfferID],
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
	[factOfferID],
	[SessionID],
	[RegionID],
	[CampaignID],
	[ImpulseOfferID],
	[OfferDate],
	[OfferTime],
	[OfferDateTime],
	[AreaCode],
	[AreaType],
	[RiskRank],
	[RegionName],
	[ProductID],
	[ProductCode],
	[PlanCode],
	[ProductName],
	[TripType],
	[TripCost],
	[SingleFamilyDuo],
	[PromoCode],
	[PromoType],
	[CampaignName],
	[BusinessUnitID],
	[Domain],
	[BusinessUnitName],
	[Partner],
	[CurrencyCode],
	[Destination],
	[IsMultiDestination],
	[MultiDestination],
	[TripStart],
	[TripEnd],
	[TotalGrossPremium],
	[Excess],
	[IsMostRecent],
	[ConstructOfferDisplayPercent],
	[AdultCount],
	[ChildCount],
	[InfantCount],
	[MaxPolicies],
	[ActualPoliciesSold],
	[DepartureCountry],
	[AirportName],
	[GroupType],
	[CultureCode],
	[CultureName],
	[SelectedImpulseOfferID],
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
	etl_cdgfactOffer

GO
