USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_xora_job_error_log]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[tmp_xora_job_error_log]	@ReportingPeriod varchar(30),
											@StartDate varchar(10),
											@EndDate varchar(10)
as

SET NOCOUNT ON


/*
b)	Invalid Alpha report  ( this table is not yet created in production, is available in ulsqlrc, will be in prod on Monday)
Criteria :  from date and end date  ( based on Job end date)
fields required: CVMR_JOB_ERROR_LOG
All columns in this table
*/

/***************************************************************************************/
--	Change History:	20110418 - sharmilai - Changed the DB from "ulsqlrc" to "Wills"
/***************************************************************************************/

--uncomment to debug
/*
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @ReportingPeriod = 'Month-To-Date', @StartDate = null, @EndDate = null
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
  

select 
	e.JobNumber,
	e.JobStartTime,
	e.JobEndTime,
	e.JobID,
	e.FirstName,
	e.LastName,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate
from
	wills.xds.dbo.CVMR_JOB_ERROR_LOG e
where
	convert(varchar(10),e.JobStartTime,120) between @rptStartDate and @rptEndDate
order by
	e.JobNumber,
	e.JobStartTime
GO
