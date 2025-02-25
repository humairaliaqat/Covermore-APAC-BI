USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0796]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0796]		@DateRange varchar(30),
											@StartDate varchar(10),
											@EndDate varchar(10),
											@Country nvarchar(30),
											@GroupName nvarchar(30),
											@SubGroupName nvarchar(30)
as

Begin

SET NOCOUNT ON

										
/****************************************************************************************************/
--  Name:           rptsp_RPT0796
--  Author:         Peter Zhuo
--  Date Created:   20160726
--  Description:    This stored procedure process month-to-date and fiscal year-to-date sales data for Traveller's Choice.
--
--
--  Parameters:     @ReportingPeriod: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--					@EndDate: if_User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--					@Country: Required. Valid country code
--					@GroupName: Required. Valid group name
--					@SubGroupName: Optional. Valid Sub Group Name, enter 'All' for all sub groups
--   
--  Change History: 20160726 - PZ - Created based on rptsp_rpt0533
--									When a reporting period has been specified by user:
--									YTD Start Date = "Fiscal Year Start Date" of the last day of the selected period
--									YTD End Date   = Last day of the selected period
--					20160829 - PZ - Modified to accept any country/group/subgroup
--                  
/****************************************************************************************************/

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
declare @Country nvarchar(30)
declare @GroupName nvarchar(30)
declare @SubGroupName nvarchar(30)

select @DateRange = 'Last Month', @StartDate = null, @EndDate = null
--select @DateRange = '_User Defined', @StartDate = '2015-01-01', @EndDate = '2016-04-30'
select @Country = 'AU'
select @GroupName = 'Independent Agents'
select @SubGroupName = 'magellan'
*/

--select @GroupName


declare @rptStartDate date
declare @rptEndDate date
declare @rptStartDate_YTD date
declare @rptEndDate_YTD date


--get reporting dates
if @DateRange = '_User Defined'
	select 
			@rptStartDate = @StartDate,
            @rptEndDate = @EndDate,
			@rptStartDate_YTD = (select c.[CurFiscalYearStart] from Calendar c where c.[Date] = @EndDate),
		    @rptEndDate_YTD = @EndDate
else
	select
		    @rptStartDate = StartDate,
            @rptEndDate = EndDate,
			@rptStartDate_YTD = c.[CurFiscalYearStart], 
		    @rptEndDate_YTD = d.EndDate
	from [db-au-cmdwh].dbo.vDateRange d
	inner join [db-au-cmdwh].dbo.Calendar c on c.[Date] = d.[EndDate]
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
	o.CountryKey = @Country and
	(
		lo.GroupName = @GroupName and (lo.SubGroupName = @SubGroupName or isnull(@SubGroupName,'All') = 'All')
	)
	
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
	o.CountryKey = @Country and
	(
		lo.GroupName = @GroupName and (lo.SubGroupName = @SubGroupName or isnull(@SubGroupName,'All') = 'All')
	)
		
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
	p.CountryKey = @Country and
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
	p.CountryKey = @Country and
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
	q.CountryKey = @Country and
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
	q.CountryKey = @Country and
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

	
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------


if object_id('tempdb..#Outlet_YTD') is not null drop table #Outlet_YTD
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
into #Outlet_YTD
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
	o.CountryKey = @Country and
	(
		lo.GroupName = @GroupName and (lo.SubGroupName = @SubGroupName or isnull(@SubGroupName,'All') = 'All')
	)
	
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
	o.CountryKey = @Country and
	(
		lo.GroupName = @GroupName and (lo.SubGroupName = @SubGroupName or isnull(@SubGroupName,'All') = 'All')
	)
		
--get latest outletkey
if object_id('tempdb..#LatestOutletKey_YTD') is not null drop table #LatestOutletKey_YTD
select distinct LatestOutletKey, UserKey, [Login]
into #LatestOutletKey_YTD
from #Outlet_YTD


--get current year policies
if object_id('tempdb..#cyp_YTD') is not null drop table #cyp_YTD
select
	convert(nvarchar(50),null) as LatestOutletKey,
	p.OutletAlphaKey,
	isnull(p.UserKey,'Cover-More') as UserKey,
	sum(p.NewPolicyCount) as PolicyCount,
	sum(p.GrossAdminFee + Commission) as AgencyCommission,
	sum(p.GrossPremium) as SellPrice	
into #cyp_YTD
from
	penPolicyTransSummary p
	join penOutlet o on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
where
	p.CountryKey = @Country and
	p.PostingDate between @rptStartDate_YTD and @rptEndDate_YTD and
	o.LatestOutletKey in (select distinct LatestOutletKey from #LatestOutletKey_YTD)
group by
	p.OutletAlphaKey,
	isnull(p.UserKey,'Cover-More')


update p
set p.LatestOutletKey = la.LatestOutletKey
from
	#cyp_YTD p
	cross apply
	(
		select top 1 l.LatestOutletKey
		from 
			#LatestOutletKey_YTD l
			join penOutlet o on l.LatestOutletKey = o.LatestOutletKey and o.OutletStatus = 'Current'
		where
			o.OutletAlphaKey = p.OutletAlphaKey				
	) la
	


--get prior year policies
if object_id('tempdb..#pyp_YTD') is not null drop table #pyp_YTD
select
	convert(nvarchar(50),null) as LatestOutletKey,
	p.OutletAlphaKey,
	isnull(p.UserKey,'Cover-More') as UserKey,
	sum(p.NewPolicyCount) as PolicyCount,
	sum(p.GrossAdminFee + Commission) as AgencyCommission,
	sum(p.GrossPremium) as SellPrice		
into #pyp_YTD	
from
	penPolicyTransSummary p
	join penOutlet o on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
where
	p.CountryKey = @Country and
	p.YAGOPostingDate between @rptStartDate_YTD and @rptEndDate_YTD and
	o.LatestOutletKey in (select distinct LatestOutletKey from #LatestOutletKey_YTD)
group by
	p.OutletAlphaKey,
	isnull(p.UserKey,'Cover-More')
	
update p
set p.LatestOutletKey = la.LatestOutletKey
from
	#pyp_YTD p
	cross apply
	(
		select top 1 l.LatestOutletKey
		from 
			#LatestOutletKey_YTD l
			join penOutlet o on l.LatestOutletKey = o.LatestOutletKey and o.OutletStatus = 'Current'
		where
			o.OutletAlphaKey = p.OutletAlphaKey				
	) la

	

--get current year quotes
if object_id('tempdb..#cyq_YTD') is not null drop table #cyq_YTD
select
	convert(nvarchar(50),null) as LatestOutletKey,
	q.OutletAlphaKey,
	isnull(u.UserKey,'Cover-More') as UserKey,
	count(q.QuoteID) as QuoteCount
into #cyq_YTD
from
	penQuote q
	join penOutlet o on q.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
	left join penUser u on q.OutletAlphaKey = u.OutletAlphaKey and q.UserName = u.[Login] and u.UserStatus = 'Current'
where
	q.CountryKey = @Country and
	q.CreateDate between @rptStartDate_YTD and @rptEndDate_YTD and
	o.LatestOutletKey in (select distinct LatestOutletKey from #LatestOutletKey_YTD)
group by
	q.OutletAlphaKey,
	isnull(u.UserKey,'Cover-More')
	
update q
set q.LatestOutletKey = la.LatestOutletKey
from
	#cyq_YTD q
	cross apply
	(
		select top 1 l.LatestOutletKey
		from 
			#LatestOutletKey_YTD l
			join penOutlet o on l.LatestOutletKey = o.LatestOutletKey and o.OutletStatus = 'Current'
		where
			o.OutletAlphaKey = q.OutletAlphaKey				
	) la


--get prior year quotes
if object_id('tempdb..#pyq_YTD') is not null drop table #pyq_YTD
select
	convert(nvarchar(50),null) as LatestOutletKey,
	q.OutletAlphaKey,
	isnull(u.UserKey,'Cover-More') as UserKey,
	count(q.QuoteID) as QuoteCount
into #pyq_YTD
from
	penQuote q
	join penOutlet o on q.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
	left join penUser u on q.OutletAlphaKey = u.OutletAlphaKey and q.UserName = u.[Login] and u.UserStatus = 'Current'
where
	q.CountryKey = @Country and
	q.YAGOCreateDate between @rptStartDate_YTD and @rptEndDate_YTD and
	o.LatestOutletKey in (select distinct LatestOutletKey from #LatestOutletKey_YTD)
group by
	q.OutletAlphaKey,
	isnull(u.UserKey,'Cover-More')
	
	
update q
set q.LatestOutletKey = la.LatestOutletKey
from
	#pyq_YTD q
	cross apply
	(
		select top 1 l.LatestOutletKey
		from 
			#LatestOutletKey_YTD l
			join penOutlet o on l.LatestOutletKey = o.LatestOutletKey and o.OutletStatus = 'Current'
		where
			o.OutletAlphaKey = q.OutletAlphaKey				
	) la


if object_id('tempdb..#OutletFinal_YTD') is not null drop table #OutletFinal_YTD
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
into #OutletFinal_YTD		
from
	#LatestOutletKey_YTD l
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
		from #Outlet_YTD
		where 
			LatestOutletKey = l.LatestOutletKey and
			UserKey = l.UserKey
	) o		


----------------------------------------------------------------------------------

select
	'MTD' as [Period Type],
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

union all
	
select
	'YTD' as [Period Type],
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
	@rptStartDate_YTD as rptStartDate,
	@rptEndDate_YTD as rptEndDate
from
	#OutletFinal_YTD o
	outer apply
	(
		select
			sum(PolicyCount) as PolicyCount,
			sum(AgencyCommission) as AgencyCommission,
			sum(SellPrice) as SellPrice
		from
			#cyp_YTD
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
			#pyp_YTD
		where
			LatestOutletKey = o.LatestOutletKey and
			UserKey = o.UserKey						
	) pyp
	outer apply
	(
		select
			sum(QuoteCount) as QuoteCount
		from
			#cyq_YTD
		where
			LatestOutletKey = o.LatestOutletKey and
			UserKey = o.UserKey
	) cyq
	outer apply
	(
		select
			sum(QuoteCount) as QuoteCount
		from
			#pyq_YTD
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

--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
		
drop table #Outlet
drop table #LatestOutletKey
drop table #OutletFinal
drop table #cyp
drop table #pyp
drop table #cyq
drop table #pyq

drop table #Outlet_YTD
drop table #LatestOutletKey_YTD
drop table #OutletFinal_YTD
drop table #cyp_YTD
drop table #pyp_YTD
drop table #cyq_YTD
drop table #pyq_YTD

End
GO
