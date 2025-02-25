USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_policy_discount_stats]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[tmp_policy_discount_stats] @AgencyGroup varchar(3),
												  @ReportingPeriod varchar(30),
												  @StartDate varchar(10),
												  @EndDate varchar(10)
as

SET NOCOUNT ON


--uncomment to debug
/*
declare @AgencyGroup varchar(3)
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @AgencyGroup = 'FL', @ReportingPeriod = '_User Defined', @StartDate = '2011-01-01', @EndDate = '2011-12-31'
*/

declare @rptStartDate datetime
declare @rptEndDate datetime

/* get reporting dates */
if @ReportingPeriod = '_User Defined'
  select @rptStartDate = convert(smalldatetime,@StartDate), @rptEndDate = convert(smalldatetime,@EndDate)
else
  select @rptStartDate = StartDate, @rptEndDate = EndDate
  from [db-au-cmdwh].dbo.vDateRange
  where DateRange = @ReportingPeriod

if object_id('tempdb..#AgencyGroup') is not null drop table #AgencyGroup
create table #AgencyGroup (AgencyGroupCode varchar(3) null)

if @AgencyGroup = 'ALL'
	insert #AgencyGroup
	select distinct AgencyGroupCode 	
	from [db-au-cmdwh].dbo.Agency where CountryKey = 'AU'
else
	insert #AgencyGroup
	select distinct AgencyGroupCode	
	from [db-au-cmdwh].dbo.Agency where CountryKey = 'AU' and AgencyGroupCode = @AgencyGroup
		


if object_id('tempdb..#Quotes') is not null drop table #Quotes
select distinct PolicyID as PolicyNo
into #Quotes
from
	oxley.trips.dbo.tblQuotes q
	join oxley.trips.dbo.CLREG c on
		q.AgencyCode COLLATE DATABASE_DEFAULT = c.CLALPHA COLLATE DATABASE_DEFAULT 
where 
	c.CLGROUP COLLATE DATABASE_DEFAULT  in (select AgencyGroupCode COLLATE DATABASE_DEFAULT  from #AgencyGroup) and
	(PolicyID is not null or PolicyID <> 0) and
	IssueDate between @rptStartDate and @rptEndDate
	
	
if object_id('tempdb..#Policies') is not null drop table #Policies	
select
	p.PolicyNo,
	p.CreateDate,
	p.GrossPremiumExGSTBeforeDiscount as GrossBeforeDisc,
	p.ActualGrossPremiumAfterDiscount as GrossAfterDisc,
	case when p.GrossPremiumExGSTBeforeDiscount = p.ActualGrossPremiumAfterDiscount then 0 else 1 end as hasDiscount
into #Policies	
from
	dbo.Policy p
	join dbo.Agency a on
		p.AgencyKey = a.AgencyKey
where
	a.AgencyGroupCode in (select AgencyGroupCode from #AgencyGroup) and
	p.CountryKey = 'AU' and
	p.PolicyType = 'N' and
	p.CreateDate between @rptStartDate and @rptEndDate
			

select distinct
	p.PolicyNo,
	case when q.PolicyNo is null then 0 else 1 end as QuoteSaved,
	p.GrossBeforeDisc,
	p.GrossAfterDisc,
	p.HasDiscount,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate
from
	#Policies p
	left join #Quotes q on
		p.PolicyNo = q.PolicyNo	

drop table #Quotes
drop table #Policies
drop table #AgencyGroup
GO
