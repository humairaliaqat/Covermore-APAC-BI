USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vsfAccount]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vsfAccount]
as

/****************************************************************************************************/
--	Name:			vsfAccount
--	Author:			Linus Tor
--	Date Created:	20100930
--	Description:	This view is used for Salesforce related reports/dashboards/universes etc..
--	
--	Change History:	20160804 - LT - Created
--	
/****************************************************************************************************/


select
	left(a.AgencyID,2) as Country,
	a.AgencyID,
	a.AccountID,
	isnull(o.BDMName,a.BDMName) as BDMName,
	o.JV,
	o.SuperGroupName,
	a.GroupName,
	a.SubGroupName,
	a.AlphaCode,
	o.OutletAlphaKey,
	o.CommencementDate,
	a.TradingStatus,
	a.OutletName,
	o.Branch,
	o.Suburb,
	o.Postcode,
	o.[State],
	case when o.State in ('NSW','ACT') then 'NSW/ACT'
		 when o.State in ('SA','NT') then 'SA/NT'
		 when o.State in ('VIC','TAS') then 'VIC/TAS'
		 else o.State
	end as StateCombined,
	o.Phone,
	o.Email,
	isnull(a.Quadrant,'UNKNOWN') as Quadrant,
	lastvisit.DateLastVisit,
	SellPriceCY.SellPriceCY,
	SellPricePY.SellPricePY,
	case when SellPricePY.SellPricePY <> 0 then (SellPriceCY.SellPriceCY-SellPricePY.SellPricePY)/SellPricePY.SellPricePY else 0 end as YTDGrowthPct,
	SellPricePY2.SellPricePY2,
	SellPriceCQ.SellPriceCQ,
	SellPricePQ.SellPricePQ,
	case when SellPricePQ.SellPricePQ <> 0 then (SellPriceCQ.SellPriceCQ-SellPricePQ.SellPricePQ)/SellPricePQ.SellPricePQ else 0 end as QtrGrowthPct,
	DateCY.StartDateCY,
	DateCY.EndDateCY,
	DatePY.StartDatePY,
	DatePY.EndDatePY,
	DatePY2.StartDatePY2,
	DatePY2.EndDatePY2,
	DateCQ.StartDateCQ,
	DateCQ.EndDateCQ,
	DatePQ.StartDatePQ,
	DatePQ.EndDatePQ
from
	sfAccount a
	outer apply
	(
		select top 1
			OutletAlphaKey,
			CommencementDate,
			Branch,
			ContactSuburb as Suburb,
			ContactPostCode as Postcode,
			isnull(ContactState,case StateSalesArea when 'New South Wales' then 'NSW' 
													when 'Victoria' then 'VIC'
													when 'Western Australia' then 'WA'
													when 'Queensland' then 'QLD'
													when 'South Australia' then 'SA'
													when 'Northern Territory' then 'NT'
													when 'Tasmania' then 'TAS'
													when 'Australian Capital Territory' then 'ACT'
													else StateSalesArea
								end) as [State],
			ContactPhone as Phone,
			ContactEmail as Email,
			BDMName,
			SuperGroupName,
			JVDesc as JV
		from [db-au-star].dbo.dimOutlet
		where 
			AlphaCode = a.AlphaCode and
			Country = left(a.AgencyID,2)
	) o
	outer apply
	(
		select
			max(CallStartTime) as DateLastVisit
		from sfAgencyCall
		where
			CallSubCategory = 'Agency Visit' and
			AccountID = a.AccountID
	) lastvisit
	outer apply
	(
		select top 1
			StartDate as StartDateCY,
			EndDate as EndDateCY
		from
			vDateRange
		where DateRange = 'Fiscal Year-To-Date'
	) DateCY
	outer apply
	(
		select top 1
			StartDate as StartDatePY,
			EndDate as EndDatePY
		from
			vDateRange
		where DateRange = 'Last Year Fiscal Year-To-Date'
	) DatePY
	outer apply
	(
		select top 1
			StartDate as StartDatePY2,
			EndDate as EndDatePY2
		from
			vDateRange
		where DateRange = 'Last 2 Year Fiscal YTD'
	) DatePY2	
	outer apply
	(
		select top 1
			StartDate as StartDateCQ,
			EndDate as EndDateCQ
		from
			vDateRange
		where DateRange = 'Last Quarter'
	) DateCQ
	outer apply
	(
		select top 1
			dateadd(year,-1,StartDate) as StartDatePQ,
			dateadd(year,-1,EndDate) as EndDatePQ
		from
			vDateRange
		where DateRange = 'Last Quarter'
	) DatePQ		
	outer apply
	(
		select sum(GrossPremium) as SellPriceCY
		from [db-au-cmdwh].dbo.penPolicyTransSummary
		where 
			OutletAlphaKey = o.OutletAlphaKey and
			PostingDate between DateCY.StartDateCY and DateCY.EndDateCY			
	) SellPriceCY
	outer apply
	(
		select sum(GrossPremium) as SellPricePY
		from [db-au-cmdwh].dbo.penPolicyTransSummary
		where 
			OutletAlphaKey = o.OutletAlphaKey and
			PostingDate between DatePY.StartDatePY and DatePY.EndDatePY
	) SellPricePY
	outer apply
	(
		select sum(GrossPremium) as SellPricePY2
		from [db-au-cmdwh].dbo.penPolicyTransSummary
		where 
			OutletAlphaKey = o.OutletAlphaKey and
			PostingDate between DatePY2.StartDatePY2 and DatePY2.EndDatePY2
	) SellPricePY2
	outer apply
	(
		select sum(GrossPremium) as SellPriceCQ
		from [db-au-cmdwh].dbo.penPolicyTransSummary
		where 
			OutletAlphaKey = o.OutletAlphaKey and
			PostingDate between DateCQ.StartDateCQ and DateCQ.EndDateCQ
	) SellPriceCQ
	outer apply
	(
		select sum(GrossPremium) as SellPricePQ
		from [db-au-cmdwh].dbo.penPolicyTransSummary
		where 
			OutletAlphaKey = o.OutletAlphaKey and
			PostingDate between DatePQ.StartDatePQ and DatePQ.EndDatePQ
	) SellPricePQ
where
	a.TradingStatus in ('Stocked','Prospect') and
	a.OutletType = 'B2B'

GO
