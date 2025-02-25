USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0188]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[rptsp_rpt0188]	@ReportingPeriod varchar(30),
										@StartDate varchar(10),
										@EndDate varchar(10)
as

SET NOCOUNT ON

/****************************************************************************************************/
--	Name:			dbo.rptsp_rpt0188
--	Author:			Linus Tor
--	Date Created:	20110810
--	Description:	This stored procedure returns multiple payments, same claim for payments <= $1000
--
--	Parameters:		@ReportingPeriod: default date range or '_User Defined'
--					@StartDate: if _User Defined enter date value (Format YYYY-MM-DD eg. 2010-01-01).
--					@EndDate: if _User Defined enter date value (Format YYYY-MM-DD eg. 2010-01-01).
--	
--	Change History:	20110811 - LT - Created
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @ReportingPeriod = 'Last Week', @StartDate = null, @EndDate = null
*/

declare @rptStartDate datetime
declare @rptEndDate datetime
declare @SQL nvarchar(max)

/* get reporting dates */
if @ReportingPeriod = '_User Defined'
  select @rptStartDate = convert(smalldatetime,@StartDate), @rptEndDate = convert(smalldatetime,@EndDate)
else
  select @rptStartDate = StartDate, @rptEndDate = EndDate
  from [db-au-cmdwh].dbo.vDateRange
  where DateRange = @ReportingPeriod

if object_id('tempdb..#rpt0188_claim') is not null drop table #rpt0188_claim
select
	s.ClaimNo
into #rpt0188_claim
from
	[db-au-cmdwh].dbo.clmSECHEQUE s
	join [db-au-cmdwh].dbo.clmName n on
			s.ClaimKey = n.ClaimKey and
			s.PayeeID = n.NameID
where
	s.[Status] = 'PAID' and
	s.TransactionType = 'DD' and
	convert(varchar(10),s.PaymentDate,120) between convert(varchar(10),@rptStartDate,120) and convert(varchar(10),@rptEndDate,120) and
	s.Amount <= 1000
group by
	s.ClaimNo	


select
	a.ClaimNo,
	max(a.ClaimNoOrder) as ClaimNoOrder,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate
from
(	
	select
		s.ClaimNo,
		s.PaymentDate,
		s.Amount,
		row_number() over (partition by s.ClaimNo order by s.ClaimNo) as ClaimNoOrder
	from
		[db-au-cmdwh].dbo.clmSECHEQUE s
	where
		s.[Status] = 'PAID' and
		s.TransactionType = 'DD' and
		convert(varchar(10),s.PaymentDate,120) <= convert(varchar(10),@rptEndDate,120) and
		s.Amount <= 1000 and
		s.ClaimNo in (select ClaimNo from #rpt0188_claim)
) a
where
	a.ClaimNoOrder >= 4
group by
	a.ClaimNo


GO
