USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0693]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0693]

as

SET NOCOUNT ON


/****************************************************************************************************/

--  Name:           dbo.rptsp_rpt0693
--  Author:         Saurabh Date
--  Date Created:   20151023
--  Description:    This stored procedure returns Top 20 agencies for the selected BDM, Country, Supergroup and Outlet reference
--   
--  Change History: 20151023 - SD - Created

/****************************************************************************************************/

declare @MTDStart datetime, @MTDEnd datetime
declare @LYMTDStart datetime, @LYMTDEnd datetime
declare @FYTDStart datetime, @FYTDEnd datetime
declare @LYFYTDStart datetime, @LYFYTDEnd datetime
declare @LYFYStart datetime, @LYFYEnd datetime

select @MTDStart = StartDate, @MTDEnd = EndDate
from [db-au-cmdwh].dbo.vDateRange
where DateRange = 'Month-To-Date'
	
select @LYMTDStart = StartDate, @LYMTDEnd = EndDate
from [db-au-cmdwh].dbo.vDateRange
where DateRange = 'Last Year Month-To-Date'

select @FYTDStart = StartDate, @FYTDEnd = EndDate
from [db-au-cmdwh].dbo.vDateRange
where DateRange = 'Fiscal Year-To-Date'

select @LYFYTDStart = StartDate, @LYFYTDEnd = EndDate
from [db-au-cmdwh].dbo.vDateRange
where DateRange = 'Last Year Fiscal Year-To-Date'

select @LYFYStart = StartDate, @LYFYEnd = EndDate
from [db-au-cmdwh].dbo.vDateRange
where DateRange = 'Last Fiscal Year'


if object_id('tempdb..#outlettemp') is not null drop table #outlettemp
select 
	o.Country,
	o.SuperGroupName as SuperGroup,

	o.OutletName + ' (' + o.AlphaCode + ')' as Store,
	o.LatestBDMName,
	o.OutletSK,
	ar.OutletReference,
	ar.ReferenceSK
into #outlettemp
from
	[db-au-star].dbo.dimOutlet o 
	inner join 
	(
		select	'Point in time' as OutletReference,
				OutletSK,
				OutletSK as ReferenceSK,
				'PT' + convert(varchar(max),OutletSK) as RefSK
		from
			[db-au-star].dbo.dimOutlet

			union

		select	'Latest alpha' as OutletReference,
				OutletSK,
				LatestOutletSK as ReferenceSK,
				'LA' + convert(varchar(max),OutletSK) as RefSK
		from
			[db-au-star].dbo.dimOutlet
	) ar on o.OutletSK = ar.ReferenceSK
where
	o.Country in ('AU','NZ') and
	o.Distributor = 'Agents' and
	o.SuperGroupName in ('Flight Centre','helloworld','Independents') and 
	o.OutletType = 'B2B' 
	

--get last fiscal year
if object_id('tempdb..#lyfy') is not null drop table #lyfy
select
	o.Store,
	o.LatestBDMName,
	'Point in time' as OutletReference,
	isnull(sum(pt.PolicyCount),0) as PolicyCount,
	isnull(sum(pt.SellPrice),0) as SellPrice
into #lyfy
from
	[db-au-star].dbo.factPolicyTransaction pt
	inner join #outlettemp o on pt.OutletSK = o.OutletSK and o.OutletReference = 'Point in time'
where
	pt.DateSK between convert(varchar(8),@LYFYStart,112) and convert(varchar(8),@LYFYEnd,112)
group by
	o.Store,
	o.LatestBDMName
	
union all

select
	o.Store,
	o.LatestBDMName,
	'Latest alpha' as OutletReference,
	isnull(sum(pt.PolicyCount),0) as PolicyCount,
	isnull(sum(pt.SellPrice),0) as SellPrice
from
	[db-au-star].dbo.factPolicyTransaction pt
	inner join #OutletTemp o on pt.OutletSK = o.OutletSK and o.OutletReference = 'Latest alpha'
where
	pt.DateSK between convert(varchar(8),@LYFYStart,112) and convert(varchar(8),@LYFYEnd,112)
group by
	o.Store,
	o.LatestBDMName


--mtd sales
if object_id('tempdb..#mtd') is not null drop table #mtd
select
	o.Store,
	o.LatestBDMName,
	'Point in time' as OutletReference,
	isnull(sum(pt.PolicyCount),0) as PolicyCount,
	isnull(sum(pt.SellPrice),0) as SellPrice
into #mtd
from
	[db-au-star].dbo.factPolicyTransaction pt
	inner join #OutletTemp o on pt.OutletSK = o.OutletSK and o.OutletReference = 'Point in time'
where
	pt.DateSK between convert(varchar(8),@MTDStart,112) and convert(varchar(8),@MTDEnd,112)
group by
	o.Store,
	o.LatestBDMName
	
union all

select
	o.Store,
	o.LatestBDMName,
	'Latest alpha' as OutletReference,
	isnull(sum(pt.PolicyCount),0) as PolicyCount,
	isnull(sum(pt.SellPrice),0) as SellPrice
from
	[db-au-star].dbo.factPolicyTransaction pt
	inner join #OutletTemp o on pt.OutletSK = o.OutletSK and o.OutletReference = 'Latest alpha'
where
	pt.DateSK between convert(varchar(8),@MTDStart,112) and convert(varchar(8),@MTDEnd,112)
group by
	o.Store,
	o.LatestBDMName


--last year mtd sales
if object_id('tempdb..#lymtd') is not null drop table #lymtd
select
	o.Store,
	o.LatestBDMName,
	'Point in time' as OutletReference,
	isnull(sum(pt.PolicyCount),0) as PolicyCount,
	isnull(sum(pt.SellPrice),0) as SellPrice
into #lymtd
from
	[db-au-star].dbo.factPolicyTransaction pt
	inner join #OutletTemp o on pt.OutletSK = o.OutletSK and o.OutletReference = 'Point in time'
where
	pt.DateSK between convert(varchar(8),@LYMTDStart,112) and convert(varchar(8),@LYMTDEnd,112)
group by
	o.Store,
	o.LatestBDMName
	
union all

select
	o.Store,
	o.LatestBDMName,
	'Latest alpha' as OutletReference,
	isnull(sum(pt.PolicyCount),0) as PolicyCount,
	isnull(sum(pt.SellPrice),0) as SellPrice
from
	[db-au-star].dbo.factPolicyTransaction pt
	inner join #OutletTemp o on pt.OutletSK = o.OutletSK and o.OutletReference = 'Latest alpha'
where
	pt.DateSK between convert(varchar(8),@LYMTDStart,112) and convert(varchar(8),@LYMTDEnd,112)
group by
	o.Store,
	o.LatestBDMName

--fiscal year to date
if object_id('tempdb..#fytd') is not null drop table #fytd
select
	o.Store,
	o.LatestBDMName,
	'Point in time' as OutletReference,
	isnull(sum(pt.PolicyCount),0) as PolicyCount,
	isnull(sum(pt.SellPrice),0) as SellPrice
into #fytd
from
	[db-au-star].dbo.factPolicyTransaction pt
	inner join #OutletTemp o on pt.OutletSK = o.OutletSK and o.OutletReference = 'Point in time'
where
	pt.DateSK between convert(varchar(8),@FYTDStart,112) and convert(varchar(8),@FYTDEnd,112)
group by
	o.Store,
	o.LatestBDMName
	
union all

select
	o.Store,
	o.LatestBDMName,
	'Latest alpha' as OutletReference,
	isnull(sum(pt.PolicyCount),0) as PolicyCount,
	isnull(sum(pt.SellPrice),0) as SellPrice
from
	[db-au-star].dbo.factPolicyTransaction pt
	inner join #OutletTemp o on pt.OutletSK = o.OutletSK and o.OutletReference = 'Latest alpha'
where
	pt.DateSK between convert(varchar(8),@FYTDStart,112) and convert(varchar(8),@FYTDEnd,112)
group by
	o.Store,
	o.LatestBDMName

--last fiscal year to date
if object_id('tempdb..#lyfytd') is not null drop table #lyfytd
select
	o.Store,
	o.LatestBDMName,
	'Point in time' as OutletReference,
	isnull(sum(pt.PolicyCount),0) as PolicyCount,
	isnull(sum(pt.SellPrice),0) as SellPrice
into #lyfytd
from
	[db-au-star].dbo.factPolicyTransaction pt
	inner join #OutletTemp o on pt.OutletSK = o.OutletSK and o.OutletReference = 'Point in time'
where
	pt.DateSK between convert(varchar(8),@LYFYTDStart,112) and convert(varchar(8),@LYFYTDEnd,112)
group by
	o.Store,
	o.LatestBDMName
	
union all

select
	o.Store,
	o.LatestBDMName,
	'Latest alpha' as OutletReference,
	isnull(sum(pt.PolicyCount),0) as PolicyCount,
	isnull(sum(pt.SellPrice),0) as SellPrice
from
	[db-au-star].dbo.factPolicyTransaction pt
	inner join #OutletTemp o on pt.OutletSK = o.OutletSK and o.OutletReference = 'Latest alpha'
where
	pt.DateSK between convert(varchar(8),@LYFYTDStart,112) and convert(varchar(8),@LYFYTDEnd,112)
group by
	o.Store,
	o.LatestBDMName

--get top 20 stores based on Sell Price (PY) for each latest BDM, country, super group, and outlet reference
if object_id('tempdb..#outlet') is not null drop table #outlet
select distinct
	a.Country,
	a.SuperGroup,
	a.LatestBDMName,
	a.OutletReference,
	a.Store,
	a.[Rank],
	a.[Policy Count (LY)],
	a.[Sell Price (LY)],
	a.[Policy Count],
	a.[Sell Price],
	a.[Policy Count (PY)],
	a.[Sell Price (PY)],
	a.[Policy Count (YTD)],
	a.[Sell Price (YTD)],
	a.[Policy Count (PYTD)],
	a.[Sell Price (PYTD)],
	a.[Policy Count Variance (MTD)],
	a.[Sell Price Variance (MTD)],
	a.[Policy Count Variance (YTD)],
	a.[Sell Price Variance (YTD)]
from
(
	select
		o.Country,
		o.SuperGroup,
		o.Store,
		o.LatestBDMName,
		o.OutletReference,
		lyfy.PolicyCount as [Policy Count (LY)],
		lyfy.SellPrice as [Sell Price (LY)],
		mtd.PolicyCount as [Policy Count],
		mtd.SellPrice as [Sell Price],
		lymtd.PolicyCount as [Policy Count (PY)],
		lymtd.SellPrice as [Sell Price (PY)],
		fytd.PolicyCount as [Policy Count (YTD)],
		fytd.SellPrice as [Sell Price (YTD)],
		lyfytd.PolicyCount as [Policy Count (PYTD)],
		lyfytd.SellPrice as [Sell Price (PYTD)],
		case -- Calculating MTD Variance of Policy Count
			when lymtd.PolicyCOunt=0 then 0
			else isnull(cast(((cast(mtd.PolicyCount as decimal(18,4)) - cast(lymtd.PolicyCount as decimal(18,4)))/cast(lymtd.PolicyCount as decimal(18,4))) as decimal(18,4)),0)
		end [Policy Count Variance (MTD)],
		case -- Calculating MTD Variance of Sell Price
			when lymtd.SellPrice=0 then 0
			else isnull(((mtd.SellPrice - lymtd.SellPrice) / lymtd.SellPrice), 0)
		end [Sell Price Variance (MTD)],
		case -- Calculating YTD Variance of Policy Count
			when lyfytd.PolicyCount=0 then 0
			else isnull(cast(((cast(fytd.PolicyCount as decimal(18,4)) - cast(lyfytd.PolicyCount as decimal(18,4))) / cast(lyfytd.PolicyCount as decimal(18,4))) as decimal(18,4)),0)
		end [Policy Count Variance (YTD)],
		case -- Calculating YTD Variance of Sell Price
			when lyfytd.SellPrice=0 then 0
			else isnull(((fytd.SellPrice - lyfytd.SellPrice) / lyfytd.SellPrice), 0)
		end [Sell Price Variance (YTD)],		
		DENSE_RANK() OVER (PARTITION BY o.LatestBDMName, o.Country, o.SuperGroup, OutletReference ORDER BY lyfy.SellPrice DESC) [Rank]
	from
		#outletTemp o
		outer apply
		(
			select
				isnull(sum(PolicyCount),0) as PolicyCount,
				isnull(sum(SellPrice),0) as SellPrice
			from #lyfy
			where 
				Store = o.Store and
				LatestBDMName = o.LatestBDMName and
				OutletReference = o.OutletReference
		) lyfy
		outer apply
		(
			select
				isnull(sum(PolicyCount),0) as PolicyCount,
				isnull(sum(SellPrice),0) as SellPrice
			from #mtd
			where 
				Store = o.Store and
				LatestBDMName = o.LatestBDMName and
				OutletReference = o.OutletReference
		) mtd
		outer apply
		(
			select
				isnull(sum(PolicyCount),0) as PolicyCount,
				isnull(sum(SellPrice),0) as SellPrice
			from #lymtd
			where 
				Store = o.Store and
				LatestBDMName = o.LatestBDMName and
				OutletReference = o.OutletReference
		) lymtd
		outer apply
		(
			select
				isnull(sum(PolicyCount),0) as PolicyCount,
				isnull(sum(SellPrice),0) as SellPrice
			from #fytd
			where 
				Store = o.Store and
				LatestBDMName = o.LatestBDMName and
				OutletReference = o.OutletReference
		) fytd
		outer apply
		(
			select
				isnull(sum(PolicyCount),0) as PolicyCount,
				isnull(sum(SellPrice),0) as SellPrice
			from #lyfytd
			where 
				Store = o.Store and
				LatestBDMName = o.LatestBDMName and
				OutletReference = o.OutletReference
		) lyfytd
	) a
where
	a.[Rank] <= 20
order by
	a.LatestBDMName,
	a.Country,
	a.SuperGroup,
	a.OutletReference,
	a.[Rank]


drop table #lyfy
drop table #mtd
drop table #lymtd
drop table #fytd
drop table #lyfytd
GO
