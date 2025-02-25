USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1054]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************/
--  Name			:	rptsp_rpt1054
--  Description		:	WTP Dashboard for CBA
--  Author			:	Yi Yang
--  Date Created	:	20190225
--  Parameters		:	@ReportingPeriod, @StartDate, @EndDate
--  Change History	:	
/****************************************************************************************************/

CREATE PROCEDURE [dbo].[rptsp_rpt1054]

AS

begin
    set nocount on

---- uncomments to debug
DECLARE @ReportingPeriod VARCHAR(30)
, @StartDate DATETIME
, @EndDate DATETIME
SELECT @ReportingPeriod =  '_User Defined'
, @StartDate = dateadd(day, 1, EOMONTH(DATEADD(day, -1, convert(date, GETDATE())), -6))		 
, @EndDate = DATEADD(day, -1, convert(date, GETDATE()))									 
-- uncomments to debug
 
 --get reporting dates
DECLARE @rptStartDate DATETIME, @rptEndDate DATETIME
IF @ReportingPeriod = '_User Defined'
	SELECT @rptStartDate = @StartDate, @rptEndDate = @EndDate
ELSE
    SELECT @rptStartDate = StartDate, @rptEndDate = EndDate
    FROM [db-au-cmdwh].dbo.vDateRange
    where DateRange = @ReportingPeriod

select 
	c.ClientCode,
	cg.ClientName,
	o.SubGroupName, 
	(case when c.Protocol = 'Medical' then 'Medical'
		else 'Non-Medical' end) as IsMedical,
	c.CreateDate,
	c.CaseNo,
	pts.PolicyNumber
	--,
	--* 
from 
	cbCase as c
	join vCBClientGroup as cg on (c.ClientCode = cg.ClientCode)
	join cbpolicy as cp on (c.CaseKey = cp.CaseKey)
	left join penPolicyTransSummary as pts on (cp.PolicyTransactionKey = pts.PolicyTransactionKey)
	join penOutlet as o on (pts.OutletAlphaKey = o.OutletAlphaKey)

where 
	c.CountryKey = 'AU'
	and (convert(date, c.CreateDate) >= @rptStartDate and convert(date, c.CreateDate) <= @rptEndDate) 
	and c.ClientCode in ('CB', 'BW')
	and o.GroupCode in ('CB', 'BW')
	and o.OutletStatus = 'Current'

end
GO
