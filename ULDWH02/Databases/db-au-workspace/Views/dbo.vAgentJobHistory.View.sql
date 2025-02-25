USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vAgentJobHistory]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vAgentJobHistory] as
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
					DateDiff(second,'',CAST(CAST(run_duration/10000 as varchar)  + ':' + CAST(run_duration/100%100 as varchar) + ':' + CAST(run_duration%100 as varchar) as datetime)) as RunDuration,
					row_number() over(partition by job_id order by convert(datetime, rtrim(run_date)) + (run_time * 9 + run_time % 10000 * 6 + run_time % 100 * 10) / 216e4 desc) as rnk
	from msdb.dbo.sysjobhistory
	where step_id = 0
	)
	select	j.[name], 
			j.[job_id],
			case J.enabled
				when 1 then 'Enabled'
				else 'Disabled' 
			END as JobStatus,
			D.[Date],
			SUM(CASE h.run_status WHEN 1 THEN 1 ELSE 0 END) as SuccessfulRuns,
			SUM(CASE h.run_status WHEN 0 THEN 1 ELSE 0 END) as FailedRuns,
			COUNT(h.run_status) as totalRuns,
			avg(H.RunDuration) as averageDuration
	from
	uldwh01.msdb.dbo.sysjobs j
	cross join dim_date D
	left join job_history h on h.job_id = j.job_id AND H.RunTime between dateadd(d,-7,D.[Date]) AND Dateadd(s,-1,D.[Date])
	where J.category_id <> 3
	and j.enabled = 1
	--And d.DateValue between dateadd(d,-7,convert(varchar(8),getdate(),112)) AND Dateadd(s,-1,convert(varchar(8),getdate(),112))
	GROUP BY j.[name],
			j.[job_id],
			D.[Date],
			case J.enabled
				when 1 then 'Enabled'
				else 'Disabled' 
			END
GO
