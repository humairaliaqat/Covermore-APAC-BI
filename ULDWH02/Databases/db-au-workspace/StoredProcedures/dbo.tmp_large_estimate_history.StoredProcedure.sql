USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_large_estimate_history]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[tmp_large_estimate_history]
as

SET NOCOUNT ON

select
  c.ClaimNo,
  c.ReceivedDate,
  s.SectionCode,
  eh.EstimateHistoryID,
  eh.EHSectionID,
  eh.EHEstimateValue,
  eh.EHCreateDate,
  row_number() over (partition by eh.EHSectionID  order by eh.EstimateHistoryID asc)as EstimateOrder
into #t  
from
	clmClaim c
	join clmSection s on
		c.CountryKey = s.CountryKey and
		c.ClaimKey = s.ClaimKey
	join clmEstimateHistory eh on
		s.CountryKey = eh.CountryKey and
		s.SectionID = eh.EHSectionID
where
	c.CountryKey = 'AU' and	
	c.ReceivedDate between '2010-10-01' and '2011-03-09' 
group by	
  c.ClaimNo,
  c.ReceivedDate,
  s.SectionCode,
  eh.EstimateHistoryID,
  eh.EHSectionID,
  eh.EHEstimateValue,
  eh.EHCreateDate
order by
	c.ClaimNo,
	eh.EHSectionID,
	eh.EstimateHistoryID
	
	
select 
	ClaimNo, 
	EHSectionID 
into #x 
from #t 
where 
	EHEstimateValue > 15000 and 
	EstimateOrder = 1 
order by ClaimNo, EHSectionID


select t.*
from #t t join #x x on t.ClaimNo = x.ClaimNo and t.EHSectionID = x.EHSectionID
order by t.ClaimNo, t.EHSectionID, t.EstimateHistoryID

drop table #t
drop table #x
GO
