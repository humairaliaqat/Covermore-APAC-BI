USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_cdgfactQuote]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_cdgfactQuote]
as

SET NOCOUNT ON


/************************************************************************************************************************************
Author:         Linus Tor
Date:           20180227
Prerequisite:   Requires ETL043_CDGQuote agent job successfully run
Description:    Innate Impulse2 version 2 fact quote table denormalisation, and load data to [db-au-cmdwh].dbo.cdgfactQuote
Change History:
                20180227 - LT - Procedure created
						
*************************************************************************************************************************************/

if object_id('[db-au-stage].dbo.etl_cdgfactQuote') is not null drop table [db-au-stage].dbo.etl_cdgfactQuote

select
	q.factQuoteID,
	q.SessionID,
	q.RegionID,
	q.CampaignID,
	qDate.QuoteDate,
	qTime.QuoteTime,
	convert(datetime, qDate.QuoteDate + ' ' + qTime.QuoteTime) as QuoteDateTime,
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
	bu.CurrencyCode,
	alpha.AffiliateCode,
	destcm.Destination,
	q.IsMultiDestination,
	multidest.MultiDestination,
	tripSD.TripStart,
	tripED.TripEnd,
	q.TotalGrossPremium,
	q.TotalAdjustedGrossPremium,
	q.TotalTravelers as TravellerCount,
	q.Excess,
	q.IsMostRecent,
	q.NumAdults as AdultCount,
	q.NumChildren as ChildCount,
	q.NumInfants as InfantCount,
	q.HasCANX,
	q.HasWNTS,
	q.HasCRS,
	q.HasRTCR,
	q.CANXCoverageAmount,
	q.RTCRCoverageAmount,
	q.MaxPolicies,
	q.ActualPoliciesSold,
	departCountry.DepartureCountry,
	departAirport.AirportName,
	grp.GroupType,
	quoteSrc.QuoteSource
into [db-au-stage].dbo.etl_cdgfactQuote
from
	cdg_factQuote_AU q
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
		select top 1 QuoteSource
		from cdg_dimQuoteSource_AU
		where dimQuoteSourceID = q.QuoteSourceID
	) quoteSrc
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
		select top 1 [Date] as QuoteDate
		from dbo.cdg_dimDate_AU 
		where DimDateID = q.QuoteTransactionDateID
	) qdate
	outer apply
	(
		select top 1 [Time] as QuoteTime
		from dbo.cdg_dimTime_AU 
		where dimTimeID = q.QuoteTransactionTimeID
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


if object_id('[db-au-cmdwh].dbo.cdgfactQuote') is null
begin
	create table [db-au-cmdwh].dbo.cdgfactQuote
	(
		[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
		[factQuoteID] [int] NOT NULL,
		[SessionID] [int] NOT NULL,
		[RegionID] [int] NOT NULL,
		[CampaignID] [int] NOT NULL,
		[QuoteDate] [datetime] NULL,
		[QuoteTime] [char](8) NULL,
		[QuoteDateTime] [datetime] NULL,
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
		[CurrencyCode] [char](3) NULL,
		[AffiliateCode] [varchar](50) NULL,
		[Destination] [varchar](50) NULL,
		[IsMultiDestination] [int] NULL,
		[MultiDestination] [varchar](8000) NULL,
		[TripStart] [datetime] NULL,
		[TripEnd] [datetime] NULL,
		[TotalGrossPremium] [numeric](9, 4) NOT NULL,
		[TotalAdjustedGrossPremium] [numeric](9, 4) NOT NULL,
		[TravellerCount] [int] NOT NULL,
		[Excess] [int] NOT NULL,
		[IsMostRecent] [int] NOT NULL,
		[AdultCount] [int] NULL,
		[ChildCount] [int] NULL,
		[InfantCount] [int] NULL,
		[HasCANX] [int] NOT NULL,
		[HasWNTS] [int] NOT NULL,
		[HasCRS] [int] NOT NULL,
		[HasRTCR] [int] NOT NULL,
		[CANXCoverageAmount] [numeric](18, 2) NOT NULL,
		[RTCRCoverageAmount] [numeric](18, 2) NOT NULL,
		[MaxPolicies] [int] NOT NULL,
		[ActualPoliciesSold] [int] NOT NULL,
		[DepartureCountry] [varchar](50) NULL,
		[AirportName] [nvarchar](50) NULL,
		[GroupType] [nvarchar](7) NULL,
		[QuoteSource] [nvarchar](30) NULL
	)
	create clustered index idx_cdgfactQuote_BIRowID on [db-au-cmdwh].dbo.cdgfactQuote(BIRowID)
	create nonclustered index idx_cdgfactQuote_factQuoteID on [db-au-cmdwh].dbo.cdgfactQuote(factQuoteID)
	create nonclustered index idx_cdgfactQuote_QuoteDate ON [db-au-cmdwh].[dbo].[cdgfactQuote] ([QuoteDate])
	include
	(
		[factQuoteID],
		[SessionID],
		[RegionID],
		[CampaignID],
		[QuoteDateTime],
		[BusinessUnitID],
		[BusinessUnitName],
		[Destination],
		[TripStart],
		[TripEnd],
		[TotalGrossPremium],
		[TotalAdjustedGrossPremium],
		[AdultCount],
		[ChildCount],
		[InfantCount],
		[ProductID]
	)
end
else
	delete a
	from
		[db-au-cmdwh].dbo.cdgfactQuote a
		inner join etl_cdgfactQuote b on 
			a.factQuoteID = b.FactQuoteID and
			a.SessionID = b.SessionID

insert [db-au-cmdwh].dbo.cdgfactQuote with(tablock)
(	
	[factQuoteID],
	[SessionID],
	[RegionID],
	[CampaignID],
	[QuoteDate],
	[QuoteTime],
	[QuoteDateTime],
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
	[CurrencyCode],
	[AffiliateCode],
	[Destination],
	[IsMultiDestination],
	[MultiDestination],
	[TripStart],
	[TripEnd],
	[TotalGrossPremium],
	[TotalAdjustedGrossPremium],
	[TravellerCount],
	[Excess],
	[IsMostRecent],
	[AdultCount],
	[ChildCount],
	[InfantCount],
	[HasCANX],
	[HasWNTS],
	[HasCRS],
	[HasRTCR],
	[CANXCoverageAmount],
	[RTCRCoverageAmount],
	[MaxPolicies],
	[ActualPoliciesSold],
	[DepartureCountry],
	[AirportName],
	[GroupType],
	[QuoteSource]
)
select
	[factQuoteID],
	[SessionID],
	[RegionID],
	[CampaignID],
	[QuoteDate],
	[QuoteTime],
	[QuoteDateTime],
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
	[CurrencyCode],
	[AffiliateCode],
	[Destination],
	[IsMultiDestination],
	[MultiDestination],
	[TripStart],
	[TripEnd],
	[TotalGrossPremium],
	[TotalAdjustedGrossPremium],
	[TravellerCount],
	[Excess],
	[IsMostRecent],
	[AdultCount],
	[ChildCount],
	[InfantCount],
	[HasCANX],
	[HasWNTS],
	[HasCRS],
	[HasRTCR],
	[CANXCoverageAmount],
	[RTCRCoverageAmount],
	[MaxPolicies],
	[ActualPoliciesSold],
	[DepartureCountry],
	[AirportName],
	[GroupType],
	[QuoteSource]
from
	etl_cdgfactQuote

	





GO
