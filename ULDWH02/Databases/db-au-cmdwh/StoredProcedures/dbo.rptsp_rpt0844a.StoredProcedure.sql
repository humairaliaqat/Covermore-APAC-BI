USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0844a]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0844a]	@DateRange varchar(30),
										@StartDate varchar(10),
										@EndDate varchar(10)
as

SET NOCOUNT ON

										
/****************************************************************************************************/
--  Name:           rptsp_RPT0844a
--  Author:         Saurabh Date
--  Date Created:   20180410
--  Description:    Additional script of RPT0844 to fetch consultant sales for Flight Centre in reporting period
--
--  Parameters:     @@DateRange: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2018-01-01
--					@EndDate: if_User Defined. Format: YYYY-MM-DD eg. 2018-01-01
--   
--  Change History: 20180410 - SD - Created
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
DECLARE @rptStartDateLY datetime
DECLARE @rptEndDateLY datetime


--get reporting dates
if @DateRange = '_User Defined'
	select @rptStartDate = @StartDate,
		   @rptEndDate = @EndDate
else
	select @rptStartDate = StartDate, 
		   @rptEndDate = EndDate
	from [db-au-cmdwh].dbo.vDateRange
	where DateRange = @DateRange

SELECT @rptStartDateLY = DATEADD(year,-1,@rptStartDate)
	, @rptEndDateLY = DATEADD(year,-1,@rptEndDate)
	
if object_id('tempdb..#Outlet') is not null drop table #Outlet
select distinct
	o.OutletKey, 
	o.OutletAlphaKey, 
	o.LatestOutletKey,
	u.UserKey,
	u.[Login],
	u.Consultant,
	lo.GroupCode,
	lo.GroupName,
	lo.SubGroupCode,
	lo.SubGroupName,
	lo.AlphaCode,
	lo.OutletName,
	lo.OutletType,
	lo.EGMNation,
	lo.FCNation,
	lo.FCArea,
	lo.StateSalesArea,
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
			GroupCode,
			SubGroupCode,
			SubGroupName,
			AlphaCode,
			OutletName,
			OutletType,
			ContactState,
			Branch,
			BDMName,
			SalesSegment,
			TradingStatus,
			EGMNation,
			FCNation,
			FCArea,
			StateSalesArea			
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
	lo.GroupCode  =  'FL' AND
	--Excluding Test Alpha
	lo.AlphaCode  NOT IN ('AAN0280','FLN1025','FLN1312','FLN1449','FLN1469','FLN1531','FLN1589','FLN1600','FLQ1880','ZZZZ999') 
	
union

select distinct
	o.OutletKey, 
	o.OutletAlphaKey, 
	o.LatestOutletKey,
	u.UserKey,
	u.[Login],
	u.Consultant,
	lo.GroupCode,
	lo.GroupName,
	lo.SubGroupCode,
	lo.SubGroupName,
	lo.AlphaCode,
	lo.OutletName,
	lo.OutletType,
	lo.EGMNation,
	lo.FCNation,
	lo.FCArea,
	lo.StateSalesArea,
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
			GroupCode,
			SubGroupCode,
			SubGroupName,
			AlphaCode,
			OutletName,
			OutletType,
			ContactState,
			Branch,
			BDMName,
			SalesSegment,
			TradingStatus,
			EGMNation,
			FCNation,
			FCArea,
			StateSalesArea		
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
	lo.GroupCode  =  'FL' AND
	--Excluding Test Alpha
	lo.AlphaCode  NOT IN ('AAN0280','FLN1025','FLN1312','FLN1449','FLN1469','FLN1531','FLN1589','FLN1600','FLQ1880','ZZZZ999') 

		
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
	sum(p.GrossPremium) [SellPrice]
into #cyp	
from
	penPolicyTransSummary p
	join penOutlet o on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
	left join penUser pu on pu.UserKey = p.UserKey and pu.UserStatus = 'Current'
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
	

if object_id('tempdb..#OutletFinal') is not null drop table #OutletFinal
select distinct
	l.LatestOutletKey,
	l.UserKey,
	o.Consultant,
	o.GroupCode,	
	o.GroupName,
	o.SubGroupCode,
	o.SubGroupName,
	o.AlphaCode,
	o.OutletName,
	o.EGMNation,
	o.FCNation,
	o.FCArea,
	o.StateSalesArea,
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
			GroupCode,		
			GroupName,
			SubGroupCode,
			SubGroupName,
			AlphaCode,
			OutletName,
			EGMNation,
			FCNation,
			FCArea,
			StateSalesArea,
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


if object_id('tempdb..#out') is not null
    drop table #out
	
select
	o.GroupCode,
	o.[GroupName],
	o.[SubGroupCode],
	o.[SubGroupName],
	o.[AlphaCode],
	o.[OutletName],
	o.EGMNation,
	o.FCNation,
	o.FCArea,
	o.StateSalesArea,
	o.[OutletType],
	o.[ContactState],
	o.[Branch],
	o.[BDMName],
	o.[Consultant],
	lg.login,
	o.[SalesSegment],
	o.[TradingStatus],
	sum(isnull(cyp.SellPrice,0)) as SellPrice,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate,
	@rptStartDateLY as rptStartDateLY,
	@rptEndDateLY as rptEndDateLY
into #out
from
	#OutletFinal o
	outer apply
	(
		select
			sum(SellPrice) as SellPrice
		from
			#cyp
		where
			LatestOutletKey = o.LatestOutletKey and
			UserKey = o.UserKey
	) cyp
	Outer apply
	(
		select
			Top 1
			lg.login
		From
			penUser lg
		Where
			Status = 'Active' and
			lg.UserKey = o.UserKey
	) lg
where
	o.[GroupName] is not null	
group by
	o.GroupCode,
	o.[GroupName],
	o.SubGroupCode,
	o.[SubGroupName],
	o.[AlphaCode],
	o.[OutletName],
	o.EGMNation,
	o.FCNation,
	o.FCArea,
	o.StateSalesArea,
	o.[OutletType],
	o.[ContactState],
	o.[Branch],
	o.[BDMName],
	o.[Consultant],
	lg.login,
	o.[SalesSegment],
	o.[TradingStatus]

select 
	Consultant,
	login,
	AlphaCode [AgencyCode],
	OutletName [AgencyName],
	FCNation,
	FCArea,
	SellPrice,
	rptStartDate [StartDate],
	rptEndDate [EndDate],
	rptStartDateLY [StartDateLY],
	rptEndDateLY [EndDateLY]
from
    #out
where
	SellPrice <> 0
    
		
drop table #Outlet
drop table #LatestOutletKey
drop table #OutletFinal
drop table #cyp
GO
