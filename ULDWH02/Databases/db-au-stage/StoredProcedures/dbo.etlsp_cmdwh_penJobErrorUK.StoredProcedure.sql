USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penJobErrorUK]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_penJobErrorUK]
as
begin

/************************************************************************************************************************************
Author:         Linus Tor
Date:           20140117
Prerequisite:   Requires Penguin Data Loader UK ETL successfully run.
Description:
Change History:
                20140117 - LT - Procedure created for Penguin Data Loader UK
*************************************************************************************************************************************/

    set nocount on

    /*************************************************************/
    --select data into temporary table
    /*************************************************************/
    if object_id('etl_penJobErrorUK') is not null
        drop table etl_penJobErrorUK
 
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        left(PrefixKey + convert(varchar,d.ID),41) collate database_default as JobErrorKey,
        left(PrefixKey + convert(varchar,d.JobID),41) collate database_default as JobKey,
        d.ID,
        d.JobID,
        d.Description,
        dbo.xfn_ConvertUTCtoLocal(d.CreateDateTime, TimeZone) as CreateDateTime,
        d.ErrorSource,
        d.DataID,
        d.SourceData
	into etl_penJobErrorUK        
    from
        penguin_tblJobError_ukcm d
        inner join penguin_tblJob_ukcm j on
            d.JobID = j.JobID
        cross apply dbo.fn_GetDomainKeys(j.DomainID, j.Company, 'UK') dk
        
    /*************************************************************/
    --delete existing job data or create table if table doesnt exist
    /*************************************************************/
    if object_id('[db-au-cmdwh].dbo.penJobError') is null
    begin

        create table [db-au-cmdwh].dbo.penJobError
        (
            CountryKey varchar(2) null,
            CompanyKey varchar(3) null,
            DomainKey varchar(41) null,
            JobErrorKey varchar(41) null,
            JobKey varchar(41) null,
            ID int null,
            JobID int null,
            [Description] varchar(max) null,
            CreateDateTime datetime null,
            ErrorSource varchar(15) null,
            DataID varchar(300) null,
            SourceData varchar(max) null
        )

        create clustered index idx_penJobError_JobErrorKey on [db-au-cmdwh].dbo.penJobError(JobErrorKey)
        create index idx_penJobError_CountryKey on [db-au-cmdwh].dbo.penJobError(CountryKey)
        create index idx_penJobError_CompanyKey on [db-au-cmdwh].dbo.penJobError(CompanyKey)
        create index idx_penJobError_JobKey on [db-au-cmdwh].dbo.penJobError(JobKey)
        create index idx_penJobError_DataID on [db-au-cmdwh].dbo.penJobError(DataID)

    end
    else
    begin

        delete [db-au-cmdwh].dbo.penJobError
        from [db-au-cmdwh].dbo.penJobError a
            inner join etl_penJobErrorUK b on
                a.JobErrorKey = b.JobErrorKey

    end


    /*************************************************************/
    -- Transfer data from etl_penDataImport to [db-au-cmdwh].dbo.penDataImport
    /*************************************************************/
    insert into [db-au-cmdwh].dbo.penJobError with (tablockx)
    (
        CountryKey,
        CompanyKey,
        DomainKey,
        JobErrorKey,
        JobKey,
        ID,
        JobID,
        [Description],
        CreateDateTime,
        ErrorSource,
        DataID,
        SourceData
    )
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        JobErrorKey,
        JobKey,
        ID,
        JobID,
        [Description],
        CreateDateTime,
        ErrorSource,
        DataID,
        SourceData
    from
        etl_penJobErrorUK

end
GO
