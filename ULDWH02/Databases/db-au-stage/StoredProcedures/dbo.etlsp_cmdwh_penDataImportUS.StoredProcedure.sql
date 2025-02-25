USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penDataImportUS]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_penDataImportUS]
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
    if object_id('etl_penDataImportUS') is not null 
        drop table etl_penDataImportUS        
 
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        left(PrefixKey + convert(varchar,d.ID), 41) collate database_default as DataImportKey,
        d.ID,
        d.SourceReference,
        d.GroupCode,
        dbo.xfn_ConvertUTCtoLocal(d.CreateDateTime, TimeZone) as CreateDateTime,
        dbo.xfn_ConvertUTCtoLocal(d.CreateDateTime, TimeZone) as UpdateDateTime,
        d.JobID,
        d.Status
	into etl_penDataImportUS       
    from
        penguin_tblDataImport_uscm d
        inner join penguin_tblJob_uscm j on d.JobID = j.JobID
        cross apply dbo.fn_GetDomainKeys(j.DomainID, 'CM', 'US') dk
        
    /*************************************************************/
    --delete existing data import or create table if table doesnt exist
    /*************************************************************/
    if object_id('[db-au-cmdwh].dbo.penDataImport') is null
    begin

        create table [db-au-cmdwh].dbo.penDataImport
        (
            CountryKey varchar(2) null,
            CompanyKey varchar(5) null,
            DomainKey varchar(41) null,
            DataImportKey varchar(41) null,
            ID int null,
            SourceReference varchar(100) null,
            GroupCode varchar(50) null,
            CreateDateTime datetime null,
            UpdateDateTime datetime null,
            JobID int null,
            [Status] varchar(50) null
        )

        create clustered index idx_penDataImport_DataImportKey on [db-au-cmdwh].dbo.penDataImport(DataImportKey)
        create index idx_penDataImport_CountryKey on [db-au-cmdwh].dbo.penDataImport(CountryKey)
        create index idx_penDataImport_CompanyKey on [db-au-cmdwh].dbo.penDataImport(CompanyKey, CountrySet)

    end
    else
    begin

        delete a
        from 
            [db-au-cmdwh].dbo.penDataImport a
            inner join etl_penDataImportUS b on
                a.DataImportKey = b.DataImportKey
                
    end


    /*************************************************************/
    -- Transfer data from etl_penDataImport to [db-au-cmdwh].dbo.penDataImport
    /*************************************************************/
    insert into [db-au-cmdwh].dbo.penDataImport with (tablockx)
    (
        CountryKey,
        CompanyKey,
        DomainKey,
        DataImportKey,
        ID,
        SourceReference,
        GroupCode,
        CreateDateTime,
        UpdateDateTime,
        JobID,
        Status
    )
    select
        CountryKey,
        CompanyKey,
        left(DomainKey,41) as DomainKey,
        left(DataImportKey,41) as DataImportKey,
        ID,
        SourceReference,
        GroupCode,
        CreateDateTime,
        UpdateDateTime,
        JobID,
        Status
    from
        etl_penDataImportUS

end

GO
