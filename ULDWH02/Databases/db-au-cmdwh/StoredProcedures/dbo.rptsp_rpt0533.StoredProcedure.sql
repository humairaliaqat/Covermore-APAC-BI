USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0533]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0533]		@DateRange varchar(30),
											@StartDate varchar(10),
											@EndDate varchar(10)
as

SET NOCOUNT ON

										
/****************************************************************************************************/
--  Name:           rptsp_RPT0533
--  Author:         Linus Tor
--  Date Created:   20150323
--  Description:    This stored proceddtored in [db-au-cmdwh].dbo.usrRPT0533 and will be used by RPT0533, and RPT0533a reports.
--
--					This ETL procedure was created to speed up processing of helloworld reports above.
--
--  Parameters:     @ReportingPeriod: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--					@EndDate: if_User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--   
--  Change History: 20150323 - LT - Created
--					20161020 - PZ - TFS27253 - Exclude 'Concorde Transonic'
--					20171019 - LT - INC0047546 - Excluded subgroups: Best flights, Ethnic Travel Agency Group, Cedar Jet Travel
--					20171121 - LT - Add exclusion for JTN super group
--                  
/****************************************************************************************************/

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @DateRange = 'Month-To-Date', @StartDate = null, @EndDate = null
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
			TradingStatus			
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
	(
		lo.SuperGroupName = 'Stella' or
		lo.GroupName = 'Traveller''s Choice'
	) and
	lo.GroupName <> 'Concorde Transonic' and
	lo.SubGroupName not in ('Best flights','Ethnic Travel Agency Group','Cedar Jet Travel') and
	lo.GroupName <> 'JTN'
	
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
			TradingStatus			
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
	(
		lo.SuperGroupName = 'Stella' or
		lo.GroupName = 'Traveller''s Choice'
	) and
	lo.GroupName <> 'Concorde Transonic' and
	lo.SubGroupName not in ('Best flights','Ethnic Travel Agency Group','Cedar Jet Travel') and
	lo.GroupName <> 'JTN'

		
--get latest outletkey
if object_id('tempdb..#LatestOutletKey') is not null drop table #LatestOutletKey
select distinct LatestOutletKey, UserKey, [Login]
into #LatestOutletKey
from #Outlet


--get current year policies
if object_id('tempdb..#cyp') is not null drop table #cyp
select
	convert(nvarchar(50),null) as LatestOutletKey,
	p.OutletAlphaKey,
	isnull(p.UserKey,'Cover-More') as UserKey,
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
	isnull(p.UserKey,'Cover-More')


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
	isnull(p.UserKey,'Cover-More')
	
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
	isnull(u.UserKey,'Cover-More')
	
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
	isnull(u.UserKey,'Cover-More')
	
	
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
	o.[Consultant],
	o.[SalesSegment],
	o.[TradingStatus],
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
		select
			sum(PolicyCount) as PolicyCount,
			sum(AgencyCommission) as AgencyCommission,
			sum(SellPrice) as SellPrice
		from
			#cyp
		where
			LatestOutletKey = o.LatestOutletKey and
			UserKey = o.UserKey
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
			UserKey = o.UserKey						
	) pyp
	outer apply
	(
		select
			sum(QuoteCount) as QuoteCount
		from
			#cyq
		where
			LatestOutletKey = o.LatestOutletKey and
			UserKey = o.UserKey
	) cyq
	outer apply
	(
		select
			sum(QuoteCount) as QuoteCount
		from
			#pyq
		where
			LatestOutletKey = o.LatestOutletKey and
			UserKey = o.UserKey
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
	o.[Consultant],
	o.[SalesSegment],
	o.[TradingStatus]


		
drop table #Outlet
drop table #LatestOutletKey
drop table #OutletFinal
drop table #cyp
drop table #pyp
drop table #cyq
drop table #pyq


GO
