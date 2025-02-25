USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penDataQueueUS]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_penDataQueueUS]
as
begin

/************************************************************************************************************************************
Author:         Linus Tor
Date:           20160321
Prerequisite:   Requires Penguin Data Loader US ETL successfully run.
Description:
Change History:
                20160321 - LT - Created
				
*************************************************************************************************************************************/

    set nocount on

    /*************************************************************/
    --select data into temporary table
    /*************************************************************/
    if object_id('etl_penDataQueueUS') is not null
        drop table etl_penDataQueueUS

     select
        CountryKey,
        CompanyKey,
        DomainKey,
        left(PrefixKey + convert(varchar,d.DataQueueID), 41) collate database_default as DataQueueKey,
        left(PrefixKey + convert(varchar,d.JobID), 41) collate database_default as JobKey,
        d.DataQueueID,
        d.JobID,
        d.DataID,
        d.DataQueueTypeID,
        d.DataValue,
        d.Comment,
        d.RetryCount,
        d.Status,
        dbo.xfn_ConvertUTCtoLocal(d.CreateDateTime, TimeZone) as CreateDateTime,
        dbo.xfn_ConvertUTCtoLocal(d.CreateDateTime, TimeZone) as UpdateDateTime,
		d.TrooperName,
		dbo.xfn_ConvertUTCtoLocal(d.LastSourceUpdated, TimeZone) as LastSourceUpdated
	into etl_penDataQueueUS        
    from
        penguin_tblDataQueue_uscm d
        inner join penguin_tblJob_uscm j on
            d.JobID = j.JobID
        cross apply dbo.fn_GetDomainKeys(j.DomainID, j.Company, 'US') dk
        
    /*************************************************************/
    --delete existing data import or create table if table doesnt exist
    /*************************************************************/
    if object_id('[db-au-cmdwh].dbo.penDataQueue') is null
    begin

        create table [db-au-cmdwh].dbo.penDataQueue
        (
            CountryKey varchar(2) null,
            CompanyKey varchar(5) null,
            DomainKey varchar(41) null,
            DataQueueKey varchar(41) null,
            JobKey varchar(41) null,
            DataQueueID int null,
            JobID int null,
            DataID varchar(300) null,
            DataQueueTypeID int null,
            DataValue xml,
            Comment varchar(2000) null,
            RetryCount int null,
            [Status] varchar(15) null,
            CreateDateTime datetime null,
            UpdateDateTime datetime null,
			TrooperName varchar(100) null
        )

        create clustered index idx_penDataQueue_DataQueueKey on [db-au-cmdwh].dbo.penDataQueue(DataQueueKey)
        create index idx_penDataQueue_JobKey on [db-au-cmdwh].dbo.penDataQueue(JobKey)
        create index idx_penDataQueue_CountryKey on [db-au-cmdwh].dbo.penDataQueue(CountryKey)
        create index idx_penDataQueue_CreateDateTime on [db-au-cmdwh].dbo.penDataQueue(CreateDateTime)
        create index idx_penDataQueue_DataID on [db-au-cmdwh].dbo.penDataQueue(DataID, CountryKey, CompanyKey, CountrySet)

    end
    else
    begin

        delete a
        from
            [db-au-cmdwh].dbo.penDataQueue a
            inner join etl_penDataQueueUS b on
                a.DataQueueKey = b.DataQueueKey

    end


    /*************************************************************/
    -- Transfer data from etl_penDataQueueUK to [db-au-cmdwh].dbo.penDataQueue
    /*************************************************************/
    insert into [db-au-cmdwh].dbo.penDataQueue with (tablockx)
    (
        CountryKey,
        CompanyKey,
        DomainKey,
        DataQueueKey,
        JobKey,
        DataQueueID,
        JobID,
        DataID,
        DataQueueTypeID,
        DataValue,
        Comment,
        RetryCount,
        Status,
        CreateDateTime,
        UpdateDateTime,
		TrooperName,
		LastSourceUpdated
    )
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        DataQueueKey,
        JobKey,
        DataQueueID,
        JobID,
        DataID,
        DataQueueTypeID,
        DataValue,
        Comment,
        RetryCount,
        Status,
        CreateDateTime,
        UpdateDateTime,
		TrooperName,
		LastSourceUpdated
    from
        etl_penDataQueueUS

end

GO
