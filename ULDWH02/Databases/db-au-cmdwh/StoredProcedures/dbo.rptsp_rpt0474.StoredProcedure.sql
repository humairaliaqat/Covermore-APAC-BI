USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0474]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0474]  @ReportingPeriod varchar(30),
										@StartDate varchar(10),
										@EndDate varchar(10)
as

set nocount on


/****************************************************************************************************/
--	Name:			dbo.rptsp_rpt0474
--	Author:			Linus Tor
--	Date Created:	20131113
--	Description:	This stored procedure shows number of policies and GWP day by day. This will be used
--					by Crystal Reports for MAS Policy Extract reconciliation
--					
--	Parameters:		@ReportingPeriod	- required. Value is standard date range or _User Defined
--					@StartDate			- optional. If _User Defined, enter Start Date (Format: YYYY-MM-DD)
--					@EndDate			- optional. If _User Defined, enter End Date (Format: YYYY-MM-DD)
--
--	Change History:	20131113 - LT - Created
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
	a.SourceType,
	a.Country,
	a.PostingDate,
	count(a.PolicyNumber) as PolicyNumberCount,
	sum(case when a.TransactionType = 'CX' then a.GWP * -1
		     else a.GWP
		end) as GWP
into #PolicyExtract
from
(
	select
		'POLICY EXTRACT' as SourceType,
		substring(a.Data,62,2) as Country,
		convert(datetime,substring(Data,3,10),111) as PostingDate,	
		left(a.Data,2) as TransactionType,
		substring(a.Data,649,11) as PolicyNumber,
		convert(money,substring(a.Data,28,11)) as GWP
	from
		[db-au-cmdwh].dbo.usrRPT0385 a
	where
		a.xFailx = 0 and	
		convert(datetime,substring(a.Data,3,10),111) between @rptStartDate and @rptEndDate
) a
group by
	a.SourceType,
	a.Country,
	a.PostingDate
order by
	a.Country,
	a.PostingDate
	

if object_id('tempdb..#DW') is not null drop table #DW
select
	'DATA WAREHOUSE' as SourceType,
	pts.CountryKey as Country,
	pts.PostingDate,
	count(pts.PolicyNumber) as PolicyNumberCount,
	sum(pts.GrossPremium - pts.TaxAmountSD) as GWP
into #DW	
from
	dbo.penPolicyTransSummary pts
	join dbo.penOutlet o on	pts.OutletSKey = o.OutletSKey
where
	convert(varchar(10),pts.PostingDate,120) between @rptStartDate and @rptEndDate and
	pts.CountryKey in ('MY','SG') and
	o.GroupCode = 'MA'					--Malaysia Airlines	
group by
	pts.CountryKey,
	pts.PostingDate
order by
	pts.CountryKey,
	pts.PostingDate


select
	d.CalDate as PostingDate,
	a.SourceType,
	a.Country,
	a.PolicyNumberCount,
	a.GWP,
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
		p.Country,
		p.PostingDate,
		p.PolicyNumberCount,
		p.GWP
	from #PolicyExtract p

	union all

	select
		d.SourceType,
		d.Country,
		d.PostingDate,
		d.PolicyNumberCount,	
		d.GWP		
	from #DW d
) a on d.CalDate = a.PostingDate
		
		
drop table #PolicyExtract
drop table #DW		



GO
