USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_CarebaseCaseAnalysis]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[tmp_CarebaseCaseAnalysis]
as

SET NOCOUNT ON

--for Cindy Zhang Policy Issued vs Carebase Open Cases

--get Policy
if object_id('tempdb..#x') is not null drop table #x
select
	p.PolicyNo,
	p.IssuedDate as IssueDate,
	p.PolicyType
into #x	
from
	[db-au-cmdwh].dbo.Policy p
where
	convert(varchar(10),p.IssuedDate,120) between '2005-01-01' and '2012-09-30' and
	(p.PolicyType in ('N','E') or
	 (p.PolicyType = 'R' and p.OldPolicyType in ('N','E')))


--store carebase case data
if object_id('tempdb..#t') is not null drop table #t
select
	p.PolicyNo,
	c.CreateDate as OpenDate,
	c.CaseNo,
	n.NoteID
into #t	
from
	[db-au-cmdwh].dbo.cbCase c
	join [db-au-cmdwh].dbo.cbNote n on
		c.CaseKey = n.CaseKey
	join [db-au-cmdwh].dbo.cbPolicy p on c.CaseKey = p.CaseKey and
		left(p.PolicyNo,1) in ('1','2','3','4','5','6','7','8','9') and
		(p.PolicyNo  like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') and
		len(replace(p.PolicyNo,' ','')) = 8
where
	c.CreateDate between '2005-01-01' and '2012-09-30' and
	c.CaseKey not in (select CaseKey from [db-au-cmdwh].dbo.cbCase where Surname like '%delete%' or Surname like '%test%' or Surname like '%train%' or Surname like '%duplicate%')
	
	
--summarise policy
if object_id('tempdb..#p') is not null drop table #p
select
	convert(datetime,convert(varchar(8),x.IssueDate,120)+'01') as IssueDate,
	sum(case when x.PolicyType = 'R' then -1 else 1 end) as IssueCount
into #p	
from
	#x x
group by
	convert(datetime,convert(varchar(8),x.IssueDate,120)+'01')
order by 1

--summarise case
if object_id('tempdb..#c') is not null drop table #c
select
	convert(datetime,convert(varchar(8),x.IssueDate,120)+'01') as IssueDate,
	convert(datetime,convert(varchar(8),t.OpenDate,120)+'01') as OpenDate,
	count(distinct CaseNo) as OpenCount,
	count(distinct NoteID) as NoteCount
into #c
from
	#x x
	join #t t on convert(varchar(20),x.PolicyNo) = convert(varchar(20),t.PolicyNo)
group by
	convert(datetime,convert(varchar(8),x.IssueDate,120)+'01'),
	convert(datetime,convert(varchar(8),t.OpenDate,120)+'01')
order by 1

--combine policy and case
select
	c.IssueDate,
	c.OpenDate,
	p.IssueCount,
	c.OpenCount,
	c.NoteCount
into #m	
from
	#p p join #c c on p.IssueDate = c.OpenDate	
order by 1,2	

--set policy metrics to zero if not same case month
update #m
set IssueCount = case when IssueDate = OpenDate then IssueCount else 0 end

--select main data for report
select * from #m	
		
--drop temp tables		
drop table #x
drop table #t		
drop table #p
drop table #c
drop table #m
GO
