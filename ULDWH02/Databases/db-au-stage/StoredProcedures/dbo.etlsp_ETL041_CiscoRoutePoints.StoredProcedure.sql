USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL041_CiscoRoutePoints]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_ETL041_CiscoRoutePoints]
as
begin
/************************************************************************************************************************************
Author:         Leo
Date:           20150326
Prerequisite:   Requires CISCO Informix database.                
Description:    populates cisRoutePoints table in [db-au-cmdwh]
Parameters:        
Change History:
                20150326 - LS - created
                
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
    if object_id('[db-au-cmdwh].dbo.cisRoutePoints') is null
    begin
    
        create table [db-au-cmdwh].dbo.cisRoutePoints
        (
            BIRowID bigint not null identity(1,1),
            RoutePoint nvarchar(30) null,
            InternalName nvarchar(100) null,
            GroupName nvarchar(100) null,
            CreateBatchID int null,
            UpdateBatchID int null
        ) 
        
        create clustered index idx_cisRoutePoints_BIRowID on [db-au-cmdwh].dbo.cisRoutePoints (BIRowID)
        create nonclustered index idx_cisRoutePoints_AgentLogin on [db-au-cmdwh].dbo.cisRoutePoints(RoutePoint) include (InternalName,GroupName)
        create nonclustered index idx_cisRoutePoints_GroupName on [db-au-cmdwh].dbo.cisRoutePoints(GroupName) include (RoutePoint)
        
        --populate agent with default unknown values
        insert [db-au-cmdwh].dbo.cisRoutePoints
        (
            RoutePoint,
            InternalName,
            GroupName,
            CreateBatchID
        )
        values
        (
            '-1',
            'Unknown',
            'Unknown',
            @batchid
        )
        
    end 
    
    if object_id('tempdb..#cisRoutePoints') is not null
        drop table #cisRoutePoints
    
    select
        routepointnum RoutePoint,
        isnull(a.internalname, '') InternalName,
        isnull(a.groupname, '') GroupName
    into #cisRoutePoints
    from 
        openquery(
            CISCO,
            '
                select 
                    routepointnum,
                    internalname,
                    groupname
                from 
                    reportreference:routepoints
            ' 
        ) a
    where
        a.routepointnum is not null
        
    select 
        @sourcecount = count(*)
    from
        #cisRoutePoints   

    --insert data
    begin transaction

    begin try
        
        merge into [db-au-cmdwh].dbo.cisRoutePoints with(tablock) t
        using #cisRoutePoints s on 
            s.RoutePoint = t.RoutePoint
            
        when matched then
        
            update
            set
                InternalName = s.InternalName,
                GroupName = s.GroupName,
                UpdateBatchID = @batchid
                
        when not matched by target then
            insert 
            (
                RoutePoint,
                InternalName,
                GroupName,
                CreateBatchID
            )
            values
            (
                s.RoutePoint,
                s.InternalName,
                s.GroupName,
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
            @SourceInfo = 'cisRoutePoints data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name
        
    end catch    

    if @@trancount > 0
        commit transaction

end
GO
