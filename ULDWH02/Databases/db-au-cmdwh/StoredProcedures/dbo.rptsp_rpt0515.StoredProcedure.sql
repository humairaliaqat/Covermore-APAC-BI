USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0515]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0515]  @ReportingPeriod varchar(30),
										@StartDate varchar(10),
										@EndDate varchar(10)
as

set nocount on


/****************************************************************************************************/
--	Name:			dbo.rptsp_rpt0515
--	Author:			Linus Tor
--	Date Created:	20140210
--	Description:	This stored procedure shows number of policies and GWP day by day. This will be used
--					by Crystal Reports for IAL Policy Extract reconciliation
--					
--	Parameters:		@ReportingPeriod	- required. Value is standard date range or _User Defined
--					@StartDate			- optional. If _User Defined, enter Start Date (Format: YYYY-MM-DD)
--					@EndDate			- optional. If _User Defined, enter End Date (Format: YYYY-MM-DD)
--
--	Change History:	20140210 - LT - Created
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @ReportingPeriod = 'Yesterday', @StartDate = null, @EndDate = null
*/

declare @rptStartDate smalldatetime
declare @rptEndDate smalldatetime


/* get reporting dates */
if @ReportingPeriod = '_User Defined'
  select @rptStartDate = convert(smalldatetime,@StartDate), @rptEndDate = convert(smalldatetime,@EndDate)
else
  select @rptStartDate = StartDate, @rptEndDate = EndDate
  from [db-au-cmdwh].dbo.vDateRange
  where DateRange = @ReportingPeriod

if object_id('tempdb..#PolicyExtract') is not null drop table #PolicyExtract
select
	'POLICY EXTRACT' as SourceType,	
	a.IssueDate,
	case when a.TransactionType = 'Quote' then 'Quote' else 'Policy' end as TransactionType,
	count(a.TransactionKey) as PolicyNumberCount,
	sum(a.GrossPremium) as SellPrice
into #PolicyExtract
from
(

	select
		a.TransactionKey,
		max(case when a.[Row] = 1 then convert(datetime,a.Item,103) else null end) as IssueDate,
		max(case when a.[Row] = 2 then convert(int,a.Item) else 0 end) as PolicyNumber,
		max(case when a.[Row] = 3 then a.Item else '' end) as TransactionType,
		sum(case when a.[Row] = 4 then convert(money,a.Item) else 0 end) as GrossPremium
	from 
	(

	select 	
		row_number() over(partition by u.xDataIDx order by u.xDataIDx) as [Row],	--pivot data output split
		u.xDataIDx as TransactionKey, 
		split.ItemNumber,
		replace(split.Item,'"','') as Item
	from 
		usrRPT0491 u
		cross apply dbo.fn_delimitedsplit8k(u.Data,'|') split
	where 
		u.xFailx <> 1 and
		u.xDataIDx not in ('Header','ColumnName','Footer') and
		convert(varchar(10),dateadd(day,-1,u.DataTimeStamp),120) between @rptStartDate and @rptEndDate and
		split.ItemNumber in (10,2,17,57)
	) a	
	group by
		a.TransactionKey
) a	
group by 	
	a.IssueDate,
	case when a.TransactionType = 'Quote' then 'Quote' else 'Policy' end
	
	

if object_id('tempdb..#DW') is not null drop table #DW
select
	'DATA WAREHOUSE' as SourceType,
	pts.IssueDate,
	'Policy' as TransactionType,
	count(pts.PolicyTransactionKey) as PolicyNumberCount,
	sum(pts.GrossPremium) as SellPrice
into #DW	
from
	dbo.penPolicyTransSummary pts
	join dbo.penOutlet o on	pts.OutletSKey = o.OutletSKey
where
	convert(varchar(10),pts.PostingDate,120) between @rptStartDate and @rptEndDate and
	pts.CountryKey = 'AU' and
	o.GroupCode in ('NI','SO','SE')					--IAL groups
group by
	pts.IssueDate
order by
	pts.IssueDate
	
	
insert #DW
select
	'DATA WAREHOUSE' as SourceType,
	convert(datetime,convert(varchar(10),q.CreateDate,120)) as IssueDate,
	'Quote' as TransactionType,
	count(q.QuoteID) as PolicyNumberCount,
	0 as SellPrice
from
	dbo.penQuote q
	join dbo.penOutlet o on q.OutletSKey = o.OutletSKey
where
	convert(date,q.CreateDate) between @rptStartDate and @rptEndDate and
	q.CountryKey = 'AU' and
	o.GroupCode in ('NI','SO','SE')
group by
	convert(datetime,convert(varchar(10),q.CreateDate,120))



select
	d.CalDate as IssueDate,
	a.SourceType,
	a.TransactionType,
	a.PolicyNumberCount,
	a.SellPrice,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate
from
(
	select Date as CalDate
	from dbo.Calendar
	where Date between @rptStartDate and @rptEndDate
) d
left join 
(
	select
		p.SourceType,
		p.TransactionType,
		p.IssueDate,
		p.PolicyNumberCount,
		p.SellPrice
	from #PolicyExtract p

	union all

	select
		d.SourceType,
		d.TransactionType,
		d.IssueDate,
		d.PolicyNumberCount,	
		d.SellPrice
	from #DW d
) a on d.CalDate = a.IssueDate
		

	
drop table #PolicyExtract
drop table #DW		

GO
