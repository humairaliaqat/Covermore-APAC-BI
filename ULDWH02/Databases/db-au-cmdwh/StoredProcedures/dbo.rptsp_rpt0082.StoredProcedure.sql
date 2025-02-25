USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0082]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[rptsp_rpt0082]
as

set nocount on


/****************************************************************************************************/
--    Name:            dbo.rptsp_rpt0082
--    Author:            Linus Tor
--    Date Created:    20100930
--    Description:    This stored procedure shows SQL Server Agent jobs status for OXLEY and TESTDATAWH01.
--
--    Parameters:
--
--    Change History:    20100930 - LT - Created
--                    20101210 - LT - Migrated the stored procedure and Crystal Reports to TESTDATAWH01
--                    20111020 - LS - Add Quote job
--                    20120606 - LS - Add EMC
--                    20120606 - LS - Add Carebase
--                  20120222 - LS - Add NSurvey
--                    20130416 - LT - Removed TestDataWh01 and BHDWH01 ETL Jobs
--                    20130801 - LT - Removed ETL job history on BHDWH02. Added ETL035 and ETL037 jobs
--                  20140210 - LS - Update OXLEY's job names
--                                  Add Finance ETL
--                    20140703 - LT - Removed OXLEY refresh jobs as BI no longer support these databases.
--                  20150310 - LS - removed:
--                                  ETL005 TIAS
--                                  ETL016 Penguin Test Policy
--                                  ETL032 Sales Cube
--                                  added:
--                                  ETL004 Claim Refresh
--                                  ETL022 Penguin Refresh
--                                  ETL033 Finance Cube Intraday
--                                  ETL034 Carebase Refresh
--                                  ETL038 Penguin Date Loader UK
--                                  ETL042 Verint
--                                  ETL043 CDG Quote
--                                  ETL044 EWS
--                                  ETL045 Telephony Star
--                    20150701 - LT - Added ETL046 - EWS BI
--                    20160215 - LS - added:
--                                  ETL049 Claim STAR
--                                  ETL054 Bot Processing
--
/****************************************************************************************************/

select
    convert(
        varchar(200),
        case
            when j.[name] like '%ETL002%' then 'ULDWH02 - ETL002 Policy'
            when j.[name] like '%ETL004%' then 'ULDWH02 - ETL004 Claims'
            when j.[name] like '%ETL007%' then 'ULDWH02 - ETL007 Corporate'
            when j.[name] like '%ETL008%' then 'ULDWH02 - ETL008 e5'
            when j.[name] like '%ETL021%' then 'ULDWH02 - ETL021 Penguin'
            when j.[name] like '%ETL022%' then 'ULDWH02 - ETL021 Penguin Intraday Refresh'
            when j.[name] like '%ETL024%' then 'ULDWH02 - ETL024 EMC'
            when j.[name] like '%ETL025%' then 'ULDWH02 - ETL025 NSurvey'
            when j.[name] like '%ETL027%' then 'ULDWH02 - ETL027 Carebase'
            when j.[name] like '%ETL028%' then 'ULDWH02 - ETL028 Penguin Data Loader'
            when j.[name] like '%ETL031%' then 'ULDWH02 - ETL031 DocGen'
            when j.[name] like '%ETL032%' then 'ULDWH02 - ETL032 Policy Cube'
            when j.[name] like '%ETL033%' then 'ULDWH02 - ETL033 Finance Cube'
            when j.[name] like '%ETL034%' then 'ULDWH02 - ETL034 Carebase Intraday Refresh'
            when j.[name] like '%ETL035%' then 'ULDWH02 - ETL035 Penguin UK'
            when j.[name] like '%ETL037%' then 'ULDWH02 - ETL037 Bank Migration'
            when j.[name] like '%ETL041%' then 'ULDWH02 - ETL041 CISCO Data'
            when j.[name] like '%ETL042%' then 'ULDWH02 - ETL042 Verint Data'
            when j.[name] like '%ETL043%' then 'ULDWH02 - ETL043 CDG Quote'
            when j.[name] like '%ETL044%IntraDay' then 'ULDWH02 - ETL044 Exchange Intraday Refresh'
            when j.[name] like '%ETL044%' then 'ULDWH02 - ETL044 Exchange Data'
            when j.[name] like '%ETL045%' then 'ULDWH02 - ETL045 Telephony Star'
            when j.[name] like '%sys_Populate_LDAP%' then 'ULDWH02 - LDAP Data'
            when j.[name] like '%ETL046%' then 'ULDWH02 - ETL046 - EWS BI'
            when j.[name] like '%ETL049%' then 'ULDWH02 - ETL049 - Claim STAR'
            when j.[name] like '%ETL054%' then 'ULDWH02 - ETL054 - Bot Processing'
        end
    ) as JobName,
    case
        when h.run_status = 1 then 'OK'
        else 'FAILED'
    end as RunStatus,
    convert(datetime, rtrim(h.run_date)) + (h.run_time * 9 + h.run_time % 10000 * 6 + h.run_time % 100 * 10) / 216e4 as RunTime,
    left(right('000000' + convert(varchar(6), run_duration), 6),2) + ':' + substring(right('000000' + convert(varchar(6), run_duration), 6),3,2) + ':' + right(right('000000' + convert(varchar(6), run_duration), 6),2) as RunDuration
from
    ULDWH02.msdb.dbo.sysjobhistory h
    inner join ULDWH02.msdb.dbo.sysjobs j on
        h.job_id = j.job_id and
        h.step_id = 0
where
    h.run_date = convert(varchar(8),getdate(),112) and
    j.[name] in
    (
        'ETL002_Legacy_UK_Policy',
        'ETL004_Claims_Data_Model',
        'ETL004_Claims_Refresh',
        'ETL007_Corporate_Data_Model',
        'ETL008_e5_Content',
        'ETL021_Penguin_Data_Model',
        'ETL022_Penguin_Refresh',
        'ETL024_EMC_Data_Model_AU',
        'ETL025_NSurvey_Data_Model',
        'ETL027_Carebase_Data_Model',
        'ETL028_Penguin_Data_Loader',
        'ETL031_DocGen_Data_Model',
        'ETL032_Policy_Star_Incremental',
        'ETL033_Finance_Data_Incremental',
        'ETL035_Penguin_Data_Model_UK',
        'ETL037_Bank_Migration',
        'ETL038_Penguin_Data_Loader_UK',
        'ETL041_Cisco',
        'ETL042_VERINT',
        'ETL043_CDG_Quote',
        'ETL044_Exchange_Web_Service_IntraDay',
        'ETL045_Telephony_Star',
        'ETL0XX_Populate_LDAP',
        'ETL046_EWS_BI',
        'ETL049_Claim_STAR',
        'ETL054_BotProcessing'
    )
order by 3
GO
