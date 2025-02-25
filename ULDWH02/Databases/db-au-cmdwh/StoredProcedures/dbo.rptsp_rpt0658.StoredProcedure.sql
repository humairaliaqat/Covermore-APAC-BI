USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0658]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0658]	@Country varchar(2),
									@DateRange varchar(30),
									@StartDate datetime,
									@EndDate datetime
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           rptsp_rpt0658
--  Author:         Linus Tor
--  Date Created:   20150708
--  Description:    This stored procedure returns customers that had repeat business for
--					Australia Post, Medibank, and IAL
--
--  Parameters:		@Country:		Required. AU, NZ, SG, MY, ID, CN, UK, IN
--					@DateRange:		Required. Standard date range or _User Defined
--					@StartDate:		Required if _User Defined. Format: YYYY-MM-DD hh:mm:ss eg. 2015-01-01 00:00:00
--					@EndDate:		Required if _User Defined. Format: YYYY-MM-DD hh:mm:ss eg. 2015-01-01 00:00:00
--   
--  Change History: 20150708 - LT - Created
--                  
/****************************************************************************************************/

--uncomment to debug
/*
declare @Country varchar(2)
declare @DateRange varchar(30)
declare @StartDate datetime
declare @EndDate datetime
select @Country = 'AU', @DateRange = 'Last Month', @StartDate = null, @EndDate = null
*/

declare @rptStartDate datetime
declare @rptEndDate datetime

--get reporting dates
if @DateRange = '_User Defined'
	select @rptStartDate = @StartDate,
		   @rptEndDate = @EndDate
else
	select @rptStartDate = StartDate, 
		   @rptEndDate = EndDate
	from [db-au-cmdwh].dbo.vDateRange
	where DateRange = @DateRange

select @rptStartDate = '2011-01-01'			--anchor date

--get recent travellers
if object_id('tempdb..#rpt0658_RecentTravellers') is not null drop table #rpt0658_RecentTravellers
select 
	o.CountryKey as Country,
	o.SuperGroupName,
	ltrim(rtrim(ptv.FirstName)) + '-' + ltrim(rtrim(ptv.LastName)) + '-' + convert(varchar(10),ptv.DOB,112) CustomerKey,
	pol.PolicyKey,
	pol.CountryKey,
	pol.CompanyKey,
	pol.PolicyNumber,
	Pol.IssueDate,
	pol.AreaType,
	pol.TripType,
	pts.NewPolicyCount as TotalPolicyCount,
	row_number() over(partition by	ltrim(rtrim(ptv.FirstName)) + '-' + ltrim(rtrim(ptv.LastName)) + '-' + convert(varchar(10),ptv.DOB,112), 
									pol.AreaType, 
									pol.TripType, 
									o.SuperGroupName,
									o.CountryKey
					  order by pol.IssueDate) Rnk
into #rpt0658_RecentTravellers
from 
	[db-au-cmdwh].dbo.penPolicyTraveller ptv
	inner join [db-au-cmdwh].dbo.penPolicy pol on 
		ptv.PolicyKey = pol.PolicyKey
	inner join [db-au-cmdwh].dbo.penOutlet o on 
		o.OutletAlphaKey = pol.OutletAlphaKey and 
		o.OutletStatus = 'Current'
	inner join [db-au-cmdwh].dbo.penPolicyTransSummary pts on
		pol.PolicyKey = pts.PolicyKey
where
	pol.CountryKey = @Country and
	o.SuperGroupName in ('Australia Post','IAL','Medibank') and
	ptv.isPrimary = 1 and
	pts.PostingDate >= @rptStartDate and
	pts.PostingDate <= @rptEndDate and
	ptv.DOB is not null and												--exclude unmatchables
	ltrim(rtrim(ptv.FirstName)) + ltrim(rtrim(ptv.LastName)) <> ''		--exclude unmatchables


--work out purchase interval in days
if object_id('tempdb..#rpt0658_RecentTravellerInterval') is not null drop table #rpt0658_RecentTravellerInterval
select 
	a.*, 
	isnull(DATEDIFF(day,b.IssueDate, a.IssueDate),0) PurchaseInterval
into #rpt0658_RecentTravellerInterval
from 
	#rpt0658_RecentTravellers a
	left outer join #rpt0658_RecentTravellers b on 
		a.CustomerKey = b.CustomerKey and 
		a.AreaType = b.AreaType and 
		a.TripType = b.TripType and 
		a.SuperGroupName = b.SuperGroupName and 
		a.Rnk - 1 = b.Rnk
order by 
	a.rnk


--get return travellers
if object_id('tempdb..#rpt0658_ReturnTravellers') is not null drop table #rpt0658_ReturnTravellers
select
	case when count(distinct p1.PolicyKey) > 1 then 1
		 else 0
	end as ReturnCustomer,
	p1.Country,
	p1.SuperGroupName,
	p1.CustomerKey,
	p1.AreaType,
	p1.TripType,
	count(distinct p1.PolicyKey) as NumberOfPolicies,
	sum(p1.PurchaseInterval) as PurchaseInterval,
	( 
      select 
			PolicyNumber + ','
      from 
			#rpt0658_RecentTravellerInterval p2
      where
			p2.CustomerKey = p1.CustomerKey and 
			p2.AreaType = p1.AreaType and 
			p2.TripType = p1.TripType and 
			p2.SuperGroupName = p1.SuperGroupName and
			p2.Country = p1.Country
      order by PolicyNumber
      for xml path('')
	) as Policies
into #rpt0658_ReturnTravellers
from 
	#rpt0658_RecentTravellerInterval p1
group by 
	p1.CustomerKey, 
	p1.AreaType, 
	p1.TripType, 
	p1.SuperGroupName,
	p1.Country


--output main data
select 
	a.Country,
	a.SuperGroupName,
	a.AreaType,
	a.TripType,
	count(1) as UniqueRepeatCustomer, 
	sum(a.NumberOfPolicies) as RepeatPolicyCount,
	sum(a.PurchaseInterval)/(sum(a.NumberOfPolicies) - 1) as AvgPurchaseIntervalDays
into #rpt0658_main
from 
	#rpt0658_ReturnTravellers a		
where 
	a.returnCustomer = 1
group by 
	a.Country,
	a.SuperGroupName,
	a.AreaType,
	a.TripType


select
	a.Country,
	a.SuperGroupName,
	a.AreaType,
	a.TripType,
	a.UniqueRepeatCustomer,
	a.RepeatPolicyCount,
	a.AvgPurchaseIntervalDays,
	b.TotalPolicyCount,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate
from
	#rpt0658_main a
	outer apply
	(
		select sum(pts.NewPolicyCount) as TotalPolicyCount
		from
			penPolicy p
			join penPolicyTransSummary pts on
				p.PolicyKey = pts.PolicyKey
			join penOutlet o on 
				p.OutletAlphaKey = o.OutletAlphaKey and
				o.OutletStatus = 'Current'
		where
			o.CountryKey = a.Country and
			o.SuperGroupName = a.SuperGroupName and
			p.AreaType = a.AreaType and
			p.TripType = a.TripType and
			pts.PostingDate >= @rptStartDate and
			pts.PostingDate <= @rptEndDate
	) b



drop table #rpt0658_main
drop table #rpt0658_RecentTravellerInterval
drop table #rpt0658_RecentTravellers
drop table #rpt0658_ReturnTravellers

GO
