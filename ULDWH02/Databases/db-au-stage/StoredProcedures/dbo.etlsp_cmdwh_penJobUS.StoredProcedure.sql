USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penJobUS]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_penJobUS]
as
begin

/************************************************************************************************************************************
Author:         Linus Tor
Date:           20160321
Prerequisite:   Requires Penguin Data Loader US ETL successfully run.
Description:
Change History:
                20160321 - LT - Created
				20160830 - PZ - Penguin 20.5 release, added IsPaused column

*************************************************************************************************************************************/

    set nocount on

    /*************************************************************/
    --select data into temporary table
    /*************************************************************/

    if object_id('etl_penJobUS') is not null
        drop table etl_penJobUS

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        left(PrefixKey + convert(varchar,d.JobID), 41) collate database_default as JobKey,
        d.JobID,
        d.JobName,
        d.JobCode,
        d.JobType,
        d.JobDesc,
        d.GroupCodes,
        d.DataQueueType,
        d.MaxRetryCount,
        d.CodeModule,
        d.JobData,
        d.Status,
        dbo.xfn_ConvertUTCtoLocal(d.CreateDateTime, TimeZone) as CreateDateTime,
        dbo.xfn_ConvertUTCtoLocal(d.UpdateDateTime, TimeZone) as UpdateDateTime,
        Company,
        d.DomainID,
		dbo.xfn_ConvertUTCtoLocal(d.LastRunTime, TimeZone) as LastRunTime,
		d.IsPaused
    into etl_penJobUS        
    from
        penguin_tblJob_uscm d
        cross apply dbo.fn_GetDomainKeys(d.DomainID, Company, 'US') dk

    /*************************************************************/
    --delete existing job data or create table if table doesnt exist
    /*************************************************************/
    if object_id('[db-au-cmdwh].dbo.penJob') is null
    begin

        create table [db-au-cmdwh].dbo.penJob
        (
            CountryKey varchar(2) null,
            CompanyKey varchar(5) null,
            DomainKey varchar(41) null,
            JobKey varchar(41) null,
            JobID int null,
            JobName varchar(100) null,
            JobCode varchar(50) null,
            JobType varchar(50) null,
            JobDesc varchar(500) null,
            GroupCodes varchar(100) null,
            DataQueueType varchar(50) null,
            MaxRetryCount int null,
            CodeModule varchar(255) null,
            JobData XML null,
            Status varchar(15) null,
            CreateDateTime datetime null,
            UpdateDateTime datetime null,
            Company varchar(20) null,
            DomainID int null,
			LastRunTime datetime null,
			IsPaused bit null
        )

        create clustered index idx_penJob_JobKey on [db-au-cmdwh].dbo.penJob(JobKey)
        create index idx_penJob_CountryKey on [db-au-cmdwh].dbo.penJob(CountryKey)
        create index idx_penJob_CompanyKey on [db-au-cmdwh].dbo.penJob(CompanyKey, CountrySet)

    end
    else
    begin
		delete [db-au-cmdwh].dbo.penJob
		from [db-au-cmdwh].dbo.penJob a
			join [db-au-stage].dbo.etl_penJobUS b on
				a.JobKey = b.JobKey
    end


    /*************************************************************/
    -- Transfer data from etl_penDataImport to [db-au-cmdwh].dbo.penDataImport
    /*************************************************************/
    insert into [db-au-cmdwh].dbo.penJob with (tablockx)
    (
        CountryKey,
        CompanyKey,
        DomainKey,
        JobKey,
        JobID,
        JobName,
        JobCode,
        JobType,
        JobDesc,
        GroupCodes,
        DataQueueType,
        MaxRetryCount,
        CodeModule,
        JobData,
        [Status],
        CreateDateTime,
        UpdateDateTime,
        Company,
        DomainID,
		LastRunTime,
		IsPaused
    )
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        JobKey,
        JobID,
        JobName,
        JobCode,
        JobType,
        JobDesc,
        GroupCodes,
        DataQueueType,
        MaxRetryCount,
        CodeModule,
        JobData,
        [Status],
        CreateDateTime,
        UpdateDateTime,
        Company,
        DomainID,
		LastRunTime,
		IsPaused
    from
        etl_penJobUS


end

GO
