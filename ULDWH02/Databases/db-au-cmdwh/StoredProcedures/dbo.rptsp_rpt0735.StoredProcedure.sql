USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0735]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0735]   @DateRange varchar(30),
										 @StartDate varchar(10),
										 @EndDate varchar(10),
										 @SuperGroup varchar(50)='Virgin'-- added by Manoj 
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           rptsp_rpt0735
--  Author:         Linus Tor
--  Date Created:   20160202
--  Description:    This stored procedure returns sales data for Virgin AU & NZ
--
--  Parameters:     @ReportingPeriod: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--					@EndDate: if_User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--   
--  Change History: 20160202 - LT - Created
--                  20160608 - LL - rename global temp tables to be a bit more unique
--                  
/****************************************************************************************************/

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @DateRange = 'Last Month', @StartDate = null, @EndDate = null
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
	from vDateRange
	where DateRange = @DateRange
	
	
--get OutletAlphaKey, latest group, and latest outletkey
if object_id('tempdb..##rpt0735_Outlet') is not null drop table ##rpt0735_Outlet
select
	o.CountryKey,
	o.OutletAlphaKey,
	lo.GroupName,
	lo.SubGroupName,
	o.LatestOutletKey
into ##rpt0735_Outlet	
from
	penOutlet o
	outer apply 
	(
		select top 1 SuperGroupName, GroupName, SubGroupName, LatestOutletKey, CountryKey
		from penOutlet l 
		where l.OutletStatus = 'Current' and l.OutletKey = o.LatestOutletKey
	) lo
where
	lo.CountryKey in ('AU','NZ') and
	o.OutletStatus = 'Current' and
	--lo.SuperGroupName ='Virgin' --modified by manoj
	(lo.SuperGroupName in (@SuperGroup)	or lo.GroupName in(@SuperGroup))



--get latestoutletkey and dates
if object_id('tempdb..##rpt0735_LatestOutletKey') is not null drop table ##rpt0735_LatestOutletKey
select 
	o.LatestOutletKey,
	d.[Date]
into ##rpt0735_LatestOutletKey	
from 
	(select distinct LatestOutletKey from ##rpt0735_Outlet) o
	cross join Calendar d
where
	d.[Date] between @rptStartDate and @rptEndDate


if object_id('tempdb..##rpt0735_cyp') is not null drop table ##rpt0735_cyp
select
	o.LatestOutletKey,
	p.PostingDate as [Date],
	sum(p.NewPolicyCount) as PolicyCount,
	sum(p.GrossPremium) as SellPrice,
	sum(p.Commission + GrossAdminFee) as AgencyCommission
into ##rpt0735_cyp	
from
	penPolicyTransSummary p
	inner join penOutlet o on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
where
	o.LatestOutletKey in (select distinct LatestOutletKey from ##rpt0735_LatestOutletKey) and
	p.PostingDate between @rptStartDate and @rptEndDate
group by
	o.LatestOutletKey,
	p.PostingDate
	
if object_id('tempdb..##rpt0735_pyp') is not null drop table ##rpt0735_pyp
select
	o.LatestOutletKey,
	p.YAGOPostingDate as [Date],
	sum(p.NewPolicyCount) as PolicyCount,
	sum(p.GrossPremium) as SellPrice,
	sum(p.Commission + GrossAdminFee) as AgencyCommission
into ##rpt0735_pyp	
from
	penPolicyTransSummary p
	inner join penOutlet o on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
where
	o.LatestOutletKey in (select distinct LatestOutletKey from ##rpt0735_LatestOutletKey) and
	p.YAGOPostingDate between @rptStartDate and @rptEndDate
group by
	o.LatestOutletKey,
	p.YAGOPostingDate
	
if object_id('tempdb..##rpt0735_cyq') is not null drop table ##rpt0735_cyq
select
	o.LatestOutletKey,
	q.CreateDate as [Date],
	count(q.QuoteID) as QuoteCount
into ##rpt0735_cyq	
from
	penQuote q
	inner join penOutlet o on q.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
where
	o.LatestOutletKey in (select distinct LatestOutletKey from ##rpt0735_LatestOutletKey) and
	q.CreateDate between @rptStartDate and @rptEndDate
group by
	o.LatestOutletKey,
	q.CreateDate

if object_id('tempdb..##rpt0735_pyq') is not null drop table ##rpt0735_pyq
select
	o.LatestOutletKey,
	q.YAGOCreateDate as [Date],
	count(q.QuoteID) as QuoteCount
into ##rpt0735_pyq	
from
	penQuote q
	inner join penOutlet o on q.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
where
	o.LatestOutletKey in (select distinct LatestOutletKey from ##rpt0735_LatestOutletKey) and
	q.YAGOCreateDate between @rptStartDate and @rptEndDate
group by
	o.LatestOutletKey,
	q.YAGOCreateDate
	
	
--get main data
select
	g.CountryKey,
	g.GroupName,
	g.SubGroupName,
	a.[Date],
	sum(isnull(cyp.PolicyCount,0)) as PolicyCount,
	sum(isnull(cyp.AgencyCommission,0)) as AgencyCommission,
	sum(isnull(cyp.SellPrice,0)) as SellPrice,
	sum(isnull(pyp.PolicyCount,0)) as YAGO_PolicyCount,
	sum(isnull(pyp.AgencyCommission,0)) as YAGO_AgencyCommission,
	sum(isnull(pyp.SellPrice,0)) as YAGO_SellPrice,
	sum(isnull(cyq.QuoteCount,0)) as QuoteCount,
	sum(isnull(pyq.QuoteCount,0)) as YAGO_QuoteCount,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate	
from
	##rpt0735_LatestOutletKey a
	outer apply
	(
		select top 1 CountryKey, GroupName, SubGroupName
		from ##rpt0735_Outlet
		where LatestOutletKey = a.LatestOutletKey
	) g
	outer apply
	(
		select
			sum(PolicyCount) as PolicyCount,
			sum(AgencyCommission) as AgencyCommission,
			sum(SellPrice) as SellPrice
		from
			##rpt0735_cyp
		where
			LatestOutletKey = a.LatestOutletKey and
			[Date] = a.[Date]
	) cyp			
	outer apply
	(
		select
			sum(PolicyCount) as PolicyCount,
			sum(AgencyCommission) as AgencyCommission,
			sum(SellPrice) as SellPrice
		from
			##rpt0735_pyp
		where
			LatestOutletKey = a.LatestOutletKey and
			[Date] = a.[Date]
	) pyp
	outer apply
	(
		select
			sum(QuoteCount) as QuoteCount
		from
			##rpt0735_cyq
		where
			LatestOutletKey = a.LatestOutletKey and
			[Date] = a.[Date]
	) cyq						
	outer apply
	(
		select
			sum(QuoteCount) as QuoteCount
		from
			##rpt0735_pyq
		where
			LatestOutletKey = a.LatestOutletKey and
			[Date] = a.[Date]
	) pyq
group by
	g.CountryKey,
	g.GroupName,
	g.SubGroupName,
	a.[Date]	
GO
