USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1019a]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt1019a]	@Country varchar(50), @DateRange varchar(30)
as


SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt1019a
--  Author:         Linus Tor
--  Date Created:   20180910
--  Description:    Returns HR attrition by Country statistics for the last 12 months based on the End Date of Date Range
--					This SP returns data for 
--  Parameters:     @DateRange: required. One of 'Last Month','Last January','Last February','Last March','Last April',
--								'Last May','Last June','Last August','Last September','Last October','Last November','Last December'
--                  
--  Change History: 
--                  20180919 - LT - Created
--					20190121 - LT - Added filter to exclude State with NULL value

/****************************************************************************************************/


--uncomment to debug
/*
declare @DateRange varchar(30), @Country varchar(50)
select @DateRange = 'Last Month', @Country = 'Australia'
*/

declare @rptStartDate datetime
declare @rptEndDate datetime
declare @rptYearStart datetime
declare @rptYearEnd datetime
declare @rptLTMStart datetime
declare @rptLTMEnd datetime


if @DateRange is null 
	select @rptStartDate = StartDate,
		   @rptEndDate = EndDate
	from
		vDateRange
	where
		DateRange = 'Last Month'
else
	select @rptStartDate = StartDate,
		   @rptEndDate = EndDate
	from
		vDateRange
	where
		DateRange = @DateRange


select @rptYearStart = dateadd(m,-23,convert(varchar(8),@rptEndDate,120)+'01'),
	   @rptYearEnd = @rptEndDate,
	   @rptLTMStart = dateadd(m,-11,convert(varchar(8),@rptEndDate,120)+'01'),
	   @rptLTMEnd = @rptEndDate


--get all months
if object_id('tempdb..#rpt0926_months') is not null drop table #rpt0926_months
select
	d.[Month],
	a.Division,
	a.DepartmentName,
	a.[State]
into #rpt0926_months
from
	(select distinct Division, DepartmentName, isnull([State],'Unknown') as [State]
	 from
		dbo.usrAttrition a	
	where 
		(
			a.Country = @Country or 
			@Country is null
		) and
		isnull([State],'') > ''
	) a
	cross join
	(
		select distinct
			CurMonthStart as [Month]
		from			
			Calendar
		where
			[Date] between @rptYearStart and @rptYearEnd
	) d
order by 1,2



if object_id('tempdb..#attrition') is not null drop table #attrition
select 
	Division,
	DepartmentName,
	[State],
	[Status],
	convert(datetime,convert(varchar(8),HireDate,120)+'01') as HireMonth,
	convert(datetime,convert(varchar(8),TerminationDate,120)+'01') as TerminationMonth,
	LeaveType
into #attrition
from
	usrAttrition
where
	(
		Country = @Country or 
		@Country is null
	) and
	isnull([State],'') > ''



if object_id('tempdb..#tempOutput') is not null drop table #tempOutput
select
	d.[Month],
	d.Division,
	d.DepartmentName,
	d.[State],
	sum(e.NewHireCount) as NewHireCount,
	sum(e.HeadCount) as HeadCount,
	sum(e.TerminationCount) as TerminationCount,
	sum(e.VoluntaryCount) as VoluntaryCount,
	sum(e.InvoluntaryCount) as InvoluntaryCount,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate,
	@rptYearStart as rptYearStart,
	@rptYearEnd as rptYearEnd,
	@rptLTMStart as rptLTMStart,
	@rptLTMEnd as rptLTMEnd
into #tempOutput
from
	#rpt0926_months d
	outer apply
	(
		select			
			case when d.[Month] = a.HireMonth then 1 else 0 end as NewHireCount,
			case when d.[Month] >= a.HireMonth and d.[Month] < isnull(a.TerminationMonth,'9999-12-31') then 1 else 0 end as HeadCount,
			case when d.[Month] = a.TerminationMonth then 1 else 0 end as TerminationCount,
			case when d.[Month] = a.TerminationMonth and isnull(a.LeaveType,'Voluntary') = 'Voluntary' then 1 else 0 end as VoluntaryCount,
			case when d.[Month] = a.TerminationMonth and a.LeaveType = 'Involuntary' then 1 else 0 end as InvoluntaryCount,
			case when d.[Month] = a.TerminationMonth and a.LeaveType not in ('Voluntary','Involuntary') then 1 else 0 end as OtherLeaveTypeCount
		from
			(
				select * from #attrition
			) a
		where
			a.Division = d.Division and
			a.DepartmentName = d.DepartmentName and
			a.[State] = d.[State]
	) e
group by 	
	d.[Month],
	d.Division,
	d.DepartmentName,
	d.State
order by 1,2,3



select
	o.[Month],
	o.Division,
	o.DepartmentName,
	o.State,
	o.NewHireCount,
	o.HeadCount,
	o.TerminationCount,
	o.VoluntaryCount,
	o.InvoluntaryCount,
	o.rptStartDate,
	o.rptEndDate,
	o.rptYearStart,
	o.rptYearEnd,
	o.rptLTMStart,
	o.rptLTMEnd,
	av.AvgHeadCount
from
	#tempOutput o
	outer apply
	(
		select sum(HeadCount) / datediff(month,@rptLTMStart, dateadd(d,1,@rptLTMEnd)) as AvgHeadCount
		from #tempOutput
		where
			Division = o.Division and
			DepartmentName = o.DepartmentName and
			[Month] >= dateadd(month,-11,o.[Month]) and		--for each month, get the last 12 months
			[Month] <= o.[Month]
	) av
where
	o.[Month] between @rptLTMStart and @rptLTMEnd


GO
