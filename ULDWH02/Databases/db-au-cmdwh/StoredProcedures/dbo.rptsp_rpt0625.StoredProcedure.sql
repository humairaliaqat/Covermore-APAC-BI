USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0625]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0625]		@DateRange varchar(30),
											@StartDate varchar(10),
											@EndDate varchar(10)
as

SET NOCOUNT ON

										
/****************************************************************************************************/
--  Name:           etlsp_RPT0625
--  Author:         Linus Tor
--  Date Created:   20150630
--  Description:    This stored procedure process fiscal year-to-date sales data for Phil Hoffman travel group.
--
--  Parameters:     @ReportingPeriod: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--					@EndDate: if_User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--   
--  Change History: 20150630 - LT - Created
--  Change History: 20160323 - GP - Altered - Changed in filter condition - GroupCode = 'HA' and SubGroupCode = 'PT' instead of OutletName like 'Phil Hoff%'
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
	from [db-au-cmdwh].dbo.vDateRange
	where DateRange = @DateRange
	
	
if object_id('tempdb..#Outlet') is not null drop table #Outlet
select 
	o.OutletKey, 
	o.OutletAlphaKey, 
	o.LatestOutletKey,
	u.UserKey,
	u.[Login],
	u.Consultant,
	lo.GroupName,
	lo.SubGroupName,
	lo.AlphaCode,
	lo.OutletName,
	lo.OutletType,
	lo.ContactState,
	lo.Branch,
	lo.BDMName,
	lo.SalesSegment,
	lo.TradingStatus	
into #Outlet	
from 
	penOutlet o
	outer apply
	(
		select top 1 
			SuperGroupName,		
			GroupName,
			SubGroupName,
			AlphaCode,
			OutletName,
			OutletType,
			ContactState,
			Branch,
			BDMName,
			SalesSegment,
			TradingStatus,
			GroupCode,
			SubGroupCode			
		from penOutlet
		where 
			OutletKey = o.LatestOutletKey and
			OutletStatus = 'Current'
	) lo
	outer apply
	(
		select UserKey, [Login], FirstName + ' ' + LastName as Consultant
		from penUser
		where OutletKey = o.OutletKey and UserStatus = 'Current'
	) u
where 
	o.CountryKey = 'AU' and
	lo.GroupCode = 'HA' and lo.SubGroupCode = 'PT'
	
union

select 
	o.OutletKey, 
	o.OutletAlphaKey, 
	o.LatestOutletKey,
	u.UserKey,
	u.[Login],
	u.Consultant,
	lo.GroupName,
	lo.SubGroupName,
	lo.AlphaCode,
	lo.OutletName,
	lo.OutletType,
	lo.ContactState,
	lo.Branch,
	lo.BDMName,
	lo.SalesSegment,
	lo.TradingStatus		
from 
	penOutlet o
	outer apply
	(
		select top 1 
			SuperGroupName,		
			GroupName,
			SubGroupName,
			AlphaCode,
			OutletName,
			OutletType,
			ContactState,
			Branch,
			BDMName,
			SalesSegment,
			TradingStatus,
			GroupCode,
			SubGroupCode			
		from penOutlet
		where 
			OutletKey = o.LatestOutletKey and
			OutletStatus = 'Current'
	) lo
	outer apply
	(
		select 'Cover-More' as UserKey, 'Cover-More' as [Login], 'Cover-More' as Consultant
		from penUser
		where OutletKey = o.OutletKey and UserStatus = 'Current'
	) u
where 
	o.CountryKey = 'AU' and
	lo.GroupCode = 'HA' and lo.SubGroupCode = 'PT'
		
--get latest outletkey
if object_id('tempdb..#LatestOutletKey') is not null drop table #LatestOutletKey
select distinct o.LatestOutletKey, o.UserKey, o.[Login], c.[Date]
into #LatestOutletKey
from 
	#Outlet o
	cross join
	(
		select [Date]
		from Calendar
		where [Date] between @rptStartDate and @rptEndDate
	) c

	
--get current year policies
if object_id('tempdb..#cyp') is not null drop table #cyp
select
	convert(nvarchar(50),null) as LatestOutletKey,
	p.OutletAlphaKey,
	isnull(p.UserKey,'Cover-More') as UserKey,
	p.PostingDate as [Date],
	sum(p.NewPolicyCount) as PolicyCount,
	sum(p.GrossAdminFee + Commission) as AgencyCommission,
	sum(p.GrossPremium) as SellPrice	
into #cyp	
from
	penPolicyTransSummary p
	join penOutlet o on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
where
	p.CountryKey = 'AU' and
	p.PostingDate between @rptStartDate and @rptEndDate and
	o.LatestOutletKey in (select distinct LatestOutletKey from #LatestOutletKey)
group by
	p.OutletAlphaKey,
	isnull(p.UserKey,'Cover-More'),
	p.PostingDate


update p
set p.LatestOutletKey = la.LatestOutletKey
from
	#cyp p
	cross apply
	(
		select top 1 l.LatestOutletKey
		from 
			#LatestOutletKey l
			join penOutlet o on l.LatestOutletKey = o.LatestOutletKey and o.OutletStatus = 'Current'
		where
			o.OutletAlphaKey = p.OutletAlphaKey				
	) la
	


--get prior year policies
if object_id('tempdb..#pyp') is not null drop table #pyp
select
	convert(nvarchar(50),null) as LatestOutletKey,
	p.OutletAlphaKey,
	isnull(p.UserKey,'Cover-More') as UserKey,
	p.YAGOPostingDate as [Date],
	sum(p.NewPolicyCount) as PolicyCount,
	sum(p.GrossAdminFee + Commission) as AgencyCommission,
	sum(p.GrossPremium) as SellPrice		
into #pyp	
from
	penPolicyTransSummary p
	join penOutlet o on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
where
	p.CountryKey = 'AU' and
	p.YAGOPostingDate between @rptStartDate and @rptEndDate and
	o.LatestOutletKey in (select distinct LatestOutletKey from #LatestOutletKey)
group by
	p.OutletAlphaKey,
	isnull(p.UserKey,'Cover-More'),
	p.YAGOPostingDate
	
update p
set p.LatestOutletKey = la.LatestOutletKey
from
	#pyp p
	cross apply
	(
		select top 1 l.LatestOutletKey
		from 
			#LatestOutletKey l
			join penOutlet o on l.LatestOutletKey = o.LatestOutletKey and o.OutletStatus = 'Current'
		where
			o.OutletAlphaKey = p.OutletAlphaKey				
	) la

	

--get current year quotes
if object_id('tempdb..#cyq') is not null drop table #cyq
select
	convert(nvarchar(50),null) as LatestOutletKey,
	q.OutletAlphaKey,
	isnull(u.UserKey,'Cover-More') as UserKey,
	q.CreateDate as [Date],
	count(q.QuoteID) as QuoteCount
into #cyq
from
	penQuote q
	join penOutlet o on q.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
	left join penUser u on q.OutletAlphaKey = u.OutletAlphaKey and q.UserName = u.[Login] and u.UserStatus = 'Current'
where
	q.CountryKey = 'AU' and
	q.CreateDate between @rptStartDate and @rptEndDate and
	o.LatestOutletKey in (select distinct LatestOutletKey from #LatestOutletKey)
group by
	q.OutletAlphaKey,
	isnull(u.UserKey,'Cover-More'),
	q.CreateDate
	
update q
set q.LatestOutletKey = la.LatestOutletKey
from
	#cyq q
	cross apply
	(
		select top 1 l.LatestOutletKey
		from 
			#LatestOutletKey l
			join penOutlet o on l.LatestOutletKey = o.LatestOutletKey and o.OutletStatus = 'Current'
		where
			o.OutletAlphaKey = q.OutletAlphaKey				
	) la


--get prior year quotes
if object_id('tempdb..#pyq') is not null drop table #pyq
select
	convert(nvarchar(50),null) as LatestOutletKey,
	q.OutletAlphaKey,
	isnull(u.UserKey,'Cover-More') as UserKey,
	q.YAGOCreateDate as [Date],
	count(q.QuoteID) as QuoteCount
into #pyq
from
	penQuote q
	join penOutlet o on q.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
	left join penUser u on q.OutletAlphaKey = u.OutletAlphaKey and q.UserName = u.[Login] and u.UserStatus = 'Current'
where
	q.CountryKey = 'AU' and
	q.YAGOCreateDate between @rptStartDate and @rptEndDate and
	o.LatestOutletKey in (select distinct LatestOutletKey from #LatestOutletKey)
group by
	q.OutletAlphaKey,
	isnull(u.UserKey,'Cover-More'),
	q.YAGOCreateDate
	
	
update q
set q.LatestOutletKey = la.LatestOutletKey
from
	#pyq q
	cross apply
	(
		select top 1 l.LatestOutletKey
		from 
			#LatestOutletKey l
			join penOutlet o on l.LatestOutletKey = o.LatestOutletKey and o.OutletStatus = 'Current'
		where
			o.OutletAlphaKey = q.OutletAlphaKey				
	) la


if object_id('tempdb..#OutletFinal') is not null drop table #OutletFinal
select distinct
	l.LatestOutletKey,
	l.UserKey,
	l.[Date],
	o.Consultant,		
	o.GroupName,
	o.SubGroupName,
	o.AlphaCode,
	o.OutletName,
	o.OutletType,
	o.ContactState,
	o.Branch,
	o.BDMName,
	o.SalesSegment,
	o.TradingStatus
into #OutletFinal		
from
	#LatestOutletKey l
	outer apply
	(
		select top 1
			Consultant,		
			GroupName,
			SubGroupName,
			AlphaCode,
			OutletName,
			OutletType,
			ContactState,
			Branch,
			BDMName,
			SalesSegment,
			TradingStatus
		from #Outlet
		where 
			LatestOutletKey = l.LatestOutletKey and
			UserKey = l.UserKey
	) o		

	
select
	o.[GroupName],
	o.[SubGroupName],
	o.[AlphaCode],
	o.[OutletName],
	o.[OutletType],
	o.[ContactState],
	o.[Branch],
	o.[BDMName],
	isnull(lu.[Consultant],'Cover-More') as Consultant,
	o.[SalesSegment],
	o.[TradingStatus],
	o.[Date],
	sum(isnull(cyp.PolicyCount,0)) as PolicyCount,
	sum(isnull(cyp.AgencyCommission,0)) as AgencyCommission,
	sum(isnull(cyp.SellPrice,0)) as SellPrice,
	sum(isnull(cyq.QuoteCount,0)) as QuoteCount,
	sum(isnull(pyp.PolicyCount,0)) as YAGO_PolicyCount,
	sum(isnull(pyp.AgencyCommission,0)) as YAGO_AgencyCommission,
	sum(isnull(pyp.SellPrice,0)) as YAGO_SellPrice,
	sum(isnull(pyq.QuoteCount,0)) as YAGO_QuoteCount,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate
from
	#OutletFinal o
	outer apply
	(
		select top 1 FirstName + ' ' + LastName as Consultant
		from 
			penUser u
			join penOutlet lo on
				u.OutletKey = lo.LatestOutletKey and
				u.UserStatus = 'Current' and
				lo.OutletStatus = 'Current'
		where
			u.UserKey = o.UserKey and
			Status = 'Active'
	) lu
	outer apply
	(
		select
			sum(PolicyCount) as PolicyCount,
			sum(AgencyCommission) as AgencyCommission,
			sum(SellPrice) as SellPrice
		from
			#cyp
		where
			LatestOutletKey = o.LatestOutletKey and
			UserKey = o.UserKey and
			[Date] = o.[Date]
	) cyp	
	outer apply
	(
		select
			sum(PolicyCount) as PolicyCount,
			sum(AgencyCommission) as AgencyCommission,
			sum(SellPrice) as SellPrice
		from
			#pyp
		where
			LatestOutletKey = o.LatestOutletKey and
			UserKey = o.UserKey and
			[Date] = o.[Date]						
	) pyp
	outer apply
	(
		select
			sum(QuoteCount) as QuoteCount
		from
			#cyq
		where
			LatestOutletKey = o.LatestOutletKey and
			UserKey = o.UserKey and
			[Date] = o.[Date]
	) cyq
	outer apply
	(
		select
			sum(QuoteCount) as QuoteCount
		from
			#pyq
		where
			LatestOutletKey = o.LatestOutletKey and
			UserKey = o.UserKey and
			[Date] = o.[Date]
	) pyq
where
	o.[GroupName] is not null	
group by
	o.[GroupName],
	o.[SubGroupName],
	o.[AlphaCode],
	o.[OutletName],
	o.[OutletType],
	o.[ContactState],
	o.[Branch],
	o.[BDMName],
	isnull(lu.[Consultant],'Cover-More'),
	o.[SalesSegment],
	o.[TradingStatus],
	o.[Date]


	
drop table #Outlet
drop table #LatestOutletKey
drop table #OutletFinal
drop table #cyp
drop table #pyp
drop table #cyq
drop table #pyq

GO
