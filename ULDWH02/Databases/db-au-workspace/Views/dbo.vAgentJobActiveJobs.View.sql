USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vAgentJobActiveJobs]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vAgentJobActiveJobs] as
with jobhistoryDetail as (
	select dense_rank() over (partition by job_id, step_id order by run_date desc, run_time desc) as my_rank,
			row_number() over (partition by job_id, step_id order by run_date desc, run_time desc) as my_rank_order,
			job_id, 
			step_id, 
			run_date,
			run_time,
			msdb.dbo.agent_datetime(run_date, run_time)as RunTime,
			DateDiff(second,'',CAST(CAST(run_duration/10000 as varchar)  + ':' + CAST(run_duration/100%100 as varchar) + ':' + CAST(run_duration%100 as varchar) as datetime)) as run_duration
	from msdb.dbo.sysjobhistory
),
jobhistorySummary as (
	SELECT job_id, step_id, avg(run_duration) as AvgRunDuration
	from jobhistoryDetail
	WHERE my_rank <= 7
	group by job_id, step_id
)
	SELECT
		ja.job_id,
		j.name AS job_name,
		ja.start_execution_date,    
		ja.stop_execution_date,
		datediff(second, ja.start_execution_date, IsNull(ja.stop_execution_date,GetDate())) as Job_Length_Of_Exexution,
		jhS2.AvgRunDuration as Job_Average_Run_Execution,
		jhd.run_duration as Job_Last_Execution,
		ISNULL(last_executed_step_id,0)+1 AS current_executed_step_id,
		Js.step_name,
		ja.last_executed_step_date,    
		datediff(second, ja.last_executed_step_date,IsNull(ja.stop_execution_date,GetDate())) as Step_Length_Of_Exexution,
		jhs.AvgRunDuration as StepAverageRunExecution
	FROM msdb.dbo.sysjobactivity ja 
	LEFT JOIN jobhistorySummary jhS ON ja.job_id = jhs.job_id AND ISNULL(last_executed_step_id,0)+1 = jhs.step_id
	LEFT JOIN jobhistorySummary jhS2 ON ja.job_id = jhs2.job_id AND jhs2.step_id = 0
	LEFT JOIN jobhistoryDetail  jhd on ja.job_id= jhd.job_id and my_rank_order = 1  AND jhd.step_id = 0
	JOIN msdb.dbo.sysjobs j ON ja.job_id = j.job_id
	left JOIN msdb.dbo.sysjobsteps js ON ja.job_id = js.job_id AND ISNULL(ja.last_executed_step_id,0) = js.step_id
	WHERE ja.session_id = (SELECT TOP 1 session_id FROM msdb.dbo.syssessions ORDER BY agent_start_date DESC)
GO
