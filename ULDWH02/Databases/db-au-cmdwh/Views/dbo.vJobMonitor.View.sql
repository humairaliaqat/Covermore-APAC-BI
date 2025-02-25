USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vJobMonitor]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[vJobMonitor]
as
select 
    replace(
        replace(replace(replace(t.job_name, '_', ' '), ' model', ''), ' incremental', ''),
        'Exchange Web Service',
        'EWS'
    ) job_name,
    t.instance_id,
    t.step_name,
    t.run_status,
    t.run_date,
    t.run_time,
    t.run_duration_sec,
    t.Ma12,
    ls.latest_run_status,
    case
        when RunCount = 0 then 0
        else TotalRun / RunCount * 1.00
    end [MA 12]
from
    [db-au-workspace]..JobActivityMonitor t
    outer apply
    (
		select top 1 
            run_status latest_run_status
		from 
            [db-au-workspace]..JobActivityMonitor j
		where 
            j.job_name = t.job_name
		order by 
            j.run_date desc, j.run_time desc
    ) ls
    outer apply
    (
        select 
            sum(run_duration_sec) TotalRun,
            count(instance_id) RunCount
        from
            (
                select 
                    instance_id,
                    run_duration_sec
                from
                    [db-au-workspace]..JobActivityMonitor r
                where
                    r.job_name = t.job_name and
                    r.run_status = 'Succeeded' and
                    r.run_date >= dateadd(day, -14, t.run_date) and
                    r.run_date <  t.run_date
            ) ma
    ) ma
where
    t.run_date >= dateadd(day, -45, getdate()) and
    job_name not like 'tmp%' and
    job_name not like 'ssis%' and
    job_name not like 'syspolicy%' and
    job_name not like 'live%' and
    job_name not like 'ETL049%' and
    job_name not like 'ETL011%' and
    job_name not like 'ETL012%'



GO
