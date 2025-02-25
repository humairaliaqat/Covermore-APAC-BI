USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_xora_jobhistory]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[tmp_xora_jobhistory]	@ReportingPeriod varchar(30),
											@StartDate varchar(10),
											@EndDate varchar(10)
as

SET NOCOUNT ON

/*
Criteria :  from date and end date  ( based on Job end date)
fields required:
JobNumber, Jobdescription, Jobstart and Job end , Job id from XDS_JOB_REPOSITORY
firstname, last name from XDS_USER table ( join on userid)
callremarks, consultant, category and subcategory from XDS_JOB_FLEXFIELD_VALUES (see queries below to get the info)



SELECT @callremarks=xjfv.FlexfieldValues FROM XDS.dbo.XDS_JOB_FLEXFIELD_VALUES xjfv WHERE xjfv.JobID=@JobId AND xjfv.FlexfieldName='Call Comments'
              SELECT @consultant=xjfv.FlexfieldValues FROM XDS.dbo.XDS_JOB_FLEXFIELD_VALUES xjfv WHERE xjfv.JobID=@JobId AND xjfv.FlexfieldName='Consultant'
              SELECT @category=xjfv.FlexfieldValues FROM XDS.dbo.XDS_JOB_FLEXFIELD_VALUES xjfv WHERE xjfv.JobID=@JobId AND xjfv.FlexfieldName='Category'
              SELECT @subcategory=xjfv.FlexfieldValues FROM XDS.dbo.XDS_JOB_FLEXFIELD_VALUES xjfv WHERE xjfv.JobID=@JobId AND xjfv.FlexfieldName=@category
*/

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
	j.JobNumber,
	j.JobDescription,
	j.JobStartTime,
	j.JobEndTime,
	j.JobId,
	u.FirstName,
	u.LastName,
	fcall.FlexfieldValues as CallRemarks,
	fcons.FlexfieldValues as Consultant,
	fcat.FlexfieldValues as Category,
	fsubcat.FlexfieldValues as SubCategory,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate
from
	wills.xds.dbo.xds_job_repositry j
	join wills.xds.dbo.xds_user u on
		j.UserID = u.UserID
	left join wills.xds.dbo.xds_job_flexfield_values fcall on
		j.JobID = fcall.JobID and
		fcall.FlexFieldName = 'Call Comments'
	left join wills.xds.dbo.xds_job_flexfield_values fcons on
		j.JobID = fcons.JobID and
		fcons.FlexFieldName = 'Consultant'
	left join wills.xds.dbo.xds_job_flexfield_values fcat on
		j.JobID = fcat.JobID and
		fcat.FlexFieldName = 'Category'
	left join wills.xds.dbo.xds_job_flexfield_values fsubcat on
		j.JobID = fsubcat.JobID and
		fsubcat.FlexFieldName = 'Category'				
where
	convert(varchar(10),j.JobEndTime,120) between @rptStartDate and @rptEndDate
order by
	j.JobNumber,
	j.JobStartTime
GO
