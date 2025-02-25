USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL042_VerintOrganisation]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_ETL042_VerintOrganisation]
as
begin

/************************************************************************************************************************************
Author:         Philip Wong
Date:           20140910
Prerequisite:   Requires Verint database.                
Description:    populates verOrganisation table in [db-au-cmdwh]
Parameters:        
Change History:
                20140910 - PW - Procedure created
                20141015 - LS - Refactoring
                                Use batch logging
                
*************************************************************************************************************************************/

    set nocount on

    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int
        
    declare @mergeoutput table (MergeAction varchar(20))

    exec syssp_getrunningbatch
        @SubjectArea = 'VERINT ODS',
        @BatchID = @batchid out,
        @StartDate = @start out,
        @EndDate = @end out

    select
        @name = object_name(@@procid)
    
    exec syssp_genericerrorhandler 
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'
        
    --create table if not exists
    if object_id('[db-au-cmdwh].dbo.verOrganisation') is null
    begin
    
        create table [db-au-cmdwh].dbo.verOrganisation
        (
            [BIRowID] bigint not null identity(1,1),
            [OrganisationKey] int not null,
            [OrganisationName] nvarchar(255) not null,
            [OrganisationDescription] nvarchar(255) not null,
            [Timezone] nvarchar(50) not null,
            [CreateBatchID] int null,
            [UpdateBatchID] int null
        ) 
        
        create clustered index idx_verOrganisation_BIRowID on [db-au-cmdwh].dbo.verOrganisation(BIRowID)
        create nonclustered index idx_verOrganisation_OrganisationKey on [db-au-cmdwh].dbo.verOrganisation(OrganisationKey)
        
        --populate organisation with default unknown values
        insert [db-au-cmdwh].dbo.verOrganisation
        (
            OrganisationKey,
            OrganisationName,
            OrganisationDescription,
            Timezone
        )
        values
        (
            -1,
            '',
            '',
            ''
        )

    end    


    if object_id('etl_verOrganisation') is not null
        drop table etl_verOrganisation

    select 
        ID OrganisationKey,
        isnull(NAME,'') OrganisationName,
        isnull(DESCRIPTION,'') OrganisationDescription,
        isnull(TIMEZONE,'') Timezone
    into etl_verOrganisation
    from 
        [ULWFM01].[BPMAINDB].dbo.ORGANIZATION

    select 
        @sourcecount = count(*)
    from
        etl_verOrganisation

    begin transaction

    begin try
        
        merge into [db-au-cmdwh].dbo.verOrganisation with(tablock) t
        using etl_verOrganisation s on 
            s.OrganisationKey = t.OrganisationKey
            
        when matched then
        
            update
            set
                OrganisationName = s.OrganisationName,
                OrganisationDescription = s.OrganisationDescription,
                Timezone = s.Timezone,
                UpdateBatchID = @batchid
                
        when not matched by target then
            insert 
            (
                OrganisationKey,
                OrganisationName,
                OrganisationDescription,
                Timezone,
                CreateBatchID
            )
            values
            (
                s.OrganisationKey,
                s.OrganisationName,
                s.OrganisationDescription,
                s.Timezone,
                @batchid
            )

        output $action into @mergeoutput
        ;

        select 
            @insertcount = 
                sum(
                    case
                        when MergeAction = 'insert' then 1
                        else 0
                    end
                ),
            @updatecount = 
                sum(
                    case
                        when MergeAction = 'update' then 1
                        else 0
                    end
                )
        from
            @mergeoutput

        exec syssp_genericerrorhandler 
            @LogToTable = 1,
            @ErrorCode = '0',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Finished',
            @LogSourceCount = @sourcecount,
            @LogInsertCount = @insertcount,
            @LogUpdateCount = @updatecount

    end try
    
    begin catch
    
        if @@trancount > 0
            rollback transaction
            
        exec syssp_genericerrorhandler 
            @SourceInfo = 'verOrganisation data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name
        
    end catch    

    if @@trancount > 0
        commit transaction

end
GO
