USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0786]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0786]   @DateRange varchar(30),
										@StartDate varchar(10),
										@EndDate varchar(10)
as

SET NOCOUNT ON

/****************************************************************************************************/
--  Name:           rptsp_rpt0786
--  Author:         Ganesh Parab
--  Date Created:   20160606
--  Description:    This stored procedure returns isolate stores and consultants and provide comparisons and variations on previous periods for MEDIBANK RETAIL
--
--  Parameters:     @ReportingPeriod: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2016-01-01
--					@EndDate: if_User Defined. Format: YYYY-MM-DD eg. 2016-01-01
--   
--  Change History: 20160606 - GP - Created
--                  
/****************************************************************************************************/

--DECLARE
--	@DateRange varchar(30),
--	@StartDate varchar(10),
--	@EndDate varchar(10)
--SET @DateRange = 'Last Month'

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
if object_id('tempdb..#Outlet') is not null drop table #Outlet
select
	o.OutletAlphaKey,
	lo.GroupName,
	lo.SubGroupName,
	lo.AlphaCode,
	lo.OutletName,
	o.LatestOutletKey,
	oso.StoreCode,
	oso.StoreName
into #Outlet	
from
	penOutlet o
	outer apply 
	(
		select top 1 SuperGroupName, GroupName, SubGroupName, LatestOutletKey, CountryKey, AlphaCode, OutletName
		from penOutlet l 
		where l.OutletStatus = 'Current' and l.OutletKey = o.LatestOutletKey
	) lo
	outer apply 
	(
		select StoreCode, StoreName
		from penOutletStore os 
		where os.StoreStatus = 'ACTIVE' and os.OutletAlphaKey = o.OutletAlphaKey
	) oso
where
	lo.CountryKey = 'AU' and
	o.OutletStatus = 'Current' and
	(
		lo.SuperGroupName = 'Medibank'
		and lo.SubGroupName = 'Retail'
	)

--get latestoutletkey and dates
if object_id('tempdb..#LatestOutletKey') is not null drop table #LatestOutletKey
select 
	o.LatestOutletKey,
	d.[Date]
into #LatestOutletKey	
from 
	(select distinct LatestOutletKey from #Outlet) o
	cross join Calendar d
where
	d.[Date] between @rptStartDate and @rptEndDate


--get current year policycount on StoreCode and Consultantname 
if object_id('tempdb..#cyp') is not null drop table #cyp
select
	o.LatestOutletKey,
	p.PostingDate as [Date],
	isnull(upper(p.StoreCode), '') StoreCode,
	isnull(pu.FirstName, '') + ' ' + isnull(pu.LastName, '') [Consultantname],
	sum(p.NewPolicyCount) as PolicyCount,
	sum(p.GrossPremium) as SellPrice
into #cyp	
from
	penPolicyTransSummary p
	inner join penOutlet o
		on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
	left outer join penUser pu
		on pu.UserKey = p.UserKey
			and pu.UserStatus = 'Current'
where
	o.LatestOutletKey in (select distinct LatestOutletKey from #LatestOutletKey) and
	p.PostingDate between @rptStartDate and @rptEndDate
group by
	o.LatestOutletKey,
	p.PostingDate,
	upper(p.StoreCode),
	isnull(pu.FirstName, '') + ' ' + isnull(pu.LastName, '')


--get last year policycount on StoreCode and Consultantname 
if object_id('tempdb..#pyp') is not null drop table #pyp
select
	o.LatestOutletKey,
	p.YAGOPostingDate as [Date],
	isnull(upper(p.StoreCode), '') StoreCode,
	isnull(pu.FirstName, '') + ' ' + isnull(pu.LastName, '') [Consultantname],
	sum(p.NewPolicyCount) as PolicyCount,
	sum(p.GrossPremium) as SellPrice
into #pyp
from
	penPolicyTransSummary p
	inner join penOutlet o
		on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
	left outer join penUser pu
		on pu.UserKey = p.UserKey
			and pu.UserStatus = 'Current'
where
	o.LatestOutletKey in (select distinct LatestOutletKey from #LatestOutletKey) and
	p.YAGOPostingDate between @rptStartDate and @rptEndDate
group by
	o.LatestOutletKey,
	p.YAGOPostingDate,
	upper(p.StoreCode),
	isnull(pu.FirstName, '') + ' ' + isnull(pu.LastName, '')


--get current year quotecount on StoreCode and Consultantname 
if object_id('tempdb..#cyq') is not null drop table #cyq
select
	o.LatestOutletKey,
	q.CreateDate as [Date],
	isnull(upper(q.StoreCode), '') StoreCode,
	case when q.OutletAlphaKey like 'AU-TIP7-RVV%' and q.PreviousPolicyNumber is not null then 'SysUser SysUser'
	else q.ConsultantName 
	end ConsultantName,
	count(distinct case when q.ParentQuoteID is null then q.QuoteKey else null end) QuoteCount
into #cyq	
from
	penQuote q
	inner join penOutlet o on q.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
where
	o.LatestOutletKey in (select distinct LatestOutletKey from #LatestOutletKey) and
	q.CreateDate between @rptStartDate and @rptEndDate
group by
	o.LatestOutletKey,
	q.CreateDate,
	upper(q.StoreCode),
	case when q.OutletAlphaKey like 'AU-TIP7-RVV%' and q.PreviousPolicyNumber is not null then 'SysUser SysUser'
	else q.ConsultantName 
	end

--get last year quotecount on StoreCode and Consultantname 
if object_id('tempdb..#pyq') is not null drop table #pyq
select
	o.LatestOutletKey,
	q.YAGOCreateDate as [Date],
	isnull(upper(q.StoreCode), '') StoreCode,
	case when q.OutletAlphaKey like 'AU-TIP7-RVV%' and q.PreviousPolicyNumber is not null then 'SysUser SysUser'
	else q.ConsultantName 
	end ConsultantName,
	count(distinct case when q.ParentQuoteID is null then q.QuoteKey else null end) QuoteCount
into #pyq	
from
	penQuote q
	inner join penOutlet o on q.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
where
	o.LatestOutletKey in (select distinct LatestOutletKey from #LatestOutletKey) and
	q.YAGOCreateDate between @rptStartDate and @rptEndDate
group by
	o.LatestOutletKey,
	q.YAGOCreateDate,
	upper(q.StoreCode),
	case when q.OutletAlphaKey like 'AU-TIP7-RVV%' and q.PreviousPolicyNumber is not null then 'SysUser SysUser'
	else q.ConsultantName 
	end


if object_id('tempdb..#cosultant') is not null drop table #cosultant
select LatestOutletKey, StoreCode, Consultantname into #cosultant from #cyp
union
select LatestOutletKey, StoreCode, Consultantname from #pyp
union
select LatestOutletKey, StoreCode, Consultantname from #cyq
union
select LatestOutletKey, StoreCode, Consultantname from #pyq


if object_id('tempdb..#LatestOutletKeystore') is not null drop table #LatestOutletKeystore
select a.*, b.date, c.Consultantname
into #LatestOutletKeystore
from #Outlet a
inner join #LatestOutletKey b
on a.LatestOutletKey = b.LatestOutletKey
left outer join #cosultant c
on a.LatestOutletKey = c.LatestOutletKey
	and a.StoreCode = c.StoreCode


select
	g.GroupName,
	g.SubGroupName,
	g.AlphaCode,
	g.OutletName,
	a.[Date],
	a.StoreCode,
	a.StoreName,
	case when a.Consultantname > '' then a.Consultantname
			else 'Cover-More CSR'
	end as Consultantname,
	sum(isnull(cyp.PolicyCount,0)) as PolicyCount,
	sum(isnull(cyp.SellPrice,0)) as SellPrice,
	sum(isnull(pyp.PolicyCount,0)) as YAGO_PolicyCount,
	sum(isnull(pyp.SellPrice,0)) as YAGO_SellPrice,
	sum(isnull(cyq.QuoteCount,0)) as QuoteCount,
	sum(isnull(pyq.QuoteCount,0)) as YAGO_QuoteCount,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate	
from
	#LatestOutletKeystore a
	outer apply
	(
		select top 1 GroupName, SubGroupName, AlphaCode, OutletName
		from #Outlet
		where LatestOutletKey = a.LatestOutletKey
	) g
	outer apply
	(
		select
			StoreCode,
			Consultantname,
			sum(PolicyCount) as PolicyCount,
			sum(SellPrice) as SellPrice
		from
			#cyp
		where
			LatestOutletKey = a.LatestOutletKey and
			[Date] = a.[Date] and
			StoreCode = a.StoreCode and
			Consultantname = a.Consultantname
		group by
			StoreCode,
			Consultantname
	) cyp			
	outer apply
	(
		select
			StoreCode,
			Consultantname,
			sum(PolicyCount) as PolicyCount,
			sum(SellPrice) as SellPrice
		from
			#pyp
		where
			LatestOutletKey = a.LatestOutletKey and
			[Date] = a.[Date] and
			StoreCode = a.StoreCode and
			Consultantname = a.Consultantname
		group by
			StoreCode,
			Consultantname
	) pyp
	outer apply
	(
		select
			StoreCode,
			ConsultantName,
			sum(QuoteCount) as QuoteCount
		from
			#cyq
		where
			LatestOutletKey = a.LatestOutletKey and
			[Date] = a.[Date] and
			StoreCode = a.StoreCode and
			Consultantname = a.Consultantname
		group by
			StoreCode,
			ConsultantName
	) cyq						
	outer apply
	(
		select
			StoreCode,
			ConsultantName,
			sum(QuoteCount) as QuoteCount
		from
			#pyq
		where
			LatestOutletKey = a.LatestOutletKey and
			[Date] = a.[Date] and
			StoreCode = a.StoreCode and
			Consultantname = a.Consultantname
		group by
			StoreCode,
			ConsultantName
	) pyq
where a.Consultantname is not null
group by
	g.GroupName,
	g.SubGroupName,
	g.AlphaCode,
	g.OutletName,
	a.[Date],
	a.StoreCode,
	a.StoreName,
	case when a.Consultantname > '' then a.Consultantname
			else 'Cover-More CSR'
	end
GO
