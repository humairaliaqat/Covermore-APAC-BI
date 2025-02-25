USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0545]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[rptsp_rpt0545]	
as

SET NOCOUNT ON


/****************************************************************************************************/
--	Name:			dbo.rptsp_rpt0545
--	Author:			Linus Tor
--	Date Created:	20140422
--	Description:	This stored procedure returns IAL policy export errors in reporting period.
--					Only the last error of each policy number is returned.
--					
--	Parameters:		@ReportingPeriod	- required. Value is standard date range or _User Defined
--					@StartDate			- optional. If _User Defined, enter Start Date (Format: YYYY-MM-DD)
--					@EndDate			- optional. If _User Defined, enter End Date (Format: YYYY-MM-DD)
--
--	Change History:	20140422 - LT - Created
--					20140519 - LT - added penDataQueue to query, and removed date restrictions.
--					20141126 - LT - rewrote query to cater for subsequent data queue updates
--					20150113 - LT - rewrote query to query natively against source data (AU_PenguinJob & AU_PenguinSharp_Active)
/****************************************************************************************************/

--get all dataqueue with JobID in 145, 146 and store in #dq
if object_id('tempdb..#dq') is not null drop table #dq
select	
	a.DataQueueID,
	a.DataID,
	a.PolicyNumber,
	a.Status,
	a.JobID,
	a.CreateDate
into #dq
from openquery([db-au-penguinsharp.aust.covermore.com.au],				--Use OpenQuery due to XML data type limitation in distributed query
'
	select
		a.DataQueueID,
		a.DataID,
		case when a.PolicyNumber is null then (select top 1 p.PolicyNumber
											   from [AU_PenguinSharp_Active].dbo.tblPolicy p
													join [AU_PenguinSharp_Active].dbo.tblPolicyTransaction pt on p.PolicyID = pt.PolicyID
											   where pt.ID = a.DataID)
			 else a.PolicyNumber
		end as PolicyNumber,
		a.JobID,
		a.Status,
		a.CreateDate
	from
		(	
			select 
				d.DataQueueID,
				d.DataID,
				(select top 1 PolicyNumber from [AU_PenguinSharp_Active].dbo.tblPolicy where PolicyID = d.DataID) as PolicyNumber,
				d.JobID,
				d.Status,
				[AU_PenguinSharp_Active].dbo.UtcToLocalTimeZone(d.CreateDateTime,''AUS Eastern Standard Time'') as CreateDate
			from 
				[AU_PenguinJob].dbo.tblDataQueue d
			where 
				d.JobID in (145,146)
		) a
') a

	
--get only data queues that are still in error status (ie no successful retry)
if object_id('tempdb..#main') is not null drop table #main
select
	a.DataQueueID,
	a.DataID,
	a.PolicyNumber,
	a.Status,
	a.JobID,
	a.CreateDate
into #main	
from
	#dq a
	left join 
	(
		select distinct									--get the last error only
			d.PolicyNumber,
			(select max(DataQueueID) from #dq where PolicyNumber = d.PolicyNumber) as MaxDataQueue
		from 
			#dq d
	) p on a.DataQueueID = p.MaxDataQueue and a.PolicyNumber = p.PolicyNumber
where
	a.Status = 'ERROR'	
order by a.PolicyNumber, a.JobID	





if object_id('tempdb..#rpt0545_main') is not null drop table #rpt0545_main
select
	d.DataQueueiD,
	d.DataID,
	d.PolicyNumber,
	d.Status,
	d.CreateDate,
	d.JobID,
	j.JobType,
	j.JobErrorID,
	j.JobCode,
	j.JobErrorDescription,
	j.JobName,
	j.ErrorSource
into #rpt0545_main	
from
	#main d	
	outer apply
	(
		select top 1
			job.JobErrorID,
			job.JobCode,
			job.JobType,
			job.JobErrorDescription,
			job.JobName,
			job.ErrorSource
		from openquery([db-au-penguinsharp.aust.covermore.com.au],
			'
				select
					dq.DataQueueID,
					je.ID as JobErrorID,
					j.JobCode,
					j.JobType,
					je.Description as JobErrorDescription,
					j.JobName,
					je.ErrorSource
				from
					[AU_PenguinJob].dbo.tblDataQueue dq
					join [AU_PenguinJob].dbo.tblJobError je on je.DataID = dq.DataID
					join [AU_PenguinJob].dbo.tblJob j on je.JobID = j.JobID
				where		
					dq.JobID in (145,146) and
					dq.Status <> ''DONE''
			') job
		where job.DataQueueID = d.DataQueueID
		order by JobErrorID desc
	) j
	

	
--get main data for Crystal Reports
if (select count(*) from #rpt0545_main) <> 0
begin
	select
		convert(int,a.JobErrorID) as JobErrorID,
		convert(varchar(50),a.JobCode) as JobCode,
		convert(text,a.JobErrorDescription) as JobErrorDescription,
		convert(int,a.DataID) as PolicyID,
		convert(varchar(50),a.PolicyNumber) as PolicyNumber,
		convert(datetime,a.CreateDate) as CreateDate,
		convert(varchar(100),a.JobName) as JobName,
		convert(varchar(15),a.ErrorSource) as ErrorSource,
		convert(varchar(50),a.JobType) as JobType
	from
		#rpt0545_main a
	order by
		a.JobErrorID					 
end
else
begin
	select
		convert(int,null) as JobErrorID,
		convert(varchar(50),null) as JobCode,
		convert(text,null) as JobErrorDescription,
		convert(int,null) as PolicyID,
		convert(varchar(50),null) as PolicyNumber,
		convert(datetime,null) as CreateDate,
		convert(varchar(100),null) as JobName,
		convert(varchar(15),null) as ErrorSource,
		convert(varchar(50),null) as JobType
end	




--drop temp tables
drop table #dq
drop table #main
drop table #rpt0545_main

GO
