USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_etl_create_event_files]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_etl_create_event_files]
as

  /****************************************************************************************************/
  --  Name:           etlsp_cmdwh_etl_create_event_files
  --  Author:         Unknown
  --  Date Created:   Unknown
  --  Description:    This stored procedure to create events files post completion of relevant ETL.
  --  Parameters:     
  --  
  --  Change History: 201XXXXX - Unknownn - Created
  --                  20190801 - RS - Included event file post ETL041 CISCO calls data.
  --
  /****************************************************************************************************/

if object_id('tempdb..#etlstatus') is not null
    drop table #etlstatus

select
    h.Instance_ID,
    case
        when j.[name] like '%ETL004%' then 'ULDWH02 - ETL004 Claims'
        when j.[name] like '%ETL005%' then 'ULDWH02 - ETL005 TIAS'
        when j.[name] like '%ETL007%' then 'ULDWH02 - ETL007 Corporate'
        when j.[name] like '%ETL008%' then 'ULDWH02 - ETL008 e5'
        when j.[name] like '%ETL021%' then 'ULDWH02 - ETL021 Penguin'
        when j.[name] like '%ETL024%AU' then 'ULDWH02 - ETL024 EMC AU'
        when j.[name] like '%ETL024%UK' then 'ULDWH02 - ETL024 EMC UK'
        when j.[name] like '%ETL027%' then 'ULDWH02 - ETL027 Carebase'
        when j.[name] like '%ETL028%' then 'ULDWH02 - ETL028 Penguin Data Loader'
        when j.[name] like '%ETL035%' then 'ULDWH02 - ETL035 Penguin UK'
        when j.[name] like '%ETL038%' then 'ULDWH02 - ETL038 Penguin Data Loader UK'
        when j.[name] like '%ETL063%' then 'ULDWH02 - ETL063 Penguin Data Loader US'
        when j.[name] like '%ETL064%' then 'ULDWH02 - ETL064 Penguin US'
		when j.[name] like '%ETL041%' then 'ULDWH02 - ETL041 CISCO CALLS'
    end as JobName,
    case
        when h.run_status = 1 then 'OK'
        else 'FAILED'
    end as RunStatus,
    convert(datetime, rtrim(h.run_date)) + (h.run_time * 9 + h.run_time % 10000 * 6 + h.run_time % 100 * 10) / 216e4 as RunTime,
    left(right('000000' + convert(varchar(6), run_duration), 6),2) + ':' + substring(right('000000' + convert(varchar(6), run_duration), 6),3,2) + ':' + right(right('000000' + convert(varchar(6), run_duration), 6),2) as RunDuration
into #etlstatus
from
    msdb.dbo.sysjobhistory h
    left join msdb.dbo.sysjobs j on
        h.job_id = j.job_id and
        h.step_id = 0
where
    h.run_date = convert(varchar(8),getdate(),112) and
    h.run_status = 1 and
    j.[name] in
    (
        'ETL002_Legacy_UK_Policy',
        'ETL004_Claims_Data_Model',
        'ETL007_Corporate_Data_Model',
        'ETL008_e5_Content',
        'ETL021_Penguin_Data_Model',
        'ETL024_EMC_Data_Model_AU',
        'ETL024_EMC_Data_Model_UK',
        'ETL027_Carebase_Data_Model',
        'ETL028_Penguin_Data_Loader',
        'ETL035_Penguin_Data_Model_UK',
        'ETL038_Penguin_Data_Loader_UK',
        'ETL063_Penguin_Data_Loader_US',
        'ETL064_Penguin_Data_Model_US',
		'ETL041_Cisco'
    )



--if (select top 1 RunStatus from #etlstatus where JobName like '%Policy' order by RunTime Desc) = 'OK'
--    execute [db-au-stage].dbo.etlsp_cmdwh_etl_event_file 'create','Policy'
if (select top 1 RuNStatus from #etlstatus where JobName = 'ULDWH02 - ETL021 Penguin' order by RunTime Desc) = 'OK'
    execute [db-au-stage].dbo.etlsp_cmdwh_etl_event_file 'create','Policy'
if (select top 1 RuNStatus from #etlstatus where JobName like '%Claims'    order by RunTime Desc) = 'OK'
    execute [db-au-stage].dbo.etlsp_cmdwh_etl_event_file 'create','Claims'
if (select top 1 RuNStatus from #etlstatus where JobName like '%e5' order by RunTime Desc) = 'OK'
    execute [db-au-stage].dbo.etlsp_cmdwh_etl_event_file 'create','e5'
if (select top 1 RuNStatus from #etlstatus where JobName like '%Corporate' order by RunTime Desc) = 'OK'
    execute [db-au-stage].dbo.etlsp_cmdwh_etl_event_file 'create','Corporate'
if (select top 1 RuNStatus from #etlstatus where JobName like '%TIAS' order by RunTime Desc) = 'OK'
    execute [db-au-stage].dbo.etlsp_cmdwh_etl_event_file 'create','TIAS'
if (select top 1 RuNStatus from #etlstatus where JobName = 'ULDWH02 - ETL021 Penguin' order by RunTime Desc) = 'OK'
    execute [db-au-stage].dbo.etlsp_cmdwh_etl_event_file 'create','Penguin'
if (select top 1 RuNStatus from #etlstatus where JobName like '%EMC AU' order by RunTime Desc) = 'OK'
    execute [db-au-stage].dbo.etlsp_cmdwh_etl_event_file 'create','EMC'
if (select top 1 RuNStatus from #etlstatus where JobName like '%EMC UK' order by RunTime Desc) = 'OK'
    execute [db-au-stage].dbo.etlsp_cmdwh_etl_event_file 'create','EMCUK'
if (select top 1 RuNStatus from #etlstatus where JobName like '%Carebase' order by RunTime Desc) = 'OK'
    execute [db-au-stage].dbo.etlsp_cmdwh_etl_event_file 'create','Carebase'
if (select top 1 RuNStatus from #etlstatus where JobName like '%ETL028 Penguin Data Loader' order by RunTime Desc) = 'OK'
    execute [db-au-stage].dbo.etlsp_cmdwh_etl_event_file 'create','PenguinDataLoader'
if (select top 1 RuNStatus from #etlstatus where JobName like '%ETL035 Penguin UK%' order by RunTime Desc) = 'OK'
    execute [db-au-stage].dbo.etlsp_cmdwh_etl_event_file 'create','PenguinUK'
if (select top 1 RuNStatus from #etlstatus where JobName like '%ETL038 Penguin Data Loader UK%' order by RunTime Desc) = 'OK'
    execute [db-au-stage].dbo.etlsp_cmdwh_etl_event_file 'create','PenguinDataLoaderUK'
if (select top 1 RuNStatus from #etlstatus where JobName like '%ETL064 Penguin US%' order by RunTime Desc) = 'OK'
    execute [db-au-stage].dbo.etlsp_cmdwh_etl_event_file 'create','PenguinUS'
if (select top 1 RuNStatus from #etlstatus where JobName like '%ETL063 Penguin Data Loader US%' order by RunTime Desc) = 'OK'
    execute [db-au-stage].dbo.etlsp_cmdwh_etl_event_file 'create','PenguinDataLoaderUS'
if (select top 1 RuNStatus from #etlstatus where JobName like '%ULDWH02 - ETL041 CISCO CALLS%' order by RunTime Desc) = 'OK'
    execute [db-au-stage].dbo.etlsp_cmdwh_etl_event_file 'create','CiscoCalls'




GO
