USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0455]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0455]	@GroupName varchar(50),
										@HistoricalStartDate varchar(10),
										@HistoricalEndDate varchar(10),
										@ReportingPeriod varchar(30),
										@StartDate varchar(10),
										@EndDate varchar(10)
as

SET NOCOUNT ON							
								

--uncomment to debug
/*
declare @GroupName varchar(50)
declare @HistoricalStartDate varchar(10)
declare @HistoricalEndDate varchar(10)
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select	@GroupName = 'RAC', 
		@HistoricalStartDate = '2013-11-01', 
		@HistoricalEndDate = '2014-01-31',
		@ReportingPeriod = 'Month-To-Date', 
		@StartDate = null, 
		@EndDate = null
*/

declare @WorkDaysElapsed int
declare @TotalWorkDays int
declare @rptStartDate datetime  
declare @rptEndDate datetime  


/* get reporting dates */  
if @ReportingPeriod = '_User Defined'  
    select @rptStartDate = @StartDate, @rptEndDate = @EndDate  
else select   
        @rptStartDate = StartDate,   
        @rptEndDate = EndDate  
    from   
        [db-au-cmdwh].dbo.vDateRange  
    where   
        DateRange = @ReportingPeriod 
        
        
if object_id('tempdb..#group') is not null drop table #group
create table #group (groupname varchar(30) null)

if @GroupName = 'ALL' or @GroupName is null or @GroupName = ''
begin
	insert #group
	select distinct GroupName
	from [db-au-cmdwh].dbo.penOutlet
	where CountryKey = 'AU' and SuperGroupName = 'AAA'
end
else insert #group values(@GroupName)

select @WorkDaysElapsed = (select sum(isWeekday) from [db-au-cmdwh].dbo.Calendar where [Date] between @rptStartDate and @rptEndDate)
select @TotalWorkDays = (select sum(isWeekDay) 
						from [db-au-cmdwh].dbo.Calendar 
						where CurMonthEnd = (select top 1 CurMonthEnd from Calendar where [Date] = @rptEndDate))


if object_id('tempdb..#p') is not null drop table #p
SELECT
  o.GroupName,
  o.AlphaCode,  
  o.OutletName,
  upper(p.StoreCode) as StoreCode,
  u.FirstName + ' ' + u.LastName as Consultant,
  sum(p.GrossPremium) as ThisSellPrice, 
  sum(p.AdjustedNet) as ThisNetPrice,
  sum(p.NewPolicyCount) as ThisPolicy,  
  avg(p.GrossPremium) as ThisAvgSellPrice,
  @rptStartDate as rptStartDate,
  @rptEndDate as rptEndDate,
  convert(datetime,@HistoricalStartDate) as rptHistoricalStartDate,
  convert(datetime,@HistoricalEndDate) as rptHistoricalEndDate,
  @WorkDaysElapsed as WorkDaysElapsed,
  @TotalWorkDays as TotalWorkDays
into #p  
FROM
  penUser u
  RIGHT OUTER JOIN penPolicyTransSummary p ON (u.UserKey=p.UserKey and u.UserStatus = 'Current')
  INNER JOIN penOutlet o ON (p.OutletAlphaKey=o.OutletAlphaKey and o.OutletStatus = 'Current')		 			  
WHERE
   o.CountryKey  =  'AU' and
   o.SuperGroupName  =  'AAA' and
   o.GroupName in (select GroupName from #Group) and
   p.PostingDate between @rptStartDate and @rptEndDate and
   (o.OutletName not like '%websales%' and o.OutletName not like '%staff%')
GROUP BY
  o.GroupName,
  o.AlphaCode,  
  o.OutletName,
  upper(p.StoreCode),
  u.FirstName + ' ' + u.LastName


if object_id('tempdb..#q') is not null drop table #q
select
  o.GroupName,
  o.AlphaCode,  
  o.OutletName,
  upper(q.StoreCode) as StoreCode,
  u.FirstName + ' ' + u.LastName as Consultant, 
  count(distinct q.QuoteKey) as ThisQuote			--get this period quotes
into #q  
from
	penOutlet o 
	join penQuote q on 
		o.OutletAlphaKey = q.OutletAlphaKey and 
		o.OutletStatus = 'Current'
	join penUser u on
		q.CountryKey = u.CountryKey and		
		q.ConsultantName = u.FirstName + ' ' + u.LastName and
		u.UserStatus = 'Current'
where 
	o.CountryKey  =  'AU' and
	o.SuperGroupName  =  'AAA' and
    o.GroupName  in (select GroupName from #Group) and
    q.CreateDate between @rptStartDate and @rptEndDate and
   (o.OutletName not like '%websales%' and o.OutletName not like '%staff%')
group by
  o.GroupName,
  o.AlphaCode,  
  o.OutletName,
  upper(q.StoreCode),
  u.FirstName + ' ' + u.LastName


if object_id('tempdb..#ph') is not null drop table #ph
select
  o.GroupName,
  o.AlphaCode,  
  o.OutletName,
  upper(p.StoreCode) as StoreCode,
  u.FirstName + ' ' + u.LastName as Consultant,
  sum(p.NewPolicyCount) as HistPolicy						--get historical policies 
into #ph  
from 
	penUser u
	RIGHT OUTER JOIN penPolicyTransSummary p ON (u.UserKey=p.UserKey and u.UserStatus = 'Current')
	INNER JOIN penOutlet o ON (p.OutletAlphaKey=o.OutletAlphaKey and o.OutletStatus = 'Current') 
where o.CountryKey = 'AU' and
	  o.SuperGroupName = 'AAA' and
	  o.GroupName  in (select GroupName from #Group) and
	  p.PostingDate between @HistoricalStartDate and @HistoricalEndDate and
	  (o.OutletName not like '%websales%' and o.OutletName not like '%staff%')
group by	  
  o.GroupName,
  o.AlphaCode,  
  o.OutletName,
  upper(p.StoreCode),
  u.FirstName + ' ' + u.LastName


if object_id('tempdb..#qh') is not null drop table #qh
select
  o.GroupName,
  o.AlphaCode,  
  o.OutletName,
  upper(q.StoreCode) as StoreCode,
  u.FirstName + ' ' + u.LastName as Consultant, 
  count(distinct q.QuoteKey) as HistQuote			--get historical quotes (April 2013 - June 2013)
into #qh  
from
	penOutlet o 
	join penQuote q on 
		o.OutletAlphaKey = q.OutletAlphaKey and 
		o.OutletStatus = 'Current'
	join penUser u on
		q.CountryKey = u.CountryKey and		
		q.ConsultantName = u.FirstName + ' ' + u.LastName and
		u.UserStatus = 'Current'
where 
	o.CountryKey  =  'AU' and
	o.SuperGroupName  =  'AAA' and
    o.GroupName  in (select GroupName from #Group) and
    q.CreateDate between @HistoricalStartDate and @HistoricalEndDate and
   (o.OutletName not like '%websales%' and o.OutletName not like '%staff%')
group by
  o.GroupName,
  o.AlphaCode,  
  o.OutletName,
  upper(q.StoreCode),
  u.FirstName + ' ' + u.LastName	

	 	
	

SELECT
  a.GroupName,
  a.AlphaCode,  
  a.OutletName,
  a.StoreCode,
  a.Consultant,
  a.ThisSellPrice, 
  a.ThisNetPrice,
  a.ThisPolicy,  
  q.ThisQuote,
  a.ThisAvgSellPrice,
  ph.HistPolicy,
  qh.HistQuote,
  a.rptStartDate,
  a.rptEndDate,
  a.WorkDaysElapsed,
  a.TotalWorkDays,
  a.rptHistoricalStartDate,
  a.rptHistoricalEndDate
from
	#p a
	join #q q on 
		a.GroupName = q.GroupName and
		a.AlphaCode = q.AlphaCode and
		a.StoreCode = q.StoreCode and
		a.Consultant = q.Consultant
	join #ph ph on
		a.GroupName = ph.GroupName and
		a.AlphaCode = ph.AlphaCode and
		a.StoreCode = ph.StoreCode and
		a.Consultant = ph.Consultant	
	join #qh qh on
		a.GroupName = qh.GroupName and
		a.AlphaCode = qh.AlphaCode and
		a.StoreCode = qh.StoreCode and
		a.Consultant = qh.Consultant						
order by
	a.GroupName,
	a.AlphaCode,
	a.StoreCode,
	a.Consultant



drop table #group
drop table #p
drop table #q
drop table #ph
drop table #qh
GO
