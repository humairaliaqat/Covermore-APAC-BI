USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_MelbourneIncentive2013]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[tmp_MelbourneIncentive2013]
as


SET NOCOUNT ON

if object_id('tempdb..#agency') is not null drop table #agency
SELECT
  penOutlet.OutletAlphaKey,
  penOutlet.GroupCode,
  penOutlet.GroupName,
  penOutlet.SubGroupCode,
  penOutlet.SubGroupName,
  penOutlet.AlphaCode,
  penOutlet.TradingStatus,
  penOutlet.OutletName,
  penOutlet.Branch,
  penOutlet.ContactStreet,
  penOutlet.ContactSuburb,
  penOutlet.ContactState,
  penOutlet.ContactPostCode,
  penOutlet.ContactPhone,
  penOutlet.ContactEmail,
  penOutlet.BDMName,
  LastCall.LastSalesCallDate,
  penOutlet.FCNation,
  penOutlet.FCArea
into #agency  
FROM
  [db-au-cmdwh].dbo.penOutlet INNER JOIN ( 
  select 
    po.OutletKey,
    am.LastAMCall,
    am.LastAMCallDate,
    am.LastAMRemarks,
    sc.LastSalesCall,
    sc.LastSalesCallDate,
    sc.LastSalesRemarks
from 
    [db-au-cmdwh].dbo.penOutlet po
    outer apply
    (
        select top 1 
            CRMCallID LastAMCall,
            CallDate LastAMCallDate,
            convert(varchar(8000), CallComments) LastAMRemarks
        from [db-au-cmdwh].dbo.penCRMCallComments cc
        where 
            cc.OutletKey = po.OutletKey and
            cc.Category in ('AcctMgr Phone Call', 'Sales Phone Call')
        order by CallDate desc
    ) am
    outer apply
    (
        select top 1
            CRMCallID LastSalesCall,
            CallDate LastSalesCallDate,
            convert(varchar(8000), CallComments) LastSalesRemarks
        from [db-au-cmdwh].dbo.penCRMCallComments cc
        where 
            cc.OutletKey = po.OutletKey and
            cc.Category in ('Sales Call', 'Head Office Hours')
        order by CallDate desc
    ) sc
where po.OutletStatus = 'Current'

  )  LastCall ON (LastCall.OutletKey=penOutlet.OutletKey)
  
WHERE
  (
   penOutlet.CountryKey  =  'AU'
   AND
   penOutlet.TradingStatus  =  'Stocked'
   AND
   (
    penOutlet.OutletName  NOT LIKE  '%test%'
    AND
    penOutlet.OutletName  NOT LIKE  '%training%'
   )
   AND
   penOutlet.SuperGroupName  IN  ( 'Flight Centre','Stella','Independents'  )
   AND
   ( penOutlet.OutletStatus = 'Current'  )
  )


if object_id('tempdb..#policy') is not null drop table #policy
SELECT
  penPolicyTransSummary.OutletAlphaKey,
  convert(datetime,convert(varchar(08),penPolicyTransSummary.IssueDate,120) + '01') as MonthYear,
  sum(penPolicyTransSummary.GrossPremium) as Sales,
  sum(penPolicyTransSummary.NewPolicyCount) as Policy
into #policy  
FROM
  [db-au-cmdwh].dbo.penPolicyTransSummary 
WHERE
   penPolicyTransSummary.CountryKey  =  'AU' and
   penPolicyTransSummary.IssueDate >= dateadd(month,-18,getdate())
GROUP BY
  penPolicyTransSummary.OutletAlphaKey,
  convert(datetime,convert(varchar(08),penPolicyTransSummary.IssueDate,120) + '01')

 

if object_id('tempdb..#quote') is not null drop table #quote
SELECT
  penQuote.OutletAlphaKey,
  convert(datetime,convert(varchar(8),penQuote.CreateDate,120)+'01') as MonthYear,
  count(distinct penQuote.QuoteKey) as Quote
into #quote  
FROM
  [db-au-cmdwh].dbo.penQuote  
WHERE
  penQuote.CountryKey  =  'AU' and
  penQuote.CreateDate >= dateadd(month,-18,getdate())  
GROUP BY
  penQuote.OutletAlphaKey,
  convert(datetime,convert(varchar(8),penQuote.CreateDate,120)+'01')


if object_id('tempdb..#date') is not null drop table #date
select distinct
	convert(datetime,convert(varchar(8),[Date],120)+'01') as MonthYear
into #date	
from
	[db-au-cmdwh].dbo.Calendar
where
	[Date] between dateadd(month,-18,getdate()) and '2013-09-30'	
		

if object_id('tempdb..#d') is not null drop table #d
select
	a.*,
	d.MonthYear
into #d
from
	#Agency a
	cross join #date d
		

select
	a.*,
	isnull(p.Sales,0) as Sales,
	isnull(p.Policy,0) as Policy,
	isNull(q.Quote,0) as Quote,
	w.WorkDay
from
	#d a
	left join #policy p on a.OutletAlphaKey = p.OutletAlphaKey and a.MonthYear = p.MonthYear
	left join #quote q on a.OutletAlphaKey = q.OutletAlphaKey and a.MonthYear = q.MonthYear
	cross apply (select sum(isWeekday) WorkDay
			     from [db-au-cmdwh].dbo.Calendar
			     where convert(datetime,convert(varchar(8),[Date],120)+'01') = a.MonthYear
			     ) w
order by
	a.GroupName, a.SubGroupName, a.AlphaCode
	
	
drop table #agency
drop table #date
drop table #d
drop table #policy
drop table #quote	
GO
