USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1047]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[rptsp_rpt1047]	@Country varchar(5), 
								@DateRange varchar(30), 
								@StartDate datetime, 
								@EndDate datetime
as

SET NOCOUNT ON

/****************************************************************************************************/
--  Name:           RPT1047 - Malaysia Airlines Data Analysis
--  Author:         Linus Tor
--  Date Created:   20190131
--  Description:    This stored procedure returns Malaysia Airlines sales data
--  Parameters:     @Country  :	Country code
--					@DateRange: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2018-07-01
--					@EndDate  : if_User Defined. Format: YYYY-MM-DD eg. 2018-07-01
--   
--  Change History: 20190131 - LT - Procedure created
--
   
/****************************************************************************************************/

--uncomment to debug
/*
declare	@Country varchar(5),
		@DateRange varchar(30),
		@StartDate varchar(10),
		@EndDate varchar(10)

select @Country = 'All', @DateRange = 'Last Month'
*/


declare @rptStartDate datetime
declare @rptEndDate datetime

--get reporting dates
if @DateRange = '_User Defined'
	select 
		@rptStartDate = @StartDate,
		@rptEndDate = @EndDate
else
	select 
		@rptStartDate = StartDate, 
		@rptEndDate = EndDate
	from 
		vDateRange
	where 
		DateRange = @DateRange

select
	o.CountryKey as Country,
	o.Channel,
	p.AreaName as DestinationRegion,
	case when p.TripDuration <= 5 then '1-5 days'
		 when p.TripDuration between 6 and 10 then '6-10 days'
		 when p.TripDuration between 11 and 15 then '11-15 days'
		 when p.TripDuration between 16 and 20 then '16-20 days'
		 when p.TripDuration between 21 and 25 then '21-25 days'
		 when p.TripDuration between 26 and 30 then '26-30 days'
		 when p.TripDuration >= 31 then '>30 days'
	end as TripDuration,
	p.ProductName + ' ' + p.PlanCode + ' ' + p.PlanName as PolicyType,
	convert(datetime,convert(varchar(8),p.IssueDate,120)+'01') as PurchasedMonth,
	convert(datetime,convert(varchar(8),p.TripStart,120)+'01') as TravellingMonth,
	sum(pts.NewPolicyCount) as PolicySold,
	sum(pts.GrossPremium) as Premium,
	sum(pts.TravellersCount) as TravellersCount,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate
from
	penPolicy p
	inner join penOutlet o on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
	inner join penPolicyTransSummary pts on p.PolicyKey = pts.PolicyKey
where
	(
		@Country = 'All' or
		o.CountryKey = @Country
	) and
	o.SuperGroupName = 'Malaysia Airlines' and
	p.IssueDate >= @rptStartDate and
	p.IssueDate < dateadd(d,1,@rptEndDate)
group by
	o.CountryKey,
	o.Channel,
	p.AreaName,
	case when p.TripDuration <= 5 then '1-5 days'
		 when p.TripDuration between 6 and 10 then '6-10 days'
		 when p.TripDuration between 11 and 15 then '11-15 days'
		 when p.TripDuration between 16 and 20 then '16-20 days'
		 when p.TripDuration between 21 and 25 then '21-25 days'
		 when p.TripDuration between 26 and 30 then '26-30 days'
		 when p.TripDuration >= 31 then '>30 days'
	end,
	p.ProductName + ' ' + p.PlanCode + ' ' + p.PlanName,
	convert(datetime,convert(varchar(8),p.IssueDate,120)+'01'),
	convert(datetime,convert(varchar(8),p.TripStart,120)+'01')
order by 1,2,3,4,5
GO
