USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL042_VerintActivity]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_ETL042_VerintActivity]
as
begin
/************************************************************************************************************************************
Author:         Philip Wong
Date:           20140910
Prerequisite:   Requires Verint database.                
Description:    populates verActivity table in [db-au-cmdwh]
Parameters:        
Change History:
                20140910 - PW - Procedure created
                20141015 - LS - Refactoring
                                Use batch logging
                                Drop media for now, causing duplication
                                
*************************************************************************************************************************************/

    set nocount on

    declare @rptStartDate datetime
    declare @rptEndDate datetime
    declare @SQL varchar(8000)
    
    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int
        
    declare @mergeoutput table (MergeAction varchar(20))

    select
        @name = object_name(@@procid)
        
    exec syssp_getrunningbatch
        @SubjectArea = 'VERINT ODS',
        @BatchID = @batchid out,
        @StartDate = @start out,
        @EndDate = @end out
        
    --create table if not exists
    if object_id('[db-au-cmdwh].dbo.verActivity') is null
    begin
    
        create table [db-au-cmdwh].dbo.verActivity
        (
            [BIRowID] bigint not null identity(1,1),
            [ActivityKey] int not null,
            [ActivityName] nvarchar(255) not null,
            [ActivityDescription] nvarchar(255) not null,
            [ActivityMedia] nvarchar(50) not null,
            [CreateBatchID] int null,
            [UpdateBatchID] int null
        ) 
        
        create clustered index idx_verActivity_BIRowID on [db-au-cmdwh].dbo.verActivity(BIRowID)
        create nonclustered index idx_verActivity_ActivityKey on [db-au-cmdwh].dbo.verActivity(ActivityKey)
        
        --populate activity with default unknown values
        insert [db-au-cmdwh].dbo.verActivity
        (
            ActivityKey,
            ActivityName,
            ActivityDescription,
            ActivityMedia
        )
        values
        (
            -1,
            '',
            '',
            ''
        )

    end    

    if object_id('etl_verActivity') is not null 
        drop table etl_verActivity

    select 
        ACTIVITY.ID ActivityKey,
        isnull(ACTIVITY.NAME,'') ActivityName,
        isnull(ACTIVITY.DESCRIPTION,'') ActivityDescription,
        '' ActivityMedia
        --,
        --isnull(MEDIA.NAME, '') ActivityMedia
    into etl_verActivity
    from 
        [ULWFM01].[BPMAINDB].dbo.ACTIVITY
        --left join [ULWFM01].[BPMAINDB].dbo.ACTIVITYMEDIA on    
        --    ACTIVITYMEDIA.ACTIVITYID = ACTIVITY.ID
        --left join [ULWFM01].[BPMAINDB].dbo.MEDIA on    
        --    ACTIVITYMEDIA.MEDIAID = MEDIA.SID

    select 
        @sourcecount = count(*)
    from
        etl_verActivity
        
    begin transaction

    begin try
        
        merge into [db-au-cmdwh].dbo.verActivity with(tablock) t
        using etl_verActivity s on 
            s.ActivityKey = t.ActivityKey
            
        when matched then
        
            update
            set
                ActivityName = s.ActivityName,
                ActivityDescription = s.ActivityDescription,
                ActivityMedia = s.ActivityMedia,
                UpdateBatchID = @batchid
                
        when not matched by target then
            insert 
            (
                ActivityKey,
                ActivityName,
                ActivityDescription,
                ActivityMedia,
                CreateBatchID
            )
            values
            (
                s.ActivityKey,
                s.ActivityName,
                s.ActivityDescription,
                s.ActivityMedia,
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
            @SourceInfo = 'verActivity data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name
        
    end catch    

    if @@trancount > 0
        commit transaction

end
GO
