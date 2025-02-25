USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1037s]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************/
--  Name			:	rptsp_rpt1037s
--  Description		:	Customer Service Dashboard - Phone Sales Data
--  Author			:	Yi Yang
--  Date Created	:	20181217
--  Parameters		:	@ReportingPeriod, @StartDate, @EndDate
--  Change History	:	
/****************************************************************************************************/

CREATE PROCEDURE [dbo].[rptsp_rpt1037s]
as

begin
    set nocount on

if object_id('tempdb..#temp_pt', 'U') IS NOT NULL 
  drop table #temp_pt;

---- uncomments to debug
DECLARE @ReportingPeriod VARCHAR(30)
, @StartDate DATETIME
, @EndDate DATETIME
SELECT @ReportingPeriod =  '_User Defined'
, @StartDate = dateadd(day, 1, EOMONTH(DATEADD(day, -1, convert(date, GETDATE())), -4))							--'2018-11-01'
, @EndDate = DATEADD(day, -1, convert(date, GETDATE()))															--'2019-02-11'
-- uncomments to debug

 --get reporting dates
DECLARE @rptStartDate DATETIME, @rptEndDate DATETIME
IF @ReportingPeriod = '_User Defined'
	SELECT @rptStartDate = @StartDate, @rptEndDate = @EndDate
ELSE
    SELECT @rptStartDate = StartDate, @rptEndDate = EndDate
    FROM [db-au-cmdwh].dbo.vDateRange
    where DateRange = @ReportingPeriod

-- Get budget from star db and summarise by date, outlet 
--select 
--	convert(date, convert(char(8), pt.DateSK)) as TargetDate,
--	OutletSK,
--	sum(pt.BudgetAmount) as BudgetAmount
--into #temp_pt
--from 
--	[db-au-star].dbo.factPolicyTarget as pt 
--where
--	convert(date, convert(char(8), pt.DateSK)) >= @rptStartDate and 
--	convert(date, convert(char(8), pt.DateSK)) <= @rptEndDate
--group by 
--	convert(date, convert(char(8), pt.DateSK)),
--	OutletSK


select 
	convert(date, convert(char(8), pt.DateSK)) as TargetDate,
	do.OutletKey,
	sum(pt.BudgetAmount) as BudgetAmount
into #temp_pt
from 
	[db-au-star].dbo.DimOutlet as do 
	join [db-au-star].dbo.factPolicyTarget as pt  on (do.OutletSK = pt.OutletSK)
where
	convert(date, convert(char(8), pt.DateSK)) >= @rptStartDate and 
	convert(date, convert(char(8), pt.DateSK)) <= @rptEndDate 
group by 
	convert(date, convert(char(8), pt.DateSK)),
	do.OutletKey
order by 
	TargetDate

SELECT
  convert(date, pts.PostingDate) as PostingDate,
  o.AlphaCode,
  o.OutletName,
  o.GroupName,
  t.OutletKey,
  sum(ppp."NAP (incl Tax)") as SumOfNAP,
  sum(pts.BasePolicyCount) as PolicyCount,
  sum(ppp."Sell Price") as TotalSellPrice,
  sum(ppp.Premium) as TotalPremium,
  max(t.BudgetAmount) as PolicyBudget

FROM
	penPolicyTransSummary as pts
	INNER JOIN penPolicy as p ON (pts.PolicyKey=p.PolicyKey)
	INNER JOIN penOutlet as o ON (pts.OutletAlphaKey=o.OutletAlphaKey)
	INNER JOIN vpenOutletJV as jv ON (o.OutletKey=jv.OutletKey)
	INNER JOIN vPenguinPolicyPremiums as ppp ON (ppp.PolicyTransactionKey=pts.PolicyTransactionKey)
	--left join [db-au-star].dbo.DimOutlet as do on (do.OutletKey = o.OutletKey and do.isLatest = 'Y')
	left join #temp_pt as t on (t.OutletKey = o.OutletKey and t.TargetDate = convert(date, pts.PostingDate))

WHERE
  (
   o.CountryKey  =  'AU'
   AND
   (convert(date, pts.PostingDate) >= @rptStartDate and convert(date, pts.PostingDate) <= @rptEndDate)
   AND
   jv.Channel  IN  ('Call Centre')
   AND
   o.AlphaCode  NOT IN  ('MBN0012','AZN2103','AZN2104','AZN2105','BWA0016',
	'CBA0025','CBA0030','CBA0035','CBA0040','CBA0045','CBN0003','CBN0004','CFV0002',
	'CRN0002','CRV0001','EAQ0001','NIN0125','NIN0129','NTN0002','NTN0004','NTN0005',
	'NTN0007','NTN0008','VAQ0001')
   AND
   ( o.OutletStatus = 'Current'  )
  )
GROUP BY
	convert(date, pts.PostingDate),
	o.AlphaCode, 
	o.OutletName, 
	o.GroupName, 
	t.OutletKey,
	jv.Channel


end
GO
