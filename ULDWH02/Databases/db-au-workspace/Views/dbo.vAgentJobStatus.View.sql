USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vAgentJobStatus]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vAgentJobStatus] as
	with job_history as (select job_id, 
					case run_status
						WHEN 0 THEN 'Failed'
						WHEN 1 THEN 'Succeeded'
						WHEN 2 THEN 'Retry'
						WHEN 3 THEN 'Canceled'
					end as RunStatus,
					run_status,
					run_date,
					msdb.dbo.agent_datetime(run_date, run_time)as RunTime,
					run_duration,
					DateDiff(second,'',CAST(CAST(run_duration/10000 as varchar)  + ':' + CAST(run_duration/100%100 as varchar) + ':' + CAST(run_duration%100 as varchar) as datetime))  as RunDuration,
					row_number() over(partition by job_id order by msdb.dbo.agent_datetime(run_date, run_time) DESC) as rnk
	from msdb.dbo.sysjobhistory
	where step_id = 0
	),
	next_run AS (SELECT job_id,max(next_scheduled_run_date) as nextRunDateTime
				from msdb.dbo.sysjobactivity
				group by job_id)
	select	j.[name],
			j.[job_id], 
			J.category_id,
			case J.enabled
				when 1 then 'Enabled'
				else 'Disabled' 
			END as JobStatus,
			h.RunStatus,
			h.RunTime,
			h.RunDuration as LastRunDuration,
			N.nextRunDateTime,
			ah.averageDuration as Last7DaysAvgDuration
	from
	uldwh01.msdb.dbo.sysjobs j
	left join job_history h on h.job_id = j.job_id AND h.rnk = 1
	left join next_run N on j.job_id = N.job_id
	left join vAgentJobHistory ah on J.job_id = Ah.job_id AND convert(varchar(8),h.RunTime,112) = ah.Date
	where J.category_id <> 3
GO
