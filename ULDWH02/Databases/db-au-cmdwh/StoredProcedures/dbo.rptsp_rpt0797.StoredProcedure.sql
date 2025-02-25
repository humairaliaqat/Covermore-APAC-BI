USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0797]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0797] @DateRange varchar(30),
								  @StartDate datetime,
								  @EndDate datetime
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0797
--  Author:         Linus Tor
--  Date Created:   20160725
--  Description:    This stored procedure outputs FC USA sales this fiscal year (2017) with FC USA actual sales
--					for FY2016. This stored procedure will be obsolete after FY2017.
--  Parameters:     
--  Change History: 
--                  20160725	-	LT	-	Created
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate datetime
declare @EndDate datetime
select @DateRange = 'Current Fiscal Year', @StartDate = null, @EndDate = null
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


if object_id('tempdb..#outlet') is not null drop table #outlet
select
	o.ExtID as T3,
	o.AlphaCode,
	o.OutletName,
	o.GroupName,
	o.SubGroupName,
	o.FCNation,
	o.FCArea,
	o.StateSalesArea
into #outlet
from
	penOutlet o
where
	o.CountryKey = 'US' and
	o.SuperGroupName = 'Flight Center' and
	o.OutletStatus = 'Current' and
	o.AlphaCode not like 'Test%'

union all

select distinct
	u.T3,
	u.T3 as AlphaCode,
	u.Store as OutletName,
	'Flight Center' as GroupName,
	u.Brand as SubGroupName,
	u.Brand as FCNation,
	'UNKNOWN' as FCArea,
	'UNKNOWN' as StateSalesArea
from
	usrFCUSASalesFY16 u
where
	AlphaCode is null

if object_id('tempdb..#date') is not null drop table #date
select
	case when o.AlphaCode = 'UNKNOWN' then o.T3 else o.AlphaCode end as AlphaCode,
	d.FMonth
into #date
from
	#outlet o
	cross join
	(
		select distinct CurMonthStart as FMonth
		from Calendar
		where [Date] between convert(varchar(10),@rptStartDate,120) and convert(varchar(10),@rptEndDate,120)
	) d


if object_id('tempdb..#cy') is not null drop table #cy
select
	o.AlphaCode,
	convert(datetime,convert(varchar(8),p.IssueDate,120) + '01') as FMonth,
	sum(p.GrossPremium) as SellPrice,
	sum(p.NewPolicyCount) as PolicyCount
into #cy
from
	penPolicyTransSummary p
	inner join penOutlet o on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
where
	o.CountryKey = 'US' and
	o.SuperGroupName = 'Flight Center' and
	o.AlphaCode in (select distinct AlphaCode from #outlet) and
	p.PostingDate between convert(varchar(10),@rptStartDate,120) and convert(varchar(10),@rptEndDate,120)
group by
	o.AlphaCode,
	convert(datetime,convert(varchar(8),p.IssueDate,120) + '01')


if object_id('tempdb..#py') is not null drop table #py
select
	isnull(p.AlphaCode,p.T3) as AlphaCode,
	dateadd(year,1,p.FMonth) as FMonth,
	sum(p.GrossPremium) as SellPrice,
	sum(p.PolicyCount) as PolicyCount
into #py
from
	usrFCUSASalesFY16 p
where
	p.FMonth between convert(varchar(10),dateadd(year,-1,@rptStartDate),120) and convert(varchar(10),dateadd(year,-1,@rptEndDate),120)
group by
	isnull(p.AlphaCode,p.T3),
	dateadd(year,1,p.FMonth)


select
	o.T3,
	o.AlphaCode,
	o.OutletName,
	o.GroupName,
	o.SubGroupName,
	o.FCNation,
	o.FCArea,
	o.[State],
	d.[FMonth],
	sum(cy.PolicyCount) as PolicyCount,
	sum(cy.SellPrice) as SellPrice,
	sum(py.PolicyCountPY) as PolicyCountPY,
	sum(py.SellPricePY) as SellPricePY,
	@rptStartDate as StartDate,
	@rptEndDate as EndDate
from
	#date d
	outer apply
	(
		select top 1 T3, AlphaCode, OutletName, GroupName, SubGroupName, FCNation, FCArea, StateSalesArea as [State]
		from #outlet
		where  AlphaCode = d.AlphaCode
	) o
	outer apply
	(
		select sum(PolicyCount) as PolicyCount,
			   sum(SellPrice) as SellPrice
		from #cy
		where AlphaCode = d.AlphaCode and
			FMonth = d.FMonth
	) cy
	outer apply
	(
		select sum(PolicyCount) as PolicyCountPY,
			   sum(SellPrice) as SellPricePY
		from #py
		where AlphaCode = d.AlphaCode and
			FMonth = d.FMonth
	) py
group by
	o.T3,
	o.AlphaCode,
	o.OutletName,
	o.GroupName,
	o.SubGroupName,
	o.FCNation,
	o.FCArea,
	o.[State],
	d.FMonth			


drop table #cy
drop table #outlet
drop table #py



GO
