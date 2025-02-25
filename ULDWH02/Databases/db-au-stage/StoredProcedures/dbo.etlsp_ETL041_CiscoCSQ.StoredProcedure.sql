USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL041_CiscoCSQ]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL041_CiscoCSQ]
as
begin
/************************************************************************************************************************************
Author:         Philip Wong
Date:           20140909
Prerequisite:   Requires CISCO Informix database.                
Description:    populates cisCSQ table in [db-au-cmdwh]
Parameters:        
Change History:
                20140909 - PW - Procedure created
                20140910 - LS - refactoring
                                add batch
                                index
                
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
        @SubjectArea = 'CISCO ODS',
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
    if object_id('[db-au-cmdwh].dbo.cisCSQ') is null
    begin
    
        create table [db-au-cmdwh].dbo.cisCSQ
        (
            BIRowID bigint not null identity(1,1),
            CSQKey nvarchar(50) not null,
            ContactServiceQueueID int not null,
            ProfileID int not null,
            CSQName nvarchar(50) not null,
            SLAPercentage int not null,
            SLA int not null,
            SelectionCriteria nvarchar(50) not null,
            isActive bit not null,
            DateInactive datetime null,
            CreateBatchID int null,
            UpdateBatchID int null
        ) 
        
        create clustered index idx_cisCSQ_BIRowID on [db-au-cmdwh].dbo.cisCSQ (BIRowID)
        create nonclustered index idx_cisCSQ_CSQKey on [db-au-cmdwh].dbo.cisCSQ(CSQKey) include(CSQName,SLAPercentage,SLA,isActive,DateInactive)
        
    end    

    if object_id('tempdb..#cisCSQ') is not null
        drop table #cisCSQ

    select
        left('AU-CM' + convert(nvarchar,isnull(a.ProfileID,0)) + '-' + convert(nvarchar,isnull(a.recordid,0)),50) as CSQKey,            --following penguing country + '-' + company + domain + '-' + id
        isnull(a.contactservicequeueid,0) as ContactServiceQueueID,
        isnull(a.ProfileID,0) as ProfileID,
        isnull(a.csqname,'') as CSQName,
        isnull(a.servicelevelpercentage,0) as SLAPercentage,
        isnull(a.servicelevel,0) as SLA,
        isnull(a.selectioncriteria,'') as SelectionCriteria,
        isnull(a.Active,0) as isActive,
        convert(datetime, a.DateInactive) as DateInactive
    into #cisCSQ
    from 
        openquery(
            CISCO,
            '
            select
                csq.recordid,
                csq.profileid,
                csq.contactservicequeueid,
                csq.csqname,
                csq.servicelevelpercentage,
                csq.servicelevel,
                csq.selectioncriteria,
                csq.active,
                csq.dateinactive
            from 
                Contactservicequeue csq
            ' 
        ) a

    select 
        @sourcecount = count(*)
    from
        #cisCSQ   

    begin transaction

    begin try
        
        merge into [db-au-cmdwh].dbo.cisCSQ with(tablock) t
        using #cisCSQ s on 
            s.CSQKey = t.CSQKey
            
        when 
            matched and
            binary_checksum(
                t.CSQName,
                t.SLAPercentage,
                t.SLA,
                t.SelectionCriteria,
                t.isActive,
                t.DateInactive
            ) <>
            binary_checksum(
                s.CSQName,
                s.SLAPercentage,
                s.SLA,
                s.SelectionCriteria,
                s.isActive,
                s.DateInactive
            )
        then
        
            update
            set
                CSQName = s.CSQName,
                SLAPercentage = s.SLAPercentage,
                SLA = s.SLA,
                SelectionCriteria = s.SelectionCriteria,
                isActive = s.isActive,
                DateInactive = s.DateInactive,
                UpdateBatchID = @batchid
                
        when not matched by target then
            insert 
            (
                CSQKey,
                ContactServiceQueueID,
                ProfileID,
                CSQName,
                SLAPercentage,
                SLA,
                SelectionCriteria,
                isActive,
                DateInactive,
                CreateBatchID
            )
            values
            (
                s.CSQKey,
                s.ContactServiceQueueID,
                s.ProfileID,
                s.CSQName,
                s.SLAPercentage,
                s.SLA,
                s.SelectionCriteria,
                s.isActive,
                s.DateInactive,
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
            @SourceInfo = 'cisCSQ data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name
        
    end catch    

    if @@trancount > 0
        commit transaction

end
GO
